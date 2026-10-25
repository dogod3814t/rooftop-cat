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












function love.keypressed(key)
    if key == "space" and not player.isJumping then
        player.velocityY = -550
        player.isJumping = true
    end
end
function love.keyreleased(key)
    if key == "space" and player.isJumping then
        if player.velocityY < -300 then
            player.velocityY = -300
        end
    end
end

function spawnRoof()
  local gap = love.math.random(80, 160)
  local w = love.math.random(200, 450)
  local y = lastRoofY + love.math.random(-60, 60)
  y = math.max(300, math.min(450, y))
  local x = lastRoofEnd + gap
  table.insert(roofs, { x = x, y = y, w = w })
  lastRoofEnd = x + w
  lastRoofY = y
end


function love.update(dt)
 player.speed = math.min(maxSpeed, player.speed + speedGain * dt)
 
 
    local prevbottom = player.y + player.height
 
    player.x = player.x + player.speed * dt
  
  local g = gravity
if math.abs(player.velocityY) < 150 then
  g = gravity * 0.4
end
player.velocityY = player.velocityY + g * dt

    player.y = player.y + player.velocityY * dt

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
while lastRoofEnd < player.x + 1000 do
spawnRoof ()
end 
for i = #roofs, 1, -1 do
  if roofs[i].x + roofs[i].w < player.x - 300 then
    table.remove(roofs, i)
  end
end


if player.y > 600 
then 
    resetPlayer() 

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
        animFrame=1
    end 
end



end

function resetPlayer()
  player.x = 100
  player.y = 300
  player.velocityY = 0
  player.isJumping = false
player.speed = startSpeed 
 
 
  roofs = { { x = 0, y = 400, w = 600 } }
  lastRoofEnd = 600
  lastRoofY = 400
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
 




  
  
  
  
  
  
  font = love.graphics.newFont(24)
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

resetPlayer ()

end
    



function love.draw()
love.graphics.clear(0.1, 0.12, 0.25)
    love.graphics.push()
love.graphics.translate(-(player.x-150 ), 0)  



love.graphics.setColor(0.25, 0.25, 0.3)

for _, roof in ipairs(roofs) do
  love.graphics.rectangle("fill", roof.x, roof.y, roof.w, 600 - roof.y)
end
love.graphics.setColor(1, 1, 1)

local drawX = player.x + player.width / 2 - 32
  local drawY = player.y + player.height - 64

if player.isJumping then
love.graphics.draw(catjump, jumpFrame, drawX, drawY)

else love.graphics.draw(catrun, runFrames[animFrame], drawX, drawY)
end

love.graphics.pop()

love.graphics.setFont(font)
love.graphics.print(score .. " m", 16, 12)
love.graphics.print("best: " .. best .. " m", 16, 44)
 

end