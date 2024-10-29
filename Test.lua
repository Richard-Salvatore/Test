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

-- Helper function to find player by partial name or display name (case-insensitive)
local function FindPlayerByName(partialName)
    local lowerPartialName = string.lower(partialName)
    for _, player in pairs(game.Players:GetPlayers()) do
        if string.find(string.lower(player.Name), lowerPartialName) or string.find(string.lower(player.DisplayName), lowerPartialName) then
            return player
        end
    end
    return nil
end

-- Function to wait for a player's character to spawn
local function WaitForCharacter(player)
    while not player.Character or not player.Character:FindFirstChild("Humanoid") do
        player.CharacterAdded:Wait()
    end
end

-- Function to wait for a player's humanoid to be alive
local function WaitForHumanoid(player)
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    while humanoid and humanoid.Health <= 0 do
        humanoid.Died:Wait()
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

    -- Wait for target's character
    WaitForCharacter(targetPlayer)

    local targetCharacter = targetPlayer.Character
    local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")

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
    wait(1)
    local args = {
        [1] = "DeleteAllVehicles"
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer(unpack(args))
end

-- Bring Command
local function BringFunction()
    local localPlayer = game.Players.LocalPlayer

    -- Wait for local player's character
    WaitForCharacter(localPlayer)

    local character = localPlayer.Character

    if controller and controller.Character then
        local targetPosition = controller.Character.HumanoidRootPart.CFrame * CFrame.new(6, 0, 0)
        character:SetPrimaryPartCFrame(targetPosition)
    else
        Chat("Controller not found.")
    end
end

-- Reset Command (by destroying head)
local function ResetFunction()
    local localPlayer = game.Players.LocalPlayer
    if localPlayer.Character then
        local head = localPlayer.Character:FindFirstChild("Head")
        if head then
            head:Destroy()
        end
    end
end

-- Reset2 Command (by setting humanoid health to 0)
local function Reset2Function()
    local localPlayer = game.Players.LocalPlayer
    local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Health = 0
    end
end

-- List of Commands
getgenv().SalvatoreCommands = {
    busbring = BusBringFunction,
    bring = BringFunction,
    reset = ResetFunction,
    reset2 = Reset2Function,
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
        -- Execute the command function if it exists
        local commandFunc = getgenv().SalvatoreCommands[commandName]
        if commandFunc then
            if commandName == "busbring" then
                commandFunc(targetPlayerName)
            else
                commandFunc() 
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

-- Function to restart script when player respawns
local function OnPlayerRespawn()
    local localPlayer = game.Players.LocalPlayer
    WaitForCharacter(localPlayer)
    -- Re-initialize or set up necessary components here if needed
end

-- Check and wait for local player in workspace
local function MonitorLocalPlayer()
    local localPlayer = game.Players.LocalPlayer
    while true do
        if not localPlayer.Character then
            -- Wait until the player character is added
            localPlayer.CharacterAdded:Wait()
            OnPlayerRespawn() -- Ensure we also handle humanoid death on respawn
        else
            local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Died:Connect(function()
                    -- Wait until character respawns
                    localPlayer.CharacterAdded:Wait()
                    OnPlayerRespawn()
                end)
            end
        end
        wait(1) -- Check every second
    end
end

-- Start monitoring the local player
MonitorLocalPlayer()
