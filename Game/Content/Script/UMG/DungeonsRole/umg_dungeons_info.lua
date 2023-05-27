-- ========================================================
-- @File    : umg_dungeons_info.lua
-- @Brief   : 角色碎片活动关卡细节信息界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.DropListFactory = Model.Use(self)
end

function tbClass:OnOpen(tbCfg, ChapterCfg)
    local tbCfg = tbCfg or RoleLevel.Get(Role.GetLevelID())
    self.tbCfg = tbCfg
    self.Infos:Show(tbCfg)
    if ChapterCfg then
        self:ShowChapter(ChapterCfg)
    end
end

---显示章节详情
function tbClass:ShowChapter(ChapterCfg)
    self.TextName:SetText(Text(ChapterCfg.sName))
    ---概念图
    if ChapterCfg.nPicture then
        SetTexture(self.ImgRole, ChapterCfg.nPicture)
    end

    ---剩余次数
    -- self.TxtNum:SetText(self.tbCfg:GetPassTime())
    -- self.TxtTarget:SetText(self.tbCfg.nNum)

    local breakInfo = Role.GetBreakInfo(ChapterCfg.tbCharacter)
    if breakInfo and breakInfo[1] and #breakInfo[1] >= 5 then
        WidgetUtils.HitTestInvisible(self.PanelPiece)
        local iteminfo = UE4.UItem.FindTemplate(breakInfo[1][1], breakInfo[1][2], breakInfo[1][3], breakInfo[1][4])
        SetTexture(self.ImgPiece, iteminfo.Icon)
        self.TxtPiece:SetText(me:GetItemCount(breakInfo[1][1], breakInfo[1][2], breakInfo[1][3], breakInfo[1][4]) .. "/" .. breakInfo[1][5])
    else
        WidgetUtils.Collapsed(self.PanelPiece)
    end
end

return tbClass
