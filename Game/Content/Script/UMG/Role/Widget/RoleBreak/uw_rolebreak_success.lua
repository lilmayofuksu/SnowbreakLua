-- ========================================================
-- @File    : uw_rolebreak_success.lua
-- @Brief   : 突破提示弹窗
-- @Author  :
-- @Date    :
-- ========================================================

local tbBreakTip = Class("UMG.BaseWidget")
function tbBreakTip:Construct()
    -- WidgetUtils.Collapsed(self.DesCanvas)
    -- self.Factory = Model.Use(self)
    -- self:BindToAnimationEvent(
    --     self.AllEnter,
    --     {
    --         self,
    --         function()
    --             self:UnbindAllFromAnimationFinished(self.AllEnter)
    --             --- 临时处理挂同一个.lua脚本的情况
    --             WidgetUtils.SelfHitTestInvisible(self.DesCanvas)
    --         end
    --     },
    -- UE4.EWidgetAnimationEvent.Finished)
end

function tbBreakTip:OnOpen(InCard)
    self.pCard = InCard or self.pCard
    self.Factory = Model.Use(self)
    self.timer = UE4.Timer.Add(2.5, function()
        self.Round:ActivateSystem(true)
    end)
    --- 天启徽标
    self.StarIcon:ShowActiveImg(RBreak.GetProcess(InCard))
    local PreSkillId = RBreak.GetBreakSkillId(self.pCard).CurSkillId[1]
     --- 技能说明
    self.Skill:ShowSkillState(0)
    self.Skill:SetSkillName()
     --- 预览属性
    self:PreAttr(self.pCard)
    self.Skill:SetSkillIcon(PreSkillId)

    self:ShowDes(PreSkillId)
    --- 预览Tip
    local tbParam = {
        SkillId = PreSkillId,
        SkillState = RBreak.BreakState.Actived,
        pRole = self.pCard,
        Click = function(InId, InState)
            UI.Close(self)
            if not UI.IsOpen('BreakDetail') then
                UI.Open("BreakDetail",{Card = self.pCard, SkillId = InId, SkillState = RBreak.BreakState.Actived, Idx = RBreak.GetProcess(self.pCard)})
            end
        end,
    }
    self.Skill:OnOpen(tbParam)
end


function tbBreakTip:PreAttr(InCard)
    local tbShowAttr = RBreak.GetAttrs()
    self:DoClearListItems(self.ListAtt)
    for _, nType in ipairs(tbShowAttr) do
        local Cate = UE4.UUMGLibrary.GetEnumValueAsString("EAttributeType", nType)
        local nGetNow = UE4.UItemLibrary.GetCharacterCardAbilityValueToStr(nType, InCard, InCard:EnhanceLevel(), InCard:Quality()-1)
        local nGetNew = UE4.UItemLibrary.GetCharacterCardAbilityValueToStr(nType, InCard, InCard:EnhanceLevel(), InCard:Quality())
        local tbParam = {
            sName = Text(string.format('attribute.%s',Cate)),
            sNow = nGetNow,
            sNew = nGetNew,
            EType = Cate,
        }
        if tonumber(tbParam.sNow) ~= tonumber(tbParam.sNew) then
            local AttrData = self.Factory:Create(tbParam)
            self.ListAtt:AddItem(AttrData)
        end
    end
end

function tbBreakTip:ShowDes(InSkillId)
    self.SkillNameTxt:SetText(SkillName(InSkillId))
    local level = 1
    if RBreak.GetProcess(self.pCard) == 4 then
        local MapLevelFix = UE4.UAbilityComponentBase.K2_GetSkillFixInfoStatic(InSkillId).SkillLevelFixMap
        local Keys = MapLevelFix:Keys()
        if Keys:Length()>0 then
            level = RoleCard.GetSkillLv(nil, Keys:Get(1), self.pCard)
        end
        if self.pCard:Break()/RBreak.NBreakLv < 4 then
            level = level + 1
        end
    end
    self.SkillDesTxt:SetContent(SkillDesc(InSkillId, nil, level))
end

function tbBreakTip:OnClose()
    EventSystem.TriggerTarget(RBreak,RBreak.AbleClick)
    if self.timer then 
        UE4.Timer.Cancel(self.timer)
    end
    -- 
    EventSystem.TriggerTarget(
        Survey,
        Survey.POST_SURVEY_EVENT,
        Survey.RBREAK
    )
end


function tbBreakTip:OnDisable()
    EventSystem.TriggerTarget(RBreak,RBreak.AbleClick)
end
return tbBreakTip