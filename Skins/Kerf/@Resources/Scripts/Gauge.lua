local STOPS = {
  { 0.00,  90, 200, 255 },
  { 0.35, 110, 214, 140 },
  { 0.60, 242, 196,  70 },
  { 0.80, 255, 130,  50 },
  { 1.00, 255,  64,  72 },
}

function Initialize()
  pct = SKIN:GetMeasure(SELF:GetOption('Pct', 'mTempPct'))
  var = SELF:GetOption('Var', 'Heat')
  meter = SELF:GetOption('Meter', 'MeterRing')
  last = ''
end

local function heat(p)
  p = math.max(0, math.min(1, p))
  for i = 2, #STOPS do
    local a, b = STOPS[i - 1], STOPS[i]
    if p <= b[1] then
      local t = (p - a[1]) / (b[1] - a[1])
      return string.format('%d,%d,%d', a[2] + (b[2] - a[2]) * t, a[3] + (b[3] - a[3]) * t, a[4] + (b[4] - a[4]) * t)
    end
  end
end

function Update()
  local p = pct and pct:GetValue() or 0
  local c = heat(p)
  if c ~= last then
    last = c
    SKIN:Bang('!SetVariable', var, c)
    SKIN:Bang('!UpdateMeter', meter)
    SKIN:Bang('!Redraw')
  end
  return p
end
