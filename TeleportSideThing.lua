local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera

local cameraTracker = Instance.new("Part")
cameraTracker.Anchored = true
cameraTracker.CanCollide = false
cameraTracker.Transparency = 1
cameraTracker.Size = Vector3.new(1, 1, 1)
cameraTracker.Parent = workspace

local DISTANCE = 20
local MOVEMENT_DELAY = 0.01
local isMoving = false
local movementConnection = nil

local positions = {0, DISTANCE, 0, -DISTANCE}
local currentPosIndex = 1
local centerPosition = hrp.Position
local lastMovementTime = 0
local lastSavedLookVector = hrp.CFrame.LookVector

local function updateCameraTracker()
    cameraTracker.Position = centerPosition + Vector3.new(0, 2, 0)
end

local function updateCenterPosition()
    if currentPosIndex == 1 or currentPosIndex == 3 then
        centerPosition = hrp.Position
        lastSavedLookVector = hrp.CFrame.LookVector
        updateCameraTracker()
    end
end

local function updatePosition()
    if not isMoving then return end
    
    local currentTime = tick()
    if currentTime - lastMovementTime < MOVEMENT_DELAY then return end
    lastMovementTime = currentTime
    
    updateCenterPosition()
    
    currentPosIndex = (currentPosIndex % #positions) + 1
    
    local rightVector = CFrame.new(Vector3.new(), lastSavedLookVector).RightVector
    local offset = positions[currentPosIndex]
    local newPosition = centerPosition + (rightVector * offset)
    
    hrp.CFrame = CFrame.new(newPosition, newPosition + lastSavedLookVector)
end

local function toggleMovement()
    if isMoving then
        isMoving = false
        if movementConnection then
            movementConnection:Disconnect()
            movementConnection = nil
        end
        
        task.wait(MOVEMENT_DELAY)
        hrp.CFrame = CFrame.new(centerPosition, centerPosition + lastSavedLookVector)
        camera.CameraSubject = humanoid
        
    else
        isMoving = true
        currentPosIndex = 1
        centerPosition = hrp.Position
        lastSavedLookVector = hrp.CFrame.LookVector
        lastMovementTime = tick()
        
        updateCameraTracker()
        
        camera.CameraSubject = cameraTracker
        
        movementConnection = RunService.Heartbeat:Connect(updatePosition)
    end
end

local function cleanup()
    if isMoving then
        toggleMovement()
    end
    cameraTracker:Destroy()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.E then
        toggleMovement()
    end
end)

game.Players.PlayerRemoving:Connect(function(plr)
    if plr == player then
        cleanup()
    end
end)

RunService.Heartbeat:Connect(function()
    if isMoving then
        updateCameraTracker()
    end
end)

print("Audio Thingy made by Federal")
