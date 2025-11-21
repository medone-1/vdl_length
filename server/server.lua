-- =================================================================
-- vdl_length – Server Side
-- =================================================================

-- Get VORP Core
local VORPcore = {}
TriggerEvent("getCore", function(obj) VORPcore = obj end)

-- ================================================================
-- Checks if a player is admin based ONLY on Steam Hex
-- ================================================================
local function IsAdmin(src)
    if not Config.AdminCommand then return false end

    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        -- Only Steam identifier is validated
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
    local user = VORPcore.getUser(src)
    if not user or not user.getUsedCharacter then return end

    local charId = user.getUsedCharacter.charIdentifier
    if not charId then return end

    -- Fetch the saved scale from DB
    exports.oxmysql:scalar(
        'SELECT tail_length FROM characters WHERE charIdentifier = ?',
        { charId },
        function(result)
            -- Convert & clamp between min/max defined in config
            local scale = tonumber(result) or 1.0
            scale = math.max(Config.MinScale, math.min(Config.MaxScale, scale))

            -- Send to client for immediate application
            TriggerClientEvent("vdl_length:apply", src, scale)
        end
    )
end

-- ================================================================
-- When player selects a character → load scale
-- ================================================================
RegisterNetEvent('vorp:SelectedCharacter', function()
    LoadAndApplyScale(source)
end)

-- ================================================================
-- Client requests scale (e.g., after skin/model change)
-- ================================================================
RegisterNetEvent('vdl_length:request', function()
    LoadAndApplyScale(source)
end)

-- ================================================================
-- Player command: Refresh their scale from database
-- ================================================================
RegisterCommand("refreshped", function(src)
    if src == 0 then return end -- Prevent console usage

    LoadAndApplyScale(src)
    VORPcore.NotifyRightTip(src, Config.Notify .. "Scale refreshed", 3000)
end, false)

-- ================================================================
-- ADMIN COMMAND: /length <playerID> <value>
-- Allows admins to modify a player's scale and save it
-- ================================================================
if Config.AdminCommand then
    RegisterCommand("length", function(src, args)
        -- Check admin rights (Steam hex only)
        if src ~= 0 and not IsAdmin(src) then
            VORPcore.NotifyRightTip(src, Config.Notify .. "No permission", 4000)
            return
        end

        local targetId = tonumber(args[1])
        local value    = tonumber(args[2])

        -- Validate input
        if not targetId or not value or value < Config.MinScale or value > Config.MaxScale then
            VORPcore.NotifyRightTip(src, "/length <playerID> <0.1-4.0>", 5000)
            return
        end

        -- Check target exists
        if not GetPlayerName(targetId) then
            VORPcore.NotifyRightTip(src, Config.Notify .. "Player not found", 4000)
            return
        end

        local targetUser = VORPcore.getUser(targetId)
        if not targetUser then return end

        local charId = targetUser.getUsedCharacter.charIdentifier

        -- Save new scale
        exports.oxmysql:execute(
            'UPDATE characters SET tail_length = ? WHERE charIdentifier = ?',
            { value, charId }
        )

        -- Apply instantly
        TriggerClientEvent("vdl_length:apply", targetId, value)

        -- Feedback to admin only
        VORPcore.NotifyRightTip(
            src,
            Config.Notify .. "length → " .. value .. " | ID: " .. targetId .. " (" .. GetPlayerName(targetId) .. ")",
            6000
        )
    end, true) -- ACE permission supported
end
