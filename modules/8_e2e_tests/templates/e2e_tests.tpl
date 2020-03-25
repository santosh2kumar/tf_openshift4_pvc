#!/bin/bash
sudo yum install -y golang git
mkdir -p /tmp/openshift_ws/src/github.com/openshift/
export TEST_DIR=/tmp/openshift_ws/src/github.com/openshift/
cd $TEST_DIR
git clone ${e2e_tests_git} origin
cd origin
git checkout ${e2e_tests_git_branch}
wget https://dl.k8s.io/v1.16.2/kubernetes-client-linux-ppc64le.tar.gz -O - | tar -xz
cp $TEST_DIR/origin/kubernetes/client/bin/kubectl /usr/bin/
./hack/update-generated-bindata.sh && make WHAT=cmd/openshift-tests
export KUBECONFIG=~/.kube/config
# To Override default repos
cat << EOREGISTRY > /tmp/kube-test-repo-list
quayK8sCSI: quay.io/multiarch-k8s-e2e
quayIncubator: quay.io/multiarch-k8s-e2e
e2eRegistry: quay.io/multiarch-k8s-e2e
gcRegistry: quay.io/multiarch-k8s-e2e
EOREGISTRY
export KUBE_TEST_REPO_LIST=/tmp/kube-test-repo-list
if [ ${e2e_tests_exclude_list_url} != "" ]; then
	curl -o excluded_tests ${e2e_tests_exclude_list_url}
fi
cat > invert_excluded.py <<EOSCRIPT; chmod +x invert_excluded.py
#!/usr/libexec/platform-python
import sys
all_tests = set()
excluded_tests = set()
for l in sys.stdin.readlines():
	all_tests.add(l.strip())
with open(sys.argv[1], "r") as f:
	for l in f.readlines():
	    excluded_tests.add(l.strip())
test_suite = all_tests - excluded_tests
for t in test_suite:
	print(t)
EOSCRIPT
_output/local/bin/linux/ppc64le/openshift-tests run openshift/conformance/parallel --dry-run | ./invert_excluded.py excluded_tests > test-suite.txt
mkdir -p ~/e2e_tests_results/
_output/local/bin/linux/ppc64le/openshift-tests run -f ./test-suite.txt openshift/conformance/parallel -o ~/e2e_tests_results/conformance-parallel-out.txt --junit-dir ~/e2e_tests_results/conformance-parallel
summary=$(cat ~/e2e_tests_results/conformance-parallel-out.txt | grep 'pass\|fail\|skip' | tail -1)
echo $summary |sed 's/error://' >> ~/e2e_tests_results/summary.txt
