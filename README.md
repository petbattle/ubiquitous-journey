## ☘️ pb-ci-cd ☘️

Tekton pipelines for the Pet Battle suite of applications.

If you want to learn how to create this project read [DEVELOPMENT.md](DEVELOPMENT.md)

We use a Pull Model of deployment - Tekton for the CI pipeline, and ArgoCD to deploy changes using GitOps.

![pull-model.png](images/pull-model.png)
### 🤠 For the impatient 🤠

Just run this code as a cluster admin user:
```bash
# clone this repo and
cd ubiquitous-journey
# bootstrap to install argocd and create projects
helm template bootstrap --dependency-update -f bootstrap/values-bootstrap.yaml bootstrap | oc apply -f-
# create the argocd token secret in labs-ci-cd namespace see TBD below
# give me ALL THE TOOLS, EXTRAS & OPSY THINGS !
helm template -f argo-app-of-apps.yaml ubiquitous-journey/ | oc -n labs-ci-cd apply -f-
# start a pipeline run
oc -n labs-ci-cd process pet-battle-api | oc -n labs-ci-cd create -f-
oc -n labs-ci-cd process pet-battle | oc -n labs-ci-cd create -f-
oc -n labs-ci-cd process pet-battle-tournament | oc -n labs-ci-cd create -f-
```

If you have already built and tagged images and you have app-of-app config changes, you can redeploy the argocd application using helm with:
```bash
oc -n labs-ci-cd process pet-battle-api-deploy | oc -n labs-ci-cd create -f-
oc -n labs-ci-cd process pet-battle-deploy | oc -n labs-ci-cd create -f-
oc -n labs-ci-cd process pet-battle-tournament-deploy | oc -n labs-ci-cd create -f-
```

To create webhooks in github repos run these (TaskRuns) once manually
```bash
oc -n labs-ci-cd process pet-battle-api-create-webhook | oc -n labs-ci-cd create -f-
```

## To Be Done
- [ ] make secrets handling more realistic - use sealed secrets or hashicorp vault - https://www.openshift.com/blog/integrating-hashicorp-vault-in-openshift-4, quarkus hashicorp integration - https://quarkus.io/guides/vault

```bash
# manually mount secrets for now
oc -n labs-ci-cd apply -f ~/tmp/git-auth.yaml

# generate argocd cd token
oc -n labs-ci-cd patch cm argocd-cm --type='json' -p='[{"op": "add", "path": "/data", "value": {"accounts.admin": "apiKey"}}]'
HOST=$(oc -n labs-ci-cd get route argocd-server --template='{{ .spec.host }}')
argocd login $HOST:443 --sso --insecure --username admin
TOKEN=$(argocd account generate-token --account admin | base64 -w0)
sed -i -e "s|  password:.*|  password: ${TOKEN}|" ~/tmp/argocd-token.yaml
oc -n labs-ci-cd apply -f ~/tmp/argocd-token.yaml
```

- [ ] delete deprecated tekton conditionals once pipeline operator updated -> when syntax

```yaml
    - name: oc-tag-image-test
      when:
        - input: "$(params.GIT_BRANCH)"
          operator: in
          values: ["master"]

    - name: helm-argocd-apps-branches # only deploy to dev, fullname includes branch
      when:
        - input: "$(params.GIT_BRANCH)"
          operator: notin
          values: ["master"]
```

- [ ] Operator split into charts requiring privilege
- [ ] tekton-tidy.sh, clean artifacts in workspace, add to UJ day2
- [ ] ubi quarkus ubi build image with tools, check base now we have new images (using custom one)
- [ ] code quality gates - configure pipeline args to fail on quality gates
- [ ] document PR'sand branches .. tooling supports this now
- [ ] document webhook triggers, auto create them using tekton task
- [ ] dev-ex-dashboard configure
- [ ] add nsfw apps to this guide
- [ ] add github triggers work
