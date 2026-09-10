local G = 8
local M = 120

function Initialize()
  N = tonumber(SELF:GetOption('Bands', '24'))
  per = N / G
  bands, env, phase = {}, {}, {}
  for i = 0, N - 1 do bands[i] = SKIN:GetMeasure('mBand' .. i) end
  for g = 1, G do env[g], phase[g] = 0, math.random() * 6.283 end
  last = os.clock()
end

local function num(v) return tonumber(SKIN:ParseFormula(SKIN:ReplaceVariables(v))) or 0 end
local function f(v) return string.format('%.2f', v) end

function Update()
  local now = os.clock()
  local dt = math.min(0.1, math.max(0.001, now - last))
  last = now

  local scale = num('(#Scale#)')
  local W     = num('(#WaveWidth#*#Scale#)')
  local H     = num('(#WaveHeight#*#Scale#)')
  local amp   = num('(#WaveAmp#)')
  local mid   = H / 2
  local A     = amp * (H / 2 - 1.5 * scale)

  for g = 1, G do
    local s = 0
    for j = 0, per - 1 do
      local b = bands[(g - 1) * per + j]
      s = s + (b and b:GetValue() or 0)
    end
    s = s / per
    env[g] = env[g] + (s - env[g]) * (s > env[g] and 0.22 or 0.05)
    phase[g] = phase[g] + dt * (0.8 + g * 0.55) * (0.5 + env[g] * 2.5)
  end

  local p = {}
  for k = 0, M do
    local u = k / M
    local y = 0
    for g = 1, G do
      local freq = 1.2 + (g - 1) * 1.25
      local weight = 1.3 - (g - 1) * 0.12
      y = y + env[g] * weight * math.sin(6.283 * freq * u - phase[g])
    end
    y = y / 2.6
    if y > 1 then y = 1 elseif y < -1 then y = -1 end
    local win = math.sin(math.pi * u) ^ 1.3
    local px, py = u * W, mid - y * A * win
    p[#p + 1] = (k == 0 and '' or 'LineTo ') .. f(px) .. ',' .. f(py)
  end

  SKIN:Bang('!SetOption', 'MeterWave', 'WavePath', table.concat(p, ' | '))
  SKIN:Bang('!UpdateMeter', 'MeterWave')
  SKIN:Bang('!Redraw')
  return 0
end
