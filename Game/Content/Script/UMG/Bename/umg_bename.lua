-- ========================================================
-- @File    : umg_bename.lua
-- @Brief   : 文本输入
-- ========================================================
---@class tbClass : ULuaWidget
---@field EditNameTxt UEditableTextBox
local tbClass = Class("UMG.BaseWidget")
function tbClass:OnInit()
    BtnAddEvent(self.BtnConfirm, function()
        local sName = self.EditNameTxt:GetText()
        local bOk, sTip = Player.CheckInputName(sName)
        if bOk == false then
            Audio.PlaySounds(3038)
            UI.ShowTip(sTip)
            return
        end

        UI.ShowConnection()
        me:ReqRename(sName)
    end)

    -- if Login.IsOversea() then
    --     WidgetUtils.Collapsed(self.BtnRandom)
    -- else
    --     WidgetUtils.Visible(self.BtnRandom)
    --     BtnAddEvent(self.BtnRandom, function()
    --         self.EditNameTxt:SetText(Player.RandomName())
    --     end)
    -- end
    WidgetUtils.Collapsed(self.BtnRandom)

    self.nHandleId = EventSystem.On(Event.Rename, function(err)
        UI.CloseConnection()
        if err and err == 0 then
            --打点
            Adjust.DoRecord("dotwcc");
            WidgetUtils.HitTestInvisible(self.BtnConfirm)
            WidgetUtils.HitTestInvisible(self.EditNameTxt)
            if self.Close and self.OpenDoor then
                local fun = function ()
                    self:BindToAnimationFinished(self.OpenDoor, {self, function()
                        self:UnbindAllFromAnimationFinished(self.OpenDoor)
                        UI.Close("Bename")
                    end})
                    self:PlayAnimation(self.OpenDoor)
                end
                self:BindToAnimationFinished(self.Close, {self, function()
                    self:UnbindAllFromAnimationFinished(self.Close)
                    if self.fCallback then
                        self.fCallback()
                    end
                    fun()
                end})
                self:PlayAnimation(self.Close)
            else
                UI.Close(self, self.fCallback)
            end
        else
            --打点
            Adjust.DoRecord("kjpye0");
            Audio.PlaySounds(3038)
        end
    end)
end

function tbClass:OnOpen(fCallback)
    self.fCallback = fCallback
    self.TxtIntro1:SetText(Text("TxtOriginalTips1"))
    self.TxtIntro2:SetText(Text("TxtOriginalTips2"))
    self.EditNameTxt:SetHintText(Text("ui.TxtNameInput"))
    self.EditNameTxt:SetMaxInputNum(Player.GetMaxNameNum())
    if Login.IsOversea() then
        self.EditNameTxt.bCanInputSpace = true
    end
    WidgetUtils.ShowMouseCursor(self, true)
    --打点
    Adjust.DoRecord("i9s28k");

    if self.DelayEndHandle then
        UE4.Timer.Cancel(self.DelayEndHandle)
    end
    self.DelayEndHandle = nil
    if self.DelayStartHandle then
        UE4.Timer.Cancel(self.DelayStartHandle)
    end
    self.DelayStartHandle = UE4.Timer.Add(self.DelayStart or 1, function()
        self.DelayStartHandle = nil
        --提示文本滚动位置
        self.fOffsetNow = 0
    end)
end

---取名屏蔽ESC
function tbClass:CanEsc()
    return false
end

function tbClass:OnClose()
    EventSystem.Remove(self.nHandleId)

    if self.DelayEndHandle then
        UE4.Timer.Cancel(self.DelayEndHandle)
    end
    if self.DelayStartHandle then
        UE4.Timer.Cancel(self.DelayStartHandle)
    end
    self.DelayEndHandle = nil
    self.DelayStartHandle = nil
end

---刷新文字滚动
function tbClass:UpdateTextScrollOffset(InDeltaTime)
    if not self.fOffsetNow then
        return
    end
    local fend = self.PanelScorll:GetScrollOffsetOfEnd()
    if fend == 0 or self.fOffsetNow >= fend then
        return
    end

    if not self.ScrollSpeed then
        self.ScrollSpeed = 20
    end
    self.fOffsetNow = self.fOffsetNow + (self.ScrollSpeed*InDeltaTime)
    if self.fOffsetNow >= fend then
        self.PanelScorll:SetScrollOffset(fend)
        self.fOffsetNow = nil
        self.DelayEndHandle = UE4.Timer.Add(self.DelayEnd or 1, function()
            self.DelayEndHandle = nil
            self.PanelScorll:SetScrollOffset(0)
            self.DelayStartHandle = UE4.Timer.Add(self.DelayStart or 1, function()
                self.DelayStartHandle = nil
                self.fOffsetNow = 0
            end)
        end)
    else
        self.PanelScorll:SetScrollOffset(self.fOffsetNow)
    end
end

function tbClass:Tick(MyGeometry, InDeltaTime)
    self:UpdateTextScrollOffset(InDeltaTime)
end

return tbClass
