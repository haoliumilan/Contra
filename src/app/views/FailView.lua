--
-- Author: Liu Hao
-- Date: 2015-12-16 10:13:35
-- 关卡失败

local FailView = class("FailView", function()
		return display.newNode()
	end)

FailView.ImgTopBg = "settle/top.png" 
FailView.ImgFailBg = "settle/failBg.png"
FailView.ImgAdd5Btn = "settle/add5Btn.png"

FailView.EventAdd5 = "add5"
FailView.EventAgain = "again"
FailView.EventGiveUp = "giveUp"

function FailView:ctor(property)
	self.callback_ = property.callback

	-- background color
	display.newColorLayer(cc.c4b(0, 0, 0, 200))
		:addTo(self)

	-- top
	display.newSprite(FailView.ImgTopBg, 231, display.top-65)
		:addTo(self)

	-- fail bg
	display.newSprite(FailView.ImgFailBg, display.cx, display.cy-30)
		:addTo(self)

	-- add 5 step btn
	cc.ui.UIPushButton.new(FailView.ImgAdd5Btn)
	    :onButtonPressed(function(event)
	        event.target:setScale(1.1)
	    end)
	    :onButtonRelease(function(event)
	        event.target:setScale(1.0)
	    end)
	    :onButtonClicked(function()
	    	self.callback_(FailView.EventAdd5)
	    end)
	    :pos(display.cx, 385)
	    :addTo(self)

	-- again btn
	cc.ui.UIPushButton.new(ImageName.BtnAgain)
	    :onButtonPressed(function(event)
	        event.target:setScale(1.1)
	    end)
	    :onButtonRelease(function(event)
	        event.target:setScale(1.0)
	    end)
	    :onButtonClicked(function()	
	    	self.callback_(FailView.EventAgain)
	    end)
	    :pos(display.cx, 270)
	    :addTo(self)

	-- give up btn
	cc.ui.UIPushButton.new(ImageName.BtnGiveUp)
	    :onButtonPressed(function(event)
	        event.target:setScale(1.1)
	    end)
	    :onButtonRelease(function(event)
	        event.target:setScale(1.0)
	    end)
	    :onButtonClicked(function()
	    	self.callback_(FailView.EventGiveUp)
	    end)
	    :pos(display.cx, 155)
	    :addTo(self)

end

return FailView