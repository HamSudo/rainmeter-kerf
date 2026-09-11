local STALE = 25

function Initialize()
  kind = SELF:GetOption('Kind', 'CPU')
  raw, tick, gpuKind = SKIN:GetMeasure('mRaw'), SKIN:GetMeasure('mTick'), SKIN:GetMeasure('mGpuKind')
  exe = SKIN:GetVariable('@') .. 'Bin\\KerfSensors.exe'
  lastLaunch, shown, good = -1000, nil, 0
end

local function exists(p)
  local h = io.open(p, 'rb')
  if h then h:close() return true end
  return false
end

local function setLabel(text)
  if text ~= shown then
    shown = text
    SKIN:Bang('!SetVariable', 'Label', text)
  end
end

function Update()
  local now = os.time()
  local fresh = now - (tonumber(tick:GetStringValue()) or 0) <= STALE

  if not fresh and now - lastLaunch > 60 then
    lastLaunch = now
    SKIN:Bang('!CommandMeasure', exists(exe) and 'mLaunch' or 'mBuild', 'Run')
  end

  if kind == 'GPU' and gpuKind:GetStringValue() == 'iGPU' then setLabel('iGPU') else setLabel(kind) end

  local v = tonumber(raw:GetStringValue())
  if v and v > 5 and v < 125 then good = v end
  return good
end
