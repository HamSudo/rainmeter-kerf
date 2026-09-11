local MODULES  = { 'Clock', 'CPU', 'GPU' }
local ON_BG, ON_FG   = '232,236,240,255', '14,17,21,255'
local OFF_BG, OFF_FG = '255,255,255,16', '214,220,226,235'

local mods, target

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

  SKIN:Bang('!UpdateMeter', '*')
  SKIN:Bang('!Redraw')
end

function Initialize()
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

