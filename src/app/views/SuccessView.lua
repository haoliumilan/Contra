--
-- Author: Liu Hao
-- Date: 2015-12-16 10:13:19
-- 关卡胜利

local SuccessView = class("SuccessView", function()
 	return display.newLayer()
end)

SuccessView.ImgBg = "settle/bg.jpg"
SuccessView.SuccessBg = "settle/successBg.png"

SuccessView.EventBack = "back"
SuccessView.EventNext = "next"

function SuccessView:ctor(property)
    self.callback_ = property.callback
    self.levelData_ = property.levelData

	-- 启用触摸
	self:setTouchSwallowEnabled(true)

	-- background
	display.newSprite(SuccessView.ImgBg, display.cx, display.cy)
		:addTo(self)

    -- top
    display.newSprite(ImageName.TopBg, display.cx, display.top - 65)
        :addTo(self)

	-- success bg
	display.newSprite(SuccessView.SuccessBg, display.cx, display.cy-30)
		:addTo(self)

    -- name
    display.newTTFLabel({text = string.format("%s.%s", self.levelData_.id, self.levelData_.name),
            size = 40, color = display.COLOR_WHITE})    
            :pos(display.cx, 1130)
            :addTo(self)

    -- pic
    display.newSprite(string.format(ImageName.Picture, self.levelData_.picture), display.cx, 760)
        :addTo(self)
        :scale(0.5)

	-- back button
    cc.ui.UIPushButton.new(ImageName.BtnBack)
        :onButtonPressed(function(event)
            event.target:setScale(1.1)
        end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
        :onButtonClicked(function()
        	self.callback_(SuccessView.EventBack)
        end)
        :pos(200, 190)
        :addTo(self)

	-- next button
    cc.ui.UIPushButton.new(ImageName.BtnNext)
        :onButtonPressed(function(event)
            event.target:setScale(1.1)
        end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
        :onButtonClicked(function()
        	self.callback_(SuccessView.EventNext)
        end)
        :pos(550, 190)
        :addTo(self)

end

return SuccessView