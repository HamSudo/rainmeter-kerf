function Initialize()
  avg = SKIN:GetMeasure('mAvgColor')
  cfg = SKIN:GetVariable('WEConfig', '')
  every = tonumber(SELF:GetOption('CheckEvery', '20'))
  n, current = 0, false
  CheckSource()
end

local function exists(p)
  local h = io.open(p, 'rb')
  if h then h:close() return true end
  return false
end

local function wallpaperEnginePreview()
  if cfg == '' then return nil end
  local f = io.open(cfg, 'r')
  if not f then return nil end
  local t = f:read('*a')
  f:close()
  local s = t:find('"wallpaperconfig"%s*:')
  if not s then return nil end
  local file = t:match('"file"%s*:%s*"([^"]+)"', s)
  local dir = file and file:match('^(.*)/[^/]*$')
  if not dir then return nil end
  for _, name in ipairs({ 'preview.jpg', 'preview.png', 'preview.gif' }) do
    local p = (dir .. '/' .. name):gsub('/', '\\')
    if exists(p) then return p end
  end
  return nil
end

function CheckSource()
  local src = wallpaperEnginePreview()
  if src == current then return end
  current = src
  if src then
    SKIN:Bang('!SetOption', 'mChameleon', 'Type', 'File')
    SKIN:Bang('!SetOption', 'mChameleon', 'Path', src)
  else
    SKIN:Bang('!SetOption', 'mChameleon', 'Type', 'Desktop')
  end
  SKIN:Bang('!UpdateMeasure', 'mChameleon')
  SKIN:Bang('!UpdateMeasure', 'mAvgColor')
end

local function lin(c)
  c = c / 255
  if c <= 0.04045 then return c / 12.92 end
  return ((c + 0.055) / 1.055) ^ 2.4
end

function Update()
  n = n + 1
  if n >= every then n = 0 CheckSource() end

  local s = avg and avg:GetStringValue() or ''
  local r, g, b = s:match('(%d+)%s*,%s*(%d+)%s*,%s*(%d+)')
  if not r then
    local h = s:match('^#?(%x%x%x%x%x%x)')
    if not h then return 0 end
    r, g, b = tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16)
  end
  return 0.2126 * lin(tonumber(r)) + 0.7152 * lin(tonumber(g)) + 0.0722 * lin(tonumber(b))
end
