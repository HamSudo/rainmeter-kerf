function Initialize()
  kind = SELF:GetOption('Kind', 'CPU')
  slots = tonumber(SELF:GetOption('Slots', '20'))
  S, L, V = {}, {}, {}
  for i = 0, slots - 1 do
    S[i], L[i], V[i] = SKIN:GetMeasure('mS' .. i), SKIN:GetMeasure('mL' .. i), SKIN:GetMeasure('mV' .. i)
  end
  shown = nil
end

local function has(s, ...)
  for _, p in ipairs({ ... }) do if s:find(p) then return true end end
  return false
end

local function isTemp(label)
  return has(label, 'temp', 'tctl', 'tdie', 'package', 'core max', 'hot spot', 'hotspot', '°c')
end

local function cpuScore(sensor, label)
  if not has(sensor .. ' ' .. label, 'cpu', 'core', 'tctl') then return 0 end
  if has(sensor .. ' ' .. label, 'gpu') or not isTemp(label) then return 0 end
  if has(label, 'cpu package', 'tctl/tdie', 'tctl', 'tdie') then return 100 end
  if has(label, 'core max') then return 70 end
  if has(label, 'cpu') then return 50 end
  return 20
end

local function gpuScore(sensor, label)
  if not has(sensor .. ' ' .. label, 'gpu', 'graphics', 'radeon', 'geforce', 'arc') then return 0 end
  if not isTemp(label) or has(label, 'memory', 'vram', 'mem ', 'vr ', 'liquid') then return 0 end
  local s = 40
  if has(label, 'gpu temperature', '^gpu temp', 'edge') then s = s + 10 end
  if has(label, 'hot spot', 'hotspot', 'junction') then s = s - 15 end
  local integrated = has(sensor, 'uhd', 'iris', 'intel hd', 'intel%(r%) hd', 'radeon%(tm%) graphics', 'radeon graphics',
                         'vega %d+ graphics', 'arc%(tm%) graphics', 'arc graphics', 'igpu', 'integrated')
  local discrete = has(sensor, 'nvidia', 'geforce', 'rtx', 'gtx', 'quadro', 'radeon rx', 'radeon pro', 'rx %d',
                       'arc a%d', 'arc b%d', 'dgpu')
  if discrete then s = s + 100 elseif not integrated then s = s + 60 end
  return s, integrated and not discrete
end

local function setLabel(text)
  if text ~= shown then
    shown = text
    SKIN:Bang('!SetVariable', 'Label', text)
  end
end

function Update()
  local base = SKIN:GetVariable('Label0', kind)
  local forced = tonumber(SKIN:GetVariable(kind .. 'Index', '-1')) or -1
  if forced >= 0 and V[forced] then
    setLabel(base)
    return tonumber(V[forced]:GetStringValue()) or 0
  end

  local list = {}
  for i = 0, slots - 1 do
    local sensor = (S[i] and S[i]:GetStringValue() or ''):lower()
    local label = (L[i] and L[i]:GetStringValue() or ''):lower()
    local value = tonumber(V[i] and V[i]:GetStringValue() or '') or 0
    if label ~= '' then
      local sc, integrated
      if kind == 'GPU' then sc, integrated = gpuScore(sensor, label) else sc = cpuScore(sensor, label) end
      if sc and sc > 0 then list[#list + 1] = { score = sc, value = value, integrated = integrated } end
    end
  end
  table.sort(list, function(a, b) return a.score > b.score end)

  for _, c in ipairs(list) do
    if c.value > 0 then
      setLabel((kind == 'GPU' and c.integrated) and 'iGPU' or base)
      return c.value
    end
  end
  setLabel(base)
  return 0
end
