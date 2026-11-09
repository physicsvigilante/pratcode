local wezterm = require 'wezterm'
local config = {}

-- Use config_builder for clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Tokyo Night (customized, pure black)
config.colors = {
  background = '#000000',
  foreground = '#c0c0c0',
  cursor_bg = '#c0caf5',
  cursor_fg = '#000000',
  selection_bg = '#33467c',
  selection_fg = '#c0caf5',
  ansi = {
    '#15161e',  -- black
    '#e44662',  -- red (matched accent)
    '#6bda59',  -- green (young leaf, +4% sat, -4% red/blue)
    '#e0af68',  -- yellow (orange)
    '#60b8f4',  -- blue (unified)
    '#bb9af7',  -- magenta (purple)
    '#7dcfff',  -- cyan
    '#c0c0c0',  -- white (grey)
  },
  brights = {
    '#414868',  -- bright black
    '#f25672',  -- bright red (matched accent)
    '#84f875',  -- bright green (young leaf bright, +4% sat, -4% red/blue)
    '#e0af68',  -- bright yellow
    '#60b8f4',  -- bright blue (unified)
    '#bb9af7',  -- bright magenta
    '#7dcfff',  -- bright cyan
    '#d5d5d5',  -- bright white
  },
}

-- Font settings
config.font = wezterm.font_with_fallback {
  { family = 'JetBrainsMono Nerd Font', weight = 'Medium' },
  'Segoe UI Emoji',
}
config.font_size = 11.0

-- Window appearance
config.audible_bell = 'Disabled'
config.window_background_opacity = 1.0
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

-- Tab bar
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true

-- Default shell (WSL Ubuntu when available, otherwise default)
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  -- WSL as default; 'Ubuntu' = the distro name in `wsl -l -v`
  config.default_prog = { 'wsl.exe', '-d', 'Ubuntu' }
  -- Fallback: uncomment below and comment above if WSL isn't ready yet
  -- config.default_prog = { 'powershell.exe' }
  -- WSL sees the pane id ($WEZTERM_PANE): claude_autocompact.sh (selfcompact) targets its own pane by it
  -- (WezTerm appends its own TERM:COLORTERM:TERM_PROGRAM:TERM_PROGRAM_VERSION). New panes only.
  config.set_environment_variables = { WSLENV = 'WEZTERM_PANE' }
end

local function move_current_pane_to_relative_tab(window, pane, relative)
  local mux_window = pane:window()
  local tabs = mux_window:tabs_with_info()
  local active_index = nil

  for i, item in ipairs(tabs) do
    if item.is_active then
      active_index = i
      break
    end
  end

  if active_index == nil then
    window:toast_notification('WezTerm', 'Could not find the active tab.', nil, 2000)
    return
  end

  local target_index = active_index + relative
  if target_index < 1 or target_index > #tabs then
    local side = relative < 0 and 'left' or 'right'
    window:toast_notification('WezTerm', 'No tab to the ' .. side .. '.', nil, 2000)
    return
  end

  local target_tab = tabs[target_index].tab
  local target_pane = target_tab:active_pane()
  if target_pane == nil then
    window:toast_notification('WezTerm', 'Target tab has no active pane.', nil, 2000)
    return
  end

  local wezterm_bin = 'wezterm'
  if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
    wezterm_bin = wezterm.executable_dir .. '/wezterm.exe'
  end

  local split_flag = relative < 0 and '--right' or '--left'
  local ok, _, stderr = wezterm.run_child_process {
    wezterm_bin,
    'cli',
    'split-pane',
    '--pane-id',
    tostring(target_pane:pane_id()),
    '--move-pane-id',
    tostring(pane:pane_id()),
    '--top-level',
    split_flag,
  }

  if ok then
    target_tab:activate()
  else
    window:toast_notification('WezTerm', 'Tab merge failed: ' .. stderr, nil, 3000)
  end
end


-- Keybindings
config.keys = {
  { key = 'f', mods = 'CTRL|SHIFT', action = wezterm.action.Search { CaseInSensitiveString = '' } },
  -- Split panes
  { key = 'e', mods = 'CTRL|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'o', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- Navigate panes (arrow keys)
  { key = 'LeftArrow', mods = 'CTRL|ALT', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'CTRL|ALT', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'CTRL|ALT', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'CTRL|ALT', action = wezterm.action.ActivatePaneDirection 'Down' },

  -- Move tabs
  { key = 'PageUp', mods = 'CTRL|SHIFT', action = wezterm.action.MoveTabRelative(-1) },
  { key = 'LeftArrow', mods = 'CTRL|SHIFT', action = wezterm.action.MoveTabRelative(-1) },
  { key = 'PageDown', mods = 'CTRL|SHIFT', action = wezterm.action.MoveTabRelative(1) },
  { key = 'RightArrow', mods = 'CTRL|SHIFT', action = wezterm.action.MoveTabRelative(1) },

  -- Merge current single-pane tab into neighboring tab
  {
    key = 'UpArrow',
    mods = 'CTRL|SHIFT',
    action = wezterm.action_callback(function(window, pane)
      move_current_pane_to_relative_tab(window, pane, -1)
    end),
  },
  {
    key = 'DownArrow',
    mods = 'CTRL|SHIFT',
    action = wezterm.action_callback(function(window, pane)
      move_current_pane_to_relative_tab(window, pane, 1)
    end),
  },
  {
    key = 'mapped:?',
    mods = 'CTRL|SHIFT',
    action = wezterm.action_callback(function(_, pane)
      pane:move_to_new_tab()
    end),
  },

  -- Rearrange panes within the current tab (official primitives)
  { key = 's', mods = 'CTRL|SHIFT', action = wezterm.action.PaneSelect { mode = 'SwapWithActive' } },
  { key = 'mapped:}', mods = 'CTRL|SHIFT', action = wezterm.action.RotatePanes 'Clockwise' },
  { key = 'mapped:{', mods = 'CTRL|SHIFT', action = wezterm.action.RotatePanes 'CounterClockwise' },

  -- Close pane
  { key = 'w', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentPane { confirm = true } },
}

return config
