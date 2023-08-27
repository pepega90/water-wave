function Spring(x,y,targetLength, restLength, speed)
    return {
        x = x,
        y = y,
        targetLength = targetLength,
        restLength = restLength,
        speed = speed,

        update = function (self)
            local displacement = self.targetLength - self.restLength
            self.speed = self.speed + 0.01 * displacement - 0.025 * self.speed
            self.restLength = self.restLength + self.speed
        end
    }
end

return Spring