--
-- Author: Liu Hao
-- Date: 2015-12-03 20:40:46
-- 

local StoneView = import("..views.StoneView")
local SkillView = import("..views.SkillView")
local SkillData = import("..data.SkillData")
local TipsView = import("..views.TipsView")

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

PlayDirector.SkOriPosX = 0 -- 技能最左坐标
PlayDirector.SkOriPosY = 850 
PlayDirector.SkSpace = 25 -- 技能之间的间距
PlayDirector.SkSide = 120 -- 技能的边长

PlayDirector.TimeDrop = 0.1 -- 珠子掉落一个格子用的时间
PlayDirector.TimeUpdatePos = 0.2 -- stone刷新位置的时间

-- 定义事件
PlayDirector.CHANGE_STEP_EVENT = "CHANGE_STEP_EVENT"
PlayDirector.CLEAR_STONE_EVENT = "CLEAR_STONE_EVENT"
PlayDirector.LEVEL_SUCCESS_EVENT = "LEVEL_SUCCESS_EVENT"
PlayDirector.LEVEL_FAIL_EVENT = "LEVEL_FAIL_EVENT"
PlayDirector.TIPS_EVENT = "TIPS_EVENT"

function PlayDirector:ctor(levelData)
	self.levelData_ = levelData

	self.stoneViews_ = {} -- stoneView 7x7 
	self.wallXViews_ = {} -- stone之间的x轴墙 8x7
	self.wallYViews_ = {} -- stone之间的y轴墙 7x8
	self.coverViews_ = {} -- stone上面的盖子 7x7

	self.skillDatas_ = {} 	-- 技能
	self.skillViews_ = {} -- skillView

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

	self.coverLayer_ = display.newColorLayer(cc.c4b(0, 0, 0, 150))
		:addTo(self, 1)
		:pos(25, 25)
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
	    {name = "clearStone", from = {"stoneSelect", "skillUse"}, to = "stoneClear" },
	    -- 重置stone
	    {name = "resetStone", from = {"stoneSelect", "stoneClear", "skillUse", "skillSelect"}, to = "normal" },
	    -- 选中skill
	    {name = "selectSkill", from = {"normal", "skillSelect", "skillUse"}, to = "skillSelect" },
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
	local oneSkill 
	local stoneCfg = self.levelData_.stone
	for i=1,PlayDirector.SMaxRow do
		self.stoneViews_[i] = {}
		self.coverViews_[i] = {}
		for j=1,PlayDirector.SMaxCol do
			if stoneCfg[i][j] then
				stoneType = stoneCfg[i][j]
				coverType = 0
				oneSkill = nil
				if type(stoneCfg[i][j]) == "table" then
					stoneType = stoneCfg[i][j].s or 0
					coverType = stoneCfg[i][j].c or 0
					if stoneCfg[i][j].sk and stoneCfg[i][j].sk > 0 then
						oneSkill = SkillData.new(stoneCfg[i][j].sk)
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
						skill = oneSkill})
						:addTo(self)
						:pos(posX, posY)
				end
			end
		end
	end

	-- 墙 x轴
	local wallXCfg = self.levelData_.wallX
	for i=1,PlayDirector.SMaxRow+1 do
		self.wallXViews_[i] = {}
		for j=1,PlayDirector.SMaxCol do
			if wallXCfg[i][j] and wallXCfg[i][j] > 0 then
				posX, posY = self:getWallXPosByIndex_(i, j)
				self.wallXViews_[i][j] = app:createView("StoneView", {rowIndex = i, colIndex = j, stoneType = wallXCfg[i][j]})
					:addTo(self, 2)
					:pos(posX, posY)
			end
		end
	end

	-- 墙 y轴
	local wallYCfg = self.levelData_.wallY
	for i=1,PlayDirector.SMaxRow do
		self.wallYViews_[i] = {}
		for j=1,PlayDirector.SMaxCol+1 do
			if wallYCfg[i][j] and wallYCfg[i][j] > 0 then
				posX, posY = self:getWallYPosByIndex_(i, j)
				self.wallYViews_[i][j] = app:createView("StoneView", {rowIndex = i, colIndex = j, stoneType = wallYCfg[i][j]})
					:addTo(self, 2)
					:pos(posX, posY)
					:rotation(90)
			end
		end
	end

	self:updateMatrix_()
