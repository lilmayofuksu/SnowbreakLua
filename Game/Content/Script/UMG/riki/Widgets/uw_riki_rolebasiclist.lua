-- ========================================================
-- @File    : uw_riki_rolebasiclist.lua
-- @Brief   : 图鉴角色基础档案
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
	self.BtnStory.OnClicked:Add(
    	self,
    	function() 
    		self.PanelOpen = not self.PanelOpen
            self:SwitchPanel(self.PanelOpen) 
        end
        )
end

function tbClass:OnListItemObjectSet(pObj)
	self.Data = pObj.Data
	self.TxtName:SetText(Text("ui.TxtRoledetail.tab1"))
	self.PanelOpen = true

	self.TxtName:SetText(self.Data.Title)
	self.TxtIntro:SetText(self.Data.Content)

	self:SwitchPanel(self.PanelOpen) 
end

function tbClass:Display(InParam)
    self.Data = InParam
    self.TxtName:SetText(Text("ui.TxtRoledetail.tab1"))
    self.PanelOpen = true

    self.TxtName:SetText(self.Data.Title)
    self.TxtIntro:SetText(self.Data.Content)

    self:SwitchPanel(self.PanelOpen,true) 
end

function tbClass:SwitchPanel(OpenPanel,bDisplay)
	WidgetUtils.Collapsed(self.ImgOpen)
    WidgetUtils.Collapsed(self.ImgClose)
    WidgetUtils.Collapsed(self.PanelIntro)

	if OpenPanel then
        WidgetUtils.HitTestInvisible(self.ImgOpen)
        WidgetUtils.HitTestInvisible(self.PanelIntro)
        local pLevelUI = UI.GetUI('RikiRoleInfo')
        if pLevelUI and not bDisplay then
            pLevelUI.ScrollBox_114:ScrollWidgetIntoView(self, false, UE4.EDescendantScrollDestination.Center, 400)
        end
    else
        WidgetUtils.HitTestInvisible(self.ImgClose)
    end
end

return tbClass