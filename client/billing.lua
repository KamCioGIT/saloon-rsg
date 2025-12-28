-- ============================================================================
-- RSG SALOON PREMIUM - CLIENT BILLING
-- Customer billing and invoice system
-- ============================================================================

local RSGCore = exports['rsg-core']:GetCoreObject()

-- ============================================================================
-- NUI CALLBACK - CREATE BILL
-- ============================================================================

RegisterNUICallback('createBill', function(data, cb)
    local closestPlayer, closestDistance = GetClosestPlayer()
    
    if closestPlayer == -1 or closestDistance > 3.0 then
        lib.notify({ type = 'error', description = 'No player nearby!' })
        cb({ success = false })
        return
    end
    
    -- Open input dialog for bill
    local input = lib.inputDialog('Create Bill', {
        { type = 'input', label = 'Bill Description', required = true, placeholder = 'Food & Drinks' },
        { type = 'number', label = 'Amount ($)', required = true, min = 1, max = 10000 }
    })
    
    if not input then
        cb({ success = false })
        return
    end
    
    local billName = input[1]
    local billAmount = tonumber(input[2])
    
    if not billName or #billName < 1 then
        lib.notify({ type = 'error', description = 'Invalid bill name!' })
        cb({ success = false })
        return
    end
    
    if not billAmount or billAmount < 1 then
        lib.notify({ type = 'error', description = 'Invalid amount!' })
        cb({ success = false })
        return
    end
    
    TriggerServerEvent('rsg-saloon-premium:server:sendBill', 
        GetPlayerServerId(closestPlayer), 
        data.saloonId or 'valsaloontender',
        billName, 
        billAmount
    )
    
    cb({ success = true })
end)

-- ============================================================================
-- VIEW UNPAID BILLS
-- ============================================================================

RegisterNUICallback('viewBills', function(data, cb)
    local closestPlayer, closestDistance = GetClosestPlayer()
    
    if closestPlayer == -1 or closestDistance > 3.0 then
        lib.notify({ type = 'error', description = 'No player nearby!' })
        cb({ success = false })
        return
    end
    
    RSGCore.Functions.TriggerCallback('rsg-saloon-premium:server:getPlayerBills', function(bills)
        if not bills or #bills == 0 then
            lib.notify({ type = 'info', description = 'This player has no unpaid bills.' })
            cb({ success = false })
            return
        end
        
        -- Create menu options
        local options = {}
        for _, bill in ipairs(bills) do
            table.insert(options, {
                title = bill.label,
                description = string.format('$%.2f - %s', bill.amount, bill.created_at),
                metadata = {
                    { label = 'Bill ID', value = bill.id },
                    { label = 'Amount', value = '$' .. bill.amount }
                }
            })
        end
        
        lib.registerContext({
            id = 'player_bills',
            title = 'Unpaid Bills',
            options = options
        })
        
        lib.showContext('player_bills')
        cb({ success = true })
    end, GetPlayerServerId(closestPlayer))
end)

-- ============================================================================
-- RECEIVE BILL NOTIFICATION
-- ============================================================================

RegisterNetEvent('rsg-saloon-premium:client:receiveBill', function(billData)
    lib.notify({
        type = 'warning',
        title = 'New Bill',
        description = string.format('You received a bill: %s - $%.2f', billData.label, billData.amount),
        duration = 10000
    })
    
    -- Show alert for payment
    local alert = lib.alertDialog({
        header = 'Bill Received',
        content = string.format('**%s** has billed you **$%.2f** for: %s\n\nDo you want to pay now?', 
            billData.senderName or 'Staff', 
            billData.amount, 
            billData.label
        ),
        centered = true,
        cancel = true
    })
    
    if alert == 'confirm' then
        TriggerServerEvent('rsg-saloon-premium:server:payBill', billData.billId)
    end
end)

-- ============================================================================
-- PAY BILL FROM UI
-- ============================================================================

RegisterNUICallback('payBill', function(data, cb)
    if not data.billId then
        cb({ success = false })
        return
    end
    
    TriggerServerEvent('rsg-saloon-premium:server:payBill', data.billId)
    cb({ success = true })
end)

-- ============================================================================
-- VIEW OWN BILLS
-- ============================================================================

RegisterNUICallback('viewOwnBills', function(data, cb)
    RSGCore.Functions.TriggerCallback('rsg-saloon-premium:server:getOwnBills', function(bills)
        cb(bills or {})
    end)
end)

-- ============================================================================
-- HELPER FUNCTION
-- ============================================================================

function GetClosestPlayer()
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local playerPed = PlayerPedId()
    local playerId = PlayerId()
    local coords = GetEntityCoords(playerPed)
    
    for i = 1, #players do
        local targetPed = GetPlayerPed(players[i])
        
        if players[i] ~= playerId then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(coords - targetCoords)
            
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = players[i]
                closestDistance = distance
            end
        end
    end
    
    return closestPlayer, closestDistance
end

print('^2[RSG-Saloon-Premium]^0 Billing client module loaded!')
