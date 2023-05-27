-- ========================================================
-- @File    : uw_riki_rolelist2.lua
-- @Brief   : 角色个人故事条目
-- @Author  :
-- @Date    :
-- ========================================================
-- local uw_logistics_story_list = Class("UMG.SubWidget")
-- local tbClass = uw_logistics_story_list
local tbClass = Class("UMG.SubWidget")

tbClass.Log2List = {
    "/Game/UI/UI/Role2/Frames/gui_servant02_bg011_03_png.gui_servant02_bg011_03_png",
    "/Game/UI/UI/Role2/Frames/gui_servant02_bg011_04_png.gui_servant02_bg011_04_png",
    "/Game/UI/UI/Role2/Frames/gui_servant02_bg011_05_png.gui_servant02_bg011_05_png",
}

function tbClass:Construct()
    self.BtnStory.OnClicked:Add(
        self,
        function()
            self.PanelOpen = not self.PanelOpen
            self:SwitchPanel(self.PanelOpen)
        end
    )

    BtnAddEvent(
		self.BtnPlay, 
    	function() 
    		-- print("OnBtnPlayClicked")
    		if self.ClickFun then 
    			self.ClickFun(self.Data.tbCfg) 
    		end 
        end
        )

    BtnAddEvent(
		self.BtnLock, 
    	function() 
    		print("OnBtnLockClicked")
    		if self.CheckFun then 
    			self.CheckFun(self.Data.tbCfg,self.sLockDes) 
    		end 
        end
        )

    BtnAddEvent(
        self.BtnGo, 
        function() 
            if not self.Data.tbChapterCfg then return end
            if self.Data.tbChapterCfg.tbCondition then
                local bUnLock, sLockDes = Condition.Check(self.Data.tbChapterCfg.tbCondition)
                if bUnLock == false then
                    local tbCon = self.Data.tbChapterCfg.tbCondition[1]
                    if tbCon[1] == 3 then 
                        local g, d, p, l = table.unpack(tbCon, 2, #tbCon)
                        if g and d and p and l then 
                            local iteminfo = UE4.UItem.FindTemplate(g, d, p, l)
                            if iteminfo then 
                                local name
                                if p == 1 then
                                    name = Text(iteminfo.I18N)
                                else
                                    name = Text(iteminfo.I18N) .. '—' .. Text(iteminfo.I18N..'_title')
                                end
                                UI.ShowTip(Text('ui.TxtRoleLock', name))
                                return            
                            end
                        end
                    end
                    UI.ShowTip(sLockDes[1])
                    return
                end
            end
            UI.Open("DungeonsRoleMap", self.Data.tbChapterCfg)
        end
        )
end

function tbClass:OnListItemObjectSet(InParam)
    self.Data = InParam.tbData
    -- self.tbCfg = self.Data.tbCfg
    -- Dump(self.Data)
    -- Dump(self.Data.tbCfg)--tbCfg.sDes
    self.ClickFun = InParam.tbData.ClickFun
    self.CheckFun = InParam.tbData.CheckFun
    self.Unlocked = self.Data.bUnlocked
    
    self.PanelOpen = self.Data.bExpand
    if Role.IsOPen() then
    	Launch.SetType(LaunchType.ROLE)
	end
	local tbCond = {}
    table.insert(tbCond,{Condition.PRE_LEVEL,self.Data.tbCfg.nID})
    local bUnLock, sLockDes = Condition.Check(tbCond)

    self.sLockDes = sLockDes
    self:InitStoryPanel(self.Unlocked)
    self:SwitchPanel(self.Data.bExpand)

    WidgetUtils.PlayEnterAnimation(self)

    
end

function tbClass:Display(InParam)
    self.Data = InParam
    self.Unlocked = self.Data.bUnlocked
    self.PanelOpen = self.Data.bExpand
    SetTexture(self.Logo2, self.Log2List[self.Data.Index])
    self:InitStoryPanel(self.Unlocked)
    self:SwitchPanel(self.Data.bExpand)
end

function tbClass:InitStoryPanel(Unlocked)
    WidgetUtils.Collapsed(self.PanelOn)
    WidgetUtils.Collapsed(self.PanelOff)
    self.TxtNameOff:SetText(GetLevelName(self.Data.tbCfg))
    -- self.TxtName:SetText(GetLevelName(self.Data.tbCfg))
    if Unlocked then
    	print("Unlocked")
        WidgetUtils.SelfHitTestInvisible(self.PanelOn)
        self.TxtIntro:SetText(Text(self.Data.tbCfg.sDes))
        -- self.TxtName:SetText(self.Data.StoryTitle)
        self.TxtName:SetText(GetLevelName(self.Data.tbCfg))
    else
    	print("locked")
        WidgetUtils.SelfHitTestInvisible(self.PanelOff)
        -- self.TxtNameOff:SetText(self.Data.StoryTitle)
        self.TxtNameOff:SetText(GetLevelName(self.Data.tbCfg))

        -- local tbCond = {}
        -- table.insert(tbCond,{Condition.PRE_LEVEL,self.Data.tbCfg.nID})
        -- local bUnLock, sLockDes = Condition.Check(tbCond)
        self.TxtStoryLock:SetText(Text(self.sLockDes[1]))
        -- print("GetLevelName(self.Data.tbCfg):",GetLevelName(self.Data.tbCfg))
    end
end

function tbClass:SwitchPanel(OpenPanel)
    if not self.Unlocked then 
    	-- print("open failed")
    	return 
    end


    WidgetUtils.Collapsed(self.ImgOpen)
    WidgetUtils.Collapsed(self.ImgClose)
    WidgetUtils.Collapsed(self.PanelIntro)
    if OpenPanel then
        WidgetUtils.HitTestInvisible(self.ImgOpen)
        -- WidgetUtils.HitTestInvisible(self.PanelIntro)
        WidgetUtils.Visible(self.PanelIntro)
        -- WidgetUtils.HitTestInvisible(self.BtnPlay)
        WidgetUtils.Visible(self.BtnPlay)
        
     --    if self.ClickFun then 
    	-- 	self.ClickFun(self.Data.tbCfg) 
    	-- end 
    else
        WidgetUtils.HitTestInvisible(self.ImgClose)
    end
end

return tbClass