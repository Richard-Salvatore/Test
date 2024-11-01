--Configuration
getgenv().SalvatoreBot = {
    Controllers = { "4424701978", "Kls7xx" }, 
    Prefix = "!",
}




local config = getgenv().SalvatoreBot
local controller  




--Identify The Controller At The Start
for _, player in pairs(game.Players:GetPlayers()) do
    if player.UserId == 4424701978 or player.Name == "Kls7xx" then
        controller = player
        break
    end
end




--Chat Message Sending Function For The New Chat System
function Chat(msg)
    local textChatService = game:GetService("TextChatService")
    if textChatService:FindFirstChild("TextChannels") then
        textChatService.TextChannels.RBXGeneral:SendAsync(msg)
    elseif game.ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
    end
end



--Helper Function To Find Player By Partial Name (Case-Insensitive)
local function FindPlayerByName(partialName)
    local lowerPartialName = string.lower(partialName)
    for _, player in pairs(game.Players:GetPlayers()) do
        if string.find(string.lower(player.Name), lowerPartialName) then
            return player
        end
    end
    return nil
end



--Bus Bring Command
local function BusBringFunction(targetPlayerName)
    local targetPlayer = FindPlayerByName(targetPlayerName)

    if not targetPlayer then
        Chat("The Salvatore bot could not identify the selected target.")
        return
    end

    local localPlayer = game.Players.LocalPlayer
    local targetCharacter = targetPlayer.Character
    local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")

    if not targetCharacter or not targetHumanoid then
        Chat("The Salvatore bot was not able to identify the character of the selected target.")
        return
    end

    if targetHumanoid.Sit then
        Chat("The Salvatore bot has detected that the selected target is sitting; the busbring cannot be executed.")
        return
    end

    
    localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1054.22009, 2.9980247, -34.663887)
    wait(1)
    
   
    game:GetService("ReplicatedStorage").RE["1Ca1r"]:FireServer("PickingCar", "SchoolBus")
    wait(1)

    local playerCar = workspace.Vehicles[localPlayer.Name .. "Car"]
    if playerCar then
        local seat = playerCar.Body.VehicleSeat
        if seat then
           
            local attempts = 0
            while not localPlayer.Character.Humanoid.Sit and attempts < 10 do
                localPlayer.Character.HumanoidRootPart.CFrame = seat.CFrame
                wait(0.5)
                attempts = attempts + 1
            end
        end
    else
        return
    end

    
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
        Chat("The Salvatore bot detected an error while bringing the selected target.")
        return
    end

    
    if controller and controller.Character then
        local controllerPrimaryCFrame = controller.Character.HumanoidRootPart.CFrame
        playerCar:SetPrimaryPartCFrame(controllerPrimaryCFrame)
    end
    wait(1)
    local args = {
        [1] = "DeleteAllVehicles"
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer(unpack(args))
    wait(1)
    localCharacter.HumanoidRootPart.CFrame = startingPosition
end




--Cart Bring Command
local function CartBringFunction(targetPlayerName)
    local targetPlayer = FindPlayerByName(targetPlayerName)

    if not targetPlayer then
        Chat("The Salvatore bot could not identify the selected target.")
        return
    end

    
    local localPlayer = game.Players.LocalPlayer
    local targetCharacter = targetPlayer.Character
    local targetHumanoidForCartBring = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")

    if not targetCharacter or not targetHumanoidForCartBring then
        Chat("The Salvatore bot was not able to identify the character of the selected target.")
        return
    end

    if targetHumanoidForCartBring.Sit then
        Chat("The Salvatore bot has detected that the selected target is sitting; the cartbring cannot be executed.")
        return
    end

    local oldPos = localPlayer.Character.HumanoidRootPart.CFrame

    
    game:GetService("ReplicatedStorage").RE["1Clea1rTool1s"]:FireServer("ClearAllTools")
    wait(1)

    if not game.Players.LocalPlayer.Character then return end
    local plr = game.Players.LocalPlayer.Character
    plr.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    plr.Humanoid.Sit = true

   
    game:GetService("ReplicatedStorage").RE["1Too1l"]:InvokeServer("PickingTools", "ShoppingCart")

    for _, tool in ipairs(localPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = localPlayer.Character 
        end
    end

    
    local success, error = pcall(function()
        local newPositionIndex = 1 
        local positions = {
            CFrame.new(0, 0, -20),
            CFrame.new(0, 0, 3),
            CFrame.new(0, 0, -15),
            CFrame.new(0, 0, 2)
        }
        while not targetHumanoidForCartBring.Sit and targetPlayer.Character and targetHumanoidForCartBring.Health > 0 do
            local targetCFrame = targetHumanoidForCartBring.RootPart.CFrame
            local newPosition = positions[newPositionIndex]
            newPositionIndex = newPositionIndex % #positions + 1 
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = targetCFrame * newPosition
            game:GetService("RunService").Heartbeat:Wait()  
        end
    end)
    if not success then
        Chat("The Salvatore bot detected an error while bringing the selected target.")
        return
    end


    while not targetHumanoidForCartBring.Sit do
        wait(0.5)
    end

    
    if controller and controller.Character then
        local controllerPrimaryCFrame = controller.Character.HumanoidRootPart.CFrame
        localPlayer.Character.HumanoidRootPart.CFrame = controllerPrimaryCFrame
        wait(2)
        game:GetService("ReplicatedStorage").RE["1Clea1rTool1s"]:FireServer("ClearAllTools")
        plr.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        plr.Humanoid.Sit = false
        wait(1)
        localCharacter.HumanoidRootPart.CFrame = startingPosition
    end
end




--Couch Bring Command
local function CouchBringFunction(targetPlayerName)
    local targetPlayerForCouchBring = FindPlayerByName(targetPlayerName)

    if not targetPlayerForCouchBring then
        Chat("The Salvatore bot could not identify the selected target.")
        return
    end

    local localPlayer = game.Players.LocalPlayer
    local localCharacter = localPlayer.Character
    workspace.FallenPartsDestroyHeight = 0 / 0

    
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then
        Chat("The Salvatore bot could not identify the local player's character.")
        return
    end

    local startingPosition = localCharacter.HumanoidRootPart.CFrame
    local localPlayer = game.Players.LocalPlayer
    local targetCharacter = targetPlayerForCouchBring.Character
    local targetHumanoidForCouchBring = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")

    if not targetCharacter or not targetHumanoidForCouchBring then
        Chat("The Salvatore bot was not able to identify the character of the selected target.")
        return
    end

    if targetHumanoidForCouchBring.Sit then
        Chat("The Salvatore bot has detected that the selected target is sitting; the couchbring cannot be executed.")
        return
    end

    
    game:GetService("ReplicatedStorage").RE["1Clea1rTool1s"]:FireServer("ClearAllTools")
    wait()

    
    if localPlayer.Character then
        local plr = localPlayer.Character
        plr.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        plr.Humanoid.Sit = true
    end

    
    game:GetService("ReplicatedStorage").RE["1Too1l"]:InvokeServer("PickingTools", "Couch")
    wait()

    
    for _, tool in ipairs(localPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = localPlayer.Character 
        end
    end

    
    local newPositionIndex = 1 
    local positions = {
        CFrame.new(1, -3, -20),
        CFrame.new(1, -3, 2),
        CFrame.new(1, -3, -15),
        CFrame.new(1, -3, 3)
    }
    local success, error = pcall(function()
        while not targetHumanoidForCouchBring.Sit and targetPlayerForCouchBring.Character and targetHumanoidForCouchBring.Health > 0 do
            local targetCFrame = targetHumanoidForCouchBring.RootPart.CFrame
            local newPosition = positions[newPositionIndex]
            newPositionIndex = newPositionIndex % #positions + 1 
            localPlayer.Character.HumanoidRootPart.CFrame = targetCFrame * newPosition
            game:GetService("RunService").Heartbeat:Wait()  
        end
    end)
    if not success then
        Chat("The Salvatore bot detected an error while bringing the selected target.")
        return
    end

    
    while not targetHumanoidForCouchBring.Sit do
        wait(0.5)
    end

   
    if controller and controller.Character then
        local controllerPrimaryCFrame = controller.Character.HumanoidRootPart.CFrame
        localPlayer.Character.HumanoidRootPart.CFrame = controllerPrimaryCFrame
        wait(2)
        game:GetService("ReplicatedStorage").RE["1Clea1rTool1s"]:FireServer("ClearAllTools")
        plr.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        plr.Humanoid.Sit = false
        wait(1)
        localCharacter.HumanoidRootPart.CFrame = startingPosition
    end
end





--Bus Kill Command
local function BusKillFunction(targetPlayerName)
    local targetPlayerForBusKill = FindPlayerByName(targetPlayerName)

    if not targetPlayerForBusKill then
        Chat("The Salvatore bot could not identify the selected target.")
        return
    end

    local localPlayer = game.Players.LocalPlayer
    local targetCharacter = targetPlayerForBusKill.Character
    local targetHumanoidForBusKill = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")

    if not targetCharacter or not targetHumanoidForBusKill then
        Chat("The Salvatore bot was not able to identify the character of the selected target.")
        return
    end

    if targetHumanoidForBusKill.Sit then
        Chat("The Salvatore bot has detected that the selected target is sitting; the buskill cannot be executed.")
        return
    end

    local localPlayer = game.Players.LocalPlayer
    local localCharacter = localPlayer.Character
    workspace.FallenPartsDestroyHeight = 0 / 0

    
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then
        Chat("The Salvatore bot could not identify the local player's character.")
        return
    end

    local startingPosition = localCharacter.HumanoidRootPart.CFrame
    
    
    local humanoidRootPart = localPlayer.Character.HumanoidRootPart
    humanoidRootPart.CFrame = CFrame.new(1054.22009, 2.9980247, -34.663887)

   
    wait(1)
    game:GetService("ReplicatedStorage").RE["1Ca1r"]:FireServer("PickingCar", "SchoolBus")
    wait(1)

    
    local localPlayerCar = workspace.Vehicles[localPlayer.Name .. "Car"]
    if localPlayerCar then
        local targetSeat = localPlayerCar.Body.VehicleSeat
        local localHumanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

       
        if targetSeat and localHumanoid then
            local offset = CFrame.new(0, 4, 0)
            local targetCFrame = targetSeat.CFrame * offset
            while not localHumanoid.Sit do
                localPlayer.Character:SetPrimaryPartCFrame(targetCFrame)
                game:GetService("RunService").Heartbeat:Wait()
                if not localHumanoid or localHumanoid.Health <= 0 then
                    break
                end
            end
        end

        
        targetHumanoidForBusKill = targetPlayerForBusKill.Character and targetPlayerForBusKill.Character:FindFirstChildOfClass("Humanoid")
        if targetHumanoidForBusKill then
            local success, error = pcall(function()
                local positions = { CFrame.new(0, -3, -3), CFrame.new(0, 0, -15), CFrame.new(0, -3, -3) }
                local positionIndex = 1
                while not targetHumanoidForBusKill.Sit and targetHumanoidForBusKill.Health > 0 do
                    local targetCFrame = targetHumanoidForBusKill.RootPart.CFrame
                    localPlayerCar:SetPrimaryPartCFrame(targetCFrame * positions[positionIndex])
                    positionIndex = (positionIndex % #positions) + 1
                    wait()
                end
            end)
            if not success then
                Chat("The Salvatore bot detected an error while killing the selected target.")
                return
            end
        end

        
        localPlayerCar:SetPrimaryPartCFrame(CFrame.new(4473.4292, -316.103912, -474.905212))
        if controller and controller.Character then
            local controllerPrimaryCFrame = controller.Character.HumanoidRootPart.CFrame
            localPlayer.Character.HumanoidRootPart.CFrame = controllerPrimaryCFrame
        end
        wait(1)
        local args = {
            [1] = "DeleteAllVehicles"
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer(unpack(args))
        wait(2)
        localCharacter.HumanoidRootPart.CFrame = startingPosition
    else
    end
end





--Cart Kill Command
local function CartKillFunction(targetPlayerName)
    local targetPlayerForCartKill = FindPlayerByName(targetPlayerName)

    if not targetPlayerForCartKill then
        Chat("The Salvatore bot could not identify the selected target.")
        return
    end

    local targetCharacter = targetPlayerForCartKill.Character
    local targetHumanoidForCartKill = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")

    if not targetCharacter or not targetHumanoidForCartKill then
        Chat("The Salvatore bot was not able to identify the character of the selected target.")
        return
    end

    if targetHumanoidForCartKill.Sit then
        Chat("The Salvatore bot has detected that the selected target is sitting; the cartkill cannot be executed.")
        return
    end

    local localPlayer = game.Players.LocalPlayer
    local localCharacter = localPlayer.Character
    workspace.FallenPartsDestroyHeight = 0 / 0

    
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then
        Chat("The Salvatore bot could not identify the local player's character.")
        return
    end

    local startingPosition = localCharacter.HumanoidRootPart.CFrame


    local ohString1 = "ClearAllTools"
    game:GetService("ReplicatedStorage").RE["1Clea1rTool1s"]:FireServer(ohString1)
    wait(1)

    
    if not localPlayer.Character then return end

    localCharacter.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    localCharacter.Humanoid.Sit = true

    local ohString2 = "ShoppingCart"
    game:GetService("ReplicatedStorage").RE["1Too1l"]:InvokeServer("PickingTools", ohString2)

    for _, tool in ipairs(localPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = localCharacter
        end
    end

    if targetHumanoidForCartKill then
        local newPositionIndex = 1
        local positions = {
            CFrame.new(0, 0, -20),
            CFrame.new(0, 0, 3),
            CFrame.new(0, 0, -15),
            CFrame.new(0, 0, 2)
        }

        local success, error = pcall(function()
            while not targetHumanoidForCartKill.Sit and targetHumanoidForCartKill.Health > 0 do
                local targetCFrame = targetHumanoidForCartKill.RootPart.CFrame
                local newPosition = positions[newPositionIndex]
                newPositionIndex = (newPositionIndex % #positions) + 1
                localCharacter.HumanoidRootPart.CFrame = targetCFrame * newPosition
                game:GetService("RunService").Heartbeat:Wait()
            end
        end)

        if not success then
            Chat("The Salvatore bot detected an error while killing the selected target.")
            return
        end

        
        localCharacter.HumanoidRootPart.CFrame = CFrame.new(4473.4292, -316.103912, -474.905212)
        wait(1)
        local ohString1 = "ClearAllTools"
        game:GetService("ReplicatedStorage").RE["1Clea1rTool1s"]:FireServer(ohString1)
        wait(1)
        localCharacter.HumanoidRootPart.CFrame = startingPosition
        
    end
end




--Couch Kill Command
local function CouchKillFunction(targetPlayerName)
    local targetPlayerForCouchKill = FindPlayerByName(targetPlayerName)

    if not targetPlayerForCouchKill then
        Chat("The Salvatore bot could not identify the selected target.")
        return
    end

    local localPlayer = game.Players.LocalPlayer
    local localCharacter = localPlayer.Character
    workspace.FallenPartsDestroyHeight = 0 / 0

    
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then
        Chat("The Salvatore bot could not identify the local player's character.")
        return
    end

    local startingPosition = localCharacter.HumanoidRootPart.CFrame
    local targetHumanoidForCouchKill = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")

    if not targetCharacter or not targetHumanoidForCouchKill then
        Chat("The Salvatore bot was not able to identify the character of the selected target.")
        return
    end

    if targetHumanoidForCouchKill.Sit then
        Chat("The Salvatore bot has detected that the selected target is sitting; the couchkill cannot be executed.")
        return
    end

    
    for _, descendant in ipairs(targetCharacter:GetDescendants()) do
        if descendant:IsA("MeshPart") or descendant:IsA("Part") then
            descendant.CanCollide = false
        end
    end

    local localPlayer = game.Players.LocalPlayer
    local localCharacter = localPlayer.Character

   
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then
        Chat("The Salvatore bot could not identify the local player's character.")
        return
    end

    local startingPosition = localCharacter.HumanoidRootPart.CFrame
    workspace.FallenPartsDestroyHeight = 0 / 0

    
    game:GetService("ReplicatedStorage").RE["1Clea1rTool1s"]:FireServer("ClearAllTools")
    wait(1)

   
    localCharacter.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    localCharacter.Humanoid.Sit = true

   
    game:GetService("ReplicatedStorage").RE["1Too1l"]:InvokeServer("PickingTools", "Couch")
    wait(1)

    
    for _, tool in ipairs(localPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = localCharacter
        end
    end

    if targetHumanoidForCouchKill then
        local newPositionIndex = 1
        local positions = {
            CFrame.new(1, -3, -20),
            CFrame.new(1, -3, 2),
            CFrame.new(1, -3, -15),
            CFrame.new(1, -3, 3)
        }

        local success, error = pcall(function()
            while not targetHumanoidForCouchKill.Sit and targetHumanoidForCouchKill.Health > 0 do
                local targetCFrame = targetHumanoidForCouchKill.RootPart.CFrame
                local newPosition = positions[newPositionIndex]
                newPositionIndex = (newPositionIndex % #positions) + 1
                localCharacter.HumanoidRootPart.CFrame = targetCFrame * newPosition
                game:GetService("RunService").Heartbeat:Wait()
            end
        end)

        if not success then
            Chat("The Salvatore bot detected an error while killing the selected target.")
            return
        end

       
        localCharacter.HumanoidRootPart.CFrame = CFrame.new(4473.4292, -316.103912, -474.905212)
        wait(1)
        local ohString1 = "ClearAllTools"
        game:GetService("ReplicatedStorage").RE["1Clea1rTool1s"]:FireServer(ohString1)
        wait(2)
        localCharacter.HumanoidRootPart.CFrame = startingPosition
    end
end




--To Command
local function ToFunction(targetPlayerName)
    local targetPlayer = FindPlayerByName(targetPlayerName)

    if not targetPlayer then
        Chat("The Salvatore bot could not identify the selected target.")
        return
    end

    local localPlayer = game.Players.LocalPlayer
    local targetCharacter = targetPlayer.Character
    local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")
    workspace.FallenPartsDestroyHeight = 0 / 0

    
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then
        Chat("The Salvatore bot could not identify the local player's character.")
        return
    end

    local startingPosition = localCharacter.HumanoidRootPart.CFrame

    if not targetCharacter or not targetHumanoid then
        Chat("The Salvatore bot was not able to identify the character of the selected target.")
        return
    end

    if targetHumanoid.Sit then
        Chat("The Salvatore bot has detected that the selected target is sitting; the teleport cannot be executed.")
        return
    end

    
    localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1054.22009, 2.9980247, -34.663887)
    wait(1)
    
    
    game:GetService("ReplicatedStorage").RE["1Ca1r"]:FireServer("PickingCar", "SchoolBus")
    wait(1)

    
    local playerCar = workspace.Vehicles[localPlayer.Name .. "Car"]
    if not playerCar then
        return
    end

    
    local seat = playerCar.Body.VehicleSeat
    if seat then
        local attempts = 0
        while not localPlayer.Character.Humanoid.Sit and attempts < 10 do
            localPlayer.Character.HumanoidRootPart.CFrame = seat.CFrame
            wait(0.5)
            attempts = attempts + 1
        end
    else
        return
    end

    
    local positions = { CFrame.new(0, -3, -3), CFrame.new(0, 0, -15), CFrame.new(0, -3, -3) }
    local positionIndex = 1

    
    local success, error = pcall(function()
        if controller and controller.Character then
            local controllerHumanoid = controller.Character:FindFirstChildOfClass("Humanoid")
            while not controllerHumanoid.Sit do
                local controllerPosition = controller.Character.HumanoidRootPart.CFrame * positions[positionIndex]
                playerCar:SetPrimaryPartCFrame(controllerPosition)
                positionIndex = (positionIndex % #positions) + 1
                wait(0.5)
            end
        end
    end)

    if not success then
        Chat("The Salvatore bot detected an error while teleporting to the selected target.")
        return
    end

    
    if targetHumanoid then
        local targetCFrame = targetHumanoid.RootPart.CFrame
        playerCar:SetPrimaryPartCFrame(targetCFrame)
    end

   
    wait(1)
    local args = {
        [1] = "DeleteAllVehicles"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer(unpack(args))
    wait(1)
    localCharacter.HumanoidRootPart.CFrame = startingPosition
end







--To2 Command
local function To2Function(targetPlayerName)
    local targetPlayer = FindPlayerByName(targetPlayerName)

    if not targetPlayer then
        Chat("The Salvatore bot could not identify the selected target.")
        return
    end

    local localPlayer = game.Players.LocalPlayer
    local targetCharacter = targetPlayer.Character
    local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")
    workspace.FallenPartsDestroyHeight = 0 / 0

    
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then
        Chat("The Salvatore bot could not identify the local player's character.")
        return
    end

    local startingPosition = localCharacter.HumanoidRootPart.CFrame

    if not targetCharacter or not targetHumanoid then
        Chat("The Salvatore bot was not able to identify the character of the selected target.")
        return
    end

    if targetHumanoid.Sit then
        Chat("The Salvatore bot has detected that the selected target is sitting; the teleport cannot be executed.")
        return
    end

    
    game:GetService("ReplicatedStorage").RE["1Too1l"]:InvokeServer("PickingTools", "ShoppingCart")

    
    for _, tool in ipairs(localPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = localPlayer.Character 
        end
    end

    
    if controller and controller.Character then
        local controllerHumanoid = controller.Character:FindFirstChildOfClass("Humanoid")
        local controllerPositions = {
            CFrame.new(0, -3, -3),
            CFrame.new(0, 0, -15),
            CFrame.new(0, -3, 3)
        }
        local positionIndex = 1
        
        while not controllerHumanoid.Sit do
            local controllerCFrame = controller.Character.HumanoidRootPart.CFrame
            local offset = controllerPositions[positionIndex]
            localPlayer.Character.HumanoidRootPart.CFrame = controllerCFrame * offset
            positionIndex = (positionIndex % #controllerPositions) + 1
            wait(0.5)
        end

        
        local targetCFrame = targetHumanoid.RootPart.CFrame
        localPlayer.Character.HumanoidRootPart.CFrame = targetCFrame * CFrame.new(0, 0, -5) 
    end

    wait(1)
    game:GetService("ReplicatedStorage").RE["1Clea1rTool1s"]:FireServer("ClearAllTools")
    localCharacter.HumanoidRootPart.CFrame = startingPosition
end






--To3 Command
local function To3Function(targetPlayerName)
    local targetPlayer = FindPlayerByName(targetPlayerName)

    if not targetPlayer then
        Chat("The Salvatore bot could not identify the selected target.")
        return
    end

    local localPlayer = game.Players.LocalPlayer
    local targetCharacter = targetPlayer.Character
    local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")
    workspace.FallenPartsDestroyHeight = 0 / 0

    
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then
        Chat("The Salvatore bot could not identify the local player's character.")
        return
    end

    local startingPosition = localCharacter.HumanoidRootPart.CFrame

    if not targetCharacter or not targetHumanoid then
        Chat("The Salvatore bot was not able to identify the character of the selected target.")
        return
    end

    if targetHumanoid.Sit then
        Chat("The Salvatore bot has detected that the selected target is sitting; the teleport cannot be executed.")
        return
    end

    
    game:GetService("ReplicatedStorage").RE["1Too1l"]:InvokeServer("PickingTools", "Couch")
    wait(1)

  
    for _, tool in ipairs(localPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = localPlayer.Character 
        end
    end

    
    if controller and controller.Character then
        local controllerHumanoid = controller.Character:FindFirstChildOfClass("Humanoid")
        local controllerPositions = {
            CFrame.new(1, -3, -2),
            CFrame.new(0, 0, -15),
            CFrame.new(1, -3, 3)
        }
        local positionIndex = 1
        
        while not controllerHumanoid.Sit do
            local controllerCFrame = controller.Character.HumanoidRootPart.CFrame
            local offset = controllerPositions[positionIndex]
            localPlayer.Character.HumanoidRootPart.CFrame = controllerCFrame * offset
            positionIndex = (positionIndex % #controllerPositions) + 1
            wait(0.5)
        end

        
        local targetCFrame = targetHumanoid.RootPart.CFrame
        localPlayer.Character.HumanoidRootPart.CFrame = targetCFrame * CFrame.new(0, 0, -5) 
    end

    wait(1)
    game:GetService("ReplicatedStorage").RE["1Clea1rTool1s"]:FireServer("ClearAllTools")
    localCharacter.HumanoidRootPart.CFrame = startingPosition
end






--Alt Account Check Command
local function IsAltAccountFunction(targetPlayerName)
    local targetPlayer = FindPlayerByName(targetPlayerName)
    if not targetPlayer then
        Chat("The Salvatore bot could not identify the selected target.")
        return
    end

    if targetPlayer.AccountAge < 20 then
        Chat("The Salvatore bot has identified the target as an alt account.")
    else
        Chat("The Salvatore bot has identified the target as not an alt account.")
    end
end




--Bring Command
local function BringFunction()
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

    if controller and controller.Character then
        local targetPosition = controller.Character.HumanoidRootPart.CFrame * CFrame.new(4, 0, 0)
        character:SetPrimaryPartCFrame(targetPosition)
    else
        return
    end
end



--Reset Command
local function ResetFunction()
    local localPlayer = game.Players.LocalPlayer
    local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Health = 0
    end
end



--Message Command 
local function MessageFunction(message)
    Chat(message)
end



--List Of Commands
getgenv().SalvatoreCommands = {
    busbring = BusBringFunction,
    cartbring = CartBringFunction,
    couchbring = CouchBringFunction,
    buskill = BusKillFunction,
    cartkill = CartKillFunction,
    couchkill = CouchKillFunction,
    isaltacc = IsAltAccountFunction,
    bring = BringFunction,
    reset = ResetFunction,
    msg = MessageFunction,
    to = ToFunction,
    to2 = To2Function,
    to3 = To3Function,
}




--Command Execution
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
            if commandName == "busbring" or commandName == "cartbring" or commandName == "couchbring" or commandName == "buskill" or "cartkill" or "couchkill" or "isaltacc" then
                getgenv().SalvatoreCommands[commandName](targetPlayerName)
            elseif commandName == "msg" then
                getgenv().SalvatoreCommands[commandName](targetPlayerName) 
            else
                getgenv().SalvatoreCommands[commandName]() 
            end
        else
           Chat("The Salvatore bot could not identify the command.")
        end
    end
end





--Monitor Incoming Messages
game:GetService("TextChatService").OnIncomingMessage = function(message)
    local player = game:GetService("Players"):GetPlayerByUserId(message.TextSource.UserId)
    local msg = message.Text

    if player then
        Command(player, msg)
    end
end




--Anti-Idle Protection
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)
