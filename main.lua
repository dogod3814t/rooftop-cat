local floorY=400
local gravity = 1500
local player 
local score =0
local best =0
local font 
local catrun
local runFrames
local animTimer = 0
local animFrame = 1
local catjump 
local jumpFrame 
local roofs
local resetPlayer 
local lastRoofEnd
local lastRoofY 
local spawnRoof
local startSpeed = 200
local maxSpeed = 650 
local speedGain = 8
local state = "title"
local bigFont 
local chimmneys 
local brooms
local skyline
local stars
local COYOTE_TIME = 0.1
local BUFFER_TIME = 0.1
local coyoteTimer = 0
local bufferTimer = 0
local catSat
local satFrames
local catHurt
local hurtFrame
local dust




function love.keypressed(key)
  if key ~= "space" then return end

  if state == "play" then
    if player.onBroom then
      player.velocityY = -350
      player.flaps = player.flaps - 1
      if player.flaps <= 0 then
        player.onBroom = false
      end
    else
      bufferTimer = BUFFER_TIME
    end
  else
    resetPlayer()
    state = "play"
  end
end
function love.keyreleased(key)
  if key == "space" and player.isJumping and not player.onBroom then
    if player.velocityY < -300 then
      player.velocityY = -300
    end
  end
end

function spawnRoof()
local minGap = 60 + player.speed * 0.15
  local maxGap = 100 + player.speed * 0.3
  local gap = love.math.random(math.floor(minGap), math.floor(maxGap))
  local w = love.math.random(200, 450)
  local y = lastRoofY + love.math.random(-60, 60)
  y = math.max(300, math.min(450, y))
  local x = lastRoofEnd + gap
  table.insert(roofs, { x = x, y = y, w = w })
  lastRoofEnd = x + w
  lastRoofY = y

 


 
 
  if love.math.random () < 0.5 then 
    local cw = 24
    local ch = love.math.random(30,50)
    local cx = love.math.random(x + 80, x + w - 80 -cw)
    table.insert(chimmneys, {x = cx, y = y - ch, w = cw, h = ch})
  end
if x > 3000 and love.math.random () < 0.15 then 
    table.insert(brooms, {x = x + w / 2 - 12, y = y - 90, w = 24, h = 24 })
    end 
end
    function love.update(dt)
 if state ~= "play" then 
    return
 end
 
 
    player.speed = math.min(maxSpeed, player.speed + speedGain * dt)
 
 
    local prevbottom = player.y + player.height
 
    player.x = player.x + player.speed * dt
  
  local g = gravity
if math.abs(player.velocityY) < 150 then
  g = gravity * 0.4
end
if player.onBroom then
  g = 900
end
player.velocityY = player.velocityY + g * dt
 
player.y = player.y + player.velocityY * dt

 if player.y < 20 then
  player.y = 20 
  player.velocityY = 0
end



   local wasInAir = player.isJumping

    player.isJumping = true
   for _, roof in ipairs(roofs ) do
local overRoof = player.x + player.width > roof.x and player.x < roof.x +roof.w
local falling = player.velocityY >= 0
local crossedTop = prevbottom <= roof.y and player.y + player.height  >= roof.y

if overRoof and falling and crossedTop then 
player.y = roof.y - player.height
player.velocityY = 0
player.isJumping = false
   end
end

if wasInAir and not player.isJumping then
  player.sx, player.sy = 1.3, 0.7
  for i = 1, 8 do
  table.insert(dust, {
x = player.x + player.width / 2,
y = player.y + player.height,
vx = love.math.random (-80, 80),
vy = love.math.random (-120, -30),
life = 0.4,

  })
  end
end



if not player.isJumping then 
  coyoteTimer = COYOTE_TIME
 else
  coyoteTimer = coyoteTimer - dt
 end 

bufferTimer = bufferTimer - dt

if bufferTimer > 0 and coyoteTimer > 0 and not player.onBroom then
  player.velocityY = -550 

  player.isJumping = true
  bufferTimer = 0
  coyoteTimer = 0
player.sx, player.sy = 0.75, 1.25

end









for _, c in ipairs(chimmneys) do
  local hit = player.x + player.width > c.x
          and player.x < c.x + c.w
          and player.y + player.height > c.y
          and player.y < c.y + c.h
  if hit then
    state = "dead"
  end
