-- ========================================================
-- @File    : uw_account_exchange.lua
-- @Brief   : 账号界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()

    BtnAddEvent(self.BtnCancel, function() 
        UI.Close(self)
    end)

    BtnAddEvent(self.BtnConfirm, function()
        local cdkey = self.ExchangeTxt:GetText()
        if cdkey and cdkey ~= ''  then
            print("ExchangeCode:", cdkey)

            ---去掉礼包码字母数字输入的限制
            --local bMatch = UE4.UGameLibrary.RegexMatch(cdkey, "^[\\uac00-\\ud7ff\\u30A1-\\u30FF\\u3041-\\u309F\\u4E00-\\u9FA5A-Za-z0-9]+$")
            if true then
                local userinfoUrl = Player.tbSetting and Player.tbSetting['GiftCodeParam1'] or ''
                local dispatchUrl = Player.tbSetting and Player.tbSetting['GiftCodeParam2'] or ''
                UE4.UGameLibrary.ExchangeGift(cdkey, userinfoUrl, dispatchUrl)
                DataPost.XGEvent("usecdk", "Player use SDK", 0, string.format("{\"cdkey\":\"%s\"}", cdkey))
            else
                UI.ShowTip("tip.rolefiles_inputcode")
            end
        else
            UI.ShowTip("tip.rolefiles_nocode")
        end
    end)

    self.nHandleExchangeResult = EventSystem.On(Event.SdkExchangeResult, function(rspCode, rspMsg)
        if tostring(rspCode) == '0' then
            UI.ShowTip(Text('tip.ExchangeCode.success'))
        else
            UI.ShowTip(rspMsg or '')
        end

        UI.Close(self)
        print("ExchangeResult", rspCode, rspMsg)
    end)
end

function tbClass:OnOpen()
    self.ExchangeTxt:SetHintText(Text('ui.TxtExchangeTip'))
end

function tbClass:OnClose()
    EventSystem.Remove(self.nHandleExchangeResult)
end


return  tbClass