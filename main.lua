local floorY=400
local gravity = 1500
local player 



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
end
    



function love.draw()
love.graphics.push()
love.graphics.translate(-(player.x-150 ), 0)  



love.graphics.setColor(1, 0, 0)
for i = 0, 100 do
    love.graphics.rectangle("fill", i * 100, floorY -10, 50, 10)

end
love.graphics.setColor(1, 1, 1)

love.graphics.rectangle("fill", 0, floorY, 100000000, 600 - floorY)
love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)



love.graphics.pop()
end