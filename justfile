# use PowerShell 7 instead of sh:
set shell := ["pwsh.exe", "-c"]

create:
  k3d cluster create -c .\k3d-default.yaml --k3s-arg "--node-taint=CriticalAddonsOnly=true:NoExecute@server:*"

delete:
  k3d cluster delete -c .\k3d-default.yaml

bootstrap:
  just create
  just install-argo
  . util\Randomize-ArgoPassword.ps1

install-argo:
  helm install argo-cd argo-cd/argo-cd -n argo-cd --create-namespace --wait --wait-for-jobs &&\
  kubectl apply -n argo-cd -f .\apps\argocd-appdefinitions\templates\app-argocd-appdefinitions.yaml &&\
  . util\Randomize-ArgoPassword.ps1

install-app appname:
  helm install {{appname}} apps/{{appname}}/ --create-namespace --namespace {{appname}} -f apps/{{appname}}/values.yaml --wait

upgrade-app category appname:
  helm upgrade {{appname}} apps/infra/{{appname}}/ --create-namespace --namespace {{appname}} -f apps/{{appname}}/values.yaml --reset-then-reuse-values --wait