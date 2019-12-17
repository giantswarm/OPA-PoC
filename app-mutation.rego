package system

import data.kubernetes.namespaces

isAppOrAppCatalog {
    isApp
}

isAppOrAppCatalog {
    isAppCatalog
}

isApp {
    input.request.kind.kind = "App"
}

isAppCatalog {
    input.request.kind.kind = "AppCatalog"
}

# If namespace depicts clusterid, add cluster config
# We only do these on create as user might have valid reason to change
# TODO could this be one patch? or at least can we extract the common checks?
# Limitations due to ensure paths functions in core.rego
# Couldn't make it one patch (functions need single objects)
# Shortest patch to path must be first, as otherwise path order is wrong and creation will fail!
patch[patchCode] {
    isApp
    isCreate

    # Checks if namespace is actually a cluster namespace
    ns := input.request.object.metadata.namespace
    some i
    namespaces[i].metadata.name == ns
    namespace := namespaces[i]
    namespace.metadata.labels.cluster
    clusterid := namespace.metadata.name

    not input.request.object.spec.kubeConfig
    patchCode := makeSpecPatch("add", "kubeConfig/inCluster", "false", "")
}
patch[patchCode] {
    isApp
    isCreate

    # Checks if namespace is actually a cluster namespace
    ns := input.request.object.metadata.namespace
    some i
    namespaces[i].metadata.name == ns
    namespace := namespaces[i]
    namespace.metadata.labels.cluster
    clusterid := namespace.metadata.name
   
   not input.request.object.spec.kubeConfig
   patchCode := makeSpecPatch("add", "kubeConfig/secret/name", sprintf("%s-kubeconfig", [clusterid]), "")
}
patch[patchCode] {
    isApp
    isCreate

    # Checks if namespace is actually a cluster namespace
    ns := input.request.object.metadata.namespace
    some i
    namespaces[i].metadata.name == ns
    namespace := namespaces[i]
    namespace.metadata.labels.cluster
    clusterid := namespace.metadata.name

    not input.request.object.spec.kubeConfig
    patchCode := makeSpecPatch("add", "kubeConfig/secret/namespace", clusterid, "")
}
patch[patchCode] {
    isApp
    isCreate

    # Checks if namespace is actually a cluster namespace
    ns := input.request.object.metadata.namespace
    some i
    namespaces[i].metadata.name == ns
    namespace := namespaces[i]
    namespace.metadata.labels.cluster
    clusterid := namespace.metadata.name

    not input.request.object.spec.kubeConfig
    patchCode := makeSpecPatch("add", "kubeConfig/context/name", clusterid, "")
}
patch[patchCode] {
    isApp
    isCreate
    
    # Checks if namespace is actually a cluster namespace
    ns := input.request.object.metadata.namespace
    some i
    namespaces[i].metadata.name == ns
    namespace := namespaces[i]
    namespace.metadata.labels.cluster
    clusterid := namespace.metadata.name

    not input.request.object.spec.config
    # create configMap path
    patchCode := makeSpecPatch("add", "config/configMap", {}, "")
}
patch[patchCode] {
    isApp
    isCreate
    # ingress controller has special config
    input.request.object.spec.name == "nginx-ingress-controller-app"

    # Checks if namespace is actually a cluster namespace
    ns := input.request.object.metadata.namespace
    some i
    namespaces[i].metadata.name == ns
    namespace := namespaces[i]
    namespace.metadata.labels.cluster
    clusterid := namespace.metadata.name

    not input.request.object.spec.config
    patchCode := makeSpecPatch("add", "config/configMap/name", "ingress-controller-values", "")
}
patch[patchCode] {
    isApp
    isCreate
    not input.request.object.spec.name == "nginx-ingress-controller-app"

    # Checks if namespace is actually a cluster namespace
    ns := input.request.object.metadata.namespace
    some i
    namespaces[i].metadata.name == ns
    namespace := namespaces[i]
    namespace.metadata.labels.cluster
    clusterid := namespace.metadata.name

    not input.request.object.spec.config
    patchCode := makeSpecPatch("add", "config/configMap/name", sprintf("%s-cluster-values", [clusterid]), "")
}
patch[patchCode] {
    isApp
    isCreate

    # Checks if namespace is actually a cluster namespace
    ns := input.request.object.metadata.namespace
    some i
    namespaces[i].metadata.name == ns
    namespace := namespaces[i]
    namespace.metadata.labels.cluster
    clusterid := namespace.metadata.name

    not input.request.object.spec.config
    patchCode := makeSpecPatch("add", "config/configMap/namespace", clusterid, "")
}

# Add all the required labels (currently only operator version)
#patch[patchCode] {
#    isAppOrAppCatalog
#    isCreateOrUpdate
#
#    # 1.0.0 is a hardcoded value as we are not changing the operator version for now
#    # ~1 is the RFC conform way of escaping / in JSON Patches
#    not hasLabelValue[["app-operator.giantswarm.io~1version", "1.0.0"]] with input as input.request.object
#	patchCode = makeLabelPatch("add", "app-operator.giantswarm.io~1version", "1.0.0", "")
#}