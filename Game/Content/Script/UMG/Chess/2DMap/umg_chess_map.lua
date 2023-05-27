-- ========================================================
-- @File    : umg_chess_map.lua
-- @Brief   : 棋盘 - 2D设计界面 
-- ========================================================

local view = Class("UMG.BaseWidget")

local KeySpace = UE4.UUMGLibrary.GetFKey("SpaceBar")
local KeyLeftCtrl = UE.UUMGLibrary.GetFKey("LeftControl")
local KeyZ = UE.UUMGLibrary.GetFKey("Z")
local KeyS = UE.UUMGLibrary.GetFKey("S")
local KeyY = UE.UUMGLibrary.GetFKey("Y")
local keyDelete = UE.UUMGLibrary.GetFKey("Delete")
local KeyLeftMouseButton = UE.UUMGLibrary.GetFKey("LeftMouseButton")

function view:OnInit()
    self.playerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
    WidgetUtils.ShowMouseCursor(self, true)
    -- UE4.UKismetSystemLibrary.ExecuteConsoleCommand(self, "DisableAllScreenMessages")

    BtnAddEvent(self.uw_chess_map_menu.BtnClose, function() self:HideChessMap() end)
    self:RegisterEvent(Event.NotifyHideChessMap, function() self:HideChessMap() end)
end

function view:OnOpen()
    if not ChessEditor.ModuleName then
        if ChessClient.nextModuleName then 
            ChessEditor.ModuleName = ChessClient.nextModuleName
            ChessEditor.CurrentMapId = ChessClient.nextMapId
        else 
            ChessEditor.ModuleName = UE4.UUserSetting.GetString('ChessEdtorModuleName', "dlc1")
            ChessEditor.CurrentMapId = UE4.UUserSetting.GetInt('ChessEdtorModuleMapId', 0)
        end
    end
    EventSystem.Trigger(Event.NotifyChess2DMapOpened)
    ChessEditor:Snapshoot()
    ChessClient:SetIsUIMode(true)
    GM.TryClose()
end

function view:SetShowOrHide()
    if WidgetUtils.IsVisible(self.Root) then
        self:HideChessMap()
        ChessEditor:TryAutoSave()
        ChessEditor:RunFromLastRegion()
    else
        ChessClient:SetIsUIMode(true)
        WidgetUtils.SelfHitTestInvisible(self.Root)
        GM.TryClose()
    end
end

function view:HideChessMap()
    WidgetUtils.Collapsed(self.Root)
    ChessClient:SetIsUIMode(false)
    EventSystem.Trigger(Event.NotifyChessExitGridHintMode)
    GM.TryOpenAdin()
end

function view:Tick()
    if self.playerController:WasInputKeyJustPressed(KeySpace) then
        self:SetShowOrHide()
    end
    if not WidgetUtils.IsVisible(self.Root) then return end

    -- ChessEditor.WasLeftMouseJustPressed = self.playerController:WasInputKeyJustPressed(KeyLeftMouseButton)
    ChessEditor.IsCtrlDown = self.playerController:IsInputKeyDown(KeyLeftCtrl)
    if ChessEditor.IsCtrlDown then 
        if self.playerController:WasInputKeyJustPressed(KeyZ) then
            ChessEditor:Undo()
        elseif self.playerController:WasInputKeyJustPressed(KeyY) then
            ChessEditor:Redo()
        elseif self.playerController:WasInputKeyJustPressed(KeyS) then 
            ChessEditor:Save()
        end
    end

    -- delete
    if self.playerController:WasInputKeyJustPressed(keyDelete) then 
        ChessEditor:DeleteSelectedObject()
    end

    -- if self.playerController:WasInputKeyJustPressed(KeyRightMouseButton) then
    --     RightDownTime = os.clock()
    -- end
    -- if self.playerController:WasInputKeyJustReleased(KeyRightMouseButton) and os.clock() - RightDownTime < 0.15 then
    --     WidgetUtils.SelfHitTestInvisible(self.uw_chess_right_menu)
    --     self.uw_chess_right_menu:Show({{"右键菜单", function() UI.ShowMessage('右键菜单') end}})
    -- end
end


function view:OnMouseWheel(MyGeometry, MouseEvent)
    self.uw_chess_map_center:OnMouseWheel(MyGeometry, MouseEvent)
    return UE4.UWidgetBlueprintLibrary.Handled()
end

return view