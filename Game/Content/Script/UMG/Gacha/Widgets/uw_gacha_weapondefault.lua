-- ========================================================
-- @File    : uw_gacha_weapondefault.lua
-- @Brief   : 武器蛋池
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:OnShow(cfg)
    self:PlayAnimation(self.VideoEnter)
    PreviewMain.SetBgVisble(false)
    local tbResourceInfo = cfg.tbResourceInfo or {}
    local sMovie = tbResourceInfo[2]
    if sMovie then
        local sCoverPath = Gacha.GetMediaPath(sMovie)
        local bSuc = self.MediaWidget:Play(sCoverPath, false, true)
        print('gacha weapon play :', bSuc, sMovie)

        if bSuc then
            Audio.PlaySounds(3039)
        end

        local pMediaPlayer = self.MediaWidget:GetMediaPlayer()
        if pMediaPlayer then
            pMediaPlayer.OnEndReached:Clear()
            pMediaPlayer.OnEndReached:Add(self, function()
                self.MediaWidget:Seek(0)
                self:StartTimer()
            end)
        end
    end

    local nInterval = tonumber(tbResourceInfo[3]) or 2.8
    local tbDisplay = tbResourceInfo[4]

    self.tbDisplay = tbDisplay

    if not tbDisplay then return end

    self.nInterval = nInterval

    self.nDisplayMax = #tbDisplay
    self:ClearTimer()
   
    self:StartTimer()


    WidgetUtils.PlayEnterAnimation(self)
end

function tbClass:StartTimer()
    self.nSatrtTime = GetTime()
    self:ClearTimer()

    self.nDisplayIdx = 1
    self:ShowItem()
  
    self.FirstTimer = UE4.Timer.Add(2, function()
        self:ShowItem()
        self.DisplayTimer = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self,function() if not self.bMaxDisplay then self:ShowItem() end end}, self.nInterval or 2.8, true, 0, 0)
    
    end)
end


function tbClass:ClearTimer()
    if self.FirstTimer then
        UE4.Timer.Cancel(self.FirstTimer)
        self.FirstTimer = nil
    end

    if self.DisplayTimer then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.DisplayTimer)
        self.DisplayTimer = nil
    end
end

function tbClass:ShowItem()
    if not self.tbDisplay or not self.nDisplayMax then return end
    local info = self.tbDisplay[self.nDisplayIdx]

    self.nDisplayIdx = self.nDisplayIdx + 1
    self.bMaxDisplay = false
    if self.nDisplayIdx > self.nDisplayMax then
        self.bMaxDisplay = true 
    end

    if not info then return end

    --local nSlogan = info[1]

    local gdpl = info[2]
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
    self:ClearTimer()
    self.MediaWidget:Close()
end

function tbClass:OnDestruct()
    Audio.PlaySounds(3040)
    self:ClearTimer()
    self.MediaWidget:Close()
end

function tbClass:OnEnterMap()

end

return tbClass