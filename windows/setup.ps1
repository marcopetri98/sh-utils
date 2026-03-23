# Basic windows functionality
winget install --id Microsoft.PowerShell --source winget
winget install --id Mozilla.Firefox.DeveloperEdition --source winget
winget install --id Adobe.Acrobat.Reader.64-bit --source winget
winget install --id Bitwarden.Bitwarden --source winget
winget install --id 7zip.7zip --source winget
winget install --id Greenshot.Greenshot --source winget
winget install --id OBSProject.OBSStudio --source winget
winget install --id Spotify.Spotify --source winget

# Microsoft suite
winget install --id Microsoft.Teams --source winget

# Research
winget install --id JabRef.JabRef --source winget
winget install --id Tailscale.Tailscale --source winget
winget install --id DigitalScholar.Zotero --source winget

# Development
winget install --id Git.Git --source winget
winget install --id Docker.DockerDesktop --source winget
winget install --id Microsoft.VisualStudioCode --source winget
winget install --id Bruno.Bruno --source winget
winget install --id Google.Antigravity --source winget
winget install --id MongoDB.Compass.Full --source winget
winget install --id JGraph.Draw --source winget
winget install --id EclipseAdoptium.Temurin.25.JDK --source winget
winget install --id Schniz.fnm --source winget

# Messaging apps
winget install --id Telegram.TelegramDesktop --source winget

# Setup posh git to view diffs on branches
Install-Module posh-git -Scope CurrentUser
Write-Output "Import-Module posh-git" >> $PROFILE
Write-Output "fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression" >> $PROFILE

# Install uv for python
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
