local IsStudio = false

local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local AvatarEditorService = game:GetService("AvatarEditorService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local Emotes = {}
local function AddEmote(name: string, id: IntValue, price: IntValue?)
    if not (name and id) then
        return
    end

    table.insert(Emotes, {
        ["name"] = name,
        ["id"] = id,
        ["icon"] = "rbxthumb://type=Asset&id=".. id .."&w=150&h=150",
        ["price"] = price or 0,
        ["index"] = #Emotes + 1,
        ["sort"] = {}
    })
end
local CurrentSort = "newestfirst"

local FavoriteOff = "rbxassetid://14133403708"
local FavoriteOn = "rbxassetid://14133403998"
local FavoritedEmotes = {}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Emotes"
ScreenGui.DisplayOrder = 99999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = false

local ShadowHolder = Instance.new("Frame")
ShadowHolder.BackgroundTransparency = 1
ShadowHolder.AnchorPoint = Vector2.new(0.5, 0.5)
ShadowHolder.Size = UDim2.new(0.21, 0, 0.6, 0)
ShadowHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
ShadowHolder.Parent = ScreenGui

for i = 1, 3 do
    local Shadow = Instance.new("Frame")
    Shadow.Size = UDim2.new(1, i * 3, 1, i * 3)
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.BackgroundTransparency = 0.7
    Shadow.BorderSizePixel = 0
    Shadow.ZIndex = 1
    
    local ShadowCorner = Instance.new("UICorner")
    ShadowCorner.CornerRadius = UDim.new(0, 5)
    ShadowCorner.Parent = Shadow
    
    Shadow.Parent = ShadowHolder
end

local BackFrame = Instance.new("Frame")
BackFrame.Size = UDim2.new(1, 0, 1, 0)
BackFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
BackFrame.BorderSizePixel = 0
BackFrame.ZIndex = 2
BackFrame.Parent = ShadowHolder

local PanelStroke = Instance.new("UIStroke")
PanelStroke.Color = Color3.fromRGB(75, 75, 75)
PanelStroke.Transparency = 0.7
PanelStroke.Thickness = 1
PanelStroke.Parent = BackFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 5)
MainCorner.Parent = BackFrame

local Dragging = false
local DragStart = nil
local StartPos = nil

BackFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = input.Position
        StartPos = ShadowHolder.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local Delta = input.Position - DragStart
        ShadowHolder.Position = UDim2.new(
            StartPos.X.Scale,
            StartPos.X.Offset + Delta.X,
            StartPos.Y.Scale,
            StartPos.Y.Offset + Delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = false
    end
end)

local HeaderContainer = Instance.new("Frame")
HeaderContainer.Name = "HeaderContainer"
HeaderContainer.Size = UDim2.new(1, 0, 0.15, 0)
HeaderContainer.Position = UDim2.new(0, 0, 0, 0)
HeaderContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
HeaderContainer.BorderSizePixel = 0
HeaderContainer.BackgroundTransparency = 1
HeaderContainer.ZIndex = 3
HeaderContainer.Parent = BackFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0.4, 0)
TopBar.Position = UDim2.new(0, 0, 0, 0)
TopBar.BackgroundTransparency = 1
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 3
TopBar.Parent = HeaderContainer

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0.07, 0, 0.8, 0)
CloseButton.Position = UDim2.new(0.05/2, 0, 0.5/2, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
CloseButton.Text = "❌"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.TextSize = 12
CloseButton.BorderSizePixel = 0
CloseButton.ZIndex = 3
MainCorner:Clone().Parent = CloseButton
CloseButton.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.4, 0, 0.8, 0)
Title.Position = UDim2.new(0.3, 0, 0.5/2, 0)
Title.BackgroundTransparency = 1
Title.Text = "Select an Emote"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.ZIndex = 3
Title.Parent = TopBar

local SortButton = Instance.new("TextButton")
SortButton.Name = "SortButton"
SortButton.Size = UDim2.new(0.15, 0, 0.8, 0)
SortButton.Position = UDim2.new(0.83, 0, 0.5/2, 0)
SortButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SortButton.Text = "Sort ▼"
SortButton.TextColor3 = Color3.new(1, 1, 1)
SortButton.TextSize = 14
SortButton.BorderSizePixel = 0
SortButton.ZIndex = 3
MainCorner:Clone().Parent = SortButton
SortButton.Parent = TopBar

