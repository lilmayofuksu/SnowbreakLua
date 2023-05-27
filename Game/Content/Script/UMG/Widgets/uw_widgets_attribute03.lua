-- ========================================================
-- @File    : uw_widgets_attribute03.lua
-- @Brief   : 属性说明文本3号样式
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Display(InParam)
    if InParam.nAdd then
        local nAdd = tonumber(InParam.nAdd) or 0
        if nAdd ~= tonumber(InParam.nNow) then
            WidgetUtils.SelfHitTestInvisible(self.PanelAdd)
            if InParam.IsPercent then
                InParam.nAdd = InParam.nAdd .. "%"
            end
            self.TxtAddNum:SetText(InParam.nAdd)
        else
            WidgetUtils.Collapsed(self.PanelAdd)
        end
    else
        WidgetUtils.Collapsed(self.PanelAdd)
    end

    self.TxtName:SetText(InParam.sName)
    if InParam.IsPercent then
        self.TxtNum:SetText(InParam.nNow.."%")
    else
        self.TxtNum:SetText(InParam.nNow)
    end
    local sPath = Resource.GetAttrPaint(InParam.ECate)

    if self.ImgType then
        SetTexture(self.ImgType,sPath)
    end

    if InParam.bMainAttr then
        local Color = UE4.UUMGLibrary.GetSlateColorFromHex('#4439C2FF')
        self.TxtNum:SetColorAndOpacity(Color)
        WidgetUtils.Collapsed(self.ImgBBg)
    end

    if InParam.bSubAttr then
        local Color = UE4.UUMGLibrary.GetSlateColorFromHex('#3C3D48FF')
        self.TxtNum:SetColorAndOpacity(Color)
        WidgetUtils.SelfHitTestInvisible(self.ImgBBg)
    end
end

---显示武器属性
function tbClass:SetWeaponAttr(nIcon, sName, sNow, sAdd)
    SetTexture(self.ImgType, nIcon)
    self.TxtName:SetText(sName)
    self.TxtNum:SetText(sNow)

    if sNow == sAdd or sAdd == nil then
        WidgetUtils.Collapsed(self.PanelAdd)
    else
        WidgetUtils.HitTestInvisible(self.PanelAdd)
        self.TxtAddNum:SetText(sAdd)
    end
end

function tbClass:OnListItemObjectSet(pObj)
    --- 添加数值显示百分号
    local function GetDataStr(InType,InData,IsPercent)
        local strData = InData
        if InType == "CriticalDamage" or IsPercent then
            strData = strData..'%'
        end
        return strData
    end
    local sPath = nil

    if pObj.Data then
        if pObj.Data.nAdd then
            local nAdd = tonumber(pObj.Data.nAdd) or 0
            if nAdd ~= tonumber(pObj.Data.nNow) then
                WidgetUtils.SelfHitTestInvisible(self.PanelAdd)
                if pObj.Data.ShowAnim then
                    self.TxtAddNum:SetNumAnimation(pObj.Data.nNow or 0, pObj.Data.nAdd, tostring(pObj.Data.nAdd), "{0}")
                else
                    self.TxtAddNum:SetText(GetDataStr(pObj.Data.ECate, pObj.Data.nAdd, pObj.Data.IsPercent))
                end
            else
                WidgetUtils.Collapsed(self.PanelAdd)
            end
        else
            WidgetUtils.Collapsed(self.PanelAdd)
        end

        self.TxtName:SetText(pObj.Data.sName )
        self.TxtNum:SetText(GetDataStr(pObj.Data.ECate,pObj.Data.nNow, pObj.Data.IsPercent))
        sPath = Resource.GetAttrPaint(pObj.Data.ECate)
    end

    if pObj.Logic then
        self.TxtName:SetText(pObj.Logic.sCate)
        self.TxtNum:SetText(GetDataStr(pObj.Logic.sCate,pObj.Logic.nData, pObj.Logic.IsPercent))
        sPath = Resource.GetAttrPaint(pObj.Logic.sECate)

        local nAdd = tonumber(pObj.Logic.nAdd) or 0
        if nAdd > 0 then

            WidgetUtils.SelfHitTestInvisible(self.PanelAdd)
            self.TxtAddNum:SetText(GetDataStr(pObj.Logic.sCate, pObj.Logic.nAdd, pObj.Logic.IsPercent))
        else
            WidgetUtils.Collapsed(self.PanelAdd)
        end
    end

    if pObj.Data.bMainAttr then
        local Color = UE4.UUMGLibrary.GetSlateColorFromHex('#4439C2FF')
        self.TxtNum:SetColorAndOpacity(Color)
        WidgetUtils.Collapsed(self.ImgBBg)
    end

    if pObj.Data.bSubAttr then
        local Color = UE4.UUMGLibrary.GetSlateColorFromHex('#3C3D48FF')
        self.TxtNum:SetColorAndOpacity(Color)
        WidgetUtils.SelfHitTestInvisible(self.ImgBBg)
    end

    -- print('sPath',sPath)
    if self.ImgType then
        SetTexture(self.ImgType,sPath)
    end

    if pObj.Data.CollapseBg then
        WidgetUtils.Collapsed(self.ImgBBg)
    end
end

return tbClass