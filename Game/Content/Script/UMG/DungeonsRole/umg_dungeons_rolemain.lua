-- ========================================================
-- @File    : umg_dungeons_rolemain.lua
-- @Brief   : 角色碎片活动主界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.Factory = Model.Use(self)
    self.nDifficult = 1 --当前选择的难度
    ---跳转到天启按钮
    -- BtnAddEvent(self.BtnBreak, function()
    --     local cfg = Role.GetChapterCfg(self.SelectChapterId, self.nDifficult)
    --     if cfg and cfg.tbCharacter then
    --         local CurCard = RoleCard.GetItem(cfg.tbCharacter)
    --         if CurCard then
    --             UI.Open("RoleUpLv", CurCard, 1, true)
    --         end
    --     end
    -- end)
    -- BtnAddEvent(self.BtnLock, function()
    --     UI.ShowTip(Text("tip.not_material_for_break"))
    --     --UI.ShowTip(Text("break num by limit..."))
    -- end)
    WidgetUtils.Collapsed(self.Subtab)
end

function tbClass:OnOpen()
    PreviewScene.PlayDungeonsSeq(5, UI.bPoping)

    Launch.SetType(LaunchType.ROLE)
    self.Subtab:Init(2)
    self:UpdateChapterPanel()
    self.List:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
end

---刷新章节信息
function tbClass:UpdateChapterPanel(allCfg)
    local allChapterCfg = allCfg or Role.GetAllOpenChapterCfg(self.nDifficult)
    table.sort(allChapterCfg, function(l, r)
        local time1 = me:GetAttribute(Role.GroupID, l.nID)
        local time2 = me:GetAttribute(Role.GroupID, r.nID)
        if time1 == time2 then
            return l.nID < r.nID
        end
        return time1 > time2
    end)
    local data = {}
    local tbLock = {}
    for _, cfg in ipairs(allChapterCfg) do
        local bUnLock = Condition.Check(cfg.tbCondition)
        if bUnLock then
            table.insert(data, cfg)
        else
            table.insert(tbLock, cfg)
        end
    end
    for _, cfg in ipairs(tbLock) do
        table.insert(data, cfg)
    end

    self:DoClearListItems(self.List)
    for _, cfg in ipairs(data) do
        local pObj = self.Factory:Create(cfg)
        self.List:AddItem(pObj)
    end
    self.List:AddItem(self.Factory:Create({}))
    ---今日消耗分数
    self.Money:Init({Role.MoneyID})
end

---刷新天启按钮
function tbClass:UpdateBreakBtn(ChapterCfg)
    local breakInfo = Role.GetBreakInfo(ChapterCfg.tbCharacter)
    if breakInfo and breakInfo[1] and #breakInfo[1] >= 5 then
        local havenum = me:GetItemCount(breakInfo[1][1], breakInfo[1][2], breakInfo[1][3], breakInfo[1][4])
        if havenum >= breakInfo[1][5] then
            WidgetUtils.Collapsed(self.BtnLock)
            WidgetUtils.Visible(self.BtnBreak)
            return
        end
    end
    WidgetUtils.Collapsed(self.BtnBreak)
    WidgetUtils.Visible(self.BtnLock)
end

return tbClass
