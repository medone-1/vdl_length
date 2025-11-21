-- =================================================================
-- vdl_length – Server Side
-- =================================================================

local VORPcore = {}
TriggerEvent("getCore", function(obj) VORPcore = obj end)

-- ================================================================
-- Checks if a player is admin based ONLY on Steam Hex
-- ================================================================
local function IsAdmin(src)
    if not Config.AdminCommand then return false end

    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        if string.match(identifier, "^steam:") then
            for _, adminSteam in ipairs(Config.Admins) do
                if identifier == adminSteam then
                    return true
                end
            end
        end
    end
    return false
end

-- ================================================================
-- Loads player scale from DB and sends it to client for application
-- ================================================================
local function LoadAndApplyScale(src)
    if src == 0 then return end
    local user = VORPcore.getUser(src)
    if not user or not user.getUsedCharacter then return end

    local charId = user.getUsedCharacter.charIdentifier
    if not charId then return end

    exports.oxmysql:scalar(
        'SELECT tail_length FROM characters WHERE charIdentifier = ?',
        { charId },
        function(result)
            local scale = tonumber(result) or 1.0
            scale = math.floor(scale * 10 + 0.5) / 10 -- round to 1 decimal
            scale = math.max(Config.MinScale, math.min(Config.MaxScale, scale))
            TriggerClientEvent("vdl_length:apply", src, scale)
        end
    )
end

-- ================================================================
-- Events
-- ================================================================
RegisterNetEvent('vorp:SelectedCharacter', function()
    LoadAndApplyScale(source)
end)

RegisterNetEvent('vdl_length:request', function()
    LoadAndApplyScale(source)
end)

-- ================================================================
-- Player command: refresh their scale
-- ================================================================
RegisterCommand("refreshped", function(src)
    LoadAndApplyScale(src)
    VORPcore.NotifyRightTip(src, Config.Notify .. "Scale refreshed", 3000)
end, false)

-- ================================================================
-- Admin command: set player scale and save to DB
-- ================================================================
if Config.AdminCommand then
    RegisterCommand("length", function(src, args)
        if src ~= 0 and not IsAdmin(src) then
            VORPcore.NotifyRightTip(src, Config.Notify .. "No permission", 4000)
            return
        end

        local targetId = tonumber(args[1])
        local value    = tonumber(args[2])

        if not targetId or not value or value < Config.MinScale or value > Config.MaxScale then
            VORPcore.NotifyRightTip(src, "/length <playerID> <0.1-4.0>", 5000)
            return
        end

        if not GetPlayerName(targetId) then
            VORPcore.NotifyRightTip(src, Config.Notify .. "Player not found", 4000)
            return
        end

        local targetUser = VORPcore.getUser(targetId)
        if not targetUser then return end
        local charId = targetUser.getUsedCharacter.charIdentifier

        value = math.floor(value * 10 + 0.5) / 10 -- round to 1 decimal

        exports.oxmysql:execute(
            'UPDATE characters SET tail_length = ? WHERE charIdentifier = ?',
            { value, charId }
        )

        TriggerClientEvent("vdl_length:apply", targetId, value)
        VORPcore.NotifyRightTip(
            src,
            Config.Notify .. "length → " .. value .. " | ID: " .. targetId .. " (" .. GetPlayerName(targetId) .. ")",
            6000
        )
    end, true)
end