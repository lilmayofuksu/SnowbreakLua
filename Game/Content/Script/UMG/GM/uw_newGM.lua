-- ========================================================
-- @File    :
-- @Brief   :
-- @Author  :
-- @DATE    : 
-- ========================================================
local umg_newGM = Class("UMG.SubWidget")

local tbClass = umg_newGM
local ColorGreen = UE.FLinearColor(0, 1, 0, 1);
local ColorWhite = UE.FLinearColor(1, 1, 1, 1);

function tbClass:Construct()
    self.Factory = Model.Use(self);
    WidgetUtils.Hidden(self.Params)
    WidgetUtils.Hidden(self.BtnSure)
    BtnAddEvent(self.BtnClose,function () UI.Close('newGM') end)
	BtnAddEvent(self.BtnSure,function ( ... )
        if self.commandTb then
            --self:UpdateParams();
            self.commandTb.Func(self.commandTb)
            self.commandTb:SaveParam()
        end
    end)

    self:DoClearListItems(self.Params)

    self.tbTypes = {}
    for _, name in ipairs({"Func", "System", "Activity", "Fight","Level"}) do 
        local btn = self["Btn" .. name]
        self.tbTypes[name] = btn
        BtnAddEvent(btn, function () self:OnBtnClickType(name) end)
    end
    self:OnBtnClickType(self:GetLastTypeName())

    local version = UE4.UGameLibrary.GetGameIni_String("Distribution", "Version", "0");
    self.TxtVersion:SetText("V: " .. version)
    EventSystem.On('RefreshGMParams',function() self:UpdateParams() end)

    local content = LoadSetting("build_info.txt");
    local tbLine = Split(content, "\n")
    if #tbLine >= 3 then 
        content = string.format("%s-%s-%s号包\n%s", tbLine[4] or "", tbLine[1] or "", tbLine[2] or "", tbLine[3] or "")
        self.TxtTitle:SetText(content)
    else 
        self.TxtTitle:SetText("")
    end
    BtnAddEvent(self.BtnTitle, function()
        UE4.UUMGLibrary.CopyMessage(content);
        UI.ShowTip("复制成功~");
    end)
end

function tbClass:InitCategory()
    self:DoClearListItems(self.Category)
    local commands = GMCommand:GetAllCommand()
    local categoryList = GMCommand:GetAllCategory()
    local lastIndex = self:GetLastCategoryIndex()
    for i,v in ipairs(categoryList) do
    	if commands[v] then
            local tbParam = {
                category = v,
                index = i,
                bSelect = i == lastIndex,
                tbCommands = commands[v],
                onClick = function (slWidget)
                    self:UpdateSelectedCategory(slWidget)
                    self:ShowOneCategory(i, commands[v])
                    EventSystem.Trigger(Event.OnGMCategorySelect, i)
                end,
            }
            local pObj = self.Factory:Create(tbParam)
            self.Category:AddItem(pObj)
        end
        if i == lastIndex then
            self:ShowOneCategory(i, commands[v])
        end
    end
    EventSystem.Trigger(Event.OnGMCategorySelect, lastIndex)
end

function tbClass:OnCategoryAdd(slWidget)
    if slWidget.tbParam.index == self:GetLastCategoryIndex() then
        self.selectedCategory = slWidget
        self.selectedCategory:UpdateSelected(true)
    end
end

function tbClass:UpdateSelectedCategory(slWidget)
    if self.selectedCategory then
        self.selectedCategory:UpdateSelected(false)
    end
    self.selectedCategory = slWidget;
    self:SetLastCategoryIndex(slWidget.tbParam.index)
    self.selectedCategory:UpdateSelected(true)
end

function tbClass:UpdateSelectedCommand(slCommand)
    if self.selectedCommand then
        self.selectedCommand:UpdateSelected(false)
    end
    self.selectedCommand = slCommand;
    if self.selectedCommand then
        self.selectedCommand:UpdateSelected(true)
    else
        self:CheckShowParams()
    end
