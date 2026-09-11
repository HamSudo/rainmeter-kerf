local STEPS = 14

local function num(v) return tonumber(SKIN:ParseFormula(SKIN:ReplaceVariables(v))) or 0 end
local function opacity(t) return 1 - math.min(math.max(t, 0), 100) / 100 end

local function set(k, redraw)
  cur = k
  SKIN:Bang('!SetVariable', 'FadeK', string.format('%.3f', k))
  if redraw then
    SKIN:Bang('!UpdateMeter', '*')
    SKIN:Bang('!Redraw')
  end
end

function Initialize()
  trans, mode = num('#Trans#'), num('#Hover#')
  rest = opacity(trans)
  from, to, step = rest, rest, STEPS
  SKIN:Bang('!SetTransparency', 255)
  set(rest, false)
end

function Update()
  if not applied then
    applied = true
    set(cur, true)
  end
  return cur
end

local function fadeTo(k)
  from, to, step = cur, k, 0
  SKIN:Bang('!CommandMeasure', 'mFader', 'Stop 1')
  SKIN:Bang('!CommandMeasure', 'mFader', 'Execute 1')
end

function Enter()
  if mode == 1 then fadeTo(1)
  elseif mode == 2 then fadeTo(opacity(math.min(trans * 3, 100)))
  elseif mode == 3 then set(0, true) end
end

function Leave()
  if mode == 1 or mode == 2 then fadeTo(rest)
  elseif mode == 3 then set(rest, true) end
end

function Step()
  step = step + 1
  local t = math.min(step / STEPS, 1)
  t = t * t * (3 - 2 * t)
  set(from + (to - from) * t, true)
end
