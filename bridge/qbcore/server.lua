if GetResourceState('qb-core') ~= 'started' then return end

QBCore = exports['qb-core']:GetCoreObject()

AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
	AddPlayer(player)
end)

AddEventHandler('QBCore:Server:OnJobUpdate', function(playerId, job)
	UpdatePlayerJob(playerId, job)
end)

AddEventHandler('QBCore:Server:OnPlayerUnload', function(playerId)
    RemovePlayer(playerId)
end)

function GetSource(player)
    return player.PlayerData.source
end

function GetPlayerJob(player)
    return player.job
end

function GetPlayerFromId(source)
    return QBCore.Functions.GetPlayer(source)
end

function GerServerPlayers()
    return QBCore.Functions.GetQBPlayers()
end