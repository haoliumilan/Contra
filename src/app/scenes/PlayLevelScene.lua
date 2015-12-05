--
-- Author: liuhao
-- Date: 2015-12-03 12:10:35
-- 游戏界面

local PlayDirector = import("app.director.PlayDirector")

local PlayLevelScene = class("PlayLevelScene", function()
    return display.newScene("PlayLevelScene")
end)

PlayLevelScene.Img_Bg = "playLevel/bg.jpg"
PlayLevelScene.Img_Pause = "playLevel/pause.png"

function PlayLevelScene:ctor()
	-- background
	display.newSprite(PlayLevelScene.Img_Bg)
		:addTo(self)
		:pos(display.cx, display.cy)

	-- 
    cc.ui.UIPushButton.new(PlayLevelScene.Img_Pause)
        :onButtonPressed(function(event)
            event.target:setScale(1.1)
        end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
        :onButtonClicked(function()
            app:enterScene("ChooseLevelScene", nil, "flipy")
        end)
        :pos(display.right - 80, display.top - 70)
        :addTo(self, 1)

    -- 
    self.playDirector = PlayDirector.new()
	    :addTo(self)

end


return PlayLevelScene