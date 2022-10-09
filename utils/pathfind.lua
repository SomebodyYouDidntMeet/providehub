local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
 
local path = PathfindingService:CreatePath()
 
local player = Players.LocalPlayer
local character = player.Character
local humanoid = character:WaitForChild("Humanoid")
 
shared.Destinations = {
    --put ur destination
    TEST = Vector3.new(87.41336059570312, -9.901970863342285, 282.98681640625)
}
 
local waypoints
local nextWaypointIndex
local reachedConnection
local blockedConnection
 
local function goto(destination)
	-- Compute the path
	local success, errorMessage = pcall(function()
		path:ComputeAsync(character.PrimaryPart.Position, destination)
	end)
 
	if success and path.Status == Enum.PathStatus.Success then
		-- Get the path waypoints
		waypoints = path:GetWaypoints()
 
		-- Detect if path becomes blocked
		blockedConnection = path.Blocked:Connect(function(blockedWaypointIndex)
			-- Check if the obstacle is further down the path
			if blockedWaypointIndex >= nextWaypointIndex then
				-- Stop detecting path blockage until path is re-computed
				blockedConnection:Disconnect()
				-- Call function to re-compute new path
				followPath(destination)
			end
		end)
 
		-- Detect when movement to next waypoint is complete
		if not reachedConnection then
			reachedConnection = humanoid.MoveToFinished:Connect(function(reached)
				if reached and nextWaypointIndex < #waypoints then
					-- Increase waypoint index and move to next waypoint
					nextWaypointIndex += 1
					humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
				else
					reachedConnection:Disconnect()
					blockedConnection:Disconnect()
				end
			end)
		end
 
		-- Initially move to second waypoint (first waypoint is path start; skip it)
		nextWaypointIndex = 2
		humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
	else
		warn("Path not computed!", errorMessage)
	end
end
 
goto(Destinations.TEST)