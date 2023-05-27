-- ========================================================
-- @File    : uw_login_movie.lua
-- @Brief   : 服务器条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Show(info)
    local sMovieName = info[2]
    print('login play movie:', sMovieName)
    if not sMovieName then return end

    local bSuc = self.MediaWidget:Play(sMovieName, false, true)
    print('login play :', bSuc, sMovieName)

    local pMediaPlayer = self.MediaWidget:GetMediaPlayer()
    if pMediaPlayer then
        pMediaPlayer.OnEndReached:Clear()
        pMediaPlayer.OnEndReached:Add(self, function()
            self.MediaWidget:Seek(0)
        end)
    end
end

function tbClass:OnDestruct()
    self.MediaWidget:Close()
end

return tbClass