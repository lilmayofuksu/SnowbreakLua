-- ========================================================
-- @File    : uw_rolebreak_attribute.lua
-- @Brief   : 角色天启属性
-- ========================================================

local tbBreakAtt = Class()

function tbBreakAtt:Construct()
    self.tbAttWidget = {
        pOn = {
                pWidget = {self.OneOn, self.TwoOn},
                DesWidget = {
                    AttrName = {{self.TxtOneOnName},{self.TxtOnNum1Name,self.TxtOnNum2Name}},
                    AttrVal = {{self.TxtOneOnNum},{self.TxtOnNum1Num,self.TxtOnNum2Num,}},
                    pAttIcon = {{self.ImgOneOn},{self.ImgTwoOn,self.ImgTwoOn2}},
                }
        },
        pOff = {
                pWidget = {self.OneOff,self.TwoOff},
                DesWidget = {
                    AttrName = {{self.TxtOneOffName},{self.TxtOffNum1Name,self.TxtOffNum2Name}}, 
                    AttrVal = {{self.TxtOneOffNum},{self.TxtOffNum1Num,self.TxtOffNum2Num}},
                    pAttIcon = {{self.ImgOneOff},{self.ImgTwoOff,self.ImgTwoOff2}},
                },
        }
    }
end

function tbBreakAtt:Init(InParam)
    self.tbAtts = InParam.tbAtts
    self.bActive = InParam.bActive
    self:ShowAtts(self.bActive,self.tbAtts)
end

function tbBreakAtt:ShowAtts(InActived,InAtts)

    for index, value in ipairs(self.tbAttWidget.pOn.pWidget) do
        WidgetUtils.Collapsed(value)
    end
    for index, value in ipairs(self.tbAttWidget.pOff.pWidget) do
        WidgetUtils.Collapsed(value)
    end

    if InActived then
        WidgetUtils.SelfHitTestInvisible(self.tbAttWidget.pOn.pWidget[#InAtts])
    else
        WidgetUtils.SelfHitTestInvisible(self.tbAttWidget.pOff.pWidget[#InAtts])
    end

    for index, value in ipairs(InAtts) do --"attribute"
        local strAttribute = value[2]
        if RBreak.PercentageType[value[1]] then
            strAttribute = TackleDecimalUnit(strAttribute, '%')
        end
        if value[1] == "SkillCDReducePer" then
            strAttribute = "-" .. strAttribute
        end
        self.tbAttWidget.pOn.DesWidget.AttrName[#InAtts][index]:SetText(Text("attribute."..value[1]))
        self.tbAttWidget.pOn.DesWidget.AttrVal[#InAtts][index]:SetText(strAttribute)
        local Icon = Resource.GetAttrPaint(value[1])
        SetTexture(self.tbAttWidget.pOn.DesWidget.pAttIcon[#InAtts][index], Icon)

        self.tbAttWidget.pOff.DesWidget.AttrName[#InAtts][index]:SetText(Text("attribute."..value[1]))
        self.tbAttWidget.pOff.DesWidget.AttrVal[#InAtts][index]:SetText(strAttribute)
        SetTexture(self.tbAttWidget.pOff.DesWidget.pAttIcon[#InAtts][index],Icon)
    end
end


return tbBreakAtt