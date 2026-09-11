local function num(v) return tonumber(SKIN:ParseFormula(SKIN:ReplaceVariables('#' .. v .. '#'))) or 0 end

function Snap(mode)
  local module = SKIN:GetVariable('CURRENTCONFIG'):match('([^\\]+)$')
  SKIN:Bang('!WriteKeyValue', 'Variables', module .. 'Align', mode, SKIN:GetVariable('@') .. 'Modules.inc')
  SKIN:Bang('!SetVariable', 'AlignMode', mode)
  if mode > 0 then
    local m = num('EdgeMargin') * num('Scale')
    local wx, wy, ww, wh = num('WORKAREAX'), num('WORKAREAY'), num('WORKAREAWIDTH'), num('WORKAREAHEIGHT')
    local cx, cy = num('CURRENTCONFIGX'), num('CURRENTCONFIGY')
    local cw, ch = num('CURRENTCONFIGWIDTH'), num('CURRENTCONFIGHEIGHT')
    local x, y = cx, cy
    if mode == 1 then x = wx + m
    elseif mode == 2 then x = wx + (ww - cw) / 2
    elseif mode == 3 then x = wx + ww - cw - m end
    SKIN:Bang('!Move', math.floor(x + 0.5), math.floor(y + 0.5))
  end
  SKIN:Bang('!UpdateMeasure', 'mAlign')
  SKIN:Bang('!UpdateMeter', '*')
  SKIN:Bang('!Redraw')
end
