-- ========================================================
-- @File    : uw_gacha_weaponup.lua
-- @Brief   : 武器UP
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:OnShow(cfg)
    self:PlayAnimation(self.VideoEnter)

    PreviewMain.SetBgVisble(false)
    local tbResourceInfo = cfg.tbResourceInfo or {}
    local sMovie = tbResourceInfo[2]
    if sMovie then

        local sCoverPath = Gacha.GetMediaPath(sMovie)
        local bSuc = self.MediaWidget:Play(sCoverPath, false, false)

        local nSecond = tonumber(tbResourceInfo[5])
        if nSecond then

            local pMediaPlayer = self.MediaWidget:GetMediaPlayer()
            if pMediaPlayer then
                pMediaPlayer.OnEndReached:Clear()
                pMediaPlayer.OnEndReached:Add(self, function()
                    self:LoopPlay(nSecond)
                    print('gacha weapon play end')
                end)
            end
        end

        local nAudio = tonumber(tbResourceInfo[6])
        if nAudio then
            Audio.PlaySounds(nAudio)
        end

        print('gacha weapon play :', bSuc, sMovie)
    end

    local nSlogan = tbResourceInfo[3]
    if nSlogan then
        SetTexture(self.Bg, nSlogan)
    end

    local gdpl = tbResourceInfo[4]
    if gdpl then
        local pTemplate = UE4.UItem.FindTemplate(table.unpack(gdpl))
        self.TxtName1:SetText(Text(pTemplate.I18N))
        local nColor = pTemplate.Color or 0
        for i = 0, nColor - 1 do
            local pStar = self.ListRoleStar:GetChildAt(i)
            if pStar then
                WidgetUtils.HitTestInvisible(pStar)
            end
        end

        self:SetImg(nColor)
    end

    WidgetUtils.PlayEnterAnimation(self)
end

function tbClass:LoopPlay(nSecond)
    local nDuration = self.MediaWidget:GetMediaDuration()
    if nDuration - nSecond < 1 then
        print('loop play :', nDuration, nSecond)
        return
    end


    local bSuc = self.MediaWidget:Seek(nSecond)
    if bSuc then
        local pMediaPlayer = self.MediaWidget:GetMediaPlayer()
        if pMediaPlayer then
            pMediaPlayer.OnEndReached:Clear()
            pMediaPlayer.OnEndReached:Add(self, function()
                self:LoopPlay(nSecond)
                print('gacha weapon play end')
            end)
            pMediaPlayer:Play()
        end
    end
    print('loop play :', bSuc, nSecond)
end

function tbClass:SetImg(nColor)
    if nColor == 5 then
        SetTexture(self.Rarity, 1700110)
        SetTexture(self.Rarity1, 1700109)
    else
        SetTexture(self.Rarity, 1700112)
        SetTexture(self.Rarity1, 1700111)
    end
end

function tbClass:OnHide()
    Audio.PlaySounds(3040)
    self.MediaWidget:Close()
end

function tbClass:OnDestruct()
    Audio.PlaySounds(3040)
    self.MediaWidget:Close()
end

function tbClass:OnEnterMap()
end

return tbClass