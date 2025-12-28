-- ============================================================================
-- RSG SALOON PREMIUM - CONSUMPTION SYSTEM
-- Eating/drinking animations with props and effects
-- ============================================================================

local RSGCore = exports['rsg-core']:GetCoreObject()

-- ============================================================================
-- DRINKING ANIMATIONS
-- ============================================================================

function PlayDrinkAnimation(bottleModel, bottleType, alcoholLevel)
    local playerPed = PlayerPedId()
    local propHash = GetHashKey(bottleModel)
    
    RequestModel(propHash)
    while not HasModelLoaded(propHash) do Wait(10) end
    
    local prop = CreateObject(propHash, GetEntityCoords(playerPed), true, true, false, false, true)
    
    -- Different animations based on bottle type
    local animHash, propPlacement
    
    if bottleType == 'small' then
        -- Beer bottle animation
        animHash = GetHashKey('CONSUMABLE_SALOON_BEER')
        propPlacement = GetHashKey('P_BOTTLEBEER01X_PH_R_HAND')
        TaskItemInteraction_2(playerPed, animHash, prop, propPlacement, -1493684811, 1, 0, -1.0)
    elseif bottleType == 'large' then
        -- Large bottle (whiskey, wine)
        animHash = GetHashKey('CONSUMABLE_SALOON_WHISKEY')
        propPlacement = GetHashKey('P_BOTTLEJD01X_PH_R_HAND')
        local interactionState = GetHashKey('DRINK_BOTTLE@Bottle_Cylinder_D1-3_H30-5_Neck_A13_B2-5_UNCORK')
        TaskItemInteraction_2(playerPed, animHash, prop, propPlacement, interactionState, 1, 0, -1.0)
    else
        -- Generic bottle
        propPlacement = GetHashKey('P_BOTTLEJD01X_PH_R_HAND')
        TaskItemInteraction_2(playerPed, -1679900928, prop, propPlacement, -68870885, 1, 0, -1.0)
    end
    
    -- Monitor for completion
    CreateThread(function()
        while true do
            Wait(1000)
            local interaction = Citizen.InvokeNative(0x6AA3DCA2C6F5EB6D, playerPed)
            
            if interaction == -1318807663 or interaction == false then
                DeleteEntity(prop)
                
                -- Apply alcohol effects
                if alcoholLevel and alcoholLevel > 0 then
                    TriggerEvent('rsg-saloon-premium:client:addAlcohol', alcoholLevel)
                end
                
                -- Restore thirst
                TriggerEvent('rsg-saloon-premium:client:restoreStats', 0, 25)
                
                lib.notify({ type = 'success', description = 'Refreshing!' })
                break
            end
        end
    end)
end

-- ============================================================================
-- EATING ANIMATIONS (BOWL/STEW)
-- ============================================================================

function PlayEatBowlAnimation(bowlModel)
    local playerPed = PlayerPedId()
    local bowlHash = GetHashKey(bowlModel)
    local spoonHash = GetHashKey('p_spoon01x')
    
    RequestModel(bowlHash)
    RequestModel(spoonHash)
    while not HasModelLoaded(bowlHash) or not HasModelLoaded(spoonHash) do Wait(10) end
    
    local coords = GetEntityCoords(playerPed)
    local bowl = CreateObject(bowlHash, coords, true, true, false, false, true)
    local spoon = CreateObject(spoonHash, coords, true, true, false, false, true)
    
    -- Set up network flags
    Citizen.InvokeNative(0xCAAF2BCCFEF37F77, bowl, 20)
    Citizen.InvokeNative(0xCAAF2BCCFEF37F77, spoon, 82)
    
    -- Play eating scenario
    TaskItemInteraction_2(playerPed, 599184882, bowl, GetHashKey('p_bowl04x_stew_ph_l_hand'), -583731576, 1, 0, -1.0)
    TaskItemInteraction_2(playerPed, 599184882, spoon, GetHashKey('p_spoon01x_ph_r_hand'), -583731576, 1, 0, -1.0)
    Citizen.InvokeNative(0xB35370D5353995CB, playerPed, -583731576, 1.0)
    
    -- Monitor for completion
    CreateThread(function()
        while true do
            Wait(1000)
            local interaction = Citizen.InvokeNative(0x6AA3DCA2C6F5EB6D, playerPed)
            
            if interaction == -1318807663 or interaction == false then
                DeleteEntity(bowl)
                DeleteEntity(spoon)
                
                -- Restore hunger
                TriggerEvent('rsg-saloon-premium:client:restoreStats', 50, 0)
                
                lib.notify({ type = 'success', description = 'Delicious!' })
                break
            end
        end
    end)
