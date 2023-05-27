-- ========================================================
-- @File    : uw_arms_evoluation.lua
-- @Brief   : 武器进化
-- ========================================================

---@class tbClass
---@field pWeapon UWeaponItem 
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
   self.bInitScreen = false
   BtnAddEvent(self.EvoluationBtn, function() self:DoEvolution() end)
end

function tbClass:OnDestruct()
end

function tbClass:OnActive(pWeapon)
    self.pWeapon = pWeapon
    if not self.pWeapon then return end
    self.lastSelectParam = nil

    self:InitSort()

    self:InitGrid()

    self:Update()

    SetTexture(self.Logo, self.pWeapon:Icon())

    ---模型显示
    Weapon.PreviewShow(self.pWeapon)
    Preview.PlayCameraAnimByCallback(self.pWeapon:Id(), PreviewType.weapon_evolution, nil)

    local icon, _, _ = Cash.GetMoneyInfo(Cash.MoneyType_Silver)
    SetTexture(self.ImgMoney, icon)
end

function tbClass:InitSort()
    self.bShowSelect = false

    WidgetUtils.Collapsed(self.Select)
    ---排序处理
    self.tbCurSort = {nIdx = 1, bReverse = false}
    -- 排序
    self.tbSortParam = {}
    self.tbSortParam.tbSortInfos = {}
    self.tbSortParam.tbSortInfos[1] = {
      {
          tbSorts = ItemSort.WeaponLevelSort,
          sName = "ui.item_level"
      },
      {
          tbSorts = ItemSort.WeaponColorSort,
          sName = "ui.TxtRareSort"
      },
      {
          tbSorts = ItemSort.WeaponExpSort,
          sName = "ui.TxtScreen14"
      },
     }
     
     self.tbSortParam.fSort = function(nIdx, bReverse)
          self.tbCurSort = {nIdx = nIdx, bReverse = bReverse}
          self:UpdateSelectInfo()
     end
    
    self.tbSortInfo = self.tbSortParam.tbSortInfos
end

function tbClass:OnDisable()
end

function tbClass:InitGrid()
     ---构建材料
     self.gridParam = {
        pItem = nil,
        nNum = 0,
        nNeedNum = nil,
        fClick = function() self:ShowSelect() end,
        tbCostMat = self:GetCostMat(),
    }

    self.Grid:Display(self.gridParam)
end

---UI数据刷新
function tbClass:Update()
    local Skills = UE4.TArray(0)
    self.pWeapon:GetSkills(self.pWeapon:EnhanceLevel(), Skills)
    if Skills:Length() <= 0 then
        return
    end

    ---技能ID
    local nSkillId = Skills:Get(1)

    ---达到最大进化等级
    if Weapon.IsEvolutionMax(self.pWeapon) then
        WidgetUtils.SelfHitTestInvisible(self.PanelEvoMax)
        WidgetUtils.Collapsed(self.PanelEvo)
        self:ShowSkillInfo(self.TxtNumMax, self.TxtSkillNameMax, self.TxtSkillDesMax, nSkillId, self.pWeapon:Evolue() + 1)
    else
        ---控件显示
        WidgetUtils.SelfHitTestInvisible(self.PanelEvo)
        WidgetUtils.Collapsed(self.PanelEvoMax)

        self:ShowSkillInfo(self.TxtNum, self.TxtSkillName, self.TxtSkillDes1, nSkillId, self.pWeapon:Evolue() + 1)
        self:ShowSkillInfo(self.TxtNumNew, self.TxtSkillNameNew, self.TxtSkillDes2, nSkillId, self.pWeapon:Evolue() + 2)
        
        local nSilver = Cash.GetMoneyCount(Cash.MoneyType_Silver)
       
        local nNeed = Weapon.GetEvolutionCostGold(self.pWeapon)
        if nSilver < nNeed then
            Color.SetTextColor(self.TxtCostMoney, 'FF0000FF')
        else
            Color.SetTextColor(self.TxtCostMoney, '03061FFF')
        end
        WidgetUtils.SelfHitTestInvisible(self.TxtCostMoney)
        self.TxtCostMoney:SetText(nNeed)
    end
end


function tbClass:GetCostMat()
    local ret = {}

    local tbCostMatInfo = Weapon.GetEvolutionMat(self.pWeapon) or {}

    --[[
        缓存需要的材料
    ]]
    for _, info in ipairs(tbCostMatInfo) do
        if #info == 1 then
           ret[self:GetGDPL(self.pWeapon)] = info[1] or 0
        else
           ret[string.format('%s-%s-%s-%s', info[1], info[2], info[3], info[4])] = info[5] or 0 
        end
    end
    return ret;
end

function tbClass:GetTbParam()
    self.tbCostItem = {}
    local tbSortInfo = self.tbSortInfo[1][self.tbCurSort.nIdx or 1]
    tbSortInfo.bReverse = self.tbCurSort.bReverse

    local tbCost = Weapon.GetEvolutionCost(self.pWeapon, tbSortInfo) or {}
    local tbRet = {}
    for _, pItem in ipairs(tbCost) do
        local bS = self.gridParam.pItem  == pItem

        local param = {
            pItem = pItem,
            nNum = bS and self.gridParam.nNum or 0,
            bCanStack = false,
            fAdd = function(item, n) return self:AddItem(item, n)  end,
            fSub = function(item, n) self:SubItem(item, n) end,
        }

        if bS then
            self.lastSelectParam = param
        end

        table.insert(tbRet, param)
        self.tbCostItem[pItem] = param
    end

    return tbRet
