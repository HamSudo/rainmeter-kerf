local function num(v) return tonumber(SKIN:ParseFormula(SKIN:ReplaceVariables('#' .. v .. '#'))) or 0 end

function Snap(mode)
  local module = SKIN:GetVariable('CURRENTCONFIG'):match('([^\\]+)$')
  SKIN:Bang('!WriteKeyValue', 'Variables', module .. 'Align', mode, SKIN:GetVariable('@') .. 'Modules.inc')
  SKIN:Bang('!SetVariable', 'AlignMode', mode)
  if mode > 0 then
    local m = num('EdgeMargin') * num('Scale')
    local wx, ww = num('WORKAREAX'), num('WORKAREAWIDTH')
    local cw, cy = num('CURRENTCONFIGWIDTH'), num('CURRENTCONFIGY')
    local x
    if mode == 1 then x = wx + m
    elseif mode == 2 then x = wx + (ww - cw) / 2
    else x = wx + ww - cw - m end
    SKIN:Bang('!Move', math.floor(x + 0.5), cy)
  end
  SKIN:Bang('!UpdateMeasure', 'mAlign')
  SKIN:Bang('!UpdateMeter', '*')
  SKIN:Bang('!Redraw')
end
