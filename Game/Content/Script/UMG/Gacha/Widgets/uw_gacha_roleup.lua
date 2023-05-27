-- ========================================================
-- @File    : uw_gacha_roleup.lua
-- @Brief   : 蛋池UP
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:OnShow(cfg)
    self:PlayAnimation(self.VideoEnter)
    if not cfg then return end
    local tbResourceInfo = cfg.tbResourceInfo or {}

    WidgetUtils.Collapsed(self.Other)
    WidgetUtils.HitTestInvisible(self.Movie)
    
    local sMovie = tbResourceInfo[2]
    local nSlogan = tbResourceInfo[8]
    local gdpl = tbResourceInfo[9]
    local nPos = tonumber(tbResourceInfo[10]) or 1

    local nAudio = tonumber(tbResourceInfo[11])

    if sMovie then
        local sCoverPath = Gacha.GetMediaPath(sMovie)
        local bSuc = self.MediaWidget:Play(sCoverPath, false, false)

        if nAudio then
            Audio.PlaySounds(nAudio)
        end

        local pMediaPlayer = self.MediaWidget:GetMediaPlayer()
        if pMediaPlayer then
            pMediaPlayer.OnEndReached:Clear()
            pMediaPlayer.OnEndReached:Add(self, function()
                self:PlayCGSpine(true, cfg)
                print('gacha role play end')
            end)
        end
        print('gacha role play :', bSuc, sMovie)
    end


    WidgetUtils.Collapsed(self.ImgSlogan)
    WidgetUtils.Collapsed(self.ImgSlogan2)

    local pSlogan = (nPos == 1) and self.ImgSlogan or self.ImgSlogan2

    if nSlogan and pSlogan then
        WidgetUtils.HitTestInvisible(pSlogan)
        SetTexture(self.ImgSlogan, nSlogan)
    end

    if gdpl then
        local pTemplate = UE4.UItem.FindTemplate(table.unpack(gdpl))
        self.TxtNameUp:SetText(Text(pTemplate.I18N)..'-'..Text(pTemplate.I18N .. '_title'))
        local nColor = pTemplate.Color or 0
        for i = 0, nColor - 1 do
            local pStar = self.ListStarUp:GetChildAt(i)
            if pStar then
                WidgetUtils.HitTestInvisible(pStar)
            end
        end

        self:SetImg(nColor)
    end
end

function tbClass:SetImg(nColor)
    if nColor == 5 then
        SetTexture(self.RarityUp1, 1700110)
        SetTexture(self.RarityUp2, 1700109)
    else
        SetTexture(self.RarityUp1, 1700112)
        SetTexture(self.RarityUp2, 1700111)
    end
end

function tbClass:StopMovie()
    self.MediaWidget:Close()
end

function tbClass:OnHide()
    Audio.PlaySounds(3040)
    self:StopMovie()
    self:PlayCGSpine(false)
end

function tbClass:OnDestruct()
    Audio.PlaySounds(3040)
    self:StopMovie()
    self.CacheCGSpine = nil
    self:PlayCGSpine(false)
end

function tbClass:PlayCGSpine(bPlay, cfg)
    WidgetUtils.HitTestInvisible(self.Other)
    WidgetUtils.Collapsed(self.Movie)

    local pCamera = PreviewMain.GetCamera()
    if not pCamera then return end

    if bPlay then
        if self.isPlayingCG then return end
        PreviewMain.SetBgVisble(false)
        self.isPlayingCG = true
        UE4.UGameLocalPlayer.SetAutoAdapteToScreen(false)
        WidgetUtils.PlayEnterAnimation(self)

        local tbResourceInfo = cfg.tbResourceInfo or {}
        local sSpineRes = tbResourceInfo[3]
        local nTime = tbResourceInfo[4] or 1
        local startPos = tbResourceInfo[5] or {0, 0}
        local endPos = tbResourceInfo[6] or {0, 0}
        local scale = tbResourceInfo[7] or {1, 1}

        if sSpineRes then
            local pSoftPath = UE4.UKismetSystemLibrary.MakeSoftObjectPath(sSpineRes)
            local pLoadObj = UE4.UGameAssetManager.GameLoadAsset(pSoftPath)
            if pLoadObj then 
                self.CacheCGSpine = pLoadObj
                UE4.UCGSpineLibrary.PlayCGSpine(pLoadObj, pCamera);
            end
        end
        UE4.UCGSpineLibrary.PlayCameraAnimation(nTime, UE4.FVector2D(startPos[1], startPos[2]), UE4.FVector2D(endPos[1], endPos[2]), UE4.FVector2D(scale[1], scale[2]))
    else
        self.CacheCGSpine = nil
        if not self.isPlayingCG then return end
        UE4.UCGSpineLibrary.ClearCGSpine(pCamera);
        UE4.UGameLocalPlayer.SetAutoAdapteToScreen(true)
        self.isPlayingCG = false
    end
end

function tbClass:OnEnterMap()

end

return tbClass