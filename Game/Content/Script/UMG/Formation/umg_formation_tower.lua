-- ========================================================
-- @File    : umg_formation_tower.lua
-- @Brief   : 爬塔编队阵容界面
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    -- 排序
    self.tbRoleSortInfo =
    {
        tbSort = {
            sDesc = 'ui.TxtScreen1',
            tbRule={
                {'ui.item_level', ItemSort.TemplateLevelSort},
                {'ui.TxtRareSort', ItemSort.TemplateRareSort},
                {'ui.TxtRolePower', ItemSort.TemplateCombatSort},
                {'ui.TxtScreen2', ItemSort.TemplateIdSort},
                --信赖度暂时隐藏{'ui.TxtDormPresentLove', {1}},
                {'ui.TxtBreakSort', ItemSort.TemplateBreakSort},
                {'ui.TxtScreen16', ItemSort.TemplateAttackSort},
                {'ui.TxtDefenceSort', ItemSort.TemplateDefenceSort},
                {'ui.health', ItemSort.TemplateHealthSort},
                {'ui.roleup_skill', ItemSort.TemplateSpineSort},
            }
        },

        --{sDesc:标题文字，rule:筛选类型, tbRule:筛选子项 }
        tbFilter = {
            {
                sDesc='ui.TxtScreen3',
                rule=10,
                tbRule={
                    {'weapon.type_1', 1},
                    {'weapon.type_2', 2},
                    {'weapon.type_3', 3},
                    {'weapon.type_4', 4},
                    {'weapon.type_5', 5}
                }
            },
        }
    }
    self.RoleCurSort = self.RoleCurSort or {tbSort={1, false}, tbFilter=nil}
    self.LastRoleCurSort = self.RoleCurSort

    BtnAddEvent(self.BtnScreen, function()
        UI.Open('Screen', self.tbRoleSortInfo, self.RoleCurSort, function ()
            self:UpdateCharacterList()
        end)
    end)
end

function tbClass:UpdateCharacterList()
    self.tbItems = RoleCard.GetAllCharacter(2)
    local tbItem = self:GetFilterItems(self.tbItems)
    if #tbItem <= 0 then
        UI.ShowMessage("ui.TxtScreen5")
        self.RoleCurSort = self.LastRoleCurSort
        tbItem = self:GetFilterItems(self.tbItems)
    end
    self:ShowCharacterList(tbItem)
    self.LastRoleCurSort = self.RoleCurSort
end

function tbClass:GetFilterItems(tbItems)
    local nSort = 1
    local bReverse = false
    local tbFilter = {{}}

    nSort = self.RoleCurSort.tbSort[1]
    bReverse = self.RoleCurSort.tbSort[2]
    tbFilter = self.RoleCurSort.tbFilter or tbFilter

    local tbData = Copy(tbItems or {})
    for _, tbCfg in pairs(tbFilter) do
        tbData = ItemSort:Filter(tbData, tbCfg)
    end

    if self.tbRoleSortInfo and self.tbRoleSortInfo.tbSort then
        tbData = ItemSort:TemplateSort(tbData, self.tbRoleSortInfo.tbSort.tbRule[nSort][2])
    end
    if bReverse then
        ItemSort:Reverse(tbData)
    end
    return tbData
end

