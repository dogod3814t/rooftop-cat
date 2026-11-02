local Bat = {}
-- big spooky boss you jump on him like a goomba cause I lack all creativity 
Bat.name = "BAT.EXE"
Bat.label = "GIANT BAT"
Bat.active = false

-- Bat tunes
local HOVER_TIME = 2.5
local WARN_TIME = 0.7
local DIVE_SPEED = 450
local HOVER_Y = 110
local HOVER_OFFSET = 380

local function overlaps(a, b)
    return a.x + a.w > b.x and a.x < b.x + b.w and a.y + a.h > b.y and a.y < b.y + b.h
end

local function setPhase(name, player)
    Bat.phase = name
    if name == "hover" then
        Bat.phaseTimer = HOVER_TIME
    elseif name == "warn" then
        Bat.phaseTimer = WARN_TIME
    elseif name == "dive" then
        Bat.diveY = player.y + player.height - Bat.h - 4
    end
end

function Bat.start(playerX)
    Bat.active = true
    Bat.hp = 3
    Bat.w = 60
    Bat.h = 28
    Bat.t = 0
    Bat.hurtTimer = 0
    Bat.offset = 700
    Bat.x = playerX + Bat.offset
    Bat.y = HOVER_Y
    setPhase("hover")
end

function Bat.update(dt, player, roofs)
    Bat.t = Bat.t + dt
    Bat.hurtTimer = Bat.hurtTimer - dt

    if Bat.phase == "dive" then

        local speed = DIVE_SPEED + (3 - Bat.hp) * 100
        Bat.offset = Bat.offset - speed * dt
        Bat.y = Bat.y + (Bat.diveY - Bat.y) * math.min(1, 6 * dt)
        if Bat.offset < -300 then
            Bat.offset = 700
            setPhase("hover", player)
        end
    else
        Bat.phaseTimer = Bat.phaseTimer - dt
        local ease = math.min(1, 3 * dt)
        local bob = math.sin(Bat.t * 3) * 20
        Bat.offset = Bat.offset + (HOVER_OFFSET - Bat.offset) * ease
        Bat.y = Bat.y + (HOVER_Y + bob - Bat.y) * ease

        if Bat.phaseTimer <= 0 then
            if Bat.phase == "hover" then
                setPhase("warn", player)
            else
                setPhase("dive", player)
            end
        end
    end
    Bat.x = player.x + Bat.offset
    if Bat.phase == "warn" then
        Bat.x = Bat.x + love.math.random(-4, 4)
    end

    local cat = {
        x = player.x,
        y = player.y,
        w = player.width,
        h = player.height
    }
    local bat = {
        x = Bat.x,
        y = Bat.y,
        w = Bat.w,
        h = Bat.h
    }

    if Bat.phase == "dive" and Bat.hurtTimer <= 0 and overlaps(cat, bat) then

        local stomp = player.velocityY > 0 and player.y + player.height < Bat.y + Bat.h / 2 + 6
        if stomp then
            Bat.hp = Bat.hp - 1
            Bat.hurtTimer = 1.0
            player.velocityY = -450
            if Bat.hp <= 0 then
                Bat.active = false
                return "defeated"
            end
            setPhase("hover", player)
            return "bonk"
        else
            return "hit"
        end
    end
end

function Bat.draw()
    if not Bat.active then
        return
    end

    if Bat.hurtTimer > 0 and math.floor(love.timer.getTime() * 15) % 2 == 0 then
        return
    end

    local x, y = Bat.x, Bat.y
    local flapSpeed = 12
    if Bat.phase == "dive" then
        flapSpeed = 30
    end
    local flap = math.sin(Bat.t * flapSpeed) * 14

    love.graphics.setColor(0.3, 0.12, 0.35)
    love.graphics.polygon("fill", x + 20, y + 10, x - 30, y + flap, x + 5, y + 26)
    love.graphics.polygon("fill", x + 40, y + 10, x + 90, y + flap, x + 55, y + 26)

    love.graphics.setColor(0.4, 0.18, 0.45)
    love.graphics.ellipse("fill", x + 30, y + 15, 20, 15)
    love.graphics.polygon("fill", x + 18, y + 4, x + 22, y - 10, x + 27, y + 2)
    love.graphics.polygon("fill", x + 33, y + 2, x + 38, y - 10, x + 42, y + 4)

    if Bat.phase == "warn" and math.floor(Bat.t * 12) % 2 == 0 then
        love.graphics.setColor(1, 1, 0.3)
    else
        love.graphics.setColor(1, 0.15, 0.15)
    end
    love.graphics.rectangle("fill", x + 22, y + 10, 5, 5)
    love.graphics.rectangle("fill", x + 32, y + 10, 5, 5)

    love.graphics.setColor(1, 1, 1)
end
return Bat
