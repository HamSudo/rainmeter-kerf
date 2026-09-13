-- The media card's moving parts: the track's text, how far through it is,
-- and the angle of the disc. KerfSensors writes the session to the registry
-- once a second; everything here is read from those measures.

local SPIN = 30          -- degrees a second, a turn slow enough to read
local STALE = 15         -- seconds before a silent helper is treated as stopped

local function num(v) return tonumber(SKIN:ParseFormula(SKIN:ReplaceVariables(v))) or 0 end

local function str(m) return m and m:GetStringValue() or '' end
local function val(m) return tonumber(str(m)) or 0 end

local function clock(s)
  if s < 0 or s ~= s then s = 0 end
  local m, sec = math.floor(s / 60), math.floor(s % 60)
  if m >= 60 then return string.format('%d:%02d:%02d', math.floor(m / 60), m % 60, sec) end
  return string.format('%d:%02d', m, sec)
end

function Initialize()
  title, artist = SKIN:GetMeasure('mTitle'), SKIN:GetMeasure('mArtist')
  status, posM, lenM, atM = SKIN:GetMeasure('mStatus'), SKIN:GetMeasure('mPos'), SKIN:GetMeasure('mLen'), SKIN:GetMeasure('mPosAt')
  artM, discM = SKIN:GetMeasure('mArt'), SKIN:GetMeasure('mDisc')
  cardH = SKIN:GetMeasure('mCardH')
  idle = SELF:GetOption('Idle', 'Nothing playing')
  spin, rate, last = 0, 0, os.clock()
  shown = {}
end

-- meters are only touched when what they say actually changes
local function set(meter, option, value)
  local k = meter .. '.' .. option
  if shown[k] == value then return false end
  shown[k] = value
  SKIN:Bang('!SetOption', meter, option, value)
  return true
end

local function variable(name, value)
  if shown[name] == value then return false end
  shown[name] = value
  SKIN:Bang('!SetVariable', name, value)
  return true
end

-- Rainmeter fits a rotated image into the meter's box, and a turning square's
-- box swells to sqrt(2) and back on every quarter turn -- left alone that
-- pumps the disc in and out. Growing the box by exactly that factor cancels
-- it, so the cover keeps one diameter and only spins.
local function turn(angle)
  local side = cardH and cardH:GetValue() or 0
  if side <= 0 then return end
  local r = math.rad(angle)
  local box = side * (math.abs(math.cos(r)) + math.abs(math.sin(r)))
  local off = (side - box) / 2
  SKIN:Bang('!SetOption', 'MeterDisc', 'W', string.format('%.0f', box))
  SKIN:Bang('!SetOption', 'MeterDisc', 'H', string.format('%.0f', box))
  SKIN:Bang('!SetOption', 'MeterDisc', 'X', string.format('%.0f', off))
  SKIN:Bang('!SetOption', 'MeterDisc', 'Y', string.format('%.0f', off))
  SKIN:Bang('!SetOption', 'MeterDisc', 'ImageRotate', string.format('%.2f', angle))
end

function Update()
  local now = os.clock()
  local dt = math.min(0.25, math.max(0, now - last))
  last = now

  local st = val(status)
  -- a helper that has stopped writing must not leave a track frozen on screen
  local at = val(atM)
  if at > 0 and os.time() - at > STALE then st = 0 end

  local name = str(title)
  if name == '' then st = 0 end

  local pos, len = val(posM), val(lenM)
  if len > 0 and pos > len then pos = len end

  local dirty = false
  if st == 0 then
    dirty = set('MeterTitle', 'Text', idle) or dirty
    dirty = set('MeterArtist', 'Text', '') or dirty
    dirty = set('MeterTime', 'Text', '') or dirty
    dirty = variable('Prog', '0') or dirty
  else
    dirty = set('MeterTitle', 'Text', name) or dirty
    dirty = set('MeterArtist', 'Text', str(artist)) or dirty
    -- a live stream has no end, so it gets the elapsed time on its own
    dirty = set('MeterTime', 'Text', len > 0 and (clock(pos) .. ' / ' .. clock(len)) or clock(pos)) or dirty
    dirty = variable('Prog', string.format('%.4f', len > 0 and math.min(1, pos / len) or 0)) or dirty
  end

  local art = str(artM)
  local disc = str(discM)
  local wanted = num('#Disc#') == 1 and disc or art
  dirty = variable('HasArt', wanted ~= '' and '1' or '0') or dirty
  if art ~= '' then dirty = set('MeterArt', 'ImageName', art) or dirty end
  if disc ~= '' then dirty = set('MeterDisc', 'ImageName', disc) or dirty end

  -- the disc eases up to speed and coasts down again rather than snapping
  local target = st == 1 and SPIN or 0
  rate = rate + (target - rate) * (1 - 0.97 ^ (dt * 60))
  if num('#Disc#') == 1 and rate > 0.05 then
    spin = (spin + rate * dt) % 360
    turn(spin)
    dirty = true
  end

  if dirty then
    SKIN:Bang('!UpdateMeter', '*')
    SKIN:Bang('!Redraw')
  end
  return st
end