function tbClass:OnInit()
    self.CardItemPath = "/Game/UI/UMG/Role/Widgets/uw_role_role_data.uw_role_role_data"

    self.Factory = Model.Use(self)

    self.FightBtn.OnClicked:Add(self, function() self:PreDoFight() end)

    self.tbRoleItem = {}
    self.tbRoleItem[6] = {self.Team1Role1, self.Team1Role2, self.Team1Role3}
    self.tbRoleItem[7] = {self.Team1Role1, self.Team1Role2, self.Team1Role3}
    self.tbRoleItem[8] = {self.Team2Role1, self.Team2Role2, self.Team2Role3}

    BtnAddEvent(self.BtnIntro.BtnInfo, function()
        if not self.TowerInfo then
            self.TowerInfo = WidgetUtils.AddChildToPanel(self.Panel, "/Game/UI/UMG/Tower/Widgets/uw_tower_info.uw_tower_info_C", 7)
        end
        if self.TowerInfo then
            WidgetUtils.SelfHitTestInvisible(self.TowerInfo)
            self.TowerInfo:UpdatePanel()
        end
    end)

    BtnAddEvent(self.BtnSelected1, function()
        if self.IsDouble and self.SelectLineupIndex ~= 7 then
            self.SelectLineupIndex = 7
            WidgetUtils.HitTestInvisible(self.SelectedPanel1)
            WidgetUtils.Collapsed(self.SelectedPanel2)
            self:UpdatePos()
        end
    end)

    BtnAddEvent(self.BtnSelected2, function()
        if self.IsDouble and self.SelectLineupIndex ~= 8 then
            self.SelectLineupIndex = 8
            WidgetUtils.HitTestInvisible(self.SelectedPanel2)
            WidgetUtils.Collapsed(self.SelectedPanel1)
            self:UpdatePos()
        end
    end)
end

---UI打开
function tbClass:OnOpen()
    Launch.SetType(LaunchType.TOWER)
    self.LeftList:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
    WidgetUtils.Collapsed(self.TowerInfo)

    Formation.bReqUpdate = false

    self.IsDouble = ClimbTowerLogic.IsDouble()
    if self.IsDouble then
        WidgetUtils.Collapsed(self.Decorate1)
        WidgetUtils.HitTestInvisible(self.Decorate2)
        WidgetUtils.SelfHitTestInvisible(self.PanelTwo)
        Formation.SetCurLineupIndex(8)
        Formation.SetCurLineupIndex(7)
    else
        WidgetUtils.Collapsed(self.Decorate2)
        WidgetUtils.HitTestInvisible(self.Decorate1)
        WidgetUtils.Collapsed(self.PanelTwo)
        Formation.SetCurLineupIndex(6)
    end

    --重写返回事件
    self.Title:SetCustomEvent(
        function()
            if self.IsDouble then
                Formation.Req_UpdateLineup(7, function()
                    Formation.Req_UpdateLineup(8, UI.CloseTop)
                end)
            else
                Formation.Req_UpdateLineup(6, UI.CloseTop)
            end
        end,
        function()
            if self.IsDouble then
                Formation.Req_UpdateLineup(7, function()
                    Formation.Req_UpdateLineup(8, UI.OpenMainUI)
                end)
            else
                Formation.Req_UpdateLineup(6, UI.OpenMainUI)
            end
        end
    )

    Preview.PlayCameraAnimByCfgByID(Preview.COMMONID, PreviewType.formation)
    PreviewScene.Enter(PreviewType.role_lvup, function()
        self:UpdatePos()
        self:UpdateRoleList()
        self:UpdateCharacterList()
    end)
end

