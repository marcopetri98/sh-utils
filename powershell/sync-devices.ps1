<#
.SYNOPSIS
    Syncs work-in-progress git changes between devices through a git patch file.

.DESCRIPTION
    Creates (or applies) a git patch named 'wip.patch' that captures every
    local change in the current repository, tracked and untracked alike.

    When creating, the script stashes all changes with
        git stash push -u -m "wip: sync <YYMMDDHHmmSS>"
    (the timestamp keeps repeated runs from stacking up identically named
    stashes) and then writes the stash contents to a patch file with
        git stash show -p -u
    The patch is stored in the folder given by -SyncPath (a location that is
    typically mirrored across your devices, e.g. a cloud-synced folder).

    On the other device, run the same script with -Apply to replay the patch
    onto the working tree.

    The patch file is always named 'wip.patch' inside -SyncPath.

.PARAMETER SyncPath
    Path to the folder in which 'wip.patch' is saved (create mode) or read
    from (apply mode). Optional and positional (index 0). Resolution order:
      1. This argument, whenever supplied (definitive).
      2. The SYNC_DEVICES_FOLDER environment variable, when it is set.
      3. The '~/syncronizations' fallback.

.PARAMETER Apply
    When supplied, applies the existing 'wip.patch' from -SyncPath to the
    current repository instead of creating a new one.

.EXAMPLE
    .\sync-devices.ps1
    Stash all local changes and write ~/syncronizations/wip.patch.

.EXAMPLE
    .\sync-devices.ps1 "D:\Sync"
    Write the patch to D:\Sync\wip.patch instead of the default folder.

.EXAMPLE
    .\sync-devices.ps1 -Apply
    Apply ~/syncronizations/wip.patch onto the current working tree.

.EXAMPLE
    .\sync-devices.ps1 "D:\Sync" -Apply
    Apply D:\Sync\wip.patch onto the current working tree.
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory = $false)]
    [string]$SyncPath,
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'

# Determine the sync folder when the user did not pass -SyncPath. An explicit
# argument always wins; otherwise fall back to the SYNC_DEVICES_FOLDER
# environment variable, and finally to '~/syncronizations'.
if (-not $PSBoundParameters.ContainsKey('SyncPath')) {
    if ($env:SYNC_DEVICES_FOLDER) {
        $SyncPath = $env:SYNC_DEVICES_FOLDER
    } else {
        $SyncPath = '~/syncronizations'
    }
}

# Resolve a leading '~' to the user's home directory so the path works the same
# way under Windows PowerShell 5.1 and PowerShell 7+.
if ($SyncPath -match '^~([\\/]|$)') {
    $SyncPath = Join-Path $HOME ($SyncPath.Substring(1).TrimStart('/', '\'))
}

# We must be inside a git work tree for any of this to make sense.
$insideRepo = (git rev-parse --is-inside-work-tree 2>$null)
if ($LASTEXITCODE -ne 0 -or $insideRepo -ne 'true') {
    Write-Error "Not inside a git repository. Run this script from within your repo."
    exit 1
}

$patchFile = Join-Path $SyncPath 'wip.patch'

if ($Apply) {
    if (-not (Test-Path -LiteralPath $patchFile)) {
        Write-Error "Patch file not found: $patchFile"
        exit 1
    }

    Write-Host "Applying patch $patchFile ..."
    git apply --whitespace=nowarn -- "$patchFile"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "git apply failed. The patch may not fit the current tree state."
        exit 1
    }

    Write-Host "Done. Changes from wip.patch have been applied to the working tree."
} else {
    if (-not (Test-Path -LiteralPath $SyncPath)) {
        Write-Error "The folder $SyncPath does not exist."
        exit 1
    }

    # Stash everything, including untracked files, under a timestamped message
    # (YYMMDDHHmmSS) so repeated runs don't pile up identically named stashes.
    $stashMsg = "wip: sync $(Get-Date -Format 'yyMMddHHmmss')"
    git stash push -u -m $stashMsg
    if ($LASTEXITCODE -ne 0) {
        Write-Error "git stash push failed."
        exit 1
    }

    # Nothing was stashed => nothing to export. (An empty $topStash must be
    # handled explicitly: `$null -notlike ...` yields $null, not $true.)
    $topStash = (git stash list --format='%gs' 2>$null | Select-Object -First 1)
    if (-not $topStash -or $topStash -notlike "*$stashMsg*") {
        Write-Host "No local changes to sync. Nothing was written."
        exit 0
    }

    # Capture the stash as a unified diff (tracked + untracked). We write the
    # file ourselves as UTF-8 without a BOM and with LF line endings so the
    # patch stays valid regardless of the PowerShell edition's default '>'
    # redirection encoding (5.1 would otherwise produce UTF-16).
    $prevOutEnc = [Console]::OutputEncoding
    try {
        [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
        $patch = (git stash show -p -u) -join "`n"
    } finally {
        [Console]::OutputEncoding = $prevOutEnc
    }
    if ($LASTEXITCODE -ne 0) {
        Write-Error "git stash show failed."
        exit 1
    }

    [System.IO.File]::WriteAllText($patchFile, $patch + "`n", [System.Text.UTF8Encoding]::new($false))

    Write-Host "Patch written to $patchFile"
    Write-Host "Your changes are kept in a stash ('$stashMsg')."
    Write-Host "Restore them on this device with: git stash pop"
}
