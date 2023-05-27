-- ========================================================
-- @File    : uw_widgets_item.lua
-- @Brief   : 通用道具
-- ========================================================
local tbClass = Class("UMG.SubWidget")


function tbClass:GetItemColor()
    local nColor = 3
    if not self.tbParam then return nColor  end

    if self.tbParam.nCashType then
        local tbInfo = Cash.GetMoneyCfgInfo(self.tbParam.nCashType)
        if tbInfo then
            nColor = tbInfo.nColor
        end
    else
        local pItemTemplate = UE4.UItemLibrary.GetItemTemplateByGDPL(self.tbParam.G,self.tbParam.D,self.tbParam.P,self.tbParam.L)
        if pItemTemplate then
            nColor = pItemTemplate.Color
        end
    end

    return nColor
end


function tbClass:CustListPlayAnim()
    local nColor = self:GetItemColor()

    if nColor == 4 then
        self:PlayAnimation(self.Purple)
        self:UnbindAllFromAnimationFinished(self.Purple)
        self:BindToAnimationFinished(self.Purple, {self, function()
            self:PlayAnimation(self.Purpleloop, 0, 0)
        end})

    elseif nColor == 5 then
        self:PlayAnimation(self.Golden)
        self:UnbindAllFromAnimationFinished(self.Golden)
        self:BindToAnimationFinished(self.Golden, {self, function()
            self:PlayAnimation(self.Goldenloop, 0, 0)
        end})
    else
        self:PlayAnimation(self.Enter)
    end
end

function tbClass:CustListQuickPlayAnim()
    local nColor = self:GetItemColor()
    if nColor == 4 then
        self:UnbindAllFromAnimationFinished(self.Purple)
        
        if self:IsAnimationPlaying(self.Purple) then
            self:PlayAnimation(self.Purple, self:GetAnimationCurrentTime(self.Purple), 1, UE4.EUMGSequencePlayMode.Forward, 10)
        end
        self:PlayAnimation(self.Purpleloop, 0, 0)
    elseif nColor == 5 then
        self:UnbindAllFromAnimationFinished(self.Golden)
        if self:IsAnimationPlaying(self.Golden) then
            self:PlayAnimation(self.Golden, self:GetAnimationCurrentTime(self.Golden), 1, UE4.EUMGSequencePlayMode.Forward, 10)
        end
        self:PlayAnimation(self.Goldenloop, 0, 0)
    else
        self:PlayAnimationForward(self.Enter, 10, false)
    end
end


function tbClass:Construct()
    WidgetUtils.Collapsed(self.PanelPiece)
    WidgetUtils.Collapsed(self.PanelLv)
    WidgetUtils.Collapsed(self.PanelNum)
    WidgetUtils.Collapsed(self.BtnInfoSP)

    BtnAddEvent(
        self.BtnClick,
        function()
            if self.fCustomEvent then
                self.fCustomEvent(self)
                return
            end
            self:DefaultClick()
        end
    )
    BtnAddEvent(
    self.BtnInfoSP,
    function()
        self:DefaultClick()
    end
    )

    self.nItemListNumChangeEvent =
        EventSystem.On(
        Event.ShowItemNumChange,
        function(nTimes)
            -- self.tbParam.Count = nil
            if not self.tbParam then
                --debug
                print(string.format("Lua error message:\n uw_widgets_item tbParam nil %s\n ",debug.traceback()))
                return
            end

            if not self.tbParam.Count then
                --debug
                print(string.format("Lua error message:\n uw_widgets_item tbParam错误 \n tbParam.GDPLN:%s\n %s", 
                    self.tbParam.G..self.tbParam.D..self.tbParam.P..self.tbParam.L..self.tbParam.N ,debug.traceback()))
                return
            end
            local newNum = self.tbParam.Count * nTimes
            WidgetUtils.Collapsed(self.PanelNum)
            if newNum > 1 then
                WidgetUtils.HitTestInvisible(self.PanelNum)
            end
            self.TxtNumber:SetText(Item.ConvertNum(newNum))
        end,
        false
    )

end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nSelectEvent or 0)
    EventSystem.Remove(self.nItemListNumChangeEvent)
end