end

function PlayDirector:onSelectStone_(event)
	-- 选中一个StoneView, 相邻的相同颜色的stone自动选中，其他的变成不可选中状态
	local selectStone = event.args[1]
	self.skillViews_[selectStone:getStoneType()]:showSkillCount(true)
	self.coverLayer_:setVisible(true)

	self.selectStones_ = self:getCanLinkStones_(selectStone)

	for i,v in ipairs(self.selectStones_) do
		self:reorderChild(v, 1)
		v:setStoneState(enStoneState.Highlight, {isFade = true})
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
	local isClearSkill = event.args[1].isClearSkill or false

	local clearColors = {} -- 每种颜色消除的数量
	local splashStones = {} -- 被溅射到的stone
	local splashCovers = {} -- 被溅射到的cover
	local splashWallXs = {} -- 溅射到的wallX
	local splashWallYs = {} -- 溅射到的wallY
	for i=1,enStoneType.Max-1 do
		clearColors[i] = 0
	end

	-- 寻找溅射的
	local function findSplashStone(centerStone)
		local rowIndex, colIndex = centerStone:getRowColIndex()
		for i=1,#DirectionSplashArr do
			-- 溅射到的墙
			local isSplashWall = false
			local newRowIndex = rowIndex + math.max(0, DirectionSplashArr[i][2])
			local newColIndex = colIndex + math.max(0, DirectionSplashArr[i][1])
			local splashWall
			if i%2==1 then
				splashWall = self.wallYViews_[newRowIndex][newColIndex]
				if splashWall and splashWall:getIsSkillEffect() == false then
					isSplashWall = true
					if splashWall:getIsSplash() == true then
						splashWallYs[splashWall] = true
					end
				end
			else
				splashWall = self.wallXViews_[newRowIndex][newColIndex]
				if splashWall and splashWall:getIsSkillEffect() == false then
					isSplashWall = true
					if splashWall:getIsSplash() == true then
						splashWallXs[splashWall] = true
					end
				end
			end

			newRowIndex = rowIndex + DirectionSplashArr[i][2]
			newColIndex = colIndex + DirectionSplashArr[i][1]
			if isSplashWall == false and self:getIsInMatrix_(newRowIndex, newColIndex) == true then
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
	if isClearSkill == false then
		local oneStone = nil
		for i=1,PlayDirector.SMaxRow do
			for j=1,PlayDirector.SMaxCol do
				oneStone = self.stoneViews_[i][j]
				if oneStone and oneStone:getStoneState() == enStoneState.Highlight 
					and oneStone:getIsSkillEffect() == false then
					findSplashStone(oneStone)
					
					if oneStone:getSkillData() then
						local skillId = oneStone:getSkillData():getSkillId()
						self.usedSkills_[skillId] = self.usedSkills_[skillId] or 0
	  					self.usedSkills_[skillId] = self.usedSkills_[skillId] + 1
					end

					clearColors[oneStone:getStoneType()] = clearColors[oneStone:getStoneType()] + 1
					self:clearOne_(oneStone)
				end

			end
		end
	else
		local skillId = self.curSkillStone_:getSkillData():getSkillId()
		self.usedSkills_[skillId] = self.usedSkills_[skillId] or 0
		self.usedSkills_[skillId] = self.usedSkills_[skillId] + 1
		findSplashStone(self.curSkillStone_)
		self:clearOne_(self.curSkillStone_)
		self.curSkillStone_ = nil
	end

	-- 技能波及的
	for i,v in ipairs(self.curEffectStones_) do
		clearColors[v:getStoneType()] = clearColors[v:getStoneType()] + 1
		self:clearOne_(v)						
	end

	-- 消除溅射到的stone
	local splashArr = table.keys(splashStones)
	for i,v in ipairs(splashArr) do
		if v:splash() == true then
			clearColors[v:getStoneType()] = clearColors[v:getStoneType()] + 1
			self:clearOne_(v)
		end
	end

	-- 消除溅射到的cover
	splashArr = table.keys(splashCovers)
	for i,v in ipairs(splashArr) do
		if v:splash() == true then
			clearColors[v:getStoneType()] = clearColors[v:getStoneType()] + 1
			self:clearOne_(v)
		end
	end

	-- 溅射到的wallX
	splashArr = table.keys(splashWallXs)
	for i,v in ipairs(splashArr) do
		if v:splash() == true then
			clearColors[v:getStoneType()] = clearColors[v:getStoneType()] + 1
			self:clearOne_(v)
		end
	end

	-- 溅射到的wallY
	splashArr = table.keys(splashWallYs)
	for i,v in ipairs(splashArr) do
		if v:splash() == true then
			clearColors[v:getStoneType()] = clearColors[v:getStoneType()] + 1
			self:clearOne_(v)
		end
	end

	for i=1,5 do
		self.skillDatas_[i]:addCurCount(clearColors[i])
	end

	for i=1,enStoneType.Max-1 do
		self.clearStones_[i] = self.clearStones_[i] or 0
		self.clearStones_[i] = self.clearStones_[i] + clearColors[i]
	end

	self:dispatchEvent({name = PlayDirector.CLEAR_STONE_EVENT})
	self:performWithDelay(function()
		self.fsm__:doEvent("resetStone", {is_clear = true})
		end, 0.2)
