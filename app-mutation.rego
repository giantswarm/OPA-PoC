package kubernetes.admission

# If namespace depicts clusterid, add cluster config
# TODO could this be one patch?
patch[patchCode] {
    input.request.kind.kind = "App"
    # only on create as user might have valid reason to change
    isCreate

    # TODO check if namespace is actually cluster namespace, to only run this for clsuter name space
    clusterid := input.request.object.metadata.namespace

    patchCode := {"op": "add",
    "path": "request/object/spec/kubeConfig/secret/name",
    "value": concat(clusterid, "-kubeconfig"),}
}
patch[patchCode] {
    input.request.kind.kind = "App"
    # only on create as user might have valid reason to change
    isCreate

    # TODO check if namespace is actually cluster namespace, to only run this for clsuter name space
    clusterid := input.request.object.metadata.namespace

    patchCode := {"op": "add",
    "path": "request/object/spec/kubeConfig/secret/namespace",
    "value": clusterid,}
}
patch[patchCode] {
    input.request.kind.kind = "App"
    # only on create as user might have valid reason to change
    isCreate

    # TODO check if namespace is actually cluster namespace, to only run this for clsuter name space
    clusterid := input.request.object.metadata.namespace

    patchCode := {"op": "add",
    "path": "request/object/spec/kubeConfig/context/name",
    "value": clusterid,}
}
patch[patchCode] {
    input.request.kind.kind = "App"
    # only on create as user might have valid reason to change
    isCreate

    # TODO check if namespace is actually cluster namespace, to only run this for clsuter name space
    clusterid := input.request.object.metadata.namespace

    patchCode := {"op": "add",
    "path": "request/object/spec/kubeConfig/inCluster",
    "value": "false",}
}
# TODO add here config, CM and secret

# Add all the required labels
# TODO do this also for appCatalogs
patch[patchCode] {
    input.request.kind.kind = "App"
    isCreateOrUpdate

    not hasLabelValue[["app-operator.giantswarm.io/version", "1.0.0"]] with input as input.request.object
	patchCode = makeLabelPatch("add", "app-operator.giantswarm.io/version", "1.0.0", "")
}