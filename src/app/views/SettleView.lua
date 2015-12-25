--
-- Author: Liu Hao
-- Date: 2015-12-25 18:40:59
--

local SkillCfg = import("..config.SkillCfg")

local SettleView = class("SettleView", function()
	return display.newNode()
	end)

function SettleView:ctor(property)
	self.stoneData_ = property.settleData.stone
	self.skillData_ = property.settleData.skill
	self.stepCount_ = property.settleData.step or 0

	self.colorLayer_ = display.newColorLayer(cc.c4b(0, 0, 0, 200))
		:addTo(self)
		:size(120, 1100)

	display.newTTFLabel({text = string.format("回合x%d", self.stepCount_), size = 25}) 
    	:pos(60, display.top-260)
    	:addTo(self)

	local index = 1
	for i=1,enStoneType.Max do
		if self.stoneData_[i] and self.stoneData_[i] > 0 then
			display.newSprite(string.format(ImageName.StoneNorml, i), 30, display.top-260-50*index)
				:addTo(self)
				:scale(0.4)

			display.newTTFLabel({text = string.format("x%d", checknumber(self.stoneData_[i])), size = 25}) 
	        	:pos(80, display.top-260-50*index)
	        	:addTo(self) 
	       
	       	index = index + 1
	    end
	end

	for i=1,SkillCfg.getCount() do
		if self.skillData_[i] and self.skillData_[i] > 0 then
			local skillCfg = SkillCfg.get(i)
			skillView = display.newSprite(string.format(ImageName.StoneNorml, skillCfg.stoneType), 30, display.top-260-50*index)
				:addTo(self)
				:scale(0.4)

			local size = skillView:getContentSize()
			display.newSprite(string.format(ImageName.SkillIcon, #skillCfg.direction), size.width*0.5, size.height*0.5)
				:addTo(skillView)
				:rotation((skillCfg.direction[1] - 1) * 45)

			display.newTTFLabel({text = string.format("x%d", checknumber(self.skillData_[i])), size = 25}) 
	        	:pos(80, display.top-260-50*index)
	        	:addTo(self) 

			index = index + 1
		end
	end
end

return SettleView