for i,v in pairs(getconnections(game:GetService("ScriptContext").Error)) do
    v:Disable()
end

getgenv().CircleVisibility = true
getgenv().Distance = 1000

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

    RunServ:BindToRenderStep("Get_Fov",1,function()
        local Length = 10
        local Middle = 37
        Circle.Visible = getgenv().CircleVisibility
        Circle.Color = Color3.fromRGB(255,0,0)
	    Circle.Radius = getgenv().FOV
        Circle.Position = Vector2.new(Mouse.X,Mouse.Y+Middle)
    end)
end)

function getTarget()
	local closestTarg = math.huge
	local Target = nil

	for _, Player in next, Players:GetPlayers() do
        if Player ~= LocalPlayer and Player ~= LocalPlayer and Player.Character then
            local playerCharacter = Player.Character
            if playerCharacter then
                local playerHumanoid = playerCharacter:FindFirstChild("Humanoid")
                local playerHumanoidRP = playerCharacter:FindFirstChild(getgenv().Hitbox)
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
        getgenv().SelectedTarget = Target.Name .. "\n" .. math.floor((LocalPlayer.Character[getgenv().Hitbox].Position - Target.Character[getgenv().Hitbox].Position).magnitude) .. " Studs"
    end
    if UserInput:IsMouseButtonPressed(0) then
        if Target then
            Hit = Target.Character[getgenv().Hitbox]
        end
    else
        Hit = nil
    end
end)
