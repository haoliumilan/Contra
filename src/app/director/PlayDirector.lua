--
-- Author: Liu Hao
-- Date: 2015-12-03 20:40:46
-- 

local StoneView = import("..views.StoneView")
local SkillData = import("..data.SkillData")
local TipsView = import("..views.TipsView")
local SkillCfg = import("..config.SkillCfg")

local PlayDirector = class("PlayDirector", function()
	return display.newNode()
end)

-- 常量
PlayDirector.SMaxRow = 9 -- 最大行数
PlayDirector.SMaxCol = 9 -- 最大列数
PlayDirector.SOriPosX = 21 -- 珠子矩阵最左坐标
PlayDirector.SOriPosY = 28 
PlayDirector.SSpace = 6 -- 珠子的间隔
PlayDirector.SSide = 72 -- 珠子的边长

PlayDirector.TimeDrop = 0.1 -- 珠子掉落一个格子用的时间
PlayDirector.TimeUpdatePos = 0.2 -- stone刷新位置的时间
PlayDirector.TimeSkillDrop = 0.5 -- 技能出来的时间
PlayDirector.TimeComposeSkill = 0.2 -- 技能合成的时间

-- 定义事件
PlayDirector.CHANGE_STEP_EVENT = "CHANGE_STEP_EVENT"
PlayDirector.CLEAR_STONE_EVENT = "CLEAR_STONE_EVENT"
PlayDirector.LEVEL_SUCCESS_EVENT = "LEVEL_SUCCESS_EVENT"
PlayDirector.LEVEL_FAIL_EVENT = "LEVEL_FAIL_EVENT"
PlayDirector.TIPS_EVENT = "TIPS_EVENT"

function PlayDirector:ctor(levelData)
	self.levelData_ = levelData

	self.stoneViews_ = {} -- stoneView 7x7 
	self.coverViews_ = {} -- stone上面的盖子 7x7

	self.skillDatas_ = {} 	-- 技能
	self.newSkills_ = {} -- 每次消除新产生的技能
	self.finalNewSkill_ = nil -- 新产生的技能中，最后一个，用于判断时间节点

	self.selectStones_ = {} -- 选中的stoneView
	self.selectSkill_ = nil -- 选中的技能
	self.curSkillStone_ = nil -- 使用技能时，当前技能选中的stone
	self.curEffectStones_ = {} -- 当前技能波及的stone
	
	if BEIBEI_TEST then
		self.leftStep_ = 0
	else
		self.leftStep_ = self.levelData_.step -- 剩余回合数
	end

	self.stepCount_ = 0 -- 使用的回合数
	self.clearStones_ = {} -- 消除的各种stone的数量, 用于统计
	self.usedSkills_ = {} -- 使用的技能数量，用于统计

	self.coverLayer_ = display.newColorLayer(cc.c4b(0, 0, 0, 200))
		:addTo(self, 1)
		:pos(21, 28)
		:size(display.width-50, display.width-50)
	self.coverLayer_:setVisible(false)
	self.coverLayer_:setTouchSwallowEnabled(false)

	-- 掉落stone类型容器
	self.dropStoneArr_ = {}
	for i,v in ipairs(self.levelData_.drop) do
		for j=1,v do
			table.insert(self.dropStoneArr_, i)
		end
	end

	-- touchLayer 用于接收触摸事件
	self.touchLayer_ = display.newLayer()
	self:addChild(self.touchLayer_)

	--  回调
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods() 

    -- 启用触摸
	self.touchLayer_:setTouchEnabled(false)	
	-- 添加触摸事件处理函数
	self.touchLayer_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch_))

	self:setStateMachine_()

	self:initSkill_()

end

-- property

function PlayDirector:getStepCount()
	return self.leftStep_
end

function PlayDirector:getClearStones()
	return self.clearStones_
end

-- state machine
-- 设置状态机
function PlayDirector:setStateMachine_()
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
	    {name = "clearStone", from = {"stoneSelect"}, to = "stoneClear" },
	    -- 重置stone
	    {name = "resetStone", from = {"stoneSelect", "stoneClear"}, to = "normal" },
	}

	-- 设定状态机的默认回调
	local defaultCallbacks = {
	    onchangestate = handler(self, self.onChangeState_),
	    onstart = handler(self, self.onStart_),
	    onselectStone = handler(self, self.onSelectStone_),
	    onclearStone = handler(self, self.onClearStone_),
	    onresetStone = handler(self, self.onResetStone_),
	}

	self.fsm__:setupState({
	    events = defaultEvents,
	    callbacks = defaultCallbacks
	})

	self:performWithDelay(function()
		self.fsm__:doEvent("start")
	end, 0.1)
