local function num(v) return tonumber(SKIN:ParseFormula(SKIN:ReplaceVariables('#' .. v .. '#'))) or 0 end
local function var(v) return tonumber(SKIN:ReplaceVariables('#' .. v .. '#')) end

function Snap(mode)
  local module = SKIN:GetVariable('CURRENTCONFIG'):match('([^\\]+)$')
  SKIN:Bang('!WriteKeyValue', 'Variables', module .. 'Align', mode, SKIN:GetVariable('@') .. 'Modules.inc')
  SKIN:Bang('!SetVariable', 'AlignMode', mode)
  if mode > 0 then
    local m = num('EdgeMargin') * num('Scale')
    local wx, wy, ww, wh = num('WORKAREAX'), num('WORKAREAY'), num('WORKAREAWIDTH'), num('WORKAREAHEIGHT')
    local cx, cy = num('CURRENTCONFIGX'), num('CURRENTCONFIGY')
    local cw, ch = num('CURRENTCONFIGWIDTH'), num('CURRENTCONFIGHEIGHT')
    local x, y = cx, cy
    if mode == 1 then x = wx + m
    elseif mode == 2 then x = wx + (ww - cw) / 2
    elseif mode == 3 then x = wx + ww - cw - m
    elseif mode == 4 then y = wy + m
    elseif mode == 5 then y = wy + wh - ch - m end
    SKIN:Bang('!Move', math.floor(x + 0.5), math.floor(y + 0.5))
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
end

function Update()
  local now = os.clock()
  if now - lastCheck < 0.5 then return 0 end
  lastCheck = now
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
