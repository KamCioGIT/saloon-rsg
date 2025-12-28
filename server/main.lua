-- ============================================================================
-- RSG SALOON PREMIUM - SERVER MAIN
-- Core server-side logic and initialization
-- ============================================================================

local RSGCore = exports['rsg-core']:GetCoreObject()

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Debug print helper
local function DebugPrint(...)
    if Config.Debug then
        print('[Saloon Premium]', ...)
    end
end

-- Get player's saloon job and grade
local function GetPlayerSaloonInfo(source)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return nil, nil end
    
    local job = Player.PlayerData.job.name
    local grade = Player.PlayerData.job.grade.level
    
    -- Check if player works at any saloon
    if Config.Saloons[job] then
        return job, grade
    end
    
    return nil, nil
end

-- Check if player has required grade for action
local function HasPermission(source, saloon, action)
    local job, grade = GetPlayerSaloonInfo(source)
    
    if not job then return false end
    if job ~= saloon then return false end
    
    local saloonConfig = Config.Saloons[saloon]
    if not saloonConfig then return false end
    
    local requiredGrade = saloonConfig.grades[action] or 999
    return grade >= requiredGrade
end

-- Get player character name
local function GetPlayerName(source)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return 'Unknown' end
    return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
end

-- Get player citizenid
local function GetCitizenId(source)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return nil end
    return Player.PlayerData.citizenid
end

-- ============================================================================
-- EXPORTS FOR OTHER RESOURCES
-- ============================================================================

exports('GetSaloonInfo', function(saloonId)
    return Config.Saloons[saloonId]
end)

exports('GetAllSaloons', function()
    return Config.Saloons
end)

-- ============================================================================
-- PLAYER DATA CALLBACKS
-- ============================================================================

-- Get saloon data for UI
RSGCore.Functions.CreateCallback('rsg-saloon-premium:server:getSaloonData', function(source, cb, saloonId)
    local job, grade = GetPlayerSaloonInfo(source)
    local isEmployee = job == saloonId
    local saloonConfig = Config.Saloons[saloonId]
    
    if not saloonConfig then
        cb(nil)
        return
    end
    
    -- Get shop stock
    local shopStock = MySQL.query.await('SELECT * FROM saloon_premium_stock WHERE saloon = ?', { saloonId })
    
    -- Get storage (only for employees)
    local storage = {}
    if isEmployee then
        storage = MySQL.query.await('SELECT * FROM saloon_premium_storage WHERE saloon = ?', { saloonId })
    end
    
    -- Get cashbox balance (only for managers+)
    local cashboxBalance = 0
    if isEmployee and grade >= saloonConfig.grades.cashbox then
        local cashboxData = MySQL.query.await('SELECT balance FROM saloon_premium_cashbox WHERE saloon = ?', { saloonId })
        if cashboxData and cashboxData[1] then
            cashboxBalance = cashboxData[1].balance
        end
    end
    
    -- Get recent transactions (only for managers+)
    local transactions = {}
    if isEmployee and grade >= saloonConfig.grades.cashbox then
        transactions = MySQL.query.await(
            'SELECT * FROM saloon_premium_transactions WHERE saloon = ? ORDER BY timestamp DESC LIMIT 50',
            { saloonId }
        )
    end
    
    -- Build response
    local data = {
        saloonId = saloonId,
        saloonName = saloonConfig.name,
        isEmployee = isEmployee,
        playerGrade = grade or 0,
        permissions = {
            canCraft = isEmployee and (grade >= saloonConfig.grades.crafting),
            canRefill = isEmployee and (grade >= saloonConfig.grades.refill),
            canCashbox = isEmployee and (grade >= saloonConfig.grades.cashbox),
            canManageEmployees = isEmployee and (grade >= saloonConfig.grades.employees),
        },
        shopStock = shopStock or {},
        storage = storage or {},
        cashboxBalance = cashboxBalance,
        transactions = transactions or {},
        recipes = Config.Recipes,
        defaultPrices = Config.DefaultPrices,
    }
    
    DebugPrint('Sending saloon data for:', saloonId, 'Employee:', isEmployee)
    cb(data)
end)

-- Get player inventory for crafting check
RSGCore.Functions.CreateCallback('rsg-saloon-premium:server:getPlayerInventory', function(source, cb)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then
        cb({})
        return
    end
    
    local inventory = {}
    for _, item in pairs(Player.PlayerData.items) do
        if item then
            if inventory[item.name] then
                inventory[item.name] = inventory[item.name] + item.amount
            else
                inventory[item.name] = item.amount
            end
        end
    end
    
    cb(inventory)
end)

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

-- Initialize cashbox entries for all saloons on resource start
CreateThread(function()
    for saloonId, saloonConfig in pairs(Config.Saloons) do
        MySQL.query.await([[
            INSERT IGNORE INTO saloon_premium_cashbox (saloon, balance) VALUES (?, 0)
        ]], { saloonId })
        
        -- Register stash for each saloon's personal storage
        exports['rsg-inventory']:CreateInventory('saloon_storage_' .. saloonId, {
            label = saloonConfig.name .. ' Storage',
            maxweight = 500000,  -- 500kg max weight
            slots = 100,        -- 100 slots
        })
    end
    DebugPrint('Initialized cashbox entries and storage stashes for all saloons')
end)

-- ============================================================================
-- PERSONAL STORAGE (RSG-INVENTORY STASH)
-- ============================================================================

-- Server event to open personal saloon storage
RegisterNetEvent('rsg-saloon:server:openStorage', function(saloonId)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Verify player is employee of this saloon
    local job = Player.PlayerData.job.name
    if job ~= saloonId then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'You do not work at this saloon.'
        })
        return
    end
    
    local saloonConfig = Config.Saloons[saloonId]
    if not saloonConfig then return end
    
    -- Open the stash
    local stashName = 'saloon_storage_' .. saloonId
    exports['rsg-inventory']:OpenInventory(src, stashName, {
        label = saloonConfig.name .. ' Storage',
        maxweight = 500000,
        slots = 100,
    })
    
    DebugPrint('Opened storage for:', saloonId, 'Player:', GetPlayerName(src))
end)

print('^2[RSG-Saloon-Premium]^0 Server loaded successfully!')
