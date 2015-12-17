--
-- Author: liuhao
-- Date: 2015-12-03 11:51:21
-- 选择关卡界面

local ChooseLevelCell = import("..views.ChooseLevelCell")
local LevelCfg = import("..config.LevelCfg")

local ChooseLevelScene = class("ChooseLevelScene", function()
    return display.newScene("ChooseLevelScene")
end)

ChooseLevelScene.ImgBg = "level/bg.jpg"

function ChooseLevelScene:ctor()
    self.curSelectIndex_ = -1 -- 当前选中的cell的index
    self.openCount_ = cc.UserDefault:getInstance():getIntegerForKey("openCount", 1) -- 当前开启的关卡的数量

    -- background
    display.newSprite(ChooseLevelScene.ImgBg, display.cx, display.cy)
        :addTo(self)

    -- top
    display.newSprite(ImageName.TopBg, display.cx, display.top - 65)
        :addTo(self, 1)

    -- bottom
    display.newSprite(ImageName.BottomBg, display.cx, 65)
        :addTo(self, 1)

    -- listview
    self.listView_ = cc.TableView:create(cc.size(750, 1034))
    self.listView_:setDelegate()
    self:addChild(self.listView_)
    self.listView_:pos(0, 150)
    self.listView_:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.listView_:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    self.listView_:registerScriptHandler(handler(self,self.numberOfCellsInTableView),cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    self.listView_:registerScriptHandler(handler(self,self.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.listView_:registerScriptHandler(handler(self,self.scrollViewDidZoom),cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.listView_:registerScriptHandler(handler(self,self.tableCellTouched),cc.TABLECELL_TOUCHED)
    self.listView_:registerScriptHandler(handler(self,self.cellSizeForTable),cc.TABLECELL_SIZE_FOR_INDEX)
    self.listView_:registerScriptHandler(handler(self,self.tableCellAtIndex),cc.TABLECELL_SIZE_AT_INDEX)
    self.listView_:reloadData()

end

function ChooseLevelScene:scrollViewDidScroll(view)
end

function ChooseLevelScene:scrollViewDidZoom(view)
end

function ChooseLevelScene:tableCellTouched(table,cell)
    -- print("cell touched at index: ", cell:getIdx())
end


function ChooseLevelScene:cellSizeForTable(table,idx)
    if idx == self.curSelectIndex_ then
        return 966
    else
        return 150  
    end
end

function ChooseLevelScene:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    end

    if cell["node"] == nil then
        cell["node"] = ChooseLevelCell.new(handler(self, self.cellCb))
        cell:addChild(cell["node"]) 
    end

    if idx == self.curSelectIndex_ then
        cell["node"]:pos(display.width/2, 483)
        cell["node"]:showContentView(enLevelCellType.Open, nil, idx)

    elseif idx < self.openCount_ then
        cell["node"]:pos(display.width/2, 75)
        cell["node"]:showContentView(enLevelCellType.Close, nil, idx)

    else
        cell["node"]:pos(display.width/2, 75)
        cell["node"]:showContentView(enLevelCellType.Lock, nil, idx)        

    end

    return cell
end

function ChooseLevelScene:numberOfCellsInTableView(table)
    return LevelCfg.getLevelCount()
end

function ChooseLevelScene:cellCb(event)
    print("cellCb", event.name, self.listView_:getContentOffset().y)
    if event.name == "cellClicked" then
        if event.cellType == enLevelCellType.Close then
            self.curSelectIndex_ = event.idx
            self.listView_:reloadData()
            local off = self.listView_:getContentOffset()
            if off.y == 0 then
                off.y = 1034-150*(29-event.idx)-966
                self.listView_:setContentOffset(off, false)
            end 
        elseif event.cellType == enLevelCellType.Open then
            self.curSelectIndex_ = -1
            local off = self.listView_:getContentOffset()
            self.listView_:reloadData()
            if off.y == 0 then
                off.y = 1034-150*(30-event.idx)
                self.listView_:setContentOffset(off, false) 
            end
        end
    elseif event.name == "sure" then
        app:enterScene("PlayLevelScene", {levelId = event.idx+1}, "flipy")
    else

    end
end

return ChooseLevelScene
