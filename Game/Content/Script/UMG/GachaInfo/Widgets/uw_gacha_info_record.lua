-- ========================================================
-- @File    : uw_gacha_inforecord.lua
-- @Brief   : 抽奖记录展示
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)
    self.nPageSize = 10
    self.nCurPage = 1
    self:DoClearListItems(self.ListRecord)

    BtnAddEvent(self.BtnLeft, function()
            if self.nCurPage > 1 then
                self:SetPage(self.nCurPage - 1)
            end
        end
    )

    BtnAddEvent( self.BtnRight, function()
            if self.nCurPage < #self.Pages then
                self:SetPage(self.nCurPage + 1)
            end
        end
    )

    self.nRspHandle =  EventSystem.On(Event.GetRecord, function(pTArrayRecords)
        if UI.IsOpen('GachaInfo') then
            print('gacha get record :', pTArrayRecords:Length())
            local tbRecords = {}
            for i = 1, pTArrayRecords:Length() do
                table.insert(tbRecords, json.decode(pTArrayRecords:Get(i)))
            end
            self:OnRsp(tbRecords)
        end
    end
)
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nRspHandle)
end

function tbClass:OnActive(nId)
    local tbID = Gacha.GetRecordIDs(nId) or {}

    self.ReqIndex = 0
    self.nAllReqNum = #tbID
    self.tbReqID = tbID
    self.tbRecive = {}
    self:NextReq()
    UI.ShowConnection()
end

function tbClass:NextReq()
    self.ReqIndex = self.ReqIndex + 1
    if self.ReqIndex <= self.nAllReqNum then
        me:GetRecord(string.format(Gacha.RecordField, self.tbReqID[self.ReqIndex]))
    else
        self:FinishRecive()
        UI.CloseConnection()
    end
end

function tbClass:FinishRecive()
    table.sort(self.tbRecive, function(a, b)
        if a.nTime ~= b.nTime then
            return a.nTime > b.nTime 
        end
        local aO = a.nOrder or 0
        local bO = b.nOrder or 0
        return aO > bO
    end)

    self.Pages = {}

    local nNowTime = GetTime()
    local nDis = 86400 * 91 ---超过90天 不显示

    for i, tbRecord in ipairs(self.tbRecive) do
        if i > 200 or (nNowTime - tbRecord.nTime > nDis) then
            break
        end

        if i % self.nPageSize == 1 then
            table.insert(self.Pages, {})
        end
        table.insert(self.Pages[(i - 1) // self.nPageSize + 1], tbRecord)
    end
    if #self.Pages == 0 then
        table.insert(self.Pages, {})
    end
    self:SetPage(1)
end

function tbClass:OnRsp(tbRecords)
    self.tbRecive = self.tbRecive or {}
    for _, v in ipairs(tbRecords or {}) do
        table.insert(self.tbRecive, v)
    end
    self:NextReq()
end

function tbClass:SetPage(nIndex)
    self:DoClearListItems(self.ListRecord)
    for _, pObj in ipairs(self.Pages[nIndex]) do
        local pCreate = self.Factory:Create(pObj)
        self.ListRecord:AddItem(pCreate)
    end
    self.nCurPage = nIndex
    self.TxtPageNum:SetText(string.format("%d", nIndex))
end

return tbClass
