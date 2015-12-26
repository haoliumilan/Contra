--
-- Author: Liu Hao
-- Date: 2015-12-25 20:18:53
--

local PicView = class("PicView", function()
	return display.newNode()
	end)

function PicView:ctor(property)
	self.picId_ = property.picId
	self.saturation_ = 1.0 -- 饱和度 {0.0~2.0}， 1
	self.brightness_ = 0 -- {-1.0~1.0}, 0
	self.picName_ = string.format(ImageName.Picture, self.picId_)

	-- self.sprite_ = display.newFilteredSprite(self.picName_, {"SATURATION", "BRIGHTNESS"}, {{self.saturation_}, {self.brightness_}}):addTo(self)
	self.sprite_ = display.newSprite(self.picName_):addTo(self)
		:pos(display.cx, 1110)
		:scale(0.35)
	-- self.sprite_:setTexture()
	-- local filter = filter.newFilter("BRIGHTNESS", {-0.0})
	-- self.sprite_:setFilter(filter)

	-- self.sprite_:clearFilter()
end

function PicView:updatePic_()
    local filters = filter.newFilters({"SATURATION", "BRIGHTNESS"}, {{self.saturation_}, {self.brightness_}})
    self.sprite_:setFilters(filters)
end


return PicView