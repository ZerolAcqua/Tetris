sequenceModule={}

--[[数据&初始化]]--
require("blockData")
local blockSequence={}
local nextNum=5
local blockNum=#blockData.blocks

--[[函数]]--
-- bag 随机出块
local function bag()
    local SortedSequence={}
    local temp={}
    for i=1,blockNum do 
        SortedSequence[i]=i
    end
    while #SortedSequence~=0 do
        local n=math.random(0, #SortedSequence)
        table.insert(temp,SortedSequence[n])
        table.remove(SortedSequence,n)
    end
    return temp
end
-- 按随机器向序列后添加序列
local function addSequence(randomizer)
    local temp=randomizer()
    for i=1,#temp do
        table.insert(blockSequence,temp[i])
    end
end
-- 更新序列
function updateSequence()
    if #blockSequence<nextNum then
        addSequence(bag)
    end
end
-- 获取序列队首
function popFront()
    updateSequence()
    -- print(blockSequence[1])
    return table.remove(blockSequence,1)
end
-- 获取序列
function getSequence()
    updateSequence()
    return blockSequence
end


--[[
整合模块
    nextNum：               预览数目
	----
	updateSequence()：		进行绘制
    popFront()：            获取序列队首
    getSequence()：         获取序列
]]--
sequenceModule.nextNum=nextNum
----
sequenceModule.updateSequence=updateSequence
sequenceModule.popFront=popFront
sequenceModule.getSequence=getSequence

return sequenceModule
