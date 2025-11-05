-- List of all train models with their hashes
-- train_models.lua
-- Dynamically build hash list from model names to avoid hardcoding incorrect hashes
local modelNames = {
    'freight',       -- locomotive
    'metrotrain',    -- metro
    'freightcar',
    'freightcar2',
    'freightcar3',
    'freightgrain',
    'freightcont1',
    'freightcont2',
    'tankercar'
}

local trainModels = {}
local loadedModels = {}

for _, name in ipairs(modelNames) do
    local hash = GetHashKey(name)
    table.insert(trainModels, { hash = hash, name = name })
    loadedModels[hash] = false
end

local function LoadModelWithTimeout(modelHash, timeoutMs)
    timeoutMs = timeoutMs or 10000
    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
        local timer = GetGameTimer() + timeoutMs
        while not HasModelLoaded(modelHash) do
            Wait(50)
            if GetGameTimer() > timer then
                return false
            end
        end
    end
    return true
end

local function PreloadTrainModels()
    local failed = {}
    for _, model in ipairs(trainModels) do
        if LoadModelWithTimeout(model.hash, 12000) then
            loadedModels[model.hash] = true
            print(('^2Loaded train model: %s (hash: %s)^7'):format(model.name, model.hash))
        else
            table.insert(failed, model.name)
            print(('^1Failed to load train model: %s (hash: %s)^7'):format(model.name, model.hash))
        end
    end

    if #failed > 0 then
        print(('^1Preload finished with failures: %s^7'):format(table.concat(failed, ', ')))
        return false
    end
    return true
end

function IsTrainModelLoaded(modelHash)
    return loadedModels[modelHash] == true
end

function RequestTrainModel(modelHash)
    if loadedModels[modelHash] then return true end
    if LoadModelWithTimeout(modelHash, 12000) then
        loadedModels[modelHash] = true
        return true
    end
    return false
end

local function UnloadTrainModels()
    for _, m in ipairs(trainModels) do
        if HasModelLoaded(m.hash) then
            SetModelAsNoLongerNeeded(m.hash)
            loadedModels[m.hash] = false
        end
    end
end

CreateThread(function()
    PreloadTrainModels()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        UnloadTrainModels()
    end
end)