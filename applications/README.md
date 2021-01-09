# 🦄 Config Repo 🔥

This repo is an Argo App definition which references other helm charts, kustomize or plain yaml.

## What's in the box? 👨

- `values-applications-test` is the application definitions for the test environments. This is updated using Tekton.
- `values-appllications-staging` is the application definitions for the staging environment. This is updated using Tekton on successful completion of the e2e tests.

### Create the ArgoCD Project and Apps 🤠

The argo app of apps are created when running the Tekton piplelines. You can manually create them using the following instructions.

Create dev+test
```bash
helm template -f argo-app-of-apps-test.yaml .
```

Create stage
```bash
helm template -f argo-app-of-apps-stage.yaml .
```