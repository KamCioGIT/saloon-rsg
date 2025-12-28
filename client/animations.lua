-- ============================================================================
-- RSG SALOON PREMIUM - CLIENT ANIMATIONS
-- Work animations for bartending RP
-- ============================================================================

local RSGCore = exports['rsg-core']:GetCoreObject()

-- ============================================================================
-- CLEAN GLASS ANIMATION
-- ============================================================================

function PlayCleanGlassAnimation()
    local playerPed = PlayerPedId()
    local propName = 'p_glass01x'
    local coords = GetEntityCoords(playerPed)
    
    -- Create glass prop
    local propHash = GetHashKey(propName)
    RequestModel(propHash)
    while not HasModelLoaded(propHash) do Wait(10) end
    
    local prop = CreateObject(propHash, coords.x, coords.y, coords.z + 0.2, true, true, true)
    local boneIndex = GetEntityBoneIndexByName(playerPed, 'PH_L_HAND')
    
    -- Load animation
    local animDict = 'amb_work@world_human_bartender@cleaning@glass@male_b@idle_b'
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(100) end
    
    -- Play animation and attach prop
    TaskPlayAnim(playerPed, animDict, 'idle_d', 8.0, 8.0, 12600, 1, 0, true, 0, false, 0, false)
    AttachEntityToEntity(prop, playerPed, boneIndex, 0.02, 0.028, 0.001, 15.0, 175.0, 0.0, true, true, false, true, 1, true)
    
    lib.notify({ type = 'info', description = 'Cleaning glass...' })
    
    Wait(10000)
    
    DeleteObject(prop)
    ClearPedTasks(playerPed)
    
    lib.notify({ type = 'success', description = 'Glass cleaned!' })
end

-- ============================================================================
-- CLEAN TABLE ANIMATION
-- ============================================================================

function PlayCleanTableAnimation()
    local playerPed = PlayerPedId()
    local propName = 'p_cs_rag01x'
    local coords = GetEntityCoords(playerPed)
    
    -- Create rag prop
    local propHash = GetHashKey(propName)
    RequestModel(propHash)
    while not HasModelLoaded(propHash) do Wait(10) end
    
    local prop = CreateObject(propHash, coords.x, coords.y, coords.z + 0.2, true, true, true)
    local boneIndex = GetEntityBoneIndexByName(playerPed, 'PH_R_HAND')
    
    -- Load animation
    local animDict = 'amb_work@world_human_clean_table@male_b@idle_c'
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(100) end
    
    -- Play animation and attach prop
    TaskPlayAnim(playerPed, animDict, 'idle_g', 8.0, 8.0, 12600, 1, 0, true, 0, false, 0, false)
    AttachEntityToEntity(prop, playerPed, boneIndex, 0.02, 0.028, 0.001, 15.0, 175.0, 0.0, true, true, false, true, 1, true)
    
    lib.notify({ type = 'info', description = 'Cleaning table...' })
    
    Wait(10000)
    
    DeleteObject(prop)
    ClearPedTasks(playerPed)
    
    lib.notify({ type = 'success', description = 'Table cleaned!' })
end

-- ============================================================================
-- SERVE DRINK ANIMATION
-- ============================================================================

function PlayServeDrinkAnimation()
    local playerPed = PlayerPedId()
    local propName = 'p_beermugglass01x'
    local coords = GetEntityCoords(playerPed)
    
    -- Create mug prop
    local propHash = GetHashKey(propName)
    RequestModel(propHash)
    while not HasModelLoaded(propHash) do Wait(10) end
    
    local prop = CreateObject(propHash, coords.x, coords.y, coords.z + 0.2, true, true, true)
    local boneIndex = GetEntityBoneIndexByName(playerPed, 'PH_R_HAND')
    
    -- Load animation
    local animDict = 'amb_rest_drunk@world_human_bottle_pickup@table@box@female_b@react_look@exit@generic'
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(100) end
    
    -- Play animation and attach prop
    TaskPlayAnim(playerPed, animDict, 'react_look_right_exit', 8.0, 8.0, 3000, 1, 0, true, 0, false, 0, false)
    AttachEntityToEntity(prop, playerPed, boneIndex, 0.02, 0.028, 0.001, 15.0, 175.0, 0.0, true, true, false, true, 1, true)
    
    lib.notify({ type = 'info', description = 'Serving drink...' })
    
    Wait(3000)
    
    DeleteObject(prop)
    ClearPedTasks(playerPed)
end

-- ============================================================================
-- POUR DRINK ANIMATION
-- ============================================================================

function PlayPourDrinkAnimation()
    local playerPed = PlayerPedId()
    
    -- Load animation
    local animDict = 'amb_work@world_human_bartender@female@idle_a'
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(100) end
    
    TaskPlayAnim(playerPed, animDict, 'idle_a', 8.0, 8.0, 5000, 1, 0, true, 0, false, 0, false)
    
    lib.notify({ type = 'info', description = 'Pouring drink...' })
    
    Wait(5000)
    ClearPedTasks(playerPed)
end

-- ============================================================================
-- NUI CALLBACKS
-- ============================================================================

RegisterNUICallback('playAnimation', function(data, cb)
    local anim = data.animation
    
    if anim == 'cleanGlass' then
        PlayCleanGlassAnimation()
    elseif anim == 'cleanTable' then
        PlayCleanTableAnimation()
    elseif anim == 'serveDrink' then
        PlayServeDrinkAnimation()
    elseif anim == 'pourDrink' then
        PlayPourDrinkAnimation()
    end
    
    cb({ success = true })
end)

-- ============================================================================
-- EXPORTS
-- ============================================================================

exports('PlayCleanGlassAnimation', PlayCleanGlassAnimation)
exports('PlayCleanTableAnimation', PlayCleanTableAnimation)
exports('PlayServeDrinkAnimation', PlayServeDrinkAnimation)
exports('PlayPourDrinkAnimation', PlayPourDrinkAnimation)

print('^2[RSG-Saloon-Premium]^0 Animations module loaded!')
