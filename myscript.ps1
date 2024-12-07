param (
    [string]$SourcePath,
    [string]$ReplicaPath,
    [string]$LogFilePath
)

function Log {
    param ([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "$Timestamp - $Message"
    Write-Output $LogMessage
    Add-Content -Path $LogFilePath -Value $LogMessage
}

# Ensure paths are provided
if (-not (Test-Path $SourcePath)) {
    Write-Error "Source folder does not exist."
    exit
}

if (-not (Test-Path $ReplicaPath)) {
    New-Item -ItemType Directory -Path $ReplicaPath -Force | Out-Null
    Log "Replica folder created: $ReplicaPath"
}

# Sync files from Source to Replica
function Sync-Folder {
    param ([string]$Source, [string]$Replica)

    # Sync files
    Get-ChildItem -Path $Source -Recurse | ForEach-Object {
        $RelativePath = $_.FullName.Substring($Source.Length).TrimStart("\")
        $ReplicaItemPath = Join-Path -Path $Replica -ChildPath $RelativePath

        if ($_.PSIsContainer) {
            if (-not (Test-Path $ReplicaItemPath)) {
                New-Item -ItemType Directory -Path $ReplicaItemPath -Force | Out-Null
                Log "Created directory: $ReplicaItemPath"
            }
        } else {
            if (-not (Test-Path $ReplicaItemPath) -or (Get-FileHash $_.FullName).Hash -ne (Get-FileHash $ReplicaItemPath).Hash) {
                Copy-Item -Path $_.FullName -Destination $ReplicaItemPath -Force
                Log "Copied file: $($_.FullName) to $ReplicaItemPath"
            }
        }
    }

    # Remove items in Replica not in Source
    Get-ChildItem -Path $Replica -Recurse | ForEach-Object {
        $RelativePath = $_.FullName.Substring($Replica.Length).TrimStart("\")
        $SourceItemPath = Join-Path -Path $Source -ChildPath $RelativePath

        if (-not (Test-Path $SourceItemPath)) {
            if ($_.PSIsContainer) {
                Remove-Item -Path $_.FullName -Recurse -Force
                Log "Removed directory: $($_.FullName)"
            } else {
                Remove-Item -Path $_.FullName -Force
                Log "Removed file: $($_.FullName)"
            }
        }
    }
}

# Begin synchronization
Log "Synchronization started between '$SourcePath' and '$ReplicaPath'"
Sync-Folder -Source $SourcePath -Replica $ReplicaPath
Log "Synchronization completed successfully."
