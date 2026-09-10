function Initialize()
  kind = SELF:GetOption('Kind', 'CPU')
  raw, tick, gpuKind = SKIN:GetMeasure('mRaw'), SKIN:GetMeasure('mTick'), SKIN:GetMeasure('mGpuKind')
  lastLaunch, shown = -1000, nil
end

local function setLabel(text)
  if text ~= shown then
    shown = text
    SKIN:Bang('!SetVariable', 'Label', text)
  end
end

function Update()
  local now = os.time()
  local fresh = now - (tonumber(tick:GetStringValue()) or 0) <= 8

  if not fresh and now - lastLaunch > 30 then
    lastLaunch = now
    SKIN:Bang('!CommandMeasure', 'mLaunch', 'Run')
  end

  if kind == 'GPU' and gpuKind:GetStringValue() == 'iGPU' then setLabel('iGPU') else setLabel(kind) end
  if not fresh then return 0 end
  return tonumber(raw:GetStringValue()) or 0
end
