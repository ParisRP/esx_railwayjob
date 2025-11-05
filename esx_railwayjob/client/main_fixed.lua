-- Main client file for esx_railwayjob
local isInService = false
local currentTrain = nil
local attachedWagons = {}
local currentSpeed = 0.0
local targetSpeed = 0.0
local maxSpeed = 30.0

-- Train configuration
local trainConfigs = {
    metro = {
        trainIndex = 24,    -- Train type index for metro
        maxSpeed = 22.0
    },
    freight = {
        trainIndex = 25,    -- Train type index for freight
        maxSpeed = 28.0
    }
}

-- Known working train configurations
local trainPresets = {
    freight = {
        name = "freight",
        trainType = 25,
        maxSpeed = 28.0,
        carriageHash = 1030400667
    },
    metro = {
        name = "metrotrain",
        trainType = 24,
        maxSpeed = 22.0,
        carriageHash = 868868440
    }
}

-- Helper function to ensure models are loaded
local function EnsureModelLoaded(modelHash)
    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
        local timeoutTimer = GetGameTimer() + 10000
        while not HasModelLoaded(modelHash) do
            Wait(100)
            if GetGameTimer() > timeoutTimer then
                return false
            end
        end
    end
    return true
end

function SpawnTrain(modelName, vtype)
    if currentTrain then
        ESX.ShowNotification('Vous avez déjà un train en service')
        return
    end

    -- Get preset configuration
    local preset = trainPresets[vtype or 'freight']
    if not preset then
        ESX.ShowNotification('Type de train invalide')
        return
    end

    -- Ensure model is loaded
    if not EnsureModelLoaded(preset.carriageHash) then
        ESX.ShowNotification('Impossible de charger le modèle du train')
        return
    end

    -- Get spawn coordinates
    local spawn = Config.Zones.VehicleSpawner.Pos

    -- Create the train using preset configuration
    currentTrain = CreateMissionTrain(preset.trainType, spawn.x, spawn.y, spawn.z, true)
    
    if not DoesEntityExist(currentTrain) then
        ESX.ShowNotification('Échec de création du train')
        return
    end

    -- Setup train
    SetEntityAsMissionEntity(currentTrain, true, true)
    SetTrainSpeed(currentTrain, 0.0)
    currentSpeed = 0.0
    targetSpeed = 0.0
    maxSpeed = preset.maxSpeed

    -- Put player in driver seat
    TaskWarpPedIntoVehicle(PlayerPedId(), currentTrain, -1)
    ESX.ShowNotification('Train créé sur les rails\nUtilisez W/S pour accélérer/freiner')
end

function AttachWagon(wagonModel)
    if not currentTrain then
        ESX.ShowNotification('Vous devez d\'abord créer une locomotive')
        return
    end

    -- Default to freight carriage if model not found
    local carriageHash = GetHashKey(wagonModel)
    if not EnsureModelLoaded(carriageHash) then
        carriageHash = GetHashKey('freightcar')
        if not EnsureModelLoaded(carriageHash) then
            ESX.ShowNotification('Impossible de charger le modèle du wagon')
            return
        end
    end

    -- Calculate position behind train
    local trainCoords = GetEntityCoords(currentTrain)
    local trainHeading = GetEntityHeading(currentTrain)
    local wagonCount = #attachedWagons
    local spacing = Config.Realism.WagonSpacing or 11.5
    local offset = -(wagonCount + 1) * spacing

    -- Create wagon as a mission train
    local wagon = CreateMissionTrain(21, -- Use type 21 for freight cars
        trainCoords.x + (math.sin(math.rad(-trainHeading)) * offset),
        trainCoords.y + (math.cos(math.rad(-trainHeading)) * offset),
        trainCoords.z,
        true)

    if not DoesEntityExist(wagon) then
        ESX.ShowNotification('Échec de création du wagon')
        return
    end

    -- Setup wagon
    SetEntityAsMissionEntity(wagon, true, true)
    SetTrainSpeed(wagon, 0.0)
    
    -- Attach to train
    AttachEntityToEntity(wagon, currentTrain, 0,
        0.0, offset, 0.0,     -- Offset X, Y, Z
        0.0, 0.0, 0.0,        -- Rotation
        false, false, true,    -- Options
        0, true)              -- Rotation order, rigid

    -- Add to wagon list
    table.insert(attachedWagons, wagon)
    ESX.ShowNotification('Wagon attaché avec succès')
end

-- Controls thread - check for player input
CreateThread(function()
    while true do
        local sleep = 500

        if currentTrain and isInService then
            sleep = 0
            
            -- Acceleration
            if IsControlPressed(0, Config.Controls.START_STOP) then -- W
                if currentSpeed < maxSpeed then
                    currentSpeed = currentSpeed + Config.Realism.Acceleration
                    SetTrainSpeed(currentTrain, currentSpeed)
                end
            end

            -- Braking
            if IsControlPressed(0, Config.Controls.SPEED_UP) then -- S
                if currentSpeed > 0.0 then
                    currentSpeed = math.max(0.0, currentSpeed - Config.Realism.Brake)
                    SetTrainSpeed(currentTrain, currentSpeed)
                end
            end

            -- Emergency brake
            if IsControlJustPressed(0, 22) then -- Space
                currentSpeed = 0.0
                SetTrainSpeed(currentTrain, 0.0)
            end

            -- Horn
            if IsControlJustPressed(0, Config.Controls.HORN) then
                if DoesEntityExist(currentTrain) then
                    StartVehicleHorn(currentTrain, 1000, GetHashKey('HELDDOWN'), false)
                end
            end
        end

        Wait(sleep)
    end
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if currentTrain and DoesEntityExist(currentTrain) then
            SetEntityAsMissionEntity(currentTrain, false, false)
            DeleteMissionTrain(currentTrain)
            currentTrain = nil
        end

        for _, wagon in ipairs(attachedWagons) do
            if DoesEntityExist(wagon) then
                SetEntityAsMissionEntity(wagon, false, false)
                DeleteMissionTrain(wagon)
            end
        end
        attachedWagons = {}
    end
end)