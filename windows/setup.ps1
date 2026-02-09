# Basic windows functionality
winget install --id Microsoft.PowerShell --source winget
winget install --id Mozilla.Firefox.DeveloperEdition --source winget
winget install --id Adobe.Acrobat.Reader.64-bit --source winget
winget install --id Bitwarden.Bitwarden --source winget

# Research
winget install --id JabRef.JabRef --source winget

# Development
winget install --id Microsoft.VisualStudioCode --source winget
winget install --id JGraph.Draw --source winget
winget install --id EclipseAdoptium.Temurin.25.JDK --source winget

# Install uv for python
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"