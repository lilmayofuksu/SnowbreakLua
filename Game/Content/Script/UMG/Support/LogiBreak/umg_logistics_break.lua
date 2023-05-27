-- ========================================================
-- @File    : umg_logistics_break.lua
-- @Brief   : 角色突破
-- @Author  :
-- @Date    :
-- ========================================================

local umg_logistics_break = Class("UMG.BaseWidget")
local LogiBreak = umg_logistics_break
LogiBreak.AttrPath = "UMG.LogiUp.Widget.uw_logis_break_Item_data"
LogiBreak.SkillPath = "UMG.LogiSkill.Widget.uw_skill_des_data"
LogiBreak.StarPath = "UMG.Support.LogisticsShow.Widgets.uw_Logistics_star_data"

function LogiBreak:Construct()
    self.BtnClick:SetText(Text("ui.break"))
    self.AttrItem = Model.Use(self, self.AttrPath)
    self.SkillDesItem = Model.Use(self, self.SkillPath)
    self.pSatrItem = Model.Use(self, self.StarPath)
    self.BreakBtn.OnClicked:Add(
        self,
        function()
            self:OnClicked()
        end
    )

    -- 限制突破进化次数
    self.OnEvolLimit =
        EventSystem.OnTarget(
        Logistics,
        Logistics.OnLimitEvol,
        function(OnTarget, InNum)
            WidgetUtils.Hidden(self.qualityNew)
            WidgetUtils.Hidden(self.TxtNewLv)
            WidgetUtils.Hidden(self.ImgArrow)
            --self:UpDataCostList(self.pLogisCard)
            self:ShowStarList(self.pLogisCard)
            self:SkillLv(self.pLogisCard)
        end
    )
end

function LogiBreak:OnOpen(InData)
    if not InData then
        print("not logiscard")
        return
    end
    self.pLogisCard = InData
    UI.CloseByName("LogiUp", nil, true)
    --- 消耗列表
    self:UpDataCostList(InData)
    -- self:BreakAttrList()
    --- 品质列表
    self:ShowStarList(self.pLogisCard)
    self:SkillDesList(InData)
    self:SkillLv(InData)
    self:SetGoldTxt(Logistics.GetCostGold(self.pLogisCard), Cash.GetMoneyCount(Cash.MoneyType_Silver))

    --- Icon 设定
    local ResId=self.pLogisCard:Icon()
    local ResBreakId=self.pLogisCard:IconBreak()
    if Logistics.CheckUnlockBreakImg(self.pLogisCard) then
        local IconId = ResBreakId
        SetTexture(self.BGIcon,IconId,true)
    else
        local IconId = ResId
        SetTexture(self.BGIcon,IconId,true)
    end 
end

--- 突破
function LogiBreak:OnClicked()
    local CanBreak, Des = Item.CanBreak(self.pLogisCard)
    if not CanBreak then
        UI.ShowTip(Des or "tip.BadParam")
        self:SetGoldTxt(0, Cash.GetMoneyCount(Cash.MoneyType_Silver))
        return
    end

    Logistics.Req_BreakLogistics(
        self.pLogisCard,
        function()
            self:UpDataCostList(self.pLogisCard)
            self:ShowStarList(self.pLogisCard)
            UI.ShowTip("tip.logistic break ok")
            -- self:BreakAttrList()
            self:SetGoldTxt(Logistics.GetCostGold(self.pLogisCard), Cash.GetMoneyCount(Cash.MoneyType_Silver))
            -- local tbbreakMat = Item.GetBreakMaterials(self.pLogisCard)
            -- if tbbreakMat then
            --     UI.CloseByName("LogiBreak", nil, true)
            --     UI.Open("LogiUp", self.pLogisCard)
            -- end
            UI.CloseByName("LogiBreak", nil, true)
            UI.Open("LogiUp", self.pLogisCard)
        end
    )
end

--- 属性列表
function LogiBreak:BreakAttrList()
    local tbChange = Logistics.GetAttrListChange(nil,self.pLogisCard, 2)
    self:DoClearListItems(self.AttrView)
    for k, v in pairs(tbChange) do
        local tbParam = {}
        local NewItem = self.AttrItem:Create(tbParam)
        NewItem.Logic:OnInit(
            {
                Name = v.Name,
                ECate = v.EName,
                New = math.ceil(v.New),
                Now = math.ceil(v.Now)
            }
        )
        self.AttrView:AddItem(NewItem)
    end
end

--- ---突破消耗列表
---@param InCard UE4.UItem 要突破的后勤卡
function LogiBreak:UpDataCostList(InCard)
    if not InCard then
        print("not equip logistic")
        return
    end
    local tbCost = Item.GetBreakMaterials(InCard)
    if not tbCost then
        EventSystem.TriggerTarget(Logistics, Logistics.OnLimitEvol)
        UI.ShowTip("tip.Logistic break limit")
        tbCost=Item.GetBreakMaterials(InCard)
    end

end

function LogiBreak:SetLogiQualTxt()
    self.TxtQualDes:SetText(Text("ui.quality"))
end

function LogiBreak:SetGoldTxt(InCost, InSum)
    Color.Set(self.TxtCost,Color.DefaultColor)
    self.TxtCost:SetText(InCost)
    self.TxtSum:SetText("/" .. InSum)
    if InCost > InSum then
        Color.Set(self.TxtCost,Color.WarnColor)
    end
end

function LogiBreak:SkillDesList(InItem)
    local tbCurSkills = UE4.TArray(UE4.int32)
    InItem:GetSkills(0, tbCurSkills)
    if tbCurSkills:Length()>0 then
        self:DoClearListItems(self.ListDes)
        for i = 1, 2 do
            local tbParam = {}
            local CurItemDes = self.SkillDesItem:Create(tbParam)
            CurItemDes.Logic:OnInit(
                {
                    SupportCard = InItem,
                    SkillId = tbCurSkills:Get(1),
                    SkillLv = i
                }
            )
            self.ListDes:AddItem(CurItemDes)
        end
    else
        print('Skill Id error',string.format("%d-%d-%d-%d",InItem:Genre(),InItem:Detail(),InItem:Particular(),InItem:Level()))
        return
    end
end

--- 品质展示
function LogiBreak:ShowStarList(InItem)
    self:DoClearListItems(self.QualList)
    for i = 1, InItem:Break() + 1 do
        local tbParam = {}
        local NewItem = self.pSatrItem:Create(tbParam)
        self.QualList:AddItem(NewItem)
    end
end

--- 技能等级
function LogiBreak:SkillLv(InItem)
    self.TxtNowLv:SetText(InItem:Break() + 1)
    self.TxtNewLv:SetText(InItem:Break() + 2)
end

function LogiBreak:OnClose()
    EventSystem.Remove(self.OnEvolLimit)
end

return LogiBreak
