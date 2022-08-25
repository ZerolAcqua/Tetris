function anime(imageList,timeList)

    local play = false --播放标记（是否在播放）
    local now = 1 --当前帧
    local nowTime --当前时间

    if #imageList ~= #timeList then
        error("image num ~= time num") --提示你图片数量和时间间隔数量是不一致的
    end

    local function reset()
        now = 1
        nowTime = love.timer.getTime() + timeList[now] --获取当前时间
    end

    return {
        start = function() --开始播放
            if not play then --如果已经开始播放，再次调用时将不再有效
                play = true
                reset()
            end
        end,
        stop = function() --停止播放
            play = false
        end,
        reset = function() --重置播放
            reset()
        end,
        update = function() --更新播放
            if play and love.timer.getTime() >= nowTime then
                now = now + 1
                if now > #imageList then
                    reset() --重置
                else
                    nowTime = love.timer.getTime() + timeList[now] --获取下一帧的时间
                end
            end
        end,
        draw = function(x,y) --绘制
            love.graphics.draw(imageList[now],x,y)
        end
    }

end


function love.load() --资源加载回调函数，仅初始化时调用一次

    displayW,displayH = love.window.getMode() --获得窗口尺寸
    playerPos = 2 --标记方向（1234分别代表上下左右）
    playerV = 100 --玩家移动速度
    playerX = displayW/2 --玩家的X轴
    playerY = displayH/2 --玩家的Y轴
    animetion = {} --动画

    local imageList = {}
    local timeList = {0.25,0.25,0.25,0.25} --播放间隔时间

    --初始化图片资源
    for i=1,16 do
        imageList[i] = love.graphics.newImage("asset/example2/"..tostring(i)..".png")
    end
    --初始化四份动画
    for i=1,4 do
        local animeListBuffer = {}

        for j=1,4 do
            animeListBuffer[j] = imageList[(i-1)*4+j] --存储成四份图片资源
        end
        animetion[i] = anime(animeListBuffer,timeList)
    end

end


function love.update(dt) --更新回调函数，每周期调用

    --切换玩家的方向
    if love.keyboard.isDown("w") then
        playerPos = 1
        playerY = playerY - playerV*dt
    elseif love.keyboard.isDown("s") then
        playerPos = 2
        playerY = playerY + playerV*dt
    elseif love.keyboard.isDown("a") then
        playerPos = 3
        playerX = playerX - playerV*dt
    elseif love.keyboard.isDown("d") then
        playerPos = 4
        playerX = playerX + playerV*dt
    end

    if love.keyboard.isDown("w","s","a","d") then --wsad任意一个被按下则开始动画
        animetion[playerPos].start()
    else
        animetion[playerPos].stop()
        animetion[playerPos].reset() --不按下时重置为最初状态
    end
    --除了被按下的按钮的方向动画均被重置
    for i=1,4 do
        if i ~= playerPos then
           animetion[i].stop()
           animetion[i].reset()
       end
    end
    animetion[playerPos].update()

end


function love.draw() --绘图回调函数，每周期调用

    --love.graphics.circle("fill",playerX,playerY,5) --模拟玩家的位置
    animetion[playerPos].draw(playerX,playerY) --绘制玩家

end