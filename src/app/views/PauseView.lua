--
-- Author: Liu Hao
-- Date: 2015-12-15 21:08:16
-- 关卡暂停界面

local PauseView = class("PauseLayer", function()
	return display.newNode()
	end)

-- image
PauseView.ImgBg = "pause/bg.png"

-- event
PauseView.EventAgain = "again"
PauseView.EventGiveUp = "giveUp"
PauseView.EventBack = "back"

function PauseView:ctor(property)
	self.callback_ = property.callback
	self.levelData_ = property.levelData

	-- background color
	display.newColorLayer(cc.c4b(0, 0, 0, 200))
		:addTo(self)

	display.newSprite(PauseView.ImgBg, display.cx, display.cy)
		:addTo(self)

	-- name
	display.newTTFLabel({text = string.format("%s.%s", self.levelData_.id, self.levelData_.name),
	        size = 40, color = display.COLOR_WHITE})    
	        :pos(display.cx, 1080)
	        :addTo(self)

	-- target
	app:createView("TargetView", {targetData = self.levelData_.target, targetType = 2})
		:pos(display.cx, 640)
		:addTo(self)

	-- again
	cc.ui.UIPushButton.new(ImageName.BtnAgain)
	    :onButtonPressed(function(event)
	        event.target:setScale(1.1)
	    end)
	    :onButtonRelease(function(event)
	        event.target:setScale(1.0)
	    end)
	    :onButtonClicked(function()
	    	self.callback_(PauseView.EventAgain)
	    end)
	    :pos(display.cx, 260)
	    :addTo(self)

	-- give up
	cc.ui.UIPushButton.new(ImageName.BtnGiveUp)
	    :onButtonPressed(function(event)
	        event.target:setScale(1.1)
	    end)
	    :onButtonRelease(function(event)
	        event.target:setScale(1.0)
	    end)
	    :onButtonClicked(function()
	    	self.callback_(PauseView.EventGiveUp)
	    end)
	    :pos(display.cx-150, 140)
	    :addTo(self)

	-- back
	cc.ui.UIPushButton.new(ImageName.BtnNext)
	    :onButtonPressed(function(event)
	        event.target:setScale(1.1)
	    end)
	    :onButtonRelease(function(event)
	        event.target:setScale(1.0)
	    end)
	    :onButtonClicked(function()
	    	self.callback_(PauseView.EventBack)
	    end)
	    :pos(display.cx+150, 140)
	    :addTo(self)

end

return PauseView