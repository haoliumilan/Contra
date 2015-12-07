--
-- Author: liuhao
-- Date: 2015-12-07 16:10:28
-- 

--  状态类型
enSkillState = {
    "CanNotUse", -- 不能使用
    "CanUse", -- 能使用
    "Using" -- 使用中
}
enSkillState = EnumTable(enSkillState, 0)

local SkillView = class("SkillView", function()
    return display.newNode()
end)

SkillView.Img_Stone_Norml = "stone/stone_n_%d.png"
SkillView.Img_Stone_Hightlight = "stone/stone_h_%d.png"

function SkillView:ctor(property)
	self.skillState_ = property.skillState or enSkillState.CanNotUse
	self.skillData_ = property.skillData

	self.sprite_ = display.newFilteredSprite():addTo(self)
		:scale(1.2)

	self:updateSprite_()
end

function SkillView:getSkillState()
	return self.skillState_
end

function SkillView:setSkillState(skillState)
	self.skillState_ = skillState
	self:updateSprite_()
end

function SkillView:updateSprite_()
    local texFile = nil
    self.sprite_:removeAllChildren()
    local colorType = self.skillData_:getColorType()
    if self.skillState_ == enSkillState.CanUse then
        texFile = string.format(SkillView.Img_Stone_Norml, colorType)
    elseif self.skillState_ == enSkillState.Using then
        texFile = string.format(SkillView.Img_Stone_Hightlight, colorType)
    elseif self.skillState_ == enSkillState.CanNotUse then
        texFile = string.format(SkillView.Img_Stone_Norml, colorType)
    end

    if not texFile then return end
    self.sprite_:setTexture(texFile)

    if self.skillState_ == enStoneState.CanNotUse then
        local filters = filter.newFilter("BRIGHTNESS", {-0.5})
        self.sprite_:setFilter(filters)
    else
        self.sprite_:clearFilter()
    end

    texFile = string.format(ImageName.SkillIcon, self.skillData_:getIconIndex())
    local size = self.sprite_:getContentSize()
    display.newSprite(texFile)
    	:addTo(self.sprite_)
    	:rotation(self.skillData_:getIconAngle())
    	:pos(size.width*0.5, size.height*0.5)
end

return SkillView
