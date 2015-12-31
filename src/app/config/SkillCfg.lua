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

-- 水平一
configArr[1] = {
	direction = {1, 5}, effect = 1, icon = 1, need = 4, 
	merge = {{add = 1, to = 4}, {add = 2, to = 3}},
}

-- 垂直一
configArr[2] = {
	direction = {3, 7}, effect = 1, icon = 1, need = 4, 
	merge = {{add = 1, to = 3}, {add = 2, to = 5}},
}

-- 十字
configArr[3] = {
	direction = {1, 3, 5, 7}, effect = 1, icon = 3,
}

-- 水平三
configArr[4] = {
	direction = {1, 5}, effect = 3, icon = 2,
}

-- 垂直三
configArr[5] = {
	direction = {3, 7}, effect = 3, icon = 2,
}

function SkillCfg.getCount()
	return #configArr
end

function SkillCfg.get(skillId)
	skillId = tonumber(skillId)
    assert(skillId >= 1 and skillId <= #configArr, string.format("SkillCfg.get() - invalid skillId %s", tostring(skillId)))
    local oneSkill = clone(configArr[skillId])
    oneSkill["id"] = tostring(skillId)
    return oneSkill
end

return SkillCfg
