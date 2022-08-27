drawModule={}

--[[数据&初始化]]--
-- 读取方块数据
require("blockData")
local blockColor=blockData.blockColor
-- 读取游戏运行数据
require("gameModule")

--[[函数]]--


--绘制场地
local function drawField(field)
    love.graphics.clear(1,1,1)
    for y=1,20 do for x=1,10 do if field[y][x]>0 then
        local tempColor=blockColor[field[y][x]]
        love.graphics.setColor(tempColor[1],tempColor[2],tempColor[3])
        love.graphics.rectangle("fill",40*x-39,801-40*y,38,38)
    end end end
end

-- 绘制方块
local function drawBlock(curBlockShp,pos,curBlockColor)
    local coorX,coorY=pos[1],pos[2]
    local blockSize=#curBlockShp

    love.graphics.setColor(curBlockColor[1],curBlockColor[2],curBlockColor[3])
    for y=1,#curBlockShp do for x=1,#curBlockShp[1]do if curBlockShp[y][x]==1 then
        love.graphics.rectangle("fill",40*(x+coorX-1)-39,801-40*(y+coorY-blockSize),38,38)
    end end end
end

-- 绘制全部
function drawAll()
    drawField(gameModule.getField())
    drawBlock(gameModule.getCurBlockShp(),gameModule.getCurPos(),gameModule.getCurBlockColor())
    love.graphics.present()	-- 输出到屏幕
end

--[[
整合模块
	----
	drawAll()：			    进行绘制
]]--

drawModule.drawAll=drawAll

return drawModule