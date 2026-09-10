local K = 4
local M = 96
local CURVES = {
  { 'PathE2', -2 },
  { 'PathE1', 3 },
  { 'PathMain', 1 },
}

function Initialize()
  level = SKIN:GetMeasure('mLevel')
  timeMeter = SKIN:GetMeter('MeterTime')
  amp, phase, last, flat = 0, 0, os.clock(), false
end

local function num(v) return tonumber(SKIN:ParseFormula(SKIN:ReplaceVariables(v))) or 0 end
local function f(v) return string.format('%.2f', v) end

local function envelope(x)
  return (K / (K + x ^ 4)) ^ K
end

function Update()
  if num('#ShowWave#') == 0 then return 0 end

  local now = os.clock()
  local frames = math.min(6, math.max(0.1, (now - last) * 60))
  last = now

  local target = math.min(1, math.max(0, level and level:GetValue() or 0))
  amp = amp + (target - amp) * (1 - 0.9 ^ frames)
  local speed = num('#WaveSpeed#') * (0.6 + 0.8 * amp)
  phase = (phase + math.pi / 2 * speed * frames) % (2 * math.pi)

  if amp < 0.003 then
    if flat then return 0 end
    flat = true
  else
    flat = false
  end

  local scale = num('#Scale#')
  local W = timeMeter:GetW()
  local H = num('#WaveHeight#') * scale
  local mid = H / 2
  local hmax = (H / 2 - 1.5 * scale) * num('#WaveAmp#') * amp
  local freq = num('#WaveFrequency#')

  for _, c in ipairs(CURVES) do
    local p = {}
    for k = 0, M do
      local x = -2 + 4 * k / M
      local y = envelope(x) * hmax / c[2] * math.sin(freq * x - phase)
      p[#p + 1] = (k == 0 and '' or 'LineTo ') .. f(W * k / M) .. ',' .. f(mid - y)
    end
    SKIN:Bang('!SetOption', 'MeterWave', c[1], table.concat(p, ' | '))
  end
  SKIN:Bang('!UpdateMeter', 'MeterWave')
  SKIN:Bang('!Redraw')
  return 0
end
