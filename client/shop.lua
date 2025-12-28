-- ============================================================================
-- RSG SALOON PREMIUM - CLIENT SHOP
-- Handles purchase and refill UI callbacks
-- ============================================================================

local RSGCore = exports['rsg-core']:GetCoreObject()

-- ============================================================================
-- PURCHASE CALLBACK
-- ============================================================================

RegisterNUICallback('purchaseItem', function(data, cb)
    local saloonId = data.saloonId
    local itemName = data.item
    local quantity = tonumber(data.quantity) or 1
    local tip = tonumber(data.tip) or 0
    
    -- Validate quantity
    if quantity < 1 then
        cb({ success = false, error = 'Invalid quantity' })
        return
    end
    
    -- Send to server
    TriggerServerEvent('rsg-saloon-premium:server:purchaseItem', saloonId, itemName, quantity, tip)
    cb({ success = true })
end)

-- ============================================================================
-- REFILL SHOP CALLBACK
-- ============================================================================

RegisterNUICallback('refillShop', function(data, cb)
    local saloonId = data.saloonId
    local itemName = data.item
    local quantity = tonumber(data.quantity) or 1
    local price = tonumber(data.price) or 1.00
    
    -- Validate
    if quantity < 1 then
        cb({ success = false, error = 'Invalid quantity' })
        return
    end
    
    if price < 0.01 then
        cb({ success = false, error = 'Invalid price' })
        return
    end
    
    -- Send to server
    TriggerServerEvent('rsg-saloon-premium:server:refillShop', saloonId, itemName, quantity, price)
    cb({ success = true })
end)

-- ============================================================================
-- GET STORAGE CALLBACK
-- ============================================================================

RegisterNUICallback('getStorage', function(data, cb)
    local saloonId = data.saloonId
    
    RSGCore.Functions.TriggerCallback('rsg-saloon-premium:server:getStorage', function(storage)
        cb(storage or {})
    end, saloonId)
end)

-- ============================================================================
-- GET SHOP STOCK CALLBACK
-- ============================================================================

RegisterNUICallback('getShopStock', function(data, cb)
    local saloonId = data.saloonId
    
    RSGCore.Functions.TriggerCallback('rsg-saloon-premium:server:getShopStock', function(stock)
        cb(stock or {})
    end, saloonId)
end)
