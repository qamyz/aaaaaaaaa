local Players = game:GetService("Players")
local UserInput = game:GetService("UserInputService")
local HTTP = game:GetService("HttpService")
local RunServ = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local CharacterAdded
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
PlayerGui:SetTopbarTransparency(1)
local Mouse = LocalPlayer:GetMouse()
getgenv().methodsTable = {"Ray", "Raycast", "FindPartOnRay", "FindPartOnRayWithIgnoreList", "FindPartOnRayWithWhitelist"}

local rigType = string.split(tostring(LocalPlayer.Character:WaitForChild("Humanoid").RigType), ".")[3]
local selected_teamType = "Regular"
local selected_rigType

local rigTypeR6 = {
	["Head"] = true,
	["Torso"] = true,
	["LowerTorso"] = true,
	["Left Arm"] = true,
	["Right Arm"] = true,
	["Left Leg"] = true,
	["Right Leg"] = true
}


if rigType == "R6" then
    selected_rigType = rigTypeR6
end

local function teamType(player)
        if player == LocalPlayer then
            return tostring(BrickColor.new(0.172549, 0.329412, 1))
        else
        for _, Player in next, Players:GetPlayers() do
            if Player.Character then
                if Player.Character:FindFirstChild("Head") then
                    if Player.Character == player.Character then
                        if Player.Character.Head:FindFirstChild("NameTag") then
                            NameTag = Player.Character.Head.NameTag.TextLabel
                        if string.find(tostring(BrickColor.new(NameTag.TextColor3)), "red") then
                            return tostring(BrickColor.new(NameTag.TextColor3))
                        elseif string.find(tostring(BrickColor.new(NameTag.TextStrokeColor3)), "blue") then
                            return tostring(BrickColor.new(NameTag.TextStrokeColor3))
                        end
                    end
                end
            end
        end
        if player == LocalPlayer then
            return tostring(BrickColor.new(0, 255, 0))
        else
            for _, Player in next, game.Players:GetPlayers() do
                if Player.Character then
                    if Player.Character:FindFirstChild("Head") then
                        if Player.Character == player.Character then
                            return tostring(BrickColor.new(Player.Character.Head.HeadTag.Label.TextColor3))
                        end
                    end
                end
                if player.Team or player.TeamColor then
                        local teamplayer = player.Team or player.TeamColor
                        return teamplayer
                    end
                end
            end
        end
    end
end

local function characterType(player)
    if player.Character or workspace:FindFirstChild(player.Name) then
        local playerCharacter = player.Character or workspace:FindFirstChild(player.Name)
        return playerCharacter
    end
end

local function FFA()
    sameTeam = 0
    for _, player in next, Players:GetPlayers() do
        if teamType(player) == teamType(LocalPlayer) then
            sameTeam = sameTeam + 1
        end
    end
    if sameTeam == #Players:GetChildren() then
        return true
    else
        return false
    end
end

local function returnVisibility(player)
    if getgenv().VisibiltyCheck then
        if characterType(player) then 
            if player.Character:FindFirstChild(getgenv().SelectedPart) then 
                CastPoint = {LocalPlayer.Character[getgenv().SelectedPart].Position, player.Character[getgenv().SelectedPart].Position}
                IgnoreList = {player.Character, LocalPlayer.Character}
                local castpointparts = workspace.CurrentCamera:GetPartsObscuringTarget(CastPoint, IgnoreList)
                if unpack(castpointparts) then
                    return false
                end
            end
        end
    end
    return true
end

local function returnRay(args, hit)
    CCF = Camera.CFrame.p
    args[2] = Ray.new(CCF, (hit.Position + Vector3.new(0,(CCF-hit.Position).Magnitude/getgenv().Distance,0) - CCF).unit * (getgenv().Distance * 10))
    return args[2]
end

