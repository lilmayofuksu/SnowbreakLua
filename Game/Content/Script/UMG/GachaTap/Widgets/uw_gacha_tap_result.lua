-- ========================================================
-- @File    : umg_gacha_tap_result.lua
-- @Brief   : 抽奖结果返回
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)
    BtnAddEvent(self.BtnConfirm, function() UI.CloseByName('GachaTap') end)
    WidgetUtils.Collapsed(self.BtnConfirm)
    WidgetUtils.Collapsed(self.Extra)

    self.ListReward.OnPlayAppearAnimFinish:Add(self, function()
        local fEnd = function()
            WidgetUtils.PlayEnterAnimation(self)
            WidgetUtils.HitTestInvisible(self.Extra)
        end
        if self.nDelayTime and self.nDelayTime > 0 then
            WidgetUtils.Collapsed(self.BtnConfirm)
            self.nDelayTimer = UE4.Timer.Add(self.nDelayTime, function()
                self.nDelayTimer = nil
                fEnd()
            end)

        else
            fEnd()
        end
    end)

    self:BindToAnimationFinished(self.AllEnter, {self, function()
    
    end})
end

function tbClass:OnOpen(tbAwards)
    if (not tbAwards) or #tbAwards == 0 then
        return UI.Close(self)
    end

    local bTen = (#tbAwards == 10)
    Audio.PlaySounds(bTen and 3035 or 3034)

    self:Sort(tbAwards)
    self:DoClearListItems(self.ListReward)

    local tbExtra = {}

    local tbChecked = {}
    local bHaveSameCard = false
    for _, GDPL in ipairs(tbAwards) do
        local tbData = { tbGDPL = GDPL, nCount = 1}
        -- 同卡分解特殊处理
        local sGDPL = string.format("%d-%d-%d-%d", GDPL[1], GDPL[2], GDPL[3], GDPL[4])

        if Gacha.tbExistsItem and Gacha.tbExistsItem[UE4.EItemType.CharacterCard] then
            local tbExists = Gacha.tbExistsItem[UE4.EItemType.CharacterCard][sGDPL]
            if GDPL[1] == UE4.EItemType.CharacterCard and ((tbExists and tbExists.nCount > 0) or tbChecked[sGDPL]) then
                tbData.tbTransSame = Item.Character2Piece(table.unpack(GDPL))[1]
                bHaveSameCard = true
            end
        end
        tbChecked[sGDPL] = tbChecked[sGDPL] or true
        local pObj = self.Factory:Create(tbData)
        self.ListReward:AddItem(pObj)

        table.insert(tbExtra, {GDPL[1], GDPL[2], GDPL[3], GDPL[4]})
    end
    self.ListReward:PlayAnimation(0)

    self.Extra:SetByTb(tbExtra)

    -- 同卡分解特殊处理
    if bHaveSameCard then
        self.nDelayTime = 3
    else
        self.nDelayTime = 0
    end
end

function tbClass:OnDestruct()
    if self.nDelayTimer then
        UE4.Timer.Cancel(self.nDelayTimer)
        self.nDelayTimer = nil
    end
    PreviewScene.Enter(PreviewType.main)
    PlayerSetting.MuteMusic(false)
end

---排序
function tbClass:Sort(tbAwards)
    --- 展示的顺序  角色 武器
    --- 再按品阶降序

    table.sort(tbAwards, function(left, right)
        local pLeft = UE4.UItem.FindTemplate(table.unpack(left))
        local pRight = UE4.UItem.FindTemplate(table.unpack(right))
        if pLeft.Genre ~= pRight.Genre then
            return pLeft.Genre < pRight.Genre
        end
        return pLeft.Color > pRight.Color
    end)
end

return tbClass
