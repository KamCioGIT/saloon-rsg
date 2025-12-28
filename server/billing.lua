-- ============================================================================
-- RSG SALOON PREMIUM - SERVER BILLING
-- Invoice and billing system
-- ============================================================================

local RSGCore = exports['rsg-core']:GetCoreObject()

-- ============================================================================
-- SEND BILL TO PLAYER
-- ============================================================================

RegisterNetEvent('rsg-saloon-premium:server:sendBill', function(targetId, saloonId, billLabel, billAmount)
    local source = source
    local Player = RSGCore.Functions.GetPlayer(source)
    local TargetPlayer = RSGCore.Functions.GetPlayer(targetId)
    
    if not Player or not TargetPlayer then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Player not found.'
        })
        return
    end
    
    -- Validate amount
    billAmount = tonumber(billAmount) or 0
    if billAmount < 1 then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Invalid bill amount.'
        })
        return
    end
    
    -- Insert bill into database
    local billId = MySQL.insert.await([[
        INSERT INTO saloon_premium_bills (saloon, target_citizenid, sender_citizenid, label, amount)
        VALUES (?, ?, ?, ?, ?)
    ]], {
        saloonId,
        TargetPlayer.PlayerData.citizenid,
        Player.PlayerData.citizenid,
        billLabel,
        billAmount
    })
    
    -- Notify sender
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = string.format('Bill sent: %s - $%.2f', billLabel, billAmount)
    })
    
    -- Notify target
    local senderName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    TriggerClientEvent('rsg-saloon-premium:client:receiveBill', targetId, {
        billId = billId,
        label = billLabel,
        amount = billAmount,
        senderName = senderName,
        saloonId = saloonId
    })
    
    if Config.Debug then
        print('[Saloon] Bill created:', billId, billLabel, billAmount)
    end
end)

-- ============================================================================
-- PAY BILL
-- ============================================================================

RegisterNetEvent('rsg-saloon-premium:server:payBill', function(billId)
    local source = source
    local Player = RSGCore.Functions.GetPlayer(source)
    
    if not Player then return end
    
    -- Get bill info
    local billData = MySQL.query.await(
        'SELECT * FROM saloon_premium_bills WHERE id = ? AND target_citizenid = ? AND paid = FALSE',
        { billId, Player.PlayerData.citizenid }
    )
    
    if not billData or not billData[1] then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Bill not found or already paid.'
        })
        return
    end
    
    local bill = billData[1]
    local amount = bill.amount
    
    -- Check if player has enough money
    if Player.PlayerData.money.cash < amount then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Not enough cash to pay this bill.'
        })
        return
    end
    
    -- Remove money from player
    Player.Functions.RemoveMoney('cash', amount, 'bill-payment')
    
    -- Mark bill as paid
    MySQL.query.await('UPDATE saloon_premium_bills SET paid = TRUE WHERE id = ?', { billId })
    
    -- Add to saloon cashbox
    MySQL.query.await(
        'UPDATE saloon_premium_cashbox SET balance = balance + ? WHERE saloon = ?',
        { amount, bill.saloon }
    )
    
    -- Log transaction
    MySQL.query.await([[
        INSERT INTO saloon_premium_transactions (saloon, type, amount, citizenid, player_name)
        VALUES (?, 'sale', ?, ?, ?)
    ]], {
        bill.saloon,
        amount,
        Player.PlayerData.citizenid,
        Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    })
    
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = string.format('Bill paid: $%.2f', amount)
    })
    
    if Config.Debug then
        print('[Saloon] Bill paid:', billId, amount)
    end
end)

-- ============================================================================
-- GET PLAYER'S UNPAID BILLS (for staff viewing)
-- ============================================================================

RSGCore.Functions.CreateCallback('rsg-saloon-premium:server:getPlayerBills', function(source, cb, targetId)
    local TargetPlayer = RSGCore.Functions.GetPlayer(targetId)
    
    if not TargetPlayer then
        cb({})
        return
    end
    
    local bills = MySQL.query.await([[
        SELECT id, label, amount, created_at 
        FROM saloon_premium_bills 
        WHERE target_citizenid = ? AND paid = FALSE
        ORDER BY created_at DESC
    ]], { TargetPlayer.PlayerData.citizenid })
    
    cb(bills or {})
end)

-- ============================================================================
-- GET OWN UNPAID BILLS
-- ============================================================================

RSGCore.Functions.CreateCallback('rsg-saloon-premium:server:getOwnBills', function(source, cb)
    local Player = RSGCore.Functions.GetPlayer(source)
    
    if not Player then
        cb({})
        return
    end
    
    local bills = MySQL.query.await([[
        SELECT id, saloon, label, amount, created_at 
        FROM saloon_premium_bills 
        WHERE target_citizenid = ? AND paid = FALSE
        ORDER BY created_at DESC
    ]], { Player.PlayerData.citizenid })
    
    cb(bills or {})
end)

print('^2[RSG-Saloon-Premium]^0 Billing module loaded!')
