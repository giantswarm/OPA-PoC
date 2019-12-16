package system

# If namespace depicts clusterid, add cluster config
# TODO could this be one patch? or at least can we extract teh common checks?
# Shortest patch to path must be first, as otherwise path creation will fail!!
patch[patchCode] {
    input.request.kind.kind = "App"
    # only on create as user might have valid reason to change
    isCreate

    # TODO check if namespace is actually cluster namespace, to only run this for clsuter name space
    # clsuter NS is labeled with cluster=clusterid, read namespace data from k8s and check for that label
    clusterid := input.request.object.metadata.namespace

    patchCode := {"op": "add",
    "path": "/spec/kubeConfig/inCluster",
    "value": "false",}
}
patch[patchCode] {
    input.request.kind.kind = "App"
    # only on create as user might have valid reason to change
    isCreate

    # TODO check if namespace is actually cluster namespace, to only run this for clsuter name space
    clusterid := input.request.object.metadata.namespace

    patchCode := {"op": "add",
    "path": "/spec/kubeConfig/secret/name",
    "value": sprintf("%s-kubeconfig", [clusterid] ),}
}
patch[patchCode] {
    input.request.kind.kind = "App"
    # only on create as user might have valid reason to change
    isCreate

    # TODO check if namespace is actually cluster namespace, to only run this for clsuter name space
    clusterid := input.request.object.metadata.namespace

    patchCode := {"op": "add",
    "path": "/spec/kubeConfig/secret/namespace",
    "value": clusterid,}
}
patch[patchCode] {
    input.request.kind.kind = "App"
    # only on create as user might have valid reason to change
    isCreate

    # TODO check if namespace is actually cluster namespace, to only run this for clsuter name space
    clusterid := input.request.object.metadata.namespace

    patchCode := {"op": "add",
    "path": "/spec/kubeConfig/context/name",
    "value": clusterid,}
}
# TODO add here config, CM and secret

# Add all the required labels
# TODO do this also for appCatalogs
# TODO see how to escape "/" as it should be "app-operator.giantswarm.io/version"
patch[patchCode] {
    input.request.kind.kind = "App"
    isCreateOrUpdate

    # TODO get version from somewhere?
    not hasLabelValue[["app-operator.giantswarm.io", "1.0.0"]] with input as input.request.object
	patchCode = makeLabelPatch("add", "app-operator.giantswarm.io", "1.0.0", "")
}