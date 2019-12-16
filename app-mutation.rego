package kubernetes.admission

patch[patchCode] {
    input.request.kind.kind = "App"
    input.request.operation = "CREATE"

    # TODO check if namespace is actually cluster namespace, to only run this for clsuter name space
    clusterid := input.request.object.metadata.namespace

    patchCode := {"op": "add",
    "path": "request/object/spec/kubeConfig/context/name",
    "value": sprintf("giantswarm-%q", clusterid)}
}