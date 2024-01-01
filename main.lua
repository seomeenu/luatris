require "scripts.mino"
require "scripts.board"
require "scripts.utils"

function love.load()
    screenW, screenH = love.graphics.getDimensions()
    love.graphics.setDefaultFilter("nearest", "nearest")
    dotSize = 24
    gravity = 1/64
    gravityTimer = 0

    controls = {
        das = 7,
        arr = 1,
        sdas = 6,
        sarr = 0
    } 
    timers = {
        das = 0,
        arr = 0,
        sdas = 0,
        sarr = 0
    }

    board:set()
    currentMino:set(table.remove(board.next, 1))
end

function love.draw()
    love.graphics.translate(screenW/2-11*dotSize/2, screenH/2-26*dotSize/2)
    love.graphics.setBackgroundColor(hexToRGB("#2d333bff"))
    for y=1, 23 do
        for x=1, 10 do
            local dot = board.grid[y][x]
            if dot ~= 0 then
                love.graphics.setColor(hexToRGB(minoColors[dot]))
                love.graphics.rectangle("fill", x*dotSize, y*dotSize, dotSize, dotSize)
            elseif y > 3 then
                love.graphics.setColor(1, 1, 1, 0.1)
                love.graphics.rectangle("line", x*dotSize, y*dotSize, dotSize, dotSize)
            end
        end
    end
    for i, mino in ipairs(board.next) do
        if i <= 5 then
            local minoShape = minoShapes[mino]
            local offset = {0, 0} 
            if mino == "I" then
                offset = {0, -0.5}
            end 
            if mino == "O" then
                offset = {0.5, 0}
            end
            love.graphics.setColor(hexToRGB(minoColors[mino]))
            for y, row in ipairs(minoShape) do
                for x, dot in ipairs(row) do
                    if dot ~= 0 then
                        love.graphics.rectangle("fill", (x+12+offset[1])*dotSize, (y+i*3+offset[2])*dotSize, dotSize, dotSize)
                    end
                end
            end
        end
    end
    if board.hold ~= nil then
        local offset = {0, 0} 
        if board.hold == "I" then
            offset = {0, -0.5}
        end
        if board.hold == "O" then
            offset = {0.5, 0}
        end
        for y, row in ipairs(minoShapes[board.hold]) do
            for x, dot in ipairs(row) do
                if dot ~= 0 then
                    if board.canHold then
                        love.graphics.setColor(hexToRGB(minoColors[board.hold])) 
                    else
                        love.graphics.setColor({1, 1, 1, 0.1}) 
                    end

                    love.graphics.rectangle("fill", (-5+x+offset[1])*dotSize, (3+y+offset[2])*dotSize, dotSize, dotSize)
                end
            end
        end
    end
    local shadowMino = copy(currentMino)
    for i=1, 23 do
        if not shadowMino:move(board.grid, 0, 1) then
            break 
        end
    end
    for y, row in ipairs(shadowMino.shape) do
        for x, dot in ipairs(row) do
            if dot ~= 0 then
                love.graphics.setColor({1, 1, 1, 0.1}) 
                love.graphics.rectangle("fill", (x+shadowMino.x)*dotSize, (y+shadowMino.y)*dotSize, dotSize, dotSize)
            end
        end
    end
    for y, row in ipairs(minoShapes[board.next[1]]) do
        for x, dot in ipairs(row) do
            if dot ~= 0 then
                love.graphics.setColor({1, 0.1, 0.2, 0.5}) 
                love.graphics.rectangle("fill", (x+math.floor(10/2-#minoShapes[board.next[1]]/2))*dotSize, (y)*dotSize, dotSize, dotSize)
            end
        end
    end
    for y, row in ipairs(currentMino.shape) do
        for x, dot in ipairs(row) do
            if dot ~= 0 then
                love.graphics.setColor(hexToRGB(minoColors[currentMino.name])) 
                love.graphics.rectangle("fill", (x+currentMino.x)*dotSize, (y+currentMino.y)*dotSize, dotSize, dotSize)
            end
        end
    end
end

function love.update(dt)
    dt = dt*60
    gravityTimer = gravityTimer+gravity*dt
    if gravityTimer >= 1 then
        gravityTimer = 0
        currentMino:move(board.grid, 0, 1)
    end

    local dir = 0
    if love.keyboard.isDown("right") then
        dir = 1
    end
    if love.keyboard.isDown("left") then
        dir = -1
    end
    if dir ~= 0 then
        if timers.das > 0 then
            timers.das = timers.das-dt
        end
        if timers.das <= 0 then
            if controls.arr <= 0 then
                for i=1, 10 do
                    if not currentMino:move(board.grid, dir, 0) then
                        break 
                    end
                end
            else
                if timers.arr > 0 then
                    for i=1, 10 do 
                        timers.arr = timers.arr-controls.arr
                        if not currentMino:move(board.grid, dir, 0) then
                            break 
                        end
                        if timers.arr <= 0 then
                            break
                        end
                    end
                end
            end
            timers.arr = timers.arr+dt
        end
    end
    if love.keyboard.isDown("down") then
        if timers.sdas > 0 then
            timers.sdas = timers.sdas-dt
        end
        if timers.sdas <= 0 then
            if controls.sarr <= 0 then
                for i=1, 20 do
                    if not currentMino:move(board.grid, 0, 1) then
                        break 
                    end
                end
            else
                if timers.sarr > 0 then
                    for i=1, 20 do 
                        timers.sarr = timers.sarr-controls.sarr
                        if not currentMino:move(board.grid, 0, 1) then
                            break 
                        end
                        if timers.sarr <= 0 then
                            break
                        end
                    end
                end
            end
            timers.sarr = timers.sarr+dt
        end
    end
end

function love.keypressed(key)
    if key == "right" then
        currentMino:move(board.grid, 1, 0)
        timers.das = controls.das
        timers.arr = 0
    end
    if key == "left" then
        currentMino:move(board.grid, -1, 0)
        timers.das = controls.das
        timers.arr = 0
    end
    if key == "lshift" then
        if board.canHold then
            holdMinoName = board:swapHold(currentMino.name)
            if holdMinoName ~= nil then
                currentMino:set(holdMinoName)
            else
                currentMino:set(board:getNext())
            end
        end
        
    end
    if key == "up" then
        currentMino:rotate(board.grid, 1)
    end
    if key == "lctrl" then
        currentMino:rotate(board.grid, 3)
    end
    if key == "a" then
        currentMino:rotate(board.grid, 2)
    end
    if key == "down" then
        currentMino:move(board.grid, 0, 1)
        timers.sdas = controls.sdas
        timers.sarr = 0
    end
    if key == "space" then
        for i=1, 23 do
            if not currentMino:move(board.grid, 0, 1) then
                break 
            end
        end
        board:place(currentMino)
        currentMino:set(board:getNext())
    end
    if key == "r" then
        board:set()
        currentMino:set(board:getNext())
    end
end

-- function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
--     return x1 < x2+w2 and
--            x2 < x1+w1 and
--            y1 < y2+h2 and
--            y2 < y1+h1
-- end