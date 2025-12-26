# use PowerShell 7 instead of sh:
set shell := ["pwsh.exe", "-c"]

# WSL bash child process env vars are annoying
# source <(just set-kubeconfig)
set-kubeconfig:
  #!/usr/bin/env bash
  echo export KUBECONFIG=$(k3d kubeconfig write --output $HOME/.config/kubeconfig-wsl.yaml)

create:
  k3d cluster create -c .\k3d-default.yaml --k3s-arg "--node-taint=CriticalAddonsOnly=true:NoExecute@server:*"

delete:
  k3d cluster delete -c .\k3d-default.yaml

bootstrap:
  just create
  just install-argo
  . util\Randomize-ArgoPassword.ps1

install-argo helmargs="":
  helm upgrade --install argo-cd argo-cd/argo-cd -n argo-cd --create-namespace --wait --wait-for-jobs {{helmargs}} &&\
  helm template .\apps\argocd-appdefinitions -s templates\app-argocd-appdefinitions.yaml | kubectl apply -n argo-cd -f-

install-app category appname:
  helm upgrade --install {{appname}} apps/{{category}}/{{appname}}/ --create-namespace --namespace {{appname}} -f apps/{{category}}/{{appname}}/values.yaml --wait

upgrade-app category appname:
  helm upgrade {{appname}} apps/{{category}}/{{appname}}/ --create-namespace --namespace {{appname}} -f apps/{{category}}/{{appname}}/values.yaml --reset-then-reuse-values --wait