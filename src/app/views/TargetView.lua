--
-- Author: Liu Hao
-- Date: 2015-12-16 10:13:52
-- 关卡目标

local TargetView = class("TargetView", function()
	return display.newNode()
end)

function TargetView:ctor(property)
	self.data_ = property.targetData
	self.type_ = property.targetType
	self.color_ = property.labelColor or display.COLOR_White
	self.labels_ = {}

	if self.type_ == 1 then
		for i,v in ipairs(self.data_) do
			local iconName = string.format(ImageName.StoneNorml, v[1], v[1])
			local iconSp = display.newSprite(iconName, 30, display.top-35-50*i)
				:addTo(self)
				:scale(0.4)

			local count = string.format("x%d", checknumber(v[2]))
			self.labels_[i] = display.newTTFLabel({text = count, size = 25, color = self.color_}) 
	        	:pos(80, display.top-35-50*i)
	        	:addTo(self) 
		end
	elseif self.type_ == 2 then
		for i,v in ipairs(self.data_) do
			local iconName = string.format(ImageName.StoneNorml, v[1], v[1])
			display.newSprite(iconName, -180+(i-1)%3*150, -70*math.floor((i-1)/3))
				:addTo(self)
				:scale(0.5)

			local count = string.format("x%d", checknumber(v[2]))
			display.newTTFLabel({text = count, size = 35, color = self.color_, align = cc.TEXT_ALIGNMENT_LEFT, 
				dimensions = cc.size(100, 40)})     
	        	:pos(-100+(i-1)%3*150, -70*math.floor((i-1)/3))
	        	:addTo(self) 
		end

	end
end

function TargetView:udpateTargetCount(newCounts)
	for i,v in ipairs(self.data_) do
		local newCount = v[2] - newCounts[v[1]]
		newCount = math.max(newCount, 0)
		self.labels_[i]:setString("x" .. newCount)
	end
end

return TargetView