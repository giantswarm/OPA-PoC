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

There's a YAML copy (from 16.12.2019) of the CRDs at https://github.com/giantswarm/OPA-PoC/blob/master/CRDs.yaml, which should work alternatively.

### Install OPA Admission controller

Install OPA and admission control webhook as described in https://www.openpolicyagent.org/docs/latest/kubernetes-tutorial/.

Check and apply the custom YAMLs in https://github.com/giantswarm/OPA-PoC/tree/master/admission-controller. You can apply RBAC and admission controller as committed to this repo, but you need to change the webhook config to reflect your CA bundle.

You should now have an OPA admission controller that knows about app and appCatalog CRDs running in your minikube.

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

## Resources

- https://github.com/open-policy-agent/kube-mgmt/blob/master/docs/admission-control-crd.md
- https://www.openpolicyagent.org/docs/how-do-i-write-policies.html
- https://medium.com/@mathurvarun98/how-to-write-great-rego-policies-dc6117679c9f
- https://github.com/tsandall/dacp
- https://github.com/open-policy-agent/opa/blob/master/docs/book/tutorials/kubernetes-admission-control-validation/ingress-conflicts.rego
- https://github.com/teq0/opa-k8s-admission/blob/master/rego/mutation.rego
- https://github.com/tsandall/opa-microservice-api-authz-demo/tree/master/policies