end
for i = #brooms, 1, -1 do 
  local b = brooms[i]
  local hit = player.x + player.width > b.x 
  and player.x < b.x +b.w 
  and player.y + player.height > b.y
  and player.y < b.y + b.h 

  if hit then
    table.remove(brooms, i)
    player.onBroom = true
    player.flaps = 3
  end
  end



while lastRoofEnd < player.x + 1000 do
spawnRoof ()
end 
for i = #roofs, 1, -1 do
  if roofs[i].x + roofs[i].w < player.x - 300 then
    table.remove(roofs, i)
  end
end
for i = #chimmneys, 1, -1 do
  if chimmneys[i].x + chimmneys[i].w < player.x - 300 then
    table.remove(chimmneys, i)
  end
end

for i = #brooms, 1, -1 do
  if brooms[i].x + brooms[i].w < player.x - 300 then
    table.remove(brooms, i)
  end
end

if player.y > 600 
then 
    state = "dead"

end
    

    score = math.floor((player.x -100) /10)
    if score > best then
        best = score
    end

animTimer = animTimer + dt
if animTimer > 0.15 then
  animTimer = 0
  animFrame = animFrame + 1
  if animFrame > 2 then
    animFrame = 1
  end
end

player.sx = player.sx + (1 - player.sx) * math.min(1, 12 * dt)
player.sy = player.sy + (1 - player.sy) * math.min(1, 12 * dt)
for i = #dust, 1, -1 do
local p =dust[i]
p.x = p.x +p.vx * dt
p.y = p.y + p.vy * dt
p.vy = p.vy + 400 * dt 
p.life = p.life - dt
if p.life <= 0 then
  table.remove (dust,i)
end
end


end

function resetPlayer()
  player.x = 100
  player.y = 300
  player.velocityY = 0
  player.isJumping = false
player.speed = startSpeed 
 player.sx = 1
 player.sy = 1
 
  roofs = { { x = 0, y = 400, w = 600 } }
  lastRoofEnd = 600
  lastRoofY = 400

  chimmneys = {}
  brooms = {}
  player.onBroom = false
  player.flaps = 0

coyoteTimer = 0
bufferTimer = 0
dust = {}
end


function love.load()
  player = {
    x = 100,
    y = floorY - 100,
    width = 40,
    height = 40,
    speed = 200,
    velocityY = 0,
    isJumping = false
  }
 
skyline = {}
for i = 0, 20 do
table.insert(skyline, {
x = i * 80,
w = love.math.random(50, 90),
h = love.math.random(80, 200),
})
end
stars = {}
for i = 1, 40 do
table.insert(stars, {
x = love.math.random(0,800),
y = love.math.random(0, 350),
phase = love.math.random() * 6,
})
end


  
  
  
  
  
  
  font = love.graphics.newFont(24)
  bigFont = love.graphics.newFont(48)

  love.graphics.setDefaultFilter("nearest", "nearest")
catrun = love.graphics.newImage("assets/Sheet_Cat_Run.png")
local w, h= catrun:getDimensions()
 runFrames = {
love.graphics.newQuad(0, 0, 64, 64, w, h),
love.graphics.newQuad(64, 0, 64, 64, w, h),
 }
catjump = love.graphics.newImage("assets/Sheet_Cat_Jump.png")
local jw, jh = catjump:getDimensions()
jumpFrame = love.graphics.newQuad(64,0, 64, 64, jw, jh)


catSat = love.graphics.newImage("assets/Sheet_Cat_Sat.png")
local sw, sh = catSat:getDimensions()
satFrames = {
love.graphics.newQuad(0, 0, 64, 64, sw, sh),
love.graphics.newQuad(64, 0, 64, 64, sw, sh),



}
catHurt = love.graphics.newImage("assets/Sheet_Cat_Hurt.png")
local hw, hh = catHurt:getDimensions()
hurtFrame = love.graphics.newQuad( 64, 0, 64, 64, hw, hh)


resetPlayer ()

end
    



function love.draw()
love.graphics.clear(0.1, 0.12, 0.25)
    love.graphics.push()


   for _, s in ipairs(stars) do
  local a = 0.5 + 0.5 * math.sin(love.timer.getTime() * 2 + s.phase)
  love.graphics.setColor(1, 1, 0.8, a)
  love.graphics.rectangle("fill", s.x, s.y, 2, 2)
