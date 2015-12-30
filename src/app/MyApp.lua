
require("config")
require("cocos.init")
require("framework.init")
require("app.data.GlobalFunction")
require("app.data.GlobalValue")
require("app.data.ImageName")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")

    math.randomseed(os.time())

    if BEIBEI_TEST then
        self:enterScene("MainScene")
    else
        self:enterScene("MainScene")
    end

end

function MyApp:createGrid(scene)
    display.newColorLayer(cc.c4b(255, 255, 255, 255)):addTo(scene)

    for y = display.bottom, display.top, 40 do
        display.newLine(
            {{display.left, y}, {display.right, y}},
            {borderColor = cc.c4f(0.9, 0.9, 0.9, 1.0)})
        :addTo(scene)
    end

    for x = display.left, display.right, 40 do
        display.newLine(
            {{x, display.top}, {x, display.bottom}},
            {borderColor = cc.c4f(0.9, 0.9, 0.9, 1.0)})
        :addTo(scene)
    end

    display.newLine(
        {{display.left, display.cy + 1}, {display.right, display.cy + 1}},
        {borderColor = cc.c4f(1.0, 0.75, 0.75, 1.0)})
    :addTo(scene)

    display.newLine(
        {{display.cx, display.top}, {display.cx, display.bottom}},
        {borderColor = cc.c4f(1.0, 0.75, 0.75, 1.0)})
    :addTo(scene)
end

return MyApp
