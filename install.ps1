$repo = "peterhellmuth/TestMutant-agent"
$installDir = "$env:USERPROFILE\.testmutant"
if (!(Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir -Force }

Write-Host "Finding latest release..."
$release = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases/latest"
$asset = $release.assets | Where-Object { $_.name -like "*win.exe.zip" } | Select-Object -First 1

$tempZip = "$installDir\temp.zip"
$tempExtract = "$installDir\temp_extract"

Write-Host "Downloading TestMutant..."
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tempZip

if (Test-Path $tempExtract) { Remove-Item -Path $tempExtract -Recurse -Force }
Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force

Write-Host "Extracting and cleaning up..."
# 1. Hunt down the exact file, completely ignoring the zip's internal folder structure
$exePath = Get-ChildItem -Path $tempExtract -Filter "TestMutant.Agent.exe" -Recurse | Select-Object -First 1

if ($exePath) {
    # 2. Pull it directly into the root .testmutant folder
    Move-Item -Path $exePath.FullName -Destination "$installDir\TestMutant.Agent.exe" -Force
} else {
    Write-Error "❌ Could not find TestMutant.Agent.exe in the downloaded zip."
    exit 1
}

# 3. Clean up the temp files
Remove-Item -Path $tempZip -Force
Remove-Item -Path $tempExtract -Recurse -Force

Write-Host "✅ TestMutant installed to $installDir\TestMutant.Agent.exe"