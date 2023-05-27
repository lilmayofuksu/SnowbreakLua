local view = Class("UMG.SubWidget")

local ColorGreen = UE4.UUMGLibrary.GetSlateColor(0, 0.8, 0, 1);
local ColorWhite = UE4.UUMGLibrary.GetSlateColor(0.5, 0.5, 0.5, 1);


function view:Construct()
    BtnAddEvent(self.BtnSelect, function() self:OnBtnClickSelect() end)
    BtnAddEvent(self.BtnOK, function() self:OnBtnClickSelect() end)
end

function view:OnListItemObjectSet(pObj)
    self.tbData = pObj.Data
    self.tbData.pRefresh = function(data)
        if data ~= self.tbData then return end
        self:UpdateSelected()
    end
    local cfg = self.tbData.cfg
    self.TxtId:SetText(cfg.Id);
    self.TxtName:SetText(cfg.Name);
    self.TxtDesc:SetText(string.format("地图:%d 完成度:%d 道具:%s 物件:%s", cfg.MapId, cfg.Score, self:GetGDPLDesc(cfg), self:GetObjDesc(cfg)) );
    self:UpdateSelected()
end

function view:GetGDPLDesc(cfg)
    local tbRet = {}
    for _, tb in ipairs(cfg.GDPL) do 
        local str = string.format("%d-%d-%d-%d-%d", tb[1], tb[2], tb[3], tb[4], tb[5] or 1)
        table.insert(tbRet, str)
    end
    return table.concat(tbRet, ";");
end

function view:GetObjDesc(cfg)
    local tbRet = {}
    for _, tb in ipairs(cfg.Object) do 
        local str = string.format("%d-%d", tb[1], tb[2] or 1)
        table.insert(tbRet, str)
    end
    return table.concat(tbRet, ";");
end

function view:UpdateSelected()
    if self.tbData.isSelected then 
        self.Background:SetColorAndOpacity(ColorGreen)
    else 
        self.Background:SetColorAndOpacity(ColorWhite)
    end
end

function view:OnBtnClickSelect()
    if self.tbData.isSelected then 
        self.tbData.parent:DoSelect(nil)
    else
        self.tbData.parent:DoSelect(self.tbData.id) 
    end
end

return view