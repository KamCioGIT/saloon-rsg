-- ============================================================================
-- RSG SALOON PREMIUM - SERVER SHOP
-- Handles customer purchases and shop management
-- ============================================================================

local RSGCore = exports['rsg-core']:GetCoreObject()

-- Debug print helper
local function DebugPrint(...)
    if Config.Debug then
        print('[Saloon Premium - Shop]', ...)
    end
end

-- ============================================================================
-- CUSTOMER PURCHASE
-- ============================================================================

RegisterNetEvent('rsg-saloon-premium:server:purchaseItem', function(saloonId, itemName, quantity, tip)
    local source = source
    local Player = RSGCore.Functions.GetPlayer(source)
    
    if not Player then return end
    
    quantity = math.max(1, math.floor(quantity or 1))
    tip = math.max(0, tip or 0)
    
    -- Get item from stock
    local stockData = MySQL.query.await(
        'SELECT * FROM saloon_premium_stock WHERE saloon = ? AND item = ?',
        { saloonId, itemName }
    )
    
    if not stockData or not stockData[1] then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = Config.Locale['out_of_stock']
        })
        return
    end
    
    local stock = stockData[1]
    
    -- Check stock quantity
    if stock.quantity < quantity then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = Config.Locale['out_of_stock']
        })
        return
    end
    
    -- Calculate total cost
    local totalCost = stock.price * quantity + tip
    
    -- Check if player has enough money
    local playerCash = Player.PlayerData.money.cash
    if playerCash < totalCost then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = Config.Locale['purchase_failed']
        })
        return
    end
    
    -- Remove money from player
    Player.Functions.RemoveMoney('cash', totalCost, 'saloon-purchase')
    
    -- Add item to player inventory
    Player.Functions.AddItem(itemName, quantity)
    TriggerClientEvent('inventory:client:ItemBox', source, RSGCore.Shared.Items[itemName], 'add', quantity)
    
    -- Update stock
    MySQL.query.await(
        'UPDATE saloon_premium_stock SET quantity = quantity - ? WHERE saloon = ? AND item = ?',
        { quantity, saloonId, itemName }
    )
    
    -- Add to cashbox (sale amount without tip for now, tip handled separately)
    local saleAmount = stock.price * quantity
    MySQL.query.await(
        'UPDATE saloon_premium_cashbox SET balance = balance + ? WHERE saloon = ?',
        { saleAmount, saloonId }
    )
    
    -- Log sale transaction
    local citizenid = Player.PlayerData.citizenid
    local playerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    
    MySQL.query.await([[
        INSERT INTO saloon_premium_transactions (saloon, type, amount, item, quantity, citizenid, player_name)
        VALUES (?, 'sale', ?, ?, ?, ?, ?)
    ]], { saloonId, saleAmount, itemName, quantity, citizenid, playerName })
    
    -- Handle tip
    if tip > 0 then
        MySQL.query.await(
            'UPDATE saloon_premium_cashbox SET balance = balance + ? WHERE saloon = ?',
            { tip, saloonId }
        )
        
        MySQL.query.await([[
            INSERT INTO saloon_premium_transactions (saloon, type, amount, citizenid, player_name)
            VALUES (?, 'tip', ?, ?, ?)
        ]], { saloonId, tip, citizenid, playerName })
    end
    
    -- Get item label
    local itemLabel = RSGCore.Shared.Items[itemName] and RSGCore.Shared.Items[itemName].label or itemName
    
    -- Notify player
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = string.format(Config.Locale['purchase_success'], quantity, itemLabel, totalCost)
    })
    
    -- Trigger UI refresh for all nearby players
    TriggerClientEvent('rsg-saloon-premium:client:refreshUI', -1, saloonId)
    
    DebugPrint('Purchase:', itemName, 'x', quantity, 'for $', totalCost, 'by', playerName)
end)

-- ============================================================================
-- GET SHOP STOCK (for UI)
-- ============================================================================

RSGCore.Functions.CreateCallback('rsg-saloon-premium:server:getShopStock', function(source, cb, saloonId)
    local stockData = MySQL.query.await(
        'SELECT item, quantity, price FROM saloon_premium_stock WHERE saloon = ? AND quantity > 0 ORDER BY item',
        { saloonId }
    )
    
    local enrichedStock = {}
    for _, stock in ipairs(stockData or {}) do
        local itemInfo = RSGCore.Shared.Items[stock.item]
        table.insert(enrichedStock, {
            item = stock.item,
            label = itemInfo and itemInfo.label or stock.item,
            quantity = stock.quantity,
            price = stock.price,
            image = itemInfo and itemInfo.image or (stock.item .. '.png'),
        })
    end
    
    cb(enrichedStock)
end)

print('^2[RSG-Saloon-Premium]^0 Shop module loaded!')
