-- ============================================================================
-- RSG SALOON PREMIUM - SERVER EMPLOYEES
-- Hire/fire employee management
-- ============================================================================

local RSGCore = exports['rsg-core']:GetCoreObject()

-- ============================================================================
-- HIRE PLAYER
-- ============================================================================

RegisterNetEvent('rsg-saloon-premium:server:hirePlayer', function(targetId, saloonId, grade)
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
    
    local saloonConfig = Config.Saloons[saloonId]
    if not saloonConfig then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Invalid saloon.'
        })
        return
    end
    
    -- Check if hiring player has permission (grade 3 = owner)
    local playerJob = Player.PlayerData.job.name
    local playerGrade = Player.PlayerData.job.grade.level
    
    if playerJob ~= saloonId or playerGrade < saloonConfig.grades.employees then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'You do not have permission to hire employees.'
        })
        return
    end
    
    -- Validate grade
    grade = tonumber(grade) or 0
    if grade < 0 or grade > 3 then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Invalid grade (must be 0-3).'
        })
        return
    end
    
    -- Cannot hire someone to a higher grade than yourself
    if grade >= playerGrade then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Cannot hire someone to a grade equal or higher than yours.'
        })
        return
    end
    
    -- Set target player's job
    TargetPlayer.Functions.SetJob(saloonId, grade)
    
    -- Notify both players
    local targetName = TargetPlayer.PlayerData.charinfo.firstname .. ' ' .. TargetPlayer.PlayerData.charinfo.lastname
    local gradeLabel = GetGradeLabel(grade)
    
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = string.format('Hired %s as %s', targetName, gradeLabel)
    })
    
    TriggerClientEvent('ox_lib:notify', targetId, {
        type = 'success',
        description = string.format('You have been hired at %s as %s!', saloonConfig.name, gradeLabel)
    })
    
    -- Add to employee stats table
    MySQL.query.await([[
        INSERT IGNORE INTO saloon_premium_employees (saloon, citizenid, player_name)
        VALUES (?, ?, ?)
    ]], { saloonId, TargetPlayer.PlayerData.citizenid, targetName })
    
    if Config.Debug then
        print('[Saloon] Hired:', targetName, 'at', saloonId, 'grade', grade)
    end
end)

-- ============================================================================
-- FIRE PLAYER
-- ============================================================================

RegisterNetEvent('rsg-saloon-premium:server:firePlayer', function(targetCitizenId, saloonId)
    local source = source
    local Player = RSGCore.Functions.GetPlayer(source)
    
    if not Player then return end
    
    local saloonConfig = Config.Saloons[saloonId]
    if not saloonConfig then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Invalid saloon.'
        })
        return
    end
    
    -- Check if firing player has permission
    local playerJob = Player.PlayerData.job.name
    local playerGrade = Player.PlayerData.job.grade.level
    
    if playerJob ~= saloonId or playerGrade < saloonConfig.grades.employees then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'You do not have permission to fire employees.'
        })
        return
    end
    
    -- Find target player (could be online or offline)
    local TargetPlayer = RSGCore.Functions.GetPlayerByCitizenId(targetCitizenId)
    
    if TargetPlayer then
        -- Player is online
        local targetGrade = TargetPlayer.PlayerData.job.grade.level
        
        -- Cannot fire someone of equal or higher grade
        if targetGrade >= playerGrade then
            TriggerClientEvent('ox_lib:notify', source, {
                type = 'error',
                description = 'Cannot fire someone of equal or higher rank.'
            })
            return
        end
        
        -- Set to unemployed
        TargetPlayer.Functions.SetJob('unemployed', 0)
        
        TriggerClientEvent('ox_lib:notify', TargetPlayer.PlayerData.source, {
            type = 'error',
            description = string.format('You have been fired from %s!', saloonConfig.name)
        })
    else
        -- Player is offline - update database directly
        MySQL.query.await([[
            UPDATE players SET job = 'unemployed', job_grade = 0 
            WHERE citizenid = ? AND job = ?
        ]], { targetCitizenId, saloonId })
    end
    
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = 'Employee has been fired.'
    })
    
    if Config.Debug then
        print('[Saloon] Fired:', targetCitizenId, 'from', saloonId)
    end
end)

-- ============================================================================
-- GET EMPLOYEES LIST
-- ============================================================================

RSGCore.Functions.CreateCallback('rsg-saloon-premium:server:getEmployees', function(source, cb, saloonId)
    local Player = RSGCore.Functions.GetPlayer(source)
    
    if not Player then
        cb({})
        return
    end
    
    local saloonConfig = Config.Saloons[saloonId]
    if not saloonConfig then
        cb({})
        return
    end
    
    -- Check permission
    local playerJob = Player.PlayerData.job.name
    local playerGrade = Player.PlayerData.job.grade.level
    
    if playerJob ~= saloonId or playerGrade < saloonConfig.grades.employees then
        cb({})
        return
    end
    
    -- Get all employees for this saloon from players table
    local employees = MySQL.query.await([[
        SELECT p.citizenid, p.charinfo, p.job_grade,
               COALESCE(e.items_crafted, 0) as items_crafted,
               COALESCE(e.sales_total, 0) as sales_total,
               COALESCE(e.tips_earned, 0) as tips_earned
        FROM players p
        LEFT JOIN saloon_premium_employees e ON p.citizenid = e.citizenid AND e.saloon = ?
        WHERE p.job = ?
        ORDER BY p.job_grade DESC
    ]], { saloonId, saloonId })
    
    -- Parse charinfo to get names
    local result = {}
    for _, emp in ipairs(employees or {}) do
        local charinfo = json.decode(emp.charinfo or '{}')
        table.insert(result, {
            citizenid = emp.citizenid,
            firstname = charinfo.firstname or 'Unknown',
            lastname = charinfo.lastname or '',
            grade = emp.job_grade,
            gradeLabel = GetGradeLabel(emp.job_grade),
            itemsCrafted = emp.items_crafted,
            salesTotal = emp.sales_total,
            tipsEarned = emp.tips_earned
        })
    end
    
    cb(result)
end)

-- ============================================================================
-- GET NEARBY PLAYERS (for hiring)
-- ============================================================================

RSGCore.Functions.CreateCallback('rsg-saloon-premium:server:getNearbyPlayers', function(source, cb)
    local Player = RSGCore.Functions.GetPlayer(source)
    
    if not Player then
        cb({})
        return
    end
    
    local players = RSGCore.Functions.GetPlayers()
    local result = {}
    
    for _, playerId in ipairs(players) do
        if playerId ~= source then
            local TargetPlayer = RSGCore.Functions.GetPlayer(playerId)
            if TargetPlayer then
                table.insert(result, {
                    id = playerId,
                    citizenid = TargetPlayer.PlayerData.citizenid,
                    name = TargetPlayer.PlayerData.charinfo.firstname .. ' ' .. TargetPlayer.PlayerData.charinfo.lastname,
                    currentJob = TargetPlayer.PlayerData.job.label
                })
            end
        end
    end
    
    cb(result)
end)

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

function GetGradeLabel(grade)
    local labels = {
        [0] = 'Helper',
        [1] = 'Bartender',
        [2] = 'Manager',
        [3] = 'Owner'
    }
    return labels[grade] or 'Unknown'
end

print('^2[RSG-Saloon-Premium]^0 Employees module loaded!')
