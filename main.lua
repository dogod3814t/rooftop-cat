local floorY=400
local gravity = 2000
local player 


function love.update(dt)
    player.velocityY = player.velocityY + gravity * dt
    player.y = player.y + player.velocityY * dt

    if player.y + player.height > floorY then
        player.y = floorY - player.height
        player.velocityY = 0
        player.isJumping = false
    end

    if love.keyboard.isDown("space") and not player.isJumping then
        player.velocityY = -600
        player.isJumping = true
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
  love.graphics.rectangle("fill", 0, floorY, 800, 600 - floorY)
love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)

end