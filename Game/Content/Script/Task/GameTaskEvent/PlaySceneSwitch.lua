local tbClass = Class()

function tbClass:OnTrigger()
	local Widget=UE4.UWidgetBlueprintLibrary.Create(self,UE4.UClass.Load("/Game/UI/UMG/Fight/Widgets/Loading/uw_fight_scene_on.uw_fight_scene_on_C"))

	local SceneOffFunc = function ()
		local Widget2 = UE4.UWidgetBlueprintLibrary.Create(self,UE4.UClass.Load("/Game/UI/UMG/Fight/Widgets/Loading/uw_fight_scene_off.uw_fight_scene_off_C"))
	    if Widget2 then
		    Widget2:AddToViewport(2)
		    Widget2:SceneOff()
		    UE4.Timer.Add(Widget2.Time or 2,function ()
		    	Widget2:RemoveFromViewport()
		    end)
		end
	end

	local SceneTextFunc = function ()
		local WidgetTxt = UE4.UWidgetBlueprintLibrary.Create(self,UE4.UClass.Load("/Game/UI/UMG/Fight/Widgets/Loading/uw_fight_scene_switch.uw_fight_scene_switch_C"))
	    if WidgetTxt then
		    WidgetTxt:AddToViewport(1)
		    WidgetTxt.TxtDes:SetText(self.Text or 'Key')
		    UE4.Timer.Add(self.TextTime or 2,function ()
		    	--self.WidgetTxt:RemoveFromViewport()
		    	SceneOffFunc()
		    	UE4.Timer.Add(0.5,function ()
			    	if WidgetTxt then
			    		WidgetTxt:RemoveFromViewport()
			    	end
			    end)
		    end)
		end
	end

	if Widget then
        Widget:AddToViewport()
        Widget:SceneOn();
        Widget.TxtDes:SetText(Text(self.Text or 'Key'))
        UE4.Timer.Add(Widget.Time or 2,function ()
	    	Widget:RemoveFromViewport()
	    	SceneTextFunc()
	    end)
    end
end

return tbClass;