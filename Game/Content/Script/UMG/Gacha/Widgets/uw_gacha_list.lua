-- ========================================================
-- @File    : uw_gacha_list.lua
-- @Brief   : 蛋池列表
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent( self.BtnSelect, function() self.tbData.OnTouch(self.tbData) end )
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nSelectEvent)
end

function tbClass:OnListItemObjectSet(pObj)
    EventSystem.Remove(self.nSelectEvent)
    self.nSelectEvent = EventSystem.OnTarget( pObj.Data, "SET_SELECTED", function()
            self:SetSelect()
        end
    )
    self.tbData = pObj.Data

    local tbCfg = Gacha.GetCfg(self.tbData.nId)
    if not tbCfg then return end

    if tbCfg:IsNewPool() then
        WidgetUtils.HitTestInvisible(self.TagRookie)
        WidgetUtils.Collapsed(self.TagTime)
    else
        WidgetUtils.Collapsed(self.TagRookie)

        if tbCfg.nTimeBan == 1 then
            WidgetUtils.Collapsed(self.TagTime)
        else
            if tbCfg.tbPoolTime then
                WidgetUtils.HitTestInvisible(self.TagTime)
                local cfgTime = tbCfg.tbPoolTime[2] or 0
                local nDisTime = ParseTime(cfgTime) or 0
                
                if nDisTime > GetTime() then
                    local strTime = ''
                    local nDay, nHour, nMin, nSec = TimeDiff(nDisTime, GetTime())
                    if nDay > 0 then
                        strTime = string.format("%s%s", nDay, Text("ui.TxtTimeDay"))
                    else
                        strTime = string.format("<1%s", Text("ui.TxtTimeDay"))
                    end
                    self.TxtTime:SetText(strTime)
                else
                    WidgetUtils.Collapsed(self.TagTime)
                end
            else
                WidgetUtils.Collapsed(self.TagTime)
            end
        end
    end

    local showName = Text(string.format('gacha.%s_name', tbCfg.sDes))

    self.TxtName:SetText(showName)
    self.TxtCheckName:SetText(showName)
    self:SetSelect()
    AsynSetTexture(self.ImgBG, Resource.Get(tbCfg.nTagUI or 0))
end

function tbClass:SetSelect()
    if self.tbData.bSelect then
        WidgetUtils.Visible(self.Checked)
    else
        WidgetUtils.Collapsed(self.Checked)
    end
end

return tbClass
