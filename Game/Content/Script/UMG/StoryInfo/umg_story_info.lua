-- ========================================================
-- @File    : umg_story_info.lua
-- @Brief   : 剧情关卡信息
-- ========================================================

---@class tbClass : ULuaWidget
---@field ListItem UListView
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(self.BtnStart, function()
            if self.nLevelID then
                if Launch.GetType() == LaunchType.DLC1_CHAPTER then
                    DLC_Chapter.SetLevelID(self.nLevelID)
                else
                    Chapter.SetLevelID(self.nLevelID)
                end
                
                Launch.Start()
            end
    end)
    self.ListItem:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self.DropListFactory = Model.Use(self)
    self:DoClearListItems(self.ListItem)
end

function tbClass:OnOpen(nLevelID)
    local tbCfg = nil
    if Launch.GetType() == LaunchType.ROLE then
        tbCfg = RoleLevel.Get(nLevelID)
    elseif Launch.GetType() == LaunchType.DLC1_CHAPTER then
        tbCfg = DLCLevel.Get(nLevelID)
    else
        tbCfg = ChapterLevel.Get(nLevelID)
    end
    if not tbCfg then return end

    self.nLevelID = nLevelID
    self:DoClearListItems(self.ListItem)
    local bGet = (tbCfg:GetPassTime() > 0)

     ---首通奖励显示
     if tbCfg:IsFirstPass() then
        for _, tbInfo in ipairs(tbCfg.tbShowFirstAward) do
            local G, D, P, L, N = table.unpack(tbInfo)
            local tbParam = {G = G, D = D, P = P, L = L, N = N, bIsFirst = true, bGeted = bGet}
            local pObj = self.DropListFactory:Create(tbParam)
            self.ListItem:AddItem(pObj)
        end
    end

    for _, tbInfo in ipairs(tbCfg.tbShowAward) do
        local G, D, P, L, N = table.unpack(tbInfo)
        local tbParam = {G = G, D = D, P = P, L = L, N = N, bGeted = bGet}
        local pObj = self.DropListFactory:Create(tbParam)
        self.ListItem:AddItem(pObj)
    end

    if tbCfg.tbShowRandomAward then
        for _, tbInfo in ipairs(tbCfg.tbShowRandomAward) do
            local G, D, P, L, N = table.unpack(tbInfo)
            local tbParam = {G = G, D = D, P = P, L = L, N = N, dropType = Launch.nDropType.RandomDrop}
            local pObj = self.DropListFactory:Create(tbParam)
            self.ListItem:AddItem(pObj)
        end
    end

    self.TxtName:SetText(Text(tbCfg.sFlag))
    self.TxtNum:SetText(Text(tbCfg.sDes))
end


return tbClass