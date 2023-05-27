-- ========================================================
-- @File    : uw_logistics_story.lua
-- @Brief   : 角色后勤界面
-- @Author  :
-- @Date    :
-- ========================================================

local LogiStory = Class("UMG.BaseWidget")

LogiStory.QualityImg = {
    "/Game/UI/UI/Common/Frames/gui_role08_other002_01_png.gui_role08_other002_01_png",
    "/Game/UI/UI/Common/Frames/gui_role08_other002_02_png.gui_role08_other002_02_png",
    "/Game/UI/UI/Common/Frames/gui_role08_other002_03_png.gui_role08_other002_03_png",
    "/Game/UI/UI/Common/Frames/gui_role08_other002_04_png.gui_role08_other002_04_png",
}

local StoryListItem = "/Game/UI/UMG/Support/LogisStory/Widgets/uw_logistics_story_list.uw_logistics_story_list_C"
function LogiStory:Construct()
    -- self.StoryFactory = Model.Use(self)
    self.BtnSwitch:SetClickMethod(UE4.EButtonClickMethod.MouseDown)
    self.BtnSwitch:SetTouchMethod(UE4.EButtonTouchMethod.Down)
    self.BtnSwitch.OnCheckStateChanged:Add(
        self,
        function()
            self:ChangeState()
        end
    )
    WidgetUtils.Collapsed(self.PanelLock)
end

function LogiStory:OnActive(InCard)
    --- 播放All Enter动画
    self:PlayAnimation(self.AllEnter, 0, 1 ,UE4.EUMGSequencePlayMode.Forward, 1, false)

    self.SupportCard = InCard
    self.gdp = string.format("%s-%s-%s", self.SupportCard:Genre(), self.SupportCard:Detail(), self.SupportCard:Particular())
    self.gdpl = string.format("%s-%s-%s-%s", self.SupportCard:Genre(), self.SupportCard:Detail(), self.SupportCard:Particular(), self.SupportCard:Level())
    -- 后勤卡的最大突破
    self.MaxBreak = Logistics.GetBreakMax(InCard)
    -- 是否展示突破立绘
    self.ShowBreakImg = InCard:Break() + 1 >= self.MaxBreak
    self.TextName:SetText(Text(InCard:I18n()))

    SetTexture(self.ImgQuality, LogiStory.QualityImg[InCard:Color() - 1])
    -- 角色拥有的同名后勤卡的最大突破
    self.NowMaxBreak = self:GetNowMaxBreak()
    self:InitImg()
    self:InitStory()
end

--- 获得icon的texture
function LogiStory:GetTexture(InIconId, InType)
    local path = Resource.Get(Resource.GetPaintingID(InIconId, InType))
    if not path then return end
    if type(path) == 'string' then
        path = UE4.UKismetSystemLibrary.MakeSoftObjectPath(path)
    end
    return UE4.UGameAssetManager.GameLoadAsset(path)
end

function LogiStory:InitImg()
    local icon = self.SupportCard:Icon()
    if self.SupportCard:Break() + 1 >= self.MaxBreak then
        local imgB = icon
        SetTexture(self.ImgPoseB, imgB, true)
    elseif self.NowMaxBreak + 1 >= self.MaxBreak then
        local imgB = self.SupportCard:IconBreak()
        SetTexture(self.ImgPoseB, imgB, true)
    else
        local mat = self.ImgPoseB:GetDynamicMaterial()
        local texture = self:GetTexture(self.SupportCard:IconBreak(), self.ImgPoseB.PaintingType)
        if texture then
            mat:SetTextureParameterValue("image", texture)
        end
    end

    WidgetUtils.Collapsed(self.PanelLock)
    WidgetUtils.Collapsed(self.ImgPoseB)
    if self.ShowBreakImg then
        WidgetUtils.HitTestInvisible(self.TxtLogisStoryB)
        WidgetUtils.Collapsed(self.TxtLogisStoryA)
    else
        WidgetUtils.HitTestInvisible(self.TxtLogisStoryA)
        WidgetUtils.Collapsed(self.TxtLogisStoryB)
    end

    if self.SupportCard:Color() <= 3 then
        WidgetUtils.Collapsed(self.BtnSwitch)
    end
end

--- 获取角色拥有的同名后勤卡的最大突破
function LogiStory:GetNowMaxBreak()
    local s = me:GetStrAttribute(41, 1)
    local attrs = json.decode(s)
    if (not attrs) or (not tonumber(attrs[self.gdp])) then
        return self.SupportCard:Break()
    end
    return tonumber(attrs[self.gdp])
end

--- 切换显示状态
function LogiStory:ChangeState()
    self.ShowSwitchImg = not self.ShowSwitchImg
    self.ShowBreakImg = not self.ShowBreakImg
    WidgetUtils.Collapsed(self.PanelLock)
    if self.ShowSwitchImg then
        EventSystem.TriggerTarget(Logistics, "SetTextureVisible")
        WidgetUtils.HitTestInvisible(self.ImgPoseB)
    else
        WidgetUtils.Collapsed(self.ImgPoseB)
        EventSystem.TriggerTarget(Logistics, "SetTextureVisible", true)
    end
    if self.ShowBreakImg then
        WidgetUtils.Collapsed(self.TxtLogisStoryA)
        WidgetUtils.HitTestInvisible(self.TxtLogisStoryB)
    else
        WidgetUtils.HitTestInvisible(self.TxtLogisStoryA)
        WidgetUtils.Collapsed(self.TxtLogisStoryB)
    end

    if self.ShowSwitchImg and self.ShowBreakImg and self.NowMaxBreak + 1 < self.MaxBreak then
        WidgetUtils.HitTestInvisible(self.PanelLock)
    end
end

function LogiStory:InitStory()
    self.ListStory:ClearChildren()
    local cfg = Logistics.tbLogiData[self.gdpl]
    if not cfg then 
        UI.ShowTip(Text("congif_err"))
        return
    end
    local storyUnlock = cfg.StoryUnlock
    local I18n = cfg.I18n
    for i = 1, #storyUnlock do
        local tbParam = {
            Index = i,
            SupportCard = self.SupportCard,
            StoryTitle = Text("ui.TxtSupportStorytitle"..i),
            StoryContent = Text(I18n.. "_story".. i) or "Story"..i,
            UnlockStars = storyUnlock[i],
            MaxBreak = self.NowMaxBreak,
            bExpand = i == 1
        }
        local pWidget = LoadWidget(StoryListItem)
        if pWidget then
            local child = self.ListStory:AddChild(pWidget)
            child:SetHorizontalAlignment(UE4.EHorizontalAlignment.HAlign_Right)
            pWidget:Display(tbParam)
        end
        -- local newStory = self.StoryFactory:Create(tbParam)
    end
end

function LogiStory:OnDestruct()
    EventSystem.TriggerTarget(Logistics, "SetTextureVisible", true)
end
return LogiStory