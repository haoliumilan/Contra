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
	self.canLinkStones_ = {} -- 可以连接的stoneView

	-- touchLayer 用于接收触摸事件
	self.touchLayer = display.newLayer()
	self:addChild(self.touchLayer)

    -- 启用触摸
	self.touchLayer:setTouchEnabled(true)	
	-- 添加触摸事件处理函数
	self.touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch))

	self:initMatrix()

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
					oneStoneData:setRandomColorType()
					pos2X, pos2Y = self:getPosByRowColIndex(PlayDirector.SMaxRow+addStoneArr[j], j)
					self.stoneViews_[i][j] = app:createView("StoneView", oneStoneData)
						:addTo(self)
						:pos(pos2X, pos2Y)
				else
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
    local label = string.format("PlayDirector: %s x,y: %0.2f, %0.2f", event.name, event.x, event.y)
    print(label)

    local stoneView = self:getStoneViewByPos(event.x, event.y)

    if event.name == "began" then
    	if stoneView then
	    	self:selectStoneView(stoneView)
	    else
	    	return false
	    end

    elseif event.name == "moved" then
    	if stoneView then
	    	self:selectStoneView(stoneView)
	    end
	    
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

	return self.stoneViews_[rowIndex][colIndex]
end

-- 选中一个StoneView
function PlayDirector:selectStoneView(stoneView)
	if #self.selectStones_ == 0 then
	-- 如果当前还一个没有选中，需要将不同颜色stone设置为不可选，相同颜色stone不变
		table.insert(self.selectStones_, stoneView)
		stoneView:getStoneData():setSelect()
		self:checkCanLinkStones(stoneView)

		for i=1,PlayDirector.SMaxRow do
			for j=1,PlayDirector.SMaxCol do
				local oneStone = self.stoneViews_[i][j]
				if oneStone:getStoneData():getColorType() ~= stoneView:getStoneData():getColorType() then
					oneStone:getStoneData():setDisable()
				else
					if table.indexof(self.canLinkStones_, oneStone) == false then
						oneStone:getStoneData():setDisable()
					end
				end
			end
		end

	else
		if stoneView:getStoneData():getState() == "normal" then
		-- 颜色相同，可以选中的
			local lastStone = self.selectStones_[#self.selectStones_]
			local rowIndex, colIndex = lastStone:getStoneData():getRowColIndex()
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
	self.canLinkStones_ = {}

	for i=1,PlayDirector.SMaxRow do
		for j=1,PlayDirector.SMaxCol do
			local oneStone = self.stoneViews_[i][j]
			if oneStone and oneStone:getStoneData():getState() ~= "normal" then
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

-- 获得一个stone所有相邻的stone
function PlayDirector:getRelateStones(centerStone)
	local relateStones = {}
	local rowIndex, colIndex = centerStone:getStoneData():getRowColIndex()
	local xValues = {-1, 0, 1, -1, 1, -1, 0, 1}
	local yValues = {1, 1, 1, 0, 0, -1, -1, -1}
	for i=1,8 do
		local xIndex = colIndex + xValues[i]
		local yIndex = rowIndex + yValues[i]
		if xIndex >= 1 and xIndex <= PlayDirector.SMaxCol and yIndex >= 1 and yIndex <= PlayDirector.SMaxRow then
			table.insert(relateStones, self.stoneViews_[yIndex][xIndex])
		end
	end

	return relateStones
end

-- 获取一个stone可以连接的所有stone,
function PlayDirector:checkCanLinkStones(startStone)
	local canLinkStones = {}
	canLinkStones[startStone] = true

	local function findCanLinkStone(oneStone)
		local relateStones = self:getRelateStones(oneStone)
		for i,v in ipairs(relateStones) do
			if v:getStoneData():getColorType() == oneStone:getStoneData():getColorType()
				and canLinkStones[v] ~= true then
				canLinkStones[v] = true
				findCanLinkStone(v)
			end
		end
	end

	findCanLinkStone(startStone)

	self.canLinkStones_ = table.keys(canLinkStones)
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