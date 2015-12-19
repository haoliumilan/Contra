--
-- Author: Liu Hao
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

SkillView.TimeSkBgMove = 0.2 
SkillView.TimeSkBgDelay = 1.0 

function SkillView:ctor(property)
	self.skillState_ = property.skillState or enSkillState.CanNotUse
	self.skillData_ = property.skillData
    self.isShowSkillCount_ = false

    -- 通过代理注册事件的好处：可以方便的在视图删除时，清理所以通过该代理注册的事件，
    -- 同时不影响目标对象上注册的其他事件
    -- EventProxy.new() 第一个参数是要注册事件的对象，第二个参数是绑定的视图
    -- 如果指定了第二个参数，那么在视图删除时，会自动清理注册的事件
    cc.EventProxy.new(self.skillData_, self)
        :addEventListener(self.skillData_.CHANGE_CURCOUNT_EVENT, handler(self, self.updateSkillCount_))

	self.sprite_ = display.newFilteredSprite()
        :addTo(self, 1)
		:scale(1.2)

    self.labelBg_ = display.newScale9Sprite(ImageName.NineFrame1, 0, 0, cc.size(60, 60))
        :addTo(self)

    -- self.label_ = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 30, color = cc.c3b(255, 255, 255)})
    --     :align(display.CENTER)
    --     :pos(30, 20)
    --     :addTo(self.labelBg_)
    
    self.label_ = display.newTTFLabel({size = 30, color = display.COLOR_White}) 
        :pos(30, 20)
        :addTo(self.labelBg_) 


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

function SkillView:showSkillCount(isShow, isAutoHide)
    if isShow and self.skillData_:getNeedCount() == self.skillData_:getCurCount() then
        return
    end

    if isShow == self.isShowSkillCount_ then
        return
    end

    self.labelBg_:stopAllActions()
    self.isShowSkillCount_ = isShow
    if isShow then
        self.labelBg_:stop()
        self.labelBg_:runAction(transition.sequence({
                cc.MoveTo:create(SkillView.TimeSkBgMove, cc.p(0, -60)),
                cc.DelayTime:create(SkillView.TimeSkBgDelay),
                cc.CallFunc:create(function()
                    if isAutoHide then
                        self.isShowSkillCount_ = false
                        self.labelBg_:stop()
                        self.labelBg_:moveTo(SkillView.TimeSkBgMove, 0, 0)
                    end
                    end)
            }))
    else
        self.labelBg_:stop()
        self.labelBg_:pos(0, -60)
        self.labelBg_:runAction(transition.sequence({
                cc.DelayTime:create(SkillView.TimeSkBgDelay),
                cc.MoveTo:create(SkillView.TimeSkBgMove, cc.p(0, 0))
            }))        
    end
end

function SkillView:updateSkillCount_()
    local needCount = self.skillData_:getNeedCount()
    local curCount = self.skillData_:getCurCount()

    self.label_:setString(string.format("%d", needCount-curCount))
    if curCount < needCount then
        self:setSkillState(enSkillState.CanNotUse)
    else
        self:setSkillState(enSkillState.CanUse)
    end
end

function SkillView:updateSprite_()
    local texFile = nil
    self.sprite_:removeAllChildren()
    local stoneType = self.skillData_:getStoneType()
    if self.skillState_ == enSkillState.CanUse then
        texFile = string.format(ImageName.StoneNorml, stoneType)
    elseif self.skillState_ == enSkillState.Using then
        texFile = string.format(ImageName.StoneHightlight, stoneType)
    elseif self.skillState_ == enSkillState.CanNotUse then
        texFile = string.format(ImageName.StoneNorml, stoneType)
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
    display.newSprite(texFile, size.width*0.5, size.height*0.5)
    	:addTo(self.sprite_)
    	:rotation(self.skillData_:getIconAngle())

end

return SkillView
