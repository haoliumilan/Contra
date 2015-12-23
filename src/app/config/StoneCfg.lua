--
-- Author: Liu Hao
-- Date: 2015-12-14 16:57:17
-- 珠子的配置

--[[
	id, 即是stoneType		
	is_selected, 是否可以选中
	is_splash, 是否可以被溅射，比如木箱子，周围有消除，就会被影响，技能可以直接消除
	splash_target, 消除效果， 五种颜色和铁块都是nil，木头是有目标的
]]

local StoneCfg = {}

local configArr = {}

configArr[1] = { -- 红色
	is_selected = true, is_splash = false, hit_count = 1
}

configArr[2] = { -- 橙色
	is_selected = true, is_splash = false, hit_count = 1
}

configArr[3] = { -- 绿色
	is_selected = true, is_splash = false, hit_count = 1
}

configArr[4] = { -- 蓝色
	is_selected = true, is_splash = false, hit_count = 1
}

configArr[5] = { -- 紫色
	is_selected = true, is_splash = false, hit_count = 1
}

configArr[6] = { -- 铁块
	is_selected = false, is_splash = false,hit_count = 1
}

configArr[7] = { -- 木头A
	is_selected = false, is_splash = true, hit_count = 2
}

configArr[8] = { -- 木头B
	is_selected = false, is_splash = true, hit_count = 2
}

configArr[9] = { -- 铁墙
	is_selected = false, is_splash = false, hit_count = 1	
}

configArr[10] = { -- 木墙
	is_selected = false, is_splash = true, hit_count = 2	
}

function StoneCfg.get(stoneId)
    assert(stoneId >= 1 and stoneId <= #configArr, string.format("StoneCfg.get() - invalid stoneId %s", tostring(stoneId)))
    local oneStone = clone(configArr[stoneId])
    oneStone["id"] = tostring(stoneId)
    return oneStone
end

return StoneCfg
