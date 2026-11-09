# WSL and WezTerm

Windows runs WezTerm (the terminal); WezTerm opens WSL (Ubuntu); Claude Code runs inside WSL. The user runs every
admin or `sudo` command themselves.

## WSL

1. Admin PowerShell: `wsl --install -d Ubuntu`, reboot, create the Linux user. `wsl -l -v` shows the distro name
   (needed in `wezterm.lua`) and `VERSION 2`.
2. In Ubuntu: `sudo apt update && sudo apt install -y git jq curl`. `jq` is required by all three scripts.
3. Code root (`<coding>` in these files): pick one.
   - `/mnt/c/<...>/coding`: on the Windows drive, visible from Windows apps; git and file scans are slower.
   - `~/coding`: Linux disk, fast; Windows sees it at `\\wsl$\Ubuntu\home\<user>\coding`.
   Then `export coding=<coding>` in `~/.zshrc` (or `~/.bashrc`).
4. Shell, optional: zsh instead of bash.
   `sudo apt install -y zsh zsh-autosuggestions zsh-syntax-highlighting fzf fd-find`, `chsh -s "$(which zsh)"`.
   The useful parts of the original `~/.zshrc`:
   - `setopt NO_BEEP AUTO_CD INTERACTIVE_COMMENTS NO_NOMATCH`; history `HISTSIZE=50000 SAVEHIST=100000`,
     `setopt INC_APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_ALL_DUPS`.
   - `bindkey -e`; Up/Down search history by the typed prefix: `bindkey '^[[A' history-search-backward`,
     `bindkey '^[[B' history-search-forward`; `WORDCHARS=${WORDCHARS//\//}` (word moves stop at `/`).
   - Source `/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh` and
     `/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh`, and fzf's key bindings
     (`/usr/share/doc/fzf/examples/key-bindings.zsh`: Ctrl+R history, Ctrl+T files, Alt+C dirs).

## WezTerm

1. Windows: `winget install wez.wezterm` (or the installer from wezterm.org). Font: JetBrainsMono Nerd Font
   (nerdfonts.com), installed in Windows.
2. Copy `wezterm.lua` to `C:\Users\<name>\.wezterm.lua`; set the distro name in `default_prog` if it isn't
   `Ubuntu`. It reloads on save.
3. The one line selfcompact needs: `config.set_environment_variables = { WSLENV = 'WEZTERM_PANE' }`. It passes the
   pane id into WSL. Check in a new pane (old panes lack it): `echo $WEZTERM_PANE` prints a number.
4. Check from WSL: `command -v wezterm.exe` prints `/mnt/c/Program Files/WezTerm/wezterm.exe` (WSL appends the
   Windows PATH). `wezterm.exe cli list` shows the panes.

Keys in `wezterm.lua`:

| Keys | Action |
|------|--------|
| `Ctrl+Shift+C` / `V` | Copy / paste |
| `Ctrl+Shift+F` | Find (case-insensitive) |
| `Ctrl+Shift+E` / `O` | Split right / down |
| `Ctrl+Alt+Arrows` | Move between panes |
| `Ctrl+Shift+S` | Swap the pane with a picked one |
| `Ctrl+Shift+{` / `}` | Rotate panes |
| `Ctrl+Shift+Left/Right`, `PageUp/PageDown` | Move the tab |
| `Ctrl+Shift+Up/Down` | Merge a one-pane tab into the tab left/right |
| `Ctrl+Shift+?` | Move the pane into a new tab |
| `Ctrl+Shift+T` / `W` | New tab / close pane |

Alternatives: Windows Terminal works for everything except selfcompact (no command to type into a pane): compact by
hand. tmux inside any terminal could replace WezTerm (`tmux send-keys`), but `claude_autocompact.sh` would need
porting.

## If Claude Code lines garble

Lines shifted by one column that heal on their own come from ConPTY counting a combining mark (e.g. `w̄`) as its own
column. Fix (only if seen): replace WezTerm's bundled `conpty.dll` and `OpenConsole.exe` (in its install folder) with
both files from Microsoft's NuGet package `Microsoft.Windows.Console.ConPTY` (worked with 1.25.260930003); keep the
old ones renamed. A WezTerm update puts the old ones back.
