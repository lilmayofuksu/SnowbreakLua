-- ========================================================
-- @File    : umg_dungeons_rolesmap.lua
-- @Brief   : 角色碎片活动关卡界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.EqPath = "/Game/UI/UMG/DungeonsRole/Widgets/uw_dungeons_ep.uw_dungeons_ep_C"
    self.LevelPath1 = "/Game/UI/UMG/DungeonsRole/Widgets/uw_dungeons_level.uw_dungeons_level_C"
    self.LevelPath2 = "/Game/UI/UMG/DungeonsRole/Widgets/uw_dungeons_level2.uw_dungeons_level2_C"
    self.tbLevelItem = {}
end

function tbClass:OnOpen(cfg)
    if Launch.GetType() ~= LaunchType.ROLE then
        Launch.SetType(LaunchType.ROLE)
    end

    self.ChapterCfg = cfg or self.ChapterCfg or Role.GetNowChapterCfg()
    if not self.ChapterCfg then
        return
    end
    Role.SetNowChapterCfg(self.ChapterCfg)
    self:UpdateLevelList()
    self:UpdateChange()

    --刷新显示挑战次数
    local num, total = Role.GetActivityNum()
    self.TxtTime:SetText(num)
    self.TxtTotal:SetText(total)
    if num <= 0 then
        self.TxtTime:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0.5, 0, 0, 1))
    else
        self.TxtTime:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0, 0, 0, 1))
    end

    ---今日消耗分数
    self.Money:Init({Role.MoneyID})
end

function tbClass:OnClose()
end

function tbClass:UpdateLevelList()
    if not self.ChapterCfg.tbLevel then return end

    local Characterinfo = nil
    if #self.ChapterCfg.tbCharacter >= 4 then
        Characterinfo = UE4.UItem.FindTemplate(self.ChapterCfg.tbCharacter[1], self.ChapterCfg.tbCharacter[2], self.ChapterCfg.tbCharacter[3], self.ChapterCfg.tbCharacter[4])
        if Characterinfo then
            self.TextName:SetText(Text(Characterinfo.I18N.."_title"))
        end
    end

    self.tbLevelItem = {}
    local count = #self.ChapterCfg.tbLevel
    for i = 1, count do
        local pLevelWidget = self["Level" .. i]
        local pWidget = self["DotPanel" .. i]
        if pLevelWidget and pWidget then
            local levelCfg = RoleLevel.Get(self.ChapterCfg.tbLevel[i])
            if levelCfg then
                WidgetUtils.SelfHitTestInvisible(pLevelWidget)
                pWidget:ClearChildren()
                local pLevel = nil
                if levelCfg.nType == 2 then --剧情
                    pLevel = Activity.LoadCaseItem(self.EqPath)
                elseif levelCfg.nNum > 0 or levelCfg.nNum == -1 then   --复刷关
                    pLevel = Activity.LoadCaseItem(self.LevelPath2)
                    if Characterinfo then
                        pLevel:SetIcon(Characterinfo.Icon)
                    end
                else
                    pLevel = Activity.LoadCaseItem(self.LevelPath1)
                end
                if pLevel then
                    pWidget:AddChild(pLevel)
                    local LevelSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(pLevel)
                    LevelSlot:SetAutoSize(true)
                    pLevel:Init(levelCfg.nID, function(cfg)
                        local bUnLock, sLockDes = Condition.Check(cfg.tbCondition)
                        if bUnLock == false then
                            UI.ShowTip(sLockDes[1])
                            return
                        end
                        self:UpdateChange(cfg.nID)
                        self:ShowDetail(cfg, self.ChapterCfg)
                    end)
                    self.tbLevelItem[levelCfg.nID] = pLevel
                end
            else
                WidgetUtils.Collapsed(pLevelWidget)
            end
        end
    end
    for i = count+1, 8 do
        WidgetUtils.Collapsed(self["Level" .. i])
    end

    local LineSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Line)
    LineSlot:SetSize(UE4.FVector2D(320 * (count - 1), 2))

    ---剧情需要显示奖励
    if Role.tbShowAward then
        UI.Open("GainItem", Role.tbShowAward)
        Role.tbShowAward = nil
    end
end

---刷新选中状态
function tbClass:UpdateChange(selectid)
    if not selectid or not self.tbLevelItem[selectid] then
        selectid = Role.GetChapterProgres()
    end
    for id, level in pairs(self.tbLevelItem) do
        level:SelectChange(id == selectid)
    end
end

---显示关卡细节
function tbClass:ShowDetail(tbLevelCfg, ChapterCfg)
    Role.SetLevelID(tbLevelCfg.nID)
    if Role.IsPlot(tbLevelCfg.nID) then
        UI.Open('StoryInfo', tbLevelCfg.nID)
    else
        if not self.Infos then
            self.Infos = WidgetUtils.AddChildToPanel(self.Panel, "/Game/UI/UMG/Common/Widgets/uw_level_info.uw_level_info_C", 4)
        end
        if self.Infos then
            WidgetUtils.SelfHitTestInvisible(self.Infos)
            self.Infos:Show(tbLevelCfg)
        end
    end
end

return tbClass
