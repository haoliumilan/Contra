--
-- Author: liuhao
-- Date: 2015-12-16 10:13:52
-- 关卡目标

local TargetView = class("TargetView", function()
	return display.newNode()
end)

function TargetView:ctor(data)
	self.data_ = data
	self.labels_ = {}

	for i,v in ipairs(self.data_) do
		print(i, v[1], v[2])
		local iconName = string.format(ImageName.StoneNorml, v[1])
		local iconSp = display.newSprite(iconName, 30, display.top-35-50*i)
			:addTo(self)
			:scale(0.4)

		local count = string.format("x%d", checknumber(v[2]))
		self.labels_[i] = display.newTTFLabel({text = count, size = 25, color = display.COLOR_White}) 
        	:pos(80, display.top-35-50*i)
        	:addTo(self) 
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