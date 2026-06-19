# PowerShell script to create GitHub repository and push code
# Run this script after updating the $githubUsername and $githubToken variables

param(
    [Parameter(Mandatory=$true)]
    [string]$githubUsername,
    
    [Parameter(Mandatory=$true)]
    [string]$githubToken
)

# Configuration
$repoName = "stellar-network-sdk"
$repoDescription = "Python SDK for building applications on the Stellar blockchain network"
$orgName = "LunarForge-Labs"  # If you want to create under your user account instead, leave this empty

Write-Host "Creating GitHub repository..." -ForegroundColor Green

# Create repository using GitHub API
$headers = @{
    "Authorization" = "token $githubToken"
    "Accept" = "application/vnd.github.v3+json"
}

$body = @{
    "name" = $repoName
    "description" = $repoDescription
    "private" = $false
    "has_issues" = $true
    "has_projects" = $true
    "has_wiki" = $true
} | ConvertTo-Json

try {
    if ($orgName) {
        # Create under organization
        $apiUrl = "https://api.github.com/orgs/$orgName/repos"
        Write-Host "Creating repository under organization: $orgName" -ForegroundColor Yellow
    } else {
        # Create under user account
        $apiUrl = "https://api.github.com/user/repos"
        Write-Host "Creating repository under user account" -ForegroundColor Yellow
    }
    
    $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $body -ContentType "application/json"
    
    Write-Host "✓ Repository created successfully!" -ForegroundColor Green
    Write-Host "Repository URL: $($response.html_url)" -ForegroundColor Cyan
    
    # Add remote and push
    Write-Host "`nAdding remote and pushing code..." -ForegroundColor Green
    
    if ($orgName) {
        $remoteUrl = "https://github.com/$orgName/$repoName.git"
    } else {
        $remoteUrl = "https://github.com/$githubUsername/$repoName.git"
    }
    
    git remote add origin $remoteUrl
    git branch -M main
    git push -u origin main
    
    Write-Host "✓ Code pushed successfully!" -ForegroundColor Green
    Write-Host "`nRepository is now available at: $($response.html_url)" -ForegroundColor Cyan
    
} catch {
    Write-Host "✗ Error creating repository:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nManual steps:" -ForegroundColor Yellow
    Write-Host "1. Go to https://github.com/new" -ForegroundColor Yellow
    Write-Host "2. Create repository named: $repoName" -ForegroundColor Yellow
    Write-Host "3. Run these commands:" -ForegroundColor Yellow
    if ($orgName) {
        Write-Host "   git remote add origin https://github.com/$orgName/$repoName.git" -ForegroundColor Cyan
    } else {
        Write-Host "   git remote add origin https://github.com/$githubUsername/$repoName.git" -ForegroundColor Cyan
    }
    Write-Host "   git push -u origin main" -ForegroundColor Cyan
}

Write-Host "`n" -NoNewline
Read-Host "Press Enter to exit"
