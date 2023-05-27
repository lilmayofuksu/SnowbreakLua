-- ========================================================
-- @File    : uw_nerve_sync_message.lua
-- @Brief   : 同步率详情界面
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnUp, function ()
        if self.CurCard and not self.CurCard:IsTrial() then
            RoleCard.ProLevelPromote(self.CurCard:Id(), function()
                if self.NextSkillId then
                    UI.Open("ProLevelTip", self.NextSkillId)
                end
                self:UpdateProLevelPanel()
                if self.FunLevelUp then
                    self.FunLevelUp()
                end
            end)
        end
    end)
end

--- 进入界面接口
function tbClass:Open(pCard, funLevelUp)
    WidgetUtils.SelfHitTestInvisible(self)
    self:StopAnimation(self.AnimClose)
    self:PlayAnimation(self.AllEnter)

    self.CurCard = pCard
    self.FunLevelUp = funLevelUp
    self:UpdateProLevelPanel()
end

function tbClass:UpdateProLevelPanel()
    if not self.CurCard then
        return
    end
    self.NextSkillId = nil

    local proLevel = self.CurCard:ProLevel()
    local key = table.concat({self.CurCard:Genre(), self.CurCard:Detail(), self.CurCard:Particular(), self.CurCard:Level()}, "-")
    local Data = RoleCard.tbProLevelData[key]
    if Data then
        if Data.tbSkillID[proLevel] then
            local SkillId = Data.tbSkillID[proLevel][1]
            local sIcon = UE4.UAbilityLibrary.GetSkillFixInfoStaticId(SkillId)
            SetTexture(self.ImgIcon, sIcon)
            self.TxtName:SetText(SkillName(SkillId))
            self.SkillDes:SetContent(SkillDesc(SkillId))
        end

        if self.CurCard and self.CurCard:IsTrial() then
            WidgetUtils.Collapsed(self.TxtSyncNextAtt)
            WidgetUtils.Collapsed(self.SkillDesNext)
            WidgetUtils.Collapsed(self.PanelUnlock)
            WidgetUtils.Collapsed(self.PanelUp)
            WidgetUtils.Collapsed(self.TxtRoleBreakMax)
        else
            if Data.tbSkillID[proLevel+1] then
                WidgetUtils.Collapsed(self.TxtRoleBreakMax)
                WidgetUtils.HitTestInvisible(self.TxtSyncNextAtt)
                WidgetUtils.HitTestInvisible(self.SkillDesNext)

                self.NextSkillId = Data.tbSkillID[proLevel+1][1]
                self.SkillDesNext:SetContent(SkillDesc(self.NextSkillId))
                self:UpdateCondition(Data.tbCondition[proLevel+1])
            elseif proLevel >= 3 then
                WidgetUtils.Collapsed(self.TxtSyncNextAtt)
                WidgetUtils.Collapsed(self.SkillDesNext)
                WidgetUtils.Collapsed(self.PanelUnlock)
                WidgetUtils.Collapsed(self.PanelUp)
                WidgetUtils.HitTestInvisible(self.TxtRoleBreakMax)
            end
        end
    end
end

function tbClass:UpdateCondition(tbCondition)
    if not tbCondition then return end
    local bAllOk = true
    for i = 1, 3 do
        local TextUnLock = self["TxtSyncUnlock"..i]
        if TextUnLock then
            local con = tbCondition[i]
            if con and #con > 0 then
                WidgetUtils.HitTestInvisible(TextUnLock)
                local bOk, Des = Condition.CheckCondition(con)
                if Des then
                    TextUnLock:SetText(Des)
                end
                if bOk then
                    Color.SetTextColor(TextUnLock, "111125FF")
                else
                    bAllOk = false
                    Color.SetTextColor(TextUnLock, "#DA1009")
                end
            else
                WidgetUtils.Collapsed(TextUnLock)
            end
        end
    end

    if bAllOk then
        WidgetUtils.Collapsed(self.PanelUnlock)
        WidgetUtils.SelfHitTestInvisible(self.PanelUp)
    else
        WidgetUtils.Collapsed(self.PanelUp)
        WidgetUtils.SelfHitTestInvisible(self.PanelUnlock)
    end
end

function tbClass:Close(funFinished)
    self:StopAnimation(self.AllEnter)
    self:BindToAnimationFinished(self.AnimClose, {self, function()
        self:UnbindAllFromAnimationFinished(self.AnimClose)
        if funFinished then
            funFinished()
        end
        WidgetUtils.Collapsed(self)
    end})
    self:PlayAnimation(self.AnimClose)
end

return tbClass