end

function PlayDirector:onChangeState_(event)
	-- printf("PlayDirector state change from %s to %s", event.from, event.to)

end

function PlayDirector:onStart_(event)
	self:dispatchEvent({name = PlayDirector.TIPS_EVENT, tips = TipsView.TxtStart})

	-- 初始化，随机7x7珠子
	local posX, posY
	local stoneType
	local coverType
	local oneSkillId 
	local stoneCfg = self.levelData_.stone or {}
	for i=1,PlayDirector.SMaxRow do
		self.stoneViews_[i] = {}
		self.coverViews_[i] = {}
		stoneCfg[i] = stoneCfg[i] or {}
		for j=1,PlayDirector.SMaxCol do
			if stoneCfg[i][j] then
				stoneType = stoneCfg[i][j]
				coverType = 0
				oneSkillId = nil
				if type(stoneCfg[i][j]) == "table" then
					stoneType = stoneCfg[i][j].s or 0
					coverType = stoneCfg[i][j].c or 0
					if stoneCfg[i][j].sk and stoneCfg[i][j].sk > 0 then
						oneSkillId = stoneCfg[i][j].sk
					end
				end

				if coverType > 0 then
					posX, posY = self:getStonePosByIndex_(i, j)
					self.coverViews_[i][j] = app:createView("StoneView", {rowIndex = i, colIndex = j, stoneType = coverType})
						:addTo(self, 2)
						:pos(posX, posY)
				end

				if stoneType > 0 then
					posX, posY = self:getStonePosByIndex_(i, j)
					self.stoneViews_[i][j] = app:createView("StoneView", {rowIndex = i, colIndex = j, stoneType = stoneType,
						skillId = oneSkillId})
						:addTo(self)
						:pos(posX, posY)
				end
			end
		end
	end

	self:updateMatrix_()
end

function PlayDirector:onSelectStone_(event)
	-- 选中一个StoneView, 相邻的相同颜色的stone自动选中，其他的变成不可选中状态
	local selectStone = event.args[1]
	self.coverLayer_:setVisible(true)

	self.selectStones_ = self:getCanLinkStones_(selectStone)

	for i,v in ipairs(self.selectStones_) do
		self:reorderChild(v, 1)
		v:setStoneState(enStoneState.Highlight)
		if v:getSkillData() ~= nil then
			self:showSkillEffect_(v)
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
	self.touchLayer_:setTouchEnabled(false)	

	event.args[1] = event.args[1] or {}
	local isClearSkill = false

	local clearColors = {} -- 每种颜色消除的数量
	local splashStones = {} -- 被溅射到的stone
	local splashCovers = {} -- 被溅射到的cover
	for i=1,enStoneType.Max-1 do
		clearColors[i] = 0
	end

	-- 寻找溅射的
	local function findSplashStone(centerStone)
		local rowIndex, colIndex = centerStone:getRowColIndex()
		for i=1,#Direction4ValueArr do
			-- 溅射到的墙
			local newRowIndex = rowIndex + math.max(0, Direction4ValueArr[i][2])
			local newColIndex = colIndex + math.max(0, Direction4ValueArr[i][1])

			newRowIndex = rowIndex + Direction4ValueArr[i][2]
			newColIndex = colIndex + Direction4ValueArr[i][1]
			if self:getIsInMatrix_(newRowIndex, newColIndex) == true then
				local splashCover = self.coverViews_[newRowIndex][newColIndex]
				if splashCover then
					if splashCover:getIsSkillEffect() == false and splashCover:getIsSplash() == true then
						splashCovers[splashCover] = true
					end
				else
					local splashStone = self.stoneViews_[newRowIndex][newColIndex]
				 	if splashStone and splashStone:getIsSkillEffect() == false and splashStone:getIsSplash() == true then
				 		splashStones[splashStone] = true
					end
				end
			end
		end
	end

	-- 消除选中的
	local oneStone = nil
	for i=1,PlayDirector.SMaxRow do
		for j=1,PlayDirector.SMaxCol do
			oneStone = self.stoneViews_[i][j]
			if oneStone and oneStone:getStoneState() == enStoneState.Highlight 
				and oneStone:getIsSkillEffect() == false then
				findSplashStone(oneStone)
				
				if oneStone:getSkillData() then
					local skillId = oneStone:getSkillData().id
					self.usedSkills_[skillId] = self.usedSkills_[skillId] or 0
  					self.usedSkills_[skillId] = self.usedSkills_[skillId] + 1
  					isClearSkill = true
				end

				clearColors[oneStone:getStoneType()] = clearColors[oneStone:getStoneType()] + 1
				self:clearOne_(oneStone)
			end

		end
	end

	-- 技能波及的
	for i,v in ipairs(self.curEffectStones_) do
		if v:getSkillData() then
			local skillId = v:getSkillData().id
			self.usedSkills_[skillId] = self.usedSkills_[skillId] or 0
				self.usedSkills_[skillId] = self.usedSkills_[skillId] + 1
				isClearSkill = true
		end

		clearColors[v:getStoneType()] = clearColors[v:getStoneType()] + 1
		self:clearOne_(v)						
	end

	-- -- 消除溅射到的stone
	-- local splashArr = table.keys(splashStones)
	-- for i,v in ipairs(splashArr) do
	-- 	if v:splash() == true then
	-- 		clearColors[v:getStoneType()] = clearColors[v:getStoneType()] + 1
	-- 		self:clearOne_(v)
	-- 	end
	-- end

	-- -- 消除溅射到的cover
	-- splashArr = table.keys(splashCovers)
	-- for i,v in ipairs(splashArr) do
	-- 	if v:splash() == true then
	-- 		clearColors[v:getStoneType()] = clearColors[v:getStoneType()] + 1
	-- 		self:clearOne_(v)
	-- 	end
	-- end

	-- 消除产生技能
	self.newSkills_ = {}
	for i=1,5 do
		self.newSkills_[i] = math.min(math.floor(clearColors[i]/self.skillDatas_[i].need), 3) 
	end

	for i=1,enStoneType.Max-1 do
		self.clearStones_[i] = self.clearStones_[i] or 0
		self.clearStones_[i] = self.clearStones_[i] + clearColors[i]
	end

	self:dispatchEvent({name = PlayDirector.CLEAR_STONE_EVENT})
	local delay = 0.2
	if isClearSkill == true then
		delay = 0.5
	end
	self:performWithDelay(function()
		self.fsm__:doEvent("resetStone", {is_clear = true})
		end, delay)
