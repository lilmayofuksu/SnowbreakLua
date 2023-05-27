-- ========================================================
-- @File    : umg_common_onlineinvite.lua
-- @Brief   : 联机邀请
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnNo, function()
        self:ShowNext()
    end)

    BtnAddEvent(self.BtnYes, function()
        if self.funcMatch then
            self:ShowNext()
            self.funcMatch()
        elseif self.tbInfo and self.tbInfo[3] and self.tbInfo[4] then
            Online.AcceptInvite(self.tbInfo[4], self.tbInfo[3])
        end
    end)
end

---打开
---@param tbParam table   {邀请者名字，其他信息(TArray<uint64> 顺序:房间id,玩法id,角色id,头像,头像框)}
---@param bSpe 当关闭抽奖结果打开抽奖主界面的时候，特殊处理
---@param funcMatch 提示匹配
function tbClass:OnOpen(tbParam, bSpe, funcMatch)
    if tbParam then
        Online.AddNewInfo(tbParam)
    end
    
    if not bSpe and self:CheckForClose() then
        return
    end

    if funcMatch then
        self.tbInfo = Online.GetCurInviteInfo()
        if not self.tbInfo then
            self.funcMatch = funcMatch
            WidgetUtils.Collapsed(self.PanelInvite)
            WidgetUtils.SelfHitTestInvisible(self.PanelRematch)
            self.nLeft = 10
            self:ShowMatchTip()
            return
        end
    end

    WidgetUtils.Collapsed(self.PanelRematch)
    WidgetUtils.SelfHitTestInvisible(self.PanelInvite)

    --提前检查一下 时间
    if self:GetCurShowInfo() then
        return
    end

    self:ShowMain()
end

--获取当前显示
function tbClass:GetCurShowInfo()
    self.tbInfo = Online.GetCurInviteInfo()
    if not self.tbInfo then
        UI.Close(self)
        return true
    end

    self.nLeft  =  30
   if self.tbInfo[8]  then
        self.nLeft = self.tbInfo[8] - GetTime()
        if self.nLeft < 0 then
            Online.DoNextInviteInfo()
        end
    end
end

function tbClass:OnClose()
    self.nLeft = 0
    self.detime = 1
    self.tbInfo = nil
end

---显示
function tbClass:ShowMain()
     if self:GetCurShowInfo() then
        return
    end
    
    if not self.tbInfo then
        UI.Close(self)
        return
    end

   local tbOnline = Online.GetConfig(self.tbInfo[3])
   if tbOnline and tbOnline.sName then
        self.TxtEvent:SetText(Text(tbOnline.sName))
   end

    self.TxtName:SetText(self.tbInfo[1] or "")
    self.TextLvNum:SetText(self.tbInfo[7] or "")

    local nFace = 0
    local nFrame = 0
    local pTemp = nil
    if self.tbInfo[5] and self.tbInfo[5] > 0 then 
        pTemp = UE4.UItem.FindTemplateForID(self.tbInfo[5])
    else
        pTemp = UE4.UItem.FindTemplate(1, 2, 1, 1)
    end
    if pTemp and pTemp.Icon and pTemp.Icon > 0 then
        nFace = pTemp.Icon
    end

    if self.tbInfo[6] and self.tbInfo[6] > 0 then
        nFrame = self.tbInfo[6]
    end
    self.Portrait:OnOpen(nFace, nFrame)

   self:ShowTimer()
end

function tbClass:ShowTimer()
    if self.nLeft < 0 then
        self.nLeft = 0
    end

    self.TxtSecond:SetText(self.nLeft)

    local nLen = 1
    if Online.tbReceiveInviteList then
        nLen = #Online.tbReceiveInviteList
    end
    self.TxtNum:SetText(string.format(Text("ui.TxtInvite"), nLen))
end

function tbClass:Tick(MyGeometry, InDeltaTime)
    if not self.detime then self.detime = 0 end

    self.detime = self.detime + InDeltaTime
    if self.detime < 1 then return end

    self.nLeft = self.nLeft - 1
    self.detime = 0

    if self.funcMatch then
        self:ShowMatchTip()
        return
    end

    self:ShowTimer()

    if self.nLeft <= 0 then
        self:ShowNext()
    end

    self:CheckForClose()
end

function tbClass:ShowNext()
    Online.DoNextInviteInfo()
    self:ShowMain()
end

--外面关闭
function tbClass:ClearAndClose()
    self.nLeft = 0
    self.detime = 1
end

--检查某些界面关闭
function tbClass:CheckForClose()
    local tbList = {
        "GaChaTap", "GachaResult", 
    }

    for i,v in ipairs(tbList) do
        local sUI = UI.GetUI(v)
        if sUI then
            UI.Close(self)
            return true
        end
    end
end


-------显示匹配提示
function tbClass:ShowMatchTip()
    local tbInfo = Online.GetCurInviteInfo()
    if tbInfo then
        self.funcMatch = nil
        WidgetUtils.Collapsed(self.PanelRematch)
        WidgetUtils.SelfHitTestInvisible(self.PanelInvite)

        if self:GetCurShowInfo() then
            return
        end
        self:ShowMain()
        return
    end

    if self.nLeft <= 0 then
        UI.Close(self)
        return
    end

    self.TxtSecond:SetText(self.nLeft)
end

--关闭匹配提示
function tbClass:CloseMatchTip()
    local tbInfo = Online.GetCurInviteInfo()
    if tbInfo then
        return
    end

    if self.funcMatch then
        self.nLeft = 0
        UI.Close(self)
    end
end

return tbClass