--[[
  tbParam table  { g,d,p,l,n }
]]
---展示详情
---@param tbParam table
function tbClass:Display(tbParam)
    ---自定义事件
    self.fCustomEvent = tbParam.fCustomEvent

    if tbParam.nCashType then
        return self:DisplayCash(tbParam)
    end

    local pItemTemplate = UE4.UItemLibrary.GetItemTemplateByGDPL(tbParam.G,tbParam.D,tbParam.P,tbParam.L)
    self:OnShowQuality(pItemTemplate.Color)
    self.tbParam = tbParam
    if tbParam.bIsFirst then
        WidgetUtils.HitTestInvisible(self.PanelFirstPass)
    else
        WidgetUtils.Hidden(self.PanelFirstPass)
    end

    self:SignIconTag(true)
    -- 是否添加标签()
    if tbParam.bTag and tbParam.bTag == 1 then
        self:SetGeted(true)
        self:SignIconTag(false)
    else
        -- 刷新获得图标
        self:SetGeted(tbParam.bGeted)
    end

    if not tbParam.bTag then
        self:SignIconTag(false)
    end

    self:OnData(tbParam.nData, tbParam.bNoLimit)

    self:SetNum(tbParam)

    self:ShowLv(tbParam)

    self:SetTexture(self.tbParam)

    self:Selected()

    self:OnLock(self.tbParam.bLock)

    ---碎片标记
    if self.tbParam.G == 5 and self.tbParam.D == 4 then
        WidgetUtils.SelfHitTestInvisible(self.PanelPiece)
        local PieceId =  UE4.UItem.FindTemplate(tbParam.G, tbParam.D, tbParam.P, tbParam.L).EXIcon
        SetTexture(self.ImgPiece, PieceId)
    else
        WidgetUtils.Collapsed(self.PanelPiece)
    end

    self:DisplayPanelTitle(self.tbParam.dropType)

    if self.tbParam.bInfoSP then
        WidgetUtils.Visible(self.BtnInfoSP)
    end
    --当前显示的时候，外围有更新需求
    if self.tbParam.DoUpdate then
        self.tbParam.DoUpdate(self)
    end

    if self.tbParam.tbDorm then
        self:DisplayDormInfo(self.tbParam.tbDorm)
    end

    self:DoUpdatePanelNerve()
end

---显示角标类型
function tbClass:DisplayPanelTitle(dropType)
    WidgetUtils.Collapsed(self.PanelTitle)
    WidgetUtils.Collapsed(self.ImgNum1)
    WidgetUtils.Collapsed(self.ImgNum2)
    WidgetUtils.Collapsed(self.ImgNum3)
    if dropType == Launch.nDropType.FirstDrop then
        -- self.TxtTitle:SetText(Text("activity.signed"))
        self.TxtTitle:SetText(Text("activity.firstDrop"))
        WidgetUtils.Visible(self.PanelTitle)
        WidgetUtils.Visible(self.ImgNum1)
    elseif dropType == Launch.nDropType.RandomDrop then
        self.TxtTitle:SetText(Text("activity.randomDrop"))
        WidgetUtils.Visible(self.PanelTitle)
        WidgetUtils.Visible(self.ImgNum2)
    elseif dropType == Launch.nDropType.SpecialDrop then
        self.TxtTitle:SetText(Text("activity.specialDrop"))
        WidgetUtils.Visible(self.PanelTitle)
        WidgetUtils.Visible(self.ImgNum3)
    elseif dropType == Launch.nDropType.ExtraBaseDrop then
        self.TxtTitle:SetText(Text("activity.extraDrop"))
        WidgetUtils.Visible(self.PanelTitle)
        WidgetUtils.Visible(self.ImgNum1)
    elseif dropType == Launch.nDropType.ExtraRandomDrop then
        self.TxtTitle:SetText(Text("activity.extraDrop"))
        WidgetUtils.Visible(self.PanelTitle)
        WidgetUtils.Visible(self.ImgNum1)
    end
end

