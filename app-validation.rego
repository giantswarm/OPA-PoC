package kubernetes.admission

import data.kubernetes.appcatalogs

deny[msg] {
    input.request.kind.kind = "App"
    input.request.operation = "CREATE"
    name = input.request.object.metadata.name
    not input.request.object.spec.catalog
    msg = sprintf("the app %q is invalid, catalog missing", [name])
}

deny[msg] {
    input.request.kind.kind = "App"
    input.request.operation = "CREATE"
    input.request.object.spec.catalog != appcatalogs[_].metadata.name # seems to only work if catalogs are present
    msg = sprintf("selected catalog %q is invalid, catalog is not in list of installed catalogs", [input.request.object.spec.catalog])
}

patch[p] {
    input.request.kind.kind = "App"
    input.request.operation = "CREATE"

    clusterid := input.request.object.metadata.namespace

    p := {"op": "add",
    "path": "request/object/spec/kubeConfig/context/name",
    "value": sprintf("giantswarm-%q", clusterid)}
}