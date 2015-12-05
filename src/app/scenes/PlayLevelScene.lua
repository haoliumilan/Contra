--
-- Author: liuhao
-- Date: 2015-12-03 12:10:35
-- 游戏界面

local PlayDirector = import("app.director.PlayDirector")

local PlayLevelScene = class("PlayLevelScene", function()
    return display.newScene("PlayLevelScene")
end)

PlayLevelScene.Img_PlayLevel_Bg = "playLevel/bg.jpg"

function PlayLevelScene:ctor()
	-- background
	display.newSprite(PlayLevelScene.Img_PlayLevel_Bg)
		:addTo(self)
		:pos(display.cx, display.cy)

    self.playDirector = PlayDirector.new()
	    :addTo(self)

end


return PlayLevelScene