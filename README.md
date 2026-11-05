# NixOS: MangoWM + Noctalia v5 + SDDM Astronaut (no Home Manager)

**Not built or evaluated by me** (no Nix available while writing). First `nix flake check` may name an attribute or option to fix; paste the error back.

## 1. How it fits together
- **flake.nix** – lists inputs (nixpkgs, mangowm, noctalia) and defines the system `desktop`. `flake.lock` pins exact commits; `nix flake update` moves them.
- **configuration.nix** – only an `imports` list. A **module** is a file that sets NixOS options; NixOS merges all modules into one system.
- **mango**: official module (`mangowm.nixosModules.mango` + `programs.mango.enable`). **noctalia**: package only (`inputs.noctalia.packages.<system>.default`), started by your `autostart.sh`. Different integration methods, as upstream documents.
- **Packages**: `modules/programs/packages.nix`. Add a name, rebuild.
- **Dotfiles**: `scripts/deploy-dotfiles.sh` makes symlinks `~/.config/mango -> ~/dotfiles/.config/mango` etc. Edit a file in either place; it is the same file. Nix never touches them.
- `follows` makes inputs reuse our nixpkgs instead of downloading their own.

## 2. Install (dual boot with Windows)
Before: back up; in Windows disable **Fast Startup** and hibernation; if BitLocker is on, suspend/decrypt before shrinking; shrink C: in Disk Management.
1. Boot a NixOS ISO (UEFI). Create root (and swap if wanted) in the free space. **Do not format the Windows EFI partition.**
2. `mount /dev/<root> /mnt` then `mkdir -p /mnt/boot/efi && mount /dev/<windows-efi> /mnt/boot/efi`.
3. `nixos-generate-config --root /mnt` (note `system.stateVersion` it writes).
4. `git clone <your-nixos-repo> /mnt/etc/nixos-flake` (or copy this folder), then
   `nixos-generate-config --show-hardware-config --root /mnt > hardware-configuration.nix` inside it.
5. `git add -A` (**flakes ignore untracked files**).
6. Edit TODOs: `hosts/desktop/default.nix` (stateVersion), `locale.nix` (timezone/layout), `boot.nix` (ESP mount).
7. `nixos-install --flake /mnt/etc/nixos-flake#desktop --option accept-flake-config true`
8. `nixos-enter --root /mnt -c 'passwd daito'`, reboot. Move the repo to `~/nixos`.
GRUB's Windows entry is found by os-prober at rebuild time.

## 3. First login
```
cd ~/nixos
bash scripts/deploy-dotfiles.sh --dry-run     # preview
bash scripts/deploy-dotfiles.sh               # link dotfiles
xdg-user-dirs-update                          # create ~/Documents etc. (once)
```
Do **not** run your `install.sh`: it is Fedora-only (dnf, rpm repos, `curl | bash` installers) and its step 16 appends duplicate lines to `.zshrc`.

## 4. Commands
| Command | Meaning |
|---|---|
| `nix flake lock` | create `flake.lock` (first time) |
| `nix flake check` | evaluate the flake, catches typos/missing attrs |
| `sudo nixos-rebuild build --flake .#desktop` | build only, change nothing |
| `sudo nixos-rebuild test --flake .#desktop` | activate now, not at boot (reboot undoes it) |
| `sudo nixos-rebuild switch --flake .#desktop` | activate and make it the boot default |
| `nix flake update` | move all inputs to newest; update one: `nix flake update noctalia` |
| `sudo nixos-rebuild list-generations` | list past system versions |
| `sudo nixos-rebuild switch --rollback` | return to previous generation |
Safe update: `nix flake update` → `build` → `nvd diff /run/current-system ./result` → `test` → `switch`. If boot breaks, pick an older entry in the GRUB "NixOS - All configurations" submenu. Commit `flake.lock` each time it works.