end

function PlayDirector:onResetStone_(event)
	local args = event.args[1] or {}
	if self.curSkillStone_ and args.is_useSkill ~= true then
		self.curSkillStone_:setSkillData(nil)
	end
	self.curSkillStone_ = nil
	self.curEffectStones_ = {}

	if self.selectSkill_ and self.skillViews_[self.selectSkill_:getStoneType()]:getSkillState() == enSkillState.Using then
		self.skillViews_[self.selectSkill_:getStoneType()]:setSkillState(enSkillState.CanUse)
	end
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

	-- 墙 x轴
	local oneWall = nil	
	for i=1,PlayDirector.SMaxRow+1 do
		for j=1,PlayDirector.SMaxCol do
			oneWall = self.wallXViews_[i][j]
			if oneWall and oneWall:getIsSkillEffect() == true then
				oneWall:setSkillEffect(false)
			end
		end
	end
	-- 墙 y轴
	for i=1,PlayDirector.SMaxRow do
		for j=1,PlayDirector.SMaxCol+1 do
			oneWall = self.wallYViews_[i][j]
			if oneWall and oneWall:getIsSkillEffect() == true then
				oneWall:setSkillEffect(false)
			end
		end
	end

	for i=1,5 do
		self.skillViews_[i]:showSkillCount(false)
	end

	-- 如果消除了，就要更新Matrix
	if args.is_clear == true then
		self:updateMatrix_()
	end
end

function PlayDirector:onSelectSkill_(event)
	if self.selectSkill_ then
		self.skillViews_[self.selectSkill_:getStoneType()]:setSkillState(enSkillState.CanUse)
	end
	self.coverLayer_:setVisible(true)

	self.selectSkill_ = event.args[1]
	self.skillViews_[self.selectSkill_:getStoneType()]:setSkillState(enSkillState.Using)

	for i=1,PlayDirector.SMaxRow do
		for j=1,PlayDirector.SMaxCol do
			local oneStone = self.stoneViews_[i][j]
			if oneStone then
				if oneStone:getStoneType() ~= self.selectSkill_:getStoneType() then
					oneStone:setStoneState(enStoneState.Disable, {isClearSkillEffect = true})
				else
					oneStone:setStoneState(enStoneState.Highlight, {isClearSkillEffect = true})
					self:reorderChild(oneStone, 1)
				end
			end
		end
	end

end

function PlayDirector:onUseSkill_(event)
	if self.curSkillStone_ then
		self.curSkillStone_:setSkillData(nil)
		for i,v in ipairs(self.curEffectStones_) do
			v:setSkillEffect(false)
		end
	end

	self.curSkillStone_ = nil
	self.curEffectStones_ = {}

	local selectStone = event.args[1]
	selectStone:setSkillData(self.selectSkill_)
	self.curSkillStone_ = selectStone
	self:showSkillEffect_(selectStone)

end

