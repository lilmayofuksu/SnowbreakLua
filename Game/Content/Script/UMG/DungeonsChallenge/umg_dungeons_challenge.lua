-- ========================================================
-- @File    : umg_dungeons_challenge.lua
-- @Brief   : 挑战区界面
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.ListFactory = self.ListFactory or Model.Use(self)
    self:DoClearListItems(self.List)
    -- BtnAddEvent(self.Tower, ClimbTowerLogic.CheckCycleLevel)
    -- BtnAddEvent(self.Boss, BossLogic.GetOpenID)
    -- BtnAddEvent(self.Defense, DefendLogic.CheckOpenAct)
end

function tbClass:OnOpen()
    PreviewScene.PlayDungeonsSeq(3, UI.bPoping)

    self.List:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
    self:DoClearListItems(self.List)
    local tb = {
        {
            nPicture = 1701124,
            sName = 'TxtDungeonsTowerName',
            nId = FunctionType.Tower,
            FunClick = function() ClimbTowerLogic.CheckCycleLevel() end
        },
        {
            nPicture = 1701125,
            sName = 'TxtDungeonsBossName',
            nId = FunctionType.BossChallenge,
            FunClick = function() BossLogic.GetOpenID() end
        },
        {
            nPicture = 1701127,
            sName = 'TxtDefenseTip2',
            nId = FunctionType.Defend,
            FunClick = function() DefendLogic.CheckOpenAct() end
        },
        {
            nPicture = 1701126,
            sName = 'TxtDungeonsRole.title',
            nId = FunctionType.TowerEvent,
            FunClick = function()
                FunctionRouter.CheckEx(FunctionType.TowerEvent, function()
                    UI.Open("TowerEvent", true)
                end)
            end
        },
    }

    local defendConf = DefendLogic.GetOpenConf()
    if defendConf then
        if defendConf.nEntryImg then tb[3].nPicture = defendConf.nEntryImg end
        if defendConf.sEntryName then tb[3].sName = defendConf.sEntryName end
        if defendConf.nNameImg then tb[3].nNameImg = defendConf.nNameImg end
    end

    for _, v in ipairs(tb) do
        local pObj = self.ListFactory:Create(v)
        self.List:AddItem(pObj)
    end
end

return tbClass