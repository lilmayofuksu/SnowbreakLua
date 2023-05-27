
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct( ... )
	self.RarityColor = {UE4.FLinearColor(0.015686, 0.188235, 0.760784, 1), UE4.FLinearColor(0.333333, 0.05098,0.815686, 1),
        UE4.FLinearColor(0.890196, 0.384314, 0.043137, 1)};
    WidgetUtils.Collapsed(self.TxtLock)
    WidgetUtils.Collapsed(self.TxtDetail)
    WidgetUtils.Collapsed(self.PanelSl)
end

function tbClass:OnListItemObjectSet(pObj)
	local tbParam = pObj.Data;
	local buffId = tbParam and tbParam.buffId
	local pawn = tbParam and tbParam.pawn;
	if not buffId or not pawn then
		return
	end
	self:ShowOwnedBuff(buffId,pawn)
    if tbParam and tbParam.checkShowSelected then
        tbParam.checkShowSelected(buffId,self)
    end
end

function tbClass:ShowSl(isSl)
    if isSl then
        WidgetUtils.SelfHitTestInvisible(self.PanelSl)
    else
        WidgetUtils.Collapsed(self.PanelSl)
    end
end

function tbClass:ShowOwnedBuff(buffId,pawn)
	local buffer = pawn:GetAbilityBuffer(buffId);
    local Color = self.RarityColor[buffer.Rarity];
    self.Frame:SetColorAndOpacity(Color);
    self.SmallFrame:SetColorAndOpacity(Color);
    self.SmallLight:SetColorAndOpacity(Color);
    SetTexture(self.ImgBuff, buffer.Icon, false);
    local nowCount = self:GetPlayerBuffCount(buffId);
    self.TxtBuffDetail:SetContent(self:GetBuffDesc(buffer,nowCount));
    self.TxtName:SetText(Text(buffer.Name));
    self.TxtName1:SetText(Text(buffer.Name));
    self.TxtNumber:SetText(nowCount);

    self.BtnOk.BtnOk:SetVisibility(UE4.ESlateVisibility.Collapsed);
    self.BtnOk.BtnNot:SetVisibility(UE4.ESlateVisibility.Collapsed);
    self.PanelMoney:SetVisibility(UE4.ESlateVisibility.Collapsed)
    WidgetUtils.Collapsed(self.TxtLock)
    WidgetUtils.Collapsed(self.TxtDetail)
    WidgetUtils.Collapsed(self.PanelLock)
end

function tbClass:GetBuffDesc(buff,nowGotNum)
    if not buff or not buff.BufferCount then
        return ''
    end
    --{{10,20,40},{20,30,60}}
    local tbStr = buff.BuffParamPerCount
    if tbStr == '' then
        tbStr = '{}'
    end
    local desc = Text(buff.Desc)
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
    -- return string.format(desc,table.unpack(res))
end

return tbClass;