local M = 120
local CURVES = {
  { 'PathE2', -2, 1.18, 0.8 },
  { 'PathE1', 3, 0.86, 1.25 },
  { 'PathMain', 1, 1.0, 1.0 },
}

function Initialize()
  level = SKIN:GetMeasure('mLevel')
  timeMeter = SKIN:GetMeter('MeterTime')
  amp, last, flat = 0, os.clock(), false
  phase = { 0, 2.1, 4.2 }
end

local function num(v) return tonumber(SKIN:ParseFormula(SKIN:ReplaceVariables(v))) or 0 end
local function f(v) return string.format('%.2f', v) end

function Update()
  if num('#ShowWave#') == 0 then return 0 end

  local now = os.clock()
  local frames = math.min(6, math.max(0.1, (now - last) * 60))
  last = now

  local loud = math.min(1, math.max(0, level and level:GetValue() or 0))
  local target = loud
  amp = amp + (target - amp) * (1 - 0.92 ^ frames)

  local speed = num('#WaveSpeed#') * (0.5 + 0.9 * amp)
  for i, c in ipairs(CURVES) do
    phase[i] = (phase[i] + math.pi / 2 * speed * c[4] * frames) % (2 * math.pi)
  end

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
  local spread = num('#WaveSpread#')

  for i, c in ipairs(CURVES) do
    local p = {}
    for k = 0, M do
      local u = k / M
      local env = math.sin(math.pi * u) ^ spread
      local y = env * hmax / c[2] * math.sin(freq * c[3] * (u * 4 - 2) - phase[i])
      p[#p + 1] = (k == 0 and '' or 'LineTo ') .. f(W * u) .. ',' .. f(mid - y)
    end
    SKIN:Bang('!SetOption', 'MeterWave', c[1], table.concat(p, ' | '))
  end
  SKIN:Bang('!UpdateMeter', 'MeterWave')
  SKIN:Bang('!Redraw')
  return 0
end
