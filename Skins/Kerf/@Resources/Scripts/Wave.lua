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
  band = 0
  lastGeom = ''
end

local function num(v) return tonumber(SKIN:ParseFormula(SKIN:ReplaceVariables(v))) or 0 end
local function f(v) return string.format('%.2f', v) end

local function point(along, across)
  if vertical then return f(across) .. ',' .. f(along) end
  return f(along) .. ',' .. f(across)
end

local function straight(L, mid)
  local geom = f(L) .. '|' .. f(mid)
  if geom == lastGeom then return end
  lastGeom = geom
  local p = point(0, mid) .. ' | LineTo ' .. point(L, mid)
  for _, meter in ipairs(meters) do
    SKIN:Bang('!SetOption', meter, 'PathMain', p)
    SKIN:Bang('!SetOption', meter, 'PathE1', p)
    SKIN:Bang('!SetOption', meter, 'PathE2', p)
  end
end

local function gradient(ink, c, w, a)
  local function alphaAt(x) return a * math.max(0, 1 - math.abs(x - c) / w) end
  local stops, lastOff = {}, -1
  local function stop(off, alpha)
    if off < 0 or off > 1 or off <= lastOff then return end
    lastOff = off
    stops[#stops + 1] = ink .. ',' .. math.floor(alpha + 0.5) .. ' ; ' .. string.format('%.4f', off)
  end
  stop(0, alphaAt(0))
  stop(c - w, 0)
  stop(c, a)
  stop(c + w, 0)
  if lastOff < 1 then stop(1, alphaAt(1)) end
  return (vertical and 90 or 0) .. ' | ' .. table.concat(stops, ' | ')
end

function Update()

  if num('#Pulse#') == 0 then
    if still then return 0 end
    local L = lengthM and lengthM:GetValue() or 0
    if L <= 0 then return 0 end
    still = true
    straight(L, num('#WaveHeight#') * num('#Scale#') / 2)
    local none = gradient('0,0,0', 0.5, 0.1, 0)
    for _, meter in ipairs(meters) do
      for _, g in ipairs({ 'GradCore', 'GradMid', 'GradGlow' }) do SKIN:Bang('!SetOption', meter, g, none) end
      SKIN:Bang('!UpdateMeter', meter)
    end
    SKIN:Bang('!Redraw')
    return 0
  end

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

  local style = SKIN:GetVariable('WaveStyle', 'glow')

  if style == 'glow' then
    straight(L, mid)

    local b0, b1 = SKIN:GetMeasure('mBass0'), SKIN:GetMeasure('mBass1')
    local bass = ((b0 and b0:GetValue() or 0) + (b1 and b1:GetValue() or 0)) / 2
    bassAvg = (bassAvg or bass) + (bass - (bassAvg or bass)) * (1 - 0.985 ^ frames)
    local punch = math.min(1, math.max(0, (bass - bassAvg * 0.9) / math.max(0.06, bassAvg * 0.7)))
    local base = math.min(0.32, 0.12 + amp * 1.5)
    local target = math.max(base, punch) * (amp > 0.005 and 1 or 0)
    glowLv = glowLv or 0
    glowLv = glowLv + (target - glowLv) * (1 - (target > glowLv and 0.25 or 0.85) ^ frames)
    if glowLv < 0.004 then
      if flat then return 0 end
      flat = true
    else
      flat = false
    end
    local k = glowLv
    local ink = SKIN:GetVariable('AccInk', '242,184,75')
    local a = k * 255 * num('#FadeK#')
    local w = 0.12 + 0.5 * k
    local s = num('#WaveStroke#') * scale
    local maxW = T
    local layers = {
      { 'Shape5', 'GradGlow', math.min(maxW, s * (3 + 9 * k)), 0.16 },
      { 'Shape6', 'GradMid', math.min(maxW, s * (1.6 + 3.5 * k)), 0.4 },
      { 'Shape7', 'GradCore', s * (1 + 0.6 * k), 1 },
    }
    for _, meter in ipairs(meters) do
      for _, ly in ipairs(layers) do
        SKIN:Bang('!SetOption', meter, ly[2], gradient(ink, 0.5, w, a * ly[4]))
        SKIN:Bang('!SetOption', meter, ly[1], 'Path PathMain | StrokeWidth ' .. f(ly[3]) .. ' | Stroke LinearGradient ' .. ly[2] .. ' | Fill Color 0,0,0,0 | StrokeStartCap Round | StrokeEndCap Round')
      end
      SKIN:Bang('!UpdateMeter', meter)
    end
    SKIN:Bang('!Redraw')
    return 0
  end

  if style == 'pulse' then
    straight(L, mid)
    band = (band + frames / 60 * num('#WavePulseSpeed#') * (0.5 + amp)) % 1.4
    if amp < 0.003 then
      if flat then return 0 end
      flat = true
    else
      flat = false
    end
    local ink = SKIN:GetVariable('AccInk', '242,184,75')

    local a = math.min(1, 0.25 + amp * 3) * 255 * num('#FadeK#')
    local w = 0.18 + 0.2 * math.min(1, amp * 2)
    for n, meter in ipairs(meters) do
      local c = band - 0.2
      if n % 2 == 0 then c = 1 - c end
      SKIN:Bang('!SetOption', meter, 'GradCore', gradient(ink, c, w, a))
      SKIN:Bang('!SetOption', meter, 'GradGlow', gradient(ink, c, w * 1.5, a * 0.4))
      SKIN:Bang('!UpdateMeter', meter)
    end
    SKIN:Bang('!Redraw')
    return 0
  end

  lastGeom = ''
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
    SKIN:Bang('!SetOption', meter, 'GradCore', gradient('0,0,0', 0.5, 0.1, 0))
    SKIN:Bang('!SetOption', meter, 'GradGlow', gradient('0,0,0', 0.5, 0.1, 0))
    SKIN:Bang('!UpdateMeter', meter)
  end
  SKIN:Bang('!Redraw')
  return 0
end
