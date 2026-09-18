local MODULES  = { 'Clock', 'CPU', 'GPU', 'Media' }
local ACCENTS  = {
  { '242,184,75',  '150,114,46' },
  { '143,179,255', '60,92,170'  },
  { '111,214,176', '38,122,92'  },
  { '255,127,106', '170,70,55'  },
  { '226,230,234', '84,90,96'   },
  { '176,140,255', '98,64,190'  },
  { '255,110,199', '170,40,120' },
  { '90,220,235',  '20,120,140' },
  { '190,235,90',  '90,130,20'  },
  { '255,77,94',   '170,30,45'  },
  { '255,150,60',  '170,85,20'  },
  { '232,170,150', '150,95,80'  },
}

local FONTS    = {
  'Hanken Grotesk', 'JetBrains Mono', 'Rajdhani', 'Orbitron', 'Teko',
  'Audiowide', 'Russo One', 'Chakra Petch', 'Bebas Neue', 'Share Tech Mono',
  'Doto', 'Space Mono', 'Tilt Neon', 'VT323', 'Tektur',
  'Cyber Track', 'Track',
}
local OPTIONAL_FONTS = { ['Cyber Track'] = 'Cyber Track.otf', ['Track'] = 'Track.ttf' }

local FONT_LABELS = {}

local FONT_PROFILES = {}
local DEFAULT_PROFILE = { TimeTracking = -2, VDigitGap = 0, TempTracking = 0 }

local FONT_METRICS = {
  ['Hanken Grotesk']  = { VCapTop = 0.226, VBase = 0.767, VDotW = 0.058, VDotH = 0.083, VDotGap = 0.196, VDotR = 0.00 },
  ['JetBrains Mono']  = { VCapTop = 0.212, VBase = 0.773, VDotW = 0.121, VDotH = 0.111, VDotGap = 0.209, VDotR = 0.42 },
  ['Rajdhani']        = { VCapTop = 0.225, VBase = 0.729, VDotW = 0.029, VDotH = 0.107, VDotGap = 0.185, VDotR = 0.02 },
  ['Orbitron']        = { VCapTop = 0.231, VBase = 0.806, VDotW = 0.065, VDotH = 0.065, VDotGap = 0.338, VDotR = 0.00 },
  ['Teko']            = { VCapTop = 0.234, VBase = 0.669, VDotW = 0.057, VDotH = 0.078, VDotGap = 0.182, VDotR = 0.00 },
  ['Audiowide']       = { VCapTop = 0.227, VBase = 0.776, VDotW = 0.099, VDotH = 0.099, VDotGap = 0.215, VDotR = 0.50 },
  ['Russo One']       = { VCapTop = 0.179, VBase = 0.768, VDotW = 0.149, VDotH = 0.124, VDotGap = 0.191, VDotR = 0.00 },
  ['Chakra Petch']    = { VCapTop = 0.225, VBase = 0.763, VDotW = 0.066, VDotH = 0.066, VDotGap = 0.216, VDotR = 0.37 },
  ['Bebas Neue']      = { VCapTop = 0.185, VBase = 0.731, VDotW = 0.082, VDotH = 0.082, VDotGap = 0.212, VDotR = 0.00 },
  ['Share Tech Mono'] = { VCapTop = 0.164, VBase = 0.785, VDotW = 0.089, VDotH = 0.089, VDotGap = 0.266, VDotR = 0.00 },
  ['Doto']            = { VCapTop = 0.232, VBase = 0.792, VDotW = 0.070, VDotH = 0.070, VDotGap = 0.200, VDotR = 0.50 },
  ['Space Mono']      = { VCapTop = 0.274, VBase = 0.756, VDotW = 0.095, VDotH = 0.095, VDotGap = 0.165, VDotR = 0.50 },
  ['Tilt Neon']       = { VCapTop = 0.238, VBase = 0.784, VDotW = 0.071, VDotH = 0.123, VDotGap = 0.162, VDotR = 0.29 },
  ['VT323']           = { VCapTop = 0.240, VBase = 0.800, VDotW = 0.108, VDotH = 0.160, VDotGap = 0.160, VDotR = 0.05 },
  ['Tektur']          = { VCapTop = 0.231, VBase = 0.769, VDotW = 0.069, VDotH = 0.077, VDotGap = 0.200, VDotR = 0.00 },
  ['Cyber Track']     = { VCapTop = 0.100, VBase = 0.800, VDotW = 0.120, VDotH = 0.120, VDotGap = 0.290, VDotR = 0.00 },
}
local DEFAULT_METRICS = { VCapTop = 0.22, VBase = 0.77, VDotW = 0.08, VDotH = 0.08, VDotGap = 0.2, VDotR = 0.3 }
local DISPLAYS = { 1.00, 1.33, 2.00 }
local PARTS    = { 'Time', 'Seconds', 'Pulse', 'Day', 'Date' }
local MEDIA_PARTS = { 'Art', 'Title', 'Artist', 'Pulse', 'Bar' }
local LAYOUT_NAMES = {
  Clock = { [0] = 'Classic', 'Vertical', 'Horizontal' },
  CPU   = { [0] = 'Horizontal', 'Vertical', 'Gauge' },
  GPU   = { [0] = 'Horizontal', 'Vertical', 'Gauge' },
}
local LAYOUT_FILES = {
  Clock = { [0] = 'Clock.ini', 'Vertical.ini', 'Horizontal.ini' },
  CPU   = { [0] = 'CPU.ini', 'Vertical.ini', 'Gauge.ini' },
  GPU   = { [0] = 'GPU.ini', 'Vertical.ini', 'Gauge.ini' },
}