end

-- ============================================================================
-- EATING ANIMATIONS (PLATE WITH FORK)
-- ============================================================================

function PlayEatPlateAnimation(plateModel, mainModel, sideModel)
    local playerPed = PlayerPedId()
    local plateHash = GetHashKey(plateModel)
    local forkHash = GetHashKey('p_fork01x')
    local mainHash = mainModel and GetHashKey(mainModel) or nil
    local sideHash = sideModel and GetHashKey(sideModel) or nil
    
    RequestModel(plateHash)
    RequestModel(forkHash)
    if mainHash then RequestModel(mainHash) end
    if sideHash then RequestModel(sideHash) end
    
    while not HasModelLoaded(plateHash) or not HasModelLoaded(forkHash) do Wait(10) end
    if mainHash then while not HasModelLoaded(mainHash) do Wait(10) end end
    if sideHash then while not HasModelLoaded(sideHash) do Wait(10) end end
    
    local coords = GetEntityCoords(playerPed)
    local plate = CreateObject(plateHash, coords, true, true, false, false, true)
    local fork = CreateObject(forkHash, coords, true, true, false, false, true)
    
    local main, side
    if mainHash then
        main = CreateObject(mainHash, coords, true, true, false, false, true)
        AttachEntityToEntity(main, plate, 0, 0.0, -0.03, 0.0, 0.0, 0.0, 0.0, true, false, false, false, 0, true, false, false)
    end
    if sideHash then
        side = CreateObject(sideHash, coords, true, true, false, false, true)
        AttachEntityToEntity(side, plate, 0, -0.04, 0.04, 0.0, 0.0, 0.0, 180.0, true, false, false, false, 0, true, false, false)
    end
    
    Citizen.InvokeNative(0xCAAF2BCCFEF37F77, plate, 20)
    Citizen.InvokeNative(0xCAAF2BCCFEF37F77, fork, 82)
    
    TaskItemInteraction_2(playerPed, 599184882, plate, GetHashKey('p_bowl04x_stew_ph_l_hand'), -583731576, 1, 0, -1.0)
    TaskItemInteraction_2(playerPed, 599184882, fork, GetHashKey('p_spoon01x_ph_r_hand'), -583731576, 1, 0, -1.0)
    Citizen.InvokeNative(0xB35370D5353995CB, playerPed, -583731576, 1.0)
    
    CreateThread(function()
        while true do
            Wait(1000)
            local interaction = Citizen.InvokeNative(0x6AA3DCA2C6F5EB6D, playerPed)
            
            if interaction == -1318807663 or interaction == false then
                DeleteEntity(plate)
                DeleteEntity(fork)
                if main then DeleteEntity(main) end
                if side then DeleteEntity(side) end
                
                TriggerEvent('rsg-saloon-premium:client:restoreStats', 75, 15)
                
                lib.notify({ type = 'success', description = 'That was a great meal!' })
                break
            end
        end
    end)
end

-- ============================================================================
-- CONSUMPTION MAPPING
-- ============================================================================

