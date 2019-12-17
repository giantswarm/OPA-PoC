package system

import data.kubernetes.namespaces

# If namespace depicts clusterid, add cluster config
# We only do these on create as user might have valid reason to change
# TODO could this be one patch? or at least can we extract the common checks?
# Couldn't make it one patch because of limitations of the ensure path functions
# Shortest patch to path must be first, as otherwise path creation will fail!!
patch[patchCode] {
    input.request.kind.kind = "App"
    isCreate

    # Checks if namespace is actually a cluster namespace
    ns := input.request.object.metadata.namespace
    some i
    namespaces[i].metadata.name == ns
    namespace := namespaces[i]
    namespace.metadata.labels.cluster
    clusterid := namespace.metadata.name

    patchCode := {"op": "add",
    "path": "/spec/kubeConfig/inCluster",
    "value": "false",}
}
patch[patchCode] {
    input.request.kind.kind = "App"
    isCreate

    # Checks if namespace is actually a cluster namespace
    ns := input.request.object.metadata.namespace
    some i
    namespaces[i].metadata.name == ns
    namespace := namespaces[i]
    namespace.metadata.labels.cluster
    clusterid := namespace.metadata.name
   
   patchCode := {"op": "add",
   "path": "/spec/kubeConfig/secret/name",
   "value": sprintf("%s-kubeconfig", [clusterid] ),}
}
patch[patchCode] {
    input.request.kind.kind = "App"
    isCreate

    # Checks if namespace is actually a cluster namespace
    ns := input.request.object.metadata.namespace
    some i
    namespaces[i].metadata.name == ns
    namespace := namespaces[i]
    namespace.metadata.labels.cluster
    clusterid := namespace.metadata.name

    patchCode := {"op": "add",
    "path": "/spec/kubeConfig/secret/namespace",
    "value": clusterid,}
}
patch[patchCode] {
    input.request.kind.kind = "App"
    isCreate

    # Checks if namespace is actually a cluster namespace
    ns := input.request.object.metadata.namespace
    some i
    namespaces[i].metadata.name == ns
    namespace := namespaces[i]
    namespace.metadata.labels.cluster
    clusterid := namespace.metadata.name

    patchCode := {"op": "add",
    "path": "/spec/kubeConfig/context/name",
    "value": clusterid,}
}
# TODO add here config, CM and secret

# Add all the required labels (currently only operator version)
# TODO do this also for appCatalogs
# TODO see how to escape "/" as it should be "app-operator.giantswarm.io/version"
patch[patchCode] {
    input.request.kind.kind = "App"
    isCreateOrUpdate

    # This is a hardcoded value as we are not changing the operator version for now
    not hasLabelValue[["app-operator.giantswarm.io", "1.0.0"]] with input as input.request.object
	patchCode = makeLabelPatch("add", "app-operator.giantswarm.io", "1.0.0", "")
}