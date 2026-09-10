local function num(v) return tonumber(SKIN:GetVariable(v)) or 0 end

function Stack()
  local cx, cy, cw = num('CURRENTCONFIGX'), num('CURRENTCONFIGY'), num('CURRENTCONFIGWIDTH')
  local scale, af = num('Scale'), num('AF')
  local t = SKIN:GetMeter('MeterTime')
  local tw, ty, th = t:GetW(), t:GetY(), t:GetH()
  local baseline = tonumber(SELF:GetOption('Baseline', '0.78'))
  local vars = SKIN:GetVariable('@') .. 'Variables.inc'

  local rowW = math.floor(tw / scale + 0.5)
  local waveH = num('WaveHeight') * scale
  local x = math.floor(cx + af * (cw - tw))
  local waveY = math.floor(cy + ty + th * baseline)
  local dateY = math.floor(waveY + waveH / 2 + 7 * scale)

  SKIN:Bang('!WriteKeyValue', 'Variables', 'WaveWidth', rowW, vars)
  SKIN:Bang('!WriteKeyValue', 'Variables', 'DateRowW', rowW, vars)
  SKIN:Bang('!Refresh', 'Kerf\\Wave')
  SKIN:Bang('!Refresh', 'Kerf\\Date')
  SKIN:Bang('!Move', x, waveY, 'Kerf\\Wave')
  SKIN:Bang('!Move', x, dateY, 'Kerf\\Date')
end

function Unstack()
  SKIN:Bang('!WriteKeyValue', 'Variables', 'DateRowW', 0, SKIN:GetVariable('@') .. 'Variables.inc')
  SKIN:Bang('!Refresh', 'Kerf\\Date')
end
