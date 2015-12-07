--
-- Author: liuhao
-- Date: 2015-12-03 18:28:24
-- 珠子的视图

--  状态类型
enStoneState = {
    "Normal",
    "Highlight",
    "Disable"
}
enStoneState = EnumTable(enStoneState, 0)

-- 颜色类型
enStoneColor = {
    "Red",
    "Yellow",
    "Blue",
    "Green",
    "Purple",
    "Max"
}
enStoneColor = EnumTable(enStoneColor, 0)

local StoneView = class("StoneView", function()
    return display.newNode()
end)

StoneView.Img_Stone_Norml = "stone/stone_n_%d.png"
StoneView.Img_Stone_Hightlight = "stone/stone_h_%d.png"

function StoneView:ctor(property)
    self.stoneState_ = property.stoneState or enStoneState.Normal
    self.stoneColor_ = property.stoneColor or enStoneColor.Red 
    self.rowIndex_ = property.rowIndex or 1
    self.colIndex_ = property.colIndex or 1

    self.sprite_ = display.newFilteredSprite():addTo(self)
    self.label_ = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 30, color = cc.c3b(0, 0, 0)})
	    :align(display.CENTER)
	    :addTo(self)

	self.label_:setString(string.format("%d, %d", self.rowIndex_, self.colIndex_))

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
    self.label_:setString(string.format("%d, %d", self.rowIndex_, self.colIndex_))
end

function StoneView:getRowColIndex()
    return self.rowIndex_, self.colIndex_
end

----

function StoneView:updateSprite_()
    local texFile = nil
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
        local filters = filter.newFilter("BRIGHTNESS", {0.5})
        self.sprite_:setFilter(filters)
    else
        self.sprite_:clearFilter()
    end
end

return StoneView

