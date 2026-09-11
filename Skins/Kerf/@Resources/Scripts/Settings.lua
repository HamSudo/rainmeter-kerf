local MODULES  = { 'Clock', 'CPU', 'GPU' }
local ACCENTS  = {
  { '242,184,75',  '150,114,46' },
  { '143,179,255', '60,92,170'  },
  { '111,214,176', '38,122,92'  },
  { '255,127,106', '170,70,55'  },
  { '226,230,234', '84,90,96'   },
}

local FONTS    = { 'Hanken Grotesk', 'JetBrains Mono' }

local FONT_LABELS = {}

local DISPLAYS = { 1.00, 1.33, 2.00 }
local PARTS    = { 'Time', 'Seconds', 'Wave', 'Day', 'Date' }
local LAYOUT_NAMES = {
  Clock = { [0] = 'Classic', 'Vertical', 'Horizontal' },
}
local LAYOUT_FILES = {
  Clock = { [0] = 'Clock.ini', 'Vertical.ini', 'Horizontal.ini' },
}

local ON_BG, ON_FG   = '232,236,240,255', '14,17,21,255'
local OFF_BG, OFF_FG = '255,255,255,16', '214,220,226,235'

local vars, mods, target

local function get(name) return SKIN:GetVariable(name) or '' end

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

function Render()
  for _, m in ipairs(MODULES) do button('BtnT' .. m, m == target) end
  SKIN:Bang('!SetOption', 'ValSize', 'Text', getn(target .. 'Size') .. '%')
  SKIN:Bang('!SetOption', 'ValTrans', 'Text', getn(target .. 'Trans') .. '%')
  for i = 0, 3 do button('BtnH' .. i, getn(target .. 'Hover') == i) end

  local isClock = target == 'Clock'
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
  SKIN:Bang(names[0] and '!HideMeter' or '!ShowMeter', 'NoteLayout')

  local edges = isClock and layout == 2
  for i = 0, 5 do
    if i >= 4 then SKIN:Bang(edges and '!ShowMeter' or '!HideMeter', 'BtnA' .. i) end
    button('BtnA' .. i, getn(target .. 'Align') == i)
  end

  for _, part in ipairs(PARTS) do
    SKIN:Bang(isClock and '!ShowMeter' or '!HideMeter', 'BtnS' .. part)
    if isClock then button('BtnS' .. part, getn('ClockShow' .. part) == 1) end
  end
  SKIN:Bang(isClock and '!HideMeter' or '!ShowMeter', 'NoteShow')
  local twelve = get('HourFormat') == '%I'
  for _, m in ipairs({ 'LblFormat', 'BtnFmt24', 'BtnFmt12' }) do SKIN:Bang(isClock and '!ShowMeter' or '!HideMeter', m) end
  button('BtnFmt24', not twelve)
  button('BtnFmt12', twelve)

  local accent = get('Accent'):gsub('%s', '')
  for i, a in ipairs(ACCENTS) do
    local on = accent == a[1]
    SKIN:Bang('!SetOption', 'Sw' .. i, 'Shape', 'Rectangle 1,1,22,22 | Fill Color ' .. a[1] .. ',255 | StrokeWidth 1.5 | Stroke Color 255,255,255,' .. (on and '255' or '0'))
  end
  local fi = fontIndex()
  SKIN:Bang('!SetOption', 'ValFont', 'Text', FONT_LABELS[FONTS[fi]] or FONTS[fi])
  SKIN:Bang('!SetOption', 'ValFont', 'FontFace', FONTS[fi])
  SKIN:Bang('!SetOption', 'ValFontCount', 'Text', fi .. ' / ' .. #FONTS)
  for i = 0, 2 do button('BtnI' .. i, getn('InkMode') == i) end
  for i, s in ipairs(DISPLAYS) do button('BtnD' .. i, math.abs(getn('BaseScale') - s) < 0.01) end

  SKIN:Bang('!UpdateMeter', '*')
  SKIN:Bang('!Redraw')
end

function Initialize()
  vars = get('@') .. 'Variables.inc'
  mods = get('@') .. 'Modules.inc'
  target = 'Clock'
  local wx, wy = getn('WORKAREAX'), getn('WORKAREAY')
  local ww, wh = getn('WORKAREAWIDTH'), getn('WORKAREAHEIGHT')
  SKIN:Bang('!Move', math.floor(wx + (ww - getn('W')) / 2), math.floor(wy + (wh - getn('H')) / 2))
  Render()
end

function Target(m)
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

function Hover(n)
  put(target .. 'Hover', n, mods) refresh(target) Render()
end

function Align(n)
  SKIN:Bang('!SetVariable', target .. 'Align', n)
  SKIN:Bang('!CommandMeasure', 'mAlignScript', 'Snap(' .. n .. ')', 'Kerf\\' .. target)
  Render()
end

function Layout(n)
  local file = (LAYOUT_FILES[target] or {})[n]
  if not file then return end
  put(target .. 'Layout', n, mods)
  if not (target == 'Clock' and n == 2) and getn(target .. 'Align') >= 4 then
    put(target .. 'Align', 0, mods)
  end
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

function Font(delta)
  local i = (fontIndex() - 1 + delta) % #FONTS + 1
  put('FontFace', FONTS[i], vars)
  refresh() Render()
end

function Ink(n)
  put('InkMode', n, vars) refresh() Render()
end

function Display(i)
  put('BaseScale', string.format('%.2f', DISPLAYS[i]), vars) refresh() Render()
end
