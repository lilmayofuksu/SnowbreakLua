-- ========================================================
-- @File    : uw_rolesbyskill.lua
-- @Brief   : 角色突破被动技能列表
-- @Author  :
-- @Date    :
-- ========================================================

local BreakSkill = Class("UMG.BaseWidget")
BreakSkill.tbAttr = {}
BreakSkill.tbSkill = {}
BreakSkill.CallOnClick = nil

function BreakSkill:Construct()
    self.tbAttr = {self.Attr1, self.Attr2, self.Attr3, self.Attr4, self.Attr5, self.Attr6}
    self.tbSkill = {self.Skill1, self.Skill2, self.Skill3, self.Skill4, self.Skill5}
    self.Factory = Model.Use(self)
    -- self:AttrInit(self.tbAttr, false)
    --- self:UpSkill()

    self.BGBtn.OnClicked:Add(
        self,
        function()
            UI.Close(self)
        end
    )
    self.BtnUp.OnClicked:Add(
        self,
        function()
            --- 关闭突破属性Tip
            -- UI.CloseTopChild()
            --- 突破请求
            self.BreakClick()
        end
    )
end


function BreakSkill:OnOpen(InCard,fBreakClick)
    self.BreakClick = fBreakClick
    self.pCard = InCard or self.pCard
    self.StarIcon:ShowActiveImg(RBreak.GetProcess(InCard)+1,1)
    self.StarIcon:PlayAnimation(self.StarIcon.Into, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    self.Skill:ShowSkillState(1)
    local tbSkillId = RBreak.GetBreakSkillId(self.pCard)
    local ShowSkillId = tbSkillId.PreSkillId[1] or tbSkillId.CurSkillId
    self.Skill:SetSkillIcon(ShowSkillId)

    local tbParam = {
        SkillId = ShowSkillId,
        SkillState = RBreak.BreakState.Actived,
        pRole = self.pCard,
        bPreBreak = true,
        Click = function(InId,InState)
            self.Skill:SetSkillName() 
            UI.Open("BreakDetail",{pRole = self.pCard,SkillId = InId,SkillState = InState})
            -- UI.Open('RoleSkillDetail',{Card = self.pCard,SkillId = InId,SkillState = InState})
        end,
    }
    self.Skill:OnOpen(tbParam)
    self.Skill:SetSkillName()

     --- 预览属性
     self:PreAttr(self.pCard)
    -- self:SetSkillIcon(InId)
    if RBreak.IsLimit(self.pCard) then
        WidgetUtils.Collapsed(self.MatList)
        UI.ShowTip("tip.Limit_Times")
        return
    end
     --- 材料列表
    -- self:GetMaterals(self.pCard)
end

function BreakSkill:PreAttr(InCard)
    local tbShowAttr = RBreak.GetAttrs()
    self:DoClearListItems(self.ListAtt)
    for _, nType in ipairs(tbShowAttr) do
        local Cate = UE4.UUMGLibrary.GetEnumValueAsString("EAttributeType", nType)
        local nGetNow = UE4.UItemLibrary.GetCharacterCardAbilityValueToStr(nType, InCard, InCard:EnhanceLevel(), InCard:Quality())
        local nGetNew = UE4.UItemLibrary.GetCharacterCardAbilityValueToStr(nType, InCard, InCard:EnhanceLevel(), InCard:Quality()+1)
        local tbParam = {
            sName = Text(string.format('attribute.%s',Cate)),
            sNow = nGetNow,
            sNew = nGetNew,
            EType = Cate,
        }
        -- if tonumber(tbParam.sNow) ~= tonumber(tbParam.sNew) then
        --     local AttrData = self.Factory:Create(tbParam)
        --     self.ListAtt:AddItem(AttrData)
        -- end
        local AttrData = self.Factory:Create(tbParam)
        self.ListAtt:AddItem(AttrData)
    end
end

--- 天启突破材料
function BreakSkill:GetMaterals(InItem)
    local  tbMat = RBreak.GetBreakMat(InItem)
    if not tbMat or InItem:Break() >= #tbMat then
        UI.ShowTip("tip.Limit_Times")
        return
    end
    local  tbParam = {
        G = tbMat[1][1],
        D = tbMat[1][2],
        P = tbMat[1][3],
        L = tbMat[1][4],
        N = {nHaveNum = me:GetItemCount(tbMat[1][1],tbMat[1][2],tbMat[1][3],tbMat[1][4]),nNeedNum= tbMat[1][5]},
        PieceId = RBreak.GetRoleSuppliItemPieceId(tbMat[1][1],tbMat[1][2],tbMat[1][3],tbMat[1][4]),
        bDetail = true,
    }
    self.MatList:Display(tbParam)
end

function BreakSkill:OnClose()
    EventSystem.TriggerTarget(RBreak,RBreak.AbleClick)
end

function BreakSkill:OnDestruct()
    EventSystem.Remove(RBreak.OnShowTip)
    for index, value in ipairs(self.tbSkill or {}) do
        EventSystem.Remove(value.OnClick)
    end
end

return BreakSkill
