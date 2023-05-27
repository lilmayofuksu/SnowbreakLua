-- ========================================================
-- @File    : uw_fight_effect.lua
-- @Brief   : 战斗受击通知
-- ========================================================

---@class uw_fight_effect :ULuaWidget
local tbClass = Class("UMG.SubWidget")

tbClass.AnimObj=nil

tbClass.Anim=nil

tbClass.bAnim=true

tbClass.num=0


function tbClass:Construct()
    -- self.Anim=self.armor_broken
    self.AnimObj=self.broken
end
function tbClass:OnHit(nAngle, nShield)
    nAngle = 360 - nAngle
    local Item = self:GetItemByAngle(nAngle, nShield > 0)
    if Item then
        Item:Play()
    end
    if nShield <= 0 then
        if self.num<=0 then
            self.bAnim=true
            self:EnterPlay()
        end
    else
        self.bAnim=false
        self.num=0
    end
  
end

function tbClass:GetItemByAngle(InAngle, bShield)
    if InAngle > 0 and InAngle <= 45 then
        return bShield and self.Angle45 or self.HitAngle45
    elseif InAngle > 45 and InAngle <= 90 then
        return bShield and self.Angle90 or self.HitAngle90
    elseif InAngle > 90 and InAngle <= 135 then
        return bShield and self.Angle135 or self.HitAngle135
    elseif InAngle > 135 and InAngle <= 180 then
        return bShield and self.Angle180 or self.HitAngle180
    elseif InAngle > 180 and InAngle <= 225 then
        return bShield and self.Angle225 or self.HitAngle225
    elseif InAngle > 225 and InAngle <= 270 then
        return bShield and self.Angle270 or self.HitAngle270
    elseif InAngle > 270 and InAngle <= 315 then
        return bShield and self.Angle315 or self.HitAngle315
    elseif InAngle > 315 and InAngle <= 360 then
        return bShield and self.Angle360 or self.HitAngle360
    end
end


function tbClass:PlayShieldAnim(InObj,InAnim)
    if InObj and InAnim then
        for i=0, self.Group_Armor:GetAllChildren():Length()-1 do
            WidgetUtils.SelfHitTestInvisible(self.Group_Armor:GetChildAt(i))
        end
        self:PlayAnimation(InAnim,0,1,UE4.EUMGSequencePlayMode.Forward,1,false)
    end
end

function tbClass:EnterPlay()
    if self.bAnim then
        --self:PlayShieldAnim(self.AnimObj,self.Anim)
        self.bAnim=false
        self.num=self.num+1
    end
end

return tbClass