end

function PlayDirector:onResetStone_(event)
	local args = event.args[1] or {}
	self.curSkillStone_ = nil
	self.curEffectStones_ = {}

	self.selectSkill_ = nil

	self.coverLayer_:setVisible(false)
	-- 重置所有stone
	self.selectStones_ = {}

	for i=1,PlayDirector.SMaxRow do
		for j=1,PlayDirector.SMaxCol do
			local oneStone = self.stoneViews_[i][j]
			if oneStone then
				if oneStone:getStoneState() == enStoneState.Highlight then
					self:reorderChild(oneStone, 0)
				end
				oneStone:setStoneState(enStoneState.Normal, {isClearSkillEffect = true})
			end

			local oneCover = self.coverViews_[i][j]
			if oneCover and oneCover:getIsSkillEffect() == true then
				oneCover:setSkillEffect(false)
			end
		end
	end

	-- 如果消除了，就要更新Matrix
	if args.is_clear == true then
		self:updateMatrix_()
	end
end

-- 技能按钮
function PlayDirector:initSkill_()
	for i=1,5 do
		self.skillDatas_[i] = SkillCfg.get(self.levelData_.skill[i])
	end
end

-- 消除后，更新7x7矩阵, 有不会移动的珠子，左右随机
function PlayDirector:updateMatrix3_()
	local isRunAction = false

	-- 获得一个可以移动到的位置
	local function getRunActionPos(rowIndex, colIndex, valueIndex)
		local newRowIndex = rowIndex - 1
		local newColIndex = colIndex + valueIndex
		-- 目标位置超出有效范围
		if self:getIsInMatrix_(newRowIndex, newColIndex) == false then
			return nil
		end

		-- 目标位置有stone或者是冰块
		if self.stoneViews_[newRowIndex][newColIndex] or self.coverViews_[newRowIndex][newColIndex] then
			return nil
		end

		if valueIndex ~= 0 and self:getIsSelectStone_(self.stoneViews_[rowIndex][colIndex+valueIndex]) == true then
			return nil
		end

		return newRowIndex, newColIndex
	end

	-- 去找它上面的，离他最近的那个stone, 如果碰到不能移动的珠子，那么就从两边移动
	local function stoneRunAction(rowIndex, colIndex)
		local threeX
		-- 随机向左，或者向右
		if math.random(1, 2) == 1 then
			threeX = {0, 1, -1}
		else
			threeX = {0, -1, 1}
		end
		local newRowIndex, newColIndex
		local oneStone = self.stoneViews_[rowIndex][colIndex]
		for k,v in ipairs(threeX) do
			newRowIndex, newColIndex = getRunActionPos(rowIndex, colIndex, v)
			if newRowIndex ~= nil then
				oneStone:setRowColIndex(newRowIndex, newColIndex)
				self.stoneViews_[newRowIndex][newColIndex] = oneStone
				self.stoneViews_[rowIndex][colIndex] = nil
				
				oneStone:stop()
				local pos1X, pos1Y = self:getStonePosByIndex_(newRowIndex, newColIndex)
				oneStone:moveTo(PlayDirector.TimeDrop, pos1X, pos1Y)
				isRunAction = true

				break
			end
		end
	end

	-- 创建新的stone,在第8行
	local function addNewStone(colIndex)
		-- 最上面一行了，创建新的吧
		local pos1X, pos1Y = self:getStonePosByIndex_(7, colIndex)
		local pos2X, pos2Y = self:getStonePosByIndex_(8, colIndex)					
		local oneStone = app:createView("StoneView", {rowIndex = 7, colIndex = colIndex, stoneType = self:getRandomStoneColor_()})
			:addTo(self)
			:pos(pos2X, pos2Y)					
		self.stoneViews_[7][colIndex] = oneStone
		oneStone:stop()
		oneStone:moveTo(PlayDirector.TimeDrop, pos1X, pos1Y)
		isRunAction = true
	end

	local oneStone
	for i=2,PlayDirector.SMaxRow+1 do
		for j=1,PlayDirector.SMaxCol do
			if i == PlayDirector.SMaxRow+1 then
				oneStone = self.stoneViews_[i-1][j]
				if oneStone == nil then
					addNewStone(j)
				end
			else
				oneStone = self.stoneViews_[i][j]
			 	if self:getIsSelectStone_(oneStone) == true then
		 			stoneRunAction(i, j)
			 	end
			end 
		end
	end

	if isRunAction == true then
		self:performWithDelay(function()
			self:updateMatrix3_()
			end, PlayDirector.TimeDrop)
	else
		self:newStep_()
	end
