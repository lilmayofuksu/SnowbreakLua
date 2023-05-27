-- ========================================================
-- @File    : uw_customize_switchtips_choose.lua
-- @Brief   : 
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnDownload, function()
        self:Toggle(true)
        if self.pSelect then
            self.pSelect()
        end
    end)

    BtnAddEvent(self.BtnName, function()
        UI.Open("Edit", 3, nil, function(sTxt, ui)
            PlayerSetting.CoverCustomizeCfgByIndex(self.Index, sTxt)
            self.TxtName:SetText(sTxt)
            UI.Close(ui)
        end)
    end)
end

function tbClass:OnDestruct()

end

function tbClass:OnListItemObjectSet(InObj)
    self:Set(InObj.Data)
end

function tbClass:Set(Data)
    Data.Reset = function()
        self:Toggle(false)
    end
    self:Toggle(Data.bSelect)
    self.pSelect = Data.pSelect
    self.TxtName:SetText(Data.sName)
    self.Index = Data.nIndex
end

function tbClass:Toggle(bSelect)
    if bSelect then
        WidgetUtils.SelfHitTestInvisible(self.ImgSl)
        WidgetUtils.SelfHitTestInvisible(self.TxtUse)
        WidgetUtils.Collapsed(self.BtnDownload)
    else
        WidgetUtils.Collapsed(self.ImgSl)
        WidgetUtils.Collapsed(self.TxtUse)
        WidgetUtils.Visible(self.BtnDownload)
    end
end

return tbClass