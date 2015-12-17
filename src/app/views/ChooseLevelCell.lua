--
-- Author: liuhao
-- Date: 2015-12-12 10:48:15
-- 选择关卡的cell

local ChooseLevelCell = class("ChooseLevelCell", function()
	return display.newNode()
end)

enLevelCellType = {
	"Close",
	"Open",
	"Lock"
}
enLevelCellType = EnumTable(enLevelCellType, 0)

ChooseLevelCell.EventCellClicked = "cellClicked"
ChooseLevelCell.EventNewPic = "newPic"
ChooseLevelCell.EventSure = "sure"

ChooseLevelCell.ImgCellCloseBg = "level/closeBg.png"
ChooseLevelCell.ImgCellOpenBg = "level/openBg.png"
ChooseLevelCell.ImgNewPicBtn = "level/newPic.png"
ChooseLevelCell.ImgNew = "level/new.png"
ChooseLevelCell.ImgFinish = "level/finish.png"
ChooseLevelCell.ImgLock = "level/lock.png"
ChooseLevelCell.ImgArrowUp = "level/arrowUp.png"
ChooseLevelCell.ImgArrowDown = "level/arrowDown.png"
ChooseLevelCell.ImgSure = "level/sure.png"

function ChooseLevelCell:ctor(callback)
	self.callback_ = callback
	self.cellType_ = nil
	self.levelData_ = nil
	self.idx_ = nil

	self:initAllValue()
end

function ChooseLevelCell:initAllValue()
	self.cellBg_ = nil
	self.newPicBtn_ = nil
	self.leftSp_ = nil	
	self.titleLb_ = nil
	self.arrowSp_ = nil
	self.sureBtn_ = nil
end

function ChooseLevelCell:showContentView(cellType, levelData, idx)
	self.idx_ = idx
	self.levelData_ = levelData

	-- if self.cellType_ ~= cellType and (self.cellType_ == enLevelCellType.Open or cellType == enLevelCellType.Open) then
		self:removeAllChildren()
		self:initAllValue()
	-- end

	if cellType == enLevelCellType.Close then
		self:showCloseView()

	elseif cellType == enLevelCellType.Open then
		self:showOpenView()

	elseif cellType == enLevelCellType.Lock then
		self:showLockView()

	end

	self.cellType_ = cellType

end

function ChooseLevelCell:showCloseView()
	if self.cellType_ == enLevelCellType.Lock then
		if self.leftSp_ then
			self.leftSp_:removeFromParent()
			self.leftSp_ = nil		
		end
	end

	if self.cellBg_ == nil then
		self.cellBg_ = cc.ui.UIPushButton.new(ChooseLevelCell.ImgCellCloseBg)
		    :onButtonClicked(function()
		    	self.callback_({name = ChooseLevelCell.EventCellClicked, cellType = self.cellType_, idx = self.idx_})
		    end)
		    :addTo(self)
	    self.cellBg_:setTouchSwallowEnabled(false)

	end

	local openCount = cc.UserDefault:getInstance():getIntegerForKey("openCount", 1)
	if self.newPicBtn_ == nil and self.idx_ < openCount-1 then
		self.newPicBtn_ = cc.ui.UIPushButton.new(ChooseLevelCell.ImgNewPicBtn)
	        :onButtonPressed(function(event)
	            event.target:setScale(1.1)
	        end)
	        :onButtonRelease(function(event)
	            event.target:setScale(1.0)
	        end)
	        :onButtonClicked(function()
	        	self.callback_({name = ChooseLevelCell.EventNewPic})
	        end)
	        :pos(320, 0)
	        :addTo(self)
		display.newSprite(ChooseLevelCell.ImgNew, -5, 30)
			:addTo(self.newPicBtn_)
	end

	if self.titleLb_ == nil then
		self.titleLb_ = display.newTTFLabel({text = "", size = 40, color = display.COLOR_BLACK})	
	        :pos(-40, 10)
	        :addTo(self)
	end
	self.titleLb_:setString(string.format("%d.%s", self.idx_+1, self.levelData_.name))

	if self.leftSp_ == nil and self.idx_ < openCount-1 then
		self.leftSp_ = display.newSprite(ChooseLevelCell.ImgFinish, -220, 10)
			:addTo(self)
	end

	if self.arrowSp_ == nil then
		self.arrowSp_ = display.newSprite(ChooseLevelCell.ImgArrowDown, 230, 10)
		    :addTo(self)
	end
end

function ChooseLevelCell:showOpenView()
	if self.cellBg_ == nil then
		self.cellBg_ = display.newSprite(ChooseLevelCell.ImgCellOpenBg)
			:addTo(self)
	end

	local name = string.format("%d.%s", self.idx_+1, self.levelData_.name)
	local menuLabel = cc.MenuItemLabel:create(display.newTTFLabel({text = name, size = 40, color = display.COLOR_BLACK}))
		:pos(0, 400)
	menuLabel:registerScriptTapHandler(function()
	 	self.callback_({name = ChooseLevelCell.EventCellClicked, cellType = self.cellType_, idx = self.idx_})
		end)
	local menu = cc.Menu:create(menuLabel)
			:addTo(self)
			:pos(0, 0)

	if self.arrowSp_ == nil then
		self.arrowSp_ = display.newSprite(ChooseLevelCell.ImgArrowUp, 230, 440)
		    :addTo(self)
	end

	if self.sureBtn_ == nil then
		self.newPicBtn_ = cc.ui.UIPushButton.new(ChooseLevelCell.ImgSure)
	        :onButtonPressed(function(event)
	            event.target:setScale(1.1)
	        end)
	        :onButtonRelease(function(event)
	            event.target:setScale(1.0)
	        end)
	        :onButtonClicked(function()
	        	self.callback_({name = ChooseLevelCell.EventSure, cellType = self.cellType_, idx = self.idx_})
	        end)
	        :pos(0, -390)
	        :addTo(self)
	end
end

function ChooseLevelCell:showLockView()
	if self.cellType_ == enLevelCellType.Close then
		if self.leftSp_ then
			self.leftSp_:removeFromParent()
			self.leftSp_ = nil
		end
	end

	if self.cellBg_ == nil then
		self.cellBg_ = display.newSprite(ChooseLevelCell.ImgCellCloseBg)
			:addTo(self)
	end

	if self.newPicBtn_ then
		self.newPicBtn_:removeFromParent()
		self.newPicBtn_ = nil
	end

	if self.titleLb_ == nil then
		self.titleLb_ = display.newTTFLabel({text = "", size = 40, color = display.COLOR_BLACK})	
	        :pos(-40, 10)
	        :addTo(self)
	end
	self.titleLb_:setString(string.format("%d.%s", self.idx_+1, self.levelData_.name))

	if self.leftSp_ == nil then
		self.leftSp_ = display.newSprite(ChooseLevelCell.ImgLock, -220, 0)
			:addTo(self)
	end

	if self.arrowSp_ == nil then
		self.arrowSp_ = display.newSprite(ChooseLevelCell.ImgArrowDown, 230, 10)
		    :addTo(self)
	end
end

return ChooseLevelCell
