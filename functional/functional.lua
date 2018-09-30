
-- @Author: Kinnon.Z 
-- @Date: 2018-09-04 10:48:07 
-- @Last Modified by:   Kinnon.Z 
-- @Last Modified time: 2018-09-04 10:48:07 

if fn then return fn end

fn = {}

DO_TEST = DO_TEST or false

-- 扩展table
-- 判断表是否连续
table.continuous = function(t) 
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    
    if count == 0 then return false end

    return count == #t
end

local fnMeta = {
    __shr = function(lhs, rhs) 
        local result = rhs(lhs)
        if (type(result) == "table") then
            setmetatable(result, getmetatable(lhs)) 
        end
        return result
    end
}

-- 遍历table
-- @param t: table
-- @param loopFunc: (k, v, t) => void
fn.foreach = function (t, loopFunc)
    assert(t, "foreach: noly table can be loop")
    
    local ok, err = true, nil;
    for k, v in pairs(t) do
        ok, err = pcall(loopFunc, k, v, t)
        if err then error(err) end
    end
end

-- 映射table
-- @param t: table
-- @param loop: (k, v, t) => nk, nv
fn.map = function(loop)
    return function (t) 
        assert(t, "map: noly table can be loop")
        
        local result = {}
        local ok, err, nk, nv
        for k, v in pairs(t) do 
            ok, err, nv = pcall(loop, k, v, t)
            if ok then
                nk = err
                result[nk] = nv
            else
                error(err)
            end
        end
        
        setmetatable(result, fnMeta)
        return result
    end
end

-- table排序
-- @param t: table
-- @param loop: 同table.sort
fn.sort = function(loop) 
    return function(t)
        assert(t, "sort: noly table can be loop")
        
        table.sort(t, loop)

        setmetatable(t, fnMeta)
        return t         
    end
end

-- 筛选
-- @param t: table
-- @param loop: (k, v, t) => bool
fn.filter = function(loop)
    return function(t)
        assert(t, "filter: noly table can be loop")
        local result = {}
        
        
        if table.continuous(t) then
            for _, v in ipairs(t) do 
                if loop(_, v, t) then
                    table.insert(result, v)
                end
            end
        else
            for k, v in pairs(t) do 
                if loop(k, v, t) then 
                    result[k] = v
                end
            end
        end 

        setmetatable(result, fnMeta)
        return result
    end
end

-- 可以链式调用的包装
-- @param t table
-- @param func fn.map | fn.sort | fn.filter
-- @param loop
fn.chain = function (t, func, loop)
    assert(t, "chain: noly table can be loop")

    if func == nil and loop == nil then
        setmetatable(t, fnMeta)
        return t
    end

    return func(loop)(t)
end

-- 检查所有为真
-- @param t: table
-- @param loop: (t, v, t) => bool
fn.every = function(t, loop) 
    assert(t, "every: noly table can be loop")

    local ok, err
    for k, v in pairs(t) do 
        ok, err = pcall(loop, k, v, t)

        if not ok then return false end
        if not err then return false end
    end

    return true
end

-- 检查部分为真
-- @param t: table
-- @param loop: (k, v, t) => bool
fn.some = function(t, loop)
    assert(t, "some: noly table can be loop")

    local ok, err
    for k, v in pairs(t) do 
        ok, err = pcall(loop, k, v, t)
        if not ok then error(err) end
        if err then return true end
    end

    return false
end

-- 归纳
-- @param t: table
-- @param loop: (pre, curk, curv, t) => nk, nv
fn.reduce = function(t, loop) 
    assert(t, "reduce: noly table can be loop")
    
    local ok, err, nk, nv
    local start = false
    for k, v in pairs(t) do
        if not start then
            start = true;
            nk, nv = k, v
        else
            ok, err, nv = pcall(loop, nk, nv, k, v, t)
            if not ok then error(err) end
            nk = err
        end
    end

    return nk, nv
end

-- ----------------------------------------------------------------
-- testing code
-- ----------------------------------------------------------------

if DO_TEST then 
    local t1 = {
        "a",
        "b",
        "c"
    }
    
    local t2 = {
        a = 1,
        b = 2,
        c = 3
    }
    
    -- test1
    print("foreach test:")
    fn.foreach(t1, function (k, v, t)
        print(k, v) 
    end)
    
    --test2
    local ok = fn.every(t2, function(k, v, t)
        return type(v) == "number"
    end)
    print("every test:" .. tostring(ok))
    
    --test3
    ok = fn.some(t1, function(k, v, t) 
        return k == 4;
    end)
    print("some test:" .. tostring(ok))
    
    --test4
    local kk, vv = fn.reduce(t2, function(ck, cv, k, v) 
        ck = ck .. k
        cv = cv .. v
        return ck, cv
    end)
    print("reduce test:".. kk .. "," .. vv)
    
    --test5
    local newTable = fn.chain(t1, fn.map, function(k, v, t) 
        return v, k
    end) >> fn.filter(function(k, v, t)
        return v < 3
    end) >> fn.map(function(k, v, t) 
        -- local num = string.sub(k, 0, 1)
        -- num = tonumber(num)
        -- return num < 3 
        return v..k, k..v
    end) >> fn.map(function(k, v, t)
        return v .. "__", k .. "__" 
    end)
    print("map test:")
    fn.foreach(newTable, function(k, v, t)
        print(k, v)
    end)
    
    --test6
    newTable = fn.chain(t1, fn.filter, function(k, v, t) 
        return k > 1
    end)
    print("filter test:")
    fn.foreach(newTable, function(k, v, t)
        print(k, v)
    end)
end
-- ----------------------------------------------------------------
-- ----------------------------------------------------------------

return fn


