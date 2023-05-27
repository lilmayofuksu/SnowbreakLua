 HouseGirlLove = HouseGirlLove or {}

 local tbClass = HouseGirlLove;

function tbClass:LoadCfg()
    self.GirlLoveLevelPoint = {}
	local tbFile = LoadCsv('house/love_level.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local Level = tonumber(tbLine.Level or 0)
        local NeedPoint = tonumber(tbLine.NeedPoint or 0)
        self.GirlLoveLevelPoint[Level] = NeedPoint;
    end

    self.GirlLoveLevelStory = {}
    local tbFile2 = LoadCsv('house/love_story.txt', 1)
    for _, tbLine in ipairs(tbFile2) do
        local Level = tonumber(tbLine.Level or 0)
        local StoryId = (tbLine.StoryId or '')
        local Index = tonumber(tbLine.Index or 0)
        local GirlId = tonumber(tbLine.GirlId or 0)
        local TbReward = Eval(tbLine.TbAward)
        local StoryName = tbLine.StoryName or ''
        if not self.GirlLoveLevelStory[GirlId] then
            self.GirlLoveLevelStory[GirlId] = {}
        end
        if not self.GirlLoveLevelStory[GirlId][Index] then
            self.GirlLoveLevelStory[GirlId][Index] = {}
        end
        self.GirlLoveLevelStory[GirlId][Index] = {
            ['Level'] = Level,
            ['StoryId'] = StoryId,
            ['TbReward'] = TbReward,
            ['Index'] = Index,
            ['GirlId'] = GirlId,
            ['StoryName'] = StoryName,
        };
    end

    self.tbGirlAddAttribute = {}
    local tbFile3 = LoadCsv('house/love_add_attribute.txt', 1)
    for _, tbLine in ipairs(tbFile3) do
        local GirlId = tonumber(tbLine.GirlId or 0)
        local Level = tonumber(tbLine.Level or 0)
        if not self.tbGirlAddAttribute[GirlId] then
            self.tbGirlAddAttribute[GirlId] = {}
        end
        local Health = tonumber(tbLine.Health or 0)
        local Attack = tonumber(tbLine.Attack or 0)
        local Defence = tonumber(tbLine.Defence or 0)
        local Shield = tonumber(tbLine.Shield or 0)
        local tb = {}
        tb.Level = Level;
        tb.Health = Health;
        tb.Attack = Attack;
        tb.Defence = Defence;
        tb.Shield = Shield;
        table.insert(self.tbGirlAddAttribute[GirlId],tb)
    end

    self.tbGirlSpineCfg = {}
    local tbSpineFile = LoadCsv('house/girl_spine_cfg.txt',1)
    for _,tbLine in ipairs(tbSpineFile) do
        local GirlId = tonumber(tbLine.GirlId or 0)
        local Scale = tonumber(tbLine.Scale or 0)
        local OffsetX = tonumber(tbLine.OffsetX or 0)
        local OffsetY = tonumber(tbLine.OffsetY or 0)
        self.tbGirlSpineCfg[GirlId] = {Scale = Scale,OffsetX = OffsetX,OffsetY = OffsetY}
    end

    self.tbLoadingTex = {}
    local tbLoadingFile = LoadCsv('house/loading_tex.txt',1)
    for _, tbLine in ipairs(tbLoadingFile) do
        local GirlId = tonumber(tbLine.GirlId or 0)
        local ResourceId = tonumber(tbLine.TexResourceId or 0)

        self.tbLoadingTex[GirlId] = ResourceId;
    end
end

function tbClass:GetGirlSpineCfg(GirlId)
    local scale = 1
    local offset = UE4.FVector2D(0,0)

    if GirlId and self.tbGirlSpineCfg[GirlId] then
        scale = self.tbGirlSpineCfg[GirlId].Scale;
        offset.X = self.tbGirlSpineCfg[GirlId].OffsetX;
        offset.Y = self.tbGirlSpineCfg[GirlId].OffsetY;
    end
    return scale,offset
end

-- 获得当前 等级、信赖度 加权值 排序使用
function tbClass:GetGirlLove(GirlId)
    local Num = HouseStorage.GetCharacterAttr(GirlId,HouseStorage.EGirlAttr.Favor)
    local Level = GetBits(Num,0,10)
    if Level == 0 then
        Level = 1
    end
    local Point = GetBits(Num,11,25)

    local Val = 0
    Val = SetBits(Val, Point, 0, 14)
    Val = SetBits(Val, Level, 15, 25)
    return Val
end


--得到妹子当前信赖度等级
 function tbClass:GetGirlLoveLevel(GirlId)
    if not GirlId then
        return 1
    end
 	local Num = HouseStorage.GetCharacterAttr(GirlId,HouseStorage.EGirlAttr.Favor)
    local Level = GetBits(Num,0,10)
    if Level == 0 then
        Level = 1
    end
    return Level
 end

--得到妹子当前信赖度点数
 function tbClass:GetGirlNowLovePoint(GirlId)
 	local Num = HouseStorage.GetCharacterAttr(GirlId,HouseStorage.EGirlAttr.Favor)
    local Point = GetBits(Num,11,25)
    return Point
 end

 --得到妹子当前升级所需的信赖度点数
 function tbClass:GetGirlLevelUpNeedPoint(Level)
    if self.GirlLoveLevelPoint then
        return self.GirlLoveLevelPoint[Level] or 1000000,self.GirlLoveLevelPoint[Level] and true or false
    end
    return 1000000,false
 end

 function tbClass:GetGirlLoveStoryInfo(GirlId)
     if self.GirlLoveLevelStory then
        return self.GirlLoveLevelStory[GirlId]
    end
 end

function tbClass:CheckGirlLoveStoryCanRead( GirlId,Index )
    local tbInfo = self:GetGirlLoveStoryInfo(GirlId)
    if not tbInfo then
        return 
    end
    local Info = tbInfo[Index]
    if not Info then
        return
    end
    local Level = self:GetGirlLoveLevel(GirlId) or 1
    return Level >= (Info.Level or 10000)
end

function tbClass:CheckGirlLoveStoryHasRead( GirlId,Index )
    if Index < 0 or Index > 30 then
        return
    end
    local Num = HouseStorage.GetCharacterAttr(GirlId,HouseStorage.EGirlAttr.LoveStoryReadTask)
    return GetBits(Num,Index,Index) == 1
end

function tbClass:GetRandomLoadingTexId()
    if not self.tbLoadingTex then
        return nil
    end
    local Res = {}
    table.insert(Res,self.tbLoadingTex[0])
    for k,v in pairs(self.tbLoadingTex) do
        if k > 0 and self.GirlLoveLevelStory[k] and self:CheckGirlLoveStoryHasRead(k,#self.GirlLoveLevelStory[k]) then
            table.insert(Res,v)
        end
    end
    local MaxNum = #Res
    local RandIndex = math.random(MaxNum)
    return Res[RandIndex]
end

function tbClass:ReadGirlLoveStory( GirlId,Index )
 	local tbInfo = self:GetGirlLoveStoryInfo(GirlId)
    if not tbInfo then
        return 
    end
    local Info = tbInfo[Index]
    if not Info then
        return
    end
    if self:CheckGirlLoveStoryHasRead(GirlId,Index) then
        self:PlayLoveStory(Info.StoryId)
    else       
        local tbParam = {}
        tbParam.FuncName = 'ReadGirlLoveStory'
        tbParam.GirlId = GirlId;
        tbParam.Index = Index;
        HouseMessageHandle.HouseMessageSender(tbParam);
    end
end

function tbClass:ReadGirlLoveStorySuccess(tbParam)
    if not tbParam or not tbParam.tbReward or not tbParam.Index or not tbParam.GirlId then
        return
    end
    local tbInfo = self:GetGirlLoveStoryInfo(tbParam.GirlId)
    if not tbInfo then
        return 
    end
    local Info = tbInfo[tbParam.Index]
    if Info then
        self:PlayLoveStory(Info.StoryId,tbParam.tbReward)
    end
end

function tbClass:PlayLoveStory(StoryId,TbReward,EndFunc)
    local ui = UI.GetTop()
    if ui then
        --[[local Widgets = UE4.UUMGLibrary.GetAllUserWidget(ui)
        for i = 1,Widgets:Length() do
            WidgetUtils.Hidden(Widgets:Get(i))
        end]]
        WidgetUtils.Hidden(ui)
    end
    UE4.UUMGLibrary.PlayPlot(GetGameIns(), StoryId, {GetGameIns(), function(lication, CompleteType)
    --CartoonMgr:Play("test/test_1.bytes", function(completeType)
        local MapManager = UE4.UMapManager.GetSingleton()
        if IsValid(MapManager) then
            MapManager:RestoreMusic()
        end
        local ui = UI.GetTop()
        if ui then
            --[[local Widgets = UE4.UUMGLibrary.GetAllUserWidget(ui)
            for i = 1,Widgets:Length() do
                WidgetUtils.Visible(Widgets:Get(i))
            end]]
            WidgetUtils.Visible(ui)
        end
        if TbReward then
            Item.Gain(TbReward)
        end
        if EndFunc then
            EndFunc()
        end
        local UIStory = UI.GetUI('DormLoveStory')
        if UIStory then
            UIStory:OnOpen(UIStory.GirlId)
        end
    end});
end

function tbClass:Play3DStory(StoryId,TbReward,EndFunc)
    local ui = UI.GetTop()
    if ui then
        --[[local Widgets = UE4.UUMGLibrary.GetAllUserWidget(ui)
        for i = 1,Widgets:Length() do
            WidgetUtils.Hidden(Widgets:Get(i))
        end]]
        WidgetUtils.Hidden(ui)
    end

    CartoonMgr:Play(StoryId, function(CompleteType)
        local MapManager = UE4.UMapManager.GetSingleton()
        if IsValid(MapManager) then
            MapManager:RestoreMusic()
        end

        local ui = UI.GetTop()
        if ui then
            --[[local Widgets = UE4.UUMGLibrary.GetAllUserWidget(ui)
            for i = 1,Widgets:Length() do
                WidgetUtils.Visible(Widgets:Get(i))
            end]]
            WidgetUtils.Visible(ui)
        end
        HouseLogic.ShowUIMask(false)
        if TbReward then
            Item.Gain(TbReward)
        end
        if EndFunc then
            EndFunc()
        end
        local UIStory = UI.GetUI('DormDialogue')
        if UIStory then
            UIStory.HasShow = false
            UIStory:ShowTalk()
        end
    end);
end

function HouseGirlLove:GetLoveAddAttTb(InGirlId,InLevel)
    local FindTb = nil;
    if HouseGirlLove.tbGirlAddAttribute and HouseGirlLove.tbGirlAddAttribute[InGirlId] then
        local LevelNum = #HouseGirlLove.tbGirlAddAttribute[InGirlId];
        for i = 1,LevelNum do
            local tb = HouseGirlLove.tbGirlAddAttribute[InGirlId][i]
            if i < LevelNum then
                if InLevel >= tb.Level and InLevel < HouseGirlLove.tbGirlAddAttribute[InGirlId][i+1].Level then
                    FindTb = tb;
                    break;
                end
            else
                if InLevel >= tb.Level then
                    FindTb = tb;
                end
            end
        end
    end
    if not FindTb then
        FindTb = {}
        FindTb.Level = 0;
        FindTb.Health = 0;
        FindTb.Attack = 0;
        FindTb.Defence = 0;
        FindTb.Shield = 0;
    end
    return FindTb
end

function HouseGirlLove.GetLoveAddAttribute(InGirlId,InLevel,NeedGetLevel)
    if NeedGetLevel then
        InLevel = HouseGirlLove:GetGirlLoveLevel(InGirlId)
    end
    local Res = UE4.FHouseLoveAddAttributesCfg();
    if HouseGirlLove.tbGirlAddAttribute and HouseGirlLove.tbGirlAddAttribute[InGirlId] then
        local LevelNum = #HouseGirlLove.tbGirlAddAttribute[InGirlId];
        local FindTb = nil;
        for i = 1,LevelNum do
            local tb = HouseGirlLove.tbGirlAddAttribute[InGirlId][i]
            if i < LevelNum then
                if InLevel >= tb.Level and InLevel < HouseGirlLove.tbGirlAddAttribute[InGirlId][i+1].Level then
                    FindTb = tb;
                    break;
                end
            else
                if InLevel >= tb.Level then
                    FindTb = tb;
                end
            end
        end
        if FindTb then
            Res.Health = FindTb.Health;
            Res.Attack = FindTb.Attack;
            Res.Defence = FindTb.Defence;
            Res.Shield = FindTb.Shield;
        end
    end
    return Res;
end

function HouseGirlLove:OnParamRspCheckNewLevel(tbParam)
    --[[if not tbParam or not tbParam.GirlId or not tbParam.NewLevel then
        return
    end
    if tbParam.NewLevel % 10 == 0 then
        UI.Open('DormAttributeUp',tbParam.GirlId,tbParam.NewLevel)
    end--]]
end

return tbClass;