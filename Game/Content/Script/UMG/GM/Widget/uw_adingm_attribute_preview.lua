

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnClose, function() 
        local ui = UI.GetUI("AdinGM")
        if ui then return ui:SetAttributePreviewShow(false) end
    end)
end

return tbClass