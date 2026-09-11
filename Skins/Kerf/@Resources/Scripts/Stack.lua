local CAP = 0.5
local MID = 0.52

local function num(v)
  if v == nil or v == '' then return 0 end
  return tonumber(SKIN:ParseFormula(SKIN:ReplaceVariables(v))) or 0
end

local function chars(s)
  local t = {}
  for c in s:gmatch('[%z\1-\127\194-\244][\128-\191]*') do
    if c ~= ' ' then t[#t + 1] = c end
  end
  return t
end

function Initialize()
  mode = SELF:GetOption('Mode', 'letters')
  prefix = SELF:GetOption('Prefix', 'MeterL')
  count = tonumber(SELF:GetOption('Count', '9'))
  src = SELF:GetOption('SourceMeasure', '')
  srcVar = SELF:GetOption('SourceVar', '')
  upper = SELF:GetOption('Upper', '0') == '1'
  showVar = SELF:GetOption('ShowVar', '')
  lengthM = SELF:GetOption('LengthMeasure', '')
  centerM = SELF:GetOption('CenterYMeasure', '')
  slots = tonumber(SELF:GetOption('Slots', '0')) or 0
  last, ratio, measuredAt = '', nil, nil
end

local function items()
  local s = ''
  if src ~= '' then
    local m = SKIN:GetMeasure(src)
    s = m and m:GetStringValue() or ''
  elseif srcVar ~= '' then
    s = SKIN:GetVariable(srcVar) or ''
  end
  if upper then s = s:upper() end
  local list = chars(s)
  if mode == 'date' then table.insert(list, 1, os.date('%d')) end
  return list
end

function Update()
  local list = items()
  local n = math.min(#list, count)
  local visible = showVar == '' or num('#' .. showVar .. '#') ~= 0
  local maxSize = num(SELF:GetOption('MaxSize', '10'))

  local first = SKIN:GetMeter(prefix .. '1')
  if not ratio and measuredAt and first and first:GetH() > 0 then ratio = first:GetH() / measuredAt end
  local r = ratio or 1.35

  local L = lengthM ~= '' and (SKIN:GetMeasure(lengthM):GetValue()) or num(SELF:GetOption('LengthFormula', '0'))
  local top
  if centerM ~= '' then top = SKIN:GetMeasure(centerM):GetValue() - L / 2
  else top = num(SELF:GetOption('TopFormula', '0')) end

  local lines = math.max(n, slots, 1)
  local size = maxSize
  if lines * maxSize * r * CAP * 1.6 > L then size = L / (lines * r * CAP * 1.6) end
  local h = size * r
  local glyph = h * CAP
  local step = lines > 1 and (L - glyph) / (lines - 1) or 0
  local first_c = top + glyph / 2 + (lines - n) * step / 2

  local sig = table.concat({ tostring(visible), n, string.format('%.1f|%.1f|%.2f|%.3f', top, L, size, r) }, '|')
  for i = 1, n do sig = sig .. '|' .. tostring(list[i]) end
  if sig == last then return n end
  last = sig
  if not ratio then measuredAt = size end

  for i = 1, count do
    local meter = prefix .. i
    if visible and i <= n then
      if list[i] then SKIN:Bang('!SetOption', meter, 'Text', list[i]) end
      SKIN:Bang('!SetOption', meter, 'FontSize', string.format('%.2f', size))
      SKIN:Bang('!SetOption', meter, 'Y', string.format('%.1f', first_c + (i - 1) * step - h * MID))
      SKIN:Bang('!ShowMeter', meter)
    else
      SKIN:Bang('!HideMeter', meter)
    end
    SKIN:Bang('!UpdateMeter', meter)
  end
  SKIN:Bang('!Redraw')
  return n
end
