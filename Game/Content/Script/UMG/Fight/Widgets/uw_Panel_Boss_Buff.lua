-- ========================================================
-- @File    : uw_Panel_Monster_Buf_data.lua
-- @Brief   : boss属性Buf
-- @Author  :
-- @Date    :
-- ========================================================

local uw_Panel_Boss_Buff = Class("UMG.SubWidget")

local BossBuf = uw_Panel_Boss_Buff

BossBuf.Obj = nil
BossBuf.NowTime = nil
BossBuf.bAnim = nil
BossBuf.tempPercent = 0

-- function BossBuf:SetText(InValue)
--     self.Text_Buff_1:SetText("sssddd")
-- endtb

function BossBuf:OnListItemObjectSet(InObj)
    local  strname = InObj.pModifier:GetClassTag()
    if not strname then return {} end
    local  tbName =Split(strname, "%.")-- = string.lower(string.sub(InObj.pModifier:GetClassTag(),19))
    local sName=string.lower(tbName[#tbName])
    self.Obj = InObj
    self.bAnim = true
    if InObj then
    end
    local BufTxt = Text("modifier."..sName)
    self.tempPercent=self.Obj.pModifier.LifeTimeRemain
    self.Text_Buff_1:SetText(BufTxt)
    self.Img_buff:SetBrushFromAtlasInterface(InObj.ImgIcon, true)
end

function BossBuf:SetCDValue(InValue)
    self.CDBar:SetPercent(self.Obj.pModifier.LifeTimeRemain / self.Obj.pModifier.LifeTime)
end

function BossBuf:Tick(MyGeometry, InDeltaTime)
    self.NowTime = UE4.UGameplayStatics.GetTimeSeconds(self)
    if self.tempPercent > 0 then
        self.tempPercent = (self.Obj.pModifier.LifeTimeRemain / self.Obj.pModifier.LifeTime)-InDeltaTime
        self.CDBar:SetPercent(self.tempPercent)
    end
   
end

return BossBuf
