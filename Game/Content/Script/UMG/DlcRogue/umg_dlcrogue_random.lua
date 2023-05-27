-- ========================================================
-- @File    : umg_dlcrogue_random.lua
-- @Brief   : 小肉鸽活动事件节点界面
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(self.BtnOK, function ()
        if not self.NodeInfo or not self.nSelectIndex then
            return
        end
        if self.NodeInfo.nNode==2 and self.SelectEffectInfo then
            if self.SelectEffectInfo[1]==6 then
                --进入关卡
                local cfg = RogueLevel.Get(self.SelectEffectInfo[2])
                if cfg then
                    RogueLevel.SetNodeInfo(self.NodeInfo)
                    RogueLevel.SetLevelID(self.SelectEffectInfo[2])
                    UI.Open("Formation", nil, nil, cfg)
                else
                    print(string.format("umg_dlcrogue_random_error:关卡Id配置错误，节点ID:%d，请检查配置", self.NodeInfo.nID))
                end
                return
            elseif self.SelectEffectInfo[1]==2 then
                --回复生命消耗代币
                if not self.SelectEffectInfo[2] or Cash.GetMoneyCount(RogueLogic.MoneyId) < self.SelectEffectInfo[2] then
                    UI.ShowMessage(Text("rogue.TxtMoneyWarn"))
                    return
                end
            end
        end
        local tbData = {nID = self.NodeInfo.nID, nType = self.NodeInfo.nNode, nSelectIndex = self.nSelectIndex}
        RogueLogic.FinishNode(tbData, function ()
            if self.ShowTipStr and self.ShowTipStr[self.nSelectIndex] then
                UI.ShowMessage(self.ShowTipStr[self.nSelectIndex])
            end
            UI.Close(self)
        end)
    end)
end

function tbClass:OnOpen(tbInfo)
    self.Title:SetCustomEvent(UI.CloseTopChild)
    self.Money:Init({RogueLogic.MoneyId})

    if not tbInfo then
        return
    end
    self.NodeInfo = tbInfo
    ---1=战斗节点，2=事件节点，3=商店节点，4=休息点
    if tbInfo.nNode ~= 2 and tbInfo.nNode ~= 4 then
        return
    end

    self:UpdateRandomPanel(tbInfo)
    self:UpdateRolePanel()
end

function tbClass:UpdateRandomPanel(tbInfo)
    local tbData = {}
    local sTitle = ""
    self.ShowTipStr = {}
    if tbInfo.nNode == 2 then
        local RandomInfo = RogueLogic.tbRandomCfg[tbInfo.nRandomID]
        sTitle = RandomInfo.sTitle
        for i = 1, CountTB(RandomInfo.tbOptions) do
            local node = RandomInfo.tbEffect[i] or {}
            if #node>=2 and node[1] == 4 then   --获得buff
                local cfg = RogueLogic.tbBuffCfg[node[2]]
                if cfg then
                    if cfg.sName then
                        node[2] = Text(cfg.sName)
                    end
                    if cfg.sDesc then
                        node[3] = Text(cfg.sDesc, table.unpack(cfg.tbBuffParamPerCount or {}))
                    end
                end
            elseif #node>=3 and node[1] == 7 then   --消耗代币获得buff
                local cfg = RogueLogic.tbBuffCfg[node[3]]
                if cfg then
                    if cfg.sName then
                        node[3] = Text(cfg.sName)
                    end
                    if cfg.sDesc then
                        node[4] = Text(cfg.sDesc, table.unpack(cfg.tbBuffParamPerCount or {}))
                    end
                end
            end
            local str = Text(RandomInfo.tbOptions[i])
            local tipstr = "nil"

            if RandomInfo.tbTips[i] then
                if #node==2 then
                    tipstr = Text(RandomInfo.tbTips[i], node[2])
                elseif #node==3 then
                    tipstr = Text(RandomInfo.tbTips[i], node[2], node[3])
                elseif #node==4 then
                    tipstr = Text(RandomInfo.tbTips[i], node[2], node[3], node[4])
                else
                    tipstr = Text(RandomInfo.tbTips[i])
                end
            end
            self.ShowTipStr[i] = tipstr
            tbData[i] = {Des = str, Node = node, Effect = RandomInfo.tbEffect[i]}
        end
    else
        sTitle = tbInfo.sRestDesc
        for i, v in ipairs(tbInfo.tbRestOption) do
            local des = ""
            if v[1] == 1 then
                des = Text("rogue.TxtRestDesc1", v[2])
            elseif v[1] == 2 then
                des = Text("rogue.TxtRestDesc3", v[2])
            elseif v[1] == 3 then
                des = Text("rogue.TxtRestDesc2", v[2])
            end
            tbData[i] = {Des = des, Node = v, Effect = v}
        end
    end

    self.TxtTitle:SetText(Text(sTitle))
    for i = 1, 3 do
        if self["Random"..i] then
            if tbData[i] then
                if not self.nSelectIndex then
                    self.nSelectIndex = i
                    self.SelectEffectInfo = tbData[i].Effect
                end
                WidgetUtils.SelfHitTestInvisible(self["Random"..i])
                self["Random"..i]:Show(tbData[i], function ()
                    if self.nSelectIndex == i then
                        return
                    end
                    if self.nSelectIndex and self["Random"..self.nSelectIndex] then
                        self["Random"..self.nSelectIndex]:SetSelect(false)
                    end
                    self.nSelectIndex = i
                    self.SelectEffectInfo = tbData[i].Effect
                    self["Random"..i]:SetSelect(true)
                end)
                self["Random"..i]:SetSelect(self.nSelectIndex == i)
            else
                WidgetUtils.Collapsed(self["Random"..i])
            end
        end
    end
end

function tbClass:UpdateRolePanel()
    local tbCard = RogueLogic.GetRogueLineup(true)
    for i = 1, 3 do
        if self["Role"..i] then
            if tbCard[i] then
                WidgetUtils.SelfHitTestInvisible(self["Role"..i])
                local card = tbCard[i]
                local ID = card:Id()
                local TemplateId = card:TemplateId()
                local pCardItem = LoadClass("/Game/UI/UMG/Role/Widgets/uw_role_role_data.uw_role_role_data")
                local obj = NewObject(pCardItem, self, nil)
                local template = UE4.UItem.FindTemplateForID(TemplateId)
                obj:Init(ID, false, template, function() UI.Open("Role", 1, card, RogueLogic.GetAllCharacter(), true) end, card)
                obj.nTemplateId = TemplateId
                obj.ShowHP = true
                self["Role"..i]:Display(obj)
            else
                WidgetUtils.Collapsed(self["Role"..i])
            end
        end
    end
end

function tbClass:OnClose()
    for i = 1, 3 do
        if self["Random"..i] then
            self["Random"..i]:Close()
        end
    end
    local uiRogue = UI.GetUI("DlcRogue")
    if uiRogue and uiRogue:IsOpen() then
        uiRogue:UpdatePanel()
    end
end

return tbClass
