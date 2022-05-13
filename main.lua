objects = {}
debug = false
useColors = false
drawLines = true
targetNum = 1
color1 = {255, 255, 255} -- Used for most things
color2 = {0, 255, 255} -- Used for crosshairs
color3 = {0, 255, 255} -- Used for coordinates

function drawCrosshairs()
    local targetRect = objects[targetNum]
    local x, y, w, h = targetRect.x, targetRect.y, targetRect.width, targetRect.height
    local dist = targetRect.width / 2

    love.graphics.setColor(color2)

    -- Draw crosshairs
    -- Top left corner
    love.graphics.line(x - dist, y - dist, x - dist, y)
    love.graphics.line(x - dist, y - dist, x, y - dist)

    -- Top right corner
    love.graphics.line(x + w + dist, y - dist, x + w + dist, y)
    love.graphics.line(x + w + dist, y - dist, x + w, y - dist)

    -- Bottom left corner
    love.graphics.line(x - dist, y + h + dist, x - dist, y + h)
    love.graphics.line(x - dist, y + h + dist, x, y + h + dist)

    -- Bottom right corner
    love.graphics.line(x + w + dist, y + h + dist, x + w + dist, y + h)
    love.graphics.line(x + w + dist, y + h + dist, x + w, y + h + dist)
end

function createRect()
    return {
        x = math.random(0, love.graphics.getWidth()),
        y = math.random(0, love.graphics.getHeight()),
        width = 20,
        height = 20,
        speed = {
            x = math.random(-300, 300),
            y = math.random(-300, 300)
        },
        color = {
            math.random(0, 255),
            math.random(0, 255),
            math.random(0, 255),
        }
    }
end

function love.load()
    for i = 1, 10 do
        objects[i] = createRect()
    end
end

function love.draw()
    for i, obj in ipairs(objects) do
        if debug then
            if i == targetNum then
                love.graphics.setColor(love.math.colorFromBytes(color3))
                local text = string.format("%d, %d", obj.x, obj.y)
                love.graphics.print(text, obj.x + obj.width * 1.5, obj.y + obj.height / 2 - love.graphics.getFont():getHeight() / 2)
            end
        end
        
        if useColors then
            love.graphics.setColor(love.math.colorFromBytes(obj.color))
        else
            love.graphics.setColor(love.math.colorFromBytes(color1))
        end

        love.graphics.rectangle("fill", obj.x, obj.y, obj.width, obj.height)

        if drawLines then
            for j, obj2 in ipairs(objects) do
                if i == j then
                    break
                end

                if useColors then
                    love.graphics.setColor(love.math.colorFromBytes(obj2.color))
                else
                    love.graphics.setColor(love.math.colorFromBytes(color1))
                end

                love.graphics.line(obj.x + obj.width / 2, obj.y + obj.height / 2, obj2.x + obj2.width / 2, obj2.y + obj2.height / 2)
            end
        end
    end

    if debug then
        drawCrosshairs()
        drawInfoPanel()
    end
end

function boolToOnOff(bool)
    if bool then
        return "On"
    end
    return "Off"
end

function drawInfoPanel()
    local textLines = {
        "FPS: " .. love.timer.getFPS(),
        "Objects: " .. #objects .. " (Up)(Down)",
        "Colors: " .. tostring(boolToOnOff(useColors)) .. " (Space)",
        "Lines: " .. tostring(#objects * (#objects - 1) / 2),
        "Show Lines: " .. tostring(boolToOnOff(drawLines)) .. " (L)",
        "Debug: " .. tostring(boolToOnOff(debug)) .. " (D)",
        "Target: " .. targetNum .. " (Right)(Left)",
        "Matrix: " .. tostring(boolToOnOff(matrixMode)) .. " (M)"
    }

    local maxTextWidth = 0
    for i, line in ipairs(textLines) do
        if love.graphics.getFont():getWidth(line) > maxTextWidth then
            maxTextWidth = love.graphics.getFont():getWidth(line)
        end
    end

    local panel = {
        x = 10,
        y = 10,
        width = maxTextWidth + 20,
        height = #textLines * 20 + 20
    }

    love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
    love.graphics.rectangle("fill", panel.x, panel.y, panel.width, panel.height)

    love.graphics.setColor(love.math.colorFromBytes(color1))
    love.graphics.rectangle("line", panel.x, panel.y, panel.width, panel.height)

    for i, line in ipairs(textLines) do
        love.graphics.print(line, 20, i * 20)
    end
end

function love.update(dt)
    for i, obj in ipairs(objects) do
        obj.x = obj.x + obj.speed.x * dt
        obj.y = obj.y + obj.speed.y * dt

        if obj.x < 0 then
            obj.x = 0
            obj.speed.x = -obj.speed.x
        elseif obj.x + obj.width > love.graphics.getWidth() then
            obj.x = love.graphics.getWidth() - obj.width
            obj.speed.x = -obj.speed.x
        elseif obj.y < 0 then
            obj.y = 0
            obj.speed.y = -obj.speed.y
        elseif obj.y + obj.height > love.graphics.getHeight() then
            obj.y = love.graphics.getHeight() - obj.height
            obj.speed.y = -obj.speed.y
        end
    end
end

function love.keypressed(key)
    if key == "space" then
        useColors = not useColors
    elseif key == "d" then
        debug = not debug
    elseif key == "l" then
        drawLines = not drawLines
    elseif key == "m" then
        matrixMode = not matrixMode
        if matrixMode then
            color1 = {0, 255, 0} -- Green
            color2 = {255, 0, 0} -- Red
            color3 = {255, 0, 0} -- Red
        else
            color1 = {255, 255, 255} -- White
            color2 = {0, 255, 255} -- Cyan
            color3 = {0, 255, 255} -- Cyan
        end
    elseif key == "escape" then
        love.event.quit()
    elseif key == "down" then
        if #objects > 1 then
            table.remove(objects, 1)
        end

        if targetNum > #objects then
            targetNum = 1
        end
    elseif key == "up" then
        table.insert(objects, createRect())
    elseif key == "left" then
        if targetNum > 1 then
            targetNum = targetNum - 1
        else
            targetNum = #objects
        end
    elseif key == "right" then
        if targetNum < #objects then
            targetNum = targetNum + 1
        else
            targetNum = 1
        end
    end
end
