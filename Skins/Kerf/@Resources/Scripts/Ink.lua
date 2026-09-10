function Initialize()
  avg = SKIN:GetMeasure('mAvgColor')
end

local function lin(c)
  c = c / 255
  if c <= 0.04045 then return c / 12.92 end
  return ((c + 0.055) / 1.055) ^ 2.4
end

function Update()
  local s = avg and avg:GetStringValue() or ''
  local r, g, b = s:match('(%d+)%s*,%s*(%d+)%s*,%s*(%d+)')
  if not r then
    local h = s:match('^#?(%x%x%x%x%x%x)')
    if not h then return 0 end
    r, g, b = tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16)
  end
  return 0.2126 * lin(tonumber(r)) + 0.7152 * lin(tonumber(g)) + 0.0722 * lin(tonumber(b))
end
