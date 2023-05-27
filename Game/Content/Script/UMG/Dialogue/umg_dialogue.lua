-- ========================================================
-- @File    : umg_dialogue.lua
-- @Brief   : 剧情
-- @Author  :
-- @Date    :
-- ========================================================

local umg_dialogue = Class("UMG.BaseWidget")
local Dialogue = umg_dialogue


function Dialogue:OnInit()
    self.__isAutoPlay = false;
    BtnAddEvent(self.Btn_review, function()
        local datas = self:GetTalkRecords()
        if datas then
            UI.Open("DialogueRecord", datas)
        end
        self:LuaSetAutoPlay(false);
    end)

    BtnAddEvent(self.Btn_automatic, function()
        if not UI.IsOpen("DialogueRecord") then 
            self:LuaSetAutoPlay(not self.__isAutoPlay)
        end
    end)

    self:DoClearListItems(self.BranchTalk_2D)
    self:DoClearListItems(self.BranchList_R)

    local isMobile = IsMobile()
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.ImgKeyDir, isMobile)
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.CustomImageAndText, not isMobile)

    --[[self:RegisterEvent(Event.PauseGame, function(bDownESC)
        self:OnClickEsc(bDownESC)            
    end)]]
end

function Dialogue:OnClickEsc(bDownESC)
    if bDownESC then
        if (self:GetDialogueType() == UE4.EDialogueType.Fight) then

        else 
            self:EndPlot();
        end
    end
end

function Dialogue:OnOpen()
    if GuideLogic.nNowStep and GuideLogic.nNowStep <= 5 then
        self.IsGuideing = true
        WidgetUtils.Collapsed(self.Btn_close)
    else
        self.IsGuideing = false
        WidgetUtils.Visible(self.Btn_close)
    end
    DialogueMgr.SetPause(false)
end

function Dialogue:OnClose()
    self:RemoveRegisterEvent()
    DialogueMgr.OnClose(UE4.EUIDialogueType.Plot, self.IsFromFight)
end

-- 打开时不聚焦
function Dialogue:DontFocus()
    return true;
end

function Dialogue:OnEndLua()
    UI.Close(self)
end

function Dialogue:LuaSetAutoPlay(value)
    if value == self.__isAutoPlay then return end 

    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.ImgPlay, not value)
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.ImgPause, value)

    self.__isAutoPlay = value
    self:GetPlot():SetAutoPlay(self.__isAutoPlay)
end

return Dialogue
