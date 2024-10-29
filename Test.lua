-- Configuration
getgenv().SalvatoreBot = {
    Controllers = { "7472556141", "SalvatoreLogBotV3" }, 
    Prefix = "!",
}

local config = getgenv().SalvatoreBot
local controller  

-- Identify the controller at the start
for _, player in pairs(game.Players:GetPlayers()) do
    if player.UserId == 7472556141 or player.Name == "SalvatoreLogBotV3" then
        controller = player
        break
    end
end

-- Chat message sending function for the new chat system
function Chat(msg)
    local textChatService = game:GetService("TextChatService")
    if textChatService:FindFirstChild("TextChannels") then
        textChatService.TextChannels.RBXGeneral:SendAsync(msg)
    elseif game.ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
    end
end

-- Bus Bring Command
local function BusBringFunction(targetPlayerName)
    local targetPlayer = game:GetService("Players"):FindFirstChild(targetPlayerName)

    if not targetPlayer then
        Chat("The specified player was not found.")
        return
    end

    local localPlayer = game.Players.LocalPlayer
    local targetCharacter = targetPlayer.Character
    local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")

    if not targetCharacter or not targetHumanoid then
        Chat("The target player's character is not available.")
        return
    end

    if targetHumanoid.Sit then
        Chat("The target is currently sitting; bring cannot be used.")
        return
    end

    -- Teleport local player to bus seat location
    localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1054.22009, 2.9980247, -34.663887)
    wait(1)
    
    -- Spawn bus
    game:GetService("ReplicatedStorage").RE["1Ca1r"]:FireServer("PickingCar", "SchoolBus")
    wait(1)

    local playerCar = workspace.Vehicles[localPlayer.Name .. "Car"]
    if playerCar then
        local seat = playerCar.Body.VehicleSeat
        if seat then
            -- Attempt to sit player in bus seat
            local attempts = 0
            while not localPlayer.Character.Humanoid.Sit and attempts < 10 do
                localPlayer.Character.HumanoidRootPart.CFrame = seat.CFrame
                wait(0.5)
                attempts = attempts + 1
            end
        end
    else
        Chat("Could not spawn bus.")
        return
    end

    -- Teleport bus to target until they sit
    local success, error = pcall(function()
        local positions = { CFrame.new(0, -3, -3), CFrame.new(0, 0, -15), CFrame.new(0, -3, -3) }
        local positionIndex = 1
        while not targetHumanoid.Sit and targetPlayer.Character and targetHumanoid.Health > 0 do
            local targetCFrame = targetHumanoid.RootPart.CFrame
            playerCar:SetPrimaryPartCFrame(targetCFrame * positions[positionIndex])
            positionIndex = (positionIndex % #positions) + 1
            wait(0.5)
        end
    end)
    if not success then
        Chat("Error while bringing the target.")
        return
    end

    -- Teleport the bus to controller
    if controller and controller.Character then
        local controllerPrimaryCFrame = controller.Character.HumanoidRootPart.CFrame
        playerCar:SetPrimaryPartCFrame(controllerPrimaryCFrame)
    end
end

-- Bring Command
local function BringFunction()
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

    if controller and controller.Character then
        local targetPosition = controller.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
        character:SetPrimaryPartCFrame(targetPosition)
    else
        Chat("Controller not found.")
    end
end

-- List of Commands
getgenv().SalvatoreCommands = {
    busbring = BusBringFunction,
    bring = BringFunction,
}

-- Command Execution
function Command(player, msg)
    if not msg:find(config.Prefix) then
        return  
    end

    local args = string.split(msg, " ")
    local commandName = string.lower(args[1]):gsub(config.Prefix, "")

    table.remove(args, 1)  
    local targetPlayerName = table.concat(args, "") 

    if table.find(config.Controllers, tostring(player.UserId)) or table.find(config.Controllers, player.Name) then
        if getgenv().SalvatoreCommands[commandName] then
            if commandName == "busbring" then
                getgenv().SalvatoreCommands[commandName](targetPlayerName)
            else
                return
                Chat("The Salvatore Bot has no target.")
            end
        end
    end
end

-- Monitor Incoming Messages
game:GetService("TextChatService").OnIncomingMessage = function(message)
    local player = game:GetService("Players"):GetPlayerByUserId(message.TextSource.UserId)
    local msg = message.Text

    if player then
        Command(player, msg)
    end
end

-- Anti-Idle Protection
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)
