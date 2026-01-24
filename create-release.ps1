# Script para criar release no GitHub
# Uso: .\create-release.ps1 -Token "seu-token-github"

param(
    [string]$Token = "",
    [string]$Tag = "v1.0.8+2",
    [string]$Owner = "cesar-carlos",
    [string]$Repo = "flutter-expedicao-app"
)

$releaseNotes = Get-Content -Path "docs\release\RELEASE_NOTES_v1.0.8+2.md" -Raw

if ([string]::IsNullOrEmpty($Token)) {
    Write-Host "❌ Token do GitHub não fornecido!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Para criar o release, você pode:" -ForegroundColor Yellow
    Write-Host "1. Executar este script com o token: .\create-release.ps1 -Token 'seu-token'" -ForegroundColor Cyan
    Write-Host "2. Criar manualmente no GitHub: https://github.com/$Owner/$Repo/releases/new" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Tag criada: $Tag" -ForegroundColor Green
    Write-Host "Você pode criar o release manualmente usando a tag: $Tag" -ForegroundColor Green
    exit 1
}

$headers = @{
    "Authorization" = "token $Token"
    "Accept" = "application/vnd.github.v3+json"
}

$body = @{
    tag_name = $Tag
    name = "Release $Tag"
    body = $releaseNotes
    draft = $false
    prerelease = $false
} | ConvertTo-Json

try {
    Write-Host "🚀 Criando release $Tag no GitHub..." -ForegroundColor Cyan
    
    $response = Invoke-RestMethod -Uri "https://api.github.com/repos/$Owner/$Repo/releases" `
        -Method Post `
        -Headers $headers `
        -Body $body `
        -ContentType "application/json"
    
    Write-Host "✅ Release criado com sucesso!" -ForegroundColor Green
    Write-Host "🔗 URL: $($response.html_url)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Próximos passos:" -ForegroundColor Yellow
    Write-Host "1. Faça o build do APK: flutter build apk --release" -ForegroundColor White
    Write-Host "2. Faça upload do APK no release: $($response.html_url)" -ForegroundColor White
    
} catch {
    Write-Host "❌ Erro ao criar release: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Detalhes: $responseBody" -ForegroundColor Red
    }
    exit 1
}