local WEIGHTS = { 300, 400, 700 }
local FONT_WEIGHTS = {
  ['Hanken Grotesk'] = { 300, 400, 700 }, ['JetBrains Mono'] = { 300, 400, 700 },
  ['Rajdhani'] = { 300, 400, 700 },       ['Orbitron'] = { 400, 700 },
  ['Teko'] = { 300, 400, 700 },           ['Audiowide'] = { 400 },
  ['Russo One'] = { 400 },                ['Chakra Petch'] = { 300, 400, 700 },
  ['Bebas Neue'] = { 400 },               ['Share Tech Mono'] = { 400 },
  ['Doto'] = { 300, 400, 700 },           ['Space Mono'] = { 400, 700 },
  ['Tilt Neon'] = { 400 },                ['VT323'] = { 400 },
  ['Tektur'] = { 400, 700 },              ['Cyber Track'] = { 400 },
  ['Track'] = { 400 },
}
local WEIGHT_PARTS = { 'All', 'Time', 'Day', 'Date' }
local weightPart = 'All'

local vars, mods, target
local menuOpen = false

local function get(name) return SKIN:GetVariable(name) or '' end

local function themed(name, fallback) local v = get(name) return v ~= '' and v or fallback end
local ON_BG, ON_FG, OFF_BG, OFF_FG, RING
local function getn(name) return tonumber(get(name)) or 0 end

local function put(name, value, file)
  SKIN:Bang('!SetVariable', name, value)
  SKIN:Bang('!WriteKeyValue', 'Variables', name, value, file)
end

local function refresh(module)
  if module then SKIN:Bang('!Refresh', 'Kerf\\' .. module) else SKIN:Bang('!RefreshGroup', 'Kerf') end
end

local function button(meter, on)
  SKIN:Bang('!SetOption', meter, 'SolidColor', on and ON_BG or OFF_BG)
  SKIN:Bang('!SetOption', meter, 'FontColor', on and ON_FG or OFF_FG)
end

local MODULE_METERS = {
  'LblSize', 'LblTrans', 'BtnSizeDown', 'ValSize', 'BtnSizeUp', 'BtnTransDown', 'ValTrans', 'BtnTransUp',
  'LblHover', 'BtnH0', 'BtnH1', 'BtnH2', 'BtnH3', 'LblLayout', 'LblAlign',
  'BtnA0', 'BtnA1', 'BtnA2', 'BtnA3', 'BtnA4', 'BtnA5', 'BtnA6',
}
local OPTIONAL_METERS = {
  'BtnL0', 'BtnL1', 'BtnL2', 'NoteLayout', 'LblShow', 'BtnSTime', 'BtnSSeconds', 'BtnSPulse', 'BtnSDay', 'BtnSDate', 'BtnSFlip',
  'LblFormat', 'BtnFmt24', 'BtnFmt12', 'LblWeight', 'BtnWPAll', 'BtnWPTime', 'BtnWPDay', 'BtnWPDate', 'BtnW300', 'BtnW400', 'BtnW700',
  'LblUnits', 'BtnU0', 'BtnU1', 'LblGpu', 'BtnG0', 'BtnG1', 'BtnG2', 'BtnG3',
  'BtnRA0', 'BtnRA1', 'BtnMArt', 'BtnMTitle', 'BtnMArtist', 'BtnMPulse', 'BtnMBar', 'BtnMAutoHide',
}
local GENERAL_METERS = {
  'LblAccent', 'Sw1', 'Sw2', 'Sw3', 'Sw4', 'Sw5', 'Sw6', 'Sw7', 'Sw8', 'Sw9', 'Sw10', 'Sw11', 'Sw12',
  'LblFont', 'ValFont', 'FontChevron', 'LblInk', 'LblDisplay', 'BtnI0', 'BtnI1', 'BtnI2', 'BtnD0', 'BtnD1', 'BtnD2', 'BtnD3',
}

