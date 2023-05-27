-- ========================================================
-- @File    : uw_setup_language_list.lua
-- @Brief   : 语音包item
-- ========================================================

---@class tbClass : UUserWidget
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    
end

function tbClass:OnListItemObjectSet(pObj)
    local tbParam = pObj.Data
    self.TxtName:SetText(Text('setting.'..tbParam.Label))
    self.Num:SetText(tbParam.Size)
    pObj.OnReady = function ()
      self:ActiveSize(false)
    end

    pObj.NoReady = function ()
      self:ActiveSize(true)
    end

    pObj.OnRadio = function (bSelected)
      if bSelected then
        WidgetUtils.SelfHitTestInvisible(self.ImgSl)
      else
        WidgetUtils.Collapsed(self.ImgSl)
      end
    end

    BtnClearEvent(self.BtnSeleted)
    BtnAddEvent(self.BtnSeleted, tbParam.pSelect)
    self:CheckUse(tbParam.Index)
    pObj.OnRadio(tbParam.Index == 1)
end

function tbClass:CheckUse(Index)
  local curLan = Localization.GetCurrentVoiceLanguage()
  local tbLanguage = Localization.tbVoiceLanguage
  if curLan == tbLanguage[Index] then
    WidgetUtils.SelfHitTestInvisible(self.TxtUse)
  else
    WidgetUtils.Collapsed(self.TxtUse)
  end
end

function tbClass:ActiveSize(bShow)
    if bShow then
      WidgetUtils.SelfHitTestInvisible(self.Txt1)
      WidgetUtils.SelfHitTestInvisible(self.Txt2)
      WidgetUtils.SelfHitTestInvisible(self.Num)
    else
      WidgetUtils.Collapsed(self.Txt1)
      WidgetUtils.Collapsed(self.Txt2)
      WidgetUtils.Collapsed(self.Num)
    end
end

return tbClass