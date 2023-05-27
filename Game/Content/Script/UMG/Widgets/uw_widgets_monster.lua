-- ========================================================
-- @File    : uw_widgets_monster.lua
-- @Brief   : 通用怪物信息组件
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(InObj)
    if not InObj and InObj.Data then
       return
    end
    local tbData = InObj.Data
    self:UpdateIcom(tbData.ID)
    if tbData.FunClick then
        BtnClearEvent(self.Button)
        BtnAddEvent(self.Button, tbData.FunClick)
    end
end

function tbClass:UpdateIcom(monsterId)
    if not monsterId then return end
    local MonsterInfo = UE4.ULevelLibrary.GetCharacterTemplate(monsterId)
    if MonsterInfo and MonsterInfo.ProfileID then
        SetTexture(self.Imgmonster, MonsterInfo.ProfileID)
    end
end

return tbClass