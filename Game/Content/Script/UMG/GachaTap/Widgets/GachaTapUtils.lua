
local GachaTapUtils = { }



---品质颜色
GachaTapUtils.ColorStr = {
    [3] = '091FE3',
    [4] = '8624AC',
    [5] = 'D05309'
}

GachaTapUtils.QualityRoleImg = {
    1700098,
    1700098,
    1700098,
    1700098,
    1700099,
}


GachaTapUtils.QualityWeaponImg = {
    1700100,
    1700100,
    1700100,
    1700101,
    1700102,
}


local nPlayTimer = nil

function GachaTapUtils.PlayAnim(pWidget, pAnim, fCallback)
    if not pWidget or not pAnim then
        return
    end

    local nLen = pAnim:GetEndTime() - pAnim:GetStartTime()
    pWidget:PlayAnimationForward(pAnim)

    UE4.Timer.Cancel(nPlayTimer)


    nPlayTimer = UE4.Timer.Add(nLen, function()
        nPlayTimer = nil
        if fCallback then fCallback() end
    end)

end


function GachaTapUtils.PlayStarAnim(pWidget, pList, nStarNum)
    if not pList then return end
    nStarNum = nStarNum or 0
    pWidget:DoClearListItems(pList)

    local Factory = pWidget.ListFactory or Model.Use(pWidget)

    for i = 1, nStarNum do
        local param = {}
        local pObj = Factory:Create(param)
        pList:AddItem(pObj)
    end

    pList:PlayAnimation(0)
end

function GachaTapUtils.SetImgColor(pWidget, nColor)
    if not pWidget or not nColor or not GachaTapUtils.ColorStr[nColor] then return end

    for i = 1, 22 do
        local pImg = pWidget['ImgQuality' .. i]
        if pImg then
            Color.SetColorFromHex(pImg, GachaTapUtils.ColorStr[nColor])
        end
    end
end


return GachaTapUtils