-- 技能按钮
function PlayDirector:initSkill_()
	local posX
	for i=1,5 do
		self.skillDatas_[i] = SkillData.new(self.levelData_.skill[i])
		posX = PlayDirector.SkOriPosX + PlayDirector.SkSpace * i + PlayDirector.SkSide * (i - 0.5)
		self.skillViews_[i] = app:createView("SkillView", {skillData = self.skillDatas_[i]})
			:addTo(self, 1)
			:pos(posX, PlayDirector.SkOriPosY)
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

		-- 如果有wall阻隔，不能掉下去
		if self:getIsLinkByWall(rowIndex, colIndex, -1, valueIndex) == false then
			return nil
		end

		if valueIndex ~= 0 and self:getIsSelectStone_(self.stoneViews_[rowIndex][colIndex+valueIndex]) == true
				and self.wallXViews_[rowIndex][colIndex+valueIndex] == nil then
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
				if oneStone == nil and self.wallXViews_[i][j] == nil and self.coverViews_[i-1][j] == nil then
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
					if self.wallXViews_[i+tempIndex+1][j] ~= nil then
						-- 有障碍
						break
					end

					if i + tempIndex == PlayDirector.SMaxRow then
						break
					else
						tempIndex = tempIndex + 1
						oneStone = self.stoneViews_[i+tempIndex][j]
					end
				end

				if self.wallXViews_[i+tempIndex+1][j] ~= nil then
					-- 如果有障碍就停下来吧
					oneStone = nil
					isFixed = true
				elseif oneStone == nil then
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
    local oneSkill = self:getSkillByPos_(event.x, event.y)
    local state = self.fsm__:getState()
    if oneStone or oneSkill then
    	self:dispatchEvent({name = PlayDirector.TIPS_EVENT})
    end

    if oneStone then
    	-- 选中了stone
    	local stoneState = oneStone:getStoneState()
    	if state == "normal" then
    		if self:getIsSelectStone_(oneStone) == true then
	    		self.fsm__:doEvent("selectStone", oneStone)

	    		if #self.selectStones_ > 2 then
	    			self:dispatchEvent({name = PlayDirector.TIPS_EVENT, tips = TipsView.TxtAgainTouch})
	    		else
	    			self:dispatchEvent({name = PlayDirector.TIPS_EVENT, tips = TipsView.TxtLessThree})
	    		end

	    	end
    	elseif state == "stoneSelect" then
    		if oneStone:getStoneState() == enStoneState.Highlight and #self.selectStones_ > 2 then
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
		   			self.selectSkill_:setCurCount(0)
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

    elseif oneSkill then
    	-- 选中了skill
    	if state == "normal" or state == "skillSelect" or state == "skillUse" then
    		if oneSkill ~= self.selectSkill_ and oneSkill:getCurCount() >= oneSkill:getNeedCount() then
    			self:dispatchEvent({name = PlayDirector.TIPS_EVENT, tips = TipsView.TxtUseSkill})
	    		self.fsm__:doEvent("selectSkill", oneSkill)
	    	else
	    		self:showSkillCount_()
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
	-- 对一个墙的技能效果 <-o-> 
	--       -- --   -- -- 
	-- 		|  |  |o|  |  |
	-- 		 -- -- 	 -- --
	local function showOneWallEffect(isX, rowIndex, colIndex)
		local oneWall = nil
		if isX == true then
			oneWall = self.wallXViews_[rowIndex][colIndex]
		else
			oneWall = self.wallYViews_[rowIndex][colIndex]
		end
		if oneWall and oneWall:getIsSplash() == true and oneWall:getIsSkillEffect() == false then
			table.insert(self.curEffectStones_, oneWall)
			oneWall:setSkillEffect(true)
		end
	end

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
			if effectStone and effectStone:getIsSkillEffect() == false and 
				(self:getIsSelectStone_(effectStone) == true or effectStone:getIsSplash() == true) then
				table.insert(self.curEffectStones_, effectStone)
				effectStone:setSkillEffect(true)

				if effectStone:getSkillData() ~= nil then
				-- 技能触发技能
					self:showSkillEffect_(effectStone)
				end
			end
		end

		-- 当前格子上下左右四个墙
		showOneWallEffect(true, rowIndex+1, colIndex)
		showOneWallEffect(true, rowIndex, colIndex)
		showOneWallEffect(false, rowIndex, colIndex+1)
		showOneWallEffect(false, rowIndex, colIndex)

	end

	-- 一个方向上的技能效果
	local function showOneDirectionEffect(directionValue, rowIndex, colIndex, effect)
		local newRowIndex, newColIndex
		for j=1,effect do
			newRowIndex = rowIndex + directionValue[2]*j
			newColIndex = colIndex + directionValue[1]*j

			if self:getIsInMatrix_(newRowIndex, newColIndex) == true then
				-- wall
				showOneIndexEffect(newRowIndex, newColIndex)
			else
				--  wallX多一行、wallY多一列
				if newRowIndex == PlayDirector.SMaxRow + 1 then
					showOneWallEffect(true, newRowIndex, newColIndex)
				elseif newColIndex == PlayDirector.SMaxCol + 1 then
					showOneWallEffect(false, newRowIndex, newColIndex)
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

