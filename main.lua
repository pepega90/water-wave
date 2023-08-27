WIDTH = 640
HEIGHT = 480

spread = 0.25
waveNum = 28

require("spring")

function love.load() 
    love.window.setMode(WIDTH, HEIGHT)
    love.window.setTitle("Water Simulation")

    -- load assets
    img = {}
    img.sky = love.graphics.newImage("assets/sky.png")
    img.rock = love.graphics.newImage("assets/rock.png")

    -- game variabel
    rocks = {} -- list batu
    springs = {} -- list spring
    lDelta = {} -- list spring yang kiri
    rDelta = {} -- list spring yang kanan
    
    -- initiate awal-awal spring
    for i = 1, waveNum, 1 do
        local x = math.ceil(WIDTH/WIDTH) * i * 25 - 25
        local y = HEIGHT  - 200

        local s = Spring(x,y,HEIGHT - y, HEIGHT - y, 10)
        table.insert(springs, s)
    end
end

function love.update(dt)
    -- update spring, di function update pada dasarnya kalkulasi hukum hooke, yang rumusnya
    -- F = -k * x
    -- F = gaya pegas
    -- k = konstanta untuk memberikan seberapa "pegas" gayanya
    -- x = perpindahan posisi dari pegas mula-mula (sebelum di tarik), ke posisi yang sudah di tarik
    for i = 1, #springs, 1 do
        springs[i]:update()
    end

    -- kode di bawah, sebenernya mirip seperti method update() pada spring, jadi di variabel table lDelta dan rDelta
    -- pada dasarnya kita berikan valuenya juga dengan hukum hooke, yang dimana speednya itu kita buat berbeda
    -- jadi nantinya antara index di variabel lDelta dan rDelta itu akan bertemu, yang memberikan efek seperti air
    -- ()-()-() <- misal ini dari lDelta () misal ini dari rDelta -> ()-()-()
    --                                    ^
    --                                    |
    -- jadi antara lDelta dan rDelta saling tarik, yang membuat spring di tengah itu seperti air
    for i = 1, #springs, 1 do
        if i > 1 then
            lDelta[i] = spread * (springs[i].restLength - springs[i - 1].restLength);
			springs[i - 1].speed = springs[i - 1].speed + lDelta[i];
        end

        if i < #springs - 1 then
            rDelta[i] = spread * (springs[i].restLength - springs[i + 1].restLength);
			springs[i + 1].speed = springs[i + 1].speed + rDelta[i];
        end
    end

    -- nah disini kita apply deh restLength nya ke restLength spring lalu di tambah dengan value dari lDelta untuk bagian kiri dan rDelta untuk bagian kanan
    for i = 1, #springs, 1 do
        if i > 1 then
            springs[i - 1].restLength = springs[i - 1].restLength + lDelta[i];
        end

        if i < #springs - 1 then
            springs[i + 1].restLength = springs[i + 1].restLength + rDelta[i];
        end

        springs[i].y = HEIGHT - springs[i].restLength;
    end

    for _, value in ipairs(rocks) do
        value.y = value.y + 500 * dt
    end

    for i = #rocks, 1, -1 do
        local spring = rocks[i]
        if spring.y > HEIGHT then
            table.remove(rocks, i)
        end
    end
end

function love.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.draw(img.sky, 0, -100)

    for _, value in ipairs(rocks) do
        love.graphics.draw(img.rock, value.x, value.y)
    end

    love.graphics.setColor(toRGB(3, 119, 252))
    for i = 1, #springs, 1 do
        if i < #springs - 1 then
            love.graphics.setLineWidth(10)
            love.graphics.line(springs[i].x,springs[i].y, springs[i+1].x, springs[i+1].y)
            love.graphics.setLineWidth(25)
            love.graphics.line(springs[i].x, springs[i].y, springs[i].x, HEIGHT)
            love.graphics.line(springs[i+1].x, springs[i+1].y, springs[i+1].x, HEIGHT)
            if #rocks > 0 then
                if checkCollisionCircleLine(rocks[1].x, rocks[1].y, rocks[1].radius, springs[i].x,springs[i].y, springs[i+1].x, springs[i+1].y) then
                    springs[i].speed = 45;
                end
            end
        end
    end

    -- -- draw mouse position untuk utility
    -- love.graphics.print("mouse x = " .. love.mouse.getX(), 10, 10)  
    -- love.graphics.print("mouse y = " .. love.mouse.getY(), 10, 40)
end

function checkCollisionCircleLine(cx, cy, radius, x1, y1, x2, y2)
    local closestX = math.max(x1, math.min(cx, x2))
    local closestY = math.max(y1, math.min(cy, y2))
  
    local distanceX = cx - closestX
    local distanceY = cy - closestY
    local distanceSquared = distanceX * distanceX + distanceY * distanceY
  
    return distanceSquared <= radius * radius
  end

function addRock(mx,my)
    r = {
        x = mx,
        y = my,
        radius = 15,
    }

    table.insert(rocks, r)
end

function toRGB(r,g,b)
    return r/255, g/255, b/255
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
       love.event.quit()
    end
 end

function love.mousepressed( x, y, button, istouch, presses )
    if button == 1 then
        springs[math.random(1, #springs - 1)].speed = 50;
    elseif button == 2 then
        addRock(x,y)
    end
end