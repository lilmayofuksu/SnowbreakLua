-- ========================================================
-- @File    : FormationMember.lua
-- @Brief   : 编队成员
-- ========================================================

local DATA_CHANGE_EVENT = "DATA_CHANGE_EVENT"

local tbMemberLogic = {
    ---初始化
    Init = function(self, nPos, pCard)
        self.nPosIndex = nPos
        self.pCard = pCard
    end,

    ---获取编队位置索引
    GetPosIndex = function(self)
        return self.nPosIndex
    end,

    ---获取角色
    GetCard = function(self)
        return self.pCard
    end,

    ---设置角色
    SetCard = function(self,InCard)
        self.pCard = InCard
    end,

    --- 清除角色
    DelCard = function(self)
        self.pCard = nil
    end,

    ---获取ID
    GetUID = function(self)
        local pCard = self:GetCard()
        return pCard and pCard:Id() or 0
    end,

    ---获取模板ID
    GetTemplateId = function(self)
        local pCard = self:GetCard()
        return pCard and pCard:TemplateId() or 0
    end,

    ---拷贝赋值
    Copy = function(self, tbMember)
        self.nPosIndex = tbMember.nPosIndex
        self.pCard = tbMember:GetCard()
    end,

    ---派发更新事件
    Update = function(self)
        EventSystem.TriggerTarget(self, DATA_CHANGE_EVENT)
    end,

    ---是否为空
    IsNone = function(self)
        return self:GetCard() == nil
    end,

    ---是否相等
    IsEqual = function(self, tbMember)
        return self.nIndex == tbMember.nIndex and self:GetCard() == tbMember:GetCard()
    end,

    ---同步数据
    SynData = function(self, pCard)
        self.pCard = pCard
    end,
}

local Member = {}
function Member.New(nPos, pCard)
    local tb = Inherit(tbMemberLogic)
    tb.nPosIndex = 0
    tb.pCard = nil
    tb:Init(nPos, pCard)
    return tb
end
return Member