-- 通过坐标获取Skill
function PlayDirector:getSkillByPos_(posX, posY)
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

-- 判断两个stone之间的wall是否阻止他们相连, wall和不能移动的stone也可以阻止相连
function PlayDirector:getIsLinkByWall(rowIndex, colIndex, rowValue, colValue)
	if colValue == 0 then
		if self.wallXViews_[rowIndex+math.max(0, rowValue)][colIndex] then
			return false
		end
	elseif rowValue == 0 then
	   	if self.wallYViews_[rowIndex][colIndex+math.max(0, colValue)] then
			return false
		end
	else
		-- 右上、右下、左上、左下
		if (self:getIsSelectStone_(self.stoneViews_[rowIndex+rowValue][colIndex]) == false
			or self.wallXViews_[rowIndex+math.max(rowValue, 0)][colIndex]
			or self.wallYViews_[rowIndex+rowValue][colIndex+math.max(colValue, 0)])
			and (self:getIsSelectStone_(self.stoneViews_[rowIndex][colIndex+colValue]) == false
				or self.wallXViews_[rowIndex+math.max(rowValue, 0)][colIndex+colValue]
				or self.wallYViews_[rowIndex][colIndex+math.max(colValue, 0)]) then
			return false
		end
	end

	return true
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
		for i=1,#DirectionValueArr do
			local newRowIndex = rowIndex + DirectionValueArr[i][2]
			local newColIndex = colIndex + DirectionValueArr[i][1]
			if self:getIsInMatrix_(newRowIndex, newColIndex) == true 
				and self:getIsLinkByWall(rowIndex, colIndex, DirectionValueArr[i][2], DirectionValueArr[i][1]) == true then
				local relateStone = self.stoneViews_[newRowIndex][newColIndex]
			 	if self:getIsSelectStone_(relateStone) == true 
			 		and (relateStone:getStoneType() == oneStone:getStoneType() or isCheckStoneType == false) 
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

-- 获取墙X的坐标
function PlayDirector:getWallXPosByIndex_(rowIndex, colIndex)
	local posX = PlayDirector.SOriPosX + PlayDirector.SSpace * colIndex + PlayDirector.SSide * (colIndex - 0.5)
	local posY = PlayDirector.SOriPosY + PlayDirector.SSpace * rowIndex + PlayDirector.SSide * (rowIndex - 1) - 2
	return posX, posY
end

-- 获取墙Y的坐标
function PlayDirector:getWallYPosByIndex_(rowIndex, colIndex)
	local posX = PlayDirector.SOriPosX + PlayDirector.SSpace * colIndex + PlayDirector.SSide * (colIndex - 1) - 2
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
	if self:checkResult_() == true then
	-- 关卡结束了
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

-- 显示技能数量
function PlayDirector:showSkillCount_()
	local oneSkill = nil
	for i=1,5 do
		oneSkill = self.skillDatas_[i]
		if oneSkill:getCurCount() < oneSkill:getNeedCount() then
			self.skillViews_[i]:showSkillCount(true, true)
		end
	end
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

-- 消除一个stone、wall、cover
function PlayDirector:clearOne_(oneValue)
	if oneValue then
		local table 
		if oneValue:getStoneType2() == enStoneType2.Stone then
			table = self.stoneViews_
		elseif oneValue:getStoneType2() == enStoneType2.Cover then
			table = self.coverViews_
		elseif oneValue:getStoneType2() == enStoneType2.Wall then
			if oneValue:getRotation() == 90 then
				table = self.wallYViews_
			else
				table = self.wallXViews_
			end
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

return PlayDirector
