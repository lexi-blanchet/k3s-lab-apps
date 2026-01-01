set shell := ["bash", "-uc"]

ct-lint:
  ct lint --config ct-lint.yaml

ct-install:
  k3d cluster create -c tests/k3d-chart-testing.yaml --k3s-arg "--node-taint=CriticalAddonsOnly=true:NoExecute@server:*"
  ct install --config ct-install.yaml --charts apps/cluster-crds --skip-clean-up
  ct install --config ct-install.yaml
  k3d cluster delete -c tests/k3d-chart-testing.yaml

# WSL bash child process env vars are annoying
# source <(just set-kubeconfig)
set-kubeconfig:
  echo export KUBECONFIG=$(k3d kubeconfig write --output $HOME/.config/kubeconfig-wsl.yaml)

create:
  k3d cluster create -c k3d-default.yaml --k3s-arg "--node-taint=CriticalAddonsOnly=true:NoExecute@server:*"

delete:
  k3d cluster delete -c k3d-default.yaml

bootstrap:
  just create
  just install-argo
  kubectl get apps -A
  echo -e "(Linux/WSL) Run the below to enable kubectl:\n\tsource <(just set-kubeconfig)"

# Clunky but we need to install the argo-cd secret before argo-cd so its a bit of a bootstrap paradox
install-argo helmargs="":
  kubectl create namespace argo-cd &&\
  helm upgrade --install cluster-crds apps/cluster-crds -f apps/cluster-crds/values.yaml --wait --wait-for-jobs {{helmargs}} &&\
  kubectl apply -f ".tmp/sealed-secret-key.yaml" &&\
  helm upgrade --install argo-cd argo-cd/argo-cd -n argo-cd --create-namespace --wait --wait-for-jobs {{helmargs}} &&\
  helm template apps/argocd-appdefinitions -s templates/app-argocd-appdefinitions.yaml | kubectl apply -n argo-cd -f-
