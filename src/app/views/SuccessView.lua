--
-- Author: Liu Hao
-- Date: 2015-12-16 10:13:19
-- 关卡胜利

local SuccessView = class("SuccessView", function()
 	return display.newLayer()
end)

SuccessView.ImgBg = "settle/bg.jpg"
SuccessView.SuccessBg = "settle/successBg.png"
SuccessView.BackBtn = "settle/backBtn.png"
SuccessView.NextBtn = "settle/nextBtn.png"

SuccessView.EventBack = "back"
SuccessView.EventNext = "next"

function SuccessView:ctor(callback)
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

	-- back button
    cc.ui.UIPushButton.new(SuccessView.BackBtn)
        :onButtonPressed(function(event)
            event.target:setScale(1.1)
        end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
        :onButtonClicked(function()
        	callback(SuccessView.EventBack)
        end)
        :pos(200, 190)
        :addTo(self)

	-- next button
    cc.ui.UIPushButton.new(SuccessView.NextBtn)
        :onButtonPressed(function(event)
            event.target:setScale(1.1)
        end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
        :onButtonClicked(function()
        	callback(SuccessView.EventNext)
        end)
        :pos(550, 190)
        :addTo(self)

end

return SuccessView