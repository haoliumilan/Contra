--
-- Author: Liu Hao
-- Date: 2015-12-18 10:09:17
-- 关卡界面提示

local TipsView = class("TipsView", function()
	return display.newNode()
	end)

-- time
TipsView.TimeMove = 0.2

-- image
TipsView.ImgTipsIcon = "play/tips.png"

-- text
TipsView.TxtStart = "请尝试点击任意颜色方块"
TipsView.TxtLessThree = "你需要选择更多的方块"
TipsView.TxtAgainTouch = "再次点击消除"
TipsView.TxtUseSkill = "请选择一个可放置技能的方块"
TipsView.TxtSureSkill = "请再次点击以确认"

function TipsView:ctor()
	display.newSprite(TipsView.ImgTipsIcon, display.left+36, display.cy+100)
		:addTo(self)

	local clipNode = display.newClippingRectangleNode(cc.rect(display.left+80, display.cy+80, 400, 40))
		:addTo(self)

	self.label_ = display.newTTFLabel({text = "", size = 26, color = display.COLOR_BLACK})
	    :addTo(clipNode)
	display.align(self.label_, display.CENTER_LEFT, display.left+90, display.cy+100)

end

-- 
function TipsView:showTips(tag)
	if tag == nil then
		if self.label_:getString() ~= "" then
			self.label_:stop()
			self.label_:performWithDelay(function()
				self.label_:setString("")
				end, 0.5)
		else
			self.label_:stop()
			self.label_:setString("")
		end
	else
		local delay = 0.5
		if tag == TipsView.TxtStart then
			delay = 5.0
		end
		self.label_:stop()
		self.label_:performWithDelay(function()
			self.label_:setString(tag)
			self.label_:pos(display.left+90-400, display.cy+100)
			self.label_:moveTo(TipsView.TimeMove, display.left+90, display.cy+100)
			end, delay)
	end
end

return TipsView