local function num(v) return tonumber(SKIN:ParseFormula(SKIN:ReplaceVariables(v))) or 0 end

function Initialize()
  targets = {}
  for spec in SELF:GetOption('Targets', ''):gmatch('[^,]+') do
    local m, ref, meas, size = spec:match('^%s*([^|]+)|([^|]+)|([^|]+)|(.-)%s*$')
    if m then targets[#targets + 1] = { meter = m, ref = ref, measure = meas, size = size, last = '' } end
  end
  widthM = SKIN:GetMeasure(SELF:GetOption('Width', 'mColW'))
end

local function count(s)
  local n = 0
  for _ in s:gmatch('[%z\1-\127\194-\244][\128-\191]*') do n = n + 1 end
  return n
end

function Update()
  local W = widthM and widthM:GetValue() or 0
  if W <= 0 then return 0 end
  for _, t in ipairs(targets) do
    local ref = SKIN:GetMeter(t.ref)
    local m = SKIN:GetMeasure(t.measure)
    if ref and m and ref:GetW() > 0 then
      local maxSize = num(t.size)
      local natural = ref:GetW()
      local size = math.min(maxSize, maxSize * 0.9 * W / natural)
      local n = count(m:GetStringValue())
      local naturalAt = natural * size / maxSize
      local px = n > 1 and (W - naturalAt) / (n - 1) or 0

      local meter = SKIN:GetMeter(t.meter)
      if t.applied and t.applied ~= 0 and meter and math.abs(size - (t.appliedSize or 0)) < 0.01 then
        local k = (meter:GetW() - naturalAt) / (n * t.applied)
        if k > 0.3 and k < 3 then t.k = k end
      end
      local spacing = px / (t.k or 1)
      local sig = string.format('%.2f|%.2f', size, spacing)
      if sig ~= t.last and math.abs(spacing - (t.applied or 0)) > 0.05 or t.appliedSize ~= size then
        t.last, t.applied, t.appliedSize = sig, spacing, size
        SKIN:Bang('!SetOption', t.meter, 'FontSize', string.format('%.2f', size))
        SKIN:Bang('!SetOption', t.meter, 'InlineSetting2', string.format('CharacterSpacing | 0 | %.2f | 0', spacing))
        SKIN:Bang('!UpdateMeter', t.meter)
      end
    end
  end
  return 0
end
