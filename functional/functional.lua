
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
    __mul = function(lhs, rhs) 
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
    
    loopFunc = loopFunc or function(k, v, t) end

    local ok, err = true, nil;
    for k, v in pairs(t) do
        loopFunc(k, v, t)
    end
end

-- 映射table
-- @param t: table
-- @param loop: (k, v, t) => nk, nv
fn.map = function(loop)
    loop = loop or function(k, v, t) 
        return k, v
    end
    return function (t) 
        assert(t, "map: noly table can be loop")
        
        local result = {}
        local nk, nv
        for k, v in pairs(t) do 
            nk, nv = loop(k, v, t)
            result[nk] = nv
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
        assert(table.continuous(t), "sort: noly continuous array can be sort")
        
        table.sort(t, loop)

        setmetatable(t, fnMeta)
        return t         
    end
end

-- 筛选
-- @param t: table
-- @param loop: (k, v, t) => bool
fn.filter = function(loop)
    loop = loop or function(k, v, t) return true end

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
    loop = loop or function(k, v, t) return false end

    local ok
    for k, v in pairs(t) do 
        ok = loop(k, v, t)
        if not ok then return false end
    end

    return true
end

-- 检查部分为真
-- @param t: table
-- @param loop: (k, v, t) => bool
fn.some = function(t, loop)
    assert(t, "some: noly table can be loop")
    loop = loop or function(k, v, t) return false end
    local ok
    for k, v in pairs(t) do 
        ok = loop(k, v, t)
        if ok then return true end
    end

    return false
end

-- 归纳
-- @param t: table
-- @param loop: (pre, curk, curv, t) => nk, nv
fn.reduce = function(t, loop, startK, startV) 
    assert(t, "reduce: noly table can be loop")
    
    local nk = startK
    local nv = startV

    for k, v in pairs(t) do
        nk, nv = loop(nk, nv, k, v, t)
    end

    return nk, nv
end

-- 归纳 k 值
-- reduce的k值特化版本
-- loop:: (sum, curK) => newK 
fn.reduceK = function(t, sum, loop) 
    local rk, _ = fn.reduce(t, function(k, v, nk, nv) 
        return loop(k, nk), nil
    end, sum, nil)
    return rk
end

-- 归纳 v 值
-- reduce的k值特化版本
-- loop:: (sum, curV) => newV 
fn.reduceV = function(t, sum, loop) 
    local _, rv = fn.reduce(t, function(k, v, nk, nv)
        return nil, loop(v, nv)
    end, nil, sum)
    return rv
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
    end, "", "")
    print("reduce test:".. kk .. "," .. vv)
    
    --test5
    local newTable = fn.chain(t1, fn.map, function(k, v, t) 
        return v, k
    end) * fn.filter(function(k, v, t)
        return v < 3
    end) * fn.map(function(k, v, t) 
        -- local num = string.sub(k, 0, 1)
        -- num = tonumber(num)
        -- return num < 3 
        return v..k, k..v
    end) * fn.map(function(k, v, t)
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

function fn.read_only(inputTable)
    local travelled_tables = {}
    local function __read_only(tbl)
        if not travelled_tables[tbl] then
            local tbl_mt = getmetatable(tbl)
            if not tbl_mt then
                tbl_mt = {}
                setmetatable(tbl, tbl_mt)
            end

            local proxy = tbl_mt.__read_only_proxy
            if not proxy then
                proxy = {}
                tbl_mt.__read_only_proxy = proxy
                local proxy_mt = {
                    __index = tbl,
                    __newindex = function (t, k, v) error("error write to a read-only table with key = " .. tostring(k)) end,
                    __pairs = function (t) return pairs(tbl) end,
                    -- __ipairs = function (t) return ipairs(tbl) end,   5.3版本不需要此方法
                    __len = function (t) return #tbl end,
                    __read_only_proxy = proxy
                }
                setmetatable(proxy, proxy_mt)
            end
            travelled_tables[tbl] = proxy
            for k, v in pairs(tbl) do
                if type(v) == "table" then
                    tbl[k] = __read_only(v)
                end
            end
        end
        return travelled_tables[tbl]
    end
    return __read_only(inputTable)
end


return fn