local function renderGeneral()
  local accent = get('Accent'):gsub('%s', '')
  for i, a in ipairs(ACCENTS) do
    local on = accent == a[1]
    SKIN:Bang('!SetOption', 'Sw' .. i, 'Shape', 'Rectangle 1,1,22,22 | Fill Color ' .. a[1] .. ',255 | StrokeWidth 1.5 | Stroke Color ' .. RING .. ',' .. (on and '255' or '0'))
  end
  local fi = fontIndex()
  SKIN:Bang('!SetOption', 'ValFont', 'Text', FONT_LABELS[FONTS[fi]] or FONTS[fi])
  SKIN:Bang('!SetOption', 'ValFont', 'FontFace', FONTS[fi])
  for i = 0, 2 do button('BtnI' .. i, getn('InkMode') == i) end
  for i = 0, #DISPLAYS do button('BtnD' .. i, getn('DisplayMode') == i) end
end

function Render()
  local general = target == 'General'
  for _, m in ipairs(MODULES) do button('BtnT' .. m, m == target) end
  button('BtnTGeneral', general)
  for _, m in ipairs(GENERAL_METERS) do SKIN:Bang(general and '!ShowMeter' or '!HideMeter', m) end
  for _, m in ipairs(MODULE_METERS) do SKIN:Bang(general and '!HideMeter' or '!ShowMeter', m) end
  button('BtnPDark', getn('PanelTheme') ~= 1)
  button('BtnPLight', getn('PanelTheme') == 1)
  if general then
    for _, m in ipairs(OPTIONAL_METERS) do SKIN:Bang('!HideMeter', m) end
    SKIN:Bang('!SetVariable', 'Shift', -448)
    renderGeneral()
    SKIN:Bang('!UpdateMeter', '*')
    SKIN:Bang('!Redraw')
    return
  end
  SKIN:Bang('!SetOption', 'ValSize', 'Text', getn(target .. 'Size') .. '%')
  SKIN:Bang('!SetOption', 'ValTrans', 'Text', getn(target .. 'Trans') .. '%')
  for i = 0, 3 do button('BtnH' .. i, getn(target .. 'Hover') == i) end

  local isClock = target == 'Clock'
  local isMedia = target == 'Media'
  local layout = getn(target .. 'Layout')
  local names = LAYOUT_NAMES[target] or {}
  for i = 0, 2 do
    local meter = 'BtnL' .. i
    if names[i] then
      SKIN:Bang('!SetOption', meter, 'Text', names[i])
      SKIN:Bang('!ShowMeter', meter)
      button(meter, layout == i)
    else
      SKIN:Bang('!HideMeter', meter)
    end
  end
  SKIN:Bang('!HideMeter', 'NoteLayout')
  -- the card has only the one layout, so the row offers its artwork instead
  SKIN:Bang('!SetOption', 'LblLayout', 'Text', isMedia and 'Artwork' or 'Layout')
  for i = 0, 1 do
    SKIN:Bang(isMedia and '!ShowMeter' or '!HideMeter', 'BtnRA' .. i)
    if isMedia then button('BtnRA' .. i, getn('MediaDisc') == i) end
  end

  button('BtnA0', getn(target .. 'Align') == 0)
  for i = 1, 6 do
    SKIN:Bang('!ShowMeter', 'BtnA' .. i)
    button('BtnA' .. i, false)
  end

  for _, part in ipairs(PARTS) do
    SKIN:Bang(isClock and '!ShowMeter' or '!HideMeter', 'BtnS' .. part)
    if isClock then button('BtnS' .. part, getn('ClockShow' .. part) == 1) end
  end
  for _, part in ipairs(MEDIA_PARTS) do
    SKIN:Bang(isMedia and '!ShowMeter' or '!HideMeter', 'BtnM' .. part)
    if isMedia then button('BtnM' .. part, getn('MediaShow' .. part) == 1) end
  end
  SKIN:Bang(isMedia and '!ShowMeter' or '!HideMeter', 'BtnMAutoHide')
  if isMedia then button('BtnMAutoHide', getn('MediaAutoHide') == 1) end
  local flips = not isClock and not isMedia and layout ~= 2
  SKIN:Bang(flips and '!ShowMeter' or '!HideMeter', 'BtnSFlip')
  SKIN:Bang((isClock or isMedia or flips) and '!ShowMeter' or '!HideMeter', 'LblShow')
  if flips then button('BtnSFlip', getn(target .. 'Flip') == 1) end
  renderWeights(isClock)
  renderTemp(isClock, isMedia, layout)
  local twelve = get('HourFormat') == '%I'
  for _, m in ipairs({ 'LblFormat', 'BtnFmt24', 'BtnFmt12' }) do SKIN:Bang(isClock and '!ShowMeter' or '!HideMeter', m) end
  button('BtnFmt24', not twelve)
  button('BtnFmt12', twelve)

  SKIN:Bang('!UpdateMeter', '*')
  SKIN:Bang('!Redraw')
