# use PowerShell 7 instead of sh:
set shell := ["pwsh.exe", "-c"]

bootstrap:
  helm install bootstrap ./bootstrap --namespace argo-cd -f bootstrap/values.yaml --wait

install appname:
  helm install {{appname}} apps/{{appname}}/ --create-namespace --namespace {{appname}} -f apps/{{appname}}/values.yaml --wait

upgrade appname:
  helm upgrade {{appname}} apps/{{appname}}/ --create-namespace --namespace {{appname}} -f apps/{{appname}}/values.yaml --reset-then-reuse-values --wait