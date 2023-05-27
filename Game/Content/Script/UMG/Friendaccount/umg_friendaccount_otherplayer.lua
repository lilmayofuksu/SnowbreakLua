-- ========================================================
-- @File    : umg_friendaccount_otherplayer.lua
-- @Brief   : 其他玩家账号信息界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
end

---@param tbPlayerProfile PlayerProfile
function tbClass:OnOpen(tbPlayerProfile)
    if not tbPlayerProfile then
        return
    end
    self.Factory = Model.Use(self)
    self.nPid = tbPlayerProfile.nPid
    self.TxtLV:SetText(tbPlayerProfile.nLevel)
    if tbPlayerProfile.sName == "" then
        self.TxtName:SetText(Text("ui.TxtFriendtab20"))
    else
        self.TxtName:SetText(tbPlayerProfile.sName)
    end
    self.TxtIDNum:SetText(tbPlayerProfile.nPid)
    if tbPlayerProfile.sSign ~= "" then
        self.TxtContent:SetText(tbPlayerProfile.sSign)
    else
        self.TxtContent:SetText(Text("ui.Txtaccountsig"))
    end
    self:ShowItem(tbPlayerProfile.tbShowItems)
    self.TxtTime:SetText(os.date("%Y/%m/%d", tbPlayerProfile.nCreateTime))
    self.TextBlock_1:SetText("/" .. Item.GetCardsNum())
    self.TextBlock:SetText(tbPlayerProfile.tbShowAttrs[1] or 0)
    self:SetPercent((tbPlayerProfile.tbShowAttrs[1] or 0) / Item.GetCardsNum())
    if tbPlayerProfile.tbShowItems[4] then
        self.pTemplate =
            UE4.UItem.FindTemplate(
            tbPlayerProfile.tbShowItems[4].nGenre,
            tbPlayerProfile.tbShowItems[4].nDetail,
            tbPlayerProfile.tbShowItems[4].nParticular,
            tbPlayerProfile.tbShowItems[4].nLevel
        )
    end
    self:SetFace(self.pTemplate)

    ---复制识别码
    BtnAddEvent(
        self.Btncopy,
        function()
            if self.nPid then
                UE4.UUMGLibrary.CopyMessage(self.nPid)
                UI.ShowTip("ui.Txtaccountcopy")
            end
        end
    )
    BtnAddEvent(
        self.BtnReturn,
        function()
            UI.Close(self)
        end
    )
    if self:IsOpenSelf(self.nPid) then
        return
    end

    ---验证是不是黑名单
    BtnClearEvent(self.BtnBlock)
    if Friend.BlacklistCheck(self.nPid) then
        BtnAddEvent(
            self.BtnBlock,
            function()
                Friend.DelBlacklist(
                    self.nPid,
                    function()
                        UI.ShowTip("tip.friend_del_blacklist")
                        UI.Close(self)
                        EventSystem.TriggerTarget(UI.GetUI("Friend"), "FLUSH_PANEL", self.nPid)
                    end
                )
            end
        )
        SetTexture(self.ImageBlockBtnNormal, 2100402)
        self.TxtBlockBtnNormal:SetText(Text("ui.TxtFriendblock2"))
    else
        BtnAddEvent(
            self.BtnBlock,
            function()
                Friend.AddBlacklist(
                    self.nPid,
                    function()
                        UI.ShowTip("tip.friend_ban")
                        UI.Close(self)
                        EventSystem.TriggerTarget(UI.GetUI("Friend"), "FLUSH_PANEL", self.nPid)
                    end
                )
            end
        )
        SetTexture(self.ImageBlockBtnNormal, 2100401)
        self.TxtBlockBtnNormal:SetText(Text("ui.TxtFriendblock1"))
    end

    ---验证是不是好友
    BtnClearEvent(self.BtnAdd)
    if Friend.IsFriend(self.nPid) then
        BtnAddEvent(
            self.BtnAdd,
            function()
                Friend.RemoveFriend(
                    self.nPid,
                    function()
                        UI.ShowTip("tip.friend_Removed")
                        UI.Close(self)
                        EventSystem.TriggerTarget(UI.GetUI("Friend"), "FLUSH_PANEL", self.nPid)
                    end
                )
            end
        )
        SetTexture(self.ImageAddBtnNormal, 2100404)
        self.TxtAddBtnNormal:SetText(Text("ui.TxtFriendDel"))
    else
        BtnAddEvent(
            self.BtnAdd,
            function()
                self:AddFirend()
                UI.Close(self)
            end
        )
        SetTexture(self.ImageAddBtnNormal, 2100403)
        self.TxtAddBtnNormal:SetText(Text("ui.TxtFriendadd"))
    end
end

function tbClass:ShowItem(tbItems)
    self:DoClearListItems(self.LeftList)
    for i = 1, 3 do
        local pObj = self.Factory:Create({ tbItem = tbItems[i] })
        self.LeftList:AddItem(pObj)
    end
end

---拉黑
function tbClass:PullBlack()
    Friend.AddBlacklist(self.nPid)
end
---拉出黑名单
function tbClass:PopBlack()
    Friend.DelBlacklist(self.nPid)
end

---添加好友
function tbClass:AddFirend()
    Friend.SendFriendRequest(
        self.nPid,
        function(nPlayer)
            if nPlayer == self.nPid then
                UI.ShowTip("tip.friend_AddOther")
                EventSystem.TriggerTarget(UI.GetUI("Friend"), "FLUSH_PANEL", self.nPid)
            end
        end
    )
end

---设置头像
------@param pTemplate FItemTemplate 模板
function tbClass:SetFace(pTemplate)
    if pTemplate then
        self.IconGirl:Set(pTemplate.Icon)
    else
        self.IconGirl:Set()
    end
end

--设置角色拥有进度
function tbClass:SetPercent(fLerp)
    local pMaterial = self.Roll:GetDynamicMaterial()
    if pMaterial then
        pMaterial:SetScalarParameterValue("Percent", fLerp)
    end
end

--判断打开的是不是自己
function tbClass:IsOpenSelf(nPID)
    if me:Id() == nPID then
        WidgetUtils.Collapsed(self.BtnBlock)
        WidgetUtils.Collapsed(self.BtnAdd)
        return true
    end
    return false
end

return tbClass
