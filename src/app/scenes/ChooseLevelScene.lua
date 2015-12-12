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
    self.listView_ = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        -- bgScale9 = true,
        async = true, --异步加载
        viewRect = cc.rect(0, 130, 750, 1074),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        -- scrollbarImgV = "bar.png"
    }
        :onTouch(handler(self, self.touchListener))
        :addTo(self)

    self.listView_:setDelegate(handler(self, self.sourceDelegate))

    self.listView_:reload()

end

function ChooseLevelScene:sourceDelegate(listView, tag, idx)
    if cc.ui.UIListView.COUNT_TAG == tag then
        return 50
    elseif cc.ui.UIListView.CELL_TAG == tag then
        local item
        local content

        item = self.listView_:dequeueItem()
        if not item then
            item = self.listView_:newItem()
            content = ChooseLevelCell.new(handler(self, self.cellCb))
            item:addContent(content)
        else
            content = item:getContent()
        end

        if idx == self.curSelectIndex_ then
            content:showContentView(enLevelCellType.Open, nil, idx)
            item:setItemSize(750, 966)
        elseif idx <= self.openCount_ then
            content:showContentView(enLevelCellType.Close, nil, idx)
            item:setItemSize(750, 150)
        else
            content:showContentView(enLevelCellType.Lock, nil, idx)
            item:setItemSize(750, 150)
        end

        return item
    else
    end
end

function ChooseLevelScene:touchListener(event)
    local listView = event.listView
    if "clicked" == event.name then
        print("async list view clicked idx:" .. event.itemPos)
    end
end

function ChooseLevelScene:cellCb(event)
    if event.name == ChooseLevelCell.EventCellClicked then
        if event.cellType == enLevelCellType.Close then
            self.curSelectIndex_ = event.idx
            self.listView_:reload()

        elseif event.cellType == enLevelCellType.Open then
            self.curSelectIndex_ = 0
            self.listView_:reload()

        elseif event.cellType == enLevelCellType.Lock then

        end

    elseif event.name == ChooseLevelCell.EventSure then
        app:enterScene("PlayLevelScene")

    end
end

return ChooseLevelScene