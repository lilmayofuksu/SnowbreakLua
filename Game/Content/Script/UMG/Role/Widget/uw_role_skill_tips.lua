-- ========================================================
-- @File    : uw_role_skill_tips.lua
-- @Brief   : 角色主要技能描述提示
-- @Author  :
-- @Date    :
-- ========================================================

local tbSkillTip = Class("UMG.BaseWidget")
tbSkillTip.Path = "/UMG/Role/Widget/uw_skill_info_text_data"

function tbSkillTip:Construct()
    self.pSkillDes = Model.Use(self, self.Path)
    self.tbActiveSkill = {self.Skill1, self.Skill1, self.Skill3, self.Qte, self.Rush}
    self.tbActiveType = {
        RoleCard.SkillType.NormalSkill,
        RoleCard.SkillType.NormalSkill,
        RoleCard.SkillType.BigSkill,
        RoleCard.SkillType.QTESkill,
        RoleCard.SkillType.NormalSkill}
    self.tbPassiveSkill = {self.RoleBreak5, self.RoleBreak1, self.RoleBreak2, self.RoleBreak4, self.RoleBreak3}
    self.MaskClick.OnMouseButtonDownEvent:Bind(self, tbSkillTip.DownFun)
    BtnAddEvent(self.BtnClose, function ()
        UI.Close(self)
    end)

    self:DoClearListItems(self.TxtType)
    self.Factory = Model.Use(self)

    BtnAddEvent(self.Button, function()
        if not self.pCard or self.pCard:IsTrial() then
            return
        end
        RoleCard.SetRoleLeave(self.pCard, false, function ()
            UI.ShowMessage("ui.TxtGrowthSwitch3")
            self:UpdetaSwitchBtn()
        end)
    end)
    BtnAddEvent(self.Button2, function()
        if not self.pCard or self.pCard:IsTrial() then
            return
        end
        RoleCard.SetRoleLeave(self.pCard, true, function ()
            UI.ShowMessage("ui.TxtGrowthSwitch4")
            self:UpdetaSwitchBtn()
        end)
    end)
end

function tbSkillTip:DownFun(MyGeometry, InTouchEvent)
    UI.Close(self)
    return UE4.UWidgetBlueprintLibrary.Handled()
end


function tbSkillTip:OnClose()
    EventSystem.TriggerTarget(RoleCard,RoleCard.ShowSkillDetailHandle,true)
end

--- 技能Tip入口
function tbSkillTip:OnOpen(InTemplate, InId, Idx, InType, ClickCall, bShowMax,bShowRiki)
    self.bShowMax = bShowMax or false
    self.bShowRiki = bShowRiki or false
    self.Id = InId or self.Id
    self.Template = InTemplate
    self.pCard = RoleCard.GetItem({InTemplate.Genre, InTemplate.Detail, InTemplate.Particular, InTemplate.Level})

    self:SetSkillName(self.Id)
    self:SkillCD(InId)
    -- self:SpineNodeDes(InTemplate)
    self:ShowSkillItems(self.Template, self.Id)

    self.TxtCDIntro:SetText(Text("ui.TxtCoolDown"))
    self.TxtPowerIntro:SetText(self:Tagenemegy(Idx, self.Id))

    -- self:ShowActiveSkills(self.Template)
    -- self:ShowPassiveSkills(self.Template)
    -- self:ShowProLevelSkill(self.Template)

    -- self.SkillTxt:SetContent(SkillDesc(InId,nil,RoleCard.GetSkillLv(InTemplate,InId)))
    -- self.SkillTxt:SetContent(SkillDesc(InId,nil,self:GetSkillLevel(InTemplate,InId)))
    self:ShowSkillState(InType)
    --self.Skill:OnOpen({nSkillId = InId,bTag = true,bBgIcon = true})
    --self.Skill:SetStyleBySkill(InId,self.tbActiveType[Idx])

    local bShow,sTip = FunctionRouter.IsOpenById(25)
    self:ShowRoleBreakSkill(bShow)
    self:ShowSkillMaxBox()
    self:UpdateSkillContent()
    self:ShowPanelSwitch(InType == RoleCard.SkillType.BigSkill)
end

function tbSkillTip:UpdateSkillContent()
    self:ShowActiveSkills(self.Template)
    self:ShowPassiveSkills(self.Template)
    self:ShowProLevelSkill(self.Template)

    -- self.SkillTxt:SetContent(SkillDesc(InId,nil,RoleCard.GetSkillLv(InTemplate,InId)))
    -- print("SkillTxt:SetContent",self.Template,SkillDesc(self.Id,nil,self:GetSkillLevel(self.Template,self.Id)))
    self:SkillCD(self.Id)
    self.SkillTxt:SetContent(SkillDesc(self.Id,nil,self:GetSkillLevel(self.Template,self.Id)))