end

function tbClass:GetGDPL(pItem)
    return string.format('%s-%s-%s-%s', pItem:Genre(), pItem:Detail(), pItem:Particular(), pItem:Level()) 
end


 ---添加消耗处理
 function tbClass:AddItem(pItem, nNum)
    self:UpdateSelectMat(pItem, nNum)
    return true
 end

 ---减少消耗处理
 function tbClass:SubItem(pItem, nNum)
    self:UpdateSelectMat(pItem, nNum)
 end

  ---更新材料格子显示
 function tbClass:UpdateSelectMat(pItem, nNum)
    if self.gridParam then
        local bSelect = nNum ~= 0

        if self.lastSelectParam then
            if self.lastSelectParam.pItem ~= pItem then
                self.lastSelectParam.nNum = 0
                EventSystem.TriggerTarget(self.lastSelectParam, 'ON_DATA_CHANGE')
            end
        end

        self.lastSelectParam = self.tbCostItem[pItem]

        local nCount = self.gridParam.tbCostMat[self:GetGDPL(pItem)] or 0

        self.gridParam.pItem = bSelect and pItem or nil
        self.gridParam.nNum = nNum
        self.gridParam.nNeedNum = bSelect and nCount or nil
        EventSystem.TriggerTarget(self.gridParam, 'ON_DATA_CHANGE')
    end
 end

---显示技能信息
function tbClass:ShowSkillInfo(pLvTxt, pNameTxt, pDesTxt, nSkillId, nLevel)
   
    pLvTxt:SetText(nLevel)
    local sDes = SkillDesc(nSkillId, nil, nLevel)
    pDesTxt:SetContent(sDes)
    pNameTxt:SetText(SkillName(nSkillId))
end

 ---显示选择材料界面
 function tbClass:ShowSelect()
    self.bShowSelect = true
    if self.Select == nil then
        self.Select =  WidgetUtils.AddChildToPanel(self.Content, '/Game/UI/UMG/Widgets/uw_widgets_selectscreen.uw_widgets_selectscreen_C', 5)
    end

    if not self.Select then return end

    if self.bInitScreen == false then
        self.Select.Screen:Init(self.tbSortParam)
        self.Select.TxtAllEmpty:SetText(Text('ui.TxtWeaponEmpty'))
        WidgetUtils.SelfHitTestInvisible(self.Select.Screen)
        self.bInitScreen = true
    end

    WidgetUtils.SelfHitTestInvisible(self.Select)
    self.Select:Show(self:GetTbParam(), function()
        self:CloseSelect()
    end)
    UI.Call2('Arms', 'PushEvent', function()
        self:CloseSelect()
    end)
 end

 ---关闭选择
 function tbClass:CloseSelect()
    UI.Call2('Arms', 'ClearPushEvent')
    WidgetUtils.Collapsed(self.Select)
    self.bShowSelect = false
 end

 ---更新材料选择
 function tbClass:UpdateSelectInfo()
    if self.bShowSelect then
        self:ShowSelect()
    end
 end

---请求进化
function tbClass:DoEvolution()
    if not self.pWeapon then return end

    ---进化最大等级判断
    if Weapon.IsEvolutionMax(self.pWeapon) then
        UI.ShowTip('tip.evolution_max_level')
        return
    end
    local pItem = self.gridParam.pItem

    if not pItem then
        UI.ShowTip('tip.material_not_enough')
        return
    end
    local sGDPL = self:GetGDPL(pItem)
    local nNeedNum = self.gridParam.tbCostMat[sGDPL] or 0

    if pItem:Count() < nNeedNum then
        UI.ShowTip('tip.material_not_enough')
        return
    end

    ---金币判断
    local nNeedGold = Weapon.GetEvolutionCostGold(self.pWeapon)
    local nHaveGold = Cash.GetMoneyCount(Cash.MoneyType_Silver)
    if nHaveGold < nNeedGold then
        UI.ShowTip('tip.gold_not_enough')
        return
    end

    ---发送指令
    Weapon.Req_Evolution(self.pWeapon, pItem:Id())
end

function tbClass:OnRsp()
    local fVisibleWidget = function(bVisible)
        local pUI = UI.GetUI('Arms')
        if pUI then
            if bVisible then 
                WidgetUtils.SelfHitTestInvisible(pUI)
            else
                WidgetUtils.Collapsed(pUI)
             end
        end
    end

    UI.Open('WeaponEvo', self.pWeapon, function()
        fVisibleWidget(true)
        if self.pWeapon then
            Preview.PlayCameraAnimByCallback(self.pWeapon:Id(), PreviewType.weapon_evolution, nil)
        end
    end)

    self.gridParam.pItem = nil
    self.gridParam.nNum = 0
    self.gridParam.nNeedNum = nil
    self.gridParam.tbCostMat = self:GetCostMat()
    EventSystem.TriggerTarget(self.gridParam, 'ON_DATA_CHANGE')

    if Weapon.IsEvolutionMax(self.pWeapon) then
        WidgetUtils.Collapsed(self.Select)
    else
        self:UpdateSelectInfo()
    end
    self:Update()
   
   fVisibleWidget(false)
   Preview.PlayCameraAnimByCallback(self.pWeapon:Id(), PreviewType.weapon_break, nil)
end

return tbClass