end

-- 消除后，更新7x7矩阵
function PlayDirector:updateMatrix_()
	local pos1X, pos1Y, pos2X, pos2Y
	local oneStone
	local tempIndex
	local addStoneArr = {} -- 用来记录每一列新创建的珠子
	local threeX = {0, 1, -1}
	local isFixed = false -- 是否有固定的

	for i=1,PlayDirector.SMaxRow do
		for j=1,PlayDirector.SMaxCol do
			oneStone = self.stoneViews_[i][j]
			if self.coverViews_[i][j] == nil and oneStone == nil then
			-- 去找它上面的，离他最近的那个stone
				tempIndex = 0
				pos1X, pos1Y = self:getStonePosByIndex_(i, j)

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

					pos2X, pos2Y = self:getStonePosByIndex_(PlayDirector.SMaxRow+addStoneArr[j], j)
					
					self.stoneViews_[i][j] = app:createView("StoneView", {rowIndex = i, colIndex = j, stoneType = self:getRandomStoneColor_()})
						:addTo(self)
						:pos(pos2X, pos2Y)
					oneStone = self.stoneViews_[i][j]
				elseif self:getIsSelectStone_(oneStone) == true then
					oneStone:setRowColIndex(i, j)
					self.stoneViews_[i][j] = oneStone
					self.stoneViews_[i+tempIndex][j] = nil
				else
					isFixed = true
				end

				if self:getIsSelectStone_(oneStone) == true then
					oneStone:runAction(cc.MoveTo:create(PlayDirector.TimeDrop, cc.p(pos1X, pos1Y)))
				end
			end
		end
	end

	if isFixed == true then
		self:performWithDelay(function()
			self:updateMatrix3_()
		end, PlayDirector.TimeDrop)
	else
		self:newStep_()
	end
end

