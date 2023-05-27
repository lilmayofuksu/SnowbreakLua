-- ========================================================
-- @File    : uw_main_player_info.lua
-- @Brief   : 玩家信息显示
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.nLevelChange = EventSystem.On(Event.LevelUp, function(nNewLevel, nOldLevel) self:Update() end)
    BtnAddEvent(self.BtnClick, function() UI.Open('Account') end)
    self:Update()
    self:SetFace()
end

function tbClass:Update()
    self.Lv:SetText(me:Level())
    local nExp = me:Exp()
    local nMaxExp = Player.GetMaxExp(me:Level())
    
    self.Exp:SetPercent(nMaxExp > 0 and (nExp / nMaxExp) or 1)
    self.Name:SetText(me:Nick())
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nLevelChange)
end

---设置头像
function tbClass:SetFace()
    local pCard = me:GetShowItem(Profile.SHOWITEM_CARD)
    if pCard == nil then
        pCard = me:GetCharacterCard(PlayerSetting.GetShowCardID())
    end

    if pCard then
        SetTexture(self.Image, pCard:Icon())
    end
end





return tbClass