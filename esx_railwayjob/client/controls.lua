-- controls.lua
-- Gestion fine du throttle / brake pour un pilotage réaliste
local throttle = 0.0
local targetSpeed = 0.0
local maxAllowedSpeed = 30.0 -- m/s approx (ajustable par type)

function UpdateTrainPhysics(dt)
    if not currentTrain or not isInService then return end

    -- lerp vers targetSpeed en fonction de l'accélération
    local acc = Config.Realism.Acceleration
    local brk = Config.Realism.Brake

    if targetSpeed > currentSpeed then
        currentSpeed = math.min(currentSpeed + acc * dt, targetSpeed)
    elseif targetSpeed < currentSpeed then
        currentSpeed = math.max(currentSpeed - brk * dt, targetSpeed)
    end

    -- appliquer la vitesse
    SetTrainSpeed(currentTrain, currentSpeed)
end

CreateThread(function()
    local prev = GetGameTimer()
    while true do
        local now = GetGameTimer()
        local dt = (now - prev) / 1000.0
        prev = now

        if currentTrain and isInService then
            -- Touche accélérer
            if IsControlPressed(0, 71) then -- W
                targetSpeed = math.min(targetSpeed + 0.5, maxAllowedSpeed)
            end

            -- Touche ralentir
            if IsControlPressed(0, 72) then -- S
                targetSpeed = math.max(targetSpeed - 0.7, 0.0)
            end

            -- Emergency Brake (space)
            if IsControlJustPressed(0, 22) then
                targetSpeed = 0.0
                currentSpeed = math.max(0.0, currentSpeed - Config.Realism.EmergencyBrake)
            end

            UpdateTrainPhysics(dt)
        end

        Wait(50)
    end
end)