end

function Initialize()
  vars = get('@') .. 'Variables.inc'
  mods = get('@') .. 'Modules.inc'
  for i = #FONTS, 1, -1 do
    local file = OPTIONAL_FONTS[FONTS[i]]
    if file then
      local h = io.open(get('@') .. 'Fonts\\' .. file, 'rb')
      if h then h:close() else table.remove(FONTS, i) end
    end
  end
  target = 'General'
  ON_BG, ON_FG = themed('POnBg', '232,236,240,255'), themed('POnFg', '14,17,21,255')
  OFF_BG, OFF_FG = themed('PBtnBg', '255,255,255,16'), themed('PBtnFg', '214,220,226,235')
  RING = themed('PRing', '255,255,255')
  local panel = get('CURRENTPATH') .. get('CURRENTFILE')
  local keep = get('PanelKeep') == '1'
  if keep then
    target = get('PanelTab') ~= '' and get('PanelTab') or 'Clock'
    SKIN:Bang('!WriteKeyValue', 'Variables', 'PanelKeep', '0', panel)
  end
  Render()
  if not keep then
    local wx, wy = getn('WORKAREAX'), getn('WORKAREAY')
    local ww, wh = getn('WORKAREAWIDTH'), getn('WORKAREAHEIGHT')
    SKIN:Bang('!Move', math.floor(wx + (ww - getn('W')) / 2), math.floor(wy + (wh - getn('H') - getn('Shift')) / 2))
  end
end

function Target(m)
  if menuOpen then FontMenu(0) end
  target = m
  Render()
end

function Size(delta)
  local v = math.min(400, math.max(10, getn(target .. 'Size') + delta))
  put(target .. 'Size', v, mods) refresh(target) Render()
end

function Trans(delta)
  local v = math.min(100, math.max(0, getn(target .. 'Trans') + delta))
  put(target .. 'Trans', v, mods) refresh(target) Render()
end

local LIMITS = { Size = { 10, 400 }, Trans = { 0, 100 } }

function Edit(what)
  local meter = SKIN:GetMeter('Val' .. what)
  if not meter then return end
  local function opt(k, v) SKIN:Bang('!SetOption', 'mInput', k, v) end

  opt('X', meter:GetX() + 10) opt('Y', meter:GetY() + 6)
  opt('W', math.max(30, meter:GetW() - 20)) opt('H', math.max(12, meter:GetH() - 12))
  opt('DefaultValue', getn(target .. what))
  editing = what
  SKIN:Bang('!UpdateMeasure', 'mInput')
  SKIN:Bang('!CommandMeasure', 'mInput', 'ExecuteBatch 1')
end

function Typed(text)
  local what = editing
  if not what then return end
  local v = tonumber((text or ''):match('%-?[%d%.]+'))
  if not v then return end
  local lim = LIMITS[what]
  v = math.floor(math.min(lim[2], math.max(lim[1], v)) + 0.5)
  put(target .. what, v, mods) refresh(target) Render()