-- 触摸回调
function PlayDirector:onTouch_(event)
    -- event.name 是触摸事件的状态：began, moved, ended, cancelled
    -- event.x, event.y 是触摸点当前位置
    -- event.prevX, event.prevY 是触摸点之前的位置
    -- local label = string.format("PlayDirector: %s x,y: %0.2f, %0.2f", event.name, event.x, event.y)
    -- print(label)

    local oneStone = self:getStoneByPos_(event.x, event.y)
    local state = self.fsm__:getState()
    if oneStone then
    	self:dispatchEvent({name = PlayDirector.TIPS_EVENT})
    end

    if oneStone then
    	-- 选中了stone
    	local stoneState = oneStone:getStoneState()
    	if state == "normal" then
    		if self:getIsSelectStone_(oneStone) == true then
	    		self.fsm__:doEvent("selectStone", oneStone)

	    		if #self.selectStones_ > 1 then
	    			self:dispatchEvent({name = PlayDirector.TIPS_EVENT, tips = TipsView.TxtAgainTouch})
	    		else
	    			self:dispatchEvent({name = PlayDirector.TIPS_EVENT, tips = TipsView.TxtLessThree})
	    		end

	    	end
    	elseif state == "stoneSelect" then
    		if oneStone:getStoneState() == enStoneState.Highlight and #self.selectStones_ > 1 then
	    		-- 消除
	    		self:useStepCount_()
	    		self.fsm__:doEvent("clearStone")
	    	else
	    		-- 取消选中
	    		self.fsm__:doEvent("resetStone")
	    	end
	    elseif state == "skillSelect" then
	    	-- 使用技能
	    	if stoneState == enStoneState.Highlight then
	    		self:dispatchEvent({name = PlayDirector.TIPS_EVENT, tips = TipsView.TxtSureSkill})
	    		self.fsm__:doEvent("useSkill", oneStone)
	    	else
	    		self.fsm__:doEvent("resetStone")
	    	end
	    elseif state == "skillUse" then
		   	-- 已经显示技能效果了
		   	if stoneState == enStoneState.Highlight then
		   		if oneStone == self.curSkillStone_ then
		   			self.fsm__:doEvent("clearStone", {isClearSkill = true})

		   			-- self.fsm__:doEvent("resetStone", {is_useSkill = true})
		   		else
		   			self.fsm__:doEvent("useSkill", oneStone)
		   		end
		   	else
		   		self.fsm__:doEvent("resetStone", false)
		   	end

    	else
    		-- 取消选中
	    	self.fsm__:doEvent("resetStone")

    	end
    else
    	if state ~= "normal" then
	    	self.fsm__:doEvent("resetStone")
	    end
    end

    -- 返回 true 表示要响应该触摸事件，并继续接收该触摸事件的状态变化
    return false
end

-- 显示技能效果
function PlayDirector:showSkillEffect_(oneStone)
	if oneStone:getIsSkillEffect() == true then
		return
	end

	table.insert(self.curEffectStones_, oneStone)
	oneStone:setSkillEffect(true)

	-- 对一个格子的技能效果
	local function showOneIndexEffect(rowIndex, colIndex)
		local effectCover = self.coverViews_[rowIndex][colIndex]
		if effectCover then
			if effectCover:getIsSkillEffect() == false and effectCover:getIsSplash() == true then
				table.insert(self.curEffectStones_, effectCover)
				effectCover:setSkillEffect(true)
			end
		else
			local effectStone = self.stoneViews_[rowIndex][colIndex]
			if effectStone and effectStone:getIsSkillEffect() == false and self:getIsSelectStone_(effectStone) == true  then
				if effectStone:getSkillData() ~= nil then
				-- 技能触发技能
					self:showSkillEffect_(effectStone)
				else
					table.insert(self.curEffectStones_, effectStone)
					effectStone:setSkillEffect(true)
				end
			end
		end
	end

	-- 一个方向上的技能效果
	local function showOneDirectionEffect(directionValue, rowIndex, colIndex)
		local newRowIndex, newColIndex
		for j=1,8 do
			newRowIndex = rowIndex + directionValue[2]*j
			newColIndex = colIndex + directionValue[1]*j

			if self:getIsInMatrix_(newRowIndex, newColIndex) == true then
				showOneIndexEffect(newRowIndex, newColIndex)
			else
				break
			end
		end
	end

	local rowIndex, colIndex = oneStone:getRowColIndex()
	local skillData = oneStone:getSkillData()
	local direction = skillData.direction
	local directionValue
	for i,v in ipairs(direction) do
		directionValue = Direction8ValueArr[v]
		showOneDirectionEffect(directionValue, rowIndex, colIndex)
		if skillData.effect and skillData.effect == 3 then
			
		end
	end

end

-- 通过坐标获取Stone
function PlayDirector:getStoneByPos_(posX, posY)
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
function PlayDirector:getIsRelate_(stone1, stone2)
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
function PlayDirector:getIsInMatrix_(rowIndex, colIndex)
	if rowIndex >= 1 and rowIndex <= PlayDirector.SMaxRow and colIndex >= 1 and colIndex <= PlayDirector.SMaxCol then
		return true
	else
		return false
	end
end

