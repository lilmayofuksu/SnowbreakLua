-- ========================================================
-- @File    : uw_arms_details.lua
-- @Brief   : 武器详情显示界面
-- ========================================================

---@class tbClass
---@field MainAttr UListView
---@field SubAttr UListView
---@field ImgNum1 UImage
---@field ImgNum2 UImage
---@field pInfoActor AActor
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnLeft,
            function()
                if self.tbData and self.tbData.OnLeft then
                    local tbData = self.tbData.OnLeft(self.tbData.Id)
                    local ui = UI.GetUI('Arms')
                    if ui and tbData then
                        ui:OnOpen(1, tbData.pItem, tbData.rikiState, tbData)
                    end
                end
            end
        )

    BtnAddEvent(self.BtnRight,
        function()
            if self.tbData and self.tbData.OnRight then
                local tbData = self.tbData.OnRight(self.tbData.Id)
                local ui = UI.GetUI('Arms')
                if ui and tbData then
                    ui:OnOpen(1, tbData.pItem, tbData.rikiState, tbData)
                end
            end
        end
    )
end

function tbClass:OnDestruct()
    self:ClearTimer() 
end

function tbClass:OnActive(pWeapon, nForm, tbData)
    self.pWeapon = pWeapon
    self.nForm = nForm
    self.tbData = tbData
    if not self.pWeapon then
        return
    end
    self.Min.OnCheckStateChanged:Add(
        self,
        function(_, bChecked)
            self:UpdatePreviewItem(1)
        end
    )

    self.Max.OnCheckStateChanged:Add(
        self,
        function(_, bChecked)
            self:UpdatePreviewItem(2)
        end
    )

    if not tbData or tbData.nTotal <= 1 then
        WidgetUtils.Collapsed(self.PanelArrow)
    else
        WidgetUtils.Visible(self.PanelArrow)
    end

    --图鉴刷新武器属性
    if self.nForm and self.nForm >= RikiLogic.tbState.Lock then
        self:UpdatePreviewItem(1)
    end
    
    WidgetUtils.Visible(self.CheckMark)
    WidgetUtils.Collapsed(self.CheckMark_1)
    self:ShowDetails()
end

--武器属性切换
function tbClass:UpdatePreviewItem(nType)
    if nType == 1 then --最小
        WidgetUtils.Visible(self.CheckMark)
        WidgetUtils.Collapsed(self.CheckMark_1)

        Item.ChangeItemAttr(self.pWeapon)
    else --最大
        WidgetUtils.Visible(self.CheckMark_1)
        WidgetUtils.Collapsed(self.CheckMark)

        Item.ChangeItemAttr(self.pWeapon, true)
    end


    self:ShowDetails()
end

function tbClass:OnDisable()
     self:ClearTimer()
end

function tbClass:ClearTimer()
    Preview.CancelTimer()
end

---UI数据刷新
function tbClass:ShowDetails()
    if not self.nForm or self.nForm < RikiLogic.tbState.Lock then
        WidgetUtils.Collapsed(self.Story)
        WidgetUtils.Collapsed(self.Preview)
        WidgetUtils.Collapsed(self.PanelLock)
    else
        if self.nForm == RikiLogic.tbState.Lock then
            WidgetUtils.Visible(self.PanelLock)
        else
            WidgetUtils.Collapsed(self.PanelLock)
        end
        WidgetUtils.Visible(self.Story)
        WidgetUtils.Visible(self.Preview)
        
        self.Story:Set(self.pWeapon, self.nForm)
    end

    self.Skill:Set(self.pWeapon, self.nForm)
    self.Detail:Set(self.pWeapon, self.nForm)
    
    ---模型显示
    Weapon.PreviewShow(self.pWeapon)
    Preview.PlayCameraAnimByCallback(self.pWeapon:Id(), PreviewType.weapon, nil)
end


return tbClass