spawn(function()
    local Circle = Drawing.new('Circle')
    Circle.Transparency = 1
    Circle.Thickness = 1.5
    Circle.Visible = true
    Circle.Color = Color3.fromRGB(255,0,0)
    Circle.Filled = false
    Circle.Radius = getgenv().FOV

    local TargetText = Drawing.new("Text")
    getgenv().SelectedTarget = ""
    TargetText.Text = ""
    TargetText.Size = 17
    TargetText.Center = true
    TargetText.Visible = true
    TargetText.Color = Color3.fromRGB(255,0,0)
    TargetText.Font = Drawing.Fonts.Monospace

    RunServ:BindToRenderStep("Get_Fov",1,function()
        local Length = 10
        local Middle = 37
        Circle.Visible = getgenv().CircleVisibility
	TargetText.Visible = getgenv().CircleVisibility
        Circle.Color = Color3.fromRGB(255,0,0)
	Circle.Radius = getgenv().FOV
        Circle.Position = Vector2.new(Mouse.X,Mouse.Y+Middle)
	TargetText.Position = Vector2.new(Mouse.X,Mouse.Y+Middle-180)
	TargetText.Text = getgenv().SelectedTarget
    end)
end)

function getTarget()
	local closestTarg = math.huge
	local Target = nil

	for _, Player in next, Players:GetPlayers() do
        if Player ~= LocalPlayer and returnVisibility(Player) and teamType(Player) ~= teamType(LocalPlayer) or FFA() and Player ~= LocalPlayer and returnVisibility(Player) then
            local playerCharacter = characterType(Player)
            if playerCharacter then
                local playerHumanoid = playerCharacter:FindFirstChild("Humanoid")
                local playerHumanoidRP = playerCharacter:FindFirstChild(getgenv().SelectedPart)
                if playerHumanoidRP and playerHumanoid then
                    local hitVector, onScreen = Camera:WorldToScreenPoint(playerHumanoidRP.Position)
                    if onScreen and playerHumanoid.Health > 0 then
                        local CCF = Camera.CFrame.p
                        if workspace:FindPartOnRayWithIgnoreList(Ray.new(CCF, (playerHumanoidRP.Position-CCF).unit * getgenv().Distance),{Player}) then
                            local hitTargMagnitude = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(hitVector.X, hitVector.Y)).magnitude
                            if hitTargMagnitude < closestTarg and hitTargMagnitude <= getgenv().FOV then
                                Target = Player
                                closestTarg = hitTargMagnitude
                            end
                        else
                        end
                    else
                    end
                end
            end
		end
	end
	return Target
end

local mt = getrawmetatable(game)
setreadonly(mt, false)
local index = mt.__index
local namecall = mt.__namecall
local hookfunc

mt.__namecall = newcclosure(function(...)
    local method = getnamecallmethod()
    local args = {...}
    for _, rayMethod in next, getgenv().methodsTable do
        if tostring(method) == rayMethod and Hit then
            returnRay(args, Hit)
            return namecall(unpack(args))
        end
    end
    return namecall(unpack(args))
end)

mt.__index = newcclosure(function(func, idx)
    if func == Mouse and tostring(idx) == "Hit" and Hit then
        return Hit.CFrame
    end
    return index(func, idx)
end)

hookfunc = hookfunction(workspace.FindPartOnRayWithIgnoreList, function(...)
    local args = {...}
    if Hit then
        returnRay(args, Hit)
    end
    return hookfunc(unpack(args))
end)

RunServ:BindToRenderStep("Get_Target",1,function()
    local Target = getTarget()
    if not Target then
        Hit = nil
        getgenv().SelectedTarget = ""
    else
        getgenv().SelectedTarget = Target.Name .. "\n" .. math.floor((LocalPlayer.Character[getgenv().SelectedPart].Position - Target.Character[getgenv().SelectedPart].Position).magnitude) .. " Studs"
    end
    if UserInput:IsMouseButtonPressed(0) then
        if Target then
            Hit = Target.Character[getgenv().SelectedPart]
        end
    else
        Hit = nil
    end
end)