end

-- 技能名称
function tbSkillTip:SetSkillName(InSkillId)
    local sName = SkillName(InSkillId)
    self.TxtSkill:SetText(sName)
end

-- 技能描述
function tbSkillTip:SkillDes(InSkillId, spinesID)
    local sDes = ''
    if InSkillId and spinesID then
        -- sDes = SkillDesc(InSkillId, spinesID, RoleCard.GetSkillLv(self.Template, InSkillId))
        sDes = SkillDesc(InSkillId, spinesID, self:GetSkillLevel(self.Template, InSkillId))
    else
        sDes = 'Id nil'
    end
    self.SkillTxt:SetContent(sDes)
end

--- 技能CD描述
function tbSkillTip:SkillCD(InId)
    local Info  = UE4.UItemLibrary.GetSkillTemplate(InId)
    local SkillCD = Info.CDTimes
    -- local SkillLv = RoleCard.GetSkillLv(self.Template,InId)
    local SkillLv = self:GetSkillLevel(self.Template,InId)
    local sCD = UE4.UAbilityLibrary.GetMapValueForLevel(SkillCD, SkillLv or 1)
    if sCD and sCD > 0 then
        WidgetUtils.HitTestInvisible(self.PanelCD)
        local v1, v2 = math.modf(sCD)
        if v2==0 then
            self.TxtNum:SetText(v1)
        else
            self.TxtNum:SetText(string.format("%.1f", math.floor(sCD*10 + 0.5)/10))
        end
    else
        WidgetUtils.Collapsed(self.PanelCD)
    end
end

--刷新技能标签
function tbSkillTip:UpdateSkillTag(SkillID)
    self:DoClearListItems(self.TxtType)
    if not SkillID then return end
    local tbTag = RoleCard.GetSkillTagID(SkillID)
    for _, TagID in ipairs(tbTag) do
        local pObj = self.Factory:Create({nID = TagID})
        self.TxtType:AddItem(pObj)
    end
end

--- 必杀能量
function tbSkillTip:SkillKillEnergy()
    local function CharacterEnergyfun()
        local strValueArr = Localization.Get("skill_describe." .. self.Id .. "_energy")
        -- local SkillLv = RoleCard.GetSkillLv(self.Template,self.Id)
        local SkillLv = self:GetSkillLevel(self.Template,self.Id)
        local OutValue = UE4.UAbilityLibrary.GetSkillValue(strValueArr, SkillLv or 1)
        if OutValue:Length() >= 1 and #OutValue:Get(1).StrValue>0 then
            WidgetUtils.HitTestInvisible(self.PanelEnergy)
            return OutValue:Get(1).StrValue
        else
            WidgetUtils.Collapsed(self.PanelEnergy)
            return '/'
        end
    end
    return CharacterEnergyfun()
end

function tbSkillTip:GetSkillNote(InItem)
    if not InItem then return end
    local tbNode = {}
    for i = 1, Spine.MaxMastNum do
        local tbInfo = Spine.tbKeyId[InItem:SpineId()][i]
        local SKillIds = Spine.tbSpineNode[tbInfo.SpId][7].Skilfix
        table.insert(tbNode,{Id = SKillIds,bActived = InItem:GetSpine(i, Spine.MaxSubNum)})
    end
    return tbNode
end

function tbSkillTip:GetActived(InId, InIds)
    for _, value in ipairs(InIds or {}) do
        if value.Id == InId then
            return value
        end
    end
end

function tbSkillTip:ShowSkillMaxBox()
    WidgetUtils.Collapsed(self.Preview)
    if self.bShowMax then
        WidgetUtils.Visible(self.Preview)
        WidgetUtils.Visible(self.CheckMark)
        WidgetUtils.Collapsed(self.CheckMark_1)
        self.Min:SetIsChecked(true)
        self.Max:SetIsChecked(false)
        self.Max.OnCheckStateChanged:Add(
        self,
        function(_, bChecked)
            self:ShowSkillMaxChange(bChecked==true)
        end
        )

        self.Min.OnCheckStateChanged:Add(
        self,
        function(_, bChecked)
            self:ShowSkillMaxChange(bChecked==false)
        end
        )
    end
end

