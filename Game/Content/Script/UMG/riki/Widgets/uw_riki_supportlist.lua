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

		BtnAddEvent(self.Min, function() 
			WidgetUtils.Visible(self.CheckMark_Min)
			WidgetUtils.Collapsed(self.CheckMark_Max)
			
			self.Data.ParentUI:RefreshItemAttr()
			self:ShowBaseInfo()
			self.Data.ParentUI:UpdateSupportInfo()
		end)

		BtnAddEvent(self.Max, function() 
			WidgetUtils.Collapsed(self.CheckMark_Min)
			WidgetUtils.Visible(self.CheckMark_Max)
			
			self.Data.ParentUI:RefreshItemAttr(true)
			self:ShowBaseInfo()
			self.Data.ParentUI:UpdateSupportInfo(true)
		end)

	self.tbSuitSkill = {
        self.TxtSuitInfo2,
        self.TxtSuitInfo3,
    }
end

function tbClass:OnListItemObjectSet(pObj)
	self.Data = pObj.Data

	self:SwitchPanel(true)
end

function tbClass:Display(InParam)
	-- Dump(InParam)
	self.Data = InParam

	self:SwitchPanel(true)
end

function tbClass:SwitchPanel(OpenPanel)
	self.PanelOpen = OpenPanel
	--基础信息
	if self.Data.nType == 1 then
		WidgetUtils.Collapsed(self.PanelIntro)
		if OpenPanel then
			WidgetUtils.Visible(self.PanelIntroBase)
		else
			WidgetUtils.Collapsed(self.PanelIntroBase)
		end

		self:ShowBaseInfo()
	else
		WidgetUtils.Collapsed(self.PanelIntroBase)
		if OpenPanel then
			WidgetUtils.Visible(self.PanelIntro)
		else
			WidgetUtils.Collapsed(self.PanelIntro)
		end

		self:ShowTeamInfo()
	end
end

function tbClass:ShowBaseInfo()
	self.TxtName:SetText(Text("ui.TxtRoledetail.tab1"))
	local pItem = self.Data.pItem
	local GrowupID= Logistics.GetSupportGrowupIDByGDPL(pItem:Genre(), pItem:Detail(), pItem:Particular(), pItem:Level())
    local tbGrow = Logistics.tbGrow[GrowupID]
	local nLv = pItem:EnhanceLevel()
	local nBreakLv = pItem:Break()
	local tbInfo = {}
    for i, v in pairs(tbGrow) do
        if string.find(tostring(i), "_break") then
			if nBreakLv ~= 0 then
				table.insert(tbInfo, { Attr = v[#v][2], sType = i, IsPercent = not (i == "Command_break"),})
			else
				table.insert(tbInfo, { Attr = v[1][2], sType = i, IsPercent = not (i == "Command_break"),})
			end
        else
            table.insert(tbInfo, { Attr = v[nLv][2], sType = i})
        end
    end

	for index=1,3 do
		if tbInfo[index] then
			WidgetUtils.Visible(self['Attr'..index])
			self['Attr'..index]:Display(tbInfo[index])
		else
			WidgetUtils.Collapsed(self['Attr'..index])
		end
	end
end

function tbClass:ShowTeamInfo()
	self.TxtName:SetText(Text("ui.TxtRoledetail.tab1"))
	local pItem = self.Data.pItem
	local sGDPL = string.format("%d-%d-%d-%d", pItem:Genre(), pItem:Detail(), pItem:Particular(), pItem:Level())
	local cfg = Logistics.tbLogiData[sGDPL]
    if not cfg then 
        UI.ShowTip(Text("congif_err"))
        return
    end

	local SuitSkillId = UE4.TArray(UE4.int32)
	pItem:GetSuitFirstSkills(2, SuitSkillId)
    pItem:GetSuitFirstSkills(3, SuitSkillId)

	--local SuitSkill = UE4.TArray(UE4.int32)
	self.TxtName:SetText(Text('ui.TxtTeamSkill'))
	self.TxtSuitName:SetText(SkillName(SuitSkillId:Get(1)))

	for index, pWidget in ipairs(self.tbSuitSkill) do
		pWidget:SetContent(SkillDesc(SuitSkillId:Get(index)))
    end
end

return tbClass