-- ========================================================
-- @File    : uw_general_props_list_item.lua
-- @Brief   : 通用材料显示
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Btn_reduce.OnClicked:Add(
        self, 
        function() 
            self.Obj:Sub()
            if self.Obj.CurrentNum<1 then
                self:ShowClickState() 
            end 
        end
    )
    self.Btn_reduce.OnLongPressed:Add(self, function(_, _, n)
        local bSuc =  self.Obj:Sub()
        self:ShowClickState(self.Obj.CurrentNum>=1)
         if not bSuc then
             self.BtnClick:StopLongPress()
         end
     end)
    self.BtnClick.OnPressed:Add(self, function() self:SetClickAnim(true)end )
    self.BtnClick.OnReleased:Add(self, function() self:SetClickAnim(false) end)
    self.BtnClick.OnLongPressed:Add(self, function(_, _, n)
       local bSuc =  self.Obj:Add()
        self:ShowClickState(self.Obj.CurrentNum>=1)
        if not bSuc then
            self.BtnClick:StopLongPress()
        end
    end)
    self.BtnClick.OnClicked:Add(
        self,
        function()
            self.Obj:Add()
            if self.Obj.CurrentNum>=1 then
                self:ShowClickState(true)
            end
        end
    )

    self:ShowClickState()
end

function tbClass:OnListItemObjectSet(InObj)
    self.Obj = InObj
    if InObj == nil then
        return
    end
    if not self.bAnim then
        self.TimaHandle = UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                {
                    self,
                    function()
                        WidgetUtils.Visible(self.props)
                        self:PlayAnimation(self.Anim, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
                        self.bAnim = true
                        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self.TimaHandle)
                    end
                },
                self.Obj.delayTime,
                false
            )

    end


    --- 销毁实例时解除点击事件绑定
    EventSystem.Remove(InObj.DataChangeEvent)
    EventSystem.Remove(self.SelectEvent)
    self.SelectEvent = nil
    self.Obj:OnDestruct()

    -- EventSystem.RemoveAllByTarget(InObj)
    self.SelectEvent =
        EventSystem.OnTarget(
        InObj,
        InObj.DataChangeEvent,
        function()
            self:Update()
        end
    )
    -- Dump(self.Obj)
    self:SetClickAnim(false)
    self:Update()

    local function GetGDPL(InItem)
        if not InItem.Type then
            return {
                G = InItem.Genre,
                D = InItem.Detail,
                P = InItem.Particular,
                L = InItem.Level,
                --N = me:GetItemCount(InItem.Genre,InItem.Detail,InItem.Particular,InItem.Level),
                Type = 1}   ---标记为Template
        elseif InItem.Type == 5 then
            return {
                G = InItem:Genre(),
                D = InItem:Detail(),
                P = InItem:Particular(),
                L = InItem:Level(),
                -- N = me:GetItemCount(InItem:Genre(),InItem:Detail(),InItem:Particular(),InItem:Level())
                }
        end
    end

    self.ItemProp:Display(GetGDPL(self.Obj.Item))
    self:ShowClickState(self.Obj.CurrentNum>=1)
end

function tbClass:Update()
    -- local CountDes = self.Obj:GetCurrentNum()..'/'..Item.AboveNum(self.Obj:GetItemNum())
    self.TextNeed:SetText(self.Obj:GetCurrentNum())

    self.TextHave:SetText(Item.AboveNum(self.Obj:GetItemNum()))
    -- self.Sum_Num:SetText(self.Obj:GetItemNum())
    if self.Obj:GetCurrentNum() > self.Obj:GetItemNum() then
        self.TextNeed:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0.854993, 0.06301, 0.035601, 1))
        self.ItemProp:SetRenderOpacity(0.5)
    else
        self.TextNeed:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1.0, 0.558341, 0, 1))
        self.ItemProp:SetRenderOpacity(1.0)
    end
    if self.Image_prop then
        if self.Obj.Item.Type then
            SetTexture(self.Image_prop, self.Obj.Item:Icon())
        else
            SetTexture(self.Image_prop, self.Obj.Item.Icon)
        end
    end
    self:ShowClickState(self.Obj.CurrentNum>=1)
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.SelectEvent)
    EventSystem.Remove(self.Obj.DataChangeEvent)
    EventSystem.RemoveAllByTarget(self.ItemProp)
    self.Obj:OnDestruct()
end

function tbClass:SetClickAnim(InState)
    WidgetUtils.Hidden(self.PanelClick)
    if InState then
        WidgetUtils.SelfHitTestInvisible(self.PanelClick)
    end
end

function tbClass:PlayAnim()
    if not self.Obj.bPlaying then
        WidgetUtils.Visible(self.props)
        self:PlayAnimation(self.Anim, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
        self.Obj.bPlaying = true
    end
end

--- 道具边框
function tbClass:ShowClickState(InState)
    WidgetUtils.Collapsed(self.Selected)
    if InState then
        WidgetUtils.SelfHitTestInvisible(self.Selected)
    end
    self:ShowSubBtnState(InState)
end

--- 选择减少道具交互操作状态
function tbClass:ShowSubBtnState(InState)
    WidgetUtils.Collapsed(self.Btn_reduce)
    if InState then
        WidgetUtils.Visible(self.Btn_reduce)
    end
end
return tbClass
