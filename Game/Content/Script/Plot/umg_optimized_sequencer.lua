-- ========================================================
-- @File    : umg_optimized_sequencer.lua
-- @Brief   : 
-- ========================================================
local tbClass = Class("UMG.SubWidget")


function tbClass:Construct()
    local name = UE4.UUMGLibrary.GetObjectName(self)
    name = Split(name, "_C")[1];

    local cfg = BossSequenceConfig.Get(name)
    if cfg then 
        self.Animate_name.TxtBossLevel:SetText(Text(cfg.BossDesc))
        self.Animate_name.TxtBossName:SetText(Text(cfg.BossName))
        
        SetTexture(self.Animate_name.Img5, cfg.BossIcon, false)

        self.Animate_area.TxtName:SetText(Text(cfg.SceneName))
        self.Animate_area.TxtName1:SetText(Text(cfg.SceneDesc))
    end
end


return tbClass
