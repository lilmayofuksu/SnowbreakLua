-- ========================================================
-- @File    : umg_RoleStarUp.lua
-- @Brief   : 养成界面
-- @Author  :
-- @Date    :
-- ========================================================
--- 

local umg_RoleStarUp = Class("UMG.BaseWidget")
local RoleStarUp = umg_RoleStarUp

function RoleStarUp:Construct()
    --角色突破
    self.BreakBtn.OnClicked:Add(
        self,
        function()
            RoleCard.Req_Break(
                RoleCard:GetShowRole(),
                function()
                    self:UpdateRoleBreakCondition()
                    self:UpdateQualityData()
                    self:ShowUpLvTip()
                    print("role card break ok")
                end
            )
        end
    )

    -- self.OnBreakFailHandle = EventSystem.OnTarget(RoleCard, RoleCard.RoleBreakFailTipHandle, function()
    --     print("break fail")
    -- end)
end

function RoleStarUp:OnActive(InRole)
    self.CurCard=InRole or self.CurCard
    RoleCard.SeleCard=self.CurCard
    ---进入角色突破界面，刷新角色数据
    self:UpdateQualityData()
    ---刷新角色突破道具数据
    self:UpdateRoleBreakCondition()
end

function RoleStarUp:OnOpen(...)
    PreviewScene.Enter(PreviewType.role_lvup)
end

function RoleStarUp:OnClose()
    self:Clear()
end

function RoleStarUp.Clear()
    --body
end

---@param InIndex number 属性index
---@return Tname string 属性名
function RoleStarUp:SetTexPropertyName(InIndex)
    self.Tname = "Expert"
    if InIndex == 1 then
        self.Tname = Text("ui.health")
    elseif InIndex == 2 then
        self.Tname = Text("ui.attack")
    elseif InIndex == 3 then
        self.Tname = Text("ui.def")
    elseif InIndex == 4 then
        self.Tname = Text("ui.shield")
    end
    return self.Tname
end

---@param Index number 角色卡属性Index
---@return CurVal number 当前角色拥有属性值
---@return QualityVal number  角色突破当前品质的上限值
function RoleStarUp:UpdateRoleCarddata(Index)
    self.CurVal = 0
    self.QualityVal = 0
    if Index == 1 then
        self.CurVal = self.CurCard:Health()
        self.QualityVal = self.CurCard:Health(0, self:GetCardQuality() + 1)
    elseif Index == 2 then
        self.CurVal = self.CurCard:Attack()
        self.QualityVal = self.CurCard:Attack(0, self:GetCardQuality() + 1)
    elseif Index == 3 then
        self.CurVal = self.CurCard:Shield()
        self.QualityVal = self.CurCard:Shield(0, self:GetCardQuality() + 1)
    elseif Index == 3 then
        self.CurVal = self.CurCard:Defence()
        self.QualityVal = self.CurCard:Defence(0, self:GetCardQuality() + 1)
    end
    return self.CurVal, self.QualityVal
end
---@return IQual number角色卡的品质
function RoleStarUp:GetCardQuality()
    self.nQual = self.CurCard:Quality()
    return self.nQual
end

---@param InQual number 当前品质级别
function RoleStarUp:UpdateRoleQulity(InQual)
    if InQual == 1 then
        self.effectiveness:SetText(Text("ui.role_break_b"))
    elseif InQual == 2 then
        self.effectiveness:SetText(Text("ui.role_break_a"))
    elseif InQual == 3 then
        self.effectiveness:SetText(Text("ui.role_break_s"))
    elseif InQual == 4 then
        self.effectiveness:SetText(Text("ui.role_break_ss"))
    elseif InQual == 5 then
        self.effectiveness:SetText(Text("ui.role_break_sss"))
    end
end

---品质突破道具数据接入
function RoleStarUp:UpdateRoleBreakCondition()
    local AExpItem = LoadClass("/Game/UI/UMG/Role/Widgets/uw_Breach_prop_data")
    ---可提供角色突破道具g,d,p,l,n
    self.BreakItems = Item.GetBreakMaterials(self.CurCard)
    if not self.BreakItems then
        return
    end
    ---突破需要的数量
    self:DoClearListItems(self.ATitleView)
    for i = 1, #self.BreakItems do
        self.pItem = self.BreakItems[i]
        self.nBreakItem = me:GetItemCount(self.pItem[1], self.pItem[2], self.pItem[3], self.pItem[4])
        self.nNeedItem = self.pItem[5]
        self.NewExpInfo = NewObject(AExpItem, self, nil)
        self.NewExpInfo.HaveNum = self.nBreakItem
        self.NewExpInfo.NeedNum = "/" .. self.nNeedItem
        self.ATitleView:AddItem(self.NewExpInfo)
    end
end

---show 提示界面
---@param IsSuc boolean 升级/突破成功(服务器返回成功消息)
function RoleStarUp:ShowUpLvTip()
    if #RoleCard.CheckAttrChange(2) == 0 then
        UI.ShowTip("ui.up lv ok")
        return
    end
    self.CurCard = RoleCard:GetShowRole()
    self.BreakItems = Item.GetBreakMaterials(self.CurCard)
    ---第几次突破需要的道具g,d,p,l,n 超过突破次数的提示需要对接
    if not self.BreakItems then
        UI.ShowTip("tip.break num by limit...")
        print("break num limit")
        return
    end
    UI.Open("RoleLvTip", self.CurCard,100, {}, function()  end)
end

---初始化角色品质属性数据
function RoleStarUp:UpdateQualityData()
    local ExpertItem = LoadClass("/Game/UI/UMG/Role/Widgets/uw_Role_StarUp_list_data")
    self:UpdateRoleQulity(self:GetCardQuality())
    self:DoClearListItems(self.ExpertView)
    for i = 1, 4 do
        self.NewExpertInfo = NewObject(ExpertItem, self, nil)
        local CurQual, NextQual = self:UpdateRoleCarddata(i)
        self.NewExpertInfo.Name = self:SetTexPropertyName(i)
        self.NewExpertInfo.CurNum = CurQual
        if NextQual == 0 then
            self.NewExpertInfo.SumNum = " "
        else
            self.NewExpertInfo.SumNum = "(" .. NextQual .. ")"
        end
        self.ExpertView:AddItem(self.NewExpertInfo)
    end
end

return RoleStarUp