end
love.graphics.setColor(0.95, 0.92, 0.8)
love.graphics.circle("fill", 650, 110, 50)

love.graphics.setColor(0.15, 0.16, 0.3)
local offset = (player.x * 0.2) % 1600
for _, b in ipairs(skyline) do 
  local bx = b.x - offset
  if bx < -100 then bx = bx + 1600 end
  love.graphics.rectangle("fill", bx, 600 - b.h, b.w, b.h)
end
love.graphics.setColor(1, 1, 1)
  
  
  love.graphics.translate(-(player.x-150 ), 0)  



love.graphics.setColor(0.25, 0.25, 0.3)

for _, roof in ipairs(roofs) do
  love.graphics.rectangle("fill", roof.x, roof.y, roof.w, 600 - roof.y)
end

love.graphics.setColor(0.6, 0.25, 0.2)
for _, c in ipairs(chimmneys) do
  love.graphics.rectangle("fill", c.x, c.y, c.w, c.h)
end
for _, b in ipairs(brooms) do 
    love.graphics.setColor(0.55, 0.35, 0.15)
    love.graphics.rectangle("fill", b.x, b.y + 10, 24, 4)
    love.graphics.setColor(0.9, 0.75, 0.3)
    love.graphics.rectangle("fill", b.x + 16, b.y + 6, 8, 12)
end
love.graphics.setColor(1, 1, 1)

for _, p in ipairs(dust) do 
  love.graphics.setColor(0.8, 0.8, 0.85, p.life /0.4)
  love.graphics.rectangle("fill", p.x, p.y, 3, 3)
end 
love.graphics.setColor(1, 1, 1)





local drawX = player.x + player.width / 2 - 32
  local drawY = player.y + player.height - 64

  local footX = player.x + player.width / 2
  local footY = player.y + player.height
local flicker = player.onBroom
and player.flaps == 1
and math.floor(love.timer.getTime() * 10) % 2 == 0

if player.onBroom and not flicker then
  local bx = player.x - 8
  local by = player.y + player.height - 6
    love.graphics.setColor(0.55, 0.35, 0.15)
  love.graphics.rectangle("fill", bx, by, 56, 4)
  love.graphics.setColor(0.9, 0.75, 0.3)
  love.graphics.rectangle("fill", bx - 10, by - 4, 12, 12)
  love.graphics.setColor(1, 1, 1)
end

if not flicker then
  if player.isJumping then
    love.graphics.draw(catjump, jumpFrame, footX, footY, 0, player.sx, player.sy, 32, 64)
  else
    love.graphics.draw(catrun, runFrames[animFrame], footX, footY, 0, player.sx, player.sy, 32, 64)
  end
end
love.graphics.pop()
if player.onBroom then
  love.graphics.setFont(font)
love.graphics.print("BROOM x" .. player.flaps, 16, 76)
end




love.graphics.setFont(font)
love.graphics.print(score .. " m", 16, 12)
love.graphics.print("best: " .. best .. " m", 16, 44)
 
if state ~= "play" then 
    love.graphics.setColor (0, 0, 0, 0.5)
love.graphics.rectangle ("fill", 0, 0, 800, 600)
love.graphics.setColor(1, 1, 1)
  if state == "title" then
local f = math.floor(love.timer.getTime() * 2) % 2 + 1
    love.graphics.draw(catSat, satFrames[2], 400, 215, 0, 2, 2, 32, 64)
    love.graphics.setFont(bigFont)
    love.graphics.printf("ROOFTOP CAT", 0, 220, 800, "center")
    love.graphics.setFont(font)
    love.graphics.printf("Press space to start", 0, 300, 800, "center")
  else
   love.graphics.draw(catHurt, hurtFrame, 400, 195, 0, 2, 2, 32, 64)
    love.graphics.setFont(bigFont)
    love.graphics.printf("You didn't save Halloween", 0, 200, 800, "center")
    love.graphics.setFont(font)
    love.graphics.printf(score .. " m", 0, 270, 800, "center")
    love.graphics.printf("Press space to retry", 0, 310, 800, "center")
  end
end 
end   