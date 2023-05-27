-- ========================================================
-- @File    : umg_riki_monsterinfo.lua
-- @Brief   : 图鉴系统主面板
-- ========================================================

local tbClass = Class('UMG.BaseWidget')

function tbClass:Construct()
    BtnAddEvent(self.BtnLeft,
        function ()
            if not self.tbData or not self.tbData.OnLeft then
                return
            end

            local tbData = self.tbData.OnLeft(self.tbData.Id)
            
            self:OnOpen(tbData)
        end
    )

    BtnAddEvent(self.BtnRight,
        function ()
            if not self.tbData or not self.tbData.OnRight then
                return
            end

            local tbData = self.tbData.OnRight(self.tbData.Id)
            
            self:OnOpen(tbData)
        end
    )

    self.ListInfo:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
    self.TxtTitle_1:SetText(Text("TxtHandbook11"))
end

function tbClass:OnInit()

end

function tbClass:OnOpen(tbData)
    self.tbData = tbData
    self:Clean()
    PreviewScene.Enter(PreviewType.dungeonsboss, function()
        self:PreviewMonster()
    end)

    if self.tbData.nTotal > 1 then
        WidgetUtils.Visible(self.PanelArrow)
    else
        WidgetUtils.Collapsed(self.PanelArrow)
    end

    self:UpdateIcon(tbData.cfg.tbMonster[1])
    self:UpdateInfo()
end

function tbClass:OnClose()
    self:Clean()
end

function tbClass:PreviewMonster()
    if not self.tbData.cfg then
        return
    end
    local cfg1,cfg2
    if not self.tbData.cfg.Extension2 then
        cfg2 = {{0,-45,0},{0,140,0},{0.5,0.5,0.5}}
    else
        cfg2 = Eval(self.tbData.cfg.Extension2)
    end

    if not self.tbData.cfg.Extension1 then
        cfg1 = {{0,-100,0},{0,140,0},{0.5,0.5,0.5}}
    else
        cfg1 = Eval(self.tbData.cfg.Extension1)
    end

    
    local b_pos = UE4.FVector(table.unpack(cfg2[1]))
    local b_rot = UE4.FRotator(table.unpack(cfg2[2]))
    local sca = UE4.FVector(table.unpack(cfg2[3]))
    Preview.PreviewByMonsterID(self.tbData.cfg.tbMonster[1], PreviewType.dungeonsboss, b_pos, b_rot, sca)
    Preview.PlayCameraAnimByCallback(Preview.COMMONID, PreviewType.dungeonsboss)

    local actor = self:GetGardenActor()
    if actor then
        b_pos = UE4.FVector(table.unpack(cfg1[1]))
        sca = UE4.FVector(table.unpack(cfg1[3]))

        actor:SetActorScale3D(sca)
        actor:K2_SetActorLocation(b_pos)
    end

    self.Actor = Preview.GetModel()
    self.Interaction:Init(self, self.Actor)
end

--获取底部圆圈Actor
function tbClass:GetGardenActor()
    if self.GardenActor then
        return self.GardenActor
    end

    local ActorClass = UE4.UClass.Load("/Game/Environment/07Terrain/entry02/BP_boss_bottom.BP_boss_bottom_C")
    if ActorClass then
        self.GardenActor = self:GetWorld():SpawnActor(ActorClass)
        return self.GardenActor
    end
end

function tbClass:Clean()
    if self.GardenActor and IsValid(self.GardenActor) then
        self.GardenActor:K2_DestroyActor()
    end
    --底部圆圈
    self.GardenActor = nil
    Preview.Destroy()
end

function tbClass:UpdateInfo()
    if not self.tbData.cfg then
        return
    end
    self.TxtName:SetText(Text(self.tbData.cfg.Extension3))
    local nIcon1, nIcon2 = RikiLogic:GetMonsterTypeIcon(self.tbData.cfg.tbMonster[1])
    
    SetTexture(self.ImgType1, nIcon1)
    SetTexture(self.ImgType2, nIcon2)

    if self.tbData.rikiState == RikiLogic.tbState.Lock then
        WidgetUtils.Visible(self.PanelLock)
        WidgetUtils.Collapsed(self.ListInfo)
        WidgetUtils.Collapsed(self.PanelNormal)
    else
        local key = self.tbData.cfg.Extension4

        -- if Text(key) == key then
        --     WidgetUtils.Visible(self.PanelLock)
        --     WidgetUtils.Collapsed(self.ListInfo)
        --     WidgetUtils.Collapsed(self.PanelNormal)
        --     return
        -- end

        WidgetUtils.Collapsed(self.PanelLock)
        WidgetUtils.Visible(self.ListInfo)
        WidgetUtils.Visible(self.PanelNormal)

        self.TxtDescribe:SetText(Text(key))
    end
end

function tbClass:UpdateIcon(monsterId)
    if not monsterId then return end
    local MonsterInfo = UE4.ULevelLibrary.GetCharacterTemplate(monsterId)
    if MonsterInfo and MonsterInfo.ProfileID then
        SetTexture(self.Imgmonster, MonsterInfo.ProfileID)
    end
end

return tbClass