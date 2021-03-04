#!/bin/bash

set -e
#set -x

function generate_git_secret() {
    cat <<EOF | oc apply -f -
apiVersion: v1
data:
  password: "$(echo -n ${GITHUB_TOKEN} | base64)"
  username: amVua2lucy1naXRhdXRo
  webhook: "$(echo -n ${WEBHOOK_SECRET} | base64)"
kind: Secret
metadata:
  labels:
    credential.sync.jenkins.openshift.io: "true"
  name: git-auth
  namespace: labs-ci-cd
type: kubernetes.io/basic-auth
EOF
}

function generate_argocd_secret() {
    HOST=$(oc -n labs-ci-cd get route argocd-server --template='{{ .spec.host }}')
    argocd login --insecure --sso --username ${ARGOCD_USERNAME} $HOST:443
    TOKEN=$(argocd account generate-token --account ${ARGOCD_USERNAME} | base64 -w0)
    cat <<EOF | oc apply -f -
apiVersion: v1
data:
  password: ${TOKEN}
  username: "$(echo -n ${ARGOCD_USERNAME} | base64)"
kind: Secret
metadata:
  labels:
    credential.sync.jenkins.openshift.io: "true"
  name: argocd-token
  namespace: labs-ci-cd
type: kubernetes.io/basic-auth
EOF
    oc -n labs-ci-cd patch cm argocd-cm --type='json' -p='[{"op": "add", "path": "/data", "value": {"accounts.'${ARGOCD_USERNAME}'": "apiKey"}}]'
}

usage() {
  cat <<EOF 2>&1
usage: $0 -t <GITHUB_TOKEN> -s <WEBHOOK_SECRET> -a <ARGOCD_USERNAME>

example:
       ./create-petbattle-secrets.sh -t abcdefghijklmnop0987654321 -s secret -a admin

Create Pet Battle Secrets. Requires argocd and oc command line and a browser to login via sso to argocd.
        -t      Your GitHub user Token
        -s      Secret string for pipeline webhooks
        -a      ArgoCD UserName for SSO Login i.e. Your OpenShift user
EOF
  exit 1
}

while getopts t:s:a: c; do
  case $c in
    t)
      GITHUB_TOKEN=${OPTARG}
      ;;
    s)
      WEBHOOK_SECRET=${OPTARG}
      ;;
    a)
      ARGOCD_USERNAME=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done

if [ -z ${GITHUB_TOKEN} ] || [ -z ${WEBHOOK_SECRET} ] || [ -z ${ARGOCD_USERNAME} ]; then
    usage
fi

generate_git_secret
generate_argocd_secret
