--
-- Author: Liu Hao
-- Date: 2015-12-12 10:48:15
-- 选择关卡的cell

local SkillCfg = import("..config.SkillCfg")

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
ChooseLevelCell.ImgImg = "image/image_%s.png"
ChooseLevelCell.ImgSkillBg = "level/skillBg.jpg"

function ChooseLevelCell:ctor(callback)
	self.callback_ = callback
	self.cellType_ = nil
	self.levelData_ = nil
	self.idx_ = nil

	self:initAllValue()
end

function ChooseLevelCell:initAllValue()

end

function ChooseLevelCell:showContentView(cellType, levelData, idx)
	self.idx_ = idx
	self.levelData_ = levelData

	self:removeAllChildren()
	self:initAllValue()

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
	local cellBg = cc.ui.UIPushButton.new(ChooseLevelCell.ImgCellCloseBg)
	    :onButtonClicked(function()
	    	self.callback_({name = ChooseLevelCell.EventCellClicked, cellType = self.cellType_, idx = self.idx_})
	    end)
	    :addTo(self)
    cellBg:setTouchSwallowEnabled(false)

	local openCount = cc.UserDefault:getInstance():getIntegerForKey("openCount", 1)
	if self.idx_ < openCount-1 then
		local newPicBtn = cc.ui.UIPushButton.new(ChooseLevelCell.ImgNewPicBtn)
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
			:addTo(newPicBtn)
	end

	local titleLb = display.newTTFLabel({text = "", size = 40, color = display.COLOR_BLACK})	
	        :pos(-40, 10)
	        :addTo(self)
	titleLb:setString(string.format("%d.%s", self.idx_+1, self.levelData_.name))

	if self.idx_ < openCount-1 then
		local leftSp = display.newSprite(ChooseLevelCell.ImgFinish, -220, 10)
				:addTo(self)
	end

	local arrowSp = display.newSprite(ChooseLevelCell.ImgArrowDown, 230, 10)
		    :addTo(self)
end

function ChooseLevelCell:showOpenView()
	display.newSprite(ChooseLevelCell.ImgSkillBg, 0, -230)
		:addTo(self)

	local cellBg = display.newSprite(ChooseLevelCell.ImgCellOpenBg)
		:addTo(self)

	local titleLb = display.newTTFLabel({text = "", size = 40, color = display.COLOR_BLACK})	
	        :pos(-40, 440)
	        :addTo(self)
	titleLb:setString(string.format("%d.%s", self.idx_+1, self.levelData_.name))

	local arrowSp = display.newSprite(ChooseLevelCell.ImgArrowUp, 230, 440)
	    :addTo(self)

	local image = display.newSprite(string.format(ChooseLevelCell.ImgImg, self.levelData_.id), -10, 290)
			:addTo(self)

	local detailLb = display.newTTFLabel({text = self.levelData_.detail, size = 25, color = display.COLOR_BLACK,
		valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP, align = cc.TEXT_ALIGNMENT_LEFT, dimensions = cc.size(500, 100)})	
	        :pos(0, 105)
	        :addTo(self)

	-- 目标
	app:createView("TargetView", {targetData = self.levelData_.target, targetType = 2, labelColor = cc.COLOR_BLACK})
		:addTo(self)

	-- 技能
	local skillArr = self.levelData_.skill
	local skillCfg = nil
	local skillView = nil
	for i=1,5 do
		skillCfg = SkillCfg.get(skillArr[i])
		skillView = display.newSprite(string.format(ImageName.StoneNorml, skillCfg.stoneType), -285+95*i, -230)
			:addTo(self)
			:scale(0.7)

		local size = skillView:getContentSize()
		display.newSprite(string.format(ImageName.SkillIcon, #skillCfg.direction), size.width*0.5, size.height*0.5)
			:addTo(skillView)
			:rotation((skillCfg.direction[1] - 1) * 45)

	end

	cc.ui.UIPushButton.new(ChooseLevelCell.ImgSure)
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

    -- touchLayer 用于接收触摸事件
    self.touchLayer_ = display.newLayer()
    	:size(560, 60)
    	:pos(-280, 420)
    	:addTo(self)

    -- 启用触摸
    self.touchLayer_:setTouchEnabled(true) 
    self.touchLayer_:setTouchSwallowEnabled(false)
    -- 添加触摸事件处理函数
    self.touchLayer_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch_))
end

function ChooseLevelCell:onTouch_(event)
	if event.name == "began" then
	    return true
	elseif event.name == "ended" then
	 	self.callback_({name = ChooseLevelCell.EventCellClicked, cellType = self.cellType_, idx = self.idx_})
	end

end

function ChooseLevelCell:showLockView()
	local cellBg = display.newSprite(ChooseLevelCell.ImgCellCloseBg)
		:addTo(self)

	local titleLb = display.newTTFLabel({text = "", size = 40, color = display.COLOR_BLACK})	
        :pos(-40, 10)
        :addTo(self)
	titleLb:setString(string.format("%d.%s", self.idx_+1, self.levelData_.name))

	local leftSp = display.newSprite(ChooseLevelCell.ImgLock, -220, 0)
			:addTo(self)

	local arrowSp = display.newSprite(ChooseLevelCell.ImgArrowDown, 230, 10)
		    :addTo(self)
end

return ChooseLevelCell
