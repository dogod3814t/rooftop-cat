-- witch boss very evil much mwhahaha 
local Boss = {}
Boss.name = "WITCH.EXE"
Boss.label = "WITCH"

-- Witch tunes 

local ATTACK_TIME = 4.0
local TIRED_TIME = 4.0
local THROW_EVERY = 1.2
local POTION_GRAVITY = 500
local HIGH_Y = 110
local LOW_Y = 250
local FAR_OFFSET = 420
local NEAR_OFFSET = 160
local WINDUP_TIME = 0.8
local SWING_CENTER = 80
local SWING_SIZE = 130
local SWING_SPEED = 1.6

Boss.active = false

local function overlaps(a, b)
    return a.x + a.w > b.x and a.x < b.x + b.w and a.y + a.h > b.y and a.y < b.y + b.h
end

local function setPhase(name)
    Boss.phase = name
    if name == "attack" then
        Boss.phaseTimer = ATTACK_TIME
        Boss.throwTimer = 0.8
    elseif name == "windup" then
        Boss.phaseTimer = WINDUP_TIME
    else
        Boss.phaseTimer = TIRED_TIME
    end
end
--Boss rules 
function Boss.start(playerX)
    Boss.active = true
    Boss.hp = 3
    Boss.w = 50
    Boss.h = 60
    Boss.t = 0
    Boss.hurtTimer = 0
    Boss.offset = FAR_OFFSET
    Boss.x = playerX + Boss.offset
    Boss.y = HIGH_Y
    Boss.potions = {}
    setPhase("attack")
end

function Boss.update(dt, player, roofs)
    Boss.t = Boss.t + dt
    Boss.hurtTimer = Boss.hurtTimer - dt
    Boss.phaseTimer = Boss.phaseTimer - dt

    if Boss.phaseTimer <= 0 then
        if Boss.phase == "attack" then
            setPhase("windup")
        elseif Boss.phase == "windup" then
            setPhase("tired")
        else
            setPhase("attack")
        end
    end

    local targetY, targetOffset = HIGH_Y, FAR_OFFSET
    if Boss.phase == "tired" then
        targetY = LOW_Y
        targetOffset = SWING_CENTER + math.sin(Boss.t * SWING_SPEED) * SWING_SIZE
    end

    local ease = math.min(1, 3 * dt)
    local bob = math.sin(Boss.t * 2) * 15
    Boss.offset = Boss.offset + (targetOffset - Boss.offset) * ease
    Boss.y = Boss.y + (targetY + bob - Boss.y) * ease
    Boss.x = player.x + Boss.offset

    if Boss.phase == "windup" then
        Boss.x = Boss.x + love.math.random(-4, 4)
    end

    local cat = {
        x = player.x,
        y = player.y,
        w = player.width,
        h = player.height
    }
    local witch = {
        x = Boss.x,
        y = Boss.y - 25,
        w = Boss.w,
        h = Boss.h + 25
    }

    if Boss.phase == "tired" and Boss.hurtTimer <= 0 and overlaps(cat, witch) then
        Boss.hp = Boss.hp - 1
        Boss.hurtTimer = 1.0
        player.velocityY = -400
        if Boss.hp <= 0 then
            Boss.active = false
            Boss.potions = {}
            return "defeated"
        end
        setPhase("attack")
        return "bonk"
    end

    if Boss.phase == "attack" then
        Boss.throwTimer = Boss.throwTimer - dt
        if Boss.throwTimer <= 0 then
            Boss.throwTimer = THROW_EVERY
            table.insert(Boss.potions, {
                x = Boss.x + 20,
                y = Boss.y + 30,
                w = 14,
                h = 16,
                vx = player.speed - 250,
                vy = -150
            })
        end
    end
    for i = #Boss.potions, 1, -1 do
        local p = Boss.potions[i]
        p.vy = p.vy + POTION_GRAVITY * dt
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt

        local gone = p.y > 650

        for _, roof in ipairs(roofs) do
            if p.x + p.w > roof.x and p.x < roof.x + roof.w and p.y + p.h >= roof.y then
                gone = true
            end
        end

        if overlaps(p, cat) then
            return "hit"
        end

        if gone then
            table.remove(Boss.potions, i)
        end
    end
end

function Boss.draw()
    if not Boss.active then
        return
    end

    for _, p in ipairs(Boss.potions) do
        love.graphics.setColor(0.3, 0.9, 0.3)
        love.graphics.circle("fill", p.x + 7, p.y + 10, 7)
        love.graphics.setColor(0.6, 0.6, 0.65)
        love.graphics.rectangle("fill", p.x + 5, p.y, 4, 5)
    end

    if Boss.hurtTimer > 0 and math.floor(love.timer.getTime() * 15) % 2 == 0 then
        love.graphics.setColor(1, 1, 1)
        return
    end

    love.graphics.setColor(0.55, 0.35, 0.15)
    love.graphics.rectangle("fill", Boss.x - 15, Boss.y + 50, 80, 5)
    love.graphics.setColor(0.9, 0.75, 0.3)
    love.graphics.rectangle("fill", Boss.x + 60, Boss.y + 44, 18, 16)

    if Boss.phase == "windup" and math.floor(Boss.t * 12) % 2 == 0 then
        love.graphics.setColor(1, 0.6, 0.2)
    else
        love.graphics.setColor(0.4, 0.1, 0.5)
    end
    love.graphics.polygon("fill", Boss.x + 25, Boss.y + 15, Boss.x + 5, Boss.y + 52, Boss.x + 45, Boss.y + 52)

    love.graphics.setColor(0.45, 0.8, 0.35)
    love.graphics.circle("fill", Boss.x + 25, Boss.y + 14, 10)

    love.graphics.setColor(0.1, 0.05, 0.15)
    love.graphics.polygon("fill", Boss.x + 10, Boss.y + 8, Boss.x + 40, Boss.y + 8, Boss.x + 18, Boss.y - 25)

    if Boss.phase == "windup" then
        love.graphics.setColor(1, 0.9, 0.3)
        love.graphics.rectangle("fill", Boss.x + 22, Boss.y - 60, 6, 18)
        love.graphics.rectangle("fill", Boss.x + 22, Boss.y - 38, 6, 6)
    end

    if Boss.phase == "tired" then
        love.graphics.setColor(1, 0.9, 0.3)
        for k = 0, 2 do
            local a = Boss.t * 4 + k * 2.1
            love.graphics.circle("fill", Boss.x + 25 + math.cos(a) * 22, Boss.y - 32 + math.sin(a) * 6, 3)
        end
    end

    love.graphics.setColor(1, 1, 1)
end

return Boss
