#!/usr/bin/env bash

repo_root_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")/..

export SKIP_INITIALIZE=true
export GOPATH=/tmp/go
export GOCACHE=/tmp/go-cache
export ARTIFACTS=${ARTIFACT_DIR:-$(mktemp -u -t -d)}

pushd "${repo_root_dir}/third_party/eventing"
echo "Apply eventing submodule patches"
git apply -v ../../openshift/submodule-patches/eventing/*

echo "Install cert-manager"
kubectl apply -f third_party/cert-manager/01-cert-manager.crds.yaml
kubectl apply -f third_party/cert-manager/02-cert-manager.yaml

popd

"${repo_root_dir}/test/e2e-tests.sh"
