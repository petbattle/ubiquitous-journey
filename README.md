## ☘️ pet battle ubquitous journey ☘️

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
helm upgrade --install bootstrap -f bootstrap/values-bootstrap.yaml bootstrap --create-namespace --namespace labs-bootstrap
# Create GitHub and ArgoCD secrets
../tekton/secrets/create-petbattle-secrets.sh -t <GITHUB_TOKEN> -s <WEBHOOK_SECRET> -a <ARGOCD_USERNAME>
# give me ALL THE TOOLS, EXTRAS & OPSY THINGS !
helm template -f argo-app-of-apps.yaml ubiquitous-journey/ | oc -n labs-ci-cd apply -f-
# start a pipeline run
oc -n labs-ci-cd process pet-battle-api | oc -n labs-ci-cd create -f-
oc -n labs-ci-cd process pet-battle | oc -n labs-ci-cd create -f-
oc -n labs-ci-cd process pet-battle-tournament | oc -n labs-ci-cd create -f-
```

If you have already built and tagged images, you can redeploy the argocd application suite (helm template) using:
```bash
oc -n labs-ci-cd process pet-battle-api-deploy -p HELM_CHART_VERSION=1.0.8 | oc -n labs-ci-cd create -f-
oc -n labs-ci-cd process pet-battle-deploy -p HELM_CHART_VERSION=1.0.4 | oc -n labs-ci-cd create -f-
oc -n labs-ci-cd process pet-battle-tournament-deploy -p HELM_CHART_VERSION=1.0.20 | oc -n labs-ci-cd create -f-
```

If you are on a branch called `develop`, you can test a deployment (the same as a helm update --install) using:
```bash
# HELM_CHART_VERSION is Optional (it will pull latest chart from nexus helm chart repo if not specified)
oc -n labs-ci-cd process pet-battle-api-deploy -p GIT_SHORT_REVISION=develop -p GIT_BRANCH=develop -p HELM_CHART_VERSION=1.0.6 | oc -n labs-ci-cd create -f-
# OR
oc -n labs-ci-cd process pet-battle-api-deploy -p GIT_SHORT_REVISION=develop -p GIT_BRANCH=develop | oc -n labs-ci-cd create -f-
```

Or you can do a full build and deployment pipeline of a branch called `develop` using
```bash
oc -n labs-ci-cd process pet-battle-api -p GIT_REVISION=develop -p GIT_SHORT_REVISION=develop -p GIT_BRANCH=develop | oc -n labs-ci-cd create -f-
```

To create webhooks that trigger a full pipeline build and deployment in your github repos run these (TaskRuns) once manually:
```bash
oc -n labs-ci-cd process create-webhook -p GITHUB_ORG=petbattle -p GITHUB_REPO=pet-battle-api -p WEBHOOK_URL=http://$(oc -n labs-ci-cd get route webhook -o custom-columns=ROUTE:.spec.host --no-headers) | oc -n labs-ci-cd create -f-
oc -n labs-ci-cd process create-webhook -p GITHUB_ORG=petbattle -p GITHUB_REPO=pet-battle -p WEBHOOK_URL=http://$(oc -n labs-ci-cd get route webhook -o custom-columns=ROUTE:.spec.host --no-headers) | oc -n labs-ci-cd create -f-
oc -n labs-ci-cd process create-webhook -p GITHUB_ORG=petbattle -p GITHUB_REPO=tournamentservice-v1 -p WEBHOOK_URL=http://$(oc -n labs-ci-cd get route webhook -o custom-columns=ROUTE:.spec.host --no-headers) | oc -n labs-ci-cd create -f-
```

## To Be Done
- [ ] make secrets handling more realistic - use sealed secrets or hashicorp vault - https://www.openshift.com/blog/integrating-hashicorp-vault-in-openshift-4, quarkus hashicorp integration - https://quarkus.io/guides/vault
- [ ] tekton-tidy.sh, clean artifacts in workspace, add to UJ day2
- [ ] ubi quarkus build image with tools, check base now we have new images (using custom ones)
- [ ] code quality check should include the branch name generated for sonarqube
- [ ] dev-ex-dashboard configure - REPLACE this with Console Links Chart when ready!! https://github.com/redhat-cop/helm-charts/pull/109
- [ ] add nsfw apps to this guide
- [ ] add HelmChartRepository to UJ - need this to merge for nexus support https://github.com/openshift/console/pull/7711,https://github.com/openshift/console/pull/7841
- [ ] add E2E tests written between test -> stage promotion
- [ ] get Helm Release Notes working for pb apps in openshift
- [X] delete deprecated tekton conditionals once pipeline operator updated -> when syntax
- [X] Operator split into charts requiring privilege
- [X] document webhook triggers create them using tekton task
- [X] add github triggers work
- [X] split test, stage deploys - app of apps
- [X] boostrap crd's is two step process on an empty cluster. need this in a pipeline somewhere
- [X] code quality gates - configure pipeline args to fail on quality gates
- [X] Automate These Secrets:
