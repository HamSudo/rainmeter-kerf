local STALE = 25

function Initialize()
  kind = SELF:GetOption('Kind', 'CPU')
  labelVar = SELF:GetOption('LabelVar', 'Label')
  local rawName = SELF:GetOption('Raw', 'mRaw')
  raw, tick, gpuKind = SKIN:GetMeasure(rawName), SKIN:GetMeasure('mTick'), SKIN:GetMeasure('mGpuKind')
  exe = SKIN:GetVariable('@') .. 'Bin\\KerfSensors.exe'
  lastLaunch, shown, good = -1000, nil, 0
  source = kind
  if kind == 'GPU' then
    local show = tonumber(SKIN:GetVariable('GPUShow', '0')) or 0
    local both = (tonumber(SKIN:ParseFormula(SELF:GetOption('Both', '0'))) or 0) == 1
    if show == 1 then source = 'iGPU'
    elseif show == 2 then source = 'dGPU'
    elseif show == 3 and both then source = SELF:GetOption('Slot', '1') == '2' and 'iGPU' or 'dGPU'
    else source = 'GPU' end
  end
  SKIN:Bang('!SetOption', rawName, 'RegValue', source)
end

local function exists(p)
  local h = io.open(p, 'rb')
  if h then h:close() return true end
  return false
end

local function setLabel(text)
  if text ~= shown then
    shown = text
    SKIN:Bang('!SetVariable', labelVar, text)
  end
end

function Update()
  local now = os.time()
  local fresh = now - (tonumber(tick:GetStringValue()) or 0) <= STALE

  if not fresh and now - lastLaunch > 60 then
    lastLaunch = now
    SKIN:Bang('!CommandMeasure', exists(exe) and 'mLaunch' or 'mBuild', 'Run')
  end

  if source == 'iGPU' then setLabel('iGPU')
  elseif source == 'dGPU' then setLabel('GPU')
  elseif kind == 'GPU' and gpuKind:GetStringValue() == 'iGPU' then setLabel('iGPU')
  else setLabel(kind) end

  local v = tonumber(raw:GetStringValue())
  if v and v > 5 and v < 125 then good = v end
  return good
end