---显示货币
function tbClass:DisplayCash(tbParam)
    WidgetUtils.Collapsed(self.PanelSelect1)
    WidgetUtils.Collapsed(self.PanelPiece)
    WidgetUtils.Collapsed(self.PanelNeed)
    WidgetUtils.Collapsed(self.PanelGet)
    WidgetUtils.Collapsed(self.PanelFirstPass)

    WidgetUtils.Visible(self.ItemPanel)
    WidgetUtils.Visible(self.ImgLv)
    WidgetUtils.Visible(self.ImgIcon)
    if tbParam.nNum and tbParam.nNum > 0 then
        WidgetUtils.HitTestInvisible(self.PanelNum)
        self.TxtNumber:SetText(tostring(tbParam.nNum))
    else
        WidgetUtils.Collapsed(self.PanelNum)
    end
    local tbInfo = Cash.GetMoneyCfgInfo(tbParam.nCashType)
    SetTexture(self.ImgIcon, tbInfo.nIcon)
    SetTexture(self.ImgLv, Item.ItemIconColorIcon[tbInfo.nColor])

    self.tbParam = tbParam

    if self.tbParam then
        self:Selected()
    end
    if self.tbParam and self.tbParam.bInfoSP then
        WidgetUtils.Visible(self.BtnInfoSP)
    end
    -- self.tbParam = tbParam
end

function tbClass:OnListItemObjectSet(InObj)
    if (not InObj) or (not InObj.Data) then
        return
    end

    EventSystem.Remove(self.nSelectEvent)


    if InObj.Data.G == 0 then
        WidgetUtils.Collapsed(self.PanelItem)
        WidgetUtils.Collapsed(self.BtnClick)
        WidgetUtils.Visible(self.PanelEmpty)
        return
    end

    if InObj.Data.nCashType then
        WidgetUtils.Visible(self.PanelItem)
        WidgetUtils.Visible(self.BtnClick)
        WidgetUtils.Collapsed(self.PanelEmpty)
        return self:DisplayCash(InObj.Data)
    end

    WidgetUtils.Collapsed(self.PanelEmpty)
    WidgetUtils.Visible(self.PanelItem)
    WidgetUtils.Visible(self.BtnClick)

    self.nSelectEvent =
        EventSystem.OnTarget(
        InObj.Data,
        "SET_SELECTED",
        function()
            self:Selected()
        end
    )

    self.tbParam = InObj.Data
    self:Display(self.tbParam)
end

---数量显示
function tbClass:SetNum(tbParam)
    tbParam = tbParam or self.tbParam
    WidgetUtils.Collapsed(self.PanelSelect1)
    local Num = tbParam.N or 0
    if type(Num) == "number" then
        WidgetUtils.Collapsed(self.PanelNeed)
        WidgetUtils.Collapsed(self.ImgAdd)

        if Num > 1 or tbParam.bForceShowNum then
            WidgetUtils.HitTestInvisible(self.PanelNum)
            if self.TxtNumber then 
                self.TxtNumber:SetText(Item.ConvertNum(Num))
            end
        else
            WidgetUtils.Collapsed(self.PanelNum)
        end

        if tbParam.Type then
            self.PanelPiece:SetRenderOpacity(0.5)
            self.ImgIcon:SetRenderOpacity(0.5)
        end
        self.nShowNum = Num
    elseif type(Num) == "table" then
        --[[
            {   nHaveNum = 0, 拥有数量
                nNeedNum = nil, 需要数量
                nSelectNum = nil 选择数量
            } 
        ]]
        local n1 , n2 = 0, 0
        if Num.nSelectNum then
            n1 = Num.nHaveNum or 0
            n2 = Num.nSelectNum
            WidgetUtils.Collapsed(self.ImgAdd)
        elseif Num.nNeedNum then
            n1 = Num.nHaveNum or 0
            n2 = Num.nNeedNum
            if n1 < n2 then
                WidgetUtils.SelfHitTestInvisible(self.ImgAdd)
                self.fCustomEvent = function()
                    self:DefaultClick()
                    --UI.Open("DropWay", self.tbParam.G, self.tbParam.D, self.tbParam.P, self.tbParam.L)
                end
            else
                WidgetUtils.Collapsed(self.ImgAdd)
            end
        end

        if n1 < n2 then
            self.TxtNumberNeed:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0.854993, 0.06301, 0.035601, 1))
            self.PanelPiece:SetRenderOpacity(0.5)
            self.ImgIcon:SetRenderOpacity(0.5)
        else
            self.TxtNumberNeed:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1.0, 0.558341, 0, 1))
            self.PanelPiece:SetRenderOpacity(1)
            self.ImgIcon:SetRenderOpacity(1)
        end

        self.nShowNum = n2

        self.TxtNumberHas:SetText(Item.AboveNum(n1))
        self.TxtNumberNeed:SetText(Item.ConvertNum(n2))
        if tbParam.CanStack == false then
            WidgetUtils.Collapsed(self.PanelNum)
            WidgetUtils.Collapsed(self.PanelNeedNum)
        else
            WidgetUtils.HitTestInvisible(self.PanelNeed)
            WidgetUtils.HitTestInvisible(self.PanelNeedNum)
        end
        WidgetUtils.Collapsed(self.PanelNum)
        if tbParam.bDetail then
            WidgetUtils.Collapsed(self.PanelNeed)
        end
    end

    if not tbParam.N then
        WidgetUtils.Collapsed(self.PanelNeed)
        WidgetUtils.Collapsed(self.PanelNum)
        WidgetUtils.Collapsed(self.PanelNeedNum)
    end