-- 获取一个stone可以连接的所有stone,
function PlayDirector:getCanLinkStones_(startStone, isCheckStoneType)
	if startStone == nil then
		return {}
	end

	local canLinkStones = {}
	canLinkStones[startStone] = true

	-- 判断1个stone周围8个相连的stone是否符合要求
	local function findCanLinkStone(oneStone)
		local rowIndex, colIndex = oneStone:getRowColIndex()
		for i=1,#Direction4ValueArr do
			local newRowIndex = rowIndex + Direction4ValueArr[i][2]
			local newColIndex = colIndex + Direction4ValueArr[i][1]
			if self:getIsInMatrix_(newRowIndex, newColIndex) == true then
				local relateStone = self.stoneViews_[newRowIndex][newColIndex]
			 	if self:getIsSelectStone_(relateStone) == true 
			 		and (relateStone:getStoneType() == oneStone:getStoneType() 
			 			or relateStone:getStoneType() == enStoneType.Multicolor 
			 			or isCheckStoneType == false) 
			 		and canLinkStones[relateStone] ~= true then
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
function PlayDirector:getStonePosByIndex_(rowIndex, colIndex)
	local posX = PlayDirector.SOriPosX + PlayDirector.SSpace * colIndex + PlayDirector.SSide * (colIndex - 0.5)
	local posY = PlayDirector.SOriPosY + PlayDirector.SSpace * rowIndex + PlayDirector.SSide * (rowIndex - 0.5)
	return posX, posY
end

