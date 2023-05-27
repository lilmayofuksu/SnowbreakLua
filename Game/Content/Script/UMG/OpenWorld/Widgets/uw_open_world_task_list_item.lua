-- ========================================================
-- @File    : uw_open_world_task_list_item.lua
-- @Brief   : 
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(pObj)
   local tbParam = pObj.Data
   if tbParam.desc then 
      self.Des:SetText(tbParam.desc)
      return
   end

   tbParam.onDataChange = function(Execute) 
      self:DataChange(Execute)
   end
   self:DataChange(tbParam.Execute)
end


function tbClass:DataChange(Execute)
   print("uw_open_world_task_list_item on data change", Execute);
   
   local CurrentState = Execute:GetNodeState()
   local Des = Execute:GetExecuteDescription()
   local DesWithoutRich = Execute:GetExecuteDescription(true)

   WidgetUtils.Collapsed(self.Progress)
   WidgetUtils.Collapsed(self.Fail)
   WidgetUtils.Collapsed(self.Succ)
   WidgetUtils.Collapsed(self.Disable)
   if CurrentState == UE4.ENodeState.Normal then
      WidgetUtils.SelfHitTestInvisible(self.Disable)
   elseif CurrentState == UE4.ENodeState.Succeeded then
      WidgetUtils.SelfHitTestInvisible(self.Succ)
      if not self.bTriggerFightTip then
         EventSystem.Trigger(Event.FightTip, {Type = 1, Msg = DesWithoutRich})
         self.bTriggerFightTip = true
      end
   elseif CurrentState == UE4.ENodeState.Failed then
      WidgetUtils.SelfHitTestInvisible(self.Succ)
      if not self.bTriggerFightTip then
         EventSystem.Trigger(Event.FightTip, {Type = 0, Msg = DesWithoutRich})
         self.bTriggerFightTip = true
      end
   elseif CurrentState == UE4.ENodeState.InProgress then
      WidgetUtils.HitTestInvisible(self)
      WidgetUtils.SelfHitTestInvisible(self.Progress)
   end
    
   self.Des:SetText(Des)
   local StateImg = self:GetStateImg(CurrentState)
   if StateImg then
      self.Flag:SetBrushFromAtlasInterface(StateImg, true)
   end
   self:SetState(CurrentState)
end


function tbClass:GetStateImg(InState)
   if InState == UE4.ENodeState.Normal then
      return self.DisableImg
   elseif InState == UE4.ENodeState.Succeeded then
      return self.FinishImg
   elseif InState == UE4.ENodeState.InProgress then
      return self.ProgressImg
   end
   return self.DisableImg
end

return tbClass