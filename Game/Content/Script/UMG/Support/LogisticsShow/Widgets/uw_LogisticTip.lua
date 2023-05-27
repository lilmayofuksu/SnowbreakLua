-- ========================================================
-- @File    : uw_LogisticTip.lua
-- @Brief   : 角色后勤Tip
-- @Author  :
-- @Date    :
-- ========================================================

local tbConfirmTip = Class("UMG.BaseWidget")
--- 按键监听
function tbConfirmTip:Construct()
    self.no.OnClicked:Add(
        self,
        function()
            UI.Close(self)
        end
    )

    self.yes.OnClicked:Add(
        self,
        function()
            self:Req_ForceEquip()
            UI.Close(self)
        end
    )
end


--- 进入界面初始化
---@param InParam table 请求数据
---@param InCall function 请求后的回调
function tbConfirmTip:OnOpen(InParam, InCall)
    self.tbParam = InParam
    if InCall then
        self.CallBack = InCall
    end
    self:TipDes()
end
--- 是否安装按键请求
function tbConfirmTip:Req_ForceEquip()
    self.tbParam.BEqId = Logistics.GetBeCharacterCard(self.tbParam.pSCard):Id()
    self.tbParam.bForce = true
    Logistics.Req_Equip(
        self.tbParam,
        function()
            EventSystem.TriggerTarget(Logistics, Logistics.OnUpdataLogisticsSlot)
            self.CallBack()
        end
    )
end

--- 是否安装界面描述
function tbConfirmTip:TipDes()
    local pRCard = Logistics.GetBeCharacterCard(self.tbParam.pSCard)
    local pSCard = self.tbParam.pSCard
    local sDes = '"'..Text(pSCard:I18N())..'"'.. Text("ui.TxtSupportDes1") ..'"'.. Text(pRCard:I18N().."_suits") ..'"'.. Text("ui.TxtSupportDes2")
    self.txtDes:SetText(sDes)
end

return tbConfirmTip
