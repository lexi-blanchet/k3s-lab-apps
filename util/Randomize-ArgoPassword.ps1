# Requires 7
$ARGO_PASSWORD = kubectl -n argo-cd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
$NEW_PASSWORD = -join ((65..90) + (97..122) + (48..57) + 33, 64, 35, 36, 37 | ForEach-Object { [char]$_ } | Get-Random -Count 20)
$server = "argocd.test.local"

$max_tries = 5
$retry_length = 5
for ($s=1; $s -lt $max_tries; $s+=1) {
    argocd login $server --insecure --username admin --password $ARGO_PASSWORD
    if (0 -ne $LASTEXITCODE) {
        Write-Output "Retry Backoff: $s Max: $max_tries"
        Start-Sleep ($s * $retry_length)
    } else {
        break
    }
    if ($s -eq $max_tries) {
        throw "Couldn't authenticate to argo"
    }
}
argocd account update-password --insecure --current-password $ARGO_PASSWORD --new-password $NEW_PASSWORD
kubectl -n argo-cd delete secret argocd-initial-admin-secret
if (-not(test-path ".tmp")) { mkdir ".tmp" }
$NEW_PASSWORD | Out-File ".tmp\\argopass" -NoNewline -Force
argocd login $server--insecure --username admin --password $NEW_PASSWORD
$ARGO_PASSWORD = $null
$NEW_PASSWORD = $null
argocd version --insecure