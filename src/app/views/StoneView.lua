--
-- Author: liuhao
-- Date: 2015-12-03 18:28:24
-- 珠子的视图

local SkillData = import("app.data.SkillData")

--  状态类型
enStoneState = {
    "Normal",
    "Highlight",
    "Skill",
    "Disable"
}
enStoneState = EnumTable(enStoneState, 0)

local StoneView = class("StoneView", function()
    return display.newNode()
end)

StoneView.Img_Stone_Norml = "stone/stone_n_%d.png"
StoneView.Img_Stone_Hightlight = "stone/stone_h_%d.png"
StoneView.Img_Skill_XuKuang = "skill/skill_xukuang.png"

function StoneView:ctor(property)
    self.stoneState_ = property.stoneState or enStoneState.Normal
    self.stoneColor_ = property.stoneColor or enColorType.Red 
    self.rowIndex_ = property.rowIndex or 1
    self.colIndex_ = property.colIndex or 1
    self.skillData_ = nil

    self.sprite_ = display.newFilteredSprite():addTo(self)
    self.skillEffectSp_ = nil
 --    self.label_ = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 30, color = cc.c3b(0, 0, 0)})
	--     :align(display.CENTER)
	--     :addTo(self)

	-- self.label_:setString(string.format("%d, %d", self.rowIndex_, self.colIndex_))

    self:updateSprite_()
end

---- property

function StoneView:setStoneState(stoneState)
    self.stoneState_ = stoneState
    self:updateSprite_()
end

function StoneView:getStoneState()
    return self.stoneState_
end

function StoneView:setStoneColor(stoneColor)
    self.stoneColor_ = stoneColor
end

function StoneView:getColorType()
    return self.stoneColor_
end

function StoneView:setRowColIndex(rowIndex, colIndex)
    self.rowIndex_ = rowIndex
    self.colIndex_ = colIndex
    -- self.label_:setString(string.format("%d, %d", self.rowIndex_, self.colIndex_))
end

function StoneView:getRowColIndex()
    return self.rowIndex_, self.colIndex_
end

function StoneView:setSkillData(skillData)
    self.skillData_ = skillData
    self:updateSprite_()
end

function StoneView:getSkillData()
    return self.skillData_
end

function StoneView:setSkillEffect(isSkillEffect)
    if isSkillEffect == true then
        local size = self.sprite_:getContentSize()
        self.skillEffectSp_ = display.newSprite(StoneView.Img_Skill_XuKuang)
            :addTo(self.sprite_)
            :pos(size.width/2.0, size.height/2.0)
    else
        if self.skillEffectSp_ then
            self.skillEffectSp_:removeFromParent()
            self.skillEffectSp_ = nil
        end
    end
end

----

function StoneView:updateSprite_()
    local texFile = nil
    self.sprite_:removeAllChildren()
    if self.stoneState_ == enStoneState.Normal then
        texFile = string.format(StoneView.Img_Stone_Norml, self.stoneColor_)
    elseif self.stoneState_ == enStoneState.Highlight then
        texFile = string.format(StoneView.Img_Stone_Hightlight, self.stoneColor_)
    elseif self.stoneState_ == enStoneState.Disable then
        texFile = string.format(StoneView.Img_Stone_Norml, self.stoneColor_)
    end

    if not texFile then return end
    self.sprite_:setTexture(texFile)

    if self.stoneState_ == enStoneState.Disable then
        local filters = filter.newFilter("BRIGHTNESS", {-0.5})
        self.sprite_:setFilter(filters)
    else
        self.sprite_:clearFilter()
    end

    if self.skillData_ then
        texFile = string.format(ImageName.SkillIcon, self.skillData_:getIconIndex())
        local size = self.sprite_:getContentSize()
        display.newSprite(texFile)
            :addTo(self.sprite_)
            :rotation(self.skillData_:getIconAngle())
            :pos(size.width*0.5, size.height*0.5)
    end
end

return StoneView

