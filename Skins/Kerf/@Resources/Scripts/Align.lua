local function num(v) return tonumber(SKIN:ParseFormula(SKIN:ReplaceVariables('#' .. v .. '#'))) or 0 end
local function var(v) return tonumber(SKIN:ReplaceVariables('#' .. v .. '#')) end

local function ink()
  return 0, 0, num('CURRENTCONFIGWIDTH'), num('CURRENTCONFIGHEIGHT')
end

local function save(key, value)
  SKIN:Bang('!SetVariable', module .. key, value)
  SKIN:Bang('!WriteKeyValue', 'Variables', module .. key, value, SKIN:GetVariable('@') .. 'Modules.inc')
end

local function locked() return (var(module .. 'Align') or 0) ~= 0 end

local function setLock(on)
  SKIN:Bang('!Draggable', on and '0' or '1')
  SKIN:Bang('!KeepOnScreen', on and '0' or '1')
end

local function pin()
  if not locked() then return end
  local sx, sy = var(module .. 'SnapX') or 0, var(module .. 'SnapY') or 0
  if sx == 0 and sy == 0 then return end
  local m = num('EdgeMargin') * num('Scale')
  local wx, wy, ww, wh = num('WORKAREAX'), num('WORKAREAY'), num('WORKAREAWIDTH'), num('WORKAREAHEIGHT')
  local cx, cy = num('CURRENTCONFIGX'), num('CURRENTCONFIGY')
  local l, t, r, b = ink()
  if r - l <= 0 or b - t <= 0 then return end
  local x, y = cx, cy
  if sx == 1 then x = wx + m - l
  elseif sx == 2 then x = wx + (ww - (l + r)) / 2
  elseif sx == 3 then x = wx + ww - m - r end
  if sy == 4 then y = wy + m - t
  elseif sy == 5 then y = wy + wh - m - b end
  x, y = math.floor(x + 0.5), math.floor(y + 0.5)
  if math.abs(x - cx) >= 1 or math.abs(y - cy) >= 1 then SKIN:Bang('!Move', x, y) end
end

function Snap(mode)
  if mode == 0 then
    save('Align', 0) save('SnapX', 0) save('SnapY', 0)
    setLock(false)
  else
    if mode <= 3 then save('SnapX', mode) else save('SnapY', mode) end
    save('Align', 1)
    setLock(true)
    pin()
  end
  SKIN:Bang('!UpdateMeasure', 'mAlign')
  SKIN:Bang('!UpdateMeter', '*')
  SKIN:Bang('!Redraw')
end

local function screenHeight()
  local x = num('CURRENTCONFIGX') + num('CURRENTCONFIGWIDTH') / 2
  local y = num('CURRENTCONFIGY') + num('CURRENTCONFIGHEIGHT') / 2
  for n = 1, 16 do
    local sx, sy = var('SCREENAREAX@' .. n), var('SCREENAREAY@' .. n)
    local sw, sh = var('SCREENAREAWIDTH@' .. n), var('SCREENAREAHEIGHT@' .. n)
    if not (sx and sy and sw and sh) or sw <= 0 then break end
    if x >= sx and x < sx + sw and y >= sy and y < sy + sh then return sh end
  end
  return var('SCREENAREAHEIGHT')
end

function Initialize()
  module = SKIN:GetVariable('CURRENTCONFIG'):match('([^\\]+)$')
  dpi = SKIN:GetMeasure('mDPI')
  away, lastCheck = nil, -10
  setLock(locked())
end

function Update()
  local now = os.clock()
  if now - lastCheck < 0.5 then return 0 end
  lastCheck = now
  pin()
  if var('DisplayMode') ~= 0 then return 0 end
  local h = screenHeight()
  if not h or h <= 0 then return 0 end
  local d = dpi and dpi:GetValue() or 0
  if d < 96 then d = 96 end
  local want = math.floor(h * d / 96 / 1080 * 100 + 0.5) / 100
  local have = var(module .. 'AutoScale') or 1
  if math.abs(want - have) < 0.01 then away = nil return 0 end
  away = away or now
  if now - away > 1.5 then
    away = nil
    SKIN:Bang('!WriteKeyValue', 'Variables', module .. 'AutoScale', string.format('%.2f', want), SKIN:GetVariable('@') .. 'Modules.inc')
    SKIN:Bang('!Refresh')
  end
  return 0
end
