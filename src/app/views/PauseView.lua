--
-- Author: Liu Hao
-- Date: 2015-12-15 21:08:16
-- 关卡暂停界面

local PauseView = class("PauseLayer", function()
	return display.newNode()
	end)

-- image
PauseView.ImgBg = "pause/bg.png"
PauseView.ImgAgainBtn = "pause/againBtn.png"
PauseView.ImgGiveUpBtn = "pause/giveUpBtn.png"
PauseView.ImgBackBtn = "pause/backBtn.png"
PauseView.ImgCloseBtn = "pause/closeBtn.png"

-- event
PauseView.EventAgain = "again"
PauseView.EventGiveUp = "giveUp"
PauseView.EventBack = "back"

function PauseView:ctor(callback)
	-- background color
	display.newColorLayer(cc.c4b(0, 0, 0, 200))
		:addTo(self)

	display.newSprite(PauseView.ImgBg, display.cx, display.cy)
		:addTo(self)

	-- again
	cc.ui.UIPushButton.new(PauseView.ImgAgainBtn)
	    :onButtonPressed(function(event)
	        event.target:setScale(1.1)
	    end)
	    :onButtonRelease(function(event)
	        event.target:setScale(1.0)
	    end)
	    :onButtonClicked(function()
	    	callback(PauseView.EventAgain)
	    end)
	    :pos(display.cx, 580)
	    :addTo(self)

	-- give up
	cc.ui.UIPushButton.new(PauseView.ImgGiveUpBtn)
	    :onButtonPressed(function(event)
	        event.target:setScale(1.1)
	    end)
	    :onButtonRelease(function(event)
	        event.target:setScale(1.0)
	    end)
	    :onButtonClicked(function()
	    	callback(PauseView.EventGiveUp)
	    end)
	    :pos(display.cx, 420)
	    :addTo(self)

	-- back
	cc.ui.UIPushButton.new(PauseView.ImgBackBtn)
	    :onButtonPressed(function(event)
	        event.target:setScale(1.1)
	    end)
	    :onButtonRelease(function(event)
	        event.target:setScale(1.0)
	    end)
	    :onButtonClicked(function()
	    	callback(PauseView.EventBack)
	    end)
	    :pos(display.cx, 260)
	    :addTo(self)

	-- close
	cc.ui.UIPushButton.new(PauseView.ImgCloseBtn)
	    :onButtonPressed(function(event)
	        event.target:setScale(1.1)
	    end)
	    :onButtonRelease(function(event)
	        event.target:setScale(1.0)
	    end)
	    :onButtonClicked(function()
	    	callback(PauseView.EventBack)
	    end)
	    :pos(670, 1070)
	    :addTo(self)
end

return PauseView