-- ========================================================
-- @File    : umg_fightonline_allbuff.lua
-- @Brief   : 已拥有buff查看
-- ========================================================

--- @class umg_fightonline_choose : UI_Template
local tbClass = Class("UMG.BaseWidget");

function tbClass:OnInit()
    self:RegisterEvent(
        Event.RefreshRandomBufferes,
        function()
            self:OnOpen()
        end
    )
    self:DoClearListItems(self.ListAllBuff)
    self:RegisterEvent(
        Event.OpenOrCloseBuffDesc,
        function(tbParam)
            if tbParam[1] then
                WidgetUtils.Visible(self.BtnClose)
            else
                WidgetUtils.Collapsed(self.BtnClose)
            end
        end
    )

    BtnAddEvent(self.BtnClose,function ()
        EventSystem.Trigger(Event.OpenOrCloseBuffDesc, {false})
    end)

    self.RarityColor = {UE4.FLinearColor(0.015686, 0.188235, 0.760784, 1), UE4.FLinearColor(0.333333, 0.05098,0.815686, 1),
        UE4.FLinearColor(0.890196, 0.384314, 0.043137, 1)};


    self.Back:Set(function()
        UI.Close(self)
    end)
end

function tbClass:Construct()
    self.ListAllBuff:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
end


function tbClass:OnOpen()
    self:ExhaleMouse(true)


    self.Factory = Model.Use(self);
    local pawn = self:GetOwningPlayerPawn()
    local buffList = pawn.RandomBufferes
    local NoRepeatedBuffList = UE4.TArray(UE4.int32)
    for i = 1, buffList:Length() do
        local BufferId = buffList:Get(i)
        if not NoRepeatedBuffList:Contains(BufferId) then
            NoRepeatedBuffList:Add(BufferId)
        end
    end
    self:DoClearListItems(self.ListAllBuff)
    self:DoClearListItems(self.uw_fightonline_shop_allbuff.ListBuff)
    for i = 1, NoRepeatedBuffList:Length() do
        local buffId = NoRepeatedBuffList:Get(i);
        if buffId ~= -1 then
            local tbParam = {}
            tbParam.buffId = buffId
            tbParam.pawn = pawn;
            tbParam.checkShowSelected = function (buffId,widget)
                if self.SlBuffId == buffId then
                    if self.slDetail then
                        self.slDetail:ShowSl(false)
                    end
                    self.slDetail = widget;
                    widget:ShowSl(true)
                end
            end
            local obj = self.Factory:Create(tbParam)
            self.ListAllBuff:AddItem(obj)
            local buffer = self:GetAbilityBuffer(buffId);
            local nowCount = self:GetPlayerBuffCount(buffId)
            local Color = self.RarityColor[buffer.Rarity];
            local tbParam2 = {nIcon = buffer.Icon, nColor = Color, desc = self:GetBuffDesc(buffer,nowCount),name = Text(buffer.Name), root = self.uw_fightonline_shop_allbuff, onClick = function (isSl,widget)
                if isSl then
                    if self.slSmallBuff then
                        self.slSmallBuff:ShowSl(false)
                    end
                    self.slSmallBuff = widget;
                    self.SlBuffId = buffId
                else
                    if self.slSmallBuff then
                        self.slSmallBuff:ShowSl(false)
                    end
                    self.slSmallBuff = nil
                    self.SlBuffId = nil
                end
                self.ListAllBuff:RegenerateAllEntries()
                self.ListAllBuff:ScrollIndexIntoView(i-1)
            end}
            local pObject = self.Factory:Create(tbParam2)
            self.uw_fightonline_shop_allbuff.ListBuff:AddItem(pObject)
        end
    end

    local uiFight = UI.GetUI('Fight')
    if uiFight then
        local pGameTaskActor = uiFight:GetTaskActor()
        if pGameTaskActor ~= nil then        
            self.CurTime = math.max(0, pGameTaskActor:GetLevelCountDownTime())   
            self.Time.TxtTime:SetText(os.date("%M:%S",self.CurTime))
        end

        if self.TimerHandle then
            UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self,self.TimerHandle)
        end
        self.TimerHandle =
        UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
            {
                self,
                function()
                    self.CurTime = (self.CurTime or 1) - 1
                    if self.CurTime >= 0 then
                        self.Time.TxtTime:SetText(os.date("%M:%S",self.CurTime))
                    end
                end
            },
            1,
            true
        )
    end
end

function tbClass:GetBuffDesc(buff,nowGotNum)
    local desc = Text(buff.Desc)
    if not buff or not buff.BufferCount then
        return ''
    end
    --{{10,20,40},{20,30,60}}
    local tbStr = buff.BuffParamPerCount
    if tbStr == '' then
        tbStr = '{}'
    end
    local tbParam = Eval(tbStr)
    if #tbParam == 0 or not string.find(desc,'{') then
        return desc
    end
    local getStrNeed = function (tbNum)
        if type(tbNum) ~= 'table' then
            tbNum = {10}
        end
        local resStr = ''
        for i=1,buff.BufferCount do
            local thisLevelNum = tbNum[i] or (tbNum[1] * i)
            resStr = resStr..((nowGotNum == i) and ('<span color="#f88d0f">'..string.format('%s',thisLevelNum)..'</>') or string.format('%s',thisLevelNum))
            resStr = resStr..(i == buff.BufferCount and '' or '/')
        end
        return resStr
    end
    local res = {}
    for i=1,#tbParam do
        res[i] = getStrNeed((tbParam[i]))
    end
    for i=1,4 do
        res[#res + 1] = 0
    end
    local ParamArray = UE4.TArray(UE4.FString)
    for i = 1, #res do
        ParamArray:Add(res[i])
    end
    return UE4.UAbilityLibrary.FormatDescribe(desc, ParamArray)
    -- return string.format(desc,table.unpack(res));
end

function tbClass:OnClose()
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self,self.TimerHandle)
    self:ExhaleMouse(false)
    self:RemoveRegisterEvent()
end

function tbClass:ExhaleMouse(bShow)
    RuntimeState.ChangeInputMode(bShow)
end

return tbClass;
