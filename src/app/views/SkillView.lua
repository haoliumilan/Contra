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

    -- 通过代理注册事件的好处：可以方便的在视图删除时，清理所以通过该代理注册的事件，
    -- 同时不影响目标对象上注册的其他事件
    -- EventProxy.new() 第一个参数是要注册事件的对象，第二个参数是绑定的视图
    -- 如果指定了第二个参数，那么在视图删除时，会自动清理注册的事件
    cc.EventProxy.new(self.skillData_, self)
        :addEventListener(self.skillData_.CHANGE_CURCOUNT_EVENT, handler(self, self.updateSkillCount_))

	self.sprite_ = display.newFilteredSprite():addTo(self)
		:scale(1.2)

    self.label_ = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 30, color = cc.c3b(255, 255, 255)})
        :align(display.CENTER)
        :pos(0, -80)
        :addTo(self)

    self:updateSkillCount_()

	self:updateSprite_()
end

function SkillView:getSkillState()
	return self.skillState_
end

function SkillView:setSkillState(skillState)
	self.skillState_ = skillState
	self:updateSprite_()
end

function SkillView:updateSkillCount_()
    local needCount = self.skillData_:getNeedCount()
    local curCount = self.skillData_:getCurCount()

    self.label_:setString(string.format("%d/%d", curCount, needCount))
    if curCount < needCount then
        self:setSkillState(enSkillState.CanNotUse)
    else
        self:setSkillState(enSkillState.CanUse)
    end
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

    if self.skillState_ == enSkillState.CanNotUse then
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