---刷新队伍角色列表
function tbClass:UpdateRoleList()
    if self.IsDouble then
        for lineupIdx = 7, 8 do
            for i = 1, 3 do
                local info = {}
                info.nPos = i
                info.nLineupIndex = lineupIdx
                info.bSelectLineup = self.SelectLineupIndex == lineupIdx
                info.UpdateSelectPos = function()
                    self.SelectLineupIndex = lineupIdx
                    if self.SelectLineupIndex == 7 then
                        WidgetUtils.HitTestInvisible(self.SelectedPanel1)
                        WidgetUtils.Collapsed(self.SelectedPanel2)
                    else
                        WidgetUtils.HitTestInvisible(self.SelectedPanel2)
                        WidgetUtils.Collapsed(self.SelectedPanel1)
                    end
                    if Formation.GetCurLineupIndex() ~= lineupIdx then
                        Formation.SetCurLineupIndex(lineupIdx)
                    end
                    self:UpdateFormationOnClick(i-1)
                end
                info.FunCheck = function ()
                    self.SelectLineupIndex = lineupIdx
                    if Formation.GetCurLineupIndex() ~= lineupIdx then
                        Formation.SetCurLineupIndex(lineupIdx)
                    end
                    Formation.SetMemberPos(i-1)
                end
                if self.tbRoleItem[lineupIdx][i] then
                    self.tbRoleItem[lineupIdx][i]:UpdatePanel(info)
                end
            end
        end
    else
        for i = 1, 3 do
            local info = {}
            info.nPos = i
            info.nLineupIndex = 6
            info.bSelectLineup = self.SelectLineupIndex == 6
            info.UpdateSelectPos = function()
                self.SelectLineupIndex = 6
                if Formation.GetCurLineupIndex() ~= 6 then
                    Formation.SetCurLineupIndex(6)
                end
                self:UpdateFormationOnClick(i-1)
            end
            info.FunCheck = function ()
                self.SelectLineupIndex = 6
                if Formation.GetCurLineupIndex() ~= 6 then
                    Formation.SetCurLineupIndex(6)
                end
                Formation.SetMemberPos(i-1)
            end
            if self.tbRoleItem[6][i] then
                self.tbRoleItem[6][i]:UpdatePanel(info)
            end
        end
    end
end

---点击队伍时更新队伍的数据
---@param ID integer 角色卡ID
function tbClass:UpdateFormationOnClick(nPos)
    local pCard = Formation.GetCardByIndex(self.SelectLineupIndex, nPos)
    if pCard then
        Formation.SetLineupMember(self.SelectLineupIndex, nPos, nil)
    end

    for i = 0, 1 do
        if not Formation.GetCardByIndex(self.SelectLineupIndex, i) and Formation.GetCardByIndex(self.SelectLineupIndex, i+1) then
            Formation.ChangePos(self.SelectLineupIndex, i, i+1)
        end
    end

    local CallBack = function()
        self:UpdatePos()
        self:UpdateRoleListState()
        if pCard and self.tbCardItem[pCard:Id()] then
            self.tbCardItem[pCard:Id()]:SetSelect(false)
        end
    end
    Formation.Req_UpdateLineup(self.SelectLineupIndex, CallBack)
end

---刷新当前的编辑位置
function tbClass:UpdatePos()
    if not self.SelectLineupIndex then
        if self.IsDouble then
            self.SelectLineupIndex = 7
        else
            self.SelectLineupIndex = 6
        end
        WidgetUtils.HitTestInvisible(self.SelectedPanel1)
        WidgetUtils.Collapsed(self.SelectedPanel2)
    end

    local tb = {}
    if self.IsDouble then
        tb = {7, 8}
    else
        tb = {6}
    end
    for _, index in pairs(tb) do
        for _, Item in pairs(self.tbRoleItem[index]) do
            Item:UpdateBGColor(self.SelectLineupIndex == index)
        end
    end

    Formation.SetCurLineupIndex(self.SelectLineupIndex)
    for i = 0, 2 do
        local pCard = Formation.GetCardByIndex(self.SelectLineupIndex, i)
        if not pCard then
            Formation.SetMemberPos(i)
            break
        end
    end
end

---刷新所有可加入编队的角色
function tbClass:ShowCharacterList(tbItems)
    self.tbCardItem = {}
    self:DoClearListItems(self.LeftList)
    local pCardItem = LoadClass(self.CardItemPath)
    for _, value in ipairs(tbItems) do
        local card = RoleCard.GetItem({value.Genre, value.Detail, value.Particular, value.Level})
        if card then
            local ID = card:Id()
            local TemplateId = card:TemplateId()
            local template = UE4.UItem.FindTemplateForID(TemplateId)

            local CardItem = NewObject(pCardItem, self, nil)
            local bSelect = self:IsInTeam(card)
            CardItem:Init(ID, bSelect, template,
                function()
                    if not self.SelectLineupIndex then
                        return
                    end
                    self:UpdateCurrentFormation(ID)
                end
            )
            CardItem.bTowerFormation = true
            self.LeftList:AddItem(CardItem)
            self.tbCardItem[ID] = CardItem
        end
    end
