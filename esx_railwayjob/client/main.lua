-- client/main.lua
-- ESX Railway Job - realistic spawn on rails and smooth controls

local isInService = false
local currentTrain = nil
local attachedWagons = {}
local currentSpeed = 0.0
local targetSpeed = 0.0
local maxSpeed = 30.0

local trainTypeMap = {
    metrotrain = {type = 24, max = 22.0},
    freight = {type = 25, max = 28.0}
}

-- Valid train hashes
local trainHashes = {
    freight = 1030400667,      -- Locomotive
    freightcar = 1090274449,   -- Standard freight car
    freightgrain = -1094739713,-- Grain transport
    freightcont1 = 642617954,  -- Container car type 1
    freightcont2 = 586013744,  -- Container car type 2
    tankercar = -742380147,    -- Tanker car
    metrotrain = 868868440     -- Metro train
}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

-- Fonction pour créer les blips
CreateThread(function()
    for k,v in pairs(Config.Zones) do
        if v.BlipSprite then
            local blip = AddBlipForCoord(v.Pos.x, v.Pos.y, v.Pos.z)
            SetBlipSprite(blip, v.BlipSprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 1.0)
            SetBlipColour(blip, v.BlipColor or 1)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.BlipName)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

-- Création des markers
CreateThread(function()
    while true do
        local sleep = 1500
        local playerCoords = GetEntityCoords(PlayerPedId())

        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'railway' then
            for k,v in pairs(Config.Zones) do
                local distance = #(playerCoords - v.Pos)

                if distance < 15 then
                    sleep = 0
                    DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                        v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, 
                        false, true, 2, false, nil, nil, false)

                    if distance < 2 then
                        ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour accéder au menu')
                        if IsControlJustReleased(0, 38) then
                            OpenRailwayMenu(k)
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- Gestion des contrôles du train
CreateThread(function()
    while true do
        local sleep = 500

        if currentTrain and isInService then
            sleep = 0
            local ped = PlayerPedId()

            -- Démarrage/Arrêt
            if IsControlJustReleased(0, Config.Controls.START_STOP) then
                if currentSpeed == 0.0 then
                    currentSpeed = 5.0
                else
                    currentSpeed = 0.0
                end
                SetTrainSpeed(currentTrain, currentSpeed)
            end

            -- Accélération/Décélération
            if IsControlPressed(0, Config.Controls.SPEED_UP) then
                if currentSpeed < maxSpeed then
                    currentSpeed = currentSpeed + 0.5
                    SetTrainSpeed(currentTrain, currentSpeed)
                end
            elseif IsControlPressed(0, Config.Controls.SPEED_UP + 1) then
                if currentSpeed > 0.0 then
                    currentSpeed = currentSpeed - 0.5
                    SetTrainSpeed(currentTrain, currentSpeed)
                end
            end

            -- Klaxon
            if IsControlJustPressed(0, Config.Controls.HORN) then
                PlayTrainHorn(currentTrain)
            end

            -- Lumières
            if IsControlJustReleased(0, Config.Controls.LIGHTS) then
                ToggleTrainLights(currentTrain)
            end
        end

        Wait(sleep)
    end
end)

function OpenRailwayMenu(zone)
    local elements = {}

    if zone == 'Cloakroom' then
        elements = {
            {label = 'Tenue civile', value = 'citizen_wear'},
            {label = 'Tenue de travail', value = 'railway_wear'}
        }
    elseif zone == 'VehicleSpawner' then
        elements = {}
        for _, vehicle in ipairs(Config.Vehicles) do
            if ESX.PlayerData.job.grade >= (vehicle.minGrade or 0) then
                table.insert(elements, {
                    label = vehicle.label,
                    value = vehicle.name,
                    type = vehicle.type
                })
            end
        end
    end

    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'railway_actions', {
        title    = 'Menu Railway',
        align    = 'top-left',
        elements = elements
    }, function(data, menu)
        if zone == 'Cloakroom' then
            if data.current.value == 'citizen_wear' then
                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                    TriggerEvent('skinchanger:loadSkin', skin)
                end)
                isInService = false
            else
                isInService = true
                -- Chargement de la tenue de travail
                local uniformObject = {
                    male = {
                        ['tshirt_1'] = 59, ['tshirt_2'] = 1,
                        ['torso_1'] = 55, ['torso_2'] = 0,
                        ['decals_1'] = 0, ['decals_2'] = 0,
                        ['arms'] = 41,
                        ['pants_1'] = 25, ['pants_2'] = 0,
                        ['shoes_1'] = 25, ['shoes_2'] = 0,
                        ['helmet_1'] = 46, ['helmet_2'] = 0,
                        ['chain_1'] = 0, ['chain_2'] = 0,
                        ['ears_1'] = 2, ['ears_2'] = 0
                    },
                    female = {
                        ['tshirt_1'] = 36, ['tshirt_2'] = 1,
                        ['torso_1'] = 48, ['torso_2'] = 0,
                        ['decals_1'] = 0, ['decals_2'] = 0,
                        ['arms'] = 44,
                        ['pants_1'] = 34, ['pants_2'] = 0,
                        ['shoes_1'] = 27, ['shoes_2'] = 0,
                        ['helmet_1'] = 45, ['helmet_2'] = 0,
                        ['chain_1'] = 0, ['chain_2'] = 0,
                        ['ears_1'] = 2, ['ears_2'] = 0
                    }
                }

                TriggerEvent('skinchanger:getSkin', function(skin)
                    local uniformData = skin.sex == 0 and uniformObject.male or uniformObject.female
                    TriggerEvent('skinchanger:loadClothes', skin, uniformData)
                end)
            end
            menu.close()
        elseif zone == 'VehicleSpawner' then
            if isInService then
                local vehicleType = data.current.type
                local vehicleName = data.current.value
                
                if vehicleType == 'metrotrain' or vehicleType == 'freight' then
                    SpawnTrain(vehicleName)
                else
                    AttachWagon(vehicleName)
                end
            else
                ESX.ShowNotification('Vous devez être en service pour utiliser les véhicules')
            end
        end
    end, function(data, menu)
        menu.close()
    end)
