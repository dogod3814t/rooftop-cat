local Boss = {}

Boss.active = false 

local function overlaps(a, b)
    return a.x + a.w > b.x and a.x < b.x + b.w
    and a.y + a.h > b.y and a.y < b.y + b.h 
end


function Boss.start(playerX)
    Boss.active = true
    Boss.hp = 3
    Boss.x = playerX + 450
    Boss.baseY = 120
    Boss.y = Boss.baseY
    Boss.w = 50 
    Boss.h = 60 
    Boss.t = 0 
    Boss.hurtTimer = 0
    Boss.throwTimer = 1.5
    Boss.potions = {}
end


function Boss.update(dt, player, roofs)
    Boss.t = Boss.t + dt 
    Boss.hurtTimer = Boss.hurtTimer -dt



    local offset = 260 + math.sin(Boss.t * 0.8) * 230
    Boss.x = player.x + offset 
    Boss.y = Boss.baseY + math.sin(Boss.t * 2) * 30

    local cat = { x = player.x, y = player.y, w = player.width, h = player.height }
    local witch = { x = Boss.x, y = Boss.y -25, w = Boss.w, h = Boss.h + 25}

    if Boss.hurtTimer <= 0 and overlaps(cat, witch) then
        if player.onBroom then
            Boss.hp = Boss.hp - 1 
Boss.hurtTimer = 1.0 
player.velocityY = 300 
if Boss.hp <= 0 then
    Boss.active = false 
    Boss.potions = {}
    return "defeated"
end
return "bonk"
else
    return "hit"
end
end

Boss.throwTimer = Boss.throwTimer - dt
if Boss.throwTimer <= 0 then 
    Boss.throwTimer = 1.0 + Boss.hp * 0.3 
    table.insert(Boss.potions, {
x = Boss.x + 20,
y = Boss.y + 30, 
w = 14, 
h = 16,
vx = player.speed - 250, 
vy = -150, 
    })
end


for i = #Boss.potions, 1, -1 do
local p = Boss.potions[i]
p.vy = p.vy + 600 * dt
p.x = p.x + p.vx * dt 
p.y = p.y + p.vy * dt 

local gone = p.y > 650 

for _, roof in ipairs(roofs) do 
    if p.x + p.w > roof.x and p.x < roof.x + roof.w and p.y + p.h >= roof.y then
        gone = true
    end
end

if overlaps( p, cat) then
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

love.graphics.setColor(0.4, 0.1, 0.5)
love.graphics.polygon("fill", Boss.x + 25, Boss.y + 15, Boss.x + 5, Boss.y + 52, Boss.x + 45, Boss.y + 52)

love.graphics.setColor(0.45, 0.8, 0.35)
love.graphics.circle("fill", Boss.x + 25, Boss.y + 14, 10)


love.graphics.setColor(0.1, 0.05, 0.15)
love.graphics.polygon("fill", Boss.x + 10, Boss.y + 8, Boss.x + 40, Boss.y + 8, Boss.x + 18, Boss.y - 25)

love.graphics.setColor(1, 1, 1)
end

return Boss
