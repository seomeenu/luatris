function copy(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do res[copy(k)] = copy(v) end
    return res
end

function hexToRGB(hex)
    _,_,r,g,b,a = hex:find("(%x%x)(%x%x)(%x%x)(%x%x)")
    color = {tonumber(r,16)/255,tonumber(g,16)/255,tonumber(b,16)/255,tonumber(a,16)/255}
    return color
end

function transposeMatrix(table)
    local n = #table[1]
    local m = #table
    local t = copy(table)
    for i=1, n do
        for j=1, m do
            t[j][i] = table[i][j]
        end
    end
    return t
end

function rotateMatrix(table)
    local r = transposeMatrix(table)
    local n = #r[1]
    local m = #r
    for i=1, n do
        for j=1, m/2 do
            local temp = r[i][j]
            r[i][j] = r[i][m-j+1]
            r[i][m-j+1] = temp
        end
    end
    return r
end

function round(num)
    return math.floor(num+0.5)
end

function shuffle(table)
    local shuffled = copy(table)
    for i=#table, 2, -1 do
        math.randomseed(os.clock()+i)
        local j = math.random(i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end
    return shuffled
end