local DrinkModels = {
    -- Small bottles (beer)
    ['p_bottlebeer01x'] = { type = 'small', alcohol = 0.1 },
    ['p_bottlebeer01a'] = { type = 'small', alcohol = 0.1 },
    ['p_bottlebeer01a_1'] = { type = 'small', alcohol = 0.1 },
    ['p_bottlebeer01a_2'] = { type = 'small', alcohol = 0.1 },
    ['p_bottlebeer01a_3'] = { type = 'small', alcohol = 0.1 },
    ['p_bottlebeer02x'] = { type = 'small', alcohol = 0.2 },
    ['p_bottlebeer03x'] = { type = 'small', alcohol = 0.2 },
    
    -- Large bottles
    ['p_bottle02x'] = { type = 'large', alcohol = 0.6 },  -- Whiskey
    ['p_bottle006x'] = { type = 'large', alcohol = 0.5 }, -- Gin
    ['p_bottle008x'] = { type = 'large', alcohol = 0.2 }, -- Lager
    ['p_bottle008x_big'] = { type = 'large', alcohol = 0.3 },
    ['p_bottle009x'] = { type = 'large', alcohol = 0.4 }, -- Rye Whiskey
    ['p_bottle010x'] = { type = 'large', alcohol = 1.0 }, -- Absinthe
    ['p_bottle011x'] = { type = 'large', alcohol = 0.5 },
    ['p_bottleabsinthe01x'] = { type = 'large', alcohol = 1.5 },
    ['p_bottlebrandy01x'] = { type = 'large', alcohol = 0.5 },
    ['p_bottlechampagne01x'] = { type = 'large', alcohol = 0.2 },
    ['p_bottlecognac01x'] = { type = 'large', alcohol = 0.2 },
    ['p_bottleredmist01x'] = { type = 'large', alcohol = 0.4 },
    ['p_bottlesherry01x'] = { type = 'large', alcohol = 0.3 },
    ['p_bottletequila02x'] = { type = 'large', alcohol = 0.6 },
    ['p_bottlewine01x'] = { type = 'large', alcohol = 0.3 },
    ['p_bottlewine02x'] = { type = 'large', alcohol = 0.3 },
    ['p_bottlewine03x'] = { type = 'large', alcohol = 0.2 },
    ['p_bottlewine04x'] = { type = 'large', alcohol = 0.2 },
    
    -- Non-alcoholic
    ['p_mugCoffee01x'] = { type = 'other', alcohol = 0 },
    ['p_bottle01x'] = { type = 'other', alcohol = 0 }, -- Milk
}

local BowlModels = {
    'p_bowl04x_stew',
    'p_bacon_cabbage01x',
    'p_beefstew01x',
    'p_chillicurry01x',
    'p_fishstew01x',
    'p_lobster_bisque01x',
    'p_oatmeal01x',
    'p_wheat_milk01x',
}

-- ============================================================================
-- CONSUME PLACED PROP EVENT
-- ============================================================================

RegisterNetEvent('rsg-saloon-premium:client:consumeProp', function(propData)
    local model = propData.model
    
    -- Check if it's a drink
    if DrinkModels[model] then
        local drinkInfo = DrinkModels[model]
        PlayDrinkAnimation(model, drinkInfo.type, drinkInfo.alcohol)
        return
    end
    
    -- Check if it's a bowl/stew
    for _, bowlModel in ipairs(BowlModels) do
        if model == bowlModel then
            PlayEatBowlAnimation(model)
            return
        end
    end
    
    -- Check if it's a plate
    if propData.propType == 'plate' then
        PlayEatPlateAnimation(
            propData.extraData.plate or 'p_plate01x',
            propData.extraData.mainDish,
            propData.extraData.sideDish
        )
        return
    end
    
    -- Default plate eating
    PlayEatPlateAnimation(model)
end)

-- ============================================================================
-- STAT RESTORATION
-- ============================================================================

RegisterNetEvent('rsg-saloon-premium:client:restoreStats', function(hunger, thirst)
    -- This integrates with your needs system
    -- Adjust event name as needed for your server
    if hunger > 0 then
        TriggerServerEvent('rsg-saloon-premium:server:restoreHunger', hunger)
    end
    if thirst > 0 then
        TriggerServerEvent('rsg-saloon-premium:server:restoreThirst', thirst)
    end
end)

-- Export functions
exports('PlayDrinkAnimation', PlayDrinkAnimation)
exports('PlayEatBowlAnimation', PlayEatBowlAnimation)
exports('PlayEatPlateAnimation', PlayEatPlateAnimation)

print('^2[RSG-Saloon-Premium]^0 Consumption module loaded!')