function tbSkillTip:ShowSkillMaxChange(bMax)
    if bMax == true then
        WidgetUtils.Visible(self.CheckMark_1)
        WidgetUtils.Collapsed(self.CheckMark)
        self.Min:SetIsChecked(false)
        self.Max:SetIsChecked(true)
    else
        WidgetUtils.Visible(self.CheckMark)
        WidgetUtils.Collapsed(self.CheckMark_1)
        self.Max:SetIsChecked(false)
        self.Min:SetIsChecked(true)
    end

    if self.bMax ~= bMax then
        self.bMax = bMax
        self:UpdateSkillContent()
    end
end

function tbSkillTip:GetSkillLevel(InpTemplate, InSkillId, Card)
    if self.bShowMax then
        if self.bMax == true then
            local maxSkill = RoleCard.GetMaxSkillLv(InpTemplate, InSkillId, Card)
            -- print("maxSkill:",maxSkill)
            return maxSkill
        else
            -- print("minSkill")
            return 1
        end
    end

    return RoleCard.GetSkillLv(InpTemplate,InSkillId,Card)
end

function tbSkillTip:ShowSkillItems(InItem, InSkillId)
    self:UpdatePanelBlue(InSkillId)
    self.ShowSkillList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed);
    self:DoClearListItems(self.ShowSkillList)
    local tbnodeID = RoleCard.tbShowSkills[InSkillId]
    if not tbnodeID then
        print("SkillId err", InSkillId)
        return
    end
    for _, value in pairs(tbnodeID) do
        if Spine.tbSpineNode[value] then
            local mastID = value%10
            local ID = Spine.tbSpineNode[value][Spine.MaxSubNum].Nodedes
            local Active = false
            if self.pCard then
                Active = self.pCard:GetSpine(mastID, Spine.MaxSubNum)
            end
            local NewDes = self.pSkillDes:Create({Id = ID, bActived = Active})
            self.ShowSkillList:AddItem(NewDes)
        end
    end
end
--- @param Idx Interge 技能Idx
--- @param InAuto boolean true:主动技能 
function tbSkillTip:Tagenemegy(Idx, SkillID)
    if Idx == 3 and SkillID then
        WidgetUtils.HitTestInvisible(self.PanelEnergy)
        local fEnergy = 0
        if self.pCard then
            fEnergy = UE4.UAbilityLibrary.GetSkillCharacterEnergyCost(SkillID, RoleCard.GetSkillLv(_, SkillID, self.pCard))
        else
            fEnergy = UE4.UAbilityLibrary.GetSkillCharacterEnergyCost(SkillID, 1)
        end
        local v1, v2 = math.modf(fEnergy)
        if v2==0 then
            self.TxtNum2:SetText(v1)
        else
            self.TxtNum2:SetText(string.format("%.1f", math.floor(fEnergy*10 + 0.5)/10))
        end
        return Text("TxtPowerIntroconsump")
    else
        self.TxtNum2:SetText(self:SkillKillEnergy())
        return Text("TxtPowerIntro")
    end
end

function tbSkillTip:UpdatePanelBlue(ID)
    WidgetUtils.Collapsed(self.PanelBlue)
    local skillInfo = UE4.UAbilityComponentBase.K2_GetSkillInfoStatic(ID)
    if skillInfo and skillInfo.SkillCost:Length()>0 then
        local Level = self:GetSkillLevel(self.Template, ID, self.pCard) or 1
        for i = 1, skillInfo.SkillCost:Length() do
            local info = skillInfo.SkillCost:Get(i)
            if info.AttributeClass and info.AttributeClass:GetName()== "NormalEnergy" then
                local tbKey = info.Value:Keys()
                if tbKey:Length()>0 then
                    WidgetUtils.HitTestInvisible(self.PanelBlue)
                    local v = 0
                    if tbKey:Length()>=Level then
                        v = math.abs(info.Value:Find(tbKey:Get(Level)))
                    else
                        v = math.abs(info.Value:Find(tbKey:Get(1)))
                    end
                    local v1, v2 = math.modf(v)
                    if v2==0 then
                        self.TxtNum2_1:SetText(v1)
                    else
                        self.TxtNum2_1:SetText(string.format("%.1f", math.floor(v*10 + 0.5)/10))
                    end
                end
                break
            end
        end
    end
end

