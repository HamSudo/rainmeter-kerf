function Initialize()
  N = tonumber(SELF:GetOption('Bands', '24'))
  bands, sm = {}, {}
  for i = 0, N - 1 do
    bands[i] = SKIN:GetMeasure('mBand' .. i)
    sm[i] = 0
  end
  lastSec, secStart = -1, os.clock()
end

local function num(v) return tonumber(SKIN:ParseFormula(SKIN:ReplaceVariables(v))) end
local function f(v) return string.format('%.2f', v) end

function Update()
  local scale  = num('(#Scale#)')
  local W      = num('(#WaveWidth#*#Scale#)')
  local H      = num('(#WaveHeight#*#Scale#)')
  local amp    = num('(#WaveAmp#)')
  local mid    = H / 2
  local A      = amp * (H / 2 - 2 * scale)

  local pts = {}
  for i = 0, N - 1 do
    local k = i / (N - 1)
    local target = (bands[i] and bands[i]:GetValue() or 0) * (1.15 - k * 0.6)
    local rate = target > sm[i] and 0.35 or 0.08
    sm[i] = sm[i] + (target - sm[i]) * rate
    local win = math.sin(math.pi * k) ^ 1.4
    local sign = (i % 2 == 0) and -1 or 1
    pts[i] = { k * W, mid + sign * math.min(sm[i], 1) * A * win }
  end

  local p = { f(pts[0][1]) .. ',' .. f(pts[0][2]) }
  for i = 1, N - 2 do
    local mx = (pts[i][1] + pts[i + 1][1]) / 2
    local my = (pts[i][2] + pts[i + 1][2]) / 2
    p[#p + 1] = 'CurveTo ' .. f(mx) .. ',' .. f(my) .. ',' .. f(pts[i][1]) .. ',' .. f(pts[i][2])
  end
  p[#p + 1] = 'LineTo ' .. f(pts[N - 1][1]) .. ',' .. f(pts[N - 1][2])
  SKIN:Bang('!SetOption', 'MeterWave', 'WavePath', table.concat(p, ' | '))

  local t = os.date('*t')
  if t.sec ~= lastSec then lastSec, secStart = t.sec, os.clock() end
  local pos = math.min(0.999, (t.sec + math.min(os.clock() - secStart, 0.99)) / 60)
  local a0, a1 = math.max(0.001, pos - 0.07), math.min(0.998, pos + 0.02)
  local acc = SKIN:GetVariable('AccInk')
  local on = num('(#WaveMarker#)') > 0
  local grad = '0 | ' .. acc .. ',0 ; 0.0 | ' .. acc .. ',0 ; ' .. f(a0) .. ' | ' .. acc .. ',255 ; ' .. string.format('%.3f', pos) .. ' | ' .. acc .. ',0 ; ' .. f(a1) .. ' | ' .. acc .. ',0 ; 1.0'
  SKIN:Bang('!SetOption', 'MeterWave', 'AccGrad', grad)
  SKIN:Bang('!SetOption', 'MeterWave', 'Shape3', 'Rectangle ' .. f(pos * W - scale) .. ',' .. f(mid - 7 * scale) .. ',' .. f(2 * scale) .. ',' .. f(14 * scale) .. ' | Fill Color ' .. acc .. ',' .. (on and '255' or '0') .. ' | StrokeWidth 0')
  if not on then SKIN:Bang('!SetOption', 'MeterWave', 'AccGrad', '0 | ' .. acc .. ',0 ; 0.0 | ' .. acc .. ',0 ; 1.0') end
  SKIN:Bang('!UpdateMeter', 'MeterWave')
  SKIN:Bang('!Redraw')
  return 0
end
