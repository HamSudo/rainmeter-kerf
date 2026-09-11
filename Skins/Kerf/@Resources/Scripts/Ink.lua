local function exists(p)
  if not p or p == '' then return false end
  local h = io.open(p, 'rb')
  if h then h:close() return true end
  return false
end

local function m(name) return SKIN:GetMeasure(name) end

local MARGIN = 0.03
local TAU = 8
local DWELL = 10
lastTick, decided, ema, emaAt, flippedAt = nil, nil, nil, nil, -100

function Initialize()
  avg, we64, we32 = m('mAvgColor'), m('mWE64'), m('mWE32')
  bgType, bgColor, winWall, steam = m('mBgType'), m('mBgColor'), m('mWinWall'), m('mSteamPath')
  every = tonumber(SELF:GetOption('CheckEvery', '20'))
  n, kind, source, weCfg = 0, nil, nil, nil

  screenLum, screenTick, screenAlive, screenCon = m('mScreenLum'), m('mScreenTick'), m('mScreenAlive'), m('mScreenCon')
  local module = SKIN:GetVariable('CURRENTCONFIG'):match('([^\\]+)$')
  SKIN:Bang('!SetOption', 'mScreenLum', 'RegValue', module)
  SKIN:Bang('!SetOption', 'mScreenCon', 'RegValue', module .. 'C')
  haloK = 1
end

local function setHalo(k)
  k = math.floor(k * 10 + 0.5) / 10
  if k == haloK then return end
  haloK = k
  SKIN:Bang('!SetVariable', 'HaloK', string.format('%.1f', k))
  SKIN:Bang('!UpdateMeter', '*')
  SKIN:Bang('!Redraw')
end

local function findWEConfig()
  if exists(weCfg) then return weCfg end
  local candidates = {}
  local override = SKIN:GetVariable('WEConfig', '')
  if override ~= '' then candidates[#candidates + 1] = override end
  local root = (steam and steam:GetStringValue() or ''):gsub('/', '\\')
  if root ~= '' then
    candidates[#candidates + 1] = root .. '\\steamapps\\common\\wallpaper_engine\\config.json'
    local f = io.open(root .. '\\steamapps\\libraryfolders.vdf', 'r')
    if f then
      for p in f:read('*a'):gmatch('"path"%s*"([^"]+)"') do
        candidates[#candidates + 1] = p:gsub('\\\\', '\\') .. '\\steamapps\\common\\wallpaper_engine\\config.json'
      end
      f:close()
    end
  end
  for _, c in ipairs(candidates) do
    if exists(c) then weCfg = c return c end
  end
  return nil
end

local function wePreview()
  local cfg = findWEConfig()
  if not cfg then return nil end
  local f = io.open(cfg, 'r')
  if not f then return nil end
  local t = f:read('*a')
  f:close()
  local s = t:find('"wallpaperconfig"%s*:')
  local file = s and t:match('"file"%s*:%s*"([^"]+)"', s)
  local dir = file and file:match('^(.*)/[^/]*$')
  if not dir then return nil end
  for _, name in ipairs({ 'preview.jpg', 'preview.png', 'preview.gif' }) do
    local p = (dir .. '/' .. name):gsub('/', '\\')
    if exists(p) then return p end
  end
  return nil
end

local function weRunning()
  return (we64 and we64:GetValue() > 0) or (we32 and we32:GetValue() > 0)
end

function CheckSource()
  local k, src = 'none', nil
  if weRunning() then src = wePreview() if src then k = 'we' end end
  if k == 'none' then
    if bgType and bgType:GetValue() == 1 then
      k = 'solid'
    elseif winWall and winWall:GetStringValue() ~= '' then
      k = 'desktop'
    else
      src = (os.getenv('APPDATA') or '') .. '\\Microsoft\\Windows\\Themes\\TranscodedWallpaper'
      if exists(src) then k = 'file' else src = nil end
    end
  end
  if k == kind and src == source then return end
  kind, source = k, src
  if src then
    SKIN:Bang('!SetOption', 'mChameleon', 'Type', 'File')
    SKIN:Bang('!SetOption', 'mChameleon', 'Path', src)
  else
    SKIN:Bang('!SetOption', 'mChameleon', 'Type', 'Desktop')
  end
  SKIN:Bang('!SetVariable', 'InkSource', k)
  SKIN:Bang('!UpdateMeasure', 'mChameleon')
  SKIN:Bang('!UpdateMeasure', 'mAvgColor')
end

local function lin(c)
  c = c / 255
  if c <= 0.04045 then return c / 12.92 end
  return ((c + 0.055) / 1.055) ^ 2.4
end

local function luminance(r, g, b)
  return 0.2126 * lin(tonumber(r)) + 0.7152 * lin(tonumber(g)) + 0.0722 * lin(tonumber(b))
end

function Update()

  local now = os.time()
  local age = now - (tonumber(screenAlive and screenAlive:GetStringValue() or '') or 0)
  if age > 20 and now - (lastLaunch or -1000) > 60 then
    lastLaunch = now
    SKIN:Bang('!CommandMeasure', exists(SKIN:GetVariable('@') .. 'Bin\\KerfSensors.exe') and 'mLaunch' or 'mBuild', 'Run')
  end
  local screen = tonumber(screenLum and screenLum:GetStringValue() or '')
  if screen and age <= 20 then
    local tick = screenTick:GetStringValue()
    if tick ~= lastTick then
      lastTick = tick
      local th = tonumber(SKIN:GetVariable('InkThreshold', '0.3')) or 0.3
      local dt = emaAt and (now - emaAt) or nil
      if ema == nil or not dt or dt >= 4 * TAU then
        ema = screen
      else
        ema = ema + (screen - ema) * (1 - math.exp(-dt / TAU))
      end
      emaAt = now
      if decided == nil then
        decided = ema
        flippedAt = now
      elseif now - flippedAt >= DWELL then
        local wantsDark = ema > th + MARGIN
        local wantsLight = ema < th - MARGIN
        if (wantsDark and decided <= th) or (wantsLight and decided > th) then
          decided = ema
          flippedAt = now
        end
      end
    end
    local con = tonumber(screenCon and screenCon:GetStringValue() or '')
    setHalo(con and con > 0 and math.max(1, math.min(2.5, 4.5 / con)) or 1)
    if decided then return decided end
  end
  setHalo(1)

  if kind == nil or n >= every then n = 0 CheckSource() end
  n = n + 1

  if kind == 'none' then return 0 end
  if kind == 'solid' then
    local r, g, b = (bgColor and bgColor:GetStringValue() or ''):match('(%d+)%s+(%d+)%s+(%d+)')
    return r and luminance(r, g, b) or 0
  end

  local s = avg and avg:GetStringValue() or ''
  local r, g, b = s:match('(%d+)%s*,%s*(%d+)%s*,%s*(%d+)')
  if not r then
    local h = s:match('^#?(%x%x%x%x%x%x)')
    if not h then return 0 end
    r, g, b = tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16)
  end
  return luminance(r, g, b)
end