end

function tbClass:ShowOneCategory(categoryIndex, tbParam)
    if not tbParam then
        return
    end
    self:DoClearListItems(self.commands)
    self.tbCommandObjs = {}
    local lastIndex = self:GetLastCommandIndex(categoryIndex)
    for i, v in ipairs(tbParam) do
        local tb = {
            tbParam = v, 
            category = categoryIndex,
            index = i,
            selectedIndex = lastIndex,
            onClick = function (commandTb, commandWidget)
                self:CheckShowParams(commandTb,commandWidget)
                self:SetLastCommandIndex(categoryIndex, i)

                for _, tb in pairs(self.tbCommandObjs) do 
                    tb.selectedIndex = i
                end                
            end,
            onListAdd = function(commandTb, commandWidget)
                if i == lastIndex then 
                    self:CheckShowParams(commandTb,commandWidget)
                end
            end
        }
        local pObj = self.Factory:Create(tb)
        self.commands:AddItem(pObj)
        self.tbCommandObjs[i] = tb
    end
end

function tbClass:CountTB(tb)
    if type(tb)~='table' then
        return 0
    end
    local res = 0;
    for k,v in pairs(tb) do
        res = res + 1
    end
    return res;
end

function tbClass:UpdateParams()
    self:CheckShowParams(self.commandTb,self.commandWidget)
end

function tbClass:CheckShowParams(commandTb, commandWidget)
    if not commandTb or not commandTb.Params_sort then
        WidgetUtils.Hidden(self.Params)
        return
    end
    WidgetUtils.Visible(self.BtnSure)
    WidgetUtils.Visible(self.CommandIntro)
    self.CommandIntro:SetText(commandTb.introKey)
    self.commandTb = commandTb;
    self.commandWidget = commandWidget;
    if self:CountTB(commandTb.Params_sort) == 0 then
        WidgetUtils.Hidden(self.Params)
        --[[commandTb.Func(commandTb);
        commandTb:SaveParam()]]
    else
        WidgetUtils.Visible(self.Params)

        self:DoClearListItems(self.Params)
        for i,v in ipairs(commandTb.Params_sort) do
            local pObj = self.Factory:Create({paramTb = v,commandTb = commandTb})
            self.Params:AddItem(pObj)
        end
    end
    self:UpdateSelectedCommand(commandWidget)
end

function tbClass:OnBtnClickType(name)
    self:SetLastTypeName(name)
    for _name, btn in pairs(self.tbTypes) do 
        btn:SetBackgroundColor(_name == name and ColorGreen or ColorWhite)
    end
    GMCommand:SetType(name)
    self:InitCategory()
end

--------------------------------------------------------------
function tbClass:SetLastCategoryIndex(index)
    UE4.UUserSetting.SetInt(self.typeName .. '_LastGMCategoryIndex', index)
    UE4.UUserSetting.Save()
end

function tbClass:GetLastCategoryIndex()
    return UE4.UUserSetting.GetInt(self.typeName .. '_LastGMCategoryIndex', 1)
end

function tbClass:SetLastCommandIndex(category, index)
    UE4.UUserSetting.SetInt(self.typeName .. '_LastGMCommandIndex' .. category, index)
    UE4.UUserSetting.Save()
end

function tbClass:GetLastCommandIndex(category)
    return UE4.UUserSetting.GetInt(self.typeName .. '_LastGMCommandIndex' .. category, 1)
end

function tbClass:SetLastTypeName(name)
    self.typeName = name
    UE4.UUserSetting.SetString('LastGMTypeName', name)
    UE4.UUserSetting.Save()
end

function tbClass:GetLastTypeName()
    return UE4.UUserSetting.GetString('LastGMTypeName', "Func")
end

--------------------------------------------------------------
return tbClass;
--------------------------------------------------------------
