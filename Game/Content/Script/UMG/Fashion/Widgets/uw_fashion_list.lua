-- ========================================================
-- @File    : uw_fashion_list.lua
-- @Brief   : 角色时装
-- ========================================================

local tbFashionList = Class("UMG.SubWidget")

function tbFashionList:Construct()
    BtnAddEvent(
        self.BtnChoose,
        function()
            if self.Data.Click then
                self.Data.Click(self)
            end
        end
    )
end


function tbFashionList:OnListItemObjectSet(InObj)
    if InObj == nil then
        return
    end
    self.Data = InObj.Data
    self:InitClothesList()
    
    if self.Data.bShow then
        if self.Data.Click then
            self.Data.Click(self, true)
        end
    end
end

function tbFashionList:InitClothesList()
    WidgetUtils.Collapsed(self.PanelLock)
    WidgetUtils.Collapsed(self.PanelLock1)
    WidgetUtils.Collapsed(self.PanelNow)
    WidgetUtils.Collapsed(self.PanelNow1)
    WidgetUtils.Collapsed(self.PanelPose)
    WidgetUtils.Collapsed(self.PanelPoseBack)
    -- WidgetUtils.Collapsed(self.ImgFrame)
    if type(self.Data.Skin) == "table" then
        local Template = self.Data.Skin
        local pSkin = Fashion.GetSkinItem({Template.Genre, Template.Detail, Template.Particular, Template.Level})
        if pSkin and Fashion.CheckRedPointBySkin(pSkin) then
            WidgetUtils.SelfHitTestInvisible(self.New)
        else
            WidgetUtils.Collapsed(self.New)
        end
        SetTexture(self.ImgPose, self.Data.Skin.Icon)
        SetTexture(self.ImgPose_1, self.Data.Skin.Icon)
    else
        if self.Data.Skin and Fashion.CheckRedPointBySkin(self.Data.Skin) then
            WidgetUtils.SelfHitTestInvisible(self.New)
        else
            WidgetUtils.Collapsed(self.New)
        end
        SetTexture(self.ImgPose, self.Data.Skin:Icon())
        SetTexture(self.ImgPose_1, self.Data.Skin:Icon())
    end
    if not self.Data.HaveSkin then
        WidgetUtils.HitTestInvisible(self.PanelLock)
        WidgetUtils.HitTestInvisible(self.PanelLock1)
        WidgetUtils.HitTestInvisible(self.PanelPoseBack)
    else
        WidgetUtils.HitTestInvisible(self.PanelPose)
    end
    if self.Data.Equip == self.Data.Index then
        if self.Data.SetEquipItem then
            self.Data.SetEquipItem(self)
        end
        WidgetUtils.HitTestInvisible(self.PanelNow)
        WidgetUtils.HitTestInvisible(self.PanelNow1)
    end


    self:OnSelect(false, true)
    -- self.TxtInitiate:SetText(Text(Fashion.EGetType[self.Data.Template.GetType]))
end

--- 选中时改变样式
--- @param IsSelectTarget boolean 是否是选中的道具
function tbFashionList:OnSelect(IsSelectTarget, bInit)
    if IsSelectTarget then
        if not self.IsSelected and not bInit then
            self:UnbindAllFromAnimationFinished(self.list_refresh)
            self:PlayAnimation(self.list_refresh)
        end
        self.IsSelected = true
        -- WidgetUtils.HitTestInvisible(self.ImgFrame)
        WidgetUtils.Collapsed(self.PanelPoseBack)
        WidgetUtils.SelfHitTestInvisible(self.PanelPose)

        if type(self.Data.Skin) == "table" then
            local Template = self.Data.Skin
            local pSkin = Fashion.GetSkinItem({Template.Genre, Template.Detail, Template.Particular, Template.Level})
            if pSkin and not pSkin:HasFlag(Item.FLAG_READED) then
                Item.Read({pSkin:Id()})
                WidgetUtils.Collapsed(self.New)
            end
        else
            local pSkin = self.Data.Skin
            if pSkin and not pSkin:HasFlag(Item.FLAG_READED) then
                Item.Read({pSkin:Id()})
                WidgetUtils.Collapsed(self.New)
            end
        end
    else
        if self.IsSelected and not bInit then
            self:PlayAnimation(self.list_refresh, 0, 1, UE4.EUMGSequencePlayMode.Reverse)
            self:BindToAnimationFinished(self.list_refresh, {self, function()
                WidgetUtils.Collapsed(self.PanelPose)
                WidgetUtils.SelfHitTestInvisible(self.PanelPoseBack)
                self:UnbindAllFromAnimationFinished(self.list_refresh)
            end})
        end
        if bInit then
            WidgetUtils.Collapsed(self.PanelPose)
            WidgetUtils.SelfHitTestInvisible(self.PanelPoseBack)
        end
        self.IsSelected = false
        -- WidgetUtils.Collapsed(self.ImgFrame)
        -- WidgetUtils.Collapsed(self.PanelPose)
        -- WidgetUtils.SelfHitTestInvisible(self.PanelPoseBack)
    end
end

function tbFashionList:UpdateEquipState(bEquip)
    if bEquip then
        WidgetUtils.HitTestInvisible(self.PanelNow)
        WidgetUtils.HitTestInvisible(self.PanelNow1)
    else
        WidgetUtils.Collapsed(self.PanelNow)
        WidgetUtils.Collapsed(self.PanelNow1)
    end
end

function tbFashionList:OnDestruct()
    EventSystem.Remove(self.EventTarget)
end

return tbFashionList