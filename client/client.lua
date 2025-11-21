-- =================================================================
-- vdl_length – Client Side
-- =================================================================

local currentScale = 1.0

-- Apply scale to the local player ped
-- This function only applies the scale; it does NOT request anything from the server
local function ApplyScale()
    local ped = PlayerPedId()
    if ped and ped ~= 0 and DoesEntityExist(ped) then
        SetPedScale(ped, currentScale)
    end
end

-- Receive scale from server and apply it
-- Server always sends the scale stored in the database
RegisterNetEvent("vdl_length:apply", function(newScale)
    currentScale = tonumber(newScale) or 1.0

    -- Prevent values outside config limits
    currentScale = math.max(Config.MinScale, math.min(Config.MaxScale, currentScale))

    -- Apply scale immediately
    ApplyScale()
end)

-- Persistent loop to keep scale applied every frame
-- Required because some game events reset ped scale by default
CreateThread(function()
    while true do
        Wait(0)
        ApplyScale()
    end
end)

-- When player fully spawns, request the scale from server
AddEventHandler('vorp:playerSpawned', function()
    Wait(7000) -- Wait for ped to fully load
    TriggerServerEvent('vdl_length:request')
end)

-- Detect model/skin change (player changed clothes, morph, or switched ped)
-- When this happens, re-request the scale from the server
CreateThread(function()
    local lastPed = 0
    while true do
        Wait(1000)
        local ped = PlayerPedId()

        if ped ~= lastPed and ped ~= 0 then
            lastPed = ped
            Wait(4000) -- Wait for new ped to stabilize
            TriggerServerEvent('vdl_length:request')
        end
    end
end)
