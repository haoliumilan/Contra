--
-- Author: liuhao
-- Date: 2015-12-04 11:42:25
--

-- change table to enum type 枚举
function EnumTable(tbl, index)
    local enumTable = {}
    local enumIndex = index or -1
    for i, v in ipairs(tbl) do
        enumTable[v] = enumIndex + i
    end
    return enumTable
end
