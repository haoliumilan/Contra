--
-- Author: liuhao
-- Date: 2015-12-03 20:40:46
-- 

local StoneView = import("app.views.StoneView")

local PlayDirector = class("PlayDirector", function()
	return display.newNode()
end)

-- 常量
PlayDirector.SMaxRow = 7 -- 最大行数
PlayDirector.SMaxCol = 7 -- 最大列数
PlayDirector.SOriPosX = 15 -- 珠子矩阵最左坐标
PlayDirector.SOriPosY = 110 
PlayDirector.SSpace = 20 -- 珠子的间隔
PlayDirector.SSide = 80 -- 珠子的边长
PlayDirector.DropTime = 0.2 -- 珠子掉落一个格子用的时间

function PlayDirector:ctor()
	self.stoneViews_ = {} -- 7x7 stoneView
	self.selectStones_ = {} -- 选中的stoneView

	self:setStateMachine()

	-- touchLayer 用于接收触摸事件
	self.touchLayer = display.newLayer()
	self:addChild(self.touchLayer)

    -- 启用触摸
	self.touchLayer:setTouchEnabled(true)	
	-- 添加触摸事件处理函数
	self.touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch))

end

-- state machine
-- 设置状态机
function PlayDirector:setStateMachine()
	-- 因为PlayDirector在不同状态，所以这里为 PlayDirector 绑定了状态机组件
	cc(self):addComponent("components.behavior.StateMachine")
	-- 由于状态机仅供内部使用，所以不应该调用组件的 exportMethods() 方法，改为用内部属性保存状态机组件对象
	self.fsm__ = self:getComponent("components.behavior.StateMachine")

	-- 设定状态机的默认事件
	local defaultEvents = {
	    -- 初始化
	    {name = "start", from = "none", to = "normal" },
	    -- 选中stone
	    {name = "selectStone", from = "normal", to = "stoneSelect" },
	    -- 消除stone
	    {name = "clearStone", from = "stoneSelect", to = "stoneClear" },
	    -- 重置stone
	    {name = "resetStone", from = {"stoneSelect", "stoneClear", "skillUse", "skillSelect"}, to = "normal" },
	    -- 选中skill
	    {name = "selectSkill", from = "normal", to = "skillSelect" },	    
	    -- 确认技能
	    {name = "useSkill", from = "skillSelect", to = "skillUse" }	    	    
	}

	-- 设定状态机的默认回调
	local defaultCallbacks = {
	    onchangestate = handler(self, self.onChangeState_),
	    onstart = handler(self, self.onStart_),
	    onselectStone = handler(self, self.onSelectStone_),
	    onclearStone = handler(self, self.onClearStone_),
	    onresetStone = handler(self, self.onResetStone_),
	    onselectSkill = handler(self, self.onSelectSkill_),
	    onuseSkill = handler(self, self.onUseSkill_)
	}

	self.fsm__:setupState({
	    events = defaultEvents,
	    callbacks = defaultCallbacks
	})

	self.fsm__:doEvent("start")
end

function PlayDirector:onChangeState_(event)
	printf("PlayDirector state change from %s to %s", event.from, event.to)

end

function PlayDirector:onStart_(event)
	-- 初始化，随机7x7珠子
	local oneStone = nil
	for i=1,PlayDirector.SMaxRow do
		self.stoneViews_[i] = {}
		for j=1,PlayDirector.SMaxCol do
			local posX, posY = self:getPosByRowColIndex(i, j)
			self.stoneViews_[i][j] = app:createView("StoneView", {rowIndex = i, colIndex = j, stoneColor = self:getRandomStoneColor()})
				:addTo(self)
				:pos(posX, posY)
		end
	end
end

function PlayDirector:onSelectStone_(event)
	-- 选中一个StoneView, 相邻的相同颜色的stone自动选中，其他的变成不可选中状态
	local selectStone = event.args[1]
	self.selectStones_ = self:getCanLinkStones(selectStone)

	for i,v in ipairs(self.selectStones_) do
		v:setStoneState(enStoneState.Highlight)
	end

	local oneStone = nil
	for i=1,PlayDirector.SMaxRow do
		for j=1,PlayDirector.SMaxCol do
			oneStone = self.stoneViews_[i][j]
			if oneStone:getStoneState() == enStoneState.Normal then
				oneStone:setStoneState(enStoneState.Disable)
			end
		end
	end