## 5. Changes needed in YOUR dotfiles (not made; your call)
1. `bind.conf`: `brave-origin` → `brave` (nixpkgs name). `limusic-app` and `Telegram` binds do nothing unless you add those apps (e.g. `telegram-desktop`; limusic is not in my package list).
2. `autostart.sh`: the `/usr/libexec/xdg-desktop-portal*` lines are Fedora paths and are harmless no-ops here (portals start via D-Bus, configured in `portals.nix`). Optional: replace `gsettings set ...` with `dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"` (needs no schemas).
3. `.zshrc`: **no change**. `~/.oh-my-zsh` becomes a link to a Nix-built tree with your plugins/theme.
4. GTK/Qt: I haven't seen `settings.ini` / `qt6ct.conf`. Themes your `install.sh` cloned by git (e.g. adwaita-amoled) are not installed by this config; send those files and I'll map each name.
5. Noctalia GUI changes are saved in `~/.local/state/noctalia/settings.toml` and override your TOML.
6. Wallpaper widget `ashur-d/wallpaper-widget` is a Noctalia plugin, installed from inside Noctalia, not Nix.

## 6. Custom SDDM background
Copy an image to `modules/desktop/backgrounds/bg.png`, then in `sddm.nix` wrap the package:
```nix
sddm-astronaut = (pkgs.sddm-astronaut.override {
  embeddedTheme = "japanese_aesthetic";
  themeConfig = { HeaderTextColor = "#d5c4a1"; Background = "Backgrounds/bg.png"; };
}).overrideAttrs (old: {
  postInstall = (old.postInstall or "") + ''
    cp ${./backgrounds/bg.png} $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/bg.png
  '';
});
```
(Verify the theme directory name with step "SDDM theme" below; adjust if it differs.)

## 7. Troubleshooting
- **Flake eval error** – read the *first* `error:` line; `--show-trace` for detail. "attribute 'x' missing" = package renamed: search https://search.nixos.org/packages?channel=unstable. Untracked file → `git add`.
- **Missing package** – same; names I'm least sure of: `noto-fonts-color-emoji`, `whitesur-icon-theme`, `qt6Packages.qt6ct`.
- **Mango not in SDDM** – `ls /run/current-system/sw/share/wayland-sessions` should list `mango.desktop`; check `programs.mango.addLoginEntry`.
- **Mango won't start** – from a TTY (Ctrl+Alt+F3): `mango -c ~/.config/mango/config.conf -p` validates config; `journalctl -b | grep -i mango`.
- **Noctalia missing** – `command -v noctalia`; `pgrep -a noctalia`; run `noctalia` in a terminal for errors; check `autostart.sh` ran (it needs `+x`: `chmod +x`).
- **SDDM theme not loading** – `ls /run/current-system/sw/share/sddm/themes/`; test: `sddm-greeter-qt6 --test-mode --theme /run/current-system/sw/share/sddm/themes/sddm-astronaut-theme`. Needs the override in BOTH `systemPackages` and `extraPackages`.
- **Zsh plugin errors** – `ls -l ~/.oh-my-zsh` must point to `/etc/oh-my-zsh`; if it's a real dir from before, move it and re-run deploy. `echo $ZSH_CACHE_DIR` should be `~/.cache/oh-my-zsh`.
- **Qt theme not applied** – `echo $QT_QPA_PLATFORMTHEME` = `qt6ct`; relogin after rebuild; run `qt6ct` once to confirm style/icons.
- **Symlink conflicts** – script lists them and changes nothing; move yours aside, or use `--backup`. Undo: `--undo`.
- **Wallpaper permissions** – `ls -ld ~ ~/Pictures ~/Pictures/Wallpaper`; home must be traversable by you; the link must resolve (`readlink -f`).
- **Windows missing from GRUB** – Windows disk must be mounted/visible; rebuild with `os-prober` available (it is); check `sudo os-prober`.
- **Clock wrong in Windows** – config sets local-time RTC; if Windows is also configured for UTC, remove `time.hardwareClockInLocalTime` in `boot.nix`.