end

function Hover(n)
  put(target .. 'Hover', n, mods) refresh(target) Render()
end

function Align(n)
  SKIN:Bang('!SetVariable', target .. 'Align', n == 0 and 0 or 1)
  SKIN:Bang('!CommandMeasure', 'mAlignScript', 'Snap(' .. n .. ')', 'Kerf\\' .. target)
  Render()
end

function Layout(n)
  local file = (LAYOUT_FILES[target] or {})[n]
  if not file then return end
  put(target .. 'Layout', n, mods)
  SKIN:Bang('!ActivateConfig', 'Kerf\\' .. target, file)
  Render()
end

function Format(hours)
  if hours == 12 then
    put('TimeFormat', '%I:%M', vars) put('HourFormat', '%I', vars)
  else
    put('TimeFormat', '%H:%M', vars) put('HourFormat', '%H', vars)
  end
  refresh('Clock') Render()
end

function Toggle(part)
  local key = 'ClockShow' .. part
  put(key, 1 - getn(key), mods) refresh('Clock') Render()
end

local function has(list, w) for _, v in ipairs(list) do if v == w then return true end end return false end

local function weightsOf(part)
  return FONT_WEIGHTS[get('FontFace')] or { 400 }
end

function WeightPart(p) weightPart = p Render() end

function Weight(w)
  if not has(weightsOf(weightPart), w) then return end
  local parts = weightPart == 'All' and { 'Time', 'Day', 'Date' } or { weightPart }
  for _, p in ipairs(parts) do put(p .. 'Weight', w, vars) end
  refresh('Clock') Render()
end

local function fitWeights()
  for _, p in ipairs({ 'Time', 'Day', 'Date' }) do
    if not has(weightsOf(p), getn(p .. 'Weight')) then put(p .. 'Weight', 400, vars) end
  end
end

function renderWeights(isClock)
  for _, p in ipairs(WEIGHT_PARTS) do
    SKIN:Bang(isClock and '!ShowMeter' or '!HideMeter', 'BtnWP' .. p)
    button('BtnWP' .. p, p == weightPart)
  end
  SKIN:Bang(isClock and '!ShowMeter' or '!HideMeter', 'LblWeight')
  local avail = weightsOf(weightPart)
  local prev = 'BtnWPDate'
  for _, w in ipairs(WEIGHTS) do
    local meter = 'BtnW' .. w
    if isClock and has(avail, w) then
      SKIN:Bang('!SetOption', meter, 'X', '([' .. prev .. ':X] + [' .. prev .. ':W] + ' .. (prev == 'BtnWPDate' and 16 or 4) .. ')')
      SKIN:Bang('!ShowMeter', meter)
      local on
      if weightPart == 'All' then
        on = getn('TimeWeight') == w and getn('DayWeight') == w and getn('DateWeight') == w
      else
        on = getn(weightPart .. 'Weight') == w
      end
      button(meter, on)
      prev = meter
    else
      SKIN:Bang('!HideMeter', meter)
    end
  end
end

local function hasGpu(which)
  local m = SKIN:GetMeasure(which == 'i' and 'mHasI' or 'mHasD')
  local v = tonumber(m and m:GetStringValue() or '')
  return v ~= nil and v > 5
end

function renderTemp(isClock, isMedia, layout)
  local temp = not isClock and not isMedia
  for _, m in ipairs({ 'LblUnits', 'BtnU0', 'BtnU1' }) do SKIN:Bang(temp and '!ShowMeter' or '!HideMeter', m) end
  if temp then
    button('BtnU0', getn(target .. 'Fahr') ~= 1)
    button('BtnU1', getn(target .. 'Fahr') == 1)
  end
  local pick = target == 'GPU' and hasGpu('i') and hasGpu('d')
  local show = getn('GPUShow')
  local rows = 3
  if temp then
    local y = layout ~= 2 and 408 or 352
    SKIN:Bang('!SetOption', 'LblUnits', 'Y', y)
    SKIN:Bang('!SetOption', 'BtnU0', 'Y', y + 16)
    SKIN:Bang('!SetOption', 'LblGpu', 'Y', y + 56)
    SKIN:Bang('!SetOption', 'BtnG0', 'Y', y + 72)
    rows = (layout ~= 2 and 1 or 0) + 1 + (pick and 1 or 0)
  end
  SKIN:Bang('!SetVariable', 'Shift', isMedia and -328 or ((rows - 3) * 56 - 216))
  for i = 0, 3 do
    local visible = pick
    SKIN:Bang(visible and '!ShowMeter' or '!HideMeter', 'BtnG' .. i)
    if visible then button('BtnG' .. i, show == i) end
  end
  SKIN:Bang(pick and '!ShowMeter' or '!HideMeter', 'LblGpu')
