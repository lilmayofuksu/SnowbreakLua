-- ========================================================
-- @File    : uw_nerve_node.lua
-- @Brief   : 角色脊椎系统中间节点
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.EventActive = EventSystem.OnTarget(Spine, Spine.UpDataNode, function(Target, tbData)
        self:UpdateState(tbData.Idx, tbData.Item)
    end)
end

function RoleStar:OnDestruct()
    if self.EventActive then
        EventSystem.Remove(self.EventActive)
        self.EventActive = nil
    end
end

function tbClass:UpdatePanel(Idx, pItem, SkillID)
    if SkillID then
        local icon = UE4.UAbilityLibrary.GetSkillIcon(SkillID)
        SetTexture(self.ImgOnIcon, icon)
        SetTexture(self.ImgOffIcon, icon)
    end
    if not pItem then return end
    if pItem:GetSpine(Idx, Spine.MaxSubNum) then
        WidgetUtils.Collapsed(self.ImgOffIcon)
        WidgetUtils.HitTestInvisible(self.ImgOnIcon)
    else
        WidgetUtils.Collapsed(self.ImgOnIcon)
        WidgetUtils.HitTestInvisible(self.ImgOffIcon)
    end

    self:UpdateState(Idx, pItem)
    self:UpdatePanelLevel(pItem)
end

function tbClass:UpdateState(Idx, pItem)
    if not pItem then return end
    local RecordIndx = Spine.GetRecordIndx(pItem:Id())
    if Idx%2 ~= 0 then
        WidgetUtils.Collapsed(self.ImgOffBG2)
        WidgetUtils.Collapsed(self.ImgOnBG2)
        WidgetUtils.Collapsed(self.ImgLockBG2)
        if pItem:GetSpine(Idx, Spine.MaxSubNum) then
            WidgetUtils.Collapsed(self.ImgLockBG1)
            WidgetUtils.Collapsed(self.ImgOffBG1)
            WidgetUtils.HitTestInvisible(self.ImgOnBG1)
        elseif RecordIndx == Idx then
            WidgetUtils.Collapsed(self.ImgLockBG1)
            WidgetUtils.Collapsed(self.ImgOnBG1)
            WidgetUtils.HitTestInvisible(self.ImgOffBG1)
        else
            WidgetUtils.Collapsed(self.ImgOffBG1)
            WidgetUtils.Collapsed(self.ImgOnBG1)
            WidgetUtils.HitTestInvisible(self.ImgLockBG1)
        end
    else
        WidgetUtils.Collapsed(self.ImgOffBG1)
        WidgetUtils.Collapsed(self.ImgOnBG1)
        WidgetUtils.Collapsed(self.ImgLockBG1)
        if pItem:GetSpine(Idx, Spine.MaxSubNum) then
            WidgetUtils.Collapsed(self.ImgLockBG2)
            WidgetUtils.Collapsed(self.ImgOffBG2)
            WidgetUtils.HitTestInvisible(self.ImgOnBG2)
        elseif RecordIndx == Idx then
            WidgetUtils.Collapsed(self.ImgLockBG2)
            WidgetUtils.Collapsed(self.ImgOnBG2)
            WidgetUtils.HitTestInvisible(self.ImgOffBG2)
        else
            WidgetUtils.Collapsed(self.ImgOffBG2)
            WidgetUtils.Collapsed(self.ImgOnBG2)
            WidgetUtils.HitTestInvisible(self.ImgLockBG2)
        end
    end
end

---刷新职级信息
function tbClass:UpdatePanelLevel(pItem)
    if not pItem then
        return
    end
    local proLevel = pItem:ProLevel()
    local showProLevel = 0
    if FunctionRouter.IsOpenById(FunctionType.ProLevel) then
        showProLevel = proLevel+1
    end
    for i = 1, 4 do
        if i>showProLevel then
            WidgetUtils.Collapsed(self["ImgLevel" .. i .. "_1"])
            WidgetUtils.HitTestInvisible(self["ImgLevel" .. i])
        else
            WidgetUtils.Collapsed(self["ImgLevel" .. i])
            WidgetUtils.HitTestInvisible(self["ImgLevel" .. i .. "_1"])
        end
    end
    if showProLevel>=4 then
        WidgetUtils.Collapsed(self.PanelNormal)
        WidgetUtils.HitTestInvisible(self.PanelSuccess)
    else
        WidgetUtils.Collapsed(self.PanelSuccess)
        WidgetUtils.HitTestInvisible(self.PanelNormal)
    end

    local key = table.concat({pItem:Genre(), pItem:Detail(), pItem:Particular(), pItem:Level()}, "-")
    local Data = RoleCard.tbProLevelData[key]
    if Data and Data.tbSkillID[proLevel] then
        local sIcon = UE4.UAbilityLibrary.GetSkillFixInfoStaticId(Data.tbSkillID[proLevel][1])
        SetTexture(self.ImgSkillSuc, sIcon)
        SetTexture(self.ImgSkillNor, sIcon)
    end
end

return tbClass
