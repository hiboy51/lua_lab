# lua_lab
some interesting and useful features written by lua

## functional —— 一些fp常用的针对数组的高阶方法
命名空间 __fn__:

* fn.foreach(t, loop) :
```
    fn.foreach(table, function(k, v, t) 
        ...
    end)
```
* fn.map(loop) : 
```
    f = fn.map(function(k, v, t) 
        ....
    end)
    newTable = f(table)
```

* fn.chain(t, func, loop) : 
```
    newTable = fn.chain(table, fn.map, function(k, v, t) 
        ...
    end) >> fn.map(function(k, v, t) 
        ...
    end) >> fn.filter(function(k, v, t) 
        ...
    end) >> fn.sort(function(k, v) 
        ...
    end)
```

* fn.filter(loop)
```
    f = fn.filter(function(k, v, t) 
        ...
    end)
    newTable = f(table)
```

* fn.reduce(t, loop)
```
    result = fn.reduce(table, function(k, v, t) 
        ...
    end)
```

* fn.some(t, loop)  
```
    newTable = fn.some(table, function(k, v, t) 
        ...
    end)
```

* fn.every(t, loop)
```
    newTable = fn.every(table, function(k, v, t) 
        ...
    end)
```

* fn.sort(loop)
```
    f = fn.sort(function(k, v) 
        ...
    end)
    newTable = f(table)
```

## flow —— 简化和明晰过程的一些工具函数

命名空间：flow

* flow.waterfall(...) : 
```
    flow.waterfall(
        function(cb) 
            ...
            cb()
        end,

        function(cb) 
            ...
            cb()
        end,

        function(cb) 
            ...
            cb()
        end
    )
```

* flow.async(exec) : 
```
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
```



