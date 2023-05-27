-- ========================================================
-- @File    : umg_account.lua
-- @Brief   : 账号界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.nShowCardID = 0
 
    BtnAddEvent(self.Btncopy, function()
            local sStr = me:Id()
            if sStr then
                UE4.UUMGLibrary.CopyMessage(sStr)
                UI.ShowTip("ui.Txtaccountcopy")
            end
        end
    )
    BtnAddEvent( self.BtnEdit,function() UI.Open("Edit", 2, nil,
                function(sTxt)
                    if sTxt == "" then
                        return
                    end
                    UI.ShowConnection()
                    me:ReqResign(sTxt)
                end
            )
        end
    )

    BtnAddEvent(self.BtnEditName,  function() UI.Open("Edit", 1, nil,
                function(sTxt)
                    if sTxt == "" then
                        return
                    end
                    UI.ShowConnection()
                    me:ReqRename(sTxt)
                end
            )
        end
    )

    self.nHandleId = EventSystem.On(Event.Rename, function(nErr)
            if nErr and nErr == 0 then
                UI.ShowTip("tip.rolefiles_changename")
                self:SetNick()
                UI.CloseByName('Edit')
            else
                Audio.PlaySounds(3038)
            end
        end
    )

    self.nSignHandle = EventSystem.On( Event.Sign, function()
            UI.CloseByName('Edit')
            UI.ShowTip("tip.rolefiles_changesig")
            self:SetSign()
        end
    )

    self.nFaceHandle =
        EventSystem.On(
        Event.FaceChanged,
        function()
            self:SetFace()
        end
    )
end

function tbClass:OnOpen()
    self.TxtLV:SetText(string.format("%s", me:Level()))
    self.TxtIDNum:SetText(me:Id())

    local nNum = me:GetCharacterCards():Length()
    local nAll = Item.GetCardsNum()

    self.TextBlock:SetText(nNum)
    self.TextBlock_1:SetText("/" .. nAll)
    self.Progress:SetPercent(nNum / nAll)

    local nExp = me:Exp()
    local nMaxExp = Player.GetMaxExp(me:Level())
    if nMaxExp == 0 then
        local nLastMax = Player.GetMaxExp(me:Level() - 1)
        self.ExpBar:SetPercent(1)
        self.TxtNum:SetText(nLastMax .. "/" .. nLastMax)
    else
        self.ExpBar:SetPercent(nExp / nMaxExp)
        self.TxtNum:SetText(nExp .. "/" .. nMaxExp)
    end

    self.TxtTime:SetText(os.date("%Y/%m/%d", me:CreateTime()))
    self:SetSign()
    self:SetFace()
    self:SetNick()
    self:ShowCharacterCard()

    PreviewScene.Enter(PreviewType.main, function() end)

    self.nShowCardID =  PlayerSetting.GetShowCardID() 
    PreviewMain.LoadCard(self.nShowCardID)
    PreviewMain.LoadBG(function()
        PreviewMain.SetBlurBgVisible(true)
        
        PreviewMain.HideEffect(true)
    end, true)

    if Player.tbSetting and Player.tbSetting['Rename'] ~= 0 then
        WidgetUtils.Collapsed(self.BtnEditName)
        WidgetUtils.Collapsed(self.BtnEdit)
    end

    self.DelayTimer = UE4.Timer.Add(0.5, function()
        self.DelayTimer = nil
        PreviewMain.EnabledBGTick(false)
    end)
end

function tbClass:OnClose()
    if self.DelayTimer then
        UE4.Timer.Cancel(self.DelayTimer)
    end
    EventSystem.Remove(self.nHandleId)
    EventSystem.Remove(self.nSignHandle)
    EventSystem.Remove(self.nFaceHandle)
    PreviewMain.SetBlurBgVisible(false)
    PreviewMain.EnabledBGTick(true)
end

function tbClass:OnDisable()
    UI.CloseByName("Edit")
    PreviewMain.SetBlurBgVisible(false)
end


---显示角色卡
---@param CardItems table 三个角色卡的信息
function tbClass:ShowCharacterCard()
    for i = 1, 3 do
        local pCard = me:GetShowItem(i)
        local param = {nIndex = i, pCard = pCard}
        local pItemWidget = self['Role' .. i]
        if pItemWidget then
            pItemWidget:Set(param)
        end
    end
end

---设置头像
function tbClass:SetFace()
    local pCard = me:GetShowItem(Profile.SHOWITEM_CARD)
    if not pCard then
        pCard = me:GetCharacterCard(PlayerSetting.GetShowCardID())
    end

    if pCard then
        self.IconGirl:Set(pCard:Icon())
    end
end

---设置签名
function tbClass:SetSign()
    if me:Sign() ~= "" then
        self.TxtContent:SetText(me:Sign())
    else
        self.TxtContent:SetText(Text("ui.Txtaccountsig"))
    end
end

---设置昵称
function tbClass:SetNick()
    self.TxtName:SetText(me:Nick())
end

return tbClass
