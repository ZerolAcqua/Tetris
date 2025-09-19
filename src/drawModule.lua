drawModule={}

--[[数据&初始化]]--
-- 读取方块数据
require("blockData")
local blockColor=blockData.blockColor
local blocks=blockData.blocks
-- 读取游戏运行数据
require("gameModule")
-- 序列数据
require("sequenceModule")

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

-- 绘制预览序列
local function drawNext(sequence)
    love.graphics.setColor(0,0,0)
    love.graphics.line(400,0,400,800)

    local id
    local oneBlockColor
    local blockShp
    local blockSize
    for i=1,sequenceModule.nextNum do
        id=sequence[i]
        oneBlockColor=blockColor[id]
        blockShp=blocks[id][1]
        blockSize=#blockShp
        X=430
        Y=i*100-70
        love.graphics.setColor(oneBlockColor[1],oneBlockColor[2],oneBlockColor[3])
        for y=1,#blockShp do for x=1,#blockShp[1]do if blockShp[y][x]==1 then
            love.graphics.rectangle("fill",40*(x-1)+X,40*(blockSize-y)+Y,38,38)
        end end end
    end
end
-- 绘制暂存块
local function drawHold(holdType)
    love.graphics.setColor(0,0,0)
    love.graphics.line(400,590,600,590)
    if holdType>0 then
        local id=holdType
        local oneBlockColor=blockColor[id]
        local blockShp=blocks[id][1]
        local blockSize=#blockShp

        X=430
        Y=650
        love.graphics.setColor(oneBlockColor[1],oneBlockColor[2],oneBlockColor[3])
        for y=1,#blockShp do for x=1,#blockShp[1]do if blockShp[y][x]==1 then
            love.graphics.rectangle("fill",40*(x-1)+X,40*(blockSize-y)+Y,38,38)
        end end end
    end
end

-- 绘制全部
function drawAll()
    drawField(gameModule.getField())
    drawBlock(gameModule.getCurBlockShp(),gameModule.getCurPos(),gameModule.getCurBlockColor())
    drawNext(sequenceModule.getSequence())
    drawHold(gameModule.getHoldType())
    love.graphics.present()	-- 输出到屏幕
end

--[[
整合模块
	----
	drawAll()：			    进行绘制
]]--

drawModule.drawAll=drawAll

return drawModule