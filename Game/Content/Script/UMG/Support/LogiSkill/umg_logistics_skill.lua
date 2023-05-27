-- ========================================================
-- @File    : umg_logistics_skill.lua
-- @Brief   : 角色技能进化

-- @Author  :
-- @Date    :
-- ========================================================

local umg_logistics_skill = Class("UMG.BaseWidget")
local LogiSkill = umg_logistics_skill
LogiSkill.SkillPath='UMG.LogiSkill.Widget.uw_skill_des_data'
LogiSkill.OnEvolLimit=nil

function LogiSkill:Construct()
    self.SkillDesItem=Model.Use(self,self.SkillPath)
    self.BreakBtn.OnClicked:Add(
        self,
        function()
            self:OnBreakClick()
        end
    )

    self.OnEvolLimit=
    EventSystem.OnTarget(
        Logistics,
        Logistics.OnLimitEvol,
        function(OnTarget,InNum)
            WidgetUtils.Hidden(self.TxtNowLevel)
            self:SetLv(InNum-1)
        end

    )
end

function LogiSkill:OnOpen(InData)
    if InData then
        self.pCard = InData
    else
        --- 非正常进入当前界面，显示数据需要从数据管理器中取。。。。
        self.pCard = Logistics.GetLogisticsSlot(Logistics.SelectType)
    end
    self:GetDefaultSkillInfo(self.pCard)
    local Id, Lv = self:GetSkills(self.pCard)
    self:GetSkillEvolMats(self.pCard, Lv)
    self:SkillDesList(self.pCard)
end

--- 获取技能Id 和Lv
function LogiSkill:GetSkills(pItem)
    local Id = Logistics.GetSkillID(pItem)
    local Evolue = pItem:Evolue()+1
    return Id, Evolue
end

--- 获取后勤技能等级信息
---@param pItem  UE4.UItem 后勤卡
function LogiSkill:GetDefaultSkillInfo(pItem)
    local Id, Lv = self:GetSkills(pItem)
    self:SetLv(Lv)
    if not Id then
       return
    end
    self:SetSkillDes(SkillDesc(Id))
end

--- 技能进化花费材料
---@param pItem  UE4.UItem 后勤卡
---@param InNum integer 升级次数
function LogiSkill:GetSkillEvolMats(pItem, InNum)
    local Id, nEvolue = self:GetSkills(pItem)
    local tbSkillMat = Logistics.GetSkillEvolutMats(pItem, InNum)
    if not tbSkillMat then
        -- 进化到限制等级，不再需要展示突破材料需要的数据。
        local  tbMat =Logistics.GetSkillEvolutMats(pItem, InNum-1)
        for k, v in pairs(tbMat) do
            local nHave = me:GetItemCount(tbMat[k][1], tbMat[k][2], tbMat[k][3], tbMat[k][4])
            self:SetTextMatNum(nHave)
        end
        EventSystem.TriggerTarget(Logistics,Logistics.OnLimitEvol,InNum)
        return
    end
    for k, v in pairs(tbSkillMat) do
            local nHave = me:GetItemCount(tbSkillMat[k][1], tbSkillMat[k][2], tbSkillMat[k][3], tbSkillMat[k][4])
            self:SetTextMatNum(nHave, tbSkillMat[k][5])
    end
end

function LogiSkill:OnBreakClick()
    Logistics.Req_Evolut(
        self.pCard,
        function()
            UI.ShowTip("LogiSkill_Evol_Ok")
            self:GetDefaultSkillInfo(self.pCard)
            local Id, Lv = self:GetSkills(self.pCard)
            self:GetSkillEvolMats(self.pCard, Lv)
            print("LogiSkill up ok")
        end
    )
end

function LogiSkill:SkillDesList(InItem)
    local tbSkills = UE4.TArray(UE4.int32)
    InItem:GetSkills(0,tbSkills)
    self:DoClearListItems(self.ListDes)
    for i = 1, tbSkills:Length() do
        local tbParam = {}
        local  ItemDes = self.SkillDesItem:Create(tbParam)
        ItemDes.Logic:OnInit(
            {
                SkillId = tbSkills:Get(i)
            }
        )
        self.ListDes:AddItem(ItemDes)
    end

end

function LogiSkill:SetLv(InLv)
    self.TxtNowLevel:SetText(InLv)
    self.TxtNewLevel:SetText(InLv + 1)
end

function LogiSkill:SetSkillDes(InDes)
    --- self.RichDes:SetText(InDes)
end

function LogiSkill:SetTextMatNum(nNow, nNeed)
    self.TxtHave:SetText(nNow)
    if nNeed then
        self.TxtNeed:SetText("/" .. nNeed)
    else
        self.TxtNeed:SetText("")
    end
end
return LogiSkill
