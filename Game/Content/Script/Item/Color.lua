Color = Color or {}
--- 警告色
Color.WarnColor = {1,0,0,1}

--- 默认颜色
Color.DefaultColor={0.02,0.02,0.03,0.6}
--- DisableColor
Color.DisableColor={0.286,0.286,0.286,0.7}

--- 
Color.AbledColor={0,0,0,1}

Color.White={0.86,0.92,0.98,1.0}
Color.Black={0,0,0,1}

---品质框颜色
Color.tbQuality = {'#4A4A4AFF','#017411FF','#0E1DD6FF', '#5B1BC8FF','#E3620BFF','#DA0612FF'}
Color.tbShadowHex = {
        {['R'] = 1.0,['G'] = 1.0,['B'] = 1.0,['A'] = 1.0},
        {['R'] = 1.0,['G'] = 1.0,['B'] = 1.0,['A'] = 1.0},
        {['R'] = 0.057,['G'] = 0.117,['B'] = 0.839,['A'] = 1.0},
        {['R'] = 0.356,['G'] = 0.107,['B'] = 0.783,['A'] = 1.0},
        {['R'] = 0.887,['G'] = 0.386,['B'] = 0.047,['A'] = 1.0}}

--------------------------------
function Color.Set(pWidget, tbRGB)
    local Color = UE4.UUMGLibrary.GetSlateColor(tbRGB[1], tbRGB[2], tbRGB[3], tbRGB[4])
    pWidget:SetColorAndOpacity(Color)
end

---根据品质设置颜色
---@param pImage UImage
---@param nQuality Integer
function Color.SetQuality(pImage, nQuality)
    if not pImage then return end

    local str = Color.tbQuality[nQuality] or '#4A4A4AFF'
    local Color = UE4.UUMGLibrary.GetSlateColorFromHex(str)
    pImage:SetColorAndOpacity(Color)
end

function Color.SetColorFromHex(pImage,sHex)
    if not pImage then return end
    local Color = UE4.UUMGLibrary.GetSlateColorFromHex(sHex)
    pImage:SetColorAndOpacity(Color)
end


---设置文字颜色
function Color.SetTextColor(pTxt, sColor)
    if not pTxt then return end
    local Color = UE4.UUMGLibrary.GetSlateColorFromHex(sColor)
    pTxt:SetColorAndOpacity(Color)
end