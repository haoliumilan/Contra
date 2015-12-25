--
-- Author: Liu Hao
-- Date: 2015-12-07 17:41:13
-- 技能配置

--[[
	id,
	stoneType, 颜色类型
	effect,  威力，每个方向影响珠子的数量
	needCount, 需要消除stone的数量
	direction, 方向类型				
					7	
				6		8
			5				1
				4		2
					3
]]


local SkillCfg = {}

local configArr = {}

-- 红左
configArr[1] = {
	stoneType = 1, direction = {5}, effect = 2, needCount = 25,
}

-- 黄左右
configArr[2] = {
	stoneType = 2, direction = {1, 5}, effect = 2, needCount = 25,
}

-- 绿右	
configArr[3] = {
	stoneType = 3, direction = {1}, effect = 2, needCount = 25,
}

-- 蓝上
configArr[4] = {
	stoneType = 4, direction = {7}, effect = 2, needCount = 25,
}

-- 紫上下
configArr[5] = {
	stoneType = 5, direction = {3, 7}, effect = 2, needCount = 25,
}

-- 黄下
configArr[6] = {
	stoneType = 2, direction = {3}, effect = 2, needCount = 25,
}

-- 蓝下
configArr[7] = {
	stoneType = 4, direction = {3}, effect = 2, needCount = 25,
}

-- 紫下
configArr[8] = {
	stoneType = 5, direction = {3}, effect = 2, needCount = 25,
}

function SkillCfg.getCount()
	return #configArr
end

function SkillCfg.get(skillId)
    assert(skillId >= 1 and skillId <= #configArr, string.format("SkillCfg.get() - invalid skillId %s", tostring(skillId)))
    local oneSkill = clone(configArr[skillId])
    oneSkill["id"] = tostring(skillId)
    return oneSkill
end

return SkillCfg
