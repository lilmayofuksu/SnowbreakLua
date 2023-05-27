-- ========================================================
-- @File    : umg_general_pause.lua
-- @Brief   : 暂停界面
-- ========================================================
---@class tbClass : ULuaWidget
---@field Conditions UWrapBox
---@field AwardList UListView
local tbClass = Class("UMG.BaseWidget")


function tbClass:OnInit()
    self.BtnNo.OnClicked:Add(self, function()
            UE4.UGameplayStatics.SetGamePaused(self, false)
            UI.Close(self)
        end
    )

    self.BtnOk.OnClicked:Add(self, function()
            Launch.End()
        end
    )

    local LevelData = nil
    if Launch.GetType() == LaunchType.ROLE then
        LevelData = RoleLevel.Get(Role.GetLevelID())
    else
        LevelData = ChapterLevel.Get(Chapter.GetLevelID())
    end
    if LevelData then
        self.Chapter:SetText(LevelData.LevelIndex)
        self.LevelName:SetText(LevelData.LevelName)
    end
    self.ListFactory = Model.Use(self)
end

function tbClass:OnOpen()
    UE4.UGameplayStatics.SetGamePaused(self, true)

    --- 显示星级目标

    local pSubSys = UE4.USubsystemBlueprintLibrary.GetWorldSubsystem(self, UE4.ULevelStarTaskManager)
        ---显示星级目标信息
    if pSubSys then
        local Infos = pSubSys:GetStarTaskProperties()
        for i = 1, Infos:Length() do
            local pItem = Infos:Get(i)
            local pWidget = self.Conditions:GetChildAt(i - 1)
            if pWidget then
                pWidget.Des:SetText(pItem.Description)
                if pItem.bFinished then
                    WidgetUtils.SelfHitTestInvisible(pWidget.Succ)
                else
                    WidgetUtils.Collapsed(pWidget.Succ)
                end
            end
        end
    end

    local pDropSubSys = UE4.USubsystemBlueprintLibrary.GetWorldSubsystem(self, UE4.ULevelDropsManager)
    --- 显示奖励
    self:DoClearListItems(self.AwardList)
    self.AwardList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    if pDropSubSys then
        local tbAward = pDropSubSys:GetGainedDrops():ToTable()
        if tbAward then
            for k, v in pairs(tbAward) do
                local tbGDPL = Split(k, "-")
                if #tbGDPL >= 4 then
                    local tbParam = {G = tbGDPL[1], D = tbGDPL[2], P = tbGDPL[3], L = tbGDPL[4], N = v}
                    local pObj = self.ListFactory:Create(tbParam)
                    self.AwardList:AddItem(pObj)
                end
            end
        end
    end
end


return tbClass
