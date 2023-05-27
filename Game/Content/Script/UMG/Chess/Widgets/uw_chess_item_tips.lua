-- ========================================================
-- @File    : uw_chess_item_tips.lua
-- @Brief   : 背包分类条目
-- ========================================================

local view = Class("UMG.SubWidget")

--[[
tbParam = 
{
    needMoveTo = false,     -- 是否需要移动
    groundActor = nil,      -- 移动目的地，如果没有表示不可到达
    actor = nil,            -- 点击的actor
    tbTarget = nil,         -- lua中对象
}
--]]
function view:Construct()
    WidgetUtils.Collapsed(self.Root)

    BtnAddEvent(self.BtnClose, function() self:OnClose() end)
    BtnAddEvent(self.BtnNo, function() self:OnBtnClickNo() end)
    BtnAddEvent(self.BtnGo, function() self:OnBtnClickGo() end)

    self:RegisterEvent(Event.NotifyShowChessItemTip, function(tbParam) 
        self:OnOpen(tbParam)
    end)

    self.Factory = Model.Use(self);
    self:DoClearListItems(self.DropList)
end


function view:OnOpen(tbParam)
    self.tbParam = tbParam
    local classHandler = tbParam.tbTarget.classHandler

    WidgetUtils.SelfHitTestInvisible(self.Root)
    ChessClient:SetIsUIMode(true)
    WidgetUtils.Collapsed(self.PanelItem)
    WidgetUtils.Collapsed(self.Level)

    local tbDef = ChessClient:GetGridDef(tbParam.tbTarget.cfg.tpl)

    if tbDef.ClassName == "npc" then
        local classArg = tbParam.tbTarget.cfg.tbData.classArg
        if classArg and classArg.id and #classArg.id > 0 then
            local npcId = classArg.id[1]
            local tbNpcCfg = ChessClient:GetNpcDef(npcId)
            self.Name:SetText(Text(tbNpcCfg.Name))
            self.TxtDes:SetContent(Text(tbNpcCfg.Desc))
            if tbNpcCfg.Icon then
                SetTexture(self.Icon, tbNpcCfg.Icon, true)
            end
        end
    else
        local ClassHandleDesc = classHandler and classHandler.GetTipsDesc and classHandler:GetTipsDesc()
        self.Name:SetText(Text(tbDef.NameKey))

        if ClassHandleDesc then
            self.TxtDes:SetContent(Text(ClassHandleDesc))
        else
            self.TxtDes:SetContent(Text(tbDef.DescKey))
        end

        if tbDef.Icon then 
            SetTexture(self.Icon, tbDef.Icon, true)
        end
    end
    WidgetUtils.Collapsed(self.BtnNo)
    WidgetUtils.Collapsed(self.BtnGo)

    if not tbDef or not tbDef.Interaction or (classHandler and classHandler.HideTipsButton and classHandler:HideTipsButton()) then 
        WidgetUtils.Collapsed(self.PanelBtn)
        return
    end

    WidgetUtils.SelfHitTestInvisible(self.PanelBtn)
    if tbParam.tbTarget.classHandler and tbParam.tbTarget.classHandler.GetPreviewInfo then
        local AllItems, Rank = tbParam.tbTarget.classHandler:GetPreviewInfo()
        WidgetUtils.SelfHitTestInvisible(self.PanelItem)
        WidgetUtils.SelfHitTestInvisible(self.Level)
        self.TxtLevelNum:SetText(Rank)
        self.DropList:ClearListItems()
        for _, ItemData in ipairs(AllItems) do
            for _, item in ipairs(ItemData.tbItems) do
                local tbData = {
                    G = item[1], 
                    D = item[2], 
                    P = item[3],  
                    L = item[4],  
                    N = item[5] or 1,
                    bIsFirst = ItemData.bIsFirst,
                    bGeted = ItemData.bGeted,
                }
                local pObj = self.Factory:Create(tbData);
                self.DropList:AddItem(pObj)
            end
        end
    end

    if tbParam.actor and tbParam.actor.GetObjectId and ChessData:GetObjectIsUsed(tbParam.actor:GetObjectId()) == 1 then
        self.TxtNoDesc:SetText("TxtChessInvalid")
        WidgetUtils.Visible(self.BtnNo)
    elseif tbParam.tbTarget.cfg.tbData and tbParam.tbTarget.cfg.tbData.id and ChessData:GetObjectIsUsed(tbParam.tbTarget.cfg.tbData.id[1]) == 1 then
        self.TxtNoDesc:SetText("TxtChessInvalid")
        WidgetUtils.Visible(self.BtnNo)
    elseif tbParam.tbTarget.classHandler and tbParam.tbTarget.classHandler.CanInteraction and not tbParam.tbTarget.classHandler:CanInteraction() then
        self.TxtNoDesc:SetText("TxtChessInvalid")
        WidgetUtils.Visible(self.BtnNo)
    else
        if self.tbParam.needMoveTo then
            if self.tbParam.groundActor then 
                self.TxtGoDesc:SetText(Text("TxtChessbutton1"))
                WidgetUtils.Visible(self.BtnGo)
            else
                self.TxtNoDesc:SetText("TxtChessbutton2")
                WidgetUtils.Visible(self.BtnNo)
            end
        else 
            self.TxtGoDesc:SetText(Text("TxtDormRoomInteract"))
            WidgetUtils.Visible(self.BtnGo)
        end
    end
end

function view:OnClose()
    WidgetUtils.Collapsed(self.Root)
    ChessClient:SetIsUIMode(false)
end

function view:OnBtnClickGo()
    local controller = ChessClient:GetPlayerController()
    local actor = self.tbParam.actor;
    if self.tbParam.needMoveTo and self.tbParam.groundActor then 
        controller:MoveToGround(self.tbParam.groundActor,  {self, function()
            if not actor.OnlyFrontWalkable then 
                controller:LookAtTarget(actor)
            end
            if not actor:HasTag("dontInteractAfterMove") then
                ChessTools:ApplyInteraction(actor)
            end
        end})
    elseif not self.tbParam.needMoveTo then 
        ChessTools:ApplyInteraction(actor)
        if not actor.OnlyFrontWalkable then 
            controller:LookAtTarget(actor)
        end
    end
    self:OnClose()
end

function view:OnBtnClickNo()
    self:OnClose()
end


return view