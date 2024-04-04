#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function install_eventing_with_mesh() {

    KNATIVE_EVENTING_ISTIO_MANIFESTS_DIR="${SCRIPT_DIR}/release/artifacts"
    export KNATIVE_EVENTING_ISTIO_MANIFESTS_DIR

    GO111MODULE=off go get -u github.com/openshift-knative/hack/cmd/sobranch

    local release
    release=$(yq r "${SCRIPT_DIR}/project.yaml" project.tag)
    release=${release/knative-/}
    so_branch=$( $(go env GOPATH)/bin/sobranch --upstream-version "${release}")

    local operator_dir=/tmp/serverless-operator
    git clone --branch "${so_branch}" https://github.com/openshift-knative/serverless-operator.git $operator_dir || git clone --branch main https://github.com/openshift-knative/serverless-operator.git $operator_dir

    pushd $operator_dir || return $?

    export ON_CLUSTER_BUILDS=true
    export DOCKER_REPO_OVERRIDE=image-registry.openshift-image-registry.svc:5000/openshift-marketplace

    make OPENSHIFT_CI="true" SCALE_UP=5 TRACING_BACKEND=zipkin images install-certmanager install-strimzi install-kafka-with-mesh || return $?

    popd || return $?
}

install_eventing_with_mesh || exit 1
