local STEPS = 14

local function num(v) return tonumber(SKIN:ParseFormula(SKIN:ReplaceVariables(v))) or 0 end
local function opacity(t) return 1 - math.min(math.max(t, 0), 100) / 100 end

local function set(k, redraw)
  cur = k
  SKIN:Bang('!SetVariable', 'FadeK', string.format('%.3f', k))
  if redraw then
    SKIN:Bang('!UpdateMeter', '*')
    SKIN:Bang('!Redraw')
  end
end

function Initialize()
  trans, mode = num('#Trans#'), num('#Hover#')
  rest = opacity(trans)
  from, to, step = rest, rest, STEPS
  SKIN:Bang('!SetTransparency', 255)
  set(rest, false)
end

local BUILTIN_HOVER = { [1] = 3, [2] = 1, [3] = 2 }
local lastCheck = -10

local function builtinSettings()
  local path = SKIN:GetVariable('SETTINGSPATH') .. 'Rainmeter.ini'
  local f = io.open(path, 'rb')
  if not f then return nil end
  local raw = f:read('*a')
  f:close()
  local text = raw:gsub('%z', ''):gsub('^\255\254', '')
  local config = SKIN:GetVariable('CURRENTCONFIG')
  local s = text:find('[' .. config .. ']', 1, true)
  if not s then return nil end
  local e = text:find('\n%[', s + 1) or #text
  local section = text:sub(s, e)
  return tonumber(section:match('AlphaValue=(%d+)')), tonumber(section:match('OnHover=(%d+)'))
end

local function adoptBuiltin()
  local a, h = builtinSettings()
  if (a == nil or a == 255) and (h == nil or h == 0) then return end
  local module = SKIN:GetVariable('CURRENTCONFIG'):match('([^\\]+)$')
  local file = SKIN:GetVariable('@') .. 'Modules.inc'
  if a and a ~= 255 then
    SKIN:Bang('!WriteKeyValue', 'Variables', module .. 'Trans', math.floor((1 - a / 255) * 100 + 0.5), file)
  end
  if h and BUILTIN_HOVER[h] then
    SKIN:Bang('!WriteKeyValue', 'Variables', module .. 'Hover', BUILTIN_HOVER[h], file)
  end
  local ini = SKIN:GetVariable('SETTINGSPATH') .. 'Rainmeter.ini'
  SKIN:Bang('!WriteKeyValue', SKIN:GetVariable('CURRENTCONFIG'), 'AlphaValue', '255', ini)
  SKIN:Bang('!WriteKeyValue', SKIN:GetVariable('CURRENTCONFIG'), 'OnHover', '0', ini)
  SKIN:Bang('!Refresh')
end

function Update()

  if not applied then
    applied = true
    set(cur, true)
  end
  local now = os.clock()
  if now - lastCheck > 1.5 then
    lastCheck = now
    adoptBuiltin()
  end
  return cur
end

local function fadeTo(k)
  from, to, step = cur, k, 0
  SKIN:Bang('!CommandMeasure', 'mFader', 'Stop 1')
  SKIN:Bang('!CommandMeasure', 'mFader', 'Execute 1')
end

function Enter()
  if mode == 1 then fadeTo(1)
  elseif mode == 2 then fadeTo(opacity(math.min(trans * 3, 100)))
  elseif mode == 3 then set(0, true) end
end

function Leave()
  if mode == 1 or mode == 2 then fadeTo(rest)
  elseif mode == 3 then set(rest, true) end
end

function Step()
  step = step + 1
  local t = math.min(step / STEPS, 1)
  t = t * t * (3 - 2 * t)
  set(from + (to - from) * t, true)
end
