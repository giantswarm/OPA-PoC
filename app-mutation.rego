package kubernetes.admission

patch[p] {
    input.request.kind.kind = "App"
    input.request.operation = "CREATE"

    clusterid := input.request.object.metadata.namespace

    p := {"op": "add",
    "path": "request/object/spec/kubeConfig/context/name",
    "value": sprintf("giantswarm-%q", clusterid)}
}