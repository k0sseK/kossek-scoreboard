local Scoreboard = {
    players = {},
    counter = {}
}

local function GetSteam(playerId)
    for i = 0, GetNumPlayerIdentifiers(playerId) - 1 do
        local prefix, identifier = string.strsplit(':', GetPlayerIdentifier(playerId, i))

        if prefix == 'steam' then
            return identifier
        end
    end

    print('^0[^1ERROR^0] ^0Unable to find your steam id')
    return false
end

local function GetAvatar(playerId)
    local steamHex = GetSteam(playerId)

    local p = promise.new()
    if steamHex and steamHex ~= '' then
        local steamId = tonumber(steamHex, 16)

        if steamId then
            PerformHttpRequest('http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=' .. GetConvar('steam_webApiKey') .. '&steamids=' .. steamId, function(e, data, h)
                local data = json.decode(data) or {}
                if data and data.response and data.response.players[1] then
                    local avatar = data.response.players[1].avatarfull
                    p:resolve(avatar)
                end
            end)
        end
    else
        print("^0[^1ERROR^0] ^0Unable to find your steam avatar, because you don't have steam id")
        p:resolve(false)
    end

    return Citizen.Await(p)
end

local function UpdateCounter()
    Wait(1000)
    Scoreboard.counter = { players = 0, police = 0, ambulance = 0, mechanic = 0 }

    for i, data in pairs(Scoreboard.players) do
        Scoreboard.counter.players += 1
        
        if data.job == 'police' then
            Scoreboard.counter.police += 1
        elseif data.job == 'ambulance' then
            Scoreboard.counter.ambulance += 1
        elseif data.job == 'mechanic' then
            Scoreboard.counter.mechanic += 1
        end 
    end

    GlobalState['scoreboard_counter'] = Scoreboard.counter
end

function AddPlayer(player, restart)
    local playerId = GetSource(player)

    Scoreboard.players[playerId] = {
        id = playerId,
        identifier = GetSteam(playerId),
        name = GetPlayerName(playerId),
        avatar = GetAvatar(playerId),
        job = GetPlayerJob(player).name
    }

    if not restart then
        TriggerClientEvent('kossek-scoreboard:addPlayer', -1, Scoreboard.players[playerId])
        UpdateCounter()
    end
end

function PlayerLoaded(player)
    if player then
        AddPlayer(player)
        TriggerClientEvent('kossek-scoreboard:playerLoaded', GetSource(player), Scoreboard.players)
    end
end

function RemovePlayer(playerId)
    if playerId then
        TriggerClientEvent('kossek-scoreboard:removePlayer', -1, Scoreboard.players[playerId])
        Scoreboard.players[playerId] = nil

        UpdateCounter()
    end
end

function UpdatePlayerJob(playerId, job)
    if playerId then
        Scoreboard.players[playerId].job = job.name

        UpdateCounter()
    end
end

AddEventHandler('playerDropped', function()
    local source = source
    RemovePlayer(source)
end)

AddEventHandler('onResourceStart', function(name)
	if name == GetCurrentResourceName() then
		local players = GetServerPlayers()

		if #players > 0 then
			for i=1, #players do
				local player = GetPlayerFromId(GetSource(players[i]))

				if player then
					AddPlayer(player, true)
				end
			end
            
            UpdateCounter()
            TriggerClientEvent('kossek-scoreboard:playerLoaded', -1, Scoreboard.players)
		end
	end
end)