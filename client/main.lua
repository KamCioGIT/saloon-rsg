-- ============================================================================
-- RSG SALOON PREMIUM - CLIENT MAIN
-- Core client-side logic, UI management, and target interactions
-- ============================================================================

local RSGCore = exports['rsg-core']:GetCoreObject()

-- State variables
local currentSaloon = nil
local isMenuOpen = false
local saloonBlips = {}

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

local function DebugPrint(...)
    if Config.Debug then
        print('[Saloon Premium]', ...)
    end
end

-- Get player's current job
local function GetPlayerJob()
    local playerData = RSGCore.Functions.GetPlayerData()
    if playerData and playerData.job then
        return playerData.job.name, playerData.job.grade.level
    end
    return nil, nil
end

-- Check if player is employee at specific saloon
local function IsEmployeeAt(saloonId)
    local job, _ = GetPlayerJob()
    return job == saloonId
end

-- ============================================================================
-- NUI CALLBACKS
-- ============================================================================

RegisterNUICallback('closeUI', function(_, cb)
    SetNuiFocus(false, false)
    isMenuOpen = false
    currentSaloon = nil
    cb('ok')
end)

RegisterNUICallback('ready', function(_, cb)
    DebugPrint('NUI ready')
    cb('ok')
end)

-- ============================================================================
-- OPEN SALOON MENU
-- ============================================================================

local function OpenSaloonMenu(saloonId)
    if isMenuOpen then return end
    
    local saloonConfig = Config.Saloons[saloonId]
    if not saloonConfig then
        DebugPrint('Invalid saloon config:', saloonId)
        return
    end
    
    currentSaloon = saloonId
    
    -- Request data from server
    RSGCore.Functions.TriggerCallback('rsg-saloon-premium:server:getSaloonData', function(data)
        if not data then
            lib.notify({
                type = 'error',
                description = 'Failed to load saloon data.'
            })
            return
        end
        
        -- Get player inventory for crafting
        RSGCore.Functions.TriggerCallback('rsg-saloon-premium:server:getPlayerInventory', function(inventory)
            -- Send data to NUI
            SetNuiFocus(true, true)
            isMenuOpen = true
            
            SendNUIMessage({
                action = 'openMenu',
                saloonId = saloonId,
                saloonName = data.saloonName,
                isEmployee = data.isEmployee,
                playerGrade = data.playerGrade,
                permissions = data.permissions,
                shopStock = data.shopStock,
                storage = data.storage,
                cashboxBalance = data.cashboxBalance,
                transactions = data.transactions,
                recipes = data.recipes,
                defaultPrices = data.defaultPrices,
                playerInventory = inventory,
                imgPath = Config.Img,
            })
            
            DebugPrint('Menu opened for:', saloonId)
        end)
    end, saloonId)
end

-- Export for external resources
exports('OpenSaloonMenu', OpenSaloonMenu)

-- ============================================================================
-- REFRESH UI (after crafting, purchase, etc.)
-- ============================================================================

RegisterNetEvent('rsg-saloon-premium:client:refreshUI', function(saloonId)
    if not isMenuOpen or currentSaloon ~= saloonId then return end
    
    RSGCore.Functions.TriggerCallback('rsg-saloon-premium:server:getSaloonData', function(data)
        if not data then return end
        
        RSGCore.Functions.TriggerCallback('rsg-saloon-premium:server:getPlayerInventory', function(inventory)
            SendNUIMessage({
                action = 'refreshData',
                shopStock = data.shopStock,
                storage = data.storage,
                cashboxBalance = data.cashboxBalance,
                transactions = data.transactions,
                playerInventory = inventory,
            })
        end)
    end, saloonId)
end)

-- ============================================================================
-- TARGET ZONES (OX_TARGET)
-- ============================================================================

local function SetupTargetZones()
    for saloonId, saloon in pairs(Config.Saloons) do
        -- Main bar target using ox_target
        exports.ox_target:addSphereZone({
            coords = saloon.points.bar,
            radius = 1.5,
            debug = Config.Debug,
            options = {
                {
                    name = 'saloon_menu_' .. saloonId,
                    icon = 'fas fa-beer',
                    label = saloon.name .. ' Menu',
                    onSelect = function()
                        OpenSaloonMenu(saloonId)
                    end,
                },
            }
        })
        
        -- Personal Storage target - Opens rsg-inventory stash
        if saloon.points.storage then
            exports.ox_target:addSphereZone({
                coords = saloon.points.storage,
                radius = 1.5,
                debug = Config.Debug,
                options = {
                    {
                        name = 'saloon_personal_storage_' .. saloonId,
                        icon = 'fas fa-box',
                        label = saloon.name .. ' Personal Storage',
                        canInteract = function()
                            -- Only employees can access personal storage
                            local job, _ = GetPlayerJob()
                            return job == saloonId
                        end,
                        onSelect = function()
                            -- Open rsg-inventory stash
                            local stashName = 'saloon_storage_' .. saloonId
                            TriggerServerEvent('rsg-saloon:server:openStorage', saloonId)
                        end,
                    },
                }
            })
        end
        
        DebugPrint('Added ox_target zones for:', saloonId)
    end
end

-- ============================================================================
-- BLIPS
-- ============================================================================

local function CreateBlips()
    for saloonId, saloon in pairs(Config.Saloons) do
        if saloon.showBlip then
            local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, saloon.coords.x, saloon.coords.y, saloon.coords.z)
            SetBlipSprite(blip, joaat(Config.Blip.sprite), true)
            SetBlipScale(blip, Config.Blip.scale)
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, saloon.name)
            
            saloonBlips[saloonId] = blip
            DebugPrint('Created blip for:', saloonId)
        end
    end
end

local function RemoveBlips()
    for saloonId, blip in pairs(saloonBlips) do
        RemoveBlip(blip)
    end
    saloonBlips = {}
end

-- ============================================================================
-- KEYBIND (optional) - Using ox_lib for RedM compatibility
-- ============================================================================

if Config.Keybind then
    -- Register command for keybind
    RegisterCommand('opensaloon', function()
        -- Find nearest saloon
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local nearestSaloon = nil
        local nearestDist = 999
        
        for saloonId, saloon in pairs(Config.Saloons) do
            local dist = #(playerCoords - saloon.coords)
            if dist < nearestDist and dist < 10.0 then
                nearestDist = dist
                nearestSaloon = saloonId
            end
        end
        
        if nearestSaloon then
            OpenSaloonMenu(nearestSaloon)
        else
            lib.notify({
                type = 'error',
                description = 'You are not near a saloon.'
            })
        end
    end, false)
    
    -- Use ox_lib keybind for RedM compatibility
    lib.addKeybind({
        name = 'opensaloon',
        description = 'Open Saloon Menu',
        defaultKey = Config.Keybind,
        onPressed = function()
            ExecuteCommand('opensaloon')
        end
    })
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

CreateThread(function()
    Wait(1000)
    SetupTargetZones()
    CreateBlips()
    print('^2[RSG-Saloon-Premium]^0 Client loaded successfully!')
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    RemoveBlips()
end)