--- 主动技能描述
function tbSkillTip:ShowActiveSkills(InItem)
    if not InItem then return end
    local ASkills = RoleCard.GetItemShowSkills(InItem)
    self.nQTEIconId ,self.bQTEEndSwitchBack = RoleCard.GetQTEType(ASkills[4])
    self.TxtName:SetText(SkillQTEName(ASkills[4]))
    self.TxtContent:SetContent(SkillQTEDesc(ASkills[4]))
    SetTexture(self.IconQTE, self.nQTEIconId)
    if self.bQTEEndSwitchBack  then
        Color.SetColorFromHex(self.plateImg,'#FFFFFF66') ---闪击
    else
        Color.SetColorFromHex(self.plateImg,'#00A8FF66') -- - 强袭
    end

    for index, value in ipairs(self.tbActiveSkill) do
        if self.Id == ASkills[index] then
            self:UpdateSkillTag(ASkills[index])
            value:SetActived(1)
        end
        local tbParam = {
            nSkillId = ASkills[index] or 0,
            EType = self.tbActiveType[index],
            fClickFun = function(Id)
                self:RefreshSkillData()
                value:SetActived(1)
                self.Id = Id
                self:UpdateSkillTag(Id)
                self:SetSkillName(self.Id)
                self:SkillCD(self.Id)
                self:SpineNodeDes(self.Template)
                self:ShowSkillItems(self.Template, self.Id)
                self.TxtPowerIntro:SetText(self:Tagenemegy(index, Id))
                -- self.SkillTxt:SetContent(SkillDesc(Id,nil,RoleCard.GetSkillLv(InItem,Id)))
                self.SkillTxt:SetContent(SkillDesc(Id,nil,self:GetSkillLevel(InItem,Id)))
                self:ShowSkillState(self.tbActiveType[index])
                --self.Skill:OnOpen({nSkillId = Id, bTag = true, bBgIcon = true, EType =RoleCard.SkillType[index]})
                --self.Skill:SetStyleBySkill(Id,self.tbActiveType[index])
                self:ShowPanelSwitch(index == 3)
            end
        }
        value:UpdatePanel(tbParam)
    end
end

--- 被动技能描述
function tbSkillTip:ShowPassiveSkills(InItem)
    if not InItem then return end
    local nId = tonumber(InItem.Genre..InItem.Detail..InItem.Particular..InItem.Level)
    local function tbSkills(InIdx)
        if RBreak.tbBreakId[nId] and RBreak.tbBreakId[nId].SkillId[InIdx] then
            return RBreak.tbBreakId[nId].SkillId[InIdx][1]
        else
            return nil
        end
    end
    for index, value in ipairs(self.tbPassiveSkill) do
        local tbParam = {
            bTag = true,
            nSkillId = tbSkills(index) or nil,
            bBgIcon  = true,
            EType = RoleCard.SkillType.PassiveType,
            fClickFun = function(Id)
                self:RefreshSkillData()
                value:SetActived(1)
                self.Id = Id
                self:UpdateSkillTag(Id)
                self:SetSkillName(self.Id)
                self:SkillCD(self.Id)
                self:SpineNodeDes(self.Template)
                self:ShowSkillItems(self.Template, self.Id)
                self.TxtPowerIntro:SetText(self:Tagenemegy(index))
                local level = 1
                if index == 4 then
                    local MapLevelFix = UE4.UAbilityComponentBase.K2_GetSkillFixInfoStatic(Id).SkillLevelFixMap
                    local Keys = MapLevelFix:Keys()
                    if Keys:Length()>0 then
                        level = self:GetSkillLevel(InItem, Keys:Get(1))
                    end
                    if self.pCard and self.pCard:Break()/RBreak.NBreakLv < 4 then
                        level = level + 1
                    end
                end
                self.SkillTxt:SetContent(SkillDesc(Id, nil, level))
                self:ShowSkillState(RoleCard.SkillType.PassiveType)
                --self.Skill:SetStyleBySkill(Id, value)
                --self.Skill:OnOpen({nSkillId = Id, bTag = true, bBgIcon = true, EType = RoleCard.SkillType.PassiveType})
                if not self.pCard or RBreak.GetProcess(self.pCard) < index then
                    WidgetUtils.HitTestInvisible(self.PanelLock)
                    self.TxtLock:SetText(Text("ui.TxtRoleSpSkillUnlock", index))
                end
                self:ShowPanelSwitch(false)
            end
        }
        if self.pCard and RBreak.GetProcess(self.pCard) >= index then
            tbParam.bActived = true
        end
        value:SetStyleBySkill()
        value:ShowSpecialSkill(index)
        value:SetTxtTag()
        value:OnOpen(tbParam)
    end
end

