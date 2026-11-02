local Sfx = {}

local RATE = 22050
-- rules for how sound is generated
local function makeBeep(startFreq, endFreq, duration, wave, volume)
    local samples = math.floor(RATE * duration)
    local data = love.sound.newSoundData(samples, RATE, 16, 1)
    local phase = 0

    for i = 0, samples - 1 do
        local t = i / samples
        local freq = startFreq + (endFreq - startFreq) * t
        phase = phase + freq / RATE
        local value
        if wave == "noise" then
            value = love.math.random() * 2 - 1
        elseif phase % 1 < 0.5 then
            value = 1
        else
            value = -1
        end

        local fade = 1 - t
        data:setSample(i, value * fade * volume)
    end

    return love.audio.newSource(data, "static")
end
-- funny sounds basically a profesional soundtrack 
function Sfx.load()
    Sfx.jump = makeBeep(300, 600, 0.12, "square", 0.25)
    Sfx.flap = makeBeep(500, 900, 0.08, "square", 0.2)
    Sfx.pumpkin = makeBeep(900, 1400, 0.08, "square", 0.2)
    Sfx.pickup = makeBeep(400, 1200, 0.3, "square", 0.25)
    Sfx.bonk = makeBeep(200, 80, 0.15, "noise", 0.35)
    Sfx.death = makeBeep(400, 60, 0.6, "square", 0.3)
    Sfx.boss = makeBeep(120, 240, 0.5, "square", 0.3)
end

function Sfx.play(name)
    local s = Sfx[name]
    if s then
        s:stop()
        s:play()
    end
end
return Sfx
