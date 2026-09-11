# dotfiles

Personal i3 + rofi + picom + polybar desktop setup and shell/editor config for Debian-based Linux, managed with [GNU Stow](https://www.gnu.org/software/stow/). The repo mirrors the layout of `$HOME`, so it's stowed as a single package straight into your home directory.

Theme: Catppuccin Mocha throughout (i3, rofi, tmux, polybar).

## Contents

| Path | What it is |
|---|---|
| `.config/i3/` | i3 window manager config, split into `config`, `keybinding.conf`, `autostart.conf`, `window.conf` (colors/gaps/borders) |
| `.config/rofi/` | rofi launcher: `config.rasi` (drun), `run.rasi`, `window.rasi`, `powermenu.rasi` |
| `.config/picom/` | picom compositor config (GLX backend, blur, shadows) |
| `.config/polybar/` | polybar status bar: `config.ini`, launch script `polybar-i3.sh`, helper scripts (`polywins.sh`, `bluetooth.sh`) |
| `.config/ohmyposh/` | Oh My Posh prompt themes (`zen.toml` — the one `.zshrc` loads — plus `base.json`) |
| `.config/nvim/` | Neovim config based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), using Neovim's built-in `vim.pack` plugin manager |
| `.config/tmux/` | tmux config + vendored plugins (`tpm`, `tmux-sensible`, `catppuccin-tmux`, `vim-tmux-navigator`) |
| `.config/alacritty.toml`, `.config/catppuccin-mocha.toml` | Alacritty terminal config and color scheme |
| `.config/gtk-3.0/settings.ini` | GTK3 theme settings (Catppuccin-Dark GTK theme, Papirus-Dark icons, Inter font) |
| `.fonts/JetBrainsMono/` | JetBrains Mono Nerd Font (bundled, all weights) |
| `.local/.bin/` | Helper scripts: `lockscreen`, `clipboard-menu`, `rofi-power-menu`, `open_terminal_here.sh`, `extract_zip.sh`, `papirus-folders` |
| `.local/share/rofi/themes/` | Extra rofi `.rasi` themes (Catppuccin, Nord, Tokyo Night, Windows 11, etc.) |
| `Walls/` | Wallpapers + lockscreen background images |
| `.zshrc` | Zsh config — [zinit](https://github.com/zdharma-continuum/zinit) plugins, Oh My Posh prompt, conda init |
| `.stow-local-ignore` | Empty — default Stow ignore patterns apply |

## Prerequisites (Debian)

A few of these packages **aren't in Debian's repos** and need a manual install — those are called out separately below. Install everything apt can give you first:

```bash
sudo apt update
sudo apt install -y \
  git stow zsh curl wget unzip fontconfig build-essential ca-certificates \
  xserver-xorg xinit x11-xserver-utils x11-utils x11-xkb-utils \
  i3 i3lock dex xss-lock \
  rofi picom dunst feh polybar \
  network-manager-gnome blueman \
  wmctrl xdotool maim xclip slop \
  pulseaudio-utils brightnessctl \
  thunar unar zenity \
  papirus-icon-theme fonts-inter \
  alacritty tmux ripgrep fd-find tree-sitter-cli \
  firefox-esr
```

| Package | Why |
|---|---|
| `git`, `stow` | clone + symlink the repo |
| `zsh` | the shell `.zshrc` configures |
| `curl`, `wget`, `unzip` | installers for zinit, Oh My Posh, Neovim, etc. |
| `fontconfig` | `fc-cache` to register the bundled Nerd Font |
| `build-essential` | compiles `telescope-fzf-native` and LuaSnip's `jsregexp` in Neovim |
| `xserver-xorg`, `xinit`, `x11-*-utils` | base X11 session + `setxkbmap`/`xset` (used in `autostart.conf`) |
| `i3` | window manager |
| `i3lock` | base package — **see note below**, the lockscreen script needs `i3lock-color`, not vanilla `i3lock` |
| `dex` | runs autostart `.desktop` entries (`exec --no-startup-id dex --autostart --environment i3`) |
| `xss-lock` | triggers the lockscreen on suspend/idle (`autostart.conf`) |
| `rofi` | app launcher / window switcher / power menu |
| `picom` | compositor (blur, shadows, vsync) |
| `dunst` | notification daemon |
| `feh` | sets the wallpaper (`feh --bg-scale ~/Walls/shaded_landscape.png`) |
| `polybar` | status bar (`polybar-i3.sh` launches it) |
| `network-manager-gnome` | provides `nm-applet` (tray network icon) |
| `blueman` | provides `blueman-applet` (tray) and `blueman-manager` (used by `bluetooth.sh`) |
| `wmctrl`, `xdotool` | window control — used by `polywins.sh`, `clipboard-menu`, screenshot keybinds |
| `maim`, `xclip` | screenshots and clipboard image piping (`keybinding.conf`) |
| `slop` | interactive region selection, used by `polywins.sh`'s resize action |
| `pulseaudio-utils` | provides `pactl` for the volume keybinds |
| `brightnessctl` | brightness keybinds |
| `thunar` | file manager (`$mod+e`) |
| `unar` | archive extraction used by `extract_zip.sh` |
| `zenity` | folder-picker dialog used by `extract_zip.sh` |
| `papirus-icon-theme` | icon theme referenced in `gtk-3.0/settings.ini`, managed by `papirus-folders` |
| `fonts-inter` | GTK font (`gtk-font-name=Inter 12`) |
| `alacritty` | terminal — bound to `$mod+Return`, and used by `open_terminal_here.sh` |
| `tmux` | terminal multiplexer |
| `ripgrep` | powers Neovim/Telescope's `live_grep` |
| `fd-find` | powers Telescope's `find_files`; Debian installs the binary as `fdfind` — see note below |
| `tree-sitter-cli` | Neovim's Treesitter can use it for parser compilation |
| `firefox-esr` | browser, bound to `$mod+b` (Debian's Firefox package is `firefox-esr`) |

### Not available via `apt` — install manually

- **i3lock-color** — `.local/.bin/lockscreen` uses flags (`--blur`, `--ring-color`, `--indicator`, `--clock`, custom fonts/sizes, etc.) that only exist in [i3lock-color](https://github.com/Raymo111/i3lock-color), not the plain `i3lock` from Debian's repos. Build/install it and make sure it's the `i3lock` found on `PATH`, otherwise the lockscreen script errors out on unrecognized flags. Confirmed working on Debian:
  ```bash
  sudo apt install -y libpam0g-dev libcairo2-dev libfontconfig1-dev \
    libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev \
    libxcb-xinerama0-dev libxkbcommon-dev libxkbcommon-x11-dev \
    libjpeg-dev autoconf pkg-config
  git clone https://github.com/Raymo111/i3lock-color.git
  cd i3lock-color
  ./build.sh
  sudo ./install-i3lock-color.sh
  ```
  Note the two-step build: `./build.sh` compiles the binary, then `sudo ./install-i3lock-color.sh` installs it — running the installer alone without building first won't work.

- **greenclip** — the clipboard manager `keybinding.conf` and `clipboard-menu` rely on (`greenclip daemon`, `rofi -modi "clipboard:greenclip print"`). It's a Haskell binary with no Debian package. Confirmed working — grab a specific tagged release rather than assuming a `latest` alias exists:
  ```bash
  mkdir -p ~/.local/bin
  wget https://github.com/erebe/greenclip/releases/download/v4.2/greenclip \
      -O ~/.local/bin/greenclip
  chmod +x ~/.local/bin/greenclip
  ```
  Check [the releases page](https://github.com/erebe/greenclip/releases) for the current version tag if `v4.2` has moved on.

- **VS Code** — bound to `$mod+v` as `code`. Not in Debian's default repos:
  ```bash
  sudo apt install -y gpg wget
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
  sudo apt update && sudo apt install -y code
  ```

- **Neovim** — the config uses `vim.pack`, Neovim's *built-in* plugin manager introduced in **Neovim 0.12**, which is newer than what's in Debian's repos (including testing, most of the time), so it needs a manual install. Confirmed working — install the build dependencies and Telescope/LSP tooling first, then Neovim itself:
  ```bash
  sudo apt update
  sudo apt install -y make gcc ripgrep fd-find tree-sitter-cli unzip git xclip curl

  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  sudo rm -rf /opt/nvim-linux-x86_64
  sudo mkdir -p /opt/nvim-linux-x86_64
  sudo chmod a+rX /opt/nvim-linux-x86_64
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
  sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/
  nvim --version   # confirm it reports 0.12+
  ```

  > **`.zshrc` path mismatch:** `.zshrc` adds `/opt/nvim-linux64/bin` to `PATH` — that's the *old* Neovim release folder naming. Current upstream releases extract to `nvim-linux-x86_64`, not `nvim-linux64`. The `path+=('/opt/nvim-linux64/bin')` line in `.zshrc` is therefore stale and effectively a no-op on a fresh install; it doesn't break anything, but it's not what actually puts `nvim` on your `PATH`. The install above sidesteps the issue entirely by symlinking the binary straight into `/usr/local/bin`, which is already on `PATH` by default — no `.zshrc` edit required. If you'd rather fix `.zshrc` itself, update that line to `/opt/nvim-linux-x86_64/bin` instead.

  Also note `tree-sitter-cli` here — Neovim's Treesitter integration in this config can shell out to it for parser compilation, so it's worth having even though most parsers build fine with just a C compiler.

- **Catppuccin GTK theme** — `gtk-3.0/settings.ini` sets `gtk-theme-name=Catppuccin-Dark`, which isn't in Debian's repos:
  ```bash
  git clone https://github.com/catppuccin/gtk.git /tmp/catppuccin-gtk
  # follow the repo's install script / instructions to generate and install
  # the "Catppuccin-Dark" (or matching accent) variant into ~/.themes or ~/.local/share/themes
  ```

- **Miniconda (optional)** — `.zshrc` has a conda-init block expecting `~/miniconda3`. Skip this if you don't need Python/conda; the block fails silently (falls back to just adding the path) if it's absent.
  ```bash
  curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
  bash Miniconda3-latest-Linux-x86_64.sh -b -p "$HOME/miniconda3"
  rm Miniconda3-latest-Linux-x86_64.sh
  ```

## 1. Clone the repo

Clone straight into your home directory so the parent of the repo *is* `$HOME` — Stow's default target is the parent of the package directory:

```bash
cd ~
git clone https://github.com/forlorn1216/dotfiles.git
cd dotfiles
```

## 2. Back up anything that already exists

Stow refuses to symlink over existing real files. Back up anything that might collide:

```bash
mkdir -p ~/dotfiles-backup
for f in .zshrc .config Walls .fonts .local; do
  [ -e "$HOME/$f" ] && [ ! -L "$HOME/$f" ] && mv "$HOME/$f" ~/dotfiles-backup/
done
```

## 3. Stow the dotfiles

```bash
stow -v --target="$HOME" .
```

If a specific file conflicts, Stow names it exactly — move it aside (step 2) and re-run.

Undo later with `stow -D --target="$HOME" .`; re-link after a `git pull` with `stow -R --target="$HOME" .`.

## 4. `fd` binary name fix (Debian-specific)

Debian's `fd-find` package installs the binary as `fdfind` (there's already an unrelated `fd` package). Telescope/Neovim expect `fd`:

```bash
mkdir -p ~/.local/bin
ln -s "$(which fdfind)" ~/.local/bin/fd
```

## 5. Set default shell, prompt, and fonts

```bash
chsh -s "$(which zsh)"
```
Log out/in (or open a new terminal) for it to apply.

**zinit** auto-installs to `~/.local/share/zinit/zinit.git` on first zsh launch, then pulls in `zsh-syntax-highlighting`, `zsh-completions`, `zsh-autosuggestions`, `fzf-tab`, `zsh-sudo`, and `zsh-you-should-use` — no manual step needed, just open a new zsh session.

**Oh My Posh**:
```bash
curl -s https://ohmyposh.dev/install.sh | bash -s
```
Installs to `~/.local/bin` (already on `PATH`). Theme (`~/.config/ohmyposh/zen.toml`) is already in place once stowed.

**Nerd Font**:
```bash
fc-cache -fv ~/.fonts
```
Then set your terminal's font to **JetBrainsMono Nerd Font**.

## 6. tmux plugins — path mismatch to fix

`tmux.conf` (stowed to `~/.config/tmux/tmux.conf`) loads TPM with:
```
run '~/.tmux/plugins/tpm/tpm'
```
That's a **hardcoded path outside XDG config** — but this repo vendors TPM and its plugins under `~/.config/tmux/plugins/`, not `~/.tmux/plugins/`. Symlink one to the other so the `run` line resolves:

```bash
mkdir -p ~/.tmux
ln -s ~/.config/tmux/plugins ~/.tmux/plugins
```

(Plugins — `tpm`, `tmux-sensible`, `catppuccin-tmux`, `vim-tmux-navigator` — are already vendored in the repo, so you don't need to run TPM's install; the symlink just lets tmux find them.)

## 7. Neovim first run

Once Neovim 0.12+ is installed and the config is stowed to `~/.config/nvim`, just launch `nvim`. On first run, `vim.pack` fetches all plugins from GitHub (needs internet + `git`), and Mason installs `lua_ls`/`stylua`. This can take a minute — let it finish before closing.

## 8. Launching the i3 session

- Via a display manager (LightDM/GDM/SDDM): select the **i3** session at login.
- Via `startx` (no display manager):
  ```bash
  echo "exec i3" > ~/.xinitrc
  startx
  ```

On startup, i3's `autostart.conf` will: remap Caps Lock to Ctrl, run `dex` for autostart entries, arm `xss-lock` + the lockscreen, start `nm-applet` and `blueman-applet`, launch `polybar`, set the wallpaper via `feh`, start `picom`, start `dunst`, and start the `greenclip` daemon.

## Verify

```bash
echo $SHELL          # .../zsh
nvim --version        # 0.12+, from /opt/nvim-linux-x86_64 via /usr/local/bin
fd --version           # resolves via the ~/.local/bin/fd symlink
i3lock --version        # should report i3lock-color, not plain i3lock
```

## Updating

```bash
cd ~/dotfiles
git pull
stow -R --target="$HOME" .
```

## Removing

```bash
cd ~/dotfiles
stow -D --target="$HOME" .
cd ~ && rm -rf ~/dotfiles
```
Restore anything backed up from `~/dotfiles-backup`.

## Troubleshooting

- **`stow: WARNING! stowing X would cause conflicts`** — a real file/dir already exists there; move it aside (step 2) and re-run.
- **Lockscreen errors about unknown option (`--blur`, `--ring-color`, ...)** — you have plain `i3lock` installed instead of `i3lock-color`. See the manual-install note above.
- **`clipboard-menu` / `$alt+v` does nothing, or rofi's clipboard mode is empty** — `greenclip` isn't installed or isn't on `PATH`; check `pgrep greenclip`.
- **tmux says `~/.tmux/plugins/tpm/tpm: No such file or directory`** — do step 6 (the symlink).
- **Telescope `find_files`/`live_grep` error or fall back to slow search** — `fd`/`rg` aren't on `PATH`; check step 4 and that `ripgrep` installed.
- **No compositor effects (blur/shadows/transparency)** — picom may not be autostarting, or `backend = "glx"` in `~/.config/picom/picom.conf` doesn't suit your GPU; try `xrender` on older/integrated graphics.
- **Prompt has no icons / broken glyphs** — terminal isn't set to a Nerd Font, or `fc-cache` wasn't run after stowing `.fonts`.
- **GTK apps look unthemed** — the Catppuccin GTK theme and/or Papirus icon theme aren't actually installed to `~/.themes`/`~/.icons` (or system-wide); `papirus-icon-theme` from apt covers icons, but the GTK theme itself needs the manual step above.
- **zinit plugins don't load** — `rm -rf ~/.local/share/zinit` and open a new zsh session to force a clean reinstall.
