# PoC of using OPA to validate and mutate CRDs

This PoC is aimed at showing how to solve common issues we have in validation and mutation of Custom Resources at the example of [app CRD](https://github.com/giantswarm/apiextensions/blob/master/pkg/apis/application/v1alpha1/app_types.go) (and [appCatalog CRD](https://github.com/giantswarm/apiextensions/blob/master/pkg/apis/application/v1alpha1/app_catalog_types.go)), which are part of the Giant Swarm App Katalog.

## Prerequisites

### Install CRDs

You currently need to run [app-operator](https://github.com/giantswarm/app-operator/) locally pointing to your minikube:

```bash
go run main.go daemon --service.kubernetes.incluster=false \
  --service.kubernetes.address="https://$(minikube ip):8443" \
  --service.kubernetes.tls.cafile="$HOME/.minikube/ca.crt" \
  --service.kubernetes.tls.crtfile="$HOME/.minikube/client.crt" \
  --service.kubernetes.tls.keyfile="$HOME/.minikube/client.key"
```

### Install OPA Admission controller



## Working with Rego

Apply and check a new .rego file:

```bash
kubectl -n opa create cm app-validation --from-file=app-validation.rego
kubectl -n opa get cm app-validation -o yaml
```

Update and check an exisiting .rego file:

```bash
kubectl -n opa delete cm app-validation
kubectl -n opa create cm app-validation --from-file=app-validation.rego
kubectl -n opa get cm app-validation -o yaml
```