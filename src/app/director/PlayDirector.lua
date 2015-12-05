--
-- Author: liuhao
-- Date: 2015-12-03 20:40:46
-- 

local StoneView = import("app.views.StoneView")
local StoneData = import("app.data.StoneData")

local PlayDirector = class("PlayDirector", function()
	return display.newNode()
end)

-- 常量
PlayDirector.SMaxRow = 7 -- 最大行数
PlayDirector.SMaxCol = 7 -- 最大列数
PlayDirector.SOriPosX = 15 -- 珠子矩阵最左坐标
PlayDirector.SOriPosY = 100 
PlayDirector.SSpace = 20 -- 珠子的间隔
PlayDirector.SSide = 80 -- 珠子的边长
PlayDirector.DropTime = 0.15 -- 珠子掉落一个格子用的时间

function PlayDirector:ctor()
	self.stoneViews_ = {} -- 7x7 stoneView
	self.selectStones_ = {} -- 选中的stoneView

	self:initMatrix()

	-- 启用触摸
	self:setTouchEnabled(true)	
	-- 添加触摸事件处理函数
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch))
end

-- 初始化7x7的珠子矩阵
function PlayDirector:initMatrix()
	for i=1,PlayDirector.SMaxRow do
		self.stoneViews_[i] = {}
		for j=1,PlayDirector.SMaxCol do
			local oneStoneData = StoneData.new({rowIndex = i, colIndex = j})
			oneStoneData:setRandomColorType()
			local posX, posY = self:getPosByRowColIndex(i, j)
			self.stoneViews_[i][j] = app:createView("StoneView", oneStoneData)
				:addTo(self)
				:pos(posX, posY)
		end
	end

end

-- 消除后，更新7x7矩阵
function PlayDirector:updateMatrix()
	local pos1X, pos1Y, pos2X, pos2Y
	local oneStone
	local oneStoneData
	local tempIndex
	local addStoneArr = {} -- 用来记录每一列新创建的珠子

	for i=1,PlayDirector.SMaxRow do
		for j=1,PlayDirector.SMaxCol do
			oneStone = self.stoneViews_[i][j]
			if oneStone == nil then
			-- 去找它上面的，离他最近的那个stone
				tempIndex = 0
				pos1X, pos1Y = self:getPosByRowColIndex(i, j)

				while oneStone == nil do
					if i + tempIndex == PlayDirector.SMaxRow then
						break
					else
						tempIndex = tempIndex + 1
						oneStone = self.stoneViews_[i+tempIndex][j]
					end
				end

				if oneStone == nil then
				-- 说明当前stone上面也没有stone了，要重新创建
					addStoneArr[j] = addStoneArr[j] or 0
					addStoneArr[j] = addStoneArr[j] + 1
					tempIndex = tempIndex+addStoneArr[j]
					oneStoneData = StoneData.new({rowIndex = i, colIndex = j})
					print("new stone", i, j)
					oneStoneData:setRandomColorType()
					pos2X, pos2Y = self:getPosByRowColIndex(PlayDirector.SMaxRow+addStoneArr[j], j)
					self.stoneViews_[i][j] = app:createView("StoneView", oneStoneData)
						:addTo(self)
						:pos(pos2X, pos2Y)
				else
					print("update stone", i, j)
					oneStone:getStoneData():setRowColIndex(i, j)
					self.stoneViews_[i][j] = oneStone
					self.stoneViews_[i+tempIndex][j] = nil
				end

				self.stoneViews_[i][j]:runAction(cc.MoveTo:create(PlayDirector.DropTime, cc.p(pos1X, pos1Y)))

			end
		end
	end

end

-- 触摸回调
function PlayDirector:onTouch(event)
    -- event.name 是触摸事件的状态：began, moved, ended, cancelled
    -- event.x, event.y 是触摸点当前位置
    -- event.prevX, event.prevY 是触摸点之前的位置
    if event.x < display.left or event.x > display.right or event.y < display.bottom or event.y > display.top then
    -- 超出屏幕
	    self:resetAllStone()
    	return false
    end

    local stoneView = self:getStoneViewByPos(event.x, event.y)
    if stoneView == nil then
    	return false
    end

    -- local label = string.format("sprite: %s x,y: %0.2f, %0.2f", event.name, event.x, event.y)
    -- print(label)

    if event.name == "began" then
    	self:selectStoneView(stoneView)

    elseif event.name == "moved" then
    	self:selectStoneView(stoneView)

    elseif event.name == "cancelled" then
    	self:resetAllStone()

    else
    	if #self.selectStones_ > 2 then
    	-- 选中的stone超过三个，消除
    		self:clearStone()
    	else
    	-- 重置，所有stone恢复为normal
    		self:resetAllStone()
    	end

    end

    -- 返回 true 表示要响应该触摸事件，并继续接收该触摸事件的状态变化
    return true
