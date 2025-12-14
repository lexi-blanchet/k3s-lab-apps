# k3s-lab-apps

- vagrant k3s
- argocd
- dashboard
- prometheus
- traffic load testing

Reqs:
- k3d
- kubectl
- Docker
- argocd
- helm

helm dep update charts/argo-cd/
kubectl -n default get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }