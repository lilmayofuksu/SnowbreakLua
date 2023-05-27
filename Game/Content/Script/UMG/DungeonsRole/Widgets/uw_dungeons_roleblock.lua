-- ========================================================
-- @File    : uw_dungeons_roleblock.lua
-- @Brief   : 角色碎片本主界面章节控件
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnEntry, function()
        if not self.ChapterCfg then return end
        if self.ChapterCfg.tbCondition then
            local bUnLock, sLockDes = Condition.Check(self.ChapterCfg.tbCondition)
            if bUnLock == false then
                local tbCon = self.ChapterCfg.tbCondition[1]
                if tbCon[1] == 3 then 
                    local g, d, p, l = table.unpack(tbCon, 2, #tbCon)
                    if g and d and p and l then 
                        local iteminfo = UE4.UItem.FindTemplate(g, d, p, l)
                        if iteminfo then 
                            local name
                            if p == 1 then
                                name = Text(iteminfo.I18N)
                            else
                                name = Text(iteminfo.I18N) .. '—' .. Text(iteminfo.I18N..'_title')
                            end
                            UI.ShowTip(Text('ui.TxtRoleLock', name))
                            return
                        end
                    end
                end
                UI.ShowTip(sLockDes[1])
                return
            end
        end
        UI.Open("DungeonsRoleMap", self.ChapterCfg)
    end)
end

function tbClass:OnListItemObjectSet(pObj)
    self:Init(pObj.Data)
end

function tbClass:Init(cfg)
    self.ChapterCfg = cfg
    if not self.ChapterCfg or not self.ChapterCfg.nID then
        WidgetUtils.Hidden(self.Panel)
        return
    else
        WidgetUtils.SelfHitTestInvisible(self.Panel)
    end

    if #cfg.tbCharacter >= 4 then
        local Characterinfo = UE4.UItem.FindTemplate(cfg.tbCharacter[1], cfg.tbCharacter[2], cfg.tbCharacter[3], cfg.tbCharacter[4])
        if Characterinfo then
            SetTexture(self.Logo, Characterinfo.Icon)
            SetTexture(self.Girl, Characterinfo.Icon)
            self.TextName:SetText(Text(Characterinfo.I18N))
            self.TextName2:SetText(Text(Characterinfo.I18N.."_title"))

            if Characterinfo.Color == 5 then
                SetTexture(self.ImgRarity, 1701158)
            elseif Characterinfo.Color == 4 then
                SetTexture(self.ImgRarity, 1701159)
            end
        end
    end

    WidgetUtils.HitTestInvisible(self.TimesNum)
    local num1, num2 = Role.GetNum(cfg)
    if num2 > 0 then
        self.TxtTime:SetText(num2 - num1)
        self.TxtTotal:SetText(num2)
        if num2 - num1 <= 0 then
            self.TxtTime:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0.5, 0, 0, 1))
        else
            self.TxtTime:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
        end
    else
        WidgetUtils.Collapsed(self.TimesNum)
    end

    if self.ChapterCfg.nType == 2 then
        SetTexture(self.Color, 1701087)
    else
        SetTexture(self.Color, 1701086)
    end

    local breakInfo = Role.GetBreakInfo(cfg.tbCharacter)
    if breakInfo and breakInfo[1] and #breakInfo[1] >= 5 then
        WidgetUtils.HitTestInvisible(self.PanelPiece)
        local iteminfo = UE4.UItem.FindTemplate(breakInfo[1][1], breakInfo[1][2], breakInfo[1][3], breakInfo[1][4])
        SetTexture(self.ImgPiece, iteminfo.Icon)
        self.TxtNum:SetText(me:GetItemCount(breakInfo[1][1], breakInfo[1][2], breakInfo[1][3], breakInfo[1][4]) .. "/" .. breakInfo[1][5])
    else
        WidgetUtils.Collapsed(self.PanelPiece)
    end

    local bUnLock = Condition.Check(self.ChapterCfg.tbCondition)
    if bUnLock then
        WidgetUtils.Collapsed(self.PanelEmpty)
    else
        WidgetUtils.HitTestInvisible(self.PanelEmpty)
    end
end


return tbClass
