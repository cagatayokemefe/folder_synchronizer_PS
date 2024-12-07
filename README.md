# Folder Synchronization Script

This PowerShell script synchronizes a source folder with a replica folder, ensuring that files and directories are copied, updated, and removed as needed. It also logs the synchronization process to a specified log file.

## Features

- Synchronizes files and directories between source and replica folders.
- Creates missing directories in the replica.
- Copies updated or missing files to the replica.
- Removes files and directories in the replica that no longer exist in the source.
- Logs actions to a specified log file.

## Usage

Run the script with the following parameters:

```powershell
.\SyncFolders.ps1 -SourcePath "C:\SourceFolder" -ReplicaPath "D:\ReplicaFolder" -LogFilePath "C:\sync_log.txt"
```
