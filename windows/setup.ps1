# Basic windows functionality
winget install --id Microsoft.PowerShell --source winget
winget install --id Mozilla.Firefox.DeveloperEdition --source winget
winget install --id Adobe.Acrobat.Reader.64-bit --source winget
winget install --id Bitwarden.Bitwarden --source winget

# Research
winget install --id JabRef.JabRef --source winget

# Development
winget install --id Git.Git --source winget
winget install --id Microsoft.VisualStudioCode --source winget
winget install --id JGraph.Draw --source winget
winget install --id EclipseAdoptium.Temurin.25.JDK --source winget

# Setup posh git to view diffs on branches
Install-Module posh-git -Scope CurrentUser
echo "Import-Module posh-git" >> $PROFILE
echo "Add-PoshGitToProfile -AllHosts" >> $PROFILE

# Install uv for python
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"