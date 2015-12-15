--
-- Author: liuhao
-- Date: 2015-12-03 11:51:21
-- 选择关卡界面

local ChooseLevelCell = import("..views.ChooseLevelCell")

local ChooseLevelScene = class("ChooseLevelScene", function()
    return display.newScene("ChooseLevelScene")
end)

ChooseLevelScene.ImgBg = "level/bg.jpg"

function ChooseLevelScene:ctor()
    self.curSelectIndex_ = 0 -- 当前选中的cell的index
    self.openCount_ = 10 -- 当前开启的关卡的数量

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
    self.listView = cc.TableView:create(cc.size(750, 900))
    self.listView:setDelegate()
    self:addChild(self.listView)
    self.listView:pos(display.cx, display.cy)
    self.listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)

    self.listView:registerScriptHandler(handler(self,self.numberOfCellsInTableView),cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    self.listView:registerScriptHandler(handler(self,self.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.listView:registerScriptHandler(handler(self,self.scrollViewDidZoom),cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.listView:registerScriptHandler(handler(self,self.tableCellTouched),cc.TABLECELL_TOUCHED)
    self.listView:registerScriptHandler(handler(self,self.cellSizeForTable),cc.TABLECELL_SIZE_FOR_INDEX)
    self.listView:registerScriptHandler(handler(self,self.tableCellAtIndex),cc.TABLECELL_SIZE_AT_INDEX)

end

function ChooseLevelScene:scrollViewDidScroll(view)
end

function ChooseLevelScene:scrollViewDidZoom(view)
end

function ChooseLevelScene:tableCellTouched(table,cell)
    Newprint("cell touched at index: " .. cell:getIdx())
end


function ChooseLevelScene:cellSizeForTable(table,idx) 
    return 750, 150  
end

function ChooseLevelScene:tableCellAtIndex(table, idx)
    print("tableCellAtIndex", idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    end

    if cell["node"] then
        cell["node"]:removeFromParent()
        cell["node"] = nil
    end

    if cell["node"] == nil then
        cell["node"] = ChooseLevelCell.new(handler(self, self.cellCb))
        cell:addChild(cell["node"]) 
    end

    cell["node"]:pos(display.cx, 50)
    cell["node"]:showContentView(enLevelCellType.Close, nil, idx)

    return cell
end

function ChooseLevelScene:numberOfCellsInTableView(table)
  return 10
end

function ChooseLevelScene:cellCb(event)

end

return ChooseLevelScene
