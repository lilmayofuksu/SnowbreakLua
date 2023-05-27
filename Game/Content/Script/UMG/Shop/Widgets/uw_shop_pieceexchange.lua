-- ========================================================
-- @File    : uw_shop_pieceexchage.lua
-- @Brief   : 角色碎片兑换界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()

end

function tbClass:OnInit()
    self.Factory = Model.Use(self)

    BtnAddEvent(
        self.BtnNo,
        function()
            UI.Close(self)
        end
    )

    BtnAddEvent(
        self.BtnOK,
        function()
            local tbParam = {}
            for _,pObj in pairs(self.tbConvertObjs or {}) do
                -- if pObj.Data.bSelected then
                local tbItem = pObj.Data
                local sPieceGDPLN = string.format('%s-%s-%s-%s-%s', tbItem.G,tbItem.D,tbItem.P,tbItem.L,tbItem.N);
                table.insert(tbParam,{sGirlGDPL = pObj.Data.sGirlGDPL,sPieceGDPLN = sPieceGDPLN})
                -- end
            end
            if next(tbParam) == nil then
                return UI.ShowTip("tip.PieceExchange_none")
            end

            if self.bPieceFull == true then
                return UI.ShowTip("tip.PieceExchange_Full")
            end

            me:CallGS("ShopLogic_ConvertGirlPieces", json.encode(tbParam))
            UI.Close(self)
        end
    )

end

function tbClass:PreOpen()

    return true
end

function tbClass:OnOpen()
    -- UI.Close(self)
    self:DoClearListItems(self.Costtems)
    -- self.tbExchangeList = {}
    --遍历所有角色卡，查看是否满天启
    local allCard = UE4.TArray(UE4.UCharacterCard)
    
    local tbConvertItems = {}

    me:GetCharacterCards(allCard)
    for i = 1, allCard:Length() do
        local pCard = allCard:Get(i)
        --满天启的获取其配置，找到碎片id
        if RBreak.IsLimit(pCard) then
            local tbP = pCard:PiecesGDPLN()
            if not tbConvertItems[pCard:Color()] then
                tbConvertItems[pCard:Color()] = {}
            end
            local sGirlGDPL = string.format('%s-%s-%s-%s', pCard:Genre(),pCard:Detail(),pCard:Particular(),pCard:Level());
            table.insert(tbConvertItems[pCard:Color()],{tbGDPL = {tbP:Get(1),tbP:Get(2),tbP:Get(3),tbP:Get(4)},sGirlGDPL = sGirlGDPL})
        end
    end

    self.tbConvertObjs = {}
    self.bPieceFull = false
    --生成碎片道具，加入list
    for i = 5,1,-1 do
        for _,tbGDPL in pairs(tbConvertItems[i] or {}) do
            local pObj = self:GenItemObj(tbGDPL)
            if pObj then
                table.insert(self.tbConvertObjs,pObj)
            end
        end

        table.sort(self.tbConvertObjs, function (l, r) return l.Data.N > r.Data.N; end);
    end
    
    --根据选择的碎片道具，生成兑换道具种类数量，并显示
    self:UpdateConvertItem()
end

function tbClass:OnClose()
    self:DoClearListItems(self.Costtems)
    self.tbConvertObjs = {}
end

function tbClass:UpdateConvertItem()
    self:DoClearListItems(self.Costtems)
    local tbColorList = {}
    for _,pObj in pairs(self.tbConvertObjs or {}) do
        self.Costtems:AddItem(pObj)
            tbColorList[pObj.Data.pTemp.Color] = (tbColorList[pObj.Data.pTemp.Color] or 0) + pObj.Data.N
    end
    -- Dump(tbColorList)
    self:ShowDefaultConvertItem()

    local tbGetItems = {}
    for nColor,num in pairs(tbColorList) do
        for _,tbGetItem in pairs(Item.tbPiecesConvert[nColor].tbItem or {}) do
            local sGDPL = string.format('%s-%s-%s-%s', tbGetItem[1], tbGetItem[2], tbGetItem[3], tbGetItem[4]);
            if tbGetItems[sGDPL] then
                tbGetItems[sGDPL][5] = tbGetItems[sGDPL][5] + tbGetItem[5] * num
            else
                tbGetItems[sGDPL] = {tbGetItem[1], tbGetItem[2], tbGetItem[3], tbGetItem[4],tbGetItem[5] * num}
            end
        end
    end

    for _,tbItem in pairs (tbGetItems or {}) do
        local iteminfo = UE4.UItem.FindTemplate(tbItem[1], tbItem[2], tbItem[3], tbItem[4])

        if iteminfo.Color == 5 then
            SetTexture(self.Icon1, iteminfo.Icon)
            self.TxtNum1:Settext("X"..tbItem[5])
            self.TxtName1:Settext(Text(iteminfo.I18N))
        elseif iteminfo.Color == 4 then
            SetTexture(self.Icon2, iteminfo.Icon)
            self.TxtNum2:Settext("X"..tbItem[5])
            self.TxtName2:Settext(Text(iteminfo.I18N))
        end

        if me:GetItemCount(tbItem[1], tbItem[2], tbItem[3], tbItem[4]) + tbItem[5] >= Item.MaxItemCount then
            self.bPieceFull = true
        end
    end
end

function tbClass:ShowDefaultConvertItem()
    for _,tbConvert in pairs(Item.tbPiecesConvert or {}) do
        for k,tbItem in pairs(tbConvert.tbItem or {}) do
            local iteminfo = UE4.UItem.FindTemplate(tbItem[1], tbItem[2], tbItem[3], tbItem[4])
            if iteminfo.Color == 5 then
                SetTexture(self.Icon1, iteminfo.Icon)
                self.TxtNum1:Settext("X0")
                self.TxtName1:Settext(Text(iteminfo.I18N))
            elseif iteminfo.Color == 4 then
                SetTexture(self.Icon2, iteminfo.Icon)
                self.TxtNum2:Settext("X0")
                self.TxtName2:Settext(Text(iteminfo.I18N))
            end
        end
    end
end

function tbClass:GenItemObj(tbGDPL)
    if me:GetItemCount(table.unpack(tbGDPL.tbGDPL)) <=0 then
        return nil
    end

    local tbBox = {
        G = tbGDPL.tbGDPL[1],
        D = tbGDPL.tbGDPL[2],
        P = tbGDPL.tbGDPL[3],
        L = tbGDPL.tbGDPL[4],
        N = me:GetItemCount(table.unpack(tbGDPL.tbGDPL)),
        sGirlGDPL = tbGDPL.sGirlGDPL,
        -- bForceShowNum = true,
        pTemp = UE4.UItem.FindTemplate(tbGDPL.tbGDPL[1], tbGDPL.tbGDPL[2], tbGDPL.tbGDPL[3], tbGDPL.tbGDPL[4]),
        bSelected = false,
        -- fCustomEvent = function()
        --     self:UpdateExchangeList(tbGDPL.tbGDPL)
        -- end
    }

    return self.Factory:Create(tbBox)
end

return tbClass;