local SearchBar = Instance.new("TextBox")
SearchBar.Name = "SearchBar"
SearchBar.Size = UDim2.new(0.96, 0, 0.35, 0)
SearchBar.Position = UDim2.new(0.02, 0, 0.65, 0)
SearchBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SearchBar.PlaceholderText = "Search emotes..."
SearchBar.Text = ""
SearchBar.TextColor3 = Color3.new(1, 1, 1)
SearchBar.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
SearchBar.TextSize = 14
SearchBar.BorderSizePixel = 0
SearchBar.ZIndex = 3
MainCorner:Clone().Parent = SearchBar
SearchBar.Parent = HeaderContainer

local Frame = Instance.new("ScrollingFrame")
Frame.Size = UDim2.new(1, 0, 0.82, 0)
Frame.Position = UDim2.new(0.5, 0, 0.17, 0)
Frame.AnchorPoint = Vector2.new(0.5, 0)
Frame.BackgroundTransparency = 1
Frame.BorderSizePixel = 0
Frame.ScrollBarThickness = 1
Frame.ScrollBarImageColor3 = Color3.fromRGB(75, 75, 75)
Frame.CanvasSize = UDim2.new(0, 0, 0, 0)
Frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
Frame.ScrollingDirection = Enum.ScrollingDirection.Y
Frame.ZIndex = 3
Frame.Parent = BackFrame

local Grid = Instance.new("UIGridLayout")
Grid.CellSize = UDim2.new(0.21, 0, 0, 0)
Grid.CellPadding = UDim2.new(0.04/2, 0, 0.021/2, 0)
Grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
Grid.SortOrder = Enum.SortOrder.LayoutOrder
Grid.Parent = Frame

Frame.MouseLeave:Connect(function()
    Title.Text = "Select an Emote"
end)

local SortFrame = Instance.new("Frame")
SortFrame.Visible = false
SortFrame.BorderSizePixel = 0
SortFrame.Position = UDim2.new(1.02, 0, 0, 0)
SortFrame.Size = UDim2.new(0.25, 0, 0.2, 0)
SortFrame.AutomaticSize = Enum.AutomaticSize.Y
SortFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SortFrame.ZIndex = 4
MainCorner:Clone().Parent = SortFrame
PanelStroke:Clone().Parent = SortFrame
SortFrame.Parent = BackFrame

local padding = Instance.new("UIPadding", SortFrame)
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 5)
padding.PaddingRight = UDim.new(0, 5)

local SortList = Instance.new("UIListLayout")
SortList.Padding = UDim.new(0.02, 0)
SortList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SortList.VerticalAlignment = Enum.VerticalAlignment.Top
SortList.SortOrder = Enum.SortOrder.LayoutOrder
SortList.Parent = SortFrame

local Loading = Instance.new("TextLabel", BackFrame)
Loading.AnchorPoint = Vector2.new(0.5, 0.5)
Loading.Text = "Loading..."
Loading.TextColor3 = Color3.new(1, 1, 1)
Loading.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Loading.TextScaled = true
Loading.BackgroundTransparency = 0.5
Loading.Size = UDim2.fromScale(0.4, 0.1)
Loading.Position = UDim2.fromScale(0.5, 0.5)
Loading.ZIndex = 3
MainCorner:Clone().Parent = Loading

local function SortEmotes()
    for i,Emote in pairs(Emotes) do
        local EmoteButton = Frame:FindFirstChild(Emote.id)
        if not EmoteButton then
            continue
        end
        local IsFavorited = table.find(FavoritedEmotes, Emote.id)
        EmoteButton.LayoutOrder = Emote.sort[CurrentSort] + ((IsFavorited and 0) or #Emotes)
        EmoteButton.number.Text = Emote.sort[CurrentSort]
    end
end

local function createsort(order, text, sort)
    local CreatedSort = Instance.new("TextButton")
    CreatedSort.SizeConstraint = Enum.SizeConstraint.RelativeXX
    CreatedSort.Size = UDim2.new(0.9, 0, 0, 30)
    CreatedSort.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    CreatedSort.LayoutOrder = order
    CreatedSort.TextColor3 = Color3.new(1, 1, 1)
    CreatedSort.Text = text
    CreatedSort.TextSize = 14
    CreatedSort.Font = Enum.Font.SourceSans
    CreatedSort.BorderSizePixel = 0
    CreatedSort.ZIndex = 5
    MainCorner:Clone().Parent = CreatedSort
    PanelStroke:Clone().Parent = CreatedSort
    CreatedSort.Parent = SortFrame
    CreatedSort.MouseButton1Click:Connect(function()
        SortFrame.Visible = false
        CurrentSort = sort
        SortEmotes()
    end)
    return CreatedSort
end

createsort(1, "Newest First", "newestfirst")
createsort(2, "Oldest First", "oldestfirst")
createsort(3, "Alphabetically", "alphabetic")

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

SortButton.MouseButton1Click:Connect(function()
    SortFrame.Visible = not SortFrame.Visible
end)

SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
    local text = SearchBar.Text:lower()
    local buttons = Frame:GetChildren()
    if text ~= text:sub(1,50) then
        SearchBar.Text = SearchBar.Text:sub(1,50)
        text = SearchBar.Text:lower()
    end
    if text ~= ""  then
        for i,button in pairs(buttons) do
            if button:IsA("GuiButton") then
                local name = button:GetAttribute("name"):lower()
                if name:match(text) then
                    button.Visible = true
                else
                    button.Visible = false
                end
            end
        end
    else
        for i,button in pairs(buttons) do
            if button:IsA("GuiButton") then
                button.Visible = true
            end
        end
    end
end)

