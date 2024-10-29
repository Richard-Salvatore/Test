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

-- Helper function to find player by partial name (case-insensitive)
local function FindPlayerByName(partialName)
    local lowerPartialName = string.lower(partialName)
    for _, player in pairs(game.Players:GetPlayers()) do
        if string.find(string.lower(player.Name), lowerPartialName) then
            return player
        end
    end
    return nil
end

-- Function to spawn a vehicle and attempt to sit the local player
local function SpawnVehicle(vehicleType, seatPosition)
    game:GetService("ReplicatedStorage").RE["1Ca1r"]:FireServer("PickingCar", vehicleType)
    wait(1)
    local playerCar = workspace.Vehicles[game.Players.LocalPlayer.Name .. "Car"]
    if playerCar then
        local seat = playerCar.Body:FindFirstChild("VehicleSeat")
        if seat then
            local attempts = 0
            while not game.Players.LocalPlayer.Character.Humanoid.Sit and attempts < 10 do
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = seat.CFrame
                wait(0.5)
                attempts = attempts + 1
            end
        else
            Chat("Vehicle seat not found.")
        end
    else
        Chat("Could not spawn vehicle.")
    end
end

-- Bus Bring Command
local function BusBringFunction(targetPlayerName)
    local targetPlayer = FindPlayerByName(targetPlayerName)
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

    localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1054.22009, 2.9980247, -34.663887)
    wait(1)
    SpawnVehicle("SchoolBus")

    local playerCar = workspace.Vehicles[localPlayer.Name .. "Car"]
    if playerCar then
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
        end
    else
        Chat("Error in locating player car.")
    end

    if controller and controller.Character then
        local controllerPrimaryCFrame = controller.Character.HumanoidRootPart.CFrame
        playerCar:SetPrimaryPartCFrame(controllerPrimaryCFrame)
    end
    wait(1)
    game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer("DeleteAllVehicles")
end

-- Cart Bring Command
local function CartBringFunction(targetPlayerName)
    local targetPlayer = FindPlayerByName(targetPlayerName)
    if not targetPlayer then
        Chat("The specified player was not found.")
        return
    end
    local localPlayer = game.Players.LocalPlayer
    local targetCharacter = targetPlayer.Character
    local targetHumanoidForCartBring = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")

    if not targetCharacter or not targetHumanoidForCartBring then
        Chat("The target player's character is not available.")
        return
    end

    if targetHumanoidForCartBring.Sit then
        Chat("The target is currently sitting; bring cannot be used.")
        return
    end

    game:GetService("ReplicatedStorage").RE["1Clea1rTool1s"]:FireServer("ClearAllTools")
    wait(1)
    game:GetService("ReplicatedStorage").RE["1Too1l"]:InvokeServer("PickingTools", "ShoppingCart")

    for _, tool in ipairs(localPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = localPlayer.Character 
        end
    end

    -- Teleport cart to target until they sit
    local success, error = pcall(function()
        local positions = {
            CFrame.new(0, 0, -20),
            CFrame.new(0, 0, 3),
            CFrame.new(0, 0, -15),
            CFrame.new(0, 0, 2)
        }
        local positionIndex = 1
        while not targetHumanoidForCartBring.Sit and targetPlayer.Character and targetHumanoidForCartBring.Health > 0 do
            local targetCFrame = targetHumanoidForCartBring.RootPart.CFrame
            localPlayer.Character.HumanoidRootPart.CFrame = targetCFrame * positions[positionIndex]
            positionIndex = (positionIndex % #positions) + 1
            game:GetService("RunService").Heartbeat:Wait()
        end
    end)
    if not success then
        Chat("Error while bringing the target.")
    end

    if controller and controller.Character then
        local controllerPrimaryCFrame = controller.Character.HumanoidRootPart.CFrame
        localPlayer.Character.HumanoidRootPart.CFrame = controllerPrimaryCFrame
        wait(2)
        game:GetService("ReplicatedStorage").RE["1Clea1rTool1s"]:FireServer("ClearAllTools")
        localPlayer.Character.Humanoid.Sit = false
    end
end


-- Bring Command
local function BringFunction()
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

    if controller and controller.Character then
        local targetPosition = controller.Character.HumanoidRootPart.CFrame * CFrame.new(4, 0, 0)
        character:SetPrimaryPartCFrame(targetPosition)
    else
        Chat("Controller not found.")
    end
end

-- List of Commands
getgenv().SalvatoreCommands = {
    busbring = BusBringFunction,
    cartbring = CartBringFunction,
    couchbring = CouchBringFunction,
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
    local targetPlayerName = table.concat(args, " ")

    if table.find(config.Controllers, tostring(player.UserId)) or table.find(config.Controllers, player.Name) then
        if getgenv().SalvatoreCommands[commandName] then
            if commandName == "busbring" or commandName == "cartbring" == "couchbring" then
                getgenv().SalvatoreCommands[commandName](targetPlayerName)
            else
                getgenv().SalvatoreCommands[commandName]() 
            end
        else
            Chat("Unknown command.")
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