end

-- 通过坐标获取Stone
function PlayDirector:getStoneViewByPos(posX, posY)
	local realSide = PlayDirector.SSide + PlayDirector.SSpace

	if posX < PlayDirector.SOriPosX + PlayDirector.SSpace * 0.5
		or posX > PlayDirector.SOriPosX + PlayDirector.SSpace * 0.5 + realSide * PlayDirector.SMaxCol then
		return nil
	end

	if posY < PlayDirector.SOriPosY + PlayDirector.SSpace * 0.5
		or posY > PlayDirector.SOriPosY + PlayDirector.SSpace * 0.5 + realSide * PlayDirector.SMaxRow then
		return nil
	end

	local rowIndex = (posY - PlayDirector.SOriPosY - PlayDirector.SSpace * 0.5) / realSide
	rowIndex = math.floor(rowIndex) + 1 

	local colIndex = (posX - PlayDirector.SOriPosX - PlayDirector.SSpace * 0.5) / realSide
	colIndex = math.floor(colIndex) + 1
	print("getStoneViewByPos", rowIndex, colIndex)
	return self.stoneViews_[rowIndex][colIndex]
end

-- 选中一个StoneView
function PlayDirector:selectStoneView(stoneView)
	if #self.selectStones_ == 0 then
	-- 如果当前还一个没有选中，需要将不同颜色stone设置为不可选，相同颜色stone不变
		table.insert(self.selectStones_, stoneView)
		stoneView:getStoneData():setSelect()
		for i=1,PlayDirector.SMaxRow do
			for j=1,PlayDirector.SMaxCol do
				local oneStone = self.stoneViews_[i][j]
				if oneStone:getStoneData():getColorType() ~= stoneView:getStoneData():getColorType() then
					oneStone:getStoneData():setDisable()
				end
			end
		end

	else
		if stoneView:getStoneData():getState() == "normal" then
		-- 颜色相同，可以选中的
			local lastStone = self.selectStones_[#self.selectStones_]
			local rowIndex, colIndex = lastStone:getStoneData():getRowColIndex()
			print("lastStone", rowIndex, colIndex, self:getIsRelate(lastStone, stoneView), #self.selectStones_)
			if self:getIsRelate(lastStone, stoneView) == true then
			-- 两个stone是相邻的
				table.insert(self.selectStones_, stoneView)
				stoneView:getStoneData():setSelect()
			end
		else
			if #self.selectStones_ > 1 and self.selectStones_[#self.selectStones_-1] == stoneView then
			-- 退回到倒数第二个选中的，那就取消最后一个选中的
				local lastStone = table.remove(self.selectStones_, #self.selectStones_)
				lastStone:getStoneData():setReady()
			end

		end

	end

end

-- 重置所有stone
function PlayDirector:resetAllStone()
	self.selectStones_ = {}

	for i=1,PlayDirector.SMaxRow do
		for j=1,PlayDirector.SMaxCol do
			local oneStone = self.stoneViews_[i][j]
			if oneStone and oneStone:getStoneData():getState() ~= "normal" then
				-- print("resetAllStone", i, j)
				oneStone:getStoneData():setReady()
			end
		end
	end

end

-- 判断两个stone是否相邻
function PlayDirector:getIsRelate(stone1, stone2)
	local rowIndex1, colIndex1 = stone1:getStoneData():getRowColIndex()
	local rowIndex2, colIndex2 = stone2:getStoneData():getRowColIndex()
	local temp1 = rowIndex1 - rowIndex2
	local temp2 = colIndex1 - colIndex2
	if temp1 >= -1 and temp1 <= 1 and temp2 >= -1 and temp2 <= 1 then
		return true
	else
		return false
	end

end

-- 消除选中的珠子
function PlayDirector:clearStone()
	local oneStone
	local rowIndex, colIndex
	local max = #self.selectStones_
	while max >= 1 do
		oneStone = self.selectStones_[1]
		local rowIndex, colIndex = oneStone:getStoneData():getRowColIndex()
		self.stoneViews_[rowIndex][colIndex] = nil
		table.remove(self.selectStones_, 1)
		oneStone:removeFromParent()
		oneStone = nil
        max = max - 1
	end

	self:resetAllStone()
	self:updateMatrix()
end

-- 获取矩阵的一个珠子的坐标
function PlayDirector:getPosByRowColIndex(rowIndex, colIndex)
	local posX = PlayDirector.SOriPosX + PlayDirector.SSpace * colIndex + PlayDirector.SSide * (colIndex - 0.5)
	local posY = PlayDirector.SOriPosY + PlayDirector.SSpace * rowIndex + PlayDirector.SSide * (rowIndex - 0.5)
	return posX, posY
end

return PlayDirector