local function openemotes(name, state, input)
    if state == Enum.UserInputState.Begin then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end

if IsStudio then
    ContextActionService:BindActionAtPriority(
        "Emote Menu",
        openemotes,
        true,
        2001,
        Enum.KeyCode.Comma
    )
else
    ContextActionService:BindCoreActionAtPriority(
        "Emote Menu",
        openemotes,
        true,
        2001,
        Enum.KeyCode.Comma
    )
end

local inputconnect
ScreenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
    if ScreenGui.Enabled == true then
        Title.Text = "Select an Emote"
        SearchBar.Text = ""
        SortFrame.Visible = false
        GuiService:SetEmotesMenuOpen(false)
        inputconnect = UserInputService.InputBegan:Connect(function(input, processed)
        end)
    else
        if inputconnect then
            inputconnect:Disconnect()
        end
    end
end)

if not IsStudio then
    GuiService.EmotesMenuOpenChanged:Connect(function(isopen)
        if isopen then
            ScreenGui.Enabled = false
        end
    end)
end

GuiService.MenuOpened:Connect(function()
    ScreenGui.Enabled = false
end)

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local LocalPlayer = Players.LocalPlayer

if IsStudio then
    ScreenGui.Parent = LocalPlayer.PlayerGui
else
    local SynV3 = syn and DrawingImmediate
    if (not is_sirhurt_closure) and (not SynV3) and (syn and syn.protect_gui) then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif get_hidden_gui or gethui then
        local hiddenUI = get_hidden_gui or gethui
        ScreenGui.Parent = hiddenUI()
    else
        ScreenGui.Parent = CoreGui
    end
end

local function SendNotification(title, text)
    if (not IsStudio) and syn and syn.toast_notification then
        syn.toast_notification({
            Type = ToastType.Error,
            Title = title,
            Content = text
        })
    else
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text
        })
    end
end

local function HumanoidPlayEmote(humanoid, name, id)
    if IsStudio then
        return humanoid:PlayEmote(name)
    else
        return humanoid:PlayEmoteAndGetAnimTrackById(id)
    end
end

local function PlayEmote(name: string, id: IntValue)
    SearchBar.Text = ""
    local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local Description = Humanoid and Humanoid:FindFirstChildOfClass("HumanoidDescription")
    if not Description then
        return
    end
    if LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R6 then
        local succ, err = pcall(function()
            HumanoidPlayEmote(Humanoid, name, id)
        end)
        if not succ then
            Description:AddEmote(name, id)
            HumanoidPlayEmote(Humanoid, name, id)
        end
    else
        SendNotification(
            "R6 Not Supported",
            "Emotes require R15 character rig."
        )
    end
end

local function WaitForChildOfClass(parent, class)
    local child = parent:FindFirstChildOfClass(class)
    while not child or child.ClassName ~= class do
        child = parent.ChildAdded:Wait()
    end
    return child
end

local params = CatalogSearchParams.new()
params.AssetTypes = {Enum.AvatarAssetType.EmoteAnimation}
params.SortType = Enum.CatalogSortType.RecentlyCreated
params.SortAggregation = Enum.CatalogSortAggregation.AllTime
params.IncludeOffSale = true
params.CreatorName = "Roblox"
params.Limit = 120

local function getCatalogPage()
    local success, catalogPage = pcall(function()
        return AvatarEditorService:SearchCatalog(params)
    end)
    if not success then
        task.wait(5)
        return getCatalogPage()
    end
    return catalogPage
end

local catalogPage = getCatalogPage()

local pages = {}