--- 职级认定团队技能描述
function tbSkillTip:ShowProLevelSkill(InItem)
    if not InItem then return end
    if not self.pCard then
        WidgetUtils.Collapsed(self.BreakLv)
        return
    end

    local ArrayID = RoleCard.GetProLevelSkillID(self.pCard)
    if ArrayID and ArrayID:Length() > 0 then
        local ID = ArrayID:Get(1)
        if self.Id == ID then
            self.BreakLv:SetActived(1)
            self:UpdateSkillTag(ID)
        end
        local tbParam = {
            nSkillId = ID or 0,
            EType = RoleCard.SkillType.PassiveType,
            fClickFun = function(Id)
                self:RefreshSkillData()
                self.BreakLv:SetActived(1)
                self.Id = Id
                self:UpdateSkillTag(Id)
                self:SetSkillName(self.Id)
                self:SkillCD(self.Id)
                self:SpineNodeDes(self.Template)
                self:ShowSkillItems(self.Template, self.Id)
                self.TxtPowerIntro:SetText(self:Tagenemegy(1, Id))
                -- self.SkillTxt:SetContent(SkillDesc(Id, nil, RoleCard.GetSkillLv(InItem,Id)))
                self.SkillTxt:SetContent(SkillDesc(Id, nil, self:GetSkillLevel(InItem,Id)))
                self:ShowSkillState(RoleCard.SkillType.PassiveType)
                self:ShowPanelSwitch(false)
            end
        }
        WidgetUtils.SelfHitTestInvisible(self.BreakLv)
        self.BreakLv:UpdatePanel(tbParam)
    else
        WidgetUtils.Collapsed(self.BreakLv)
    end
end

function tbSkillTip:SpineNodeDes(InTemplate)
    if self.pCard then
        local spinesID = UE4.TArray(UE4.int32)
        self.pCard:GetAllSpineNode(spinesID)
        self:SkillDes(self.Id, spinesID)
    end
end

--- 刷新为初始化
function tbSkillTip:RefreshSkillData()
    for _, value in ipairs(self.tbPassiveSkill) do
        value:SetActived()
    end

    for _, value in ipairs(self.tbActiveSkill) do
        value:SetActived()
    end

    self.BreakLv:SetActived()
    WidgetUtils.Collapsed(self.PanelLock)
end

--- InType 技能类型：1：大招，普通技能，2：QTE,3:天启技能
function tbSkillTip:ShowSkillState(InType)
    WidgetUtils.Collapsed(self.SPSkill)
    WidgetUtils.Collapsed(self.RoleBreakEmpty)
    if FunctionRouter.IsOpenById(FunctionType.Nerve) then
        if InType == RoleCard.SkillType.NormalSkill or InType == RoleCard.SkillType.BigSkill then
            WidgetUtils.SelfHitTestInvisible(self.SPSkill)
        elseif InType == RoleCard.SkillType.QTESkill then
            WidgetUtils.SelfHitTestInvisible(self.SPSkill)
        end
    end
    if InType == RoleCard.SkillType.PassiveType then
        WidgetUtils.SelfHitTestInvisible(self.RoleBreakEmpty)
    end
end

function tbSkillTip:ShowRoleBreakSkill(InShow)
    WidgetUtils.Hidden(self.PanelRoleBreak)
    if InShow then
        WidgetUtils.Visible(self.PanelRoleBreak)
    end
end

function tbSkillTip:ShowPanelSwitch(bShow)
    if bShow == nil then
        bShow = true
    end
    if bShow and self.pCard and not self.pCard:IsTrial() and not self.bShowRiki then
        local SkillInfo = UE4.UAbilityFunctionLibrary.GetSuperSkillInfoFromCharacterID(self.pCard:AppearID())
        if SkillInfo and not SkillInfo.bSuperSkillAutoSwitchBackLock then
            WidgetUtils.Visible(self.PanelSwitch)
            self:UpdetaSwitchBtn()
            return
        end
    end
    WidgetUtils.Collapsed(self.PanelSwitch)
end

function tbSkillTip:UpdetaSwitchBtn()
    if not self.pCard then
        return
    end
    if self.pCard:HasFlag(Item.FLAG_LEAVE) then
        WidgetUtils.Collapsed(self.Common2)
        WidgetUtils.Collapsed(self.Selected)
        WidgetUtils.HitTestInvisible(self.Selected2)
        WidgetUtils.HitTestInvisible(self.Common)
    else
        WidgetUtils.Collapsed(self.Common)
        WidgetUtils.Collapsed(self.Selected2)
        WidgetUtils.HitTestInvisible(self.Selected)
        WidgetUtils.HitTestInvisible(self.Common2)
    end
end

return tbSkillTip
