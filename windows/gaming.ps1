# Game launcher platforms
winget install --id Valve.Steam --source winget
winget install --id EpicGames.EpicGamesLauncher --source winget
winget install --id GOG.Galaxy --source winget
winget install --id Blizzard.BattleNet --source winget
winget install --id Playnite.Playnite --source winget

# Messaging and contact applications
winget install --id Discord.Discord --source winget

# Monitoring and support apps
winget install --id Guru3D.RTSS --source winget
winget install --id REALiX.HWiNFO --source winget

# Put links for apps to download that can't be installed with winget
Write-Warning "THESE LINKS MUST BE FOLLOWED MANUALLY AS THEY ARE NOT IN WINGET"
Write-Output "NVIDIA APP: https://www.nvidia.com/en-eu/software/nvidia-app/"
Write-Output "Ryzen Master: https://www.amd.com/en/products/software/ryzen-master.html"
Write-Output "Trust GXT 155 Mouse: https://support.trust.com/en/support/solutions/articles/9000240828-gxt-155-caldor-gaming-mouse-black-20411"