while true do
    local currentPage = catalogPage:GetCurrentPage()
    table.insert(pages, currentPage)
    if catalogPage.IsFinished then
        break
    end
    local function AdvanceToNextPage()
        local success = pcall(function()
            catalogPage:AdvanceToNextPageAsync()
        end)
        if not success then
            task.wait(5)
            return AdvanceToNextPage()
        end
    end
    AdvanceToNextPage()
end

local totalEmotes = {}
for _, page in pairs(pages) do
    for _, emote in pairs(page) do
        table.insert(totalEmotes, emote)
    end
end

for i, Emote in pairs(totalEmotes) do
    AddEmote(Emote.Name, Emote.Id, Emote.Price)
end

AddEmote("Arm Wave", 5915773155)
AddEmote("Head Banging", 5915779725)
AddEmote("Face Calisthenics", 9830731012)

Loading:Destroy()

table.sort(Emotes, function(a, b)
    return a.index < b.index
end)
for i,v in pairs(Emotes) do
    v.sort.newestfirst = i
end

table.sort(Emotes, function(a, b)
    return a.index > b.index
end)
for i,v in pairs(Emotes) do
    v.sort.oldestfirst = i
end

table.sort(Emotes, function(a, b)
    return a.name:lower() < b.name:lower()
end)
for i,v in pairs(Emotes) do
    v.sort.alphabetic = i
end

table.sort(Emotes, function(a, b)
    return a.name:lower() > b.name:lower()
end)
for i,v in pairs(Emotes) do
    v.sort.alphabeticlast = i
end

table.sort(Emotes, function(a, b)
    return a.price < b.price
end)
for i,v in pairs(Emotes) do
    v.sort.lowestprice = i
end

table.sort(Emotes, function(a, b)
    return a.price > b.price
end)
for i,v in pairs(Emotes) do
    v.sort.highestprice = i
end

local function IsFileFunc(...)
    if IsStudio then
        return
    elseif isfile then
        return isfile(...)
    end
end

local function WriteFileFunc(...)
    if IsStudio then
        return
    elseif writefile then
        return writefile(...)
    end
end

local function ReadFileFunc(...)
    if IsStudio then
        return
    elseif readfile then
        return readfile(...)
    end
end

if not IsStudio then
    if IsFileFunc("FavoritedEmotes.txt") then
        if not pcall(function()
            FavoritedEmotes = HttpService:JSONDecode(ReadFileFunc("FavoritedEmotes.txt"))
        end) then
            FavoritedEmotes = {}
        end
    else
        WriteFileFunc("FavoritedEmotes.txt", HttpService:JSONEncode(FavoritedEmotes))
    end
    local UpdatedFavorites = {}
    for i,name in pairs(FavoritedEmotes) do
        if typeof(name) == "string" then
            for i,emote in pairs(Emotes) do
                if emote.name == name then
                    table.insert(UpdatedFavorites, emote.id)
                    break
                end
            end
        end
    end
    if #UpdatedFavorites ~= 0 then
        FavoritedEmotes = UpdatedFavorites
        WriteFileFunc("FavoritedEmotes.txt", HttpService:JSONEncode(FavoritedEmotes))
    end
end

