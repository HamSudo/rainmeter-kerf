local M = 120
local CURVES = {
  { 'PathE2', -2, 1.18, 0.8 },
  { 'PathE1', 3, 0.86, 1.25 },
  { 'PathMain', 1, 1.0, 1.0 },
}

function Initialize()
  level = SKIN:GetMeasure('mLevel')
  volume = SKIN:GetMeasure('mVolume')
  lengthM = SKIN:GetMeasure('mWaveLen')
  meters = {}
  for name in SELF:GetOption('Meters', 'MeterWave'):gmatch('[^,%s]+') do meters[#meters + 1] = name end
  vertical = SELF:GetOption('Orient', 'H'):upper() == 'V'
  amp, last, flat = 0, os.clock(), false
  phase = { 0, 2.1, 4.2 }
end

local function num(v) return tonumber(SKIN:ParseFormula(SKIN:ReplaceVariables(v))) or 0 end
local function f(v) return string.format('%.2f', v) end

local function point(along, across)
  if vertical then return f(across) .. ',' .. f(along) end
  return f(along) .. ',' .. f(across)
end

function Update()
  if num('#ShowWave#') == 0 then return 0 end

  local now = os.clock()
  local frames = math.min(6, math.max(0.1, (now - last) * 60))
  last = now

  local loud = math.min(1, math.max(0, level and level:GetValue() or 0))
  local vol = 1
  if num('#WaveFollowVolume#') > 0 and volume then
    local v = volume:GetValue()
    if v >= 0 and v <= 100 then vol = (v / 100) ^ 0.7 end
  end
  amp = amp + (loud * vol - amp) * (1 - 0.92 ^ frames)

  local scale = num('#Scale#')
  local L = lengthM and lengthM:GetValue() or 0
  if L <= 0 then return 0 end
  local T = num('#WaveHeight#') * scale
  local mid = T / 2

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

  local hmax = (T / 2 - 1.5 * scale) * num('#WaveAmp#') * amp
  local freq = num('#WaveFrequency#')
  local spread = num('#WaveSpread#')
  local ys = {}
  for i, c in ipairs(CURVES) do
    local row = {}
    for k = 0, M do
      local u = k / M
      local env = math.sin(math.pi * u) ^ spread
      row[k] = env * hmax / c[2] * math.sin(freq * c[3] * (u * 4 - 2) - phase[i])
    end
    ys[i] = row
  end
  for n, meter in ipairs(meters) do
    local sign = (n % 2 == 0) and -1 or 1
    for i, c in ipairs(CURVES) do
      local p = {}
      for k = 0, M do
        p[#p + 1] = (k == 0 and '' or 'LineTo ') .. point(L * k / M, mid - sign * ys[i][k])
      end
      SKIN:Bang('!SetOption', meter, c[1], table.concat(p, ' | '))
    end
    SKIN:Bang('!UpdateMeter', meter)
  end
  SKIN:Bang('!Redraw')
  return 0
end
