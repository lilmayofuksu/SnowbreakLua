-- ========================================================
-- @File    : uw_dungeons_resourse_suppport.lua
-- @Brief   : 后勤日常本套装选择框
-- ========================================================
local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnSwitch, function()
        if self.OnClick then
            self.OnClick(self)
        end    
    end)

    self.tbLogis = {self.Logis1, self.Logis2, self.Logis3}
end

function tbClass:Display(InSuitId, InCallback)
    self.SuitId = InSuitId
    self:InitSuitPanel()
    self.OnClick = function()
        UI.Open("DungeonsSupportGroup", self.SuitId, InCallback)
    end
end

function tbClass:InitSuitPanel(InSuitId)
    self.SuitId = InSuitId or self.SuitId
    if not self.SuitId then
        return
    end
    local tbSuit = Logistics.tbAllLogiSuit[self.SuitId]
    if not tbSuit then
        return
    end

    local tbSkill = Logistics.tbSkillSuitID[tbSuit[1].SuitSkillID]
    if tbSkill and tbSkill.TwoSkillID and #tbSkill.TwoSkillID > 0 then
        self.TxtName:SetText(SkillName(tbSkill.TwoSkillID[1]))
    end

    for i = 1, 3 do
        local LogiCardTemplate = tbSuit[i]
        if LogiCardTemplate then
            self.tbLogis[i]:ShowLogiTemplate(LogiCardTemplate)
        end
    end
end

function tbClass:OnListItemObjectSet(InParam)
    self.Data = InParam.Data
    self.OnClick = InParam.Data.OnClick
    local tbSkill = Logistics.tbSkillSuitID[self.Data.tbSuit[1].SuitSkillID]
    if #tbSkill.TwoSkillID > 0 then
        self.TxtName:SetText(SkillName(tbSkill.TwoSkillID[1]))
    end

    if self.Data.bInitSelect and not self.Data.GetIsDirty() and self.OnClick then
        self:OnClick(self)
    end

    if self.Data.bSelect then
        WidgetUtils.SelfHitTestInvisible(self.Selected)
    else
        WidgetUtils.Collapsed(self.Selected)
    end
    for i = 1, 3 do
        local LogiCardTemplate = self.Data.tbSuit[i]
        if LogiCardTemplate then
            self.tbLogis[i]:ShowLogiTemplate(LogiCardTemplate)
        end
    end
end

function tbClass:SetSelect(Selected)
    if Selected then
        self.Data.bSelect = true
        WidgetUtils.SelfHitTestInvisible(self.Selected)
    else
        self.Data.bSelect = false
        WidgetUtils.Collapsed(self.Selected)
    end
end

return tbClass