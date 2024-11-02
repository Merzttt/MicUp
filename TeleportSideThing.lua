local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MovementControlGui"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0.8, 0, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 7)
FrameCorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Movement Control"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.8, 0, 0, 25)
ToggleButton.Position = UDim2.new(0.1, 0, 0.35, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
ToggleButton.Text = "Toggle Movement"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.Gotham
ToggleButton.TextSize = 14
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = Frame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 7)
ButtonCorner.Parent = ToggleButton

local DistanceLabel = Instance.new("TextLabel")
DistanceLabel.Size = UDim2.new(0.4, 0, 0, 20)
DistanceLabel.Position = UDim2.new(0.1, 0, 0.65, 0)
DistanceLabel.BackgroundTransparency = 1
DistanceLabel.Text = "Distance:"
DistanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
DistanceLabel.TextSize = 14
DistanceLabel.Font = Enum.Font.Gotham
DistanceLabel.Parent = Frame

local DistanceInput = Instance.new("TextBox")
DistanceInput.Size = UDim2.new(0.3, 0, 0, 20)
DistanceInput.Position = UDim2.new(0.6, 0, 0.65, 0)
DistanceInput.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
DistanceInput.Text = "20"
DistanceInput.TextColor3 = Color3.fromRGB(255, 255, 255)
DistanceInput.Font = Enum.Font.Gotham
DistanceInput.TextSize = 14
DistanceInput.BorderSizePixel = 0
DistanceInput.Parent = Frame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 7)
InputCorner.Parent = DistanceInput

local UserInputService = game:GetService("UserInputService")
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

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

local MOVEMENT_DELAY = 0.01
local isMoving = false
local movementConnection = nil

local positions = {0, 20, 0, -20}
local currentPosIndex = 1
local centerPosition = hrp.Position
local lastMovementTime = 0
local lastSavedLookVector = hrp.CFrame.LookVector

local function updateCharacterReferences()
    character = player.Character
    if character then
        hrp = character:WaitForChild("HumanoidRootPart")
        humanoid = character:WaitForChild("Humanoid")
        if isMoving then
            camera.CameraSubject = cameraTracker
        end
    end
end

player.CharacterAdded:Connect(updateCharacterReferences)

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
        ToggleButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
        
    else
        isMoving = true
        currentPosIndex = 1
        centerPosition = hrp.Position
        lastSavedLookVector = hrp.CFrame.LookVector
        lastMovementTime = tick()
        
        updateCameraTracker()
        
        camera.CameraSubject = cameraTracker
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        
        movementConnection = RunService.Heartbeat:Connect(updatePosition)
    end
end

local function updateDistance()
    local newDistance = tonumber(DistanceInput.Text)
    if newDistance then
        positions = {0, newDistance, 0, -newDistance}
    else
        DistanceInput.Text = tostring(positions[2])
    end
end

local function cleanup()
    if isMoving then
        toggleMovement()
    end
    cameraTracker:Destroy()
    ScreenGui:Destroy()
end

ToggleButton.MouseButton1Click:Connect(toggleMovement)
DistanceInput.FocusLost:Connect(updateDistance)

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

print("Audio Movement GUI by Federal")
