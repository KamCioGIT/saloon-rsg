-- ============================================================================
-- RSG SALOON PREMIUM - SERVER PLACED PROPS
-- Handles networked prop placement and interactions
-- ============================================================================

local RSGCore = exports['rsg-core']:GetCoreObject()

-- Storage for placed props
local placedProps = {}
local propIdCounter = 0

-- ============================================================================
-- PLACE PROP
-- ============================================================================

RegisterNetEvent('rsg-saloon-premium:server:placeProp', function(data)
    local source = source
    local Player = RSGCore.Functions.GetPlayer(source)
    
    if not Player then return end
    
    -- Verify player is a saloon employee
    local playerJob = Player.PlayerData.job.name
    local saloonId = nil
    
    for id, _ in pairs(Config.Saloons) do
        if playerJob == id then
            saloonId = id
            break
        end
    end
    
    if not saloonId then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'You must be a saloon employee to serve items.'
        })
        return
    end
    
    -- Check if item exists in saloon storage (check extraData first)
    local itemName = data.itemName
    if not itemName and data.extraData then
        itemName = data.extraData.itemName
    end

    if itemName then
        local storageResult = MySQL.query.await(
            'SELECT quantity FROM saloon_premium_storage WHERE saloon = ? AND item = ?',
            { saloonId, itemName }
        )
        
        local hasItem = storageResult and storageResult[1] and storageResult[1].quantity > 0
        
        if not hasItem then
            TriggerClientEvent('ox_lib:notify', source, {
                type = 'error',
                description = 'This item is not in saloon storage. Craft it first!'
            })
            return
        end
        
        -- Deduct 1 from storage
        MySQL.update.await(
            'UPDATE saloon_premium_storage SET quantity = quantity - 1 WHERE saloon = ? AND item = ?',
            { saloonId, itemName }
        )
        
        -- Remove if quantity is 0
        MySQL.query.await(
            'DELETE FROM saloon_premium_storage WHERE saloon = ? AND item = ? AND quantity <= 0',
            { saloonId, itemName }
        )
        
        if Config.Debug then
            print('[Saloon] Deducted 1', itemName, 'from', saloonId, 'storage')
        end
    end
    
    -- Generate unique prop ID
    propIdCounter = propIdCounter + 1
    local propId = 'prop_' .. propIdCounter
    
    -- Store prop data
    placedProps[propId] = {
        id = propId,
        model = data.model,
        x = data.x,
        y = data.y,
        z = data.z,
        rotation = data.rotation or 0.0,
        propType = data.propType or 'drink',
        extraData = data.extraData or {},
        placedBy = Player.PlayerData.citizenid,
        placedAt = os.time()
    }
    
    -- Notify all clients to create the prop
    TriggerClientEvent('rsg-saloon-premium:client:createPlacedProp', -1, {
        propId = propId,
        model = data.model,
        x = data.x,
        y = data.y,
        z = data.z,
        rotation = data.rotation or 0.0,
        propType = data.propType,
        extraData = data.extraData
    })
    
    if Config.Debug then
        print('[Saloon] Prop placed:', propId, data.model)
    end
end)

-- ============================================================================
-- CONSUME PLACED PROP
-- ============================================================================

RegisterNetEvent('rsg-saloon-premium:server:consumePlacedProp', function(propId)
    local source = source
    local Player = RSGCore.Functions.GetPlayer(source)
    
    if not Player then return end
    
    local propData = placedProps[propId]
    if not propData then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Item no longer exists.'
        })
        return
    end
    
    -- Remove from storage
    placedProps[propId] = nil
    
    -- Remove prop from all clients
    TriggerClientEvent('rsg-saloon-premium:client:removePlacedProp', -1, propId)
    
    -- Trigger consumption animation on the player
    TriggerClientEvent('rsg-saloon-premium:client:consumeProp', source, propData)
    
    if Config.Debug then
        print('[Saloon] Prop consumed:', propId, 'by', Player.PlayerData.citizenid)
    end
end)

-- ============================================================================
-- HUNGER/THIRST RESTORATION
-- ============================================================================

RegisterNetEvent('rsg-saloon:server:restoreHunger', function(amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local currentHunger = Player.PlayerData.metadata['hunger'] or 0
    local newHunger = math.min(100, currentHunger + (amount or 30))
    Player.Functions.SetMetaData('hunger', newHunger)
    
    if Config.Debug then
        print('[Saloon] Restored hunger for', Player.PlayerData.citizenid, ':', amount)
    end
end)

RegisterNetEvent('rsg-saloon:server:restoreThirst', function(amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local currentThirst = Player.PlayerData.metadata['thirst'] or 0
    local newThirst = math.min(100, currentThirst + (amount or 30))
    Player.Functions.SetMetaData('thirst', newThirst)
    
    if Config.Debug then
        print('[Saloon] Restored thirst for', Player.PlayerData.citizenid, ':', amount)
    end
end)

-- ============================================================================
-- REMOVE PLACED PROP (Staff only)
-- ============================================================================

RegisterNetEvent('rsg-saloon-premium:server:removePlacedProp', function(propId)
    local source = source
    local Player = RSGCore.Functions.GetPlayer(source)
    
    if not Player then return end
    
    local propData = placedProps[propId]
    if not propData then return end
    
    -- Check if player is staff (has any saloon job)
    local playerJob = Player.PlayerData.job.name
    local isStaff = false
    
    for saloonId, _ in pairs(Config.Saloons) do
        if playerJob == saloonId then
            isStaff = true
            break
        end
    end
    
    if not isStaff then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Only staff can remove items.'
        })
        return
    end
    
    -- Remove from storage
    placedProps[propId] = nil
    
    -- Remove prop from all clients
    TriggerClientEvent('rsg-saloon-premium:client:removePlacedProp', -1, propId)
    
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = 'Item removed.'
    })
end)

-- ============================================================================
-- SYNC PROPS ON PLAYER JOIN
-- ============================================================================

RegisterNetEvent('rsg-saloon-premium:server:requestProps', function()
    local source = source
    
    for propId, propData in pairs(placedProps) do
        TriggerClientEvent('rsg-saloon-premium:client:createPlacedProp', source, {
            propId = propId,
            model = propData.model,
            x = propData.x,
            y = propData.y,
            z = propData.z,
            rotation = propData.rotation,
            propType = propData.propType,
            extraData = propData.extraData
        })
    end
end)

-- ============================================================================
-- CLEANUP OLD PROPS (every 30 minutes)
-- ============================================================================

CreateThread(function()
    while true do
        Wait(1800000) -- 30 minutes
        
        local currentTime = os.time()
        local cleaned = 0
        
        for propId, propData in pairs(placedProps) do
            -- Remove props older than 1 hour
            if currentTime - propData.placedAt > 3600 then
                placedProps[propId] = nil
                TriggerClientEvent('rsg-saloon-premium:client:removePlacedProp', -1, propId)
                cleaned = cleaned + 1
            end
        end
        
        if cleaned > 0 and Config.Debug then
            print('[Saloon] Cleaned up', cleaned, 'old props')
        end
    end
end)

print('^2[RSG-Saloon-Premium]^0 Placed Props module loaded!')