end

function SpawnTrain(modelName, vtype)
    if currentTrain then
        ESX.ShowNotification('Vous avez déjà un train en service')
        return
    end

    local spawn = Config.Zones.VehicleSpawner.Pos
    
    -- Build list of required model hashes to preload (loco + common carriages for freight)
    local trainHash = trainHashes[modelName] or trainHashes.freight
    local required = { trainHash }

    if modelName == 'freight' or vtype == 'freight' then
        local carriageList = {'freightcar','freightcar2','freightcar3','freightgrain','freightcont1','freightcont2','tankercar'}
        for _, cname in ipairs(carriageList) do
            table.insert(required, GetHashKey(cname))
        end
    end

    -- Request and wait for each required model (short timeout per model)
    local failed = {}
    for _, h in ipairs(required) do
        if not RequestTrainModel(h) then
            -- last effort: request and wait inline
            RequestModel(h)
            local t = GetGameTimer() + 10000
            while not HasModelLoaded(h) and GetGameTimer() < t do
                Wait(50)
            end
            if not HasModelLoaded(h) then
                table.insert(failed, h)
            end
        end
    end

    if #failed > 0 then
        ESX.ShowNotification('Impossible de charger certains modèles du train: ' .. tostring(#failed) .. ' manquants')
        print(('^1Missing train models (hashes): %s^7'):format(table.concat(failed, ', ')))
        return
    end

    -- Get the train type based on model
    local trainType = (modelName == 'metrotrain' or vtype == 'metrotrain') and trainTypeMap.metro.type or trainTypeMap.freight.type

    -- Create mission train
    local train = CreateMissionTrain(trainType, spawn.x, spawn.y, spawn.z, true)
    if not DoesEntityExist(train) then
        ESX.ShowNotification('Échec de création du train')
        SetModelAsNoLongerNeeded(trainHash)
        return
    end

    -- Configure train
    SetEntityAsMissionEntity(train, true, true)
    SetTrainSpeed(train, 0.0)
    
    -- Save references
    currentTrain = train
    currentSpeed = 0.0
    targetSpeed = 0.0
    maxSpeed = (vtype == 'metrotrain') and 22.0 or 28.0
    
    -- Put player in driver seat
    TaskWarpPedIntoVehicle(PlayerPedId(), currentTrain, -1)
    SetModelAsNoLongerNeeded(trainHash)
    ESX.ShowNotification('Train créé sur les rails\nUtilisez W/S pour accélérer/freiner')
end

function AttachWagon(wagonModel)
    if not currentTrain then
        ESX.ShowNotification('Vous devez d\'abord créer une locomotive')
        return
    end
    -- Get correct hash for wagon type
    local wagonHash = trainHashes[wagonModel] or trainHashes.freightcar

    -- Ensure the model is loaded
    if not RequestTrainModel(wagonHash) then
        ESX.ShowNotification('Impossible de charger le modèle du wagon')
        return
    end

    local index = #attachedWagons + 1
    local spacing = Config.Realism.WagonSpacing or 11.5
    local offset = - (index * spacing)
    local spawnPos = GetOffsetFromEntityInWorldCoords(currentTrain, 0.0, offset, 0.0)
    local pos, _ = GetNearestRailPos(spawnPos.x, spawnPos.y, spawnPos.z)

    -- Create the wagon as a vehicle with the requested model
    local wagon = CreateVehicle(wagonHash, pos.x, pos.y, pos.z, GetEntityHeading(currentTrain), true, false)
    if not DoesEntityExist(wagon) then
        ESX.ShowNotification(_U('spawn_failed_wagon'))
        SetModelAsNoLongerNeeded(wagonHash)
        return
    end

    SetEntityAsMissionEntity(wagon, true, true)
    SetVehicleOnGroundProperly(wagon)
    AttachEntityToEntity(wagon, currentTrain, 0, 0.0, offset, 0.0, 0.0, 0.0, false, false, true, false, 2, true)
    table.insert(attachedWagons, wagon)
    SetModelAsNoLongerNeeded(wagonHash)
    ESX.ShowNotification(_U('wagon_attached'))
end

-- Contrôles de vitesse & utilitaires
function SetTrainSpeed(train, speed)
    if not DoesEntityExist(train) then return end
    -- speed en m/s approximatif, on applique comme forward speed
    SetVehicleForwardSpeed(train, speed)
end

function PlayTrainHorn(train)
    if not DoesEntityExist(train) then return end
    -- Durée courte du klaxon
    StartVehicleHorn(train, 1000, GetHashKey('HELLO'), false)
end

local lightsOn = {}
function ToggleTrainLights(train)
    if not DoesEntityExist(train) then return end
    local id = tonumber(train) or train
    lightsOn[id] = not lightsOn[id]
    SetVehicleLights(train, lightsOn[id] and 2 or 1)
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        ESX.UI.Menu.CloseAll()
        
        if currentTrain and DoesEntityExist(currentTrain) then
            SetEntityAsMissionEntity(currentTrain, false, false)
            DeleteVehicle(currentTrain)
            currentTrain = nil
        end

        for _, wagon in ipairs(attachedWagons) do
            if DoesEntityExist(wagon) then
                SetEntityAsMissionEntity(wagon, false, false)
                DeleteVehicle(wagon)
            end
        end
        attachedWagons = {}
    end

end)