end

function tbClass:ShowLv(InParam)
    local CanStack = UE4.UItem.FindTemplate(InParam.G, InParam.D, InParam.P, InParam.L).CanStack
    if CanStack > 0 then
        WidgetUtils.Collapsed(self.PanelLv)
    else
        if InParam.pitem then
            WidgetUtils.HitTestInvisible(self.PanelLv)
            self.TextCurrLv:SetText(InParam.pitem:EnhanceLevel())
        end
    end
end

function tbClass:SetTag()
    self.SignTag:SetText(Text("activity.signed"))
end

function tbClass:SetGeted(bGet)
    if bGet then
        WidgetUtils.HitTestInvisible(self.PanelGet)
    else
        WidgetUtils.Collapsed(self.PanelGet)
    end
end

--- 设置被选中的数量
---@param nCount integer 被选中的数量为0或nil则不显示选中效果
function tbClass:SetSelectedCount(nCount)
    if nCount and nCount > 0 then
        WidgetUtils.HitTestInvisible(self.PanelSelectCount)
        self.TxtSelectNum:SetText(nCount)
    else
        WidgetUtils.Collapsed(self.PanelSelectCount)
    end
end

function tbClass:OnData(InData, bNoLimit)
    if not InData then
        WidgetUtils.Collapsed(self.Day)
        return
    end

    if bNoLimit then
        WidgetUtils.SelfHitTestInvisible(self.Day)
        self.SignData:SetText(InData)
    elseif InData >= 1 and InData <= 31 then
        WidgetUtils.SelfHitTestInvisible(self.Day)
        self.SignData:SetText(InData)
    else
        WidgetUtils.Collapsed(self.Day)
    end
end

--- 签到图标tag
function tbClass:SignIconTag(InTag)
    if InTag then
        WidgetUtils.HitTestInvisible(self.ImgTag)
    else
        WidgetUtils.Hidden(self.ImgTag)
    end
end

---没有传入自定义点击事件 则用默认事件
function tbClass:DefaultClick()
    if not self.tbParam then return end
    if self.tbParam.nCashType then
        local tbInfo = Cash.GetMoneyCfgInfo(self.tbParam.nCashType)
        if tbInfo.tbItem then
            UI.Open("ItemInfo", tbInfo.tbItem[1], tbInfo.tbItem[2], tbInfo.tbItem[3], tbInfo.tbItem[4], self.nShowNum or 1, self.tbParam.pItem)
        end
        return
    end

    UI.Open("ItemInfo", self.tbParam.G, self.tbParam.D, self.tbParam.P, self.tbParam.L, self.nShowNum or 1, self.tbParam.pItem)
end

function tbClass:SetTypeIcon(nG, nD, bSign)
    WidgetUtils.Collapsed(self.ImgWeapon)
    WidgetUtils.Collapsed(self.ImgSupport)
    if bSign then
        return
    end

    if nG == 2 then
        WidgetUtils.HitTestInvisible(self.ImgWeapon)
        SetTexture(self.ImgWeapon, Item.WeaponTypeIcon[nD])
    end

    if nG == 3 then
        WidgetUtils.HitTestInvisible(self.ImgSupport)
        SetTexture(self.ImgSupport, Item.SupportTypeIcon[nD])
    end
end