end

function Artwork(n)
  put('MediaDisc', n, mods) refresh('Media') Render()
end

function AutoHide()
  put('MediaAutoHide', 1 - getn('MediaAutoHide'), mods) refresh('Media') Render()
end

function MediaToggle(part)
  local key = 'MediaShow' .. part
  put(key, 1 - getn(key), mods) refresh('Media') Render()
end

function Units(f)
  put(target .. 'Fahr', f, mods) refresh(target) Render()
end

function GpuShow(n)
  put('GPUShow', n, mods) refresh('GPU') Render()
end

function Flip()
  local key = target .. 'Flip'
  put(key, 1 - getn(key), mods) refresh(target) Render()
end

function Accent(i)
  put('Accent', ACCENTS[i][1], vars)
  put('AccentOnLight', ACCENTS[i][2], vars)
  refresh() Render()
end

function fontIndex()
  local current = get('FontFace')
  for i, name in ipairs(FONTS) do if name == current then return i end end
  return 1
end

local function optColors(i, hover)
  local sel = i == fontIndex()
  SKIN:Bang('!SetOption', 'FontOpt' .. i, 'SolidColor', sel and ON_BG or (hover and OFF_BG or '0,0,0,1'))
  SKIN:Bang('!SetOption', 'FontOpt' .. i, 'FontColor', sel and ON_FG or OFF_FG)
end

function FontMenu(open)
  if open == nil then open = not menuOpen else open = open == 1 end
  menuOpen = open
  local verb = open and '!ShowMeter' or '!HideMeter'
  SKIN:Bang('!SetOption', 'FontMenuBg', 'Shape', 'Rectangle 0,0,([ValFont:W]),' .. (#FONTS * 24 + 8) .. ',6 | Fill Color #PInputBg# | Stroke Color #PStroke# | StrokeWidth 1')
  SKIN:Bang(verb, 'FontCatch')
  SKIN:Bang(verb, 'FontMenuBg')
  for i, name in ipairs(FONTS) do
    if open then
      SKIN:Bang('!SetOption', 'FontOpt' .. i, 'Text', FONT_LABELS[name] or name)
      SKIN:Bang('!SetOption', 'FontOpt' .. i, 'FontFace', name)
      optColors(i, false)
    end
    SKIN:Bang(verb, 'FontOpt' .. i)
  end
  SKIN:Bang('!UpdateMeter', '*')
  SKIN:Bang('!Redraw')
end

function FontHover(i, on)
  if not menuOpen then return end
  optColors(i, on == 1)
  SKIN:Bang('!UpdateMeter', 'FontOpt' .. i)
  SKIN:Bang('!Redraw')
end

function PickFont(i)
  FontMenu(0)
  if i ~= fontIndex() then Font(i - fontIndex()) end
end

function Font(delta)
  local i = (fontIndex() - 1 + delta) % #FONTS + 1
  put('FontFace', FONTS[i], vars)
  local prof, met = FONT_PROFILES[FONTS[i]] or {}, FONT_METRICS[FONTS[i]] or {}
  for k, val in pairs(DEFAULT_PROFILE) do put(k, prof[k] or val, vars) end
  for k, val in pairs(DEFAULT_METRICS) do put(k, met[k] or val, vars) end
  fitWeights()
  refresh() Render()
end

function Ink(n)
  put('InkMode', n, vars) refresh() Render()
end

function Theme(n)
  put('PanelTheme', n, vars)
  local panel = get('CURRENTPATH') .. get('CURRENTFILE')
  SKIN:Bang('!WriteKeyValue', 'Variables', 'PanelTab', target, panel)
  SKIN:Bang('!WriteKeyValue', 'Variables', 'PanelKeep', '1', panel)
  SKIN:Bang('!Refresh')
end

function Display(i)
  put('DisplayMode', i, vars) refresh() Render()
end
