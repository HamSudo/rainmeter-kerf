local function num(v) return tonumber(SKIN:GetVariable(v)) or 0 end

function Stack()
  local cx, cy, cw = num('CURRENTCONFIGX'), num('CURRENTCONFIGY'), num('CURRENTCONFIGWIDTH')
  local scale, af = num('Scale'), num('AF')
  local t = SKIN:GetMeter('MeterTime')
  local tw, ty, th = t:GetW(), t:GetY(), t:GetH()
  local drop = tonumber(SELF:GetOption('Baseline', '0.80'))

  local waveW = math.floor(tw / scale + 0.5)
  local waveY = math.floor(cy + ty + th * drop)
  local waveX = math.floor(cx + af * (cw - tw))
  local dateY = math.floor(waveY + num('WaveHeight') * scale + 2 * scale)

  SKIN:Bang('!WriteKeyValue', 'Variables', 'WaveWidth', waveW, SKIN:GetVariable('@') .. 'Variables.inc')
  SKIN:Bang('!Refresh', 'Kerf\\Wave')
  SKIN:Bang('!Move', waveX, waveY, 'Kerf\\Wave')
  SKIN:Bang('!Move', math.floor(cx), dateY, 'Kerf\\Date')
end
