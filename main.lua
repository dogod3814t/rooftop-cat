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

function love.update(dt)
  player.x = player.x + player.speed * dt
  
  local g = gravity
if math.abs(player.velocityY) < 150 then
  g = gravity * 0.5
end
player.velocityY = player.velocityY + g * dt

    player.y = player.y + player.velocityY * dt

    if player.y + player.height > floorY then
        player.y = floorY - player.height
        player.velocityY = 0
        player.isJumping = false
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



function love.load()
  player = {
    x = 100,
    y = floorY - 100,
    width = 50,
    height = 50,
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
end
    



function love.draw()
love.graphics.clear(0.1, 0.12, 0.25)
    love.graphics.push()
love.graphics.translate(-(player.x-150 ), 0)  



love.graphics.setColor(1, 0, 0)
for i = 0, 100 do
    love.graphics.rectangle("fill", i * 100, floorY -10, 50, 10)

end
love.graphics.setColor(1, 1, 1)

love.graphics.rectangle("fill", 0, floorY, 100000000, 600 - floorY)
love.graphics.rectangle("line", player.x, player.y, player.width, player.height)

  local drawX = player.x + player.width / 2 - 32
  local drawY = player.y + player.height - 64


  love.graphics.draw(catrun, runFrames[animFrame], drawX, drawY)


love.graphics.pop()

love.graphics.setFont(font)
love.graphics.print(score .. " m", 16, 12)
love.graphics.print("best: " .. best .. " m", 16, 44)


end