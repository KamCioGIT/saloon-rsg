-- ============================================================================
-- RSG SALOON PREMIUM - SERVER CRAFTING
-- Handles crafting validation and item creation
-- ============================================================================

local RSGCore = exports['rsg-core']:GetCoreObject()

-- Debug print helper
local function DebugPrint(...)
    if Config.Debug then
        print('[Saloon Premium - Crafting]', ...)
    end
end

-- Find recipe by item name
local function FindRecipe(itemName)
    for _, recipe in ipairs(Config.Recipes) do
        if recipe.item == itemName then
            return recipe
        end
    end
    return nil
end

-- Check if player has required ingredients
local function HasIngredients(Player, recipe)
    for _, req in ipairs(recipe.requirements) do
        local item = Player.Functions.GetItemByName(req.item)
        if not item or item.amount < req.amount then
            return false, req.item
        end
    end
    return true
end

-- Remove ingredients from player
local function RemoveIngredients(Player, recipe)
    for _, req in ipairs(recipe.requirements) do
        Player.Functions.RemoveItem(req.item, req.amount)
        TriggerClientEvent('inventory:client:ItemBox', Player.PlayerData.source, RSGCore.Shared.Items[req.item], 'remove', req.amount)
    end
end

-- Add crafted item to saloon storage
local function AddToStorage(saloon, item, amount)
    MySQL.query.await([[
        INSERT INTO saloon_premium_storage (saloon, item, quantity)
        VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE quantity = quantity + ?
    ]], { saloon, item, amount, amount })
end

-- Log crafting transaction
local function LogCraft(saloon, citizenid, playerName, item, amount)
    MySQL.query.await([[
        INSERT INTO saloon_premium_transactions (saloon, type, amount, item, quantity, citizenid, player_name)
        VALUES (?, 'craft', 0, ?, ?, ?, ?)
    ]], { saloon, item, amount, citizenid, playerName })
end

-- Update employee stats
local function UpdateEmployeeStats(saloon, citizenid, playerName, itemsCrafted)
    MySQL.query.await([[
        INSERT INTO saloon_premium_employees (saloon, citizenid, player_name, items_crafted)
        VALUES (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE items_crafted = items_crafted + ?, player_name = ?
    ]], { saloon, citizenid, playerName, itemsCrafted, itemsCrafted, playerName })
end

-- ============================================================================
-- CRAFTING EVENT
-- ============================================================================

RegisterNetEvent('rsg-saloon-premium:server:craftItem', function(saloonId, itemName)
    local source = source
    local Player = RSGCore.Functions.GetPlayer(source)
    
    if not Player then
        DebugPrint('Player not found:', source)
        return
    end
    
    local playerJob = Player.PlayerData.job.name
    local playerGrade = Player.PlayerData.job.grade.level
    local saloonConfig = Config.Saloons[saloonId]
    
    -- Validate saloon exists
    if not saloonConfig then
        DebugPrint('Invalid saloon:', saloonId)
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Invalid saloon location.'
        })
        return
    end
    
    -- Check if player works at this saloon
    if playerJob ~= saloonId then
        DebugPrint('Not employed at saloon:', playerJob, 'vs', saloonId)
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = Config.Locale['not_employee']
        })
        return
    end
    
    -- Check crafting permission
    if playerGrade < saloonConfig.grades.crafting then
        DebugPrint('Insufficient grade for crafting:', playerGrade, '<', saloonConfig.grades.crafting)
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = Config.Locale['no_permission']
        })
        return
    end
    
    -- Find recipe
    local recipe = FindRecipe(itemName)
    if not recipe then
        DebugPrint('Recipe not found:', itemName)
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Recipe not found.'
        })
        return
    end
    
    -- Check ingredients
    local hasAll, missingItem = HasIngredients(Player, recipe)
    if not hasAll then
        DebugPrint('Missing ingredient:', missingItem)
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = Config.Locale['missing_ingredients']
        })
        return
    end
    
    -- Remove ingredients
    RemoveIngredients(Player, recipe)
    DebugPrint('Removed ingredients for:', itemName)
    
    -- Add to storage with yield
    local yieldAmount = recipe.yield or 1
    AddToStorage(saloonId, itemName, yieldAmount)
    DebugPrint('Added to storage:', itemName, 'x', yieldAmount)
    
    -- Log transaction
    local citizenid = Player.PlayerData.citizenid
    local playerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    LogCraft(saloonId, citizenid, playerName, itemName, yieldAmount)
    UpdateEmployeeStats(saloonId, citizenid, playerName, yieldAmount)
    
    -- Notify player
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = string.format(Config.Locale['crafting_success'], yieldAmount, recipe.label)
    })
    
    -- Trigger UI refresh
    TriggerClientEvent('rsg-saloon-premium:client:refreshUI', source, saloonId)
end)

print('^2[RSG-Saloon-Premium]^0 Crafting module loaded!')
