-- ========================================================
-- @File    : uw_tower_info.lua
-- @Brief   : 爬塔编队时可弹出的信息界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Popup:Init("", function() WidgetUtils.Collapsed(self) end)
    self.ListFactory = Model.Use(self)
    self:DoClearListItems(self.ListMonster)
    self.ListMonster:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
end

function tbClass:UpdatePanel()
    self:PlayAnimation(self.AllEnter)
    --关卡buff
    local levelcfg = ClimbTowerLogic.GetLevelCfg()
    if not levelcfg then return end
    if levelcfg.sBuffDesc then
        self.TxtContent:SetText(Text(levelcfg.sBuffDesc))
    end
    --本期buff
    local timecfg = ClimbTowerLogic.GetTimeCfg()
    if timecfg and timecfg.sBuffDesc then
        self.TxtContent_1:SetText(Text(timecfg.sBuffDesc))
    end
    --怪物信息
    local TbLevelID = ClimbTowerLogic.GetNowTbLevelID()
    local data = {}
    local tbMonsterInfo = {}
    for _, ID in pairs(TbLevelID) do
        local cfg = ClimbTowerLogic.GetLevelInfo(ID)
        if cfg and cfg.tbMonster then
            for _, tbinfo in pairs(cfg.tbMonster) do
                for _, mID in pairs(tbinfo) do
                    if not data[mID] then
                        table.insert(tbMonsterInfo, mID)
                        data[mID] = true
                    end
                end
            end
        end
    end

    self:DoClearListItems(self.ListMonster)
    for _, info in pairs(tbMonsterInfo) do
        local pObj = self.ListFactory:Create(info)
        self.ListMonster:AddItem(pObj)
    end
end

return tbClass
