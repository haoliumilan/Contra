--
-- Author: Liu Hao
-- Date: 2015-12-03 18:28:24
-- 珠子的视图

local SkillData = import("..data.SkillData")
local StoneCfg = import("..config.StoneCfg")

--  状态类型
enStoneState = {
    "Normal",
    "Highlight",
    "Disable"
}
enStoneState = EnumTable(enStoneState, 0)

local StoneView = class("StoneView", function()
    return display.newNode()
end)

StoneView.ImgSkillXuKuang = "skill/skill_xukuang.png"

function StoneView:ctor(property)
    self.stoneState_ = property.stoneState or enStoneState.Normal
    self.stoneType_ = property.stoneType or enStoneType.Red
    self.stoneCfg_ = StoneCfg.get(self.stoneType_ )
    self.rowIndex_ = property.rowIndex or 1
    self.colIndex_ = property.colIndex or 1
    self.skillData_ = nil
    self.curHitCount_ = self.stoneCfg_.hit_count
    self.isSkillEffect_ = false -- 使用技能消除的

    self.sprite_ = display.newFilteredSprite():addTo(self)
    self.skillEffectSp_ = nil
    self.label_ = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 30, color = cc.c3b(0, 0, 0)})
	    :align(display.CENTER)
	    :addTo(self)
	self.label_:setString(string.format("%d, %d", self.rowIndex_, self.colIndex_))
    self.label_:setVisible(false)

    self:updateSprite_()
end

---- property

-- 如果溅射后直接消除，返回true
function StoneView:splash()
    if self.curHitCount_ > 1 then
        self.curHitCount_ = self.curHitCount_ - 1
        self:updateSprite_()
        return false
    else
        return true
    end
end

function StoneView:getIsSplash()
    return self.stoneCfg_.is_splash
end

function StoneView:getIsSelected()
    return self.stoneCfg_.is_selected
end

function StoneView:setStoneState(stoneState, isClearSkillEffect)
    self.stoneState_ = stoneState
    if isClearSkillEffect == true then
        self.isSkillEffect_ = false
    end
    self:updateSprite_()
end

function StoneView:getStoneState()
    return self.stoneState_
end

function StoneView:setStoneType(stoneType)
    self.stoneType_ = stoneType
    self.stoneCfg_ = StoneCfg.get(self.stoneType_ )
end

function StoneView:getStoneType()
    return self.stoneType_
end

function StoneView:setRowColIndex(rowIndex, colIndex)
    self.rowIndex_ = rowIndex
    self.colIndex_ = colIndex
    self.label_:setString(string.format("%d, %d", self.rowIndex_, self.colIndex_))
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
    self.isSkillEffect_ = isSkillEffect
    self:updateSprite_()
end

function StoneView:getIsSkillEffect()
    return self.isSkillEffect_
end

----

function StoneView:updateSprite_()
    local texFile = nil
    self.sprite_:removeAllChildren()
    if self.stoneState_ == enStoneState.Normal or self.stoneState_ == enStoneState.Disable then
        if self.curHitCount_ < self.stoneCfg_.hit_count then
            texFile = string.format(ImageName.StoneNorml2, self.stoneType_, (self.stoneCfg_.hit_count+1-self.curHitCount_))
        else
            texFile = string.format(ImageName.StoneNorml, self.stoneType_)
        end
    elseif self.stoneState_ == enStoneState.Highlight then
        texFile = string.format(ImageName.StoneHightlight, self.stoneType_)
    end

    if not texFile then return end
    self.sprite_:setTexture(texFile)

    local size = self.sprite_:getContentSize()
    if self.stoneState_ == enStoneState.Disable then
        local filters = filter.newFilter("BRIGHTNESS", {-0.5})
        self.sprite_:setFilter(filters)
    else
        self.sprite_:clearFilter()
    end

    -- 技能icon
    if self.skillData_ then
        texFile = string.format(ImageName.SkillIcon, self.skillData_:getIconIndex())
        display.newSprite(texFile, size.width*0.5, size.height*0.5)
            :addTo(self.sprite_)
            :rotation(self.skillData_:getIconAngle())
    end

    --  技能波及
    if self.isSkillEffect_ == true then
        display.newSprite(StoneView.ImgSkillXuKuang, size.width*0.5, size.height*0.5)
            :addTo(self.sprite_)
    end

end

return StoneView

