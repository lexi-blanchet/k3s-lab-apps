# use PowerShell 7 instead of bash
# I should convert this to just bash
set shell := ["pwsh.exe", "-c"]

lint:
  #!/usr/bin/env bash
  ct lint --config ct-lint.yaml

lint-install:
  #!/usr/bin/env bash
  k3d cluster create -c tests/k3d-chart-testing.yaml --k3s-arg "--node-taint=CriticalAddonsOnly=true:NoExecute@server:*"
  ct install --config ct-install.yaml --charts apps/cluster-crds --skip-clean-up
  ct install --config ct-install.yaml
  k3d cluster delete -c tests/k3d-chart-testing.yaml

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
  Write-Output "(Linux/WSL) Run the below to enable kubectl:`n`tsource <(just set-kubeconfig)"

install-argo helmargs="":
  helm upgrade --install argo-cd argo-cd/argo-cd -n argo-cd --create-namespace --wait --wait-for-jobs {{helmargs}} &&\
  helm template .\apps\argocd-appdefinitions -s templates\app-argocd-appdefinitions.yaml | kubectl apply -n argo-cd -f-

install-app category appname:
  helm upgrade --install {{appname}} apps/{{category}}/{{appname}}/ --create-namespace --namespace {{appname}} -f apps/{{category}}/{{appname}}/values.yaml --wait

upgrade-app category appname:
  helm upgrade {{appname}} apps/{{category}}/{{appname}}/ --create-namespace --namespace {{appname}} -f apps/{{category}}/{{appname}}/values.yaml --reset-then-reuse-values --wait