-- 获得一个随机颜色
function PlayDirector:getRandomStoneColor_()
	local index = math.random(1, #self.dropStoneArr_)
	return self.dropStoneArr_[index]
end

-- 回合数加一
function PlayDirector:useStepCount_()
	if BEIBEI_TEST then
		self.leftStep_ = self.leftStep_ + 1
	else
		self.leftStep_ = self.leftStep_ - 1
	end
	self.stepCount_ = self.stepCount_ + 1
	self:dispatchEvent({name = PlayDirector.CHANGE_STEP_EVENT})
end

-- 新的一回合
function PlayDirector:newStep_()
	-- 判断是否生成技能
	local noSkill = true
	for i=1,5 do
		if self.newSkills_[i] and self.newSkills_[i] > 0 then
			noSkill = false
			break
		end
	end

	if noSkill == false then
		self:createSkill_()
		return
	end

	-- 判断是否合成技能
	if self:composeSkill_() then
		self:performWithDelay(function()
			self:updateMatrix_()
		end, PlayDirector.TimeComposeSkill+0.2)
		return
	end

	-- 关卡结束了
	if self:checkResult_() == true then
		return
	end

	if self:checkIsCanClear_() == true then
		self.touchLayer_:setTouchEnabled(true)	
	else
		-- 不能消除，重新排列
		if self:updateActiveStonePos_() == false then
			self:dispatchEvent({name = PlayDirector.LEVEL_FAIL_EVENT, isNotAddStep = true})
		end
	end

end

-- 检查结果，是否通关
function PlayDirector:checkResult_()
	local allTargetOK = true
	for i,v in ipairs(self.levelData_.target) do
		local clearCount = self.clearStones_[v[1]] or 0
		if clearCount < v[2] then
			allTargetOK = false
			break
		end
	end

	if allTargetOK == true then
	-- 目标已经达成
		local openCount = cc.UserDefault:getInstance():getIntegerForKey("openCount", 1)
		openCount = math.max(openCount, self.levelData_.id+1)
		cc.UserDefault:getInstance():setIntegerForKey("openCount", openCount)
		self:dispatchEvent({name = PlayDirector.LEVEL_SUCCESS_EVENT})
		return true
	end

	if BEIBEI_TEST == nil and self.leftStep_ <= 0 then
	-- 回合数到了，关卡失败
		self:dispatchEvent({name = PlayDirector.LEVEL_FAIL_EVENT})
		return true
	end

	return false

end

-- 增加五回合，继续游戏
function PlayDirector:addStepCount()
	self.leftStep_ = self.leftStep_ + 5
	self:newStep_()
end

-- 检查当前是否没有可以消除的stone
function PlayDirector:checkIsCanClear_(isCheckStoneType)
	local oneStone = nil
	local relateStones = nil
	for i=1,PlayDirector.SMaxRow do
		for j=1,PlayDirector.SMaxCol do
			oneStone = self.stoneViews_[i][j]
			if self:getIsSelectStone_(oneStone) == true then
				relateStones = self:getCanLinkStones_(oneStone, isCheckStoneType)
				if #relateStones > 2 then
					return true
				end
			end
		end
	end

	return false
end

-- 检查当前可以移动的所有stone，各种类数量是否都小于3的
function PlayDirector:checkStoneTypeLessThree_()
	local stoneTypeArr = {}
	for i=1,enStoneType.Max-1 do
		stoneTypeArr[i] = 0
	end

	local allActiveIndexArr = {} -- 所有可以移动的stone index
	local allActiveStones = {} -- 所有可以移动的stone

	local oneStone = nil
	for i=1,PlayDirector.SMaxRow do
		for j=1,PlayDirector.SMaxCol do
			oneStone = self.stoneViews_[i][j]
			if self:getIsSelectStone_(oneStone) == true then
				table.insert(allActiveIndexArr, {i, j})
				table.insert(allActiveStones, oneStone)
				stoneTypeArr[oneStone:getStoneType()] = stoneTypeArr[oneStone:getStoneType()] + 1
			end
		end
	end

	local allLessThree = true
	for i,v in ipairs(stoneTypeArr) do
		if v > 2 then
			allLessThree = false
			break
		end
	end

	return allLessThree, allActiveIndexArr, allActiveStones
end

-- 刷新所有可以移动的stone，保证可以消除，如果肯定不能消除，那么关卡失败
function PlayDirector:updateActiveStonePos_()
	-- 刷新也不会带来消除

	local allLessThree, allActiveIndexArr, allActiveStones = self:checkStoneTypeLessThree_()
	if allLessThree == true then
	-- 1. 不同类型的stone，如果没有超过3个的，
		return false
	end

	if self:checkIsCanClear_(false) == false then
 	-- 2. 忽略相同颜色的限制，相连的stone不超过3个，
 		return false
	end

	local function updateActiveStonePos2()
		local newIndex, newRowIndex, newColIndex
		local allActiveIndexArr2 = clone(allActiveIndexArr)
		for i,v in ipairs(allActiveStones) do
			newIndex = math.random(1, #allActiveIndexArr2)
			newRowIndex = allActiveIndexArr2[newIndex][1]
			newColIndex = allActiveIndexArr2[newIndex][2]

			v:setRowColIndex(newRowIndex, newColIndex)
			self.stoneViews_[newRowIndex][newColIndex] = v

			table.remove(allActiveIndexArr2, newIndex)
		end
	end

	updateActiveStonePos2()
	while self:checkIsCanClear_() == false do
		updateActiveStonePos2()
	end

	local newRowIndex, newColIndex, newPosX, newPosY
	for i,v in ipairs(allActiveStones) do
		newRowIndex, newColIndex = v:getRowColIndex()
		newPosX, newPosY = self:getStonePosByIndex_(newRowIndex, newColIndex)
		v:stop()
		v:moveTo(PlayDirector.TimeUpdatePos, newPosX, newPosY)
	end

	self:performWithDelay(function()
		self.touchLayer_:setTouchEnabled(true)
		end, PlayDirector.TimeUpdatePos)

	return true
end

-- stone是否可以被选中
function PlayDirector:getIsSelectStone_(oneStone)
	if oneStone == nil then
		return nil
	end

	local rowIndex, colIndex = oneStone:getRowColIndex()
	if self.coverViews_[rowIndex][colIndex] then
		return false
	end

	return oneStone:getIsSelected()
end

-- 消除一个stone、cover
function PlayDirector:clearOne_(oneValue)
	if oneValue then
		local table 
		if oneValue:getStoneType2() == enStoneType2.Stone then
			table = self.stoneViews_
		elseif oneValue:getStoneType2() == enStoneType2.Cover then
			table = self.coverViews_
		end

		local rowIndex, colIndex = oneValue:getRowColIndex()
		oneValue:removeFromParent()
		table[rowIndex][colIndex] = nil
	end
end

-- 获取统计数据
function PlayDirector:getSettleData()
	return {stone = self.clearStones_, skill = self.usedSkills_, step = self.stepCount_}
end

-- 根据消除的stone，产生技能
function PlayDirector:createSkill_()
	local stoneTypeArr = {}
	for i=1,5 do
		stoneTypeArr[i] = {}
	end
	local stoneArr = {}
	for i=1,PlayDirector.SMaxRow do
		for j=1,PlayDirector.SMaxCol do
			oneStone = self.stoneViews_[i][j]
			if oneStone and oneStone:getStoneType() <= enStoneType.Purple and oneStone:getSkillData() == nil then
				table.insert(stoneTypeArr[oneStone:getStoneType()], oneStone)
				table.insert(stoneArr, oneStone)
			end
		end
	end	

	local function createOneSkill(stoneType, skillId, skillIndex)
		local targetStone = nil
		local index = nil
		if #stoneTypeArr[stoneType] > 0 then
			index = math.random(1, #stoneTypeArr[stoneType])
			targetStone = stoneTypeArr[stoneType][index]
			table.remove(stoneTypeArr[stoneType], index)
			table.removebyvalue(stoneArr, targetStone) 
		elseif #stoneArr > 0 then
			index = math.random(1, #stoneArr)
			targetStone = stoneArr[index]
			table.remove(stoneArr, index) 
			table.removebyvalue(stoneTypeArr[targetStone:getStoneType()], targetStone)
		end

		local rowIndex, colIndex = targetStone:getRowColIndex()
		local posX, posY = self:getStonePosByIndex_(rowIndex, colIndex)
		local newStone = app:createView("StoneView", {rowIndex = rowIndex, colIndex = colIndex, stoneType = stoneType, skillId = skillId})
				:addTo(self)
				:pos(25*stoneType+120*(stoneType-0.5), 850)
		newStone:runAction(transition.sequence({
				cc.DelayTime:create(0.1*skillIndex),
				cc.EaseIn:create(cc.MoveTo:create(PlayDirector.TimeSkillDrop, cc.p(posX, posY)), 2.5),
				cc.CallFunc:create(function()
					targetStone:removeFromParent()
					self.stoneViews_[rowIndex][colIndex] = nil
					self.stoneViews_[rowIndex][colIndex] = newStone

					if newStone == self.finalNewSkill_ then
					-- 最后一个技能，可以下一步了
						self.newSkills_ = {}
						self:newStep_()
					end
				end
				)}))

		return newStone
	end

	self.finalNewSkill_ = nil
	local index = 0
	for i=1,5 do
		local newSkillCount = self.newSkills_[i]
		if newSkillCount > 0 then
			for j=1,newSkillCount do
				self.finalNewSkill_ = createOneSkill(i, self.skillDatas_[i].id, index)
				local row, col = self.finalNewSkill_:getRowColIndex()
				index = index + 1
			end
		end
	end

end

-- 合成技能
function PlayDirector:composeSkill_()
	local hasCompose = false
	for i=1,PlayDirector.SMaxRow do
		for j=1,PlayDirector.SMaxCol do
			oneStone = self.stoneViews_[i][j]
			if oneStone and oneStone:getSkillData() and self:oneComposeSkill_(oneStone) then
				hasCompose = true
			end
		end
	end
	return hasCompose
end

function PlayDirector:oneComposeSkill_(skillStone)
	local addSkills = skillStone:getSkillData().add or {}
	local toSkills = skillStone:getSkillData().to or {}
	if #addSkills == 0 or #addSkills ~= #toSkills then
		return false
	end

	local rowIndex, colIndex = skillStone:getRowColIndex()
	local oneStone = nil
	local skillIndex = nil
	local newRowIndex, newColIndex

	-- 遍历周围的四个stone，看是否有可以合并的技能
	for i=1,#Direction4ValueArr do
		newRowIndex = rowIndex + Direction4ValueArr[i][2]
		newColIndex = colIndex + Direction4ValueArr[i][1]
		if self:getIsInMatrix_(newRowIndex, newColIndex) == true then
			oneStone = self.stoneViews_[newRowIndex][newColIndex]
			if self:getIsSelectStone_(oneStone) == true and oneStone:getSkillData() ~= nil then
		 		skillIndex = table.indexof(addSkills, tonumber(oneStone:getSkillData().id))
		 		if skillIndex then
			 		break
				end
			end
		end
	end

	if skillIndex then
		local posX, posY = self:getStonePosByIndex_(rowIndex, colIndex)
		self:reorderChild(oneStone, 1)
		self.stoneViews_[rowIndex][colIndex] = nil
		self.stoneViews_[newRowIndex][newColIndex] = nil
		oneStone:stopAllActions()
		oneStone:runAction(transition.sequence({
			cc.MoveTo:create(PlayDirector.TimeComposeSkill, cc.p(posX, posY)),
			cc.CallFunc:create(function()
				skillStone:removeFromParent()
				skillStone = nil
				self.stoneViews_[rowIndex][colIndex] = oneStone
				oneStone:setProperty({rowIndex = rowIndex, colIndex = colIndex, stoneType = enStoneType.Multicolor,
					skillId = toSkills[skillIndex]})
				self:reorderChild(oneStone, 0)
			end)
			}))
		return true
	else
		return false
	end
end



return PlayDirector


