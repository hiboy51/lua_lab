--
-- @Author: Kinnon.Z 
-- @Date: 2018-09-14 11:17:56 
-- @Last Modified by:   Kinnon.Z 
-- @Last Modified time: 2018-09-14 11:17:56 
--

if flow then return flow end
flow = {}

DO_TEST = DO_TEST or false

-- 瀑布流
-- 避免回调嵌套
function flow.waterfall(...) 
    local args = {...}
    if #args == 0 then return end
    local first = table.remove(args, 1)
    first(function() 
        flow.waterfall(unpack(args))
    end)
end

-- 同步执行块
-- 执行块里配合flow.await返回异步结果
-- 创建一个独立的协程，可以实现异步过程的顺序执行
function flow.async(exec)
    coroutine.wrap(exec)()
end

-- 等待异步执行结果
-- @param dothings f(n): n => void, n: (...args) => void
-- 配合在flow.async执行块中使用
function flow.await(dothings)
    local co, sync, ret =  nil, false, {}
    function ret:ret()
        return unpack(self.result)
    end
    dothings(function(...)
        ret.result = {...}
        if not co then
            sync = true
            return
        end
        coroutine.resume(co)
    end)

    if sync then
        return ret
    end

    co = coroutine.running()
    coroutine.yield(ret)
    return ret
end

-- --------------------------------------------------------------------------------------
-- test 
-- --------------------------------------------------------------------------------------

if DO_TEST then

    -- test waterfall
    print("---- test waterfall ----")
    flow.waterfall(
        function(cb)
            print("do something 1 done")
            cb() 
        end,
        function(cb) 
            print("do something 2 done")
            cb() 
        end,
        function(cb) 
            print("do something 3 done")
            cb() 
        end
    )
    print("--------test end---------\n")
    
    --test async await
    print("---- test async await ----")
    flow.async(function()
        local a = flow.await(function(resume) 
            print("await a")
            resume(111)
        end):ret()
    
        local b, c = flow.await(function(resume) 
            print("await b")
            resume(222, 333)
        end):ret()
    
        if not a then print("await a: nil")
        else
            print("await a: " .. a)
        end
        
        print("await b: " .. b .. "," .. c)
    end)
    print("--------test end---------\n")
end

