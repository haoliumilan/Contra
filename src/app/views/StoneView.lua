--
-- Author: liuhao
-- Date: 2015-12-03 18:28:24
-- 珠子的视图

local StoneData = import("app.data.StoneData")

local StoneView = class("StoneView", function()
    return display.newNode()
end)

StoneView.Img_Stone_Norml = "stone/stone_n_%d.png"
StoneView.Img_Stone_Hightlight = "stone/stone_h_%d.png"

function StoneView:ctor(stoneData)
	self.stoneData_ = stoneData
    local cls = self.stoneData_
    -- 通过代理注册事件的好处：可以方便的在视图删除时，清理所以通过该代理注册的事件，
    -- 同时不影响目标对象上注册的其他事件
    --
    -- EventProxy.new() 第一个参数是要注册事件的对象，第二个参数是绑定的视图
    -- 如果指定了第二个参数，那么在视图删除时，会自动清理注册的事件
    cc.EventProxy.new(self.stoneData_, self)
        :addEventListener(cls.CHANGE_STATE_EVENT, handler(self, self.onStateChange_))
        :addEventListener(cls.DISABLE_EVENT, handler(self, self.onDisable_))
        :addEventListener(cls.INDEX_EVENT, handler(self, self.onIndex_))

    self.sprite_ = display.newFilteredSprite():addTo(self)
    self.label_ = cc.ui.UILabel.new({UILabelType = 2, text = "", size = 30, color = cc.c3b(0, 0, 0)})
	    :align(display.CENTER)
	    :addTo(self)
	local x, y = self.stoneData_:getRowColIndex()
	self.label_:setString(string.format("%d, %d", x, y))

    self:updateSprite_()
end

----

function StoneView:getStoneData()
	return self.stoneData_
end

----

function StoneView:onStateChange_(event)
    self:updateSprite_()
end

function StoneView:onDisable_(event)
	local filters = filter.newFilter("BRIGHTNESS", {0.5})
	self.sprite_:setFilter(filters)
end

function StoneView:onIndex_(event)
	local x, y = self.stoneData_:getRowColIndex()
	self.label_:setString(string.format("%d, %d", x, y))
end

function StoneView:updateSprite_()
    local texFile = nil
    local state = self.stoneData_:getState()
    if state == "normal" then
        texFile = string.format(StoneView.Img_Stone_Norml, self.stoneData_:getColorType())
    elseif state == "highlight" then
        texFile = string.format(StoneView.Img_Stone_Hightlight, self.stoneData_:getColorType())
    elseif state == "gray" then
        texFile = string.format(StoneView.Img_Stone_Norml, self.stoneData_:getColorType())
    end

    if not texFile then return end
    self.sprite_:setTexture(texFile)
   	self.sprite_:clearFilter()
end

return StoneView

