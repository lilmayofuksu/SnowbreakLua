-- ========================================================
-- @File    : uw_logistics_story_list.lua
-- @Brief   : 后勤履历条目
-- @Author  :
-- @Date    :
-- ========================================================
local uw_logistics_story_list = Class("UMG.SubWidget")
local tbLogiStory = uw_logistics_story_list

tbLogiStory.Log2List = {
    "/Game/UI/UI/Role2/Frames/gui_servant02_bg011_03_png.gui_servant02_bg011_03_png",
    "/Game/UI/UI/Role2/Frames/gui_servant02_bg011_04_png.gui_servant02_bg011_04_png",
    "/Game/UI/UI/Role2/Frames/gui_servant02_bg011_05_png.gui_servant02_bg011_05_png",
}

function tbLogiStory:Construct()
    self.BtnStory.OnClicked:Add(
        self,
        function()
            self.PanelOpen = not self.PanelOpen
            self:SwitchPanel(self.PanelOpen)
        end
    )
end

function tbLogiStory:OnListItemObjectSet(InParam)
    self.Data = InParam.Data
    self.Unlocked = self.Data.MaxBreak + 1 >= self.Data.UnlockStars
    self.PanelOpen = self.Data.bExpand
    self:InitStoryPanel(self.Unlocked)
    self:SwitchPanel(self.Data.bExpand)

    WidgetUtils.PlayEnterAnimation(self)
end

function tbLogiStory:Display(InParam)
    self.Data = InParam
    self.Unlocked = self.Data.MaxBreak >= self.Data.UnlockStars
    self.PanelOpen = self.Data.bExpand
    SetTexture(self.Logo2, self.Log2List[self.Data.Index])
    self:InitStoryPanel(self.Unlocked)
    self:SwitchPanel(self.Data.bExpand)
end

function tbLogiStory:InitStoryPanel(Unlocked)
    WidgetUtils.Collapsed(self.PanelOn)
    WidgetUtils.Collapsed(self.PanelOff)

    if Unlocked then
        WidgetUtils.SelfHitTestInvisible(self.PanelOn)
        self.TxtIntro:SetContent(self.Data.StoryContent)
        self.TxtName:SetText(self.Data.StoryTitle)
    else
        WidgetUtils.SelfHitTestInvisible(self.PanelOff)
        self.TxtNameOff:SetText(self.Data.StoryTitle)
        for i = 1, 6 do
            WidgetUtils.Collapsed(self["s_".. i].ImgStarOff)
            WidgetUtils.Collapsed(self["s_".. i].ImgStarNext)
            WidgetUtils.Collapsed(self["s_".. i].ImgStar)
            if i <= self.Data.UnlockStars then
                WidgetUtils.SelfHitTestInvisible(self["s_".. i].ImgStar)
            else
                WidgetUtils.SelfHitTestInvisible(self["s_".. i].ImgStarOff)
            end
        end
    end
end

function tbLogiStory:SwitchPanel(OpenPanel)
    if not self.Unlocked then return end
    WidgetUtils.Collapsed(self.ImgOpen)
    WidgetUtils.Collapsed(self.ImgClose)
    WidgetUtils.Collapsed(self.PanelIntro)
    if OpenPanel then
        WidgetUtils.HitTestInvisible(self.ImgOpen)
        WidgetUtils.HitTestInvisible(self.PanelIntro)
    else
        WidgetUtils.HitTestInvisible(self.ImgClose)
    end
end

return tbLogiStory