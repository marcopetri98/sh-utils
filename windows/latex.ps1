Invoke-WebRequest https://mirror.ctan.org/systems/texlive/tlnet/install-tl-windows.exe -OutFile TexLiveWindows.exe
Write-Host "Installing TexLive..."
Start-Process .\TexLiveWindows.exe -wait
rm .\TexLiveWindows.exe