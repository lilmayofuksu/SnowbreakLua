-- ========================================================
-- @File    : uw_chess_map_add.lua
-- @Brief   : 新增地图界面
-- ========================================================

local view = Class("UMG.SubWidget")

local tbPathTypeCfg = {
    "不可移动",
    "点击寻路",
    "点击寻路(不走斜边)",
}

function view:Construct()
    self.tbValue = {}
    BtnAddEvent(self.BtnClose, function() self:OnClose() end)
    BtnAddEvent(self.BtnOK, function() self:OnBttonClickOK() end) 

    self:RegisterEvent(Event.ApplyCreateChessMap, function()  
        self:OnOpen()
        self.modifyType = "create"
        self.TxtTitle:SetText("创建地图")
        self.tbValue.Type = "普通"
        self.tbValue.Id = ""
        self.tbValue.Name = ""
        self.tbValue.PathType = 1
        self.tbValue.CharacterScale = 1
        self.tbValue.DefaultGroundId = 0
        self.tbValue.bAutoSave = false
        self:RefreshUI()
        self.InputId:SetIsReadOnly(false)
        WidgetUtils.Collapsed(self.TxtIdReadOnly)
    end)

    self:RegisterEvent(Event.ApplyModifyMapCreateData, function(mapId)
        self:OnOpen()
        self.modifyType = "modify"
        self.TxtTitle:SetText("修改地图")
        local tb = ChessEditor.tbMapData
        self.tbValue.Type = ChessEditor:MapTypeToTypeName(tb.tbData.Type)
        self.tbValue.Id = tb.Id
        self.tbValue.Name = tb.Name
        self.tbValue.PathType = tb.tbData.PathType
        self.tbValue.CharacterScale = tb.tbData.CharacterScale
        self.tbValue.DefaultGroundId = tb.tbData.DefaultGroundId
        self.tbValue.bAutoSave = tb.tbData.bAutoSave
        self:RefreshUI()
        self.InputId:SetIsReadOnly(true)
        WidgetUtils.Visible(self.TxtIdReadOnly)
    end)

    WidgetUtils.Collapsed(self.Root)

    self.AutoSave.OnCheckStateChanged:Add(self, function()
        self.tbValue.bAutoSave = not self.tbValue.bAutoSave
    end)
    self.TypeSelect.OnSelectionChanged:Add(self, function(_, type, c) self.tbValue.Type = type end)
    self.TypePathFinding.OnSelectionChanged:Add(self, function(_, type, c) 
        for id, name in ipairs(tbPathTypeCfg) do 
            if name == type then 
                self.tbValue.PathType = id - 1 
                break
            end
        end
    end)
    self.TypeGround.OnSelectionChanged:Add(self, function(_, type, Index) 
        for _, GridDef in pairs(ChessEditor:GetGridDef().tbList) do
            if GridDef.Layer == 1 and GridDef.Name == type then
                self.tbValue.DefaultGroundId = GridDef.Id
                return;
            end
        end
        self.tbValue.DefaultGroundId = 0 
    end)
    self.InputId.OnTextCommitted:Add(self, function(_, value) self.tbValue.Id = value end)
    self.InputName.OnTextCommitted:Add(self, function(_, value) self.tbValue.Name = value end)
    self.InputCharacterScale.OnTextCommitted:Add(self, function(_, value) self.tbValue.CharacterScale = tonumber(value) end)

    self.TypeSelect:AddOption("默认")
    self.TypeSelect:AddOption("绝地求生")
    self.TypeSelect:AddOption("自走棋")
    self.TypeSelect:SetSelectedOption("默认")

    -- 寻路类型
    for _, name in ipairs(tbPathTypeCfg) do 
        self.TypePathFinding:AddOption(name);    
    end
    self.TypePathFinding:SetSelectedOption(tbPathTypeCfg[2])
end

function view:OnBttonClickOK()
    local mapId = tonumber(self.tbValue.Id) or 0
    self.tbValue.Type = ChessEditor:MapTypeNameToType(self.tbValue.Type)
    if self.tbValue.Name == "" then 
        EventSystem.Trigger(Event.NotifyChessErrorMsg, "请输入地图名");
        return;
    end
    
    if self.modifyType == "create" then 
        if mapId <= 0 then 
            EventSystem.Trigger(Event.NotifyChessErrorMsg, "请输入地图Id，必须是正整数");
            return;
        end
        if ChessConfig:IsMapExist(ChessEditor.ModuleName, mapId) then 
            EventSystem.Trigger(Event.NotifyChessErrorMsg, "地图已经存在，请换一个地图Id");
            return;
        end
        self:OnClose()
        
        ChessConfig:CreateMap(ChessEditor.ModuleName, mapId, self.tbValue)
        ChessEditor:SetCurrentMap(mapId)    
        ChessEditor:CreateDefaultRegion(1, ChessEditor.tbMapData.tbData.tbRegions)
        ChessEditor:SetCurrentRegionId(1)
        ChessEditor:SetEditorType(ChessEditor.EditorTypeRegion)
        ChessEditor:Save()

        ChessEditor:ResetSnapshoot()
        ChessEditor:Snapshoot()

        EventSystem.Trigger(Event.NotifyModifyMapCreateData, mapId, true)

    else 
        self:OnClose()
        local tb = ChessEditor.tbMapData.tbData
        tb.Type = self.tbValue.Type
        tb.Width = self.tbValue.Width
        tb.Height = self.tbValue.Height
        tb.Name = self.tbValue.Name;
        tb.PathType = self.tbValue.PathType
        tb.CharacterScale = self.tbValue.CharacterScale
        tb.DefaultGroundId = self.tbValue.DefaultGroundId
        tb.bAutoSave = self.tbValue.bAutoSave
        ChessEditor.tbMapData.Name = tb.Name
        ChessEditor:Snapshoot()

        EventSystem.Trigger(Event.NotifyModifyMapCreateData, mapId)
    end
end

function view:RefreshUI()
    self.TypeSelect:SetSelectedOption(self.tbValue.Type)
    self.TypePathFinding:SetSelectedOption(tbPathTypeCfg[self.tbValue.PathType + 1])
    self.InputId:SetText(self.tbValue.Id)
    self.InputName:SetText(self.tbValue.Name)
    self.InputCharacterScale:SetText(self.tbValue.CharacterScale);
    self.AutoSave:SetIsChecked(self.tbValue.bAutoSave)

    local tbDef = ChessEditor:GetGridDef().tbId2Data[self.tbValue.DefaultGroundId]
    self.TypeGround:SetSelectedOption(tbDef and tbDef.Name or "无")
end

function view:OnOpen()
    ChessEditor.IsOpenSpecialUI = true
    WidgetUtils.Visible(self.Root)
    
    self.TypeGround:ClearOptions()
    self.TypeGround:AddOption("无")
    for _, GridDef in pairs(ChessEditor:GetGridDef().tbList) do
        if GridDef.Layer == 1 then
            self.TypeGround:AddOption(GridDef.Name)
        end
    end
end

function view:OnClose()
    ChessEditor.IsOpenSpecialUI = false
    WidgetUtils.Collapsed(self.Root)
end

return view