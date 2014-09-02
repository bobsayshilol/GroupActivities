local activities = {}

function OnClientModuleLoad(newPlayer)
	BroadcastActivities()
end
Events:Subscribe("ClientModuleLoad", OnClientModuleLoad)

function RemoveInactiveActivities()
	for _, value in pairs(activities) do
		if not value.active then
			activities[value.id] = nil
		end
	end
end

function BroadcastActivities()
	local activityTables = {}
	for id, activity in pairs(activities) do
		activityTables[id] = activity:ToTable()
	end
	print(#activityTables)
	Network:Broadcast("ActivityList", activityTables)
end

function OnActivityCreated(table)
	--we find the next free activityId
	local newActivity = Activity.FromTable(table)
	local i = 1
	while activities[i] ~= nil do
		i = i + 1
	end
	if newActivity.id == -1 then newActivity.id = i end
	activities[newActivity.id] = newActivity
	RemoveInactiveActivities()
	BroadcastActivities()
end
Network:Subscribe("ActivityCreated", OnActivityCreated)

function OnPlayerQuit(args)
	for _, value in pairs(activities) do
		if value:IsPlayerInActivity(args.player:GetId()) then
			value:PlayerQuit(args.player:GetId())
		end
	end

	RemoveInactiveActivities()
	BroadcastActivities()
end
Events:Subscribe("PlayerQuit", OnPlayerQuit)

function OnActivityLeft(args)
	activities[args.activityId]:PlayerQuit(args.playerId)
	RemoveInactiveActivities()
	BroadcastActivities()
end
Network:Subscribe("ActivityLeft", OnActivityLeft)

function OnActivityJoined(args)
	activities[args.activityId]:PlayerJoin(args.playerId)
	BroadcastActivities()
end
Network:Subscribe("ActivityJoined", OnActivityJoined)