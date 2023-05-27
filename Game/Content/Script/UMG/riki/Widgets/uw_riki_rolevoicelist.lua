-- ========================================================
-- @File    : uw_riki_rolevoicelist.lua
-- @Brief   : 图鉴角色语音
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
 	BtnAddEvent(
		self.BtnPlay, 
    	function() 
    		-- print("BtnPlay.OnClicked")
    		self.Play = not self.Play
            self:SwitchPanel(self.Play) 
        end
        )
 	-- EventSystem.Remove(self.OnEndPlay)
  --   self.OnEndPlay =
  --       EventSystem.OnTarget(
  --       {},
  --       "EndRikiVoice",
  --       function()
  --           self:EventEndPlay()
  --       end
  --   )
end

function tbClass:OnDestruct()
	-- print("uw_riki_rolevoicelist OnDestruct")
	EventSystem.Remove(self.OnEndPlay)
end

function tbClass:OnListItemObjectSet(pObj)
    --print("OnListItemObjectSet:",self.Data)
    if self.Data == nil then 
    	self.Data = pObj.Data
    	WidgetUtils.Visible(self.PanelVoice)
    	WidgetUtils.Visible(self.PanelIntro)
    	WidgetUtils.Visible(self.TxtIntro)
    	WidgetUtils.Collapsed(self.ImgPause)
    	
    	WidgetUtils.Visible(self.BtnPlay)
    	WidgetUtils.HitTestInvisible(self.ImgPlay)
    	self.TxtIntro:SetText(Text(self.Data.TxtKey))

    	EventSystem.Remove(self.OnEndPlay)
        self.OnEndPlay =
            EventSystem.OnTarget(
            RikiLogic.tbType.Role,
            "EndRikiVoice",
            function()
                self:EventEndPlay()
            end
        )
    end
end

function tbClass:SwitchPanel(OpenPanel)

	WidgetUtils.Collapsed(self.ImgPlay)
    WidgetUtils.Collapsed(self.ImgPause)
    
	if OpenPanel then
        WidgetUtils.Visible(self.ImgPause)
        --print("play:",self.Data.VoiceID)
        UE4.UVoiceManager.PlayWithCallback(GetGameIns(), self.Data.pCard:AppearID(), self.Data.VoiceID,{self,self.EndPlayCallback},true,true)
    else
        WidgetUtils.Visible(self.ImgPlay)
        self:EndPlay()
    end
end

function tbClass:EndPlay()

	if UE4.UVoiceManager.IsPlaying() then
    	-- print("is IsPlaying,stop it")
    	UE4.UVoiceManager.Stop()
    else
    	-- print("not Playing, do nothing")
    end 
end

function tbClass:EndPlayCallback(paramWwise)
	-- print("EndPlayCallback self.Play:",self.Play)
	self.Play = false
	WidgetUtils.Visible(self.ImgPlay)
    WidgetUtils.Collapsed(self.ImgPause)
    -- UE4.UVoiceManager.Stop()
end

function tbClass:EventEndPlay()
	-- print("uw_riki_rolevoicelist EventEndPlay")
	if self.Play and UE4.UVoiceManager.IsPlaying() then
		WidgetUtils.Visible(self.ImgPlay)
    	WidgetUtils.Collapsed(self.ImgPause)
    	self.Play = false
    	self:EndPlay()
	end
end

return tbClass