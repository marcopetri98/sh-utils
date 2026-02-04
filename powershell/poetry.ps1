<#
.SYNOPSIS
    Sets up the poetry environment variables to easily switch between different
    python and poetry versions.

.DESCRIPTION
    This script creates the environment variables such that the poetry 
    environment is set up to a specific location and it is specified depending
    on the python version used.

.PARAMETER FolderPath
    The absolute path to the folder that will be referenced by the
    environment variables used in this script.  This parameter is
    mandatory and positional (index 0), so it must be supplied as the
    first argument when invoking the script.

.PARAMETER DryRun
    When supplied, the script just print what would be set or checked.

.PARAMETER Check
    When supplied, the script just print checks of the defined variables.

.EXAMPLE
    .\poetry.ps1 "D:\Data"
    Run the script normally on the specified folder.

.EXAMPLE
    .\Example.ps1 "D:\Data" -DryRun
    Perform a dry‑run check on the specified folder.

.EXAMPLE
    .\poetry.ps1 "D:\Data" -Check
    Checks the defined variables without setting them.

#>

[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$FolderPath,
    [switch]$DryRun,
    [switch]$Check
)

function Print-Poetry-Envs {
    param(
        [switch]$Verbose
    )

    $poetry_base = [Environment]::GetEnvironmentVariable('POETRY_BASE','User')
    $poetry_home = [Environment]::GetEnvironmentVariable('POETRY_HOME','User')
    $path = [Environment]::GetEnvironmentVariable('Path','User')
    $py_ver = [Environment]::GetEnvironmentVariable('PYTHON_VERSION','User')

    if ($Verbose) {
        Write-Verbose "POETRY_BASE    = $poetry_base"
        Write-Verbose "POETRY_HOME    = $poetry_home"
        Write-Verbose "PYTHON_VERSION = $py_ver"
        Write-Verbose "Path           = $path"
    } else {
        Write-Host "POETRY_BASE    = $poetry_base"
        Write-Host "POETRY_HOME    = $poetry_home"
        Write-Host "PYTHON_VERSION = $py_ver"
        Write-Host "Path           = $path"
    }
}

$py_ver = [Environment]::GetEnvironmentVariable('PYTHON_VERSION','User')
if (-not $py_ver) {
    Write-Error "The environment variable 'PYTHON_VERSION' is required but was not found. Consider running python.ps1 first."
    exit 1
}

$poetry_base = [Environment]::GetEnvironmentVariable('POETRY_BASE','User')
$poetry_home = [Environment]::GetEnvironmentVariable('POETRY_HOME','User')
$path = [Environment]::GetEnvironmentVariable('Path','User')

if ($Check) {
    Print-Poetry-Envs
    exit 0
}

Print-Poetry-Envs -Verbose

Write-Verbose "Creating virtual environment POETRY_HOME and POETRY_BASE"
if ($DryRun) {
    Write-Host "Would've written $FolderPath to POETRY_BASE"
    Write-Host "Would've written %POETRY_BASE%%PYTHON_VERSION% to POETRY_HOME"
} else {
    [Environment]::SetEnvironmentVariable('POETRY_BASE', $FolderPath, 'User')
    [Environment]::SetEnvironmentVariable('POETRY_HOME', '%POETRY_BASE%%PYTHON_VERSION%', 'User')
}

Print-Poetry-Envs -Verbose

$poetry_base = [Environment]::GetEnvironmentVariable('POETRY_BASE','User')
$poetry_home = [Environment]::GetEnvironmentVariable('POETRY_HOME','User')
$real_path_to_set = Join-Path $poetry_base$py_ver 'bin'
$path_to_set = '%POETRY_BASE%%PYTHON_VERSION%\bin'
Write-Verbose "Adding the path $real_path_to_set to Path specified as $path_to_set"

$raw_path = Get-Item "HKCU:\Environment"
$raw_path = $raw_path.GetValue("Path", $null, "DoNotExpandEnvironmentNames")
$parts = $raw_path -split ';' | Where-Object { $_ -ne '' }
$parts = $parts | Where-Object { $_ -ne $path_to_set }
$new_path = ($parts + $path_to_set) -join ';'

if ($DryRun) {
    Write-Host "Would've written $new_path to Path"
} else {
    [Environment]::SetEnvironmentVariable('Path', $new_path, 'User')
}

if (-not $DryRun) {
    Print-Poetry-Envs
}