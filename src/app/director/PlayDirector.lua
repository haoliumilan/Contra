--
-- Author: liuhao
-- Date: 2015-12-03 20:40:46
-- 

local StoneView = import("..views.StoneView")
local SkillView = import("..views.SkillView")
local SkillData = import("..data.SkillData")

local PlayDirector = class("PlayDirector", function()
	return display.newNode()
end)

-- 常量
PlayDirector.SMaxRow = 7 -- 最大行数
PlayDirector.SMaxCol = 7 -- 最大列数
PlayDirector.SOriPosX = 34 -- 珠子矩阵最左坐标
PlayDirector.SOriPosY = 40 
PlayDirector.SSpace = 6 -- 珠子的间隔
PlayDirector.SSide = 90 -- 珠子的边长
PlayDirector.TimeDrop = 0.1 -- 珠子掉落一个格子用的时间
PlayDirector.SkOriPosX = 0 -- 技能最左坐标
PlayDirector.SkOriPosY = 850 
PlayDirector.SkSpace = 25 -- 技能之间的间距
PlayDirector.SkSide = 120 -- 技能的边长

function PlayDirector:ctor()
	self.stoneViews_ = {} -- 7x7 stoneView
	self.selectStones_ = {} -- 选中的stoneView
	self.skillDatas_ = {} 	-- 技能
	self.skillViews_ = {} -- skillView
	self.selectSkill_ = nil -- 选中的技能
	self.curSkillStone_ = nil -- 使用技能时，当前技能选中的stone
	self.skillEffectStones_ = {} -- 技能消除的stone

	self:setStateMachine()

	-- touchLayer 用于接收触摸事件
	self.touchLayer = display.newLayer()
	self:addChild(self.touchLayer)

    -- 启用触摸
	self.touchLayer:setTouchEnabled(true)	
	-- 添加触摸事件处理函数
	self.touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch))

	self:initSkill()

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
	    {name = "selectSkill", from = {"normal", "skillSelect", "skillUse"}, to = "skillSelect" },
	    -- 重置技能
	    {name = "resetSkill", from = {"skillSelect", "skillUse"}, to = "normal" },    	    	    
	    -- 确认技能
	    {name = "useSkill", from = {"skillSelect", "skillUse"}, to = "skillUse" },    	    
	}

	-- 设定状态机的默认回调
	local defaultCallbacks = {
	    onchangestate = handler(self, self.onChangeState_),
	    onstart = handler(self, self.onStart_),
	    onselectStone = handler(self, self.onSelectStone_),
	    onclearStone = handler(self, self.onClearStone_),
	    onresetStone = handler(self, self.onResetStone_),
	    onselectSkill = handler(self, self.onSelectSkill_),
	    onuseSkill = handler(self, self.onUseSkill_),
	    onresetSkill = handler(self, self.onResetSkill_)
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
	local posX, posY
	local oneStoneType
	for i=1,PlayDirector.SMaxRow do
		self.stoneViews_[i] = {}
		for j=1,PlayDirector.SMaxCol do
			posX, posY = self:getPosByRowColIndex(i, j)
			if i == 4 and (j == 1 or j == 3 or j == 5 or j == 7) then
				oneStoneType = enStoneType.Iron
			elseif i <= 3 then
				oneStoneType = enStoneType.Yellow
			else
				oneStoneType = self:getRandomStoneColor()
			end
			self.stoneViews_[i][j] = app:createView("StoneView", {rowIndex = i, colIndex = j, stoneType = oneStoneType})
				:addTo(self)
				:pos(posX, posY)
		end
	end
end

function PlayDirector:onSelectStone_(event)
	-- 选中一个StoneView, 相邻的相同颜色的stone自动选中，其他的变成不可选中状态
	local selectStone = event.args[1]
	self.skillViews_[selectStone:getColorType()]:showSkillCount(true)

	self.selectStones_ = self:getCanLinkStones(selectStone)
	self.skillEffectStones_ = {}

	for i,v in ipairs(self.selectStones_) do
		v:setStoneState(enStoneState.Highlight)
		if v:getSkillData() ~= nil then
			self:showSkillEffect(v)
		end
	end

	local oneStone = nil
	for i=1,PlayDirector.SMaxRow do
		for j=1,PlayDirector.SMaxCol do
			oneStone = self.stoneViews_[i][j]
			if oneStone and oneStone:getStoneState() == enStoneState.Normal then
				oneStone:setStoneState(enStoneState.Disable)
			end
		end
	end

end

function PlayDirector:onClearStone_(event)
	local clearColors = {} -- 每种颜色消除的数量
	for i=1,5 do
		clearColors[i] = 0
	end

	-- 消除选中的珠子
	local oneStone
	local rowIndex, colIndex
	for i,v in ipairs(self.selectStones_) do
		clearColors[v:getColorType()] = clearColors[v:getColorType()] + 1
		rowIndex, colIndex = v:getRowColIndex()
		if v:getIsSkillEffect() == true then
			table.removebyvalue(self.skillEffectStones_, v)
		end

		self.stoneViews_[rowIndex][colIndex] = nil
		v:removeFromParent()
		v = nil
	end

	-- 消除技能消除的珠子
	for i,v in ipairs(self.skillEffectStones_) do
		if v then
			clearColors[v:getColorType()] = clearColors[v:getColorType()] + 1
			rowIndex, colIndex = v:getRowColIndex()
			self.stoneViews_[rowIndex][colIndex] = nil
			v:removeFromParent()
			v = nil
		end
	end

	for i=1,5 do
		self.skillDatas_[i]:addCurCount(clearColors[i])
	end

	self.fsm__:doEvent("resetStone", true)
end

function PlayDirector:onResetStone_(event)
	-- 重置所有stone
	self.selectStones_ = {}
	self.skillEffectStones_ = {}

	for i=1,PlayDirector.SMaxRow do
		for j=1,PlayDirector.SMaxCol do
			local oneStone = self.stoneViews_[i][j]
			if oneStone then
				oneStone:setStoneState(enStoneState.Normal, true)
			end
		end
	end

	for i=1,5 do
		self.skillViews_[i]:showSkillCount(false)
	end

	-- 如果消除了，就要更新Matrix
	if event.args[1] then
		self:updateMatrix()
	end
end

function PlayDirector:onSelectSkill_(event)
	if self.selectSkill_ then
		self.skillViews_[self.selectSkill_:getColorType()]:setSkillState(enSkillState.CanUse)
	end

	self.selectSkill_ = event.args[1]
	self.skillViews_[self.selectSkill_:getColorType()]:setSkillState(enSkillState.Using)

	for i=1,PlayDirector.SMaxRow do
		for j=1,PlayDirector.SMaxCol do
			local oneStone = self.stoneViews_[i][j]
			if oneStone then
				if oneStone:getColorType() ~= self.selectSkill_:getColorType() then
					oneStone:setStoneState(enStoneState.Disable, true)
				else
					oneStone:setStoneState(enStoneState.Highlight, true)
				end
			end
		end
	end

end

function PlayDirector:onResetSkill_(event)
	if event.args[1] ~= true and self.curSkillStone_ then
		self.curSkillStone_:setSkillData(nil)
	end
	self.curSkillStone_ = nil
	self.skillEffectStones_ = {}

	if self.selectSkill_ and self.skillViews_[self.selectSkill_:getColorType()]:getSkillState() == enSkillState.Using then
		self.skillViews_[self.selectSkill_:getColorType()]:setSkillState(enSkillState.CanUse)
	end
	self.selectSkill_ = nil

	for i=1,PlayDirector.SMaxRow do
		for j=1,PlayDirector.SMaxCol do
			local oneStone = self.stoneViews_[i][j]
			if oneStone and oneStone:getStoneState() ~= enStoneState.Normal then
				oneStone:setStoneState(enStoneState.Normal, true)
			end
		end
	end
end

function PlayDirector:onUseSkill_(event)
	if self.curSkillStone_ then
		self.curSkillStone_:setSkillData(nil)
	end

	for i=1,PlayDirector.SMaxRow do
		for j=1,PlayDirector.SMaxCol do
			local oneStone = self.stoneViews_[i][j]
			if oneStone then
				oneStone:setSkillEffect(false)
			end
		end
	end

	local selectStone = event.args[1]
	selectStone:setSkillData(self.selectSkill_)
	self.curSkillStone_ = selectStone
	self.skillEffectStones_ = {}
	self:showSkillEffect(selectStone)

end

-- 技能按钮
function PlayDirector:initSkill()
	local posX
	for i=1,5 do
		self.skillDatas_[i] = SkillData.new(i)
		posX = PlayDirector.SkOriPosX + PlayDirector.SkSpace * i + PlayDirector.SkSide * (i - 0.5)
		self.skillViews_[i] = app:createView("SkillView", {skillData = self.skillDatas_[i]})
			:addTo(self)
			:pos(posX, PlayDirector.SkOriPosY)
	end
end

-- 消除后，更新7x7矩阵, 有不会移动的珠子
function PlayDirector:updateMatrix2()
	local threeX = {0, 1, -1}

	local function getRunActionStone(index, rowIndex, colIndex)
		local newRowIndex = rowIndex + 1
		local newColIndex = colIndex + threeX[index]
		if self:getIsInMatrix(newRowIndex, newColIndex) == false then
			return nil
		end

		local oneStone = self.stoneViews_[newRowIndex][newColIndex]
		if oneStone == nil or oneStone:getIsCanSelected() == false then
			return nil
		end

		-- 正上方相邻的、可以移动的stone可以掉落
		if index == 1 then 
			return oneStone
		end

		-- 正上方相邻的是不可以移动的，斜上方相邻的、可以移动的stone可以掉落
		if self.stoneViews_[newRowIndex][colIndex] and self.stoneViews_[newRowIndex][colIndex]:getIsCanSelected() == false then
			return oneStone
		end

		-- 正上方相邻的是空的，斜上方相邻的、可以移动的，同时这个斜上方的stone的正下方不能是空的，可以掉落
		if oneStone:getIsVertical() == false and self.stoneViews_[rowIndex][newColIndex] then
			return oneStone
		end

		return nil
	end

	local pos1X, pos1Y, pos2X, pos2Y
	local oneStone
	local isRunAction = false
	for i=1,PlayDirector.SMaxRow do
		for j=1,PlayDirector.SMaxCol do
			oneStone = self.stoneViews_[i][j]
			pos1X, pos1Y = self:getPosByRowColIndex(i, j)
			if oneStone == nil then
			-- 去找它上面的，离他最近的那个stone, 如果碰到不能移动的珠子，那么就从两边移动
				if i < PlayDirector.SMaxRow then
					for k,v in ipairs(threeX) do
						oneStone = getRunActionStone(k, i, j)
						if oneStone then
							oneStone:setRowColIndex(i, j)
							self.stoneViews_[i][j] = oneStone
							self.stoneViews_[i+1][j+v] = nil
							self.stoneViews_[i][j]:stop()
							self.stoneViews_[i][j]:moveTo(PlayDirector.TimeDrop, pos1X, pos1Y)
							isRunAction = true

							if self:getIsInMatrix(i-1, j) == true and self.stoneViews_[i-1][j] then
								oneStone:setIsVertical(false)
							end

							break
						end
					end
				else
					-- 最上面一行了，创建新的吧
					pos2X, pos2Y = self:getPosByRowColIndex(i+1, j)					
					oneStone = app:createView("StoneView", {rowIndex = i, colIndex = j, stoneType = self:getRandomStoneColor()})
						:addTo(self)
						:pos(pos2X, pos2Y)					
					self.stoneViews_[i][j] = oneStone
					self.stoneViews_[i][j]:stop()
					self.stoneViews_[i][j]:moveTo(PlayDirector.TimeDrop, pos1X, pos1Y)
					isRunAction = true

				end
			else

			end
		end
	end

	if isRunAction == true then
		self:performWithDelay(function()
			self:updateMatrix2()
			end, PlayDirector.TimeDrop)
	end
end

-- 消除后，更新7x7矩阵
function PlayDirector:updateMatrix()
	local pos1X, pos1Y, pos2X, pos2Y
	local oneStone
	local tempIndex
	local addStoneArr = {} -- 用来记录每一列新创建的珠子
	local threeX = {0, 1, -1}
	local isFixed = false -- 是否有固定的

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
					
					self.stoneViews_[i][j] = app:createView("StoneView", {rowIndex = i, colIndex = j, stoneType = self:getRandomStoneColor()})
						:addTo(self)
						:pos(pos2X, pos2Y)
					oneStone = self.stoneViews_[i][j]
				elseif oneStone:getIsCanSelected() == true then
					oneStone:setRowColIndex(i, j)
					self.stoneViews_[i][j] = oneStone
					self.stoneViews_[i+tempIndex][j] = nil
				else
					isFixed = true
				end

				if oneStone and oneStone:getIsCanSelected() == true then
					oneStone:runAction(cc.MoveTo:create(PlayDirector.TimeDrop, cc.p(pos1X, pos1Y)))
				end
			end
		end
	end
	if isFixed == true then
		self:performWithDelay(function()
			self:updateMatrix2()
		end, PlayDirector.TimeDrop)
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
    local oneSkill = self:getSkillByPos(event.x, event.y)
    local state = self.fsm__:getState()
    if oneStone then
    	-- 选中了stone
    	local stoneState = oneStone:getStoneState()
    	if state == "normal" then
    		if oneStone:getIsCanSelected() == true then
	    		self.fsm__:doEvent("selectStone", oneStone)
	    	end
    	elseif state == "stoneSelect" then
    		if oneStone:getStoneState() == enStoneState.Highlight and #self.selectStones_ > 2 then
	    		-- 消除
	    		self.fsm__:doEvent("clearStone")
	    	else
	    		-- 取消选中
	    		self.fsm__:doEvent("resetStone")
	    	end
	    elseif state == "skillSelect" then
	    	-- 使用技能
	    	if stoneState == enStoneState.Highlight then
	    		self.fsm__:doEvent("useSkill", oneStone)
	    	else
	    		self.fsm__:doEvent("resetSkill", false)
	    	end
	    elseif state == "skillUse" then
		   	-- 已经显示技能效果了
		   	if stoneState == enStoneState.Highlight then
		   		if oneStone:getSkillData() ~= nil then
		   			self.selectSkill_:setCurCount(0)
		   			self.fsm__:doEvent("resetSkill", true)
		   		else
		   			self.fsm__:doEvent("useSkill", oneStone)
		   		end
		   	else
		   		self.fsm__:doEvent("resetSkill", false)
		   	end

    	else
    		-- 取消选中
	    	self.fsm__:doEvent("resetStone")

    	end

    elseif oneSkill then
    	-- 选中了skill
    	if state == "normal" or state == "skillSelect" or state == "skillUse" then
    		if oneSkill ~= self.selectSkill_ and oneSkill:getCurCount() >= oneSkill:getNeedCount() then
	    		self.fsm__:doEvent("selectSkill", oneSkill)
	    	else
	    		self.skillViews_[oneSkill:getColorType()]:showSkillCount(true, true)
	    	end
    	else
    		-- 取消选中
	    	self.fsm__:doEvent("resetStone")

    	end
    end

    -- 返回 true 表示要响应该触摸事件，并继续接收该触摸事件的状态变化
    return false
end

-- 显示技能效果
function PlayDirector:showSkillEffect(oneStone)
	oneStone:setSkillEffect(true)
	table.insert(self.skillEffectStones_, oneStone)

	local function showOneDirectionEffect(directionValue, rowIndex, colIndex, effect)
		local newRowIndex, newColIndex
		for j=1,effect do
			newRowIndex = rowIndex + directionValue[2]*j
			newColIndex = colIndex + directionValue[1]*j
			if self:getIsInMatrix(newRowIndex, newColIndex) == true then
				local effectStone = self.stoneViews_[newRowIndex][newColIndex]
				if table.indexof(self.skillEffectStones_, effectStone) == false then
					if effectStone:getSkillData() ~= nil then
					-- 技能触发技能
						self:showSkillEffect(effectStone)
					else
						effectStone:setSkillEffect(true)
						table.insert(self.skillEffectStones_, effectStone)
					end
				end
			end
		end

	end

	local rowIndex, colIndex = oneStone:getRowColIndex()
	local skillData = oneStone:getSkillData()
	local direction = skillData:getDirection()
	local effect = skillData:getEffect()
	local directionValue
	for i,v in ipairs(direction) do
		directionValue = DirectionValueArr[v]
		showOneDirectionEffect(directionValue, rowIndex, colIndex, effect)
	end

	return stoneArr
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

-- 通过坐标获取Skill
function PlayDirector:getSkillByPos(posX, posY)
	local realSide = PlayDirector.SkSide + PlayDirector.SkSpace

	if posX < PlayDirector.SkOriPosX + PlayDirector.SkSpace * 0.5
		or posX > PlayDirector.SkOriPosX + PlayDirector.SkSpace * 0.5 + realSide * 5 then
		return nil
	end

	if posY < PlayDirector.SkOriPosY - PlayDirector.SkSide * 0.5
		or posY > PlayDirector.SkOriPosY + PlayDirector.SkSide * 0.5 then
		return nil
	end

	local index = (posX - PlayDirector.SkOriPosX - PlayDirector.SkSpace * 0.5) / realSide
	index = math.floor(index) + 1

	return self.skillDatas_[index]
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

-- 判断一组坐标是否在matrix中
function PlayDirector:getIsInMatrix(rowIndex, colIndex)
	if rowIndex >= 1 and rowIndex <= PlayDirector.SMaxRow and colIndex >= 1 and colIndex <= PlayDirector.SMaxCol then
		return true
	else
		return false
	end
end

-- 获得一个stone所有相邻的stone
function PlayDirector:getRelateStones(centerStone)
	local relateStones = {}
	local rowIndex, colIndex = centerStone:getRowColIndex()
	for i=1,#DirectionValueArr do
		local newRowIndex = rowIndex + DirectionValueArr[i][2]
		local newColIndex = colIndex + DirectionValueArr[i][1]
		if self:getIsInMatrix(newRowIndex, newColIndex) == true then
			table.insert(relateStones, self.stoneViews_[newRowIndex][newColIndex])
		end
	end

	return relateStones
end

-- 获取一个stone可以连接的所有stone,
function PlayDirector:getCanLinkStones(startStone)
	local canLinkStones = {}
	canLinkStones[startStone] = true

	local function findCanLinkStone(oneStone)
		local rowIndex, colIndex = oneStone:getRowColIndex()
		for i=1,#DirectionValueArr do
			local newRowIndex = rowIndex + DirectionValueArr[i][2]
			local newColIndex = colIndex + DirectionValueArr[i][1]
			if self:getIsInMatrix(newRowIndex, newColIndex) == true then
				local relateStone = self.stoneViews_[newRowIndex][newColIndex]
			 	if relateStone and relateStone:getColorType() == oneStone:getColorType() and canLinkStones[relateStone] ~= true then
					canLinkStones[relateStone] = true
					findCanLinkStone(relateStone)
				end
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
	return math.random(enStoneType.Red, enStoneType.Purple)
end


return PlayDirector
