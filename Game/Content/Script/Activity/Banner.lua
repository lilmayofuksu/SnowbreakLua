-- ========================================================
-- @File    : Banner.lua
-- @Brief   : 活动预览接口
-- ========================================================


Banner = Banner or{
    tbBanner = {},
    tbBannerTexture = {},

}
--- 记录轮播Id
Banner.InIdx = 1

--------------------------------加载配置-------------------------

function Banner.LoadConfig() 
    local tbFile = LoadCsv('activity/ads/Banner.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nId       = tonumber(tbLine.Id) or nil;
        local tbInfo    = {
            nId             = tonumber(tbLine.Id) or nil,
            Showtype        = tbLine.ShowType or nil,
            Sort            = tonumber(tbLine.Sort) or 0,
            nBg             = tonumber(tbLine.Bg) or nil,
            tStarttime      = tbLine.StartTime or nil,
            tEndtime        = tbLine.EndTime or nil,
            nJump           = tonumber(tbLine.Jump) or nil,
            tbJumpParam     = Eval(tbLine.JumpParam) or {},
            sUrl                = tbLine.Url or nil,
            Unlock          = tbLine.Unlock or nil,
            LevelEndJump    = tbLine.LevelEndJump or nil,
            sLevelEndText   = tbLine.LevelEndText or 0,
            GroupTaskId     = Eval(tbLine.GroupTaskId) or nil,
            nGoodIdLimit    = tonumber(tbLine.GoodsIdLimit) or nil,
        };

        tbInfo.tStarttime      = ParseTime(string.sub(tbLine.StartTime or '', 2, -2), tbInfo, "tStarttime")
        tbInfo.tEndtime        = ParseTime(string.sub(tbLine.EndTime or '', 2, -2), tbInfo, "tEndtime")
        Banner.tbBanner[nId] = tbInfo;
    end

    

    -- Dump(Banner.tbBanner)
    print('Load ../settings/activity/Banner.txt');
end
 
function Banner.IsOpen(One)
    if One.tStarttime and One.tEndtime and not IsInTime(One.tStarttime, One.tEndtime) then return false end
    if One.GroupTaskId and Fashion.CheckSkinItem(One.GroupTaskId) then return false end
    if One.nGoodIdLimit and IBLogic.CheckProductSellOut(One.nGoodIdLimit) then return false end
    if One.nJump == 3 and One.tbJumpParam[1] then 
        local tbGacha = Gacha.GetCfg(One.tbJumpParam[1])
        if tbGacha:IsNewPool() and tbGacha:GetTotalTime() >= tbGacha.nFreshmanTime then return false end
    end
    return true
end

function Banner.GetSortTable(bReload)
    -- sort
    if not Banner.tbSort or bReload then 
        Banner.tbSort = {}
        for _,v in ipairs(Banner.tbBanner) do
            if Banner.IsOpen(v) then
                table.insert(Banner.tbSort, v)
            end
        end
        table.sort(Banner.tbSort, function (a,b)
            return a.Sort > b.Sort
        end)
    end
    return Banner.tbSort
end


function Banner._OnInit()
    Banner.LoadConfig()

    if SERVER_ONLY then
        return
    end

    EventSystem.On(Event.IBShopBuyGoods, function()
        Banner.GetSortTable(true)
    end)

    EventSystem.On(Event.BannerCheck, function ()
        Banner.GetSortTable(true)
    end)

    EventSystem.On(Event.Logined, function()
        Banner.GetSortTable(true)
        local ui = UI.GetUI('Main')
        if ui then
            ui.BtnBanner:Refresh();
        end
    end)
end

function Banner.Jump(nType, ...)
    FunctionRouter.GoTo(nType, ...)
end

Banner._OnInit()
return Banner