-- ========================================================
-- @File    : umg_edit.lua
-- @Brief   : 文本输入
-- ========================================================
---@class tbClass : ULuaWidget
---@field EditNameTxt UEditableTextBox
---@field EditSignatureTxt UEditableTextBox
local tbClass = Class("UMG.BaseWidget")

local MAX = 40

function tbClass:OnInit()
    BtnAddEvent(self.BtnCancel, function() 
        if self.fCancel then self.fCancel() end
        UI.Close(self) 
    end)

    BtnAddEvent(self.BtnConfirm, function()
        local str = (self.nType == 1) and self.EditNameTxt:GetText() or self.EditSignatureTxt:GetText()
        if self.nType == 1 then
            local bOk, sTip = Player.CheckInputName(str)
            if bOk == false then
                Audio.PlaySounds(3038)
                return  UI.ShowTip(sTip)
            end
        else
            local nLength = TextLength(str)
            if  nLength > MAX then
                UI.ShowTip(Text("ui.TxtEditSignatureTip5", MAX))
                return 
            end
    
            if str == '' then
                UI.ShowTip('ui.TxtEditSignatureTip')
                return
            end

            if Login.IsOversea() == false then
                local nFindIdx = string.find(str, ' ')
                if nFindIdx then
                    UI.ShowTip('tip.402')
                    return
                end
        
                local bMatch = UE4.UGameLibrary.RegexMatch(str, "^[\\u30A1-\\u30FF\\u3041-\\u309F\\u4E00-\\u9FA5A-Za-z0-9]+$")
                if not bMatch then
                    UI.ShowTip('tip.402')
                    return
                end
            end
        end

        if self.fConfirm then 
            self.fConfirm(str, self) 
        end
    end)
end

function tbClass:OnOpen(nType, fCancel, fConfirm)
    self.nType = nType
    self.fCancel = fCancel
    self.fConfirm = fConfirm

    WidgetUtils.Collapsed(self.Currency)
    if nType == 1 then
        self.BG:SetText(Text('Txtaccounttip'))
        WidgetUtils.SelfHitTestInvisible(self.EditName)
        WidgetUtils.SelfHitTestInvisible(self.Money)
        WidgetUtils.Collapsed(self.EditSignature)
        self.EditNameTxt:SetHintText(Text("ui.TxtEditNameTip"))
        self.EditNameTxt:SetMaxInputNum(Player.GetMaxNameNum())
        if Login.IsOversea() then
            self.EditNameTxt.bCanInputSpace = true
            self.NameTip:SetText(Text('ui.TxtEditSignatureTip6'))
        else
            self.NameTip:SetText(Text('ui.TxtEditSignatureTip3'))
        end
        self:UpdateCostMoney()
    elseif nType == 2 then
        self.BG:SetText(Text('TxtEditSignature'))

        self.EditSignatureTxt:SetHintText(Text("ui.TxtEditSignatureTip"))
        self.EditSignatureTxt:SetMaxInputNum(MAX)
        if Login.IsOversea() then
            self.EditSignatureTxt.bCanInputSpace = true
        end
        WidgetUtils.SelfHitTestInvisible(self.TxtTitle_1)
        WidgetUtils.Collapsed(self.EditName)
        WidgetUtils.Collapsed(self.Money)
        WidgetUtils.SelfHitTestInvisible(self.EditSignature)
        self.TxtTip:SetText(Text('ui.TxtEditSignatureTip4'))
    else
        self.BG:SetText(Text('TxtEditmould'))
        self.EditSignatureTxt:SetHintText(Text("ui.TxtEditmould"))
        self.EditSignatureTxt:SetMaxInputNum(MAX)
        if Login.IsOversea() then
            self.EditSignatureTxt.bCanInputSpace = true
        end
        WidgetUtils.Collapsed(self.TxtTitle_1)
        WidgetUtils.Collapsed(self.EditName)
        WidgetUtils.Collapsed(self.Money)
        WidgetUtils.SelfHitTestInvisible(self.EditSignature)
        self.TxtTip:SetText(Text('ui.TxtEditmouldDesc'))
    end
    self.Money:Init({Cash.MoneyType_Vigour, Cash.MoneyType_Silver, Cash.MoneyType_Gold})
end

---更新改名消耗
function tbClass:UpdateCostMoney()
    local nRenameCount = me:GetAttribute(99, 6) + 1
    local cfg = Player.GetRenameCfg(nRenameCount)
    if not cfg then return end

    WidgetUtils.HitTestInvisible(self.Currency)
    local nNeed = cfg.nNum or 0
    self.TxtNum1_1:Settext(nNeed)
    local nIcon, _, nHas = Cash.GetMoneyInfo(cfg.nType or 1)
    SetTexture(self.IconCurrency1_1, nIcon or 0)

    if nHas < nNeed then
        Color.SetTextColor(self.TxtNum1_1, 'FF0000FF')
    else
        Color.SetTextColor(self.TxtNum1_1, '010104FF')
    end
end

return tbClass