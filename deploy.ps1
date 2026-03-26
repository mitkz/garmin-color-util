param(
    [ValidateSet('Build','Deploy')]
    [string]$Action = 'Deploy'
)

# copy from
$sourceFilePath = "bin\ColorFinder.prg"

# MTPデバイス名とデプロイ先のパスを指定
# "active 5" で部分一致検索（アクセント記号の問題を回避）
$deviceName = "active 5"
$mtpPath = "Internal Storage\GARMIN\Apps"

function Get-MTPDevice {
    param (
        [string]$deviceName
    )
    
    $shell = New-Object -ComObject Shell.Application
    $myComputer = $shell.NameSpace(17)  # 17 = ssfDRIVES (This PC)
    
    foreach ($item in $myComputer.Items()) {
        # 部分一致検索（大文字小文字を無視）
        if ($item.Name -match [regex]::Escape($deviceName)) {
            return $item
        }
    }
    return $null
}

function Get-MTPFolder {
    param (
        [object]$parentFolder,
        [string]$path
    )
    
    $currentFolder = $parentFolder.GetFolder
    $pathParts = $path -split '\\'
    
    foreach ($part in $pathParts) {
        if ([string]::IsNullOrEmpty($part)) { continue }
        
        $found = $false
        foreach ($item in $currentFolder.Items()) {
            if ($item.Name -eq $part) {
                $currentFolder = $item.GetFolder
                $found = $true
                break
            }
        }
        
        if (-not $found) {
            Write-Host "Folder not found: $part"
            return $null
        }
    }
    
    return $currentFolder
}

function WaitForMTPDevice {
    param (
        [string]$deviceName,
        [int]$maxAttempts = 30
    )

    $attempt = 0
    Write-Host "Waiting for MTP device '$deviceName' to become available..."
    
    while ($attempt -lt $maxAttempts) {
        $device = Get-MTPDevice -deviceName $deviceName
        if ($null -ne $device) {
            Write-Host "Device found!"
            return $device
        }
        Write-Host "." -NoNewline
        Start-Sleep -Seconds 1
        $attempt++
    }
    Write-Host ""
    
    Write-Host "Device '$deviceName' did not become available within the time limit."
    return $null
}

function Copy-ToMTP {
    param (
        [string]$sourceFile,
        [object]$destinationFolder
    )
    
    $sourceFullPath = (Resolve-Path $sourceFile).Path
    $destinationFolder.CopyHere($sourceFullPath, 16)  # 16 = Yes to All
}

Write-Host "Building App..."
java.exe -Xms1g -jar ..\..\AppData\Roaming\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-8.4.0-2025-12-03-5122605dc\bin\monkeybrains.jar -o $sourceFilePath -f "monkey.jungle" -y ..\developer_key -d vivoactive5_sim -w
if ($? -ne $true) {
    Write-Host "Build failed!"
    exit 1
}

if ($Action -eq 'Build') {
    Write-Host "Build completed. Skipping deployment"
    exit 0
}

# MTPデバイスを待機
$device = WaitForMTPDevice -deviceName $deviceName
if ($null -eq $device) {
    Write-Host "Failed to find MTP device!"
    exit 1
}

# MTPデバイス上のフォルダを取得
Write-Host "Navigating to $mtpPath..."
$targetFolder = Get-MTPFolder -parentFolder $device -path $mtpPath
if ($null -eq $targetFolder) {
    Write-Host "Failed to find destination folder on device!"
    exit 1
}

# ファイルをコピー
Write-Host "Copying $sourceFilePath to MTP device..."
Copy-ToMTP -sourceFile $sourceFilePath -destinationFolder $targetFolder

Write-Host "Done!"
