# Windows/WSL symlink flow

1. Create the Windows config dir
```fish
powershell.exe -NoProfile -Command 'mkdir -Force "$env:APPDATA\Zed"'
```

2. Move the real file from dotfiles to Windows
```fish
mv ~/dotfiles/linux/zed/settings.json (wslpath (powershell.exe -NoProfile -Command '$env:APPDATA' | string trim))/Zed/
```

3. Sync Windows config back into dotfiles
```fish
bash ~/dotfiles/windows/zed/sync-settings.sh
```
