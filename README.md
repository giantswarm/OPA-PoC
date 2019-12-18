# PoC of using OPA to mutate CRDs

This PoC is aimed at showing how to solve common issues we have in defaulting (mutating) of Custom Resources at the example of [app CRD](https://github.com/giantswarm/apiextensions/blob/master/pkg/apis/application/v1alpha1/app_types.go) (and [appCatalog CRD](https://github.com/giantswarm/apiextensions/blob/master/pkg/apis/application/v1alpha1/app_catalog_types.go)), which are part of the Giant Swarm App Catalog.

## Prerequisites

### Start Minikube and Install CRDs

```bash
minikube start
```

You currently need to run [app-operator](https://github.com/giantswarm/app-operator/) locally pointing to your minikube:

```bash
go run main.go daemon --service.kubernetes.incluster=false \
  --service.kubernetes.address="https://$(minikube ip):8443" \
  --service.kubernetes.tls.cafile="$HOME/.minikube/ca.crt" \
  --service.kubernetes.tls.crtfile="$HOME/.minikube/client.crt" \
  --service.kubernetes.tls.keyfile="$HOME/.minikube/client.key"
```

There's a YAML copy (from 16.12.2019) of the CRDs at https://github.com/giantswarm/OPA-PoC/blob/master/CRDs.yaml, which should work alternatively like following:

```bash
k apply -f CRDs.yaml
```

### Install OPA Admission controller

Install OPA and admission control webhook as described in https://www.openpolicyagent.org/docs/latest/kubernetes-tutorial/, but replace the YAML there with the custom YAML in https://github.com/giantswarm/OPA-PoC/tree/master/admission-controller. You can apply RBAC and admission controller as committed to this repo, but you need to change the webhook config to reflect your CA bundle.

You can get the CA bundle for the webhook by running:

```bash
cat ca.crt | base64 | tr -d '\n'
```

You should now have an OPA admission controller that knows about app and appCatalog CRDs running in your minikube.

## Walkthrough

Once you have the CRDs and OPA admission controller in your minikube you can test like following:

Create and check the core rego. Annotations should include `openpolicyagent.org/policy-status: '{"status":"ok"}'`

```bash
kubectl -n opa create cm core --from-file=core.rego
kubectl -n opa get cm core -o yaml
```

Create and check the app-mutation rego. Annotations should include `openpolicyagent.org/policy-status: '{"status":"ok"}'`

```bash
kubectl -n opa create cm app-mutation --from-file=app-mutation.rego
kubectl -n opa get cm app-mutation -o yaml
```

Apply and check a bare app CR. You should see added cluster config and kubeconfig as well as a label depicting the operator version.

```bash
kubectl apply -f app_bare.yaml
kubectl -n 12345 get app my-cool-prometheus -o yaml
```

Apply and check a bare NGINX IC app CR. The resulting app CR should look similar to above, but with `ingress-controller-values` instead of `12345-cluster-values` in the cluster ConfigMap.

```bash
kubectl apply -f app_nginx_bare.yaml
kubectl -n 12345 get app my-cool-nginx -o yaml
```

Apply and check an appcatalog CR. You should see an added label depicting the operator version.

```bash
kubectl apply -f giantswarm-catalog-wo-label.yaml
kubectl get appcatalog giantswarm -o yaml
```

## Working with Rego

Apply and check a new .rego file:

```bash
kubectl -n opa create cm app-mutation --from-file=app-mutation.rego
kubectl -n opa get cm app-mutation -o yaml
```

Update and check an existing .rego file:

```bash
kubectl -n opa delete cm app-mutation
kubectl -n opa create cm app-mutation --from-file=app-mutation.rego
kubectl -n opa get cm app-mutation -o yaml
```

## Resources

- https://www.openpolicyagent.org/docs/latest/kubernetes-tutorial/
- https://gist.github.com/tsandall/f328635433acc5beeb4cb9b36295ee89
- https://github.com/teq0/opa-k8s-admission/tree/master/rego

## Further Reading

- https://www.openpolicyagent.org/docs/how-do-i-write-policies.html
- https://medium.com/@mathurvarun98/how-to-write-great-rego-policies-dc6117679c9f
- https://github.com/tsandall/dacp
- https://github.com/open-policy-agent/opa/blob/master/docs/book/tutorials/kubernetes-admission-control-validation/ingress-conflicts.rego
- https://github.com/tsandall/opa-microservice-api-authz-demo/tree/master/policies