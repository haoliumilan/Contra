--
-- Author: liuhao
-- Date: 2015-12-03 12:10:35
-- 游戏界面

local PlayDirector = import("..director.PlayDirector")

local PlayLevelScene = class("PlayLevelScene", function()
    return display.newScene("PlayLevelScene")
end)

PlayLevelScene.ImgBg = "play/bg.jpg"
PlayLevelScene.ImgPause = "play/pause.png"

function PlayLevelScene:ctor()
	-- background
	display.newSprite(PlayLevelScene.ImgBg, display.cx, display.cy)
		:addTo(self)

	-- 
    cc.ui.UIPushButton.new(PlayLevelScene.ImgPause)
        :onButtonPressed(function(event)
            event.target:setScale(1.1)
        end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
        :onButtonClicked(function()
            app:enterScene("ChooseLevelScene", nil, "flipy")
        end)
        :pos(display.right - 55, display.top - 55)
        :addTo(self, 1)

    -- 
    self.playDirector = PlayDirector.new()
	    :addTo(self)

end


return PlayLevelScene