function tbClass:SetTexture(tbParam)
    if tbParam.Item then
        if tbParam.nForceIcon then
            SetTexture(self.ImgIcon, tbParam.nForceIcon)
        else
            local path = tbParam.Item:Icon()
            SetTexture(self.ImgIcon, path)
        end
        
        SetTexture(self.ImgLv, Item.ItemIconColorIcon[tbParam.Item:Color()])
        self:SetTypeIcon(tbParam.Item:Genre(), tbParam.Item:Detail(), tbParam.bSign)
        return
    end
    local pTemplate = UE4.UItem.FindTemplate(tbParam.G, tbParam.D, tbParam.P, tbParam.L)
    if pTemplate then
        if tbParam.nForceIcon then
            SetTexture(self.ImgIcon, tbParam.nForceIcon)
        else
            local path = nil
            if tbParam.G == 1 or tbParam.G == 2  then
                path = pTemplate.Icon
            elseif tbParam.G == 3 then
                if tbParam.ShowBreakImg then
                    path = pTemplate.Icon
                else
                    path = pTemplate.Icon
                end
            else
                path = pTemplate.Icon
            end
            WidgetUtils.SetVisibleOrCollapsed(self.ImgRole, tbParam.G == 1)
            WidgetUtils.SetVisibleOrCollapsed(self.ImgIcon, tbParam.G ~= 1)
            SetTexture(tbParam.G == 1 and self.ImgRole or self.ImgIcon, path)
        end
        SetTexture(self.ImgLv, Item.ItemIconColorIcon[pTemplate.Color])
        self:SetTypeIcon(tbParam.G, tbParam.D)
    end
end

--- 右下角数据以及数据Icon
function tbClass:ChangeNumAndIcon(bInShow)
    WidgetUtils.SelfHitTestInvisible(self.TxtNumber)
    WidgetUtils.SelfHitTestInvisible(self.ImgNum)
    if not bInShow then
        WidgetUtils.Collapsed(self.TxtNumber)
        WidgetUtils.Collapsed(self.ImgNum)
        WidgetUtils.Collapsed(self.PanelGet)
    end
end

---设置选中效果
function tbClass:Selected()
    if self.tbParam.bSelected then
        WidgetUtils.Visible(self.PanelSelect1)
    else
        WidgetUtils.Collapsed(self.PanelSelect1)
    end
end

function tbClass:OnShowQuality(InColor)
    if not InColor or not Color.tbShadowHex[InColor] then
        print("error InColor", InColor)
        return
    end
    local HexColor = Color.tbShadowHex[InColor]
    if self.ImgPieceQuality then
        self.ImgPieceQuality:SetColorAndOpacity(UE4.FLinearColor(HexColor.R,HexColor.G,HexColor.B,HexColor.A))
    end
end

--设置锁定
function tbClass:OnLock(bLock)
    if bLock then
        WidgetUtils.SelfHitTestInvisible(self.PanelLock)
    else
        WidgetUtils.Collapsed(self.PanelLock)
    end
end

function tbClass:DisplayDormInfo(tbParam)
    self:OnLock(tbParam.bLock)
    if tbParam.bCollectAll then
        WidgetUtils.SelfHitTestInvisible(self.PanelAll)
    else
        WidgetUtils.Collapsed(self.PanelAll)
    end
    if tbParam.TargetGirl then
        SetTexture(self.ImgHead,HouseLogic:GetGirlIcon(tbParam.TargetGirl))
        WidgetUtils.SelfHitTestInvisible(self.PanelUse)
    else
        WidgetUtils.Collapsed(self.PanelUse)
    end
    if tbParam.CanExchange and not tbParam.bCollectAll then
        WidgetUtils.SelfHitTestInvisible(self.New)
    else
        WidgetUtils.Collapsed(self.New)
    end

    if tbParam.CanInteract then
        WidgetUtils.SelfHitTestInvisible(self.DormAct)
    else
        WidgetUtils.Collapsed(self.DormAct)
    end
end

--刷新角色专属道具
function tbClass:DoUpdatePanelNerve()
    if self.tbParam and Spine.tbExItem[table.concat({self.tbParam.G, self.tbParam.D, self.tbParam.P, self.tbParam.L}, "-")] and self.tbParam.pItem then
        WidgetUtils.HitTestInvisible(self.PanelNerve)
        SetTexture(self.ImgNeverHead, self.tbParam.pItem:Icon())
    else
        WidgetUtils.Collapsed(self.PanelNerve)
    end
end

return tbClass