end

---判断角色卡是否已经在爬塔队伍中
function tbClass:IsInTeam(card)
    if self.IsDouble then
        return Formation.IsInFormation(7, card) or Formation.IsInFormation(8, card)
    else
        return Formation.IsInFormation(6, card)
    end
end

---更新当前队伍的数据
---@param ID integer 角色卡ID
function tbClass:UpdateCurrentFormation(ID)
    local InCard = me:GetCharacterCard(ID)
    if not InCard then
        return
    end
    local nIndex = Formation.GetCurLineupIndex()
    if nIndex == 7 or nIndex == 8 then  ---爬塔活动队伍队员互斥检查
        local tb = {}
        tb[7] = 8
        tb[8] = 7
        local pos = Formation.GetRoleIndex(tb[nIndex], InCard)
        if pos and pos >= 0 then
            return  --在另一个队伍直接返回
        end
    end

    local isfull = true
    for i = 0, 2 do
        if not Formation.GetCardByIndex(nIndex, i) then
            isfull = false
        end
    end

    local nPos = Formation.GetMemberPos()
    local pCard = Formation.GetCardByIndex(nIndex, nPos)
    local nState = Formation.GetRoleState(nIndex, pCard, InCard)
    if nState == 0 then
        if isfull then
            return
        end
        Formation.SetLineupMember(nIndex, nPos, InCard)
    elseif nState == 1 then
        Formation.SetLineupMember(nIndex, nPos, nil)
    elseif nState == 2 then
        local Pos = Formation.GetRoleIndex(nIndex, InCard)
        if Pos then
            Formation.SetLineupMember(nIndex, Pos, nil)
        end
    end

    for i = 0, 1 do
        if not Formation.GetCardByIndex(nIndex, i) and Formation.GetCardByIndex(nIndex, i+1) then
            Formation.ChangePos(nIndex, i, i+1)
        end
    end

    local CallBack = function()
        self:UpdatePos()
        self:UpdateRoleListState()
        if nState == 0 then
            if pCard and self.tbCardItem[pCard:Id()] then
                self.tbCardItem[pCard:Id()]:SetSelect(false)
            end
            if self.tbCardItem[ID] then
                self.tbCardItem[ID]:SetSelect(true)
            end
        else
            if self.tbCardItem[ID] then
                self.tbCardItem[ID]:SetSelect(false)
            end
        end
    end
    Formation.Req_UpdateLineup(nIndex, CallBack)
end

---添加或减少角色后刷新队伍中的角色卡的状态
function tbClass:UpdateRoleListState()
    local tb = {}
    if self.IsDouble then
        tb = {7, 8}
    else
        tb = {6}
    end
    for _, index in pairs(tb) do
        for _, Item in pairs(self.tbRoleItem[index]) do
            Item:UpdateCard()
        end
    end
end

---准备出战
function tbClass:PreDoFight()
    if Formation.bReqUpdate then
        return
    end
    Formation.bReqUpdate = true
    if self.IsDouble then
        Formation.Req_UpdateLineup(7, function()
            Formation.Req_UpdateLineup(8, self.EnterLevel)
        end)
    else
        Formation.Req_UpdateLineup(6, self.EnterLevel)
    end
end

---进入关卡
function tbClass:EnterLevel()
    Formation.bReqUpdate = false
    local canFight, msg = Formation.CanFight()
    if not canFight then
        UI.ShowTip(msg)
        return
    end
    if ClimbTowerLogic.IsAdvanced() and ClimbTowerLogic.GetLevelDiff() == 0 then
        UI.Open("MessageBox",Text("climbtower.NotDiff"), UI.CloseTop)
        return
    end
    Launch.Start()
end


return tbClass