end

function PlayDirector:onClearStone_(event)
	-- 消除选中的珠子
	local oneStone
	local rowIndex, colIndex
	for i,v in ipairs(self.selectStones_) do
		rowIndex, colIndex = v:getRowColIndex()
		self.stoneViews_[rowIndex][colIndex] = nil
		v:removeFromParent()
	end

	self.fsm__:doEvent("resetStone", true)
end

function PlayDirector:onResetStone_(event)
	-- 重置所有stone
	self.selectStones_ = {}

	for i=1,PlayDirector.SMaxRow do
		for j=1,PlayDirector.SMaxCol do
			local oneStone = self.stoneViews_[i][j]
			if oneStone and oneStone:getStoneState() ~= enStoneState.Normal then
				oneStone:setStoneState(enStoneState.Normal)
			end
		end
	end

	-- 如果消除了，就要更新Matrix
	if event.args[1] then
		self:updateMatrix()
	end
end

function PlayDirector:onSelectSkill_(event)

end

function PlayDirector:onUseSkill_(event)

end

-- 消除后，更新7x7矩阵
function PlayDirector:updateMatrix()
	local pos1X, pos1Y, pos2X, pos2Y
	local oneStone
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

					pos2X, pos2Y = self:getPosByRowColIndex(PlayDirector.SMaxRow+addStoneArr[j], j)
					
					self.stoneViews_[i][j] = app:createView("StoneView", {rowIndex = i, colIndex = j, stoneColor = self:getRandomStoneColor()})
						:addTo(self)
						:pos(pos2X, pos2Y)
				else
					oneStone:setRowColIndex(i, j)
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
    -- local label = string.format("PlayDirector: %s x,y: %0.2f, %0.2f", event.name, event.x, event.y)
    -- print(label)

    local oneStone = self:getStoneByPos(event.x, event.y)
    if oneStone then
    	local state = self.fsm__:getState()
    	if state == "normal" then
    		self.fsm__:doEvent("selectStone", oneStone)

    	elseif state == "stoneSelect" then
    		if #self.selectStones_ > 2 then
	    		-- 消除
	    		self.fsm__:doEvent("clearStone")
	    	else
	    		-- 取消选中
	    		self.fsm__:doEvent("resetStone")
	    	end
    	else
    		-- 取消选中
	    	self.fsm__:doEvent("resetStone")

    	end
    end

    -- 返回 true 表示要响应该触摸事件，并继续接收该触摸事件的状态变化
    return false
end

-- 通过坐标获取Stone
function PlayDirector:getStoneByPos(posX, posY)
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

-- 判断两个stone是否相邻
function PlayDirector:getIsRelate(stone1, stone2)
	local rowIndex1, colIndex1 = stone1:getRowColIndex()
	local rowIndex2, colIndex2 = stone2:getRowColIndex()
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
	local rowIndex, colIndex = centerStone:getRowColIndex()
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
function PlayDirector:getCanLinkStones(startStone)
	local canLinkStones = {}
	canLinkStones[startStone] = true

	local function findCanLinkStone(oneStone)
		local relateStones = self:getRelateStones(oneStone)
		for i,v in ipairs(relateStones) do
			if v:getColorType() == oneStone:getColorType()
				and canLinkStones[v] ~= true then
				canLinkStones[v] = true
				findCanLinkStone(v)
			end
		end
	end

	findCanLinkStone(startStone)

	return table.keys(canLinkStones)
end

-- 获取矩阵的一个珠子的坐标
function PlayDirector:getPosByRowColIndex(rowIndex, colIndex)
	local posX = PlayDirector.SOriPosX + PlayDirector.SSpace * colIndex + PlayDirector.SSide * (colIndex - 0.5)
	local posY = PlayDirector.SOriPosY + PlayDirector.SSpace * rowIndex + PlayDirector.SSide * (rowIndex - 0.5)
	return posX, posY
end

-- 获得一个随机颜色
function PlayDirector:getRandomStoneColor()
	return math.random(enStoneColor.Red, enStoneColor.Purple)
end


return PlayDirector