local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlashStepGui"
ScreenGui.Parent = gethui()
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 99999999

local Container = Instance.new("Frame")
Container.Size = UDim2.new(0, 220, 0, 120)
Container.Position = UDim2.new(0.8, 0, 0.1, 0)
Container.BackgroundTransparency = 1
Container.Parent = ScreenGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(1, -10, 1, -10)
Frame.Position = UDim2.new(0, 5, 0, 5)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.BorderSizePixel = 0
Frame.Parent = Container

for i = 1, 3 do
    local Shadow = Instance.new("Frame")
    Shadow.Size = UDim2.new(1, 4 * i, 1, 4 * i)
    Shadow.Position = UDim2.new(0, -2 * i, 0, -2 * i)
    Shadow.BackgroundColor3 = Color3.new(0, 0, 0)
    Shadow.BorderSizePixel = 0
    Shadow.BackgroundTransparency = 1 - (0.1 / i)
    Shadow.ZIndex = -i
    Shadow.Parent = Frame
    
    local ShadowCorner = Instance.new("UICorner")
    ShadowCorner.CornerRadius = UDim.new(0, 5)
    ShadowCorner.Parent = Shadow
end

local Outline = Instance.new("UIStroke")
Outline.Color = Color3.fromRGB(75, 75, 75)
Outline.Thickness = 1
Outline.Parent = Frame

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 5)
FrameCorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "Flash Step"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.85, 0, 0, 30)
ToggleButton.Position = UDim2.new(0.075, 0, 0.35, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ToggleButton.Text = "Toggle Movement"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.GothamMedium
ToggleButton.TextSize = 14
ToggleButton.BorderSizePixel = 0
ToggleButton.AutoButtonColor = false
ToggleButton.Parent = Frame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 5)
ButtonCorner.Parent = ToggleButton

local DistanceLabel = Instance.new("TextLabel")
DistanceLabel.Size = UDim2.new(0.4, 0, 0, 20)
DistanceLabel.Position = UDim2.new(0.075, 0, 0.7, 0)
DistanceLabel.BackgroundTransparency = 1
DistanceLabel.Text = "Distance:"
DistanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
DistanceLabel.TextSize = 14
DistanceLabel.Font = Enum.Font.GothamMedium
DistanceLabel.Parent = Frame

local DistanceInput = Instance.new("TextBox")
DistanceInput.Size = UDim2.new(0.35, 0, 0, 25)
DistanceInput.Position = UDim2.new(0.575, 0, 0.68, 0)
DistanceInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
DistanceInput.Text = "20"
DistanceInput.TextColor3 = Color3.fromRGB(255, 255, 255)
DistanceInput.Font = Enum.Font.GothamMedium
DistanceInput.TextSize = 14
DistanceInput.BorderSizePixel = 0
DistanceInput.Parent = Frame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 5)
InputCorner.Parent = DistanceInput

ToggleButton.MouseEnter:Connect(function()
    game:GetService("TweenService"):Create(ToggleButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    }):Play()
end)

ToggleButton.MouseLeave:Connect(function()
    if not isMoving then
        game:GetService("TweenService"):Create(ToggleButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        }):Play()
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

local UserInputService = game:GetService("UserInputService")
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    Container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Container.Position
        
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

print("Flash Step - federal.wtf")
