$repo = "peterhellmuth/TestMutant-agent"
$installDir = "$env:USERPROFILE\.testmutant"
if (!(Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir }

# 1. Get Latest Release
$release = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases/latest"
$asset = $release.assets | Where-Object { $_.name -like "*win.exe.zip" } | Select-Object -First 1

# 2. Download and Unzip
Write-Host "Downloading TestMutant..."
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile "$installDir\testmutant.zip"
Expand-Archive -Path "$installDir\testmutant.zip" -DestinationPath $installDir -Force

Write-Host "✅ TestMutant installed to $installDir\testmutant.exe"