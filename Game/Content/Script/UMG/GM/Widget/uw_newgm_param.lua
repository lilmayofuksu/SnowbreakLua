-- ========================================================
-- @File    :
-- @Brief   :
-- @Author  :
-- @DATE    : ${date} ${time}
-- ========================================================
local uw_newgm_param = Class("UMG.SubWidget")

local tbClass = uw_newgm_param

function tbClass:Construct()
    self.Input.OnTextCommitted:Add(self, function(_, str)
        self.tbParam.commandTb:SetParam(self.tbParam.paramTb.name, str)
    end)

    self.TypeSelect.OnSelectionChanged:Add(self, function(_, type, c) 
        self.tbParam.commandTb:SetParam(self.tbParam.paramTb.name, type)
    end)

    WidgetUtils.Collapsed(self.TypeComboBox)
end

function tbClass:OnListItemObjectSet(pObj)
	local tbParam = pObj and pObj.Data
	if not tbParam then
		return
	end

    local tbOtherParam = tbParam.paramTb.param or {}
    local title = tbParam.paramTb.desc or (Text('gm.'..tbParam.paramTb.name) or tbParam.paramTb.name);
    self.tbParam = tbParam
    local str = UE4.UUserSetting.GetString('GM.'..tbParam.commandTb.Category..'.'..tbParam.commandTb.CommandName..'.'..tbParam.paramTb.name, 'null')
    if str == 'null' then
        str = tbParam.paramTb.stringValue
    end
    tbParam.commandTb:SetParam(tbParam.paramTb.name, str)
    
    if tbOtherParam.type == "combo" then 
        self.TitleCombo:SetText(title)
        WidgetUtils.Collapsed(self.TypeInput)
        WidgetUtils.SelfHitTestInvisible(self.TypeComboBox)

        self.TypeSelect:ClearOptions()
        for _, v in ipairs(tbOtherParam.value) do 
            self.TypeSelect:AddOption(v)
        end
        self.TypeSelect:SetSelectedOption(str)

    else 
        self.Text:SetText(title)
        WidgetUtils.SelfHitTestInvisible(self.TypeInput)
        WidgetUtils.Collapsed(self.TypeComboBox)
        self.Input:SetText(str)
    end
end



return uw_newgm_param;
