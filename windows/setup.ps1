# Basic windows functionality
winget install --id Microsoft.PowerShell --source winget
winget install --id Mozilla.Firefox.DeveloperEdition --source winget
winget install --id Adobe.Acrobat.Reader.64-bit --source winget
winget install --id Bitwarden.Bitwarden --source winget
winget install --id 7zip.7zip --source winget
winget install --id Greenshot.Greenshot --source winget

# Research
winget install --id JabRef.JabRef --source winget
winget install --id Tailscale.Tailscale --source winget
winget install --id DigitalScholar.Zotero --source winget

# Development
winget install --id Git.Git --source winget
winget install --id Docker.DockerDesktop --source winget
winget install --id Microsoft.VisualStudioCode --source winget
winget install --id ZedIndustries.Zed --source winget
winget install --id JGraph.Draw --source winget
winget install --id EclipseAdoptium.Temurin.25.JDK --source winget

# Setup posh git to view diffs on branches
Install-Module posh-git -Scope CurrentUser
Write-Output "Import-Module posh-git" >> $PROFILE
Write-Output "Add-PoshGitToProfile -AllHosts" >> $PROFILE

# Install uv for python
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
