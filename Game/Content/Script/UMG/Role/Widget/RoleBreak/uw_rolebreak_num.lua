-- ========================================================
-- @File    : uw_rolebreak_tips.lua
-- @Brief   : 突破提示属性
-- @Author  :
-- @Date    :
-- ========================================================

local AttrData=Class("UMG.SubWidget")
function  AttrData:Construct()
    --- body()
end

function AttrData:OnListItemObjectSet(InObj)
    if InObj == nil then
        return
    end
    local Item =InObj.Data
    
    self:UpDateAttrInfo(Item)
    self:ShowAttrIcon(Item.EType)
end

--- 属性展示
---@param tbInfo table 需要展示的属性信息
function AttrData:UpDateAttrInfo(tbInfo)
    if tbInfo then
        WidgetUtils.Visible(self.ImgArrow)
        WidgetUtils.Visible(self.TxtNum)
        WidgetUtils.Visible(self.TxtAddNum)
        self.TxtName:SetText(tbInfo.sName)
        self.TxtNum:SetText(tbInfo.sNow)
        self.TxtAddNum:SetText(tbInfo.sNew)

        if tbInfo.EType == 'CriticalValue' then
            self.TxtNum:SetText(TackleDecimalUnit(tbInfo.sNow,'%',1)) 
            self.TxtAddNum:SetText(TackleDecimalUnit(tbInfo.sNew,'%',1))
        end
       
        if tbInfo.EType == 'CriticalDamage' then
            self.TxtNum:SetText(TackleDecimalUnit(tbInfo.sNow,'%')) 
            self.TxtAddNum:SetText(TackleDecimalUnit(tbInfo.sNew,'%'))
        end

        if (tbInfo.sNew==0) or (not tbInfo.sNew) then
            WidgetUtils.Hidden(self.ImgArrow)
            WidgetUtils.Hidden(self.TxtAddNum)
            return
        end
    end
end

function AttrData:ShowAttrIcon(InType)
    local sPath = Resource.GetAttrPaint(InType)
    SetTexture(self.ImgType,sPath)
end


return AttrData