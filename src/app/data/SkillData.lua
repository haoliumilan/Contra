--
-- Author: Liu Hao
-- Date: 2015-12-03 13:55:07
-- 

local SkillCfg = import("app.config.SkillCfg")

local SkillData = class("SkillData", cc.mvc.ModelBase)

-- 常量

-- 定义属性
SkillData.schema = clone(cc.mvc.ModelBase.schema)
SkillData.schema["stoneType"] = {"number", 1} -- 颜色类型
SkillData.schema["direction"] = {"table", {}} -- 方向
SkillData.schema["effect"] = {"number", 0} -- 每个方向上影响的stone数量
SkillData.schema["iconIndex"] = {"number", 1} -- icon名字
SkillData.schema["needCount"] = {"number", 1} -- 需要消除stone的数量
SkillData.schema["curCount"] = {"number", 0} -- 当前消除stone的数量

function SkillData:ctor(id)
	SkillData.super.ctor(self, SkillCfg.get(id))

	-- 对方向排序，通过第一个方向判断icon的方向
	table.sort(self.direction_, function(a, b)
			return a < b
		end)

	if BEIBEI_TEST == nil then
		-- self.curCount_ = self.needCount_
	end
end

---- property

function SkillData:getSkillId()
	return self.id_
end

function SkillData:getStoneType()
	return self.stoneType_
end

function SkillData:getEffect()
	return self.effect_
end

function SkillData:getDirection()
	return self.direction_
end

function SkillData:getIconIndex()
	return self.iconIndex_
end

function SkillData:getIconAngle()
	return (self.direction_[1] - 1) * 45
end

function SkillData:getNeedCount()
	return self.needCount_
end

function SkillData:getCurCount()
	return self.curCount_
end

-- 


return SkillData
