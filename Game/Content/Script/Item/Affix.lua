

-- ========================================================
-- @File    : Affix.lua
-- @Brief   : 后勤卡词缀洗练
-- ========================================================

---@class SplineData 角色卡突破管理

---@field tbQualIcon table 品质Icon配置表
---@field tbLogoIcon table 后勤卡LogoIcon配置表
tbAffix = tbAffix or {
        tbAffixConfig = {},
       
}






function tbAffix.LoadAffixConfig()
    local tbFile = LoadCsv("item/support/affix.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.ID  or '0')
        local tbInfo = {
            nAttack                     = tonumber(tbLine.Attack) or 0,
            nDefence                    = tonumber(tbLine.Defence) or 0,
            nHealth                     = tonumber(tbLine.Health) or 0,
            nSpeed                      = tonumber(tbLine.Speed) or 0,
            nCriticalValue              = tonumber(tbLine.CriticalValue) or 0,
            nCharacterEnergyEfficiency  = tonumber(tbLine.CharacterEnergyEfficiency) or 0,
            nFireDamageBonus            = tonumber(tbLine.FireDamageBonus) or 0,
            nThunderDamageBonus         = tonumber(tbLine.ThunderDamageBonus) or 0,
            nIceDamageBonus             = tonumber(tbLine.IceDamageBonus) or 0,
            nEntityBulletDamageBonus    = tonumber(tbLine.EntityBulletDamageBonus) or 0,
            nSuperpowersDamageBonus     = tonumber(tbLine.SuperpowersDamageBonus) or 0,
            nAllDamageBonus             = tonumber(tbLine.AllDamageBonus) or 0,
        }
        tbAffix.tbAffixConfig[nId] = tbInfo
    end
    -- Dump(tbAffix.tbAffixConfig)
    print('Load ../settings/item/support/affix.txt')
end


function tbAffix.__Init()
    tbAffix.LoadAffixConfig()
end
tbAffix.__Init()

return tbAffix