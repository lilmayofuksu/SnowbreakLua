-- ========================================================
-- @File    : Refine.lua
-- @Brief   : 后勤洗练
-- ========================================================

Refine = Refine or {}

Refine.SupportRefine = nil
function Refine.Req_Refine(InParam,InCallback)
    -- body

    print('Req_Refine')
    Refine.SupportRefine = InCallback
    me:CallGS("SupportCard_Refine", json.encode(cmd))
end

s2c.Register(
    "SupportCard_Refine",
    function()
        if Refine.SupportRefine then
            Refine.SupportRefine()
            Refine.SupportRefine = nil
        end
    end
)




return Refine