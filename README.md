# k3s-lab-apps

Simple k3d implementation that configures core services, cluster management via Rancher, and resource deployment using ArgoCD.

All urls are mapped to *.test.local which has a local DNS record on my pihole pointing to localhost for convenience.

# Requirements

- **k3d**
- **just** command runner
- **WSL**: Much of the justfile is written for linux
- `sealed-secret-key.yaml` expected in `.tmp` directory which I don't automate for security reasons
- **chart-testing**: There's a pipeline but this makes your life easier for pre-commit linting