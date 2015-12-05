--
-- Author: liuhao
-- Date: 2015-12-03 18:53:30
-- 珠子的数据模型

local StoneData = class("StoneData", cc.mvc.ModelBase)

-- 常量

-- 定义属性
StoneData.schema = clone(cc.mvc.ModelBase.schema)
StoneData.schema["colorType"] = {"number", 1} -- 珠子颜色类型
StoneData.schema["relateStones"] = {"table", {}} -- 相邻的珠子，8个方向
StoneData.schema["rowIndex"] = {"number", 1} -- 排列的行序数
StoneData.schema["colIndex"] = {"number", 1} -- 排列的行序数

-- 定义事件
StoneData.CHANGE_STATE_EVENT = "CHANGE_STATE_EVENT"
StoneData.READY_EVENT = "READY_EVENT"
StoneData.SELECT_EVENT = "SELECT_EVENT"
StoneData.DISABLE_EVENT = "DISABLE_EVENT"
StoneData.INDEX_EVENT = "INDEX_EVENT"


function StoneData:ctor(properties)
	StoneData.super.ctor(self, properties)

	self:setStateMachine()

end

-- 设置状态机
function StoneData:setStateMachine()
	-- 因为角色存在不同状态，所以这里为 Actor 绑定了状态机组件
	self:addComponent("components.behavior.StateMachine")
	-- 由于状态机仅供内部使用，所以不应该调用组件的 exportMethods() 方法，改为用内部属性保存状态机组件对象
	self.fsm__ = self:getComponent("components.behavior.StateMachine")

	-- 设定状态机的默认事件
	local defaultEvents = {
	    -- 初始化后，珠子处于 normal 状态
	    {name	= "ready",   	from = {"none", "gray", "highlight"},		to = "normal" },
	    -- 选中，珠子变成 hightlight 状态
	    {name	= "select",  	from = "normal",    						to = "highlight" },
	    -- 不可选中，珠子变成 gray   状态
	    {name	= "disable",  	from = "normal",    						to = "gray" },
	}

	-- 设定状态机的默认回调
	local defaultCallbacks = {
	    onchangestate	= handler(self, self.onChangeState_),
	    onready			= handler(self, self.onReady_),
	    onselect		= handler(self, self.onSelect_),
	    ondisable		= handler(self, self.onDisable_),
	}

	self.fsm__:setupState({
		initial		= "normal",
	    events		= defaultEvents,
	    callbacks	= defaultCallbacks
	})

end

---- property

function StoneData:getState()
    return self.fsm__:getState()
end

function StoneData:getColorType()
	return self.colorType_
end

function StoneData:setRowColIndex(rowIndex, colIndex)
	print("StoneData:setRowColIndex", rowIndex, colIndex)
	self.rowIndex_ = rowIndex
	self.colIndex_ = colIndex
	self:dispatchEvent({name = StoneData.INDEX_EVENT})
end

function StoneData:getRowColIndex()
	return self.rowIndex_, self.colIndex_
end

---- state callbacks

function StoneData:onChangeState_(event)
    -- printf("stone state change from %s to %s", event.from, event.to)
    event = {name = StoneData.CHANGE_STATE_EVENT, from = event.from, to = event.to}
    self:dispatchEvent(event)
end

function StoneData:onReady_(event)
    self:dispatchEvent({name = StoneData.READY_EVENT})
end

function StoneData:onSelect_(event)
    self:dispatchEvent({name = StoneData.SELECT_EVENT})
end

function StoneData:onDisable_(event)
    self:dispatchEvent({name = StoneData.DISABLE_EVENT})
end

-- 

function StoneData:setRandomColorType()
	self.colorType_ = math.random(enColorType.Red, enColorType.Purple)
end

function StoneData:setReady()
	self.fsm__:doEvent("ready")
end

function StoneData:setSelect()
	self.fsm__:doEvent("select")
end

function StoneData:setDisable()
	self.fsm__:doEvent("disable")
end


return StoneData