local function CharacterAdded(Character)
    for i,v in pairs(Frame:GetChildren()) do
        if not v:IsA("UIGridLayout") and not v:IsA("UIPadding") then
            v:Destroy()
        end
    end
    local Humanoid = WaitForChildOfClass(Character, "Humanoid")
    local Description = Humanoid:WaitForChild("HumanoidDescription", 5) or Instance.new("HumanoidDescription", Humanoid)
    
    local random = Instance.new("TextButton")
    local Ratio = Instance.new("UIAspectRatioConstraint")
    Ratio.AspectType = Enum.AspectType.ScaleWithParentSize
    Ratio.Parent = random
    random.LayoutOrder = 0
    random.TextColor3 = Color3.new(1, 1, 1)
    random.BorderSizePixel = 0
    random.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    random.TextScaled = true
    random.Text = "Random"
    random:SetAttribute("name", "")
    MainCorner:Clone().Parent = random
    
    local RandomStroke = Instance.new("UIStroke")
    RandomStroke.Color = Color3.fromRGB(75, 75, 75)
    RandomStroke.Transparency = 0.7
    RandomStroke.Thickness = 1
    RandomStroke.Parent = random
    
    random.MouseButton1Click:Connect(function()
        local randomemote = Emotes[math.random(1, #Emotes)]
        PlayEmote(randomemote.name, randomemote.id)
    end)
    random.MouseEnter:Connect(function()
        Title.Text = "Random"
    end)
    random.Parent = Frame

    for i,Emote in pairs(Emotes) do
        Description:AddEmote(Emote.name, Emote.id)
        local EmoteButton = Instance.new("ImageButton")
        local IsFavorited = table.find(FavoritedEmotes, Emote.id)
        EmoteButton.LayoutOrder = Emote.sort[CurrentSort] + ((IsFavorited and 0) or #Emotes)
        EmoteButton.Name = Emote.id
        EmoteButton:SetAttribute("name", Emote.name)
        MainCorner:Clone().Parent = EmoteButton
        EmoteButton.Image = Emote.icon
        EmoteButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        EmoteButton.BorderSizePixel = 0
        PanelStroke:Clone().Parent = EmoteButton
        Ratio:Clone().Parent = EmoteButton
        
        local EmoteNumber = Instance.new("TextLabel")
        EmoteNumber.Name = "number"
        EmoteNumber.TextScaled = true
        EmoteNumber.BackgroundTransparency = 1
        EmoteNumber.TextColor3 = Color3.new(1, 1, 1)
        EmoteNumber.BorderSizePixel = 0
        EmoteNumber.AnchorPoint = Vector2.new(0.5, 0.5)
        EmoteNumber.Size = UDim2.new(0.2, 0, 0.2, 0)
        EmoteNumber.Position = UDim2.new(0.1, 0, 0.9, 0)
        EmoteNumber.Text = Emote.sort[CurrentSort]
        EmoteNumber.TextXAlignment = Enum.TextXAlignment.Center
        EmoteNumber.TextYAlignment = Enum.TextYAlignment.Center
        EmoteNumber.Parent = EmoteButton
        
        EmoteButton.Parent = Frame
        EmoteButton.MouseButton1Click:Connect(function()
            PlayEmote(Emote.name, Emote.id)
        end)
        EmoteButton.MouseEnter:Connect(function()
            Title.Text = Emote.name
        end)

        local FavoriteOff = "☆"
        local FavoriteOn = "★"
        
        local Favorite = Instance.new("TextButton")
        Favorite.Name = "favorite"
        if table.find(FavoritedEmotes, Emote.id) then
            Favorite.Text = FavoriteOn
            Favorite.TextColor3 = Color3.fromRGB(255, 215, 0)
        else
            Favorite.Text = FavoriteOff
            Favorite.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        Favorite.AnchorPoint = Vector2.new(0.5, 0.5)
        Favorite.Size = UDim2.new(0.3, 0, 0.3, 0)
        Favorite.Position = UDim2.new(0.88, 0, 0.85, 0)
        Favorite.BorderSizePixel = 0
        Favorite.BackgroundTransparency = 1
        Favorite.TextScaled = true
        Favorite.Parent = EmoteButton
        
        Favorite.MouseButton1Click:Connect(function()
            local index = table.find(FavoritedEmotes, Emote.id)
            if index then
                table.remove(FavoritedEmotes, index)
                Favorite.Text = FavoriteOff
                Favorite.TextColor3 = Color3.fromRGB(150, 150, 150)
                EmoteButton.LayoutOrder = Emote.sort[CurrentSort] + #Emotes
            else
                table.insert(FavoritedEmotes, Emote.id)
                Favorite.Text = FavoriteOn
                Favorite.TextColor3 = Color3.fromRGB(255, 215, 0)
                EmoteButton.LayoutOrder = Emote.sort[CurrentSort]
            end
            WriteFileFunc("FavoritedEmotes.txt", HttpService:JSONEncode(FavoritedEmotes))
        end)

        Favorite.MouseEnter:Connect(function()
            if not table.find(FavoritedEmotes, Emote.id) then
                Favorite.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end)

        Favorite.MouseLeave:Connect(function()
            if not table.find(FavoritedEmotes, Emote.id) then
                Favorite.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end)
    end
    
    for i=1,9 do
        local EmoteButton = Instance.new("Frame")
        EmoteButton.LayoutOrder = 2147483647
        EmoteButton.Name = "filler"
        EmoteButton.BackgroundTransparency = 1
        EmoteButton.BorderSizePixel = 0
        Ratio:Clone().Parent = EmoteButton
        EmoteButton.Visible = true
        EmoteButton.Parent = Frame
        EmoteButton.MouseEnter:Connect(function()
            Title.Text = "Select an Emote"
        end)
    end
end

if LocalPlayer.Character then
    CharacterAdded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(CharacterAdded)
