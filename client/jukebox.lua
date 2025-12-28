-- ============================================================================
-- RSG SALOON PREMIUM - CLIENT JUKEBOX
-- Handles music playback and jukebox interactions
-- ============================================================================

local RSGCore = exports['rsg-core']:GetCoreObject()

-- State
local currentTrack = nil
local soundId = nil

-- ============================================================================
-- PLAY MUSIC
-- ============================================================================

RegisterNUICallback('jukeboxPlay', function(data, cb)
    if not Config.JukeboxEnabled then
        cb({ success = false, error = 'Jukebox disabled' })
        return
    end
    
    local trackIndex = tonumber(data.track) or 1
    local track = Config.JukeboxTracks[trackIndex]
    
    if not track then
        cb({ success = false, error = 'Track not found' })
        return
    end
    
    -- Stop current track if playing
    if soundId then
        StopSound(soundId)
        ReleaseSoundId(soundId)
        soundId = nil
    end
    
    -- Play new track
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    soundId = GetSoundId()
    -- Note: In RedM, audio playback is more limited
    -- This would need custom audio implementation via xSound or similar
    
    currentTrack = trackIndex
    
    lib.notify({
        type = 'success',
        description = string.format(Config.Locale['jukebox_playing'], track.name)
    })
    
    cb({ success = true, trackName = track.name })
end)

-- ============================================================================
-- STOP MUSIC
-- ============================================================================

RegisterNUICallback('jukeboxStop', function(_, cb)
    if soundId then
        StopSound(soundId)
        ReleaseSoundId(soundId)
        soundId = nil
    end
    
    currentTrack = nil
    
    lib.notify({
        type = 'info',
        description = Config.Locale['jukebox_stopped']
    })
    
    cb({ success = true })
end)

-- ============================================================================
-- SET VOLUME
-- ============================================================================

RegisterNUICallback('jukeboxVolume', function(data, cb)
    local volume = tonumber(data.volume) or 0.5
    volume = math.max(0, math.min(1, volume))
    
    -- Apply volume to current sound
    -- This would need proper audio library integration
    
    cb({ success = true, volume = volume })
end)

-- ============================================================================
-- GET TRACKS LIST
-- ============================================================================

RegisterNUICallback('getJukeboxTracks', function(_, cb)
    local tracks = {}
    for i, track in ipairs(Config.JukeboxTracks) do
        table.insert(tracks, {
            index = i,
            name = track.name,
            isPlaying = currentTrack == i,
        })
    end
    cb(tracks)
end)

-- ============================================================================
-- CLEANUP
-- ============================================================================

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    if soundId then
        StopSound(soundId)
        ReleaseSoundId(soundId)
    end
end)
