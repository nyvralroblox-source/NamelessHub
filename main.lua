--[[
    Nameless Enhancement - Interface minimaliste
    Rectangle vertical, catégories cliquables, thèmes, config fonctionnel
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local FONT = Enum.Font.Gotham
local CONFIG_FOLDER = "NamelessEnhancement"
local CONFIGS_FOLDER = CONFIG_FOLDER .. "/Configs"
local ACTIVE_CONFIG_FILE = CONFIG_FOLDER .. "/active.txt"

-- Nettoyage si déjà existant
if playerGui:FindFirstChild("NamelessEnhancement") then
    playerGui.NamelessEnhancement:Destroy()
end

--// ================== THEMES ==================
local Themes = {
    {Name = "Nameless", Main = Color3.fromRGB(106, 142, 127), Bg = Color3.fromRGB(24, 24, 24), Section = Color3.fromRGB(32, 32, 32)},
    {Name = "Ocean",    Main = Color3.fromRGB(88, 140, 180),  Bg = Color3.fromRGB(20, 24, 28),  Section = Color3.fromRGB(28, 32, 38)},
    {Name = "Crimson",  Main = Color3.fromRGB(180, 90, 90),   Bg = Color3.fromRGB(26, 20, 20),  Section = Color3.fromRGB(34, 26, 26)},
    {Name = "Violet",   Main = Color3.fromRGB(140, 110, 180), Bg = Color3.fromRGB(22, 20, 28),  Section = Color3.fromRGB(30, 28, 36)},
    {Name = "Amber",    Main = Color3.fromRGB(190, 150, 80),  Bg = Color3.fromRGB(26, 24, 20),  Section = Color3.fromRGB(34, 30, 26)},
    {Name = "Mono",     Main = Color3.fromRGB(170, 170, 170), Bg = Color3.fromRGB(20, 20, 20),  Section = Color3.fromRGB(30, 30, 30)},
    {Name = "Forest",   Main = Color3.fromRGB(110, 170, 100), Bg = Color3.fromRGB(18, 24, 18),  Section = Color3.fromRGB(26, 32, 26)},
    {Name = "Rose",     Main = Color3.fromRGB(210, 120, 150), Bg = Color3.fromRGB(26, 20, 22),  Section = Color3.fromRGB(34, 27, 29)},
    {Name = "Cyber",    Main = Color3.fromRGB(80, 220, 210),  Bg = Color3.fromRGB(14, 18, 20),  Section = Color3.fromRGB(20, 26, 28)},
    {Name = "Sunset",   Main = Color3.fromRGB(220, 120, 70),  Bg = Color3.fromRGB(26, 20, 18),  Section = Color3.fromRGB(34, 26, 23)},
    {Name = "Ice",      Main = Color3.fromRGB(150, 200, 230), Bg = Color3.fromRGB(18, 22, 26),  Section = Color3.fromRGB(25, 30, 35)},
    {Name = "Blood",    Main = Color3.fromRGB(200, 40, 40),   Bg = Color3.fromRGB(16, 12, 12),  Section = Color3.fromRGB(24, 18, 18)},
    {Name = "Gold",     Main = Color3.fromRGB(220, 180, 90),  Bg = Color3.fromRGB(20, 18, 14),  Section = Color3.fromRGB(28, 25, 20)},
    {Name = "Lavender", Main = Color3.fromRGB(175, 160, 220), Bg = Color3.fromRGB(20, 19, 26),  Section = Color3.fromRGB(28, 27, 35)},
}

local currentTheme = Themes[1]

--// Registres pour appliquer un thème en direct
local mainColorElements = {}   -- {instance, property}
local toggleRegistry = {}      -- {button, dot, get=function() return enabled end}
local categoryButtons = {}
local pages = {}

--// ================== REGISTRE DE CONFIG GÉNÉRIQUE ==================
-- Permet à n'importe quel slider / palette de couleurs de s'enregistrer pour être
-- sauvegardé et restauré par le système de config (page Config).
local SettingsRegistry = {} -- [key] = {get = function() return value end, set = function(value) ... end}

local function registerSetting(key, getFn, setFn)
    SettingsRegistry[key] = {get = getFn, set = setFn}
end

local function colorToTable(color)
    return {r = color.R, g = color.G, b = color.B}
end

local function tableToColor(t)
    return Color3.new(t.r, t.g, t.b)
end

--// ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NamelessEnhancement"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 10000 -- toujours au premier plan, au-dessus des effets (crosshair, cercle dégradé, etc.)
ScreenGui.Parent = playerGui

--// Frame principal (rectangle vertical, un peu large)
local WINDOW_WIDTH = 500
local FULL_SIZE = UDim2.new(0, WINDOW_WIDTH, 0, 580)
local MINIMIZED_SIZE = UDim2.new(0, WINDOW_WIDTH, 0, 52)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = FULL_SIZE
MainFrame.Position = UDim2.new(0.5, -WINDOW_WIDTH / 2, 0.5, -290)
MainFrame.BackgroundColor3 = currentTheme.Bg
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = MainFrame

--// Titre en haut à gauche
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "Nameless Enhancement"
Title.TextColor3 = currentTheme.Main
Title.Font = FONT
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3
Title.Parent = MainFrame
table.insert(mainColorElements, {Title, "TextColor3"})

--// Séparateur sous le titre
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -30, 0, 1)
Divider.Position = UDim2.new(0, 15, 0, 52)
Divider.BackgroundColor3 = currentTheme.Main
Divider.BackgroundTransparency = 0.7
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame
table.insert(mainColorElements, {Divider, "BackgroundColor3"})

--// Poignée de déplacement (barre de titre)
local DragHandle = Instance.new("TextButton")
DragHandle.Name = "DragHandle"
DragHandle.Size = UDim2.new(1, 0, 0, 52)
DragHandle.BackgroundTransparency = 1
DragHandle.Text = ""
DragHandle.AutoButtonColor = false
DragHandle.ZIndex = 2
DragHandle.Parent = MainFrame

local function enableDragging(frame, handle)
    local dragging = false
    local dragStart
    local startPos
    local moveConn
    local endConn

    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        dragging = true
        dragStart = input.Position
        startPos = frame.Position

        if moveConn then moveConn:Disconnect() end
        if endConn then endConn:Disconnect() end

        moveConn = UserInputService.InputChanged:Connect(function(inp)
            if not dragging then return end
            if inp.UserInputType == Enum.UserInputType.MouseMovement
                or inp.UserInputType == Enum.UserInputType.Touch then
                local delta = inp.Position - dragStart
                frame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)

        endConn = UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                if moveConn then moveConn:Disconnect() end
                if endConn then endConn:Disconnect() end
            end
        end)
    end)
end

enableDragging(MainFrame, DragHandle)

--// Zone des catégories (colonne gauche)
local CategoryList = Instance.new("Frame")
CategoryList.Name = "CategoryList"
CategoryList.Size = UDim2.new(0, 110, 1, -70)
CategoryList.Position = UDim2.new(0, 10, 0, 62)
CategoryList.BackgroundTransparency = 1
CategoryList.Parent = MainFrame

local CategoryLayout = Instance.new("UIListLayout")
CategoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
CategoryLayout.Padding = UDim.new(0, 6)
CategoryLayout.Parent = CategoryList

--// Zone de contenu (pages, à droite)
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -140, 1, -70)
ContentArea.Position = UDim2.new(0, 130, 0, 62)
ContentArea.BackgroundColor3 = currentTheme.Section
ContentArea.BorderSizePixel = 0
ContentArea.ClipsDescendants = true
ContentArea.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 6)
ContentCorner.Parent = ContentArea

--// ================== SELECTION DE CATEGORIE ==================
local function selectCategory(name)
    for pageName, page in pairs(pages) do
        page.Visible = (pageName == name)
    end
    for btnName, btn in pairs(categoryButtons) do
        if btnName == name then
            btn.TextColor3 = currentTheme.Main
            btn.BackgroundTransparency = 0.85
        else
            btn.TextColor3 = Color3.fromRGB(160, 160, 160)
            btn.BackgroundTransparency = 1
        end
    end
end

--// ================== TOGGLES (avec état persistant) ==================
-- ToggleStates["Catégorie_NomOption"] = true/false
local ToggleStates = {}

local function createToggle(parent, order, categoryName, labelText, onChanged)
    local stateKey = categoryName .. "_" .. labelText
    if ToggleStates[stateKey] == nil then
        ToggleStates[stateKey] = false
    end

    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 34)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.LayoutOrder = order
    ToggleFrame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = FONT
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(1, -40, 0.5, -10)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleButton.Text = ""
    ToggleButton.AutoButtonColor = false
    ToggleButton.Parent = ToggleFrame

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleButton

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 16, 0, 16)
    Dot.Position = UDim2.new(0, 2, 0.5, -8)
    Dot.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    Dot.Parent = ToggleButton

    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = Dot

    local function refreshVisual()
        if ToggleStates[stateKey] then
            ToggleButton.BackgroundColor3 = currentTheme.Main
            Dot.Position = UDim2.new(1, -18, 0.5, -8)
            Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Dot.Position = UDim2.new(0, 2, 0.5, -8)
            Dot.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
        end
    end

    local function setState(value, silent)
        ToggleStates[stateKey] = value
        refreshVisual()
        if not silent and onChanged then
            onChanged(value)
        end
    end

    ToggleButton.MouseButton1Click:Connect(function()
        setState(not ToggleStates[stateKey])
    end)

    refreshVisual()

    table.insert(toggleRegistry, {
        button = ToggleButton,
        dot = Dot,
        stateKey = stateKey,
        refresh = refreshVisual,
        setState = setState,
    })

    return ToggleFrame, setState
end

--// ================== CONFIG DES CATEGORIES ==================
local CATEGORY_ORDER = {"Home", "Visuals", "World", "Combat", "Movement", "Themes", "Config"}

local CategoriesByName = {
    Home = {Name = "Home", Toggles = {}},
    Visuals = {Name = "Visuals", Toggles = {}},
    World = {Name = "World", Toggles = {}},
    Combat = {Name = "Combat", Toggles = {}},
    Movement = {Name = "Movement", Toggles = {}},
    Themes = {Name = "Themes", Toggles = {}},
    Config = {Name = "Config", Toggles = {}},
}

local Categories = {}
for i, name in ipairs(CATEGORY_ORDER) do
    local cat = CategoriesByName[name]
    cat.Order = i
    table.insert(Categories, cat)
end

--// Génération générique des catégories + pages (toggles simples)
for i, cat in ipairs(Categories) do
    local CatButton = Instance.new("TextButton")
    CatButton.Name = cat.Name
    CatButton.Size = UDim2.new(1, 0, 0, 32)
    CatButton.BackgroundColor3 = currentTheme.Main
    CatButton.BackgroundTransparency = 1
    CatButton.AutoButtonColor = false
    CatButton.Text = cat.Name
    CatButton.TextColor3 = Color3.fromRGB(160, 160, 160)
    CatButton.Font = FONT
    CatButton.TextSize = 14
    CatButton.LayoutOrder = cat.Order
    CatButton.Parent = CategoryList

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = CatButton

    categoryButtons[cat.Name] = CatButton

    local Page = Instance.new("ScrollingFrame")
    Page.Name = cat.Name
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = currentTheme.Main
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Visible = false
    Page.Parent = ContentArea
    table.insert(mainColorElements, {Page, "ScrollBarImageColor3"})

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 4)
    PageLayout.Parent = Page

    local PagePadding = Instance.new("UIPadding")
    PagePadding.PaddingTop = UDim.new(0, 10)
    PagePadding.PaddingLeft = UDim.new(0, 10)
    PagePadding.Parent = Page

    for j, toggleName in ipairs(cat.Toggles) do
        createToggle(Page, j, cat.Name, toggleName)
    end

    pages[cat.Name] = Page

    CatButton.MouseButton1Click:Connect(function()
        selectCategory(cat.Name)
    end)
end

--// Petit helper pour ajouter un simple label d'info (utilisé par Home)
local function createInfoLabel(parent, order, text, size)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, size or 20)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = FONT
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.LayoutOrder = order
    Label.Parent = parent
    return Label
end

--// Petit helper pour un bouton d'action (Save / Load / Reset...)
local function createActionButton(parent, order, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 0, 32)
    Btn.BackgroundColor3 = currentTheme.Main
    Btn.BackgroundTransparency = 0.75
    Btn.AutoButtonColor = false
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    Btn.Font = FONT
    Btn.TextSize = 14
    Btn.LayoutOrder = order
    Btn.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Btn

    Btn.MouseButton1Click:Connect(callback)
    table.insert(mainColorElements, {Btn, "BackgroundColor3"})
    return Btn
end

--// Helper pour créer un slider (barre de défilement)
local function createSlider(parent, order, labelText, minVal, maxVal, defaultVal, onChanged)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -20, 0, 50)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.LayoutOrder = order
    SliderFrame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = labelText .. ": " .. tostring(defaultVal)
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = FONT
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame

    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, 0, 0, 8)
    SliderBg.Position = UDim2.new(0, 0, 0, 24)
    SliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SliderBg.BorderSizePixel = 0
    SliderBg.Parent = SliderFrame

    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 4)
    SliderCorner.Parent = SliderBg

    local SliderFill = Instance.new("Frame")
    local fillPercent = (defaultVal - minVal) / (maxVal - minVal)
    SliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
    SliderFill.BackgroundColor3 = currentTheme.Main
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBg

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 4)
    FillCorner.Parent = SliderFill

    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(1, 0, 1, 0)
    SliderButton.BackgroundTransparency = 1
    SliderButton.Text = ""
    SliderButton.AutoButtonColor = false
    SliderButton.Parent = SliderBg

    local currentValue = defaultVal

    local function updateSlider(value)
        currentValue = math.clamp(value, minVal, maxVal)
        local newPercent = (currentValue - minVal) / (maxVal - minVal)
        SliderFill.Size = UDim2.new(newPercent, 0, 1, 0)
        Label.Text = labelText .. ": " .. tostring(math.floor(currentValue))
        if onChanged then
            onChanged(currentValue)
        end
    end

    SliderButton.MouseButton1Down:Connect(function()
        local inputConn
        inputConn = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = UserInputService:GetMouseLocation()
                local sliderAbsPos = SliderBg.AbsolutePosition
                local sliderAbsSize = SliderBg.AbsoluteSize
                local relativeX = math.clamp((mousePos.X - sliderAbsPos.X) / sliderAbsSize.X, 0, 1)
                local newValue = minVal + (relativeX * (maxVal - minVal))
                updateSlider(newValue)
            end
        end)

        local upConn
        upConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                inputConn:Disconnect()
                upConn:Disconnect()
            end
        end)
    end)

    table.insert(mainColorElements, {SliderFill, "BackgroundColor3"})
    
    return SliderFrame, updateSlider
end

--// Helper pour créer une palette de couleurs
local function createColorPalette(parent, order, labelText, colors, defaultColor, onColorSelected)
    local PaletteFrame = Instance.new("Frame")
    PaletteFrame.Size = UDim2.new(1, -20, 0, 60)
    PaletteFrame.BackgroundTransparency = 1
    PaletteFrame.LayoutOrder = order
    PaletteFrame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = FONT
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = PaletteFrame

    local ColorsContainer = Instance.new("Frame")
    ColorsContainer.Size = UDim2.new(1, 0, 0, 36)
    ColorsContainer.Position = UDim2.new(0, 0, 0, 24)
    ColorsContainer.BackgroundTransparency = 1
    ColorsContainer.Parent = PaletteFrame

    local ColorsLayout = Instance.new("UIListLayout")
    ColorsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ColorsLayout.Padding = UDim.new(0, 8)
    ColorsLayout.FillDirection = Enum.FillDirection.Horizontal
    ColorsLayout.Parent = ColorsContainer

    local selectedColor = defaultColor
    local colorButtons = {}

    for i, color in ipairs(colors) do
        local ColorBtn = Instance.new("TextButton")
        ColorBtn.Size = UDim2.new(0, 28, 0, 28)
        ColorBtn.BackgroundColor3 = color
        ColorBtn.BorderSizePixel = 0
        ColorBtn.AutoButtonColor = false
        ColorBtn.Text = ""
        ColorBtn.LayoutOrder = i
        ColorBtn.Parent = ColorsContainer

        local ColorCorner = Instance.new("UICorner")
        ColorCorner.CornerRadius = UDim.new(0, 4)
        ColorCorner.Parent = ColorBtn

        local SelectionBorder = Instance.new("UIStroke")
        SelectionBorder.Color = Color3.fromRGB(255, 255, 255)
        SelectionBorder.Thickness = 2
        SelectionBorder.Transparency = 1
        SelectionBorder.Parent = ColorBtn

        -- Vérifier si cette couleur correspond à la couleur par défaut
        if color.R == defaultColor.R and color.G == defaultColor.G and color.B == defaultColor.B then
            SelectionBorder.Transparency = 0
        end

        ColorBtn.MouseButton1Click:Connect(function()
            selectedColor = color
            for _, btn in ipairs(colorButtons) do
                btn.border.Transparency = 1
            end
            SelectionBorder.Transparency = 0
            if onColorSelected then
                onColorSelected(color)
            end
        end)

        table.insert(colorButtons, {button = ColorBtn, border = SelectionBorder, color = color})
    end

    -- Sélectionne une couleur par programme (utilisé par le système de config au chargement).
    -- Fonctionne même si la couleur ne fait pas partie de la palette prédéfinie (les bordures
    -- de sélection sont alors toutes désactivées, mais la couleur/effet est bien appliqué).
    local function selectColor(color, silent)
        selectedColor = color
        local matched = false
        for _, entry in ipairs(colorButtons) do
            local c = entry.color
            if c.R == color.R and c.G == color.G and c.B == color.B then
                entry.border.Transparency = 0
                matched = true
            else
                entry.border.Transparency = 1
            end
        end
        if not matched then
            for _, entry in ipairs(colorButtons) do
                entry.border.Transparency = 1
            end
        end
        if not silent and onColorSelected then
            onColorSelected(color)
        end
    end

    return PaletteFrame, selectColor
end



local function createEmoteButton(parent, order, emote, onClick)
    local Btn = Instance.new("TextButton")
    Btn.Name = emote.Id
    Btn.Size = UDim2.new(1, -20, 0, 48)
    Btn.BackgroundColor3 = currentTheme.Main
    Btn.BackgroundTransparency = 0.82
    Btn.AutoButtonColor = false
    Btn.Text = ""
    Btn.LayoutOrder = order
    Btn.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Btn

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -16, 0, 20)
    NameLabel.Position = UDim2.new(0, 8, 0, 6)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = emote.Name
    NameLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
    NameLabel.Font = Enum.Font.GothamMedium
    NameLabel.TextSize = 14
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = Btn

    local DescLabel = Instance.new("TextLabel")
    DescLabel.Size = UDim2.new(1, -16, 0, 16)
    DescLabel.Position = UDim2.new(0, 8, 0, 26)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Text = emote.Description
    DescLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    DescLabel.Font = FONT
    DescLabel.TextSize = 11
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
    DescLabel.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        onClick(emote, Btn)
    end)

    table.insert(mainColorElements, {Btn, "BackgroundColor3"})
    return Btn, NameLabel
end

--// ================== SYSTEME D'EMOTES ==================
local activeEmoteId = nil
local emoteStartedAt = 0
local emoteConnection = nil
local emoteButtonRefs = {}

local function getCharacter()
    local character = player.Character
    if not character then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return nil end
    return character, humanoid
end

local function findJoint(part0, part1)
    if not part0 or not part1 then return nil end
    
    -- Recherche dans part0
    for _, child in ipairs(part0:GetChildren()) do
        if child:IsA("Motor6D") and (child.Part0 == part0 or child.Part1 == part0) and (child.Part0 == part1 or child.Part1 == part1) then
            return child
        end
    end
    
    -- Recherche dans part1
    for _, child in ipairs(part1:GetChildren()) do
        if child:IsA("Motor6D") and (child.Part0 == part0 or child.Part1 == part0) and (child.Part0 == part1 or child.Part1 == part1) then
            return child
        end
    end
    
    -- Recours: Recherche dans tout le personnage
    local character = part0.Parent
    if character and character:IsA("Model") then
        for _, child in ipairs(character:GetDescendants()) do
            if child:IsA("Motor6D") and (child.Part0 == part0 or child.Part1 == part0) and (child.Part0 == part1 or child.Part1 == part1) then
                return child
            end
        end
    end
    
    -- Recours R6 par nom
    if part0.Name == "HumanRootPart" and part1.Name == "Torso" then
        return part0:FindFirstChild("RootJoint") or part1:FindFirstChild("RootJoint")
    elseif part0.Name == "Torso" then
        if part1.Name == "Left Arm" or part1.Name == "LeftUpperArm" then
            return part0:FindFirstChild("Left Shoulder") or part1:FindFirstChild("Left Shoulder")
        elseif part1.Name == "Right Arm" or part1.Name == "RightUpperArm" then
            return part0:FindFirstChild("Right Shoulder") or part1:FindFirstChild("Right Shoulder")
        end
    end
    
    return nil
end

local function getRig(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local upperTorso = character:FindFirstChild("UpperTorso")
    local lowerTorso = character:FindFirstChild("LowerTorso")
    local leftUpperArm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm")
    local rightUpperArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm")
    local leftLowerArm = character:FindFirstChild("LeftLowerArm")
    local rightLowerArm = character:FindFirstChild("RightLowerArm")
    local torso = character:FindFirstChild("Torso")

    return {
        isR15 = upperTorso ~= nil and lowerTorso ~= nil,
        hrp = hrp,
        upperTorso = upperTorso,
        lowerTorso = lowerTorso,
        leftUpperArm = leftUpperArm,
        rightUpperArm = rightUpperArm,
        leftLowerArm = leftLowerArm,
        rightLowerArm = rightLowerArm,
        torso = torso,
    }
end

local function applyJointOffset(joint, offset)
    if not joint then return end
    joint.Transform = offset
end

local function stopEmote()
    if emoteConnection then
        emoteConnection:Disconnect()
        emoteConnection = nil
    end

    activeEmoteId = nil
    emoteStartedAt = 0

    for _, refs in pairs(emoteButtonRefs) do
        refs.button.BackgroundTransparency = 0.82
        refs.nameLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
    end
end

local function applyEmotePose(character, emoteId, elapsed)
    local rig = getRig(character)

    if rig.isR15 then
        local root = findJoint(rig.hrp, rig.lowerTorso)
        local waist = findJoint(rig.lowerTorso, rig.upperTorso)
        local leftShoulder = findJoint(rig.upperTorso, rig.leftUpperArm)
        local rightShoulder = findJoint(rig.upperTorso, rig.rightUpperArm)
        local leftElbow = findJoint(rig.leftUpperArm, rig.leftLowerArm)
        local rightElbow = findJoint(rig.rightUpperArm, rig.rightLowerArm)

        if emoteId == "hip_sway" then
            local sway = math.sin(elapsed * 3.2) * math.rad(22)

            applyJointOffset(root, CFrame.Angles(0, 0, sway * 0.35))
            applyJointOffset(waist, CFrame.Angles(0, 0, sway))
            applyJointOffset(leftShoulder, CFrame.Angles(math.rad(-60), math.rad(-30), math.rad(120)))
            applyJointOffset(rightShoulder, CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-120)))
            applyJointOffset(leftElbow, CFrame.Angles(math.rad(-90), 0, 0))
            applyJointOffset(rightElbow, CFrame.Angles(math.rad(-90), 0, 0))
            return true
        elseif emoteId == "wave" then
            local wave = math.sin(elapsed * 8) * math.rad(20)

            applyJointOffset(rightShoulder, CFrame.Angles(math.rad(-40), math.rad(28), wave))
            applyJointOffset(rightElbow, CFrame.Angles(math.rad(-40), 0, 0))
            return true
        elseif emoteId == "crossed_arms" then
            applyJointOffset(leftShoulder, CFrame.Angles(math.rad(12), math.rad(22), math.rad(78)))
            applyJointOffset(rightShoulder, CFrame.Angles(math.rad(12), math.rad(-22), math.rad(-78)))
            applyJointOffset(leftElbow, CFrame.Angles(math.rad(-100), 0, 0))
            applyJointOffset(rightElbow, CFrame.Angles(math.rad(-100), 0, 0))
            return true
        elseif emoteId == "slow_dance" then
            local sway = math.sin(elapsed * 2.4) * math.rad(14)
            local bob = math.sin(elapsed * 4.8) * 0.05

            applyJointOffset(root, CFrame.new(0, bob * 0.4, 0) * CFrame.Angles(0, 0, sway * 0.35))
            applyJointOffset(waist, CFrame.new(0, bob, 0) * CFrame.Angles(0, sway * 0.5, sway))
            applyJointOffset(leftShoulder, CFrame.Angles(math.rad(-12), math.rad(38), math.rad(22)))
            applyJointOffset(rightShoulder, CFrame.Angles(math.rad(-12), math.rad(-38), math.rad(-22)))
            return true
        elseif emoteId == "dab" then
            -- Bras droit tendu en diagonale haute, bras gauche replié devant le visage
            local bob = math.sin(elapsed * 6) * 0.02

            applyJointOffset(waist, CFrame.new(0, bob, 0) * CFrame.Angles(0, 0, math.rad(-8)))
            applyJointOffset(rightShoulder, CFrame.Angles(math.rad(-100), math.rad(10), math.rad(-35)))
            applyJointOffset(rightElbow, CFrame.Angles(math.rad(-10), 0, 0))
            applyJointOffset(leftShoulder, CFrame.Angles(math.rad(20), math.rad(-30), math.rad(70)))
            applyJointOffset(leftElbow, CFrame.Angles(math.rad(-130), 0, 0))
            return true
        elseif emoteId == "floss" then
            -- Bras qui balancent d'avant en arrière en opposition, hanches qui suivent
            local swing = math.sin(elapsed * 7) 
            local armSwing = swing * math.rad(55)
            local hipSwing = -swing * math.rad(14)

            applyJointOffset(root, CFrame.Angles(0, 0, hipSwing * 0.4))
            applyJointOffset(waist, CFrame.Angles(hipSwing * 0.3, 0, hipSwing))
            applyJointOffset(rightShoulder, CFrame.Angles(armSwing, math.rad(6), math.rad(-8)))
            applyJointOffset(rightElbow, CFrame.Angles(math.rad(-15), 0, 0))
            applyJointOffset(leftShoulder, CFrame.Angles(-armSwing, math.rad(-6), math.rad(8)))
            applyJointOffset(leftElbow, CFrame.Angles(math.rad(-15), 0, 0))
            return true
        elseif emoteId == "point" then
            -- Alterne un bras tendu qui pointe vers l'avant pendant que l'autre reste sur la hanche
            local cycle = (elapsed % 1.6)
            local pointingRight = cycle < 0.8
            local punch = math.sin((cycle % 0.8) / 0.8 * math.pi)

            local bounce = math.sin(elapsed * 6) * math.rad(6)
            applyJointOffset(root, CFrame.Angles(0, 0, bounce))

            if pointingRight then
                applyJointOffset(rightShoulder, CFrame.Angles(math.rad(-70 - punch * 20), math.rad(10), math.rad(-10)))
                applyJointOffset(rightElbow, CFrame.Angles(math.rad(-5), 0, 0))
                applyJointOffset(leftShoulder, CFrame.Angles(math.rad(15), math.rad(-15), math.rad(60)))
                applyJointOffset(leftElbow, CFrame.Angles(math.rad(-100), 0, 0))
            else
                applyJointOffset(leftShoulder, CFrame.Angles(math.rad(-70 - punch * 20), math.rad(-10), math.rad(10)))
                applyJointOffset(leftElbow, CFrame.Angles(math.rad(-5), 0, 0))
                applyJointOffset(rightShoulder, CFrame.Angles(math.rad(15), math.rad(15), math.rad(-60)))
                applyJointOffset(rightElbow, CFrame.Angles(math.rad(-100), 0, 0))
            end
            return true
        elseif emoteId == "robot" then
            -- Mouvements saccadés/quantifiés façon "robot", un membre à la fois
            local step = math.floor(elapsed * 2) % 4
            local snap = ((elapsed * 2) % 1) < 0.15 -- petite pause nette entre les poses

            if step == 0 then
                applyJointOffset(rightShoulder, CFrame.Angles(math.rad(-90), 0, 0))
                applyJointOffset(rightElbow, CFrame.Angles(0, 0, 0))
                applyJointOffset(leftShoulder, CFrame.Angles(0, 0, math.rad(75)))
                applyJointOffset(leftElbow, CFrame.Angles(math.rad(-90), 0, 0))
            elseif step == 1 then
                applyJointOffset(rightShoulder, CFrame.Angles(0, 0, math.rad(-75)))
                applyJointOffset(rightElbow, CFrame.Angles(math.rad(-90), 0, 0))
                applyJointOffset(leftShoulder, CFrame.Angles(math.rad(-90), 0, 0))
                applyJointOffset(leftElbow, CFrame.Angles(0, 0, 0))
            elseif step == 2 then
                applyJointOffset(rightShoulder, CFrame.Angles(math.rad(-45), 0, math.rad(-30)))
                applyJointOffset(rightElbow, CFrame.Angles(math.rad(-45), 0, 0))
                applyJointOffset(leftShoulder, CFrame.Angles(math.rad(-45), 0, math.rad(30)))
                applyJointOffset(leftElbow, CFrame.Angles(math.rad(-45), 0, 0))
            else
                applyJointOffset(rightShoulder, CFrame.Angles(0, 0, math.rad(-15)))
                applyJointOffset(rightElbow, CFrame.Angles(0, 0, 0))
                applyJointOffset(leftShoulder, CFrame.Angles(0, 0, math.rad(15)))
                applyJointOffset(leftElbow, CFrame.Angles(0, 0, 0))
            end

            applyJointOffset(root, CFrame.Angles(0, snap and math.rad(20) or 0, 0))
            return true
        elseif emoteId == "shrug" then
            -- Hausse les épaules en rythme, paumes vers le haut, tête impliquée via le torse
            local bounce = math.max(0, math.sin(elapsed * 3.5))
            local lift = bounce * 0.08

            applyJointOffset(waist, CFrame.new(0, lift, 0) * CFrame.Angles(0, 0, 0))
            applyJointOffset(leftShoulder, CFrame.Angles(math.rad(-10), math.rad(-10 - bounce * 15), math.rad(60 + bounce * 10)))
            applyJointOffset(leftElbow, CFrame.Angles(math.rad(-100), 0, 0))
            applyJointOffset(rightShoulder, CFrame.Angles(math.rad(-10), math.rad(10 + bounce * 15), math.rad(-60 - bounce * 10)))
            applyJointOffset(rightElbow, CFrame.Angles(math.rad(-100), 0, 0))
            return true
        end

        return false
    end

    if not rig.torso or not rig.hrp then
        return false
    end

    local rootJoint = findJoint(rig.hrp, rig.torso) or rig.hrp:FindFirstChild("RootJoint")
    local leftShoulder = findJoint(rig.torso, rig.leftUpperArm)
        or rig.torso:FindFirstChild("Left Shoulder")
    local rightShoulder = findJoint(rig.torso, rig.rightUpperArm)
        or rig.torso:FindFirstChild("Right Shoulder")

    if emoteId == "hip_sway" then
        local sway = math.sin(elapsed * 3.2) * math.rad(18)

        applyJointOffset(rootJoint, CFrame.Angles(0, 0, sway))
        applyJointOffset(leftShoulder, CFrame.Angles(math.rad(-60), 0, math.rad(110)))
        applyJointOffset(rightShoulder, CFrame.Angles(math.rad(-60), 0, math.rad(-110)))
        return true
    elseif emoteId == "wave" then
        local wave = math.sin(elapsed * 8) * math.rad(20)
        applyJointOffset(rightShoulder, CFrame.Angles(math.rad(-35), math.rad(22), wave))
        return true
    elseif emoteId == "crossed_arms" then
        applyJointOffset(leftShoulder, CFrame.Angles(math.rad(10), math.rad(18), math.rad(74)))
        applyJointOffset(rightShoulder, CFrame.Angles(math.rad(10), math.rad(-18), math.rad(-74)))
        return true
    elseif emoteId == "slow_dance" then
        local sway = math.sin(elapsed * 2.4) * math.rad(12)
        applyJointOffset(rootJoint, CFrame.Angles(0, sway * 0.45, sway))
        applyJointOffset(leftShoulder, CFrame.Angles(math.rad(-10), math.rad(32), math.rad(18)))
        applyJointOffset(rightShoulder, CFrame.Angles(math.rad(-10), math.rad(-32), math.rad(-18)))
        return true
    elseif emoteId == "dab" then
        applyJointOffset(rootJoint, CFrame.Angles(0, 0, math.rad(-8)))
        applyJointOffset(rightShoulder, CFrame.Angles(math.rad(-90), math.rad(10), math.rad(-30)))
        applyJointOffset(leftShoulder, CFrame.Angles(math.rad(-20), math.rad(-25), math.rad(95)))
        return true
    elseif emoteId == "floss" then
        local swing = math.sin(elapsed * 7)
        local armSwing = swing * math.rad(50)
        local hipSwing = -swing * math.rad(12)

        applyJointOffset(rootJoint, CFrame.Angles(0, 0, hipSwing))
        applyJointOffset(rightShoulder, CFrame.Angles(armSwing, math.rad(6), math.rad(-8)))
        applyJointOffset(leftShoulder, CFrame.Angles(-armSwing, math.rad(-6), math.rad(8)))
        return true
    elseif emoteId == "point" then
        local cycle = (elapsed % 1.6)
        local pointingRight = cycle < 0.8
        local punch = math.sin((cycle % 0.8) / 0.8 * math.pi)
        local bounce = math.sin(elapsed * 6) * math.rad(6)

        applyJointOffset(rootJoint, CFrame.Angles(0, 0, bounce))

        if pointingRight then
            applyJointOffset(rightShoulder, CFrame.Angles(math.rad(-70 - punch * 20), math.rad(10), math.rad(-10)))
            applyJointOffset(leftShoulder, CFrame.Angles(math.rad(15), math.rad(-15), math.rad(70)))
        else
            applyJointOffset(leftShoulder, CFrame.Angles(math.rad(-70 - punch * 20), math.rad(-10), math.rad(10)))
            applyJointOffset(rightShoulder, CFrame.Angles(math.rad(15), math.rad(15), math.rad(-70)))
        end
        return true
    elseif emoteId == "robot" then
        local step = math.floor(elapsed * 2) % 4
        local snap = ((elapsed * 2) % 1) < 0.15

        if step == 0 then
            applyJointOffset(rightShoulder, CFrame.Angles(math.rad(-90), 0, 0))
            applyJointOffset(leftShoulder, CFrame.Angles(0, 0, math.rad(75)))
        elseif step == 1 then
            applyJointOffset(rightShoulder, CFrame.Angles(0, 0, math.rad(-75)))
            applyJointOffset(leftShoulder, CFrame.Angles(math.rad(-90), 0, 0))
        elseif step == 2 then
            applyJointOffset(rightShoulder, CFrame.Angles(math.rad(-45), 0, math.rad(-30)))
            applyJointOffset(leftShoulder, CFrame.Angles(math.rad(-45), 0, math.rad(30)))
        else
            applyJointOffset(rightShoulder, CFrame.Angles(0, 0, math.rad(-15)))
            applyJointOffset(leftShoulder, CFrame.Angles(0, 0, math.rad(15)))
        end

        applyJointOffset(rootJoint, CFrame.Angles(0, snap and math.rad(20) or 0, 0))
        return true
    elseif emoteId == "shrug" then
        local bounce = math.max(0, math.sin(elapsed * 3.5))

        applyJointOffset(leftShoulder, CFrame.Angles(math.rad(-10), math.rad(-10 - bounce * 15), math.rad(70 + bounce * 10)))
        applyJointOffset(rightShoulder, CFrame.Angles(math.rad(-10), math.rad(10 + bounce * 15), math.rad(-70 - bounce * 10)))
        return true
    end

    return false
end

local function startEmote(emoteId)
    if activeEmoteId == emoteId then
        stopEmote()
        return
    end

    stopEmote()

    local character, humanoid = getCharacter()
    if not character then return end

    activeEmoteId = emoteId
    emoteStartedAt = tick()

    if emoteButtonRefs[emoteId] then
        emoteButtonRefs[emoteId].button.BackgroundTransparency = 0.45
        emoteButtonRefs[emoteId].nameLabel.TextColor3 = currentTheme.Main
    end

    emoteConnection = RunService.Stepped:Connect(function()
        local char = getCharacter()
        if not char or not activeEmoteId then
            stopEmote()
            return
        end

        applyEmotePose(char, activeEmoteId, tick() - emoteStartedAt)
    end)
end

local skinConnection = nil
local skinParts = {}
local customSkinActive = false

local function removeCustomSkin()
    if skinConnection then
        skinConnection:Disconnect()
        skinConnection = nil
    end
    for _, part in ipairs(skinParts) do
        if part.Parent then
            part:Destroy()
        end
    end
    skinParts = {}
end

local function applyCustomSkin()
    removeCustomSkin()
    
    local character = player.Character
    if not character then return end
    
    local head = character:WaitForChild("Head", 3)
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not head or not torso or not root then return end
    
    -- 1. Créer l'auréole (grande, très lumineuse, toujours parfaitement horizontale)
    local halo = Instance.new("Part")
    halo.Name = "CustomSkin_Halo"
    halo.Size = Vector3.new(1.2, 0.1, 1.2)
    halo.Material = Enum.Material.Neon
    halo.Color = Color3.fromRGB(255, 250, 220)
    halo.CanCollide = false
    halo.Massless = true
    halo.Transparency = 0 -- pleinement lumineuse, plus de voile
    halo.Parent = character
    table.insert(skinParts, halo)
    
    local haloMesh = Instance.new("SpecialMesh")
    haloMesh.MeshId = "rbxassetid://3270017" -- Torus
    haloMesh.Scale = Vector3.new(2.4, 2.4, 2.4) -- beaucoup plus grande qu'avant
    haloMesh.Parent = halo
    
    local haloLight = Instance.new("PointLight")
    haloLight.Color = Color3.fromRGB(255, 245, 210)
    haloLight.Brightness = 4
    haloLight.Range = 12
    haloLight.Parent = halo
    
    -- 2. Créer les ailes (beaucoup plus grandes, décollées du dos pour ne plus être "coincées"/plaquées dedans)
    local leftFeathers = {}
    local rightFeathers = {}
    
    local featherSizes = {
        Vector3.new(0.15, 1.1, 5.5), -- Plume haute
        Vector3.new(0.15, 0.9, 4.4), -- Plume moyenne
        Vector3.new(0.15, 0.7, 3.3), -- Plume basse
    }
    
    for i = 1, 3 do
        local lf = Instance.new("Part")
        lf.Name = "CustomSkin_LFeather" .. i
        lf.Size = featherSizes[i]
        lf.Material = Enum.Material.Neon
        lf.Color = Color3.fromRGB(255, 255, 255) -- Très blanc
        lf.CanCollide = false
        lf.Massless = true
        lf.Parent = character
        table.insert(skinParts, lf)
        table.insert(leftFeathers, lf)
        
        local rf = Instance.new("Part")
        rf.Name = "CustomSkin_RFeather" .. i
        rf.Size = featherSizes[i]
        rf.Material = Enum.Material.Neon
        rf.Color = Color3.fromRGB(255, 255, 255)
        rf.CanCollide = false
        rf.Massless = true
        rf.Parent = character
        table.insert(skinParts, rf)
        table.insert(rightFeathers, rf)
    end
    
    -- Loop de mise à jour des positions
    skinConnection = RunService.RenderStepped:Connect(function()
        if not character.Parent or not head.Parent or not torso.Parent or not root.Parent then
            removeCustomSkin()
            return
        end
        
        local time = tick()
        local bob = math.sin(time * 3) * 0.1
        local rot = time * 2
        
        -- Auréole : ancrée uniquement sur la POSITION de la tête (pas sa rotation complète),
        -- donc elle reste toujours parfaitement à plat/horizontale, même si tu lèves ou baisses la tête.
        halo.CFrame = CFrame.new(head.Position + Vector3.new(0, 1.6 + bob, 0)) * CFrame.Angles(math.rad(90), rot, 0)
        
        -- Ailes : ancrées sur le HumanoidRootPart (qui ne fait que pivoter à gauche/droite,
        -- il ne se penche jamais), avec un grand décalage vers l'arrière et le haut pour
        -- qu'elles flottent clairement DERRIÈRE toi au lieu d'être plaquées/enfoncées dans le dos.
        local flap = math.sin(time * 3) * math.rad(10)
        local rootCF = root.CFrame
        
        -- Aile gauche (feathers)
        local leftBaseCF = rootCF * CFrame.new(-1.0, 1.2, 1.6)
        local lAngles = {
            CFrame.Angles(math.rad(15), math.rad(135) + flap, math.rad(20)),
            CFrame.Angles(math.rad(5), math.rad(145) + flap * 0.7, math.rad(5)),
            CFrame.Angles(math.rad(-5), math.rad(155) + flap * 0.4, math.rad(-10))
        }
        local lOffsets = {
            CFrame.new(0, 0, 0),
            CFrame.new(0, -0.6, -0.4),
            CFrame.new(0, -1.2, -0.8)
        }
        for i = 1, 3 do
            leftFeathers[i].CFrame = leftBaseCF * lOffsets[i] * lAngles[i] * CFrame.new(0, 0, featherSizes[i].Z / 2)
        end
        
        -- Aile droite (feathers)
        local rightBaseCF = rootCF * CFrame.new(1.0, 1.2, 1.6)
        local rAngles = {
            CFrame.Angles(math.rad(15), math.rad(-135) - flap, math.rad(-20)),
            CFrame.Angles(math.rad(5), math.rad(-145) - flap * 0.7, math.rad(-5)),
            CFrame.Angles(math.rad(-5), math.rad(-155) - flap * 0.4, math.rad(10))
        }
        local rOffsets = {
            CFrame.new(0, 0, 0),
            CFrame.new(0, -0.6, -0.4),
            CFrame.new(0, -1.2, -0.8)
        }
        for i = 1, 3 do
            rightFeathers[i].CFrame = rightBaseCF * rOffsets[i] * rAngles[i] * CFrame.new(0, 0, featherSizes[i].Z / 2)
        end
    end)
end

local function toggleCustomSkin(enabled)
    customSkinActive = enabled
    if enabled then
        applyCustomSkin()
    else
        removeCustomSkin()
    end
end

player.CharacterAdded:Connect(function()
    stopEmote()
    if customSkinActive then
        task.wait(0.5)
        applyCustomSkin()
    end
end)

local Emotes = {
    {
        Id = "hip_sway",
        Name = "Mains derrière la tête",
        Description = "Mains derrière la tête + hanches gauche/droite",
    },
    {
        Id = "wave",
        Name = "Salut",
        Description = "Salue de la main droite",
    },
    {
        Id = "crossed_arms",
        Name = "Bras croisés",
        Description = "Pose les bras croisés",
    },
    {
        Id = "slow_dance",
        Name = "Danse lente",
        Description = "Balancement lent du buste",
    },
    {
        Id = "dab",
        Name = "Dab",
        Description = "Bras tendu en diagonale, coude plié devant le visage",
    },
    {
        Id = "floss",
        Name = "Floss",
        Description = "Bras qui balancent d'avant en arrière, hanches qui suivent",
    },
    {
        Id = "point",
        Name = "Point",
        Description = "Pointe alternativement vers l'avant en rythme",
    },
    {
        Id = "robot",
        Name = "Robot",
        Description = "Mouvements saccadés, un membre à la fois",
    },
    {
        Id = "shrug",
        Name = "Shrug",
        Description = "Hausse les épaules en rythme",
    },
}

do
    local MovementPage = pages["Movement"]
    createInfoLabel(MovementPage, 1, "Choisis une emote à jouer :", 20)

    for i, emote in ipairs(Emotes) do
        local button, nameLabel = createEmoteButton(MovementPage, i + 1, emote, function(selectedEmote)
            startEmote(selectedEmote.Id)
        end)
        emoteButtonRefs[emote.Id] = {
            button = button,
            nameLabel = nameLabel,
        }
    end

    createInfoLabel(MovementPage, #Emotes + 2, "Clique à nouveau sur une emote active pour l'arrêter.", 34)

    -- Nouveau : Mode troisième personne (souvent réservé à la manette par défaut dans certains jeux)
    createInfoLabel(MovementPage, #Emotes + 3, "Caméra :", 20)

    local thirdPersonEnabled = false
    local thirdPersonConnection = nil

    local function toggleThirdPerson(enabled)
        thirdPersonEnabled = enabled

        if thirdPersonConnection then
            thirdPersonConnection:Disconnect()
            thirdPersonConnection = nil
        end

        if enabled then
            -- Certains jeux réappliquent la vue première personne en boucle pour le clavier/souris ;
            -- on force donc la vue classique (3e personne) en continu tant que l'option est active.
            thirdPersonConnection = RunService.Heartbeat:Connect(function()
                if not thirdPersonEnabled then return end
                player.CameraMode = Enum.CameraMode.Classic
                player.CameraMinZoomDistance = 10
                player.CameraMaxZoomDistance = 20
            end)
        else
            player.CameraMode = Enum.CameraMode.Classic
        end
    end

    createToggle(MovementPage, #Emotes + 4, "Movement", "Troisième personne (forcer)", function(enabled)
        toggleThirdPerson(enabled)
    end)

    -- Nouveau : Troisième personne vue diagonale arrière (au-dessus et derrière, avatar visible)
    local topDownEnabled = false
    local topDownConnection = nil
    local topDownHeight = 12
    local topDownDistance = 14

    local function toggleTopDownView(enabled)
        topDownEnabled = enabled

        if topDownConnection then
            topDownConnection:Disconnect()
            topDownConnection = nil
        end

        local camera = workspace.CurrentCamera

        if enabled then
            -- Cette vue prend la main sur la caméra ; si "Troisième personne (forcer)" tourne aussi,
            -- c'est cette boucle-ci qui l'emporte tant qu'elle est active.
            if camera then
                camera.CameraType = Enum.CameraType.Scriptable
            end

            topDownConnection = RunService.RenderStepped:Connect(function()
                if not topDownEnabled then return end

                local character = player.Character
                if not character then return end
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end

                local cam = workspace.CurrentCamera
                if not cam then return end

                -- Décalée derrière le perso (sens inverse de son regard) et au-dessus, pas à la verticale pure
                local lookVector = rootPart.CFrame.LookVector
                local behindOffset = -lookVector * topDownDistance
                local eyePos = rootPart.Position + behindOffset + Vector3.new(0, topDownHeight, 0)
                local focusPoint = rootPart.Position + Vector3.new(0, 2, 0)

                cam.CFrame = CFrame.new(eyePos, focusPoint)
            end)
        else
            -- Rend la main à la caméra classique de Roblox
            if camera then
                camera.CameraType = Enum.CameraType.Custom
            end
        end
    end

    createToggle(MovementPage, #Emotes + 5, "Movement", "Troisième personne (vue diagonale arrière)", function(enabled)
        toggleTopDownView(enabled)
    end)

    local _, updateCamHeight = createSlider(MovementPage, #Emotes + 6, "Hauteur de la caméra", 4, 30, 12, function(value)
        topDownHeight = value
    end)

    local _, updateCamDistance = createSlider(MovementPage, #Emotes + 7, "Distance derrière", 4, 30, 14, function(value)
        topDownDistance = value
    end)

    registerSetting("topDownHeight",
        function() return topDownHeight end,
        function(v) updateCamHeight(v) end
    )
    registerSetting("topDownDistance",
        function() return topDownDistance end,
        function(v) updateCamDistance(v) end
    )
end

--// ================== PAGE HOME (vitrine visuelle) ==================
do
    local HomePage = pages["Home"]
    -- On désactive le padding/layout par défaut pour construire une mise en page libre
    local existingLayout = HomePage:FindFirstChildOfClass("UIListLayout")
    if existingLayout then existingLayout:Destroy() end
    local existingPadding = HomePage:FindFirstChildOfClass("UIPadding")
    if existingPadding then existingPadding:Destroy() end
    HomePage.AutomaticCanvasSize = Enum.AutomaticSize.None
    HomePage.CanvasSize = UDim2.new(0, 0, 0, 420)

    --// Bannière du haut avec dégradé
    local Banner = Instance.new("Frame")
    Banner.Size = UDim2.new(1, 0, 0, 130)
    Banner.Position = UDim2.new(0, 0, 0, 0)
    Banner.BorderSizePixel = 0
    Banner.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Banner.ClipsDescendants = true
    Banner.Parent = HomePage

    local BannerGradient = Instance.new("UIGradient")
    BannerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, currentTheme.Main),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20)),
    })
    BannerGradient.Rotation = 105
    BannerGradient.Parent = Banner
    table.insert(mainColorElements, {BannerGradient, "__gradient_main"})

    --// Logo circulaire avec la lettre N
    local LogoCircle = Instance.new("Frame")
    LogoCircle.Size = UDim2.new(0, 56, 0, 56)
    LogoCircle.Position = UDim2.new(0, 18, 0, 18)
    LogoCircle.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    LogoCircle.BorderSizePixel = 0
    LogoCircle.Parent = Banner

    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(1, 0)
    LogoCorner.Parent = LogoCircle

    local LogoStroke = Instance.new("UIStroke")
    LogoStroke.Color = currentTheme.Main
    LogoStroke.Thickness = 2
    LogoStroke.Parent = LogoCircle
    table.insert(mainColorElements, {LogoStroke, "Color"})

    local LogoText = Instance.new("TextLabel")
    LogoText.Size = UDim2.new(1, 0, 1, 0)
    LogoText.BackgroundTransparency = 1
    LogoText.Text = "N"
    LogoText.TextColor3 = currentTheme.Main
    LogoText.Font = Enum.Font.GothamBold
    LogoText.TextSize = 28
    LogoText.Parent = LogoCircle
    table.insert(mainColorElements, {LogoText, "TextColor3"})

    --// Titre + sous-titre dans la bannière
    local BannerTitle = Instance.new("TextLabel")
    BannerTitle.Size = UDim2.new(1, -90, 0, 26)
    BannerTitle.Position = UDim2.new(0, 84, 0, 24)
    BannerTitle.BackgroundTransparency = 1
    BannerTitle.Text = "Nameless Enhancement"
    BannerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    BannerTitle.Font = Enum.Font.GothamBold
    BannerTitle.TextSize = 18
    BannerTitle.TextXAlignment = Enum.TextXAlignment.Left
    BannerTitle.Parent = Banner

    local BannerSubtitle = Instance.new("TextLabel")
    BannerSubtitle.Size = UDim2.new(1, -90, 0, 20)
    BannerSubtitle.Position = UDim2.new(0, 84, 0, 50)
    BannerSubtitle.BackgroundTransparency = 1
    BannerSubtitle.Text = "Interface personnalisée"
    BannerSubtitle.TextColor3 = Color3.fromRGB(220, 220, 220)
    BannerSubtitle.Font = FONT
    BannerSubtitle.TextSize = 13
    BannerSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    BannerSubtitle.Parent = Banner

    --// Badge "Créé par"
    local CreditBadge = Instance.new("Frame")
    CreditBadge.Size = UDim2.new(0, 150, 0, 24)
    CreditBadge.Position = UDim2.new(0, 84, 0, 76)
    CreditBadge.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    CreditBadge.BackgroundTransparency = 0.4
    CreditBadge.BorderSizePixel = 0
    CreditBadge.Parent = Banner

    local CreditCorner = Instance.new("UICorner")
    CreditCorner.CornerRadius = UDim.new(1, 0)
    CreditCorner.Parent = CreditBadge

    local CreditText = Instance.new("TextLabel")
    CreditText.Size = UDim2.new(1, -16, 1, 0)
    CreditText.Position = UDim2.new(0, 8, 0, 0)
    CreditText.BackgroundTransparency = 1
    CreditText.Text = "Créé par Gaspard"
    CreditText.TextColor3 = Color3.fromRGB(255, 255, 255)
    CreditText.Font = Enum.Font.GothamMedium
    CreditText.TextSize = 12
    CreditText.TextXAlignment = Enum.TextXAlignment.Left
    CreditText.Parent = CreditBadge

    --// Carte de description
    local DescCard = Instance.new("Frame")
    DescCard.Size = UDim2.new(1, -20, 0, 90)
    DescCard.Position = UDim2.new(0, 10, 0, 142)
    DescCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DescCard.BackgroundTransparency = 0.95
    DescCard.BorderSizePixel = 0
    DescCard.Parent = HomePage

    local DescCorner = Instance.new("UICorner")
    DescCorner.CornerRadius = UDim.new(0, 6)
    DescCorner.Parent = DescCard

    local DescText = Instance.new("TextLabel")
    DescText.Size = UDim2.new(1, -20, 1, -16)
    DescText.Position = UDim2.new(0, 10, 0, 8)
    DescText.BackgroundTransparency = 1
    DescText.Text = "Bienvenue sur Nameless Enhancement. Explore les catégories à gauche pour accéder aux réglages : Home, Visuals, Combat, Movement, Themes et Config. Maintiens Shift droit pour réduire la fenêtre."
    DescText.TextColor3 = Color3.fromRGB(210, 210, 210)
    DescText.Font = FONT
    DescText.TextSize = 13
    DescText.TextWrapped = true
    DescText.TextXAlignment = Enum.TextXAlignment.Left
    DescText.TextYAlignment = Enum.TextYAlignment.Top
    DescText.Parent = DescCard

    --// Ligne de statistiques (cartes)
    local function createStatCard(order, label)
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(0.5, -15, 0, 60)
        Card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Card.BackgroundTransparency = 0.95
        Card.BorderSizePixel = 0
        Card.LayoutOrder = order
        Card.Parent = HomePage

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Card

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(1, -16, 0, 24)
        ValueLabel.Position = UDim2.new(0, 8, 0, 6)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = "--"
        ValueLabel.TextColor3 = currentTheme.Main
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.TextSize = 18
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Left
        ValueLabel.Parent = Card
        table.insert(mainColorElements, {ValueLabel, "TextColor3"})

        local CaptionLabel = Instance.new("TextLabel")
        CaptionLabel.Size = UDim2.new(1, -16, 0, 18)
        CaptionLabel.Position = UDim2.new(0, 8, 0, 32)
        CaptionLabel.BackgroundTransparency = 1
        CaptionLabel.Text = label
        CaptionLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        CaptionLabel.Font = FONT
        CaptionLabel.TextSize = 12
        CaptionLabel.TextXAlignment = Enum.TextXAlignment.Left
        CaptionLabel.Parent = Card

        return ValueLabel
    end

    local FpsCard = Instance.new("Frame")
    FpsCard.Size = UDim2.new(0.5, -15, 0, 60)
    FpsCard.Position = UDim2.new(0, 10, 0, 242)
    FpsCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FpsCard.BackgroundTransparency = 0.95
    FpsCard.BorderSizePixel = 0
    FpsCard.Parent = HomePage
    local FpsCorner = Instance.new("UICorner")
    FpsCorner.CornerRadius = UDim.new(0, 6)
    FpsCorner.Parent = FpsCard
    local FpsValue = Instance.new("TextLabel")
    FpsValue.Size = UDim2.new(1, -16, 0, 24)
    FpsValue.Position = UDim2.new(0, 8, 0, 6)
    FpsValue.BackgroundTransparency = 1
    FpsValue.Text = "--"
    FpsValue.TextColor3 = currentTheme.Main
    FpsValue.Font = Enum.Font.GothamBold
    FpsValue.TextSize = 18
    FpsValue.TextXAlignment = Enum.TextXAlignment.Left
    FpsValue.Parent = FpsCard
    table.insert(mainColorElements, {FpsValue, "TextColor3"})
    local FpsCaption = Instance.new("TextLabel")
    FpsCaption.Size = UDim2.new(1, -16, 0, 18)
    FpsCaption.Position = UDim2.new(0, 8, 0, 32)
    FpsCaption.BackgroundTransparency = 1
    FpsCaption.Text = "FPS"
    FpsCaption.TextColor3 = Color3.fromRGB(180, 180, 180)
    FpsCaption.Font = FONT
    FpsCaption.TextSize = 12
    FpsCaption.TextXAlignment = Enum.TextXAlignment.Left
    FpsCaption.Parent = FpsCard

    local PlayerCard = Instance.new("Frame")
    PlayerCard.Size = UDim2.new(0.5, -15, 0, 60)
    PlayerCard.Position = UDim2.new(0.5, 5, 0, 242)
    PlayerCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PlayerCard.BackgroundTransparency = 0.95
    PlayerCard.BorderSizePixel = 0
    PlayerCard.Parent = HomePage
    local PlayerCorner = Instance.new("UICorner")
    PlayerCorner.CornerRadius = UDim.new(0, 6)
    PlayerCorner.Parent = PlayerCard
    local PlayerValue = Instance.new("TextLabel")
    PlayerValue.Size = UDim2.new(1, -16, 0, 24)
    PlayerValue.Position = UDim2.new(0, 8, 0, 6)
    PlayerValue.BackgroundTransparency = 1
    PlayerValue.Text = player.Name
    PlayerValue.TextColor3 = currentTheme.Main
    PlayerValue.Font = Enum.Font.GothamBold
    PlayerValue.TextSize = 16
    PlayerValue.TextXAlignment = Enum.TextXAlignment.Left
    PlayerValue.TextTruncate = Enum.TextTruncate.AtEnd
    PlayerValue.Parent = PlayerCard
    table.insert(mainColorElements, {PlayerValue, "TextColor3"})
    local PlayerCaption = Instance.new("TextLabel")
    PlayerCaption.Size = UDim2.new(1, -16, 0, 18)
    PlayerCaption.Position = UDim2.new(0, 8, 0, 32)
    PlayerCaption.BackgroundTransparency = 1
    PlayerCaption.Text = "Joueur"
    PlayerCaption.TextColor3 = Color3.fromRGB(180, 180, 180)
    PlayerCaption.Font = FONT
    PlayerCaption.TextSize = 12
    PlayerCaption.TextXAlignment = Enum.TextXAlignment.Left
    PlayerCaption.Parent = PlayerCard

    --// Ligne du bas : raccourci + version
    local FooterText = Instance.new("TextLabel")
    FooterText.Size = UDim2.new(1, -20, 0, 40)
    FooterText.Position = UDim2.new(0, 10, 0, 312)
    FooterText.BackgroundTransparency = 1
    FooterText.Text = "Astuce : glisse la barre de titre pour déplacer la fenêtre. Maintiens Shift droit pour réduire. v1.0 — Nameless Enhancement"
    FooterText.TextColor3 = Color3.fromRGB(140, 140, 140)
    FooterText.Font = FONT
    FooterText.TextSize = 12
    FooterText.TextWrapped = true
    FooterText.TextXAlignment = Enum.TextXAlignment.Left
    FooterText.Parent = HomePage

    --// FPS en direct
    local frameCount, lastCheck = 0, tick()
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastCheck >= 1 then
            FpsValue.Text = tostring(frameCount)
            frameCount = 0
            lastCheck = now
        end
    end)
end

--// ================== PAGE THEMES ==================
local function applyTheme(theme)
    currentTheme = theme

    MainFrame.BackgroundColor3 = theme.Bg
    ContentArea.BackgroundColor3 = theme.Section

    for _, entry in ipairs(mainColorElements) do
        local instance, prop = entry[1], entry[2]
        if instance and instance.Parent then
            if prop == "__gradient_main" then
                -- Cas spécial : met à jour uniquement le premier point de couleur
                -- du dégradé (celui qui suit la couleur du thème), sans toucher aux autres.
                pcall(function()
                    local keypoints = instance.Color.Keypoints
                    local newKeypoints = {}
                    for i, kp in ipairs(keypoints) do
                        if i == 1 then
                            table.insert(newKeypoints, ColorSequenceKeypoint.new(kp.Time, theme.Main))
                        else
                            table.insert(newKeypoints, kp)
                        end
                    end
                    instance.Color = ColorSequence.new(newKeypoints)
                end)
            else
                instance[prop] = theme.Main
            end
        end
    end

    for _, t in ipairs(toggleRegistry) do
        t.refresh()
    end

    -- Réapplique la couleur du bouton de catégorie actif
    for name, page in pairs(pages) do
        if page.Visible then
            selectCategory(name)
        end
    end
end

do
    local ThemesPage = pages["Themes"]
    createInfoLabel(ThemesPage, 1, "Choisis un thème pour l'interface :", 20)

    for i, theme in ipairs(Themes) do
        local ThemeRow = Instance.new("Frame")
        ThemeRow.Size = UDim2.new(1, -20, 0, 34)
        ThemeRow.BackgroundTransparency = 1
        ThemeRow.LayoutOrder = i + 1
        ThemeRow.Parent = ThemesPage

        local Swatch = Instance.new("Frame")
        Swatch.Size = UDim2.new(0, 20, 0, 20)
        Swatch.Position = UDim2.new(0, 0, 0.5, -10)
        Swatch.BackgroundColor3 = theme.Main
        Swatch.BorderSizePixel = 0
        Swatch.Parent = ThemeRow

        local SwatchCorner = Instance.new("UICorner")
        SwatchCorner.CornerRadius = UDim.new(1, 0)
        SwatchCorner.Parent = Swatch

        local ThemeButton = Instance.new("TextButton")
        ThemeButton.Size = UDim2.new(1, -30, 1, 0)
        ThemeButton.Position = UDim2.new(0, 30, 0, 0)
        ThemeButton.BackgroundTransparency = 1
        ThemeButton.Text = theme.Name
        ThemeButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        ThemeButton.Font = FONT
        ThemeButton.TextSize = 14
        ThemeButton.TextXAlignment = Enum.TextXAlignment.Left
        ThemeButton.Parent = ThemeRow

        ThemeButton.MouseButton1Click:Connect(function()
            applyTheme(theme)
        end)
    end
end

--// ================== PAGE COMBAT (Rage Bot) ==================
do
    local CombatPage = pages["Combat"]
    createInfoLabel(CombatPage, 1, "Options de combat :", 20)

    local rageBotEnabled = false
    local hitProbability = 50
    local rageBotConnection = nil
    local rageBotNotification = nil

    local function showRageBotNotification(text, color)
        -- Supprimer l'ancienne notification
        if rageBotNotification then
            rageBotNotification:Destroy()
            rageBotNotification = nil
        end
        
        -- Créer la nouvelle notification
        rageBotNotification = Instance.new("ScreenGui")
        rageBotNotification.Name = "RageBotNotification"
        rageBotNotification.ResetOnSpawn = false
        rageBotNotification.Parent = playerGui
        
        local notifFrame = Instance.new("Frame")
        notifFrame.Size = UDim2.new(0, 200, 0, 40)
        notifFrame.Position = UDim2.new(0.5, -100, 0, 60)
        notifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        notifFrame.BackgroundTransparency = 0.2
        notifFrame.BorderSizePixel = 0
        notifFrame.Parent = rageBotNotification
        
        local notifCorner = Instance.new("UICorner")
        notifCorner.CornerRadius = UDim.new(0, 6)
        notifCorner.Parent = notifFrame
        
        local notifStroke = Instance.new("UIStroke")
        notifStroke.Color = color or Color3.fromRGB(0, 255, 0)
        notifStroke.Thickness = 2
        notifStroke.Parent = notifFrame
        
        local notifText = Instance.new("TextLabel")
        notifText.Size = UDim2.new(1, 0, 1, 0)
        notifText.BackgroundTransparency = 1
        notifText.Text = text
        notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
        notifText.Font = Enum.Font.GothamBold
        notifText.TextSize = 14
        notifText.TextXAlignment = Enum.TextXAlignment.Center
        notifText.TextYAlignment = Enum.TextYAlignment.Center
        notifText.Parent = notifFrame
        
        -- Supprimer après 2 secondes
        task.delay(2, function()
            if rageBotNotification then
                rageBotNotification:Destroy()
                rageBotNotification = nil
            end
        end)
    end

    local function toggleRageBot(enabled)
        rageBotEnabled = enabled
        
        if rageBotConnection then
            rageBotConnection:Disconnect()
            rageBotConnection = nil
        end
        
        -- Supprimer la notification existante
        if rageBotNotification then
            rageBotNotification:Destroy()
            rageBotNotification = nil
        end
        
        if enabled then
            rageBotConnection = RunService.Heartbeat:Connect(function(deltaTime)
                if not rageBotEnabled then return end
                
                local character = player.Character
                if not character then return end
                
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid or humanoid.Health <= 0 then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end
                
                -- Trouver le joueur le plus proche (optimisé)
                local closestPlayer = nil
                local closestDistance = math.huge
                local closestPlayerName = nil
                
                for _, otherPlayer in ipairs(Players:GetPlayers()) do
                    if otherPlayer ~= player then
                        local otherCharacter = otherPlayer.Character
                        if otherCharacter then
                            local otherHumanoid = otherCharacter:FindFirstChildOfClass("Humanoid")
                            if otherHumanoid and otherHumanoid.Health > 0 then
                                local head = otherCharacter:FindFirstChild("Head")
                                if head then
                                    local distance = (head.Position - rootPart.Position).Magnitude
                                    if distance < closestDistance and distance < 100 then
                                        closestDistance = distance
                                        closestPlayer = otherCharacter
                                        closestPlayerName = otherPlayer.Name
                                    end
                                end
                            end
                        end
                    end
                end
                
                if closestPlayer then
                    local head = closestPlayer:FindFirstChild("Head")
                    if head then
                        -- Vérifier la probabilité de hit
                        if math.random(100) <= hitProbability then
                            -- HIT : Cible touchée
                            showRageBotNotification("HIT: " .. closestPlayerName, Color3.fromRGB(0, 255, 0))
                            
                            -- Viser vers la tête
                            local targetPosition = head.Position
                            local currentCFrame = workspace.CurrentCamera.CFrame
                            local lookAt = CFrame.lookAt(currentCFrame.Position, targetPosition)
                            workspace.CurrentCamera.CFrame = currentCFrame:Lerp(lookAt, 0.1)
                        else
                            -- MISS : Cible ratée
                            showRageBotNotification("MISS: " .. closestPlayerName, Color3.fromRGB(255, 0, 0))
                        end
                    end
                else
                    -- Pas de cible détectée
                    showRageBotNotification("Aucune cible détectée", Color3.fromRGB(255, 255, 0))
                end
            end)
        end
    end

    createToggle(CombatPage, 2, "Combat", "Rage Bot", function(enabled)
        toggleRageBot(enabled)
    end)

    createInfoLabel(CombatPage, 3, "Réglages Rage Bot :", 20)

    local sliderFrame, updateSlider = createSlider(CombatPage, 4, "Probabilité de hit (%)", 0, 100, 50, function(value)
        hitProbability = value
    end)

    -- Spin Bot avec mode spirale R15
    local spinBotEnabled = false
    local spiralMode = false
    local spinBotConnection = nil
    local detachedParts = {}
    local savedMotor6Ds = {}

    local function restoreParts()
        for _, partData in ipairs(detachedParts) do
            if partData.part and partData.part.Parent then
                -- Restaurer les propriétés originales
                partData.part.Anchored = false
                partData.part.CanCollide = true
                partData.part.Massless = false
            end
        end
        detachedParts = {}
        
        -- Restaurer les Motor6D
        for _, motorData in ipairs(savedMotor6Ds) do
            if motorData.motor and motorData.part0 and motorData.part1 then
                motorData.motor.Part0 = motorData.part0
                motorData.motor.Part1 = motorData.part1
            end
        end
        savedMotor6Ds = {}
    end

    local function toggleSpinBot(enabled)
        spinBotEnabled = enabled
        
        if spinBotConnection then
            spinBotConnection:Disconnect()
            spinBotConnection = nil
        end
        
        restoreParts()
        
        if enabled then
            spinBotConnection = RunService.Heartbeat:Connect(function(deltaTime)
                if not spinBotEnabled then return end
                
                local character = player.Character
                if not character then return end
                
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid or humanoid.Health <= 0 then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end
                
                -- Rotation du corps (optimisée avec deltaTime)
                rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(deltaTime * 900), 0)
                
                -- Mode spirale : détacher les membres et les faire tourner
                if spiralMode then
                    local partsToDetach = {
                        "LeftArm", "RightArm", "LeftLeg", "RightLeg", "Head", "UpperTorso", "LowerTorso"
                    }
                    
                    local time = tick()
                    
                    for i, partName in ipairs(partsToDetach) do
                        local part = character:FindFirstChild(partName)
                        if part then
                            -- Vérifier si déjà détaché
                            local alreadyDetached = false
                            for _, data in ipairs(detachedParts) do
                                if data.part == part then
                                    alreadyDetached = true
                                    break
                                end
                            end
                            
                            if not alreadyDetached then
                                -- Trouver et sauvegarder le Motor6D
                                for _, child in ipairs(part:GetChildren()) do
                                    if child:IsA("Motor6D") then
                                        table.insert(savedMotor6Ds, {
                                            motor = child,
                                            part0 = child.Part0,
                                            part1 = child.Part1
                                        })
                                        -- Détacher le Motor6D
                                        child.Part0 = nil
                                        child.Part1 = nil
                                    end
                                end
                                
                                -- Détacher la partie
                                part.Anchored = true
                                part.CanCollide = false
                                part.Massless = true
                                table.insert(detachedParts, {part = part, originalParent = part.Parent})
                            end
                            
                            -- Faire tourner horizontalement autour du root (plan XZ uniquement)
                            local angle = time * 2 + (i * 0.5) -- Décalage d'angle pour chaque membre
                            local radius = 2.5 -- Rayon constant
                            local height = 0 -- Altitude constante (pas de propulsion)
                            
                            local offset = Vector3.new(
                                math.cos(angle) * radius,
                                height,
                                math.sin(angle) * radius
                            )
                            
                            -- Positionner le membre horizontalement avec une rotation légère
                            part.CFrame = rootPart.CFrame * CFrame.new(offset) * CFrame.Angles(
                                0, -- Pas de rotation X (pas de bascule)
                                math.rad(angle * 50), -- Rotation Y pour suivre le mouvement
                                0 -- Pas de rotation Z
                            )
                        end
                    end
                end
            end)
        end
    end

    createToggle(CombatPage, 5, "Combat", "Spin Bot", function(enabled)
        toggleSpinBot(enabled)
    end)

    -- Shotgun Rage
    local shotgunRageEnabled = false
    local shotgunRageConnection = nil
    local orbitAngle = 0

    local function toggleShotgunRage(enabled)
        shotgunRageEnabled = enabled

        if shotgunRageConnection then
            shotgunRageConnection:Disconnect()
            shotgunRageConnection = nil
        end

        if enabled then
            shotgunRageConnection = RunService.Heartbeat:Connect(function(deltaTime)
                if not shotgunRageEnabled then return end

                local character = player.Character
                if not character then return end

                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid or humanoid.Health <= 0 then return end

                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end

                -- Trouver le joueur le plus proche (vivant uniquement)
                local closestPlayer = nil
                local closestDistance = math.huge

                for _, otherPlayer in ipairs(Players:GetPlayers()) do
                    if otherPlayer ~= player then
                        local otherCharacter = otherPlayer.Character
                        if otherCharacter then
                            local otherHRP = otherCharacter:FindFirstChild("HumanoidRootPart")
                            local otherHumanoid = otherCharacter:FindFirstChildOfClass("Humanoid")
                            if otherHRP and otherHumanoid and otherHumanoid.Health > 0 then
                                local distance = (otherHRP.Position - rootPart.Position).Magnitude
                                if distance < closestDistance and distance < 100 then
                                    closestDistance = distance
                                    closestPlayer = otherPlayer
                                end
                            end
                        end
                    end
                end

                if closestPlayer then
                    local targetCharacter = closestPlayer.Character
                    if not targetCharacter then return end

                    local targetHRP = targetCharacter:FindFirstChild("HumanoidRootPart")
                    if not targetHRP then return end

                    local targetHead = targetCharacter:FindFirstChild("Head")
                    if not targetHead then return end

                    -- Orbiter autour du joueur cible dans le ciel
                    orbitAngle = orbitAngle + (deltaTime * 36000) -- 10000% de rotation (100x 360 degrés/seconde)
                    local orbitRadius = 5
                    local orbitHeight = 8
                    local x = math.cos(math.rad(orbitAngle)) * orbitRadius
                    local z = math.sin(math.rad(orbitAngle)) * orbitRadius

                    local orbitPosition = targetHRP.Position + Vector3.new(x, orbitHeight, z)
                    rootPart.CFrame = CFrame.new(orbitPosition, targetHRP.Position)

                    -- Lock caméra sur la tête de la cible avec position fixe (pas de mouvement avec la rotation)
                    local camera = workspace.CurrentCamera
                    if camera then
                        -- Position fixe proche de la cible, face à elle
                        local fixedCameraPos = targetHRP.Position + Vector3.new(0, 2, 4)
                        camera.CFrame = CFrame.new(fixedCameraPos, targetHead.Position)
                    end
                end
            end)
        end
    end

    createToggle(CombatPage, 6, "Combat", "Shotgun Rage", function(enabled)
        toggleShotgunRage(enabled)
    end)

    createToggle(CombatPage, 7, "Combat", "Mode Spirale (R15)", function(enabled)
        spiralMode = enabled
        -- Si spin bot est activé, redémarrer pour appliquer le mode
        if spinBotEnabled then
            toggleSpinBot(false)
            task.wait(0.1)
            toggleSpinBot(true)
        end
    end)

    -- Nouveau : Trail laser vers le joueur le plus proche (clic gauche) — effet purement visuel, client-only
    createInfoLabel(CombatPage, 8, "Trail laser (effet visuel, clic gauche vers le joueur le plus proche) :", 30)

    local laserTrailEnabled = false
    local laserColor = Color3.fromRGB(0, 255, 255)
    local laserInputConn = nil

    local function findNearestPlayer()
        local character = player.Character
        if not character then return nil end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return nil end

        local nearestPlayer = nil
        local nearestDistance = math.huge

        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player then
                local otherCharacter = otherPlayer.Character
                if otherCharacter then
                    local otherRoot = otherCharacter:FindFirstChild("HumanoidRootPart")
                    if otherRoot then
                        local distance = (otherRoot.Position - rootPart.Position).Magnitude
                        if distance < nearestDistance then
                            nearestDistance = distance
                            nearestPlayer = otherPlayer
                        end
                    end
                end
            end
        end

        return nearestPlayer
    end

    local function fireLaserTrail()
        local character = player.Character
        if not character then return end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        local target = findNearestPlayer()
        if not target then return end
        local targetCharacter = target.Character
        if not targetCharacter then return end
        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end

        local originAttachment = Instance.new("Attachment")
        originAttachment.Name = "LaserOrigin"
        originAttachment.Parent = rootPart

        local targetAttachment = Instance.new("Attachment")
        targetAttachment.Name = "LaserTarget"
        targetAttachment.Parent = targetRoot

        local beam = Instance.new("Beam")
        beam.Attachment0 = originAttachment
        beam.Attachment1 = targetAttachment
        beam.Color = ColorSequence.new(laserColor)
        beam.Width0 = 0.4
        beam.Width1 = 0.15
        beam.FaceCamera = true
        beam.Brightness = 6
        beam.LightEmission = 1
        beam.LightInfluence = 0
        beam.Transparency = NumberSequence.new(0)
        beam.Parent = originAttachment

        -- Fondu rapide puis nettoyage automatique
        task.spawn(function()
            local steps = 10
            for i = 1, steps do
                task.wait(0.03)
                beam.Transparency = NumberSequence.new(i / steps)
            end
            beam:Destroy()
            originAttachment:Destroy()
            targetAttachment:Destroy()
        end)
    end

    local function toggleLaserTrail(enabled)
        laserTrailEnabled = enabled

        if laserInputConn then
            laserInputConn:Disconnect()
            laserInputConn = nil
        end

        if enabled then
            laserInputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end -- ignore les clics sur l'UI (boutons du menu, etc.)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    fireLaserTrail()
                end
            end)
        end
    end

    createToggle(CombatPage, 9, "Combat", "Trail laser (clic gauche)", function(enabled)
        toggleLaserTrail(enabled)
    end)

    createInfoLabel(CombatPage, 10, "Couleur du laser :", 20)

    local laserColorOptions = {
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(255, 0, 255),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(255, 165, 0),
        Color3.fromRGB(138, 43, 226),
    }

    local _, selectLaserColor = createColorPalette(CombatPage, 11, "Couleur", laserColorOptions, laserColor, function(color)
        laserColor = color
    end)
    registerSetting("laserColor",
        function() return colorToTable(laserColor) end,
        function(v) selectLaserColor(tableToColor(v)) end
    )
end

--// ================== PAGE VISUALS (Custom Skin + Gradient + ESP) ==================
do
    local VisualsPage = pages["Visuals"]
    createInfoLabel(VisualsPage, 1, "Effets visuels cosmétiques :", 20)

    createToggle(VisualsPage, 2, "Visuals", "Custom Skin (Ailes & Auréole)", function(enabled)
        toggleCustomSkin(enabled)
    end)

    -- Nouveau : Cercle dégradé
    local gradientEnabled = false
    local gradientColor1 = Color3.fromRGB(255, 0, 0)
    local gradientColor2 = Color3.fromRGB(0, 0, 255)
    local gradientSize = 200
    local gradientGui = nil
    local gradientRotationConnection = nil
    local gradientFollowConnection = nil
    local GRADIENT_FOLLOW_RADIUS = 140 -- rayon en pixels autour du curseur pour "accrocher" un joueur

    -- Renvoie la position écran (Vector2) que le cercle doit suivre :
    -- le joueur le plus proche du curseur s'il y en a un dans le rayon, sinon le curseur lui-même.
    local function getGradientFollowTarget()
        local mouseLoc = UserInputService:GetMouseLocation()
        local camera = workspace.CurrentCamera
        if not camera then
            return mouseLoc
        end

        local closestPos, closestDist = nil, GRADIENT_FOLLOW_RADIUS

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                if hrp and humanoid and humanoid.Health > 0 then
                    local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local flatPos = Vector2.new(screenPos.X, screenPos.Y)
                        local dist = (flatPos - mouseLoc).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestPos = flatPos
                        end
                    end
                end
            end
        end

        return closestPos or mouseLoc
    end

    local function toggleGradient(enabled)
        gradientEnabled = enabled
        
        if gradientRotationConnection then
            gradientRotationConnection:Disconnect()
            gradientRotationConnection = nil
        end

        if gradientFollowConnection then
            gradientFollowConnection:Disconnect()
            gradientFollowConnection = nil
        end
        
        if gradientGui then
            gradientGui:Destroy()
            gradientGui = nil
        end
        
        if enabled then
            gradientGui = Instance.new("ScreenGui")
            gradientGui.Name = "GradientGui"
            gradientGui.ResetOnSpawn = false
            gradientGui.IgnoreGuiInset = true
            gradientGui.Parent = playerGui
            
            local gradientFrame = Instance.new("Frame")
            gradientFrame.Name = "GradientCircle"
            gradientFrame.AnchorPoint = Vector2.new(0.5, 0.5)
            gradientFrame.Size = UDim2.new(0, gradientSize, 0, gradientSize)
            gradientFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            gradientFrame.BackgroundColor3 = gradientColor1
            gradientFrame.BackgroundTransparency = 0.4
            gradientFrame.BorderSizePixel = 0
            gradientFrame.Parent = gradientGui
            
            local gradientCorner = Instance.new("UICorner")
            gradientCorner.CornerRadius = UDim.new(1, 0)
            gradientCorner.Parent = gradientFrame
            
            local gradient = Instance.new("UIGradient")
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, gradientColor1),
                ColorSequenceKeypoint.new(1, gradientColor2)
            })
            gradient.Rotation = 45
            gradient.Parent = gradientFrame
            
            local gradientStroke = Instance.new("UIStroke")
            gradientStroke.Color = gradientColor2
            gradientStroke.Thickness = 2
            gradientStroke.Transparency = 0.4
            gradientStroke.Parent = gradientFrame

            -- Texte "Nameless.Enhancement" sous le cercle
            local gradientText = Instance.new("TextLabel")
            gradientText.Name = "GradientText"
            gradientText.Size = UDim2.new(1, 0, 0, 20)
            gradientText.Position = UDim2.new(0, 0, 1, 5)
            gradientText.BackgroundTransparency = 1
            gradientText.Text = "Nameless.Enhancement"
            gradientText.TextColor3 = Color3.fromRGB(255, 255, 255)
            gradientText.Font = Enum.Font.GothamBold
            gradientText.TextSize = 14
            gradientText.TextXAlignment = Enum.TextXAlignment.Center
            gradientText.Parent = gradientFrame

            -- Rotation automatique du dégradé (optimisée avec Heartbeat)
            gradientRotationConnection = RunService.Heartbeat:Connect(function(deltaTime)
                if gradientGui and gradientEnabled then
                    local gradientFrame = gradientGui:FindFirstChild("GradientCircle")
                    if gradientFrame then
                        local gradient = gradientFrame:FindFirstChildOfClass("UIGradient")
                        if gradient then
                            gradient.Rotation = (gradient.Rotation + deltaTime * 60) % 360
                        end
                    end
                end
            end)

            -- Suivi de position : accroche le joueur le plus proche du curseur s'il y en a un
            -- à moins de GRADIENT_FOLLOW_RADIUS pixels, sinon suit simplement le curseur.
            gradientFollowConnection = RunService.RenderStepped:Connect(function()
                if gradientGui and gradientEnabled then
                    local gradientFrame = gradientGui:FindFirstChild("GradientCircle")
                    if gradientFrame then
                        local target = getGradientFollowTarget()
                        gradientFrame.Position = UDim2.new(0, target.X, 0, target.Y)
                    end
                end
            end)
        end
    end

    local function updateGradientColors()
        if gradientGui and gradientEnabled then
            local gradientFrame = gradientGui:FindFirstChild("GradientCircle")
            if gradientFrame then
                -- Le fond était figé sur la couleur de création ; il doit suivre Couleur 1
                gradientFrame.BackgroundColor3 = gradientColor1

                local gradient = gradientFrame:FindFirstChildOfClass("UIGradient")
                if gradient then
                    gradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, gradientColor1),
                        ColorSequenceKeypoint.new(1, gradientColor2)
                    })
                end
                local stroke = gradientFrame:FindFirstChildOfClass("UIStroke")
                if stroke then
                    stroke.Color = gradientColor2
                end
            end
        end
    end

    local function updateGradientSize()
        if gradientGui and gradientEnabled then
            local gradientFrame = gradientGui:FindFirstChild("GradientCircle")
            if gradientFrame then
                gradientFrame.Size = UDim2.new(0, gradientSize, 0, gradientSize)
                -- La position est gérée en continu par gradientFollowConnection (curseur / joueur proche)
            end
        end
    end

    createToggle(VisualsPage, 3, "Visuals", "Cercle dégradé", function(enabled)
        toggleGradient(enabled)
    end)

    createInfoLabel(VisualsPage, 4, "Couleurs du dégradé :", 20)

    local colorOptions = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(255, 0, 255),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(0, 0, 0),
    }

    local _, selectGradientColor1 = createColorPalette(VisualsPage, 5, "Couleur 1", colorOptions, gradientColor1, function(color)
        gradientColor1 = color
        updateGradientColors()
    end)

    local _, selectGradientColor2 = createColorPalette(VisualsPage, 6, "Couleur 2", colorOptions, gradientColor2, function(color)
        gradientColor2 = color
        updateGradientColors()
    end)

    createInfoLabel(VisualsPage, 7, "Taille du cercle :", 20)

    local sizeSlider, updateSize = createSlider(VisualsPage, 8, "Taille (px)", 50, 500, 200, function(value)
        gradientSize = value
        updateGradientSize()
    end)

    registerSetting("gradientColor1",
        function() return colorToTable(gradientColor1) end,
        function(v) selectGradientColor1(tableToColor(v)) end
    )
    registerSetting("gradientColor2",
        function() return colorToTable(gradientColor2) end,
        function(v) selectGradientColor2(tableToColor(v)) end
    )
    registerSetting("gradientSize",
        function() return gradientSize end,
        function(v) updateSize(v) end
    )

    -- Nouveau : ESP
    local espEnabled = false
    local espColor = Color3.fromRGB(0, 255, 255)
    local espConnection = nil
    local espHighlights = {}
    local espLights = {}

    local function toggleESP(enabled)
        espEnabled = enabled
        
        if espConnection then
            espConnection:Disconnect()
            espConnection = nil
        end
        
        -- Nettoyer les highlights et lumières existants
        for _, highlight in ipairs(espHighlights) do
            if highlight.Parent then
                highlight:Destroy()
            end
        end
        espHighlights = {}
        
        for _, light in ipairs(espLights) do
            if light.Parent then
                light:Destroy()
            end
        end
        espLights = {}
        
        if enabled then
            espConnection = RunService.Heartbeat:Connect(function(deltaTime)
                if not espEnabled then return end
                
                for _, otherPlayer in ipairs(Players:GetPlayers()) do
                    if otherPlayer ~= player then
                        local character = otherPlayer.Character
                        if character then
                            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                            
                            -- Créer ou mettre à jour le highlight
                            local highlight = character:FindFirstChild("NamelessESP_Highlight")
                            if not highlight then
                                highlight = Instance.new("Highlight")
                                highlight.Name = "NamelessESP_Highlight"
                                highlight.FillColor = espColor
                                highlight.OutlineColor = espColor
                                highlight.FillTransparency = 0.2
                                highlight.OutlineTransparency = 0
                                highlight.Parent = character
                                table.insert(espHighlights, highlight)
                            else
                                -- Mettre à jour la couleur si elle a changé
                                highlight.FillColor = espColor
                                highlight.OutlineColor = espColor
                            end
                            
                            -- Ajouter une lumière néon super lumineuse
                            if humanoidRootPart then
                                local neonLight = humanoidRootPart:FindFirstChild("NamelessESP_Light")
                                if not neonLight then
                                    neonLight = Instance.new("PointLight")
                                    neonLight.Name = "NamelessESP_Light"
                                    neonLight.Color = espColor
                                    neonLight.Brightness = 3
                                    neonLight.Range = 15
                                    neonLight.Parent = humanoidRootPart
                                    table.insert(espLights, neonLight)
                                else
                                    -- Mettre à jour la couleur si elle a changé
                                    neonLight.Color = espColor
                                end
                            end
                        end
                    end
                end
            end)
        end
    end

    createToggle(VisualsPage, 9, "Visuals", "ESP (Neon Glow)", function(enabled)
        toggleESP(enabled)
    end)

    createInfoLabel(VisualsPage, 10, "Couleur ESP :", 20)

    local espColorOptions = {
        Color3.fromRGB(0, 255, 255),    -- Cyan
        Color3.fromRGB(255, 0, 255),    -- Magenta
        Color3.fromRGB(255, 255, 0),    -- Jaune
        Color3.fromRGB(0, 255, 0),      -- Vert
        Color3.fromRGB(255, 100, 100),  -- Rouge clair
        Color3.fromRGB(255, 255, 255),  -- Blanc
        Color3.fromRGB(255, 165, 0),    -- Orange
        Color3.fromRGB(138, 43, 226),    -- Violet
    }

    createColorPalette(VisualsPage, 11, "Couleur", espColorOptions, espColor, function(color)
        espColor = color
        -- Mettre à jour les ESP existants si activés
        if espEnabled then
            for _, highlight in ipairs(espHighlights) do
                if highlight.Parent then
                    highlight.FillColor = espColor
                    highlight.OutlineColor = espColor
                end
            end
            for _, light in ipairs(espLights) do
                if light.Parent then
                    light.Color = espColor
                end
            end
        end
    end)

    -- Nouveau : Crosshair rotatif qui suit le curseur
    local crosshairEnabled = false
    local crosshairColor = Color3.fromRGB(255, 0, 0)
    local crosshairGui = nil
    local crosshairConnection = nil
    local crosshairRotation = 0
    local CROSSHAIR_SPIN_SPEED = 900 -- degrés par seconde

    local function toggleCrosshair(enabled)
        crosshairEnabled = enabled

        if crosshairConnection then
            crosshairConnection:Disconnect()
            crosshairConnection = nil
        end

        if crosshairGui then
            crosshairGui:Destroy()
            crosshairGui = nil
        end

        if enabled then
            crosshairGui = Instance.new("ScreenGui")
            crosshairGui.Name = "NamelessCrosshairGui"
            crosshairGui.ResetOnSpawn = false
            crosshairGui.IgnoreGuiInset = true
            crosshairGui.DisplayOrder = 999
            crosshairGui.Parent = playerGui

            -- Wrapper statique (ne tourne pas) : suit juste le curseur, contient la croix + le texte
            local CrosshairWrapper = Instance.new("Frame")
            CrosshairWrapper.Name = "CrosshairWrapper"
            CrosshairWrapper.Size = UDim2.new(0, 36, 0, 36)
            CrosshairWrapper.AnchorPoint = Vector2.new(0.5, 0.5)
            CrosshairWrapper.BackgroundTransparency = 1
            CrosshairWrapper.Parent = crosshairGui

            -- Container qui tourne (uniquement la croix)
            local CrosshairContainer = Instance.new("Frame")
            CrosshairContainer.Name = "CrosshairContainer"
            CrosshairContainer.Size = UDim2.new(1, 0, 1, 0)
            CrosshairContainer.BackgroundTransparency = 1
            CrosshairContainer.Parent = CrosshairWrapper

            -- Barres coupées en 2 de chaque côté (haut/bas/gauche/droite) pour laisser un espace au centre
            local BarTop = Instance.new("Frame")
            BarTop.Name = "BarTop"
            BarTop.Size = UDim2.new(0, 1, 0, 12)
            BarTop.Position = UDim2.new(0.5, -0.5, 0, 0)
            BarTop.BackgroundColor3 = crosshairColor
            BarTop.BorderSizePixel = 0
            BarTop.Parent = CrosshairContainer

            local BarBottom = Instance.new("Frame")
            BarBottom.Name = "BarBottom"
            BarBottom.Size = UDim2.new(0, 1, 0, 12)
            BarBottom.Position = UDim2.new(0.5, -0.5, 1, -12)
            BarBottom.BackgroundColor3 = crosshairColor
            BarBottom.BorderSizePixel = 0
            BarBottom.Parent = CrosshairContainer

            local BarLeft = Instance.new("Frame")
            BarLeft.Name = "BarLeft"
            BarLeft.Size = UDim2.new(0, 12, 0, 1)
            BarLeft.Position = UDim2.new(0, 0, 0.5, -0.5)
            BarLeft.BackgroundColor3 = crosshairColor
            BarLeft.BorderSizePixel = 0
            BarLeft.Parent = CrosshairContainer

            local BarRight = Instance.new("Frame")
            BarRight.Name = "BarRight"
            BarRight.Size = UDim2.new(0, 12, 0, 1)
            BarRight.Position = UDim2.new(1, -12, 0.5, -0.5)
            BarRight.BackgroundColor3 = crosshairColor
            BarRight.BorderSizePixel = 0
            BarRight.Parent = CrosshairContainer

            -- Nom du hub affiché en petit sous la croix (ne tourne pas, reste lisible)
            local HubLabel = Instance.new("TextLabel")
            HubLabel.Name = "HubLabel"
            HubLabel.Size = UDim2.new(0, 160, 0, 16)
            HubLabel.Position = UDim2.new(0.5, -80, 1, 4)
            HubLabel.BackgroundTransparency = 1
            HubLabel.Text = "Nameless.Hub"
            HubLabel.TextColor3 = crosshairColor
            HubLabel.Font = Enum.Font.Gotham
            HubLabel.TextSize = 11
            HubLabel.TextTransparency = 0.15
            HubLabel.TextXAlignment = Enum.TextXAlignment.Center
            HubLabel.Parent = CrosshairWrapper

            crosshairConnection = RunService.RenderStepped:Connect(function(deltaTime)
                if not (crosshairGui and crosshairEnabled) then return end

                local mouseLoc = UserInputService:GetMouseLocation()
                CrosshairWrapper.Position = UDim2.new(0, mouseLoc.X, 0, mouseLoc.Y)

                crosshairRotation = (crosshairRotation + deltaTime * CROSSHAIR_SPIN_SPEED) % 360
                CrosshairContainer.Rotation = crosshairRotation
            end)
        end
    end

    createToggle(VisualsPage, 12, "Visuals", "Crosshair rotatif (suit le curseur)", function(enabled)
        toggleCrosshair(enabled)
    end)

    createInfoLabel(VisualsPage, 13, "Couleur du crosshair :", 20)

    local crosshairColorOptions = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(255, 0, 255),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(255, 165, 0),
        Color3.fromRGB(138, 43, 226),
    }

    local _, selectCrosshairColor = createColorPalette(VisualsPage, 14, "Couleur", crosshairColorOptions, crosshairColor, function(color)
        crosshairColor = color
        if crosshairGui then
            local wrapper = crosshairGui:FindFirstChild("CrosshairWrapper")
            if wrapper then
                local container = wrapper:FindFirstChild("CrosshairContainer")
                if container then
                    for _, barName in ipairs({"BarTop", "BarBottom", "BarLeft", "BarRight"}) do
                        local bar = container:FindFirstChild(barName)
                        if bar then bar.BackgroundColor3 = color end
                    end
                end
                local hubLabel = wrapper:FindFirstChild("HubLabel")
                if hubLabel then hubLabel.TextColor3 = color end
            end
        end
    end)

    registerSetting("crosshairColor",
        function() return colorToTable(crosshairColor) end,
        function(v) selectCrosshairColor(tableToColor(v)) end
    )

    -- Nouveau : Hide Nickname (remplace les noms au-dessus de la tête par /nameless.gg)
    local HIDE_NICKNAME_TEXT = "/nameless.gg"
    local hideNicknameEnabled = false
    local hideNicknameConnections = {} -- [player] = {added = conn}

    local function applyHiddenName(character)
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.DisplayName = HIDE_NICKNAME_TEXT
        end
    end

    local function restoreName(plr, character)
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.DisplayName = plr.DisplayName
        end
    end

    local function hookPlayer(plr)
        if hideNicknameConnections[plr] then return end

        local addedConn = plr.CharacterAdded:Connect(function(character)
            if hideNicknameEnabled then
                -- Attendre que le Humanoid existe avant de renommer
                local humanoid = character:WaitForChild("Humanoid", 5)
                if humanoid and hideNicknameEnabled then
                    humanoid.DisplayName = HIDE_NICKNAME_TEXT
                end
            end
        end)

        hideNicknameConnections[plr] = {added = addedConn}

        if plr.Character then
            applyHiddenName(plr.Character)
        end
    end

    local function unhookPlayer(plr)
        local conns = hideNicknameConnections[plr]
        if conns then
            if conns.added then conns.added:Disconnect() end
            hideNicknameConnections[plr] = nil
        end
        if plr.Character then
            restoreName(plr, plr.Character)
        end
    end

    local playerAddedConn, playerRemovingConn = nil, nil

    local function toggleHideNickname(enabled)
        hideNicknameEnabled = enabled

        if enabled then
            for _, plr in ipairs(Players:GetPlayers()) do
                hookPlayer(plr)
            end

            playerAddedConn = Players.PlayerAdded:Connect(function(plr)
                if hideNicknameEnabled then
                    hookPlayer(plr)
                end
            end)

            playerRemovingConn = Players.PlayerRemoving:Connect(function(plr)
                hideNicknameConnections[plr] = nil
            end)
        else
            if playerAddedConn then playerAddedConn:Disconnect() playerAddedConn = nil end
            if playerRemovingConn then playerRemovingConn:Disconnect() playerRemovingConn = nil end

            for _, plr in ipairs(Players:GetPlayers()) do
                unhookPlayer(plr)
            end
            hideNicknameConnections = {}
        end
    end

    createInfoLabel(VisualsPage, 15, "Masquer les pseudos :", 20)

    createToggle(VisualsPage, 16, "Visuals", "Hide Nickname (/nameless.gg)", function(enabled)
        toggleHideNickname(enabled)
    end)

    --// Mod Spirale : détache les bras et jambes R15 et les fait tourner en orbite horizontale
    -- ordonnée autour de la tête. Le torse, le cou et la racine (HumanoidRootPart) restent
    -- intacts et gérés normalement par l'humanoid : c'est important, car désactiver ces
    -- joints-là cassait l'intégrité du personnage et te faisait mourir (détection anti-triche /
    -- rig invalide côté jeu). Seuls les membres (bras, avant-bras, mains, cuisses, tibias, pieds)
    -- sont détachés, ce qui suffit pour l'effet et ne touche pas au "cœur" du personnage.
    createInfoLabel(VisualsPage, 17, "Mod Spirale (détache bras et jambes R15, orbite autour de ta tête — visible par les autres joueurs, comme une emote) :", 30)

    local bodySpiralEnabled = false
    local bodySpiralConnection = nil
    local bodySpiralAngle = 0
    local bodySpiralRadius = 5
    local bodySpiralSpeed = 90 -- degrés par seconde
    local bodySpiralJointStates = {} -- [Motor6D] = état Enabled d'origine
    local bodySpiralPartStates = {} -- [BasePart] = {CanCollide = bool, Massless = bool}

    -- Uniquement les joints des bras et des jambes : le torse (Waist), le cou (Neck) et la
    -- racine (Root) ne sont JAMAIS touchés pour garder le personnage "vivant" et stable.
    local BODY_SPIRAL_JOINT_NAMES = {
        LeftShoulder = true, RightShoulder = true,
        LeftElbow = true, RightElbow = true,
        LeftWrist = true, RightWrist = true,
        LeftHip = true, RightHip = true,
        LeftKnee = true, RightKnee = true,
        LeftAnkle = true, RightAnkle = true,
    }

    -- Ordre des membres autour de la tête
    local BODY_SPIRAL_PARTS = {
        "RightUpperArm", "RightLowerArm", "RightHand",
        "LeftUpperArm", "LeftLowerArm", "LeftHand",
        "RightUpperLeg", "RightLowerLeg", "RightFoot",
        "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
    }

    local function stopBodySpiral()
        if bodySpiralConnection then
            bodySpiralConnection:Disconnect()
            bodySpiralConnection = nil
        end
        -- Réactive les joints des membres pour que l'humanoid reprenne le contrôle normal
        for motor, wasEnabled in pairs(bodySpiralJointStates) do
            if motor and motor.Parent then
                motor.Enabled = wasEnabled
            end
        end
        bodySpiralJointStates = {}

        -- Restaure CanCollide/Massless d'origine sur les membres, et rend la propriété
        -- réseau automatique au moteur (comme avant l'activation de l'effet)
        for part, original in pairs(bodySpiralPartStates) do
            if part and part.Parent then
                part.CanCollide = original.CanCollide
                part.Massless = original.Massless
                pcall(function()
                    part:SetNetworkOwnershipAuto()
                end)
            end
        end
        bodySpiralPartStates = {}
    end

    local function startBodySpiral()
        local character = player.Character
        if not character then return end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R15 then
            return -- effet uniquement compatible avec un avatar R15
        end

        local head = character:FindFirstChild("Head")
        if not head then return end

        -- Désactive uniquement les joints des bras/jambes (torse, cou, racine intouchés)
        bodySpiralJointStates = {}
        for _, descendant in ipairs(character:GetDescendants()) do
            if descendant:IsA("Motor6D") and BODY_SPIRAL_JOINT_NAMES[descendant.Name] then
                bodySpiralJointStates[descendant] = descendant.Enabled
                descendant.Enabled = false
            end
        end

        -- Récupère les membres existants à faire orbiter (certains avatars peuvent en manquer)
        local orbitingParts = {}
        bodySpiralPartStates = {}
        for _, partName in ipairs(BODY_SPIRAL_PARTS) do
            local part = character:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                table.insert(orbitingParts, part)
                bodySpiralPartStates[part] = {CanCollide = part.CanCollide, Massless = part.Massless}
                -- Évite que les membres poussent/soient poussés par la physique pendant l'orbite
                part.CanCollide = false
                part.Massless = true
                -- Force le client à rester propriétaire réseau du membre : sans ça, une fois le
                -- membre détaché du reste du corps, le serveur peut en reprendre la propriété et
                -- nos changements de CFrame restent alors purement locaux (invisibles pour les
                -- autres joueurs). C'est ce qui rendait l'effet invisible pour eux.
                pcall(function()
                    part:SetNetworkOwner(player)
                end)
            end
        end

        local count = #orbitingParts
        if count == 0 then return end

        bodySpiralAngle = 0

        bodySpiralConnection = RunService.Heartbeat:Connect(function(deltaTime)
            if not bodySpiralEnabled then return end
            if not character.Parent or not head.Parent then
                stopBodySpiral()
                return
            end

            bodySpiralAngle = (bodySpiralAngle + deltaTime * bodySpiralSpeed) % 360

            -- La tête suit son animation normale (Neck intact) : on lit juste sa position actuelle
            local headPosition = head.Position

            for i, part in ipairs(orbitingParts) do
                local partAngle = bodySpiralAngle + (360 / count) * (i - 1)
                local rad = math.rad(partAngle)
                local offset = Vector3.new(math.cos(rad) * bodySpiralRadius, 0, math.sin(rad) * bodySpiralRadius)
                local position = headPosition + offset
                part.CFrame = CFrame.new(position, headPosition) * CFrame.Angles(0, math.rad(90), 0)
            end
        end)
    end

    local function toggleBodySpiral(enabled)
        bodySpiralEnabled = enabled
        stopBodySpiral()
        if enabled then
            startBodySpiral()
        end
    end

    createToggle(VisualsPage, 18, "Visuals", "Spirale (membres R15 en orbite autour de la tête)", function(enabled)
        toggleBodySpiral(enabled)
    end)

    local _, updateBodySpiralRadius = createSlider(VisualsPage, 19, "Spirale - Rayon", 2, 12, 5, function(value)
        bodySpiralRadius = value
    end)

    local _, updateBodySpiralSpeed = createSlider(VisualsPage, 20, "Spirale - Vitesse (°/s)", 15, 360, 90, function(value)
        bodySpiralSpeed = value
    end)

    registerSetting("bodySpiralRadius",
        function() return bodySpiralRadius end,
        function(v) updateBodySpiralRadius(v) end
    )
    registerSetting("bodySpiralSpeed",
        function() return bodySpiralSpeed end,
        function(v) updateBodySpiralSpeed(v) end
    )

    -- Réapplique l'effet après une réapparition (respawn), si toujours actif
    player.CharacterAdded:Connect(function()
        if bodySpiralEnabled then
            task.wait(1)
            startBodySpiral()
        end
    end)
end

--// ================== PAGE WORLD (Brouillard & Teinte + Particules) ==================
-- Tout ce qui suit modifie uniquement le service Lighting côté client via un LocalScript :
-- ça ne se réplique jamais aux autres joueurs ni au serveur, exactement comme des réglages graphiques.
do
    local WorldPage = pages["World"]
    createInfoLabel(WorldPage, 1, "Réglages visuels du monde, visibles uniquement par toi (les autres joueurs ne voient rien de tout ça) :", 40)

    -- Sauvegarde des valeurs d'origine du brouillard pour pouvoir les restaurer proprement
    local originalFog = {
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
        FogColor = Lighting.FogColor,
    }

    createToggle(WorldPage, 2, "World", "Brouillard épais", function(enabled)
        if enabled then
            Lighting.FogColor = Color3.fromRGB(180, 180, 190)
            Lighting.FogStart = 10
            Lighting.FogEnd = 120
        else
            Lighting.FogStart = originalFog.FogStart or 0
            Lighting.FogEnd = originalFog.FogEnd or 1000000
            Lighting.FogColor = originalFog.FogColor or Color3.fromRGB(200, 200, 200)
        end
    end)

    -- Système de particules
    local particleEnabled = false
    local particleType = "none" -- "rain", "snow", "stars"
    local particleGui = nil
    local particleConnection = nil

    local function createParticleGui()
        if particleGui then
            particleGui:Destroy()
            particleGui = nil
        end
        
        particleGui = Instance.new("ScreenGui")
        particleGui.Name = "ParticleGui"
        particleGui.ResetOnSpawn = false
        particleGui.Parent = playerGui
        
        local particles = {}
        
        if particleType == "rain" then
            for i = 1, 100 do
                local rain = Instance.new("Frame")
                rain.Size = UDim2.new(0, 2, 0, 15)
                rain.BackgroundColor3 = Color3.fromRGB(150, 180, 220)
                rain.BackgroundTransparency = 0.3
                rain.BorderSizePixel = 0
                rain.Position = UDim2.new(math.random(), 0, math.random() - 0.5, 0)
                rain.Parent = particleGui
                table.insert(particles, {frame = rain, speed = math.random(15, 25)})
            end
        elseif particleType == "snow" then
            for i = 1, 80 do
                local snow = Instance.new("Frame")
                snow.Size = UDim2.new(0, 4, 0, 4)
                snow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                snow.BackgroundTransparency = 0.2
                snow.BorderSizePixel = 0
                snow.Position = UDim2.new(math.random(), 0, math.random() - 0.5, 0)
                local snowCorner = Instance.new("UICorner")
                snowCorner.CornerRadius = UDim.new(1, 0)
                snowCorner.Parent = snow
                snow.Parent = particleGui
                table.insert(particles, {frame = snow, speed = math.random(3, 8), drift = math.random(-2, 2)})
            end
        elseif particleType == "stars" then
            for i = 1, 50 do
                local star = Instance.new("Frame")
                star.Size = UDim2.new(0, 3, 0, 3)
                star.BackgroundColor3 = Color3.fromRGB(255, 255, 200)
                star.BackgroundTransparency = 0.1
                star.BorderSizePixel = 0
                star.Position = UDim2.new(math.random(), 0, math.random(), 0)
                local starCorner = Instance.new("UICorner")
                starCorner.CornerRadius = UDim.new(1, 0)
                starCorner.Parent = star
                star.Parent = particleGui
                table.insert(particles, {frame = star, speed = math.random(2, 5), drift = math.random(-1, 1)})
            end
        end
        
        return particles
    end

    local function updateParticles(deltaTime)
        if not particleGui or not particleEnabled then return end
        
        for _, particle in ipairs(particleGui:GetChildren()) do
            if particle:IsA("Frame") then
                local currentPos = particle.Position
                local speed = particle:GetAttribute("speed") or 10
                local drift = particle:GetAttribute("drift") or 0
                
                local newY = currentPos.Y.Scale + (deltaTime * speed * 0.05)
                local newX = currentPos.X.Scale + (deltaTime * drift * 0.01)
                
                if newY > 1 then
                    newY = -0.1
                    newX = math.random()
                end
                
                if newX < 0 then newX = 1 end
                if newX > 1 then newX = 0 end
                
                particle.Position = UDim2.new(newX, 0, newY, 0)
            end
        end
    end

    local function toggleParticles(enabled, type)
        particleEnabled = enabled
        particleType = type or "none"
        
        if particleConnection then
            particleConnection:Disconnect()
            particleConnection = nil
        end
        
        if particleGui then
            particleGui:Destroy()
            particleGui = nil
        end
        
        if enabled and type ~= "none" then
            createParticleGui()
            
            -- Set attributes for movement
            for _, particle in ipairs(particleGui:GetChildren()) do
                if particle:IsA("Frame") then
                    if particleType == "rain" then
                        particle:SetAttribute("speed", math.random(15, 25))
                        particle:SetAttribute("drift", 0)
                    elseif particleType == "snow" then
                        particle:SetAttribute("speed", math.random(3, 8))
                        particle:SetAttribute("drift", math.random(-2, 2))
                    elseif particleType == "stars" then
                        particle:SetAttribute("speed", math.random(2, 5))
                        particle:SetAttribute("drift", math.random(-1, 1))
                    end
                end
            end
            
            particleConnection = RunService.Heartbeat:Connect(function(deltaTime)
                if particleEnabled then
                    updateParticles(deltaTime)
                end
            end)
        end
    end

    createInfoLabel(WorldPage, 3, "Particules d'écran :", 20)

    createActionButton(WorldPage, 4, "Pluie", function()
        toggleParticles(true, "rain")
    end)

    createActionButton(WorldPage, 5, "Neige", function()
        toggleParticles(true, "snow")
    end)

    createActionButton(WorldPage, 6, "Étoiles", function()
        toggleParticles(true, "stars")
    end)

    createActionButton(WorldPage, 7, "Désactiver particules", function()
        toggleParticles(false, "none")
    end)

    -- Effet de correction couleur local (créé une seule fois, réutilisé pour changer teinte/contraste)
    local existingColorFx = Lighting:FindFirstChild("NamelessEnhancement_ColorFx")
    if existingColorFx then
        existingColorFx:Destroy()
    end

    local ColorFx = Instance.new("ColorCorrectionEffect")
    ColorFx.Name = "NamelessEnhancement_ColorFx"
    ColorFx.Contrast = 0
    ColorFx.Saturation = 0
    ColorFx.TintColor = Color3.fromRGB(255, 255, 255)
    ColorFx.Parent = Lighting

    createInfoLabel(WorldPage, 3, "Teinte de couleur (le contraste s'ajuste automatiquement avec) :", 20)

    local TintOptions = {
        {Name = "Aucune", Color = Color3.fromRGB(255, 255, 255), Contrast = 0},
        {Name = "Chaude", Color = Color3.fromRGB(255, 214, 170), Contrast = 0.15},
        {Name = "Froide", Color = Color3.fromRGB(170, 210, 255), Contrast = 0.15},
        {Name = "Sépia", Color = Color3.fromRGB(214, 180, 130), Contrast = 0.25},
        {Name = "Verte", Color = Color3.fromRGB(170, 255, 190), Contrast = 0.2},
        {Name = "Rouge", Color = Color3.fromRGB(255, 160, 160), Contrast = 0.3},
    }

    for i, opt in ipairs(TintOptions) do
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, -20, 0, 34)
        Row.BackgroundTransparency = 1
        Row.LayoutOrder = 3 + i
        Row.Parent = WorldPage

        local Swatch = Instance.new("Frame")
        Swatch.Size = UDim2.new(0, 20, 0, 20)
        Swatch.Position = UDim2.new(0, 0, 0.5, -10)
        Swatch.BackgroundColor3 = opt.Color
        Swatch.BorderSizePixel = 0
        Swatch.Parent = Row

        local SwatchCorner = Instance.new("UICorner")
        SwatchCorner.CornerRadius = UDim.new(1, 0)
        SwatchCorner.Parent = Swatch

        local TintButton = Instance.new("TextButton")
        TintButton.Size = UDim2.new(1, -30, 1, 0)
        TintButton.Position = UDim2.new(0, 30, 0, 0)
        TintButton.BackgroundTransparency = 1
        TintButton.Text = opt.Name
        TintButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        TintButton.Font = FONT
        TintButton.TextSize = 14
        TintButton.TextXAlignment = Enum.TextXAlignment.Left
        TintButton.Parent = Row

        TintButton.MouseButton1Click:Connect(function()
            ColorFx.TintColor = opt.Color
            ColorFx.Contrast = opt.Contrast
        end)
    end

    -- Fonction commune : détecte si une part appartient au personnage d'un joueur
    -- (pour exclure les joueurs des effets qui modifient le monde, et éviter qu'ils
    -- se retrouvent affichés comme de simples "boîtes" en verre/cristal)
    local function isPlayerCharacterPart(part)
        local model = part:FindFirstAncestorOfClass("Model")
        if not model then return false end
        return Players:GetPlayerFromCharacter(model) ~= nil
    end

    -- Nouveau : Monde brillant (Glossy) - rend les parties/meshes du monde réfléchissants, uniquement côté client
    local glossyEnabled = false
    local glossyReflectance = 0.4
    local glossyOriginalData = {} -- [part] = {Material = ..., Reflectance = ...}
    local glossyDescendantConn = nil

    local function applyGlossyToPart(part)
        if not part:IsA("BasePart") then return end
        if part:IsA("Terrain") then return end
        if isPlayerCharacterPart(part) then return end -- on ne touche pas aux joueurs
        if glossyOriginalData[part] then return end -- déjà traité

        glossyOriginalData[part] = {
            Material = part.Material,
            Reflectance = part.Reflectance,
        }

        part.Material = Enum.Material.Glass
        part.Reflectance = glossyReflectance
    end

    local function restoreGlossyPart(part, data)
        if part and part.Parent then
            part.Material = data.Material
            part.Reflectance = data.Reflectance
        end
    end

    local function toggleGlossy(enabled)
        glossyEnabled = enabled

        if glossyDescendantConn then
            glossyDescendantConn:Disconnect()
            glossyDescendantConn = nil
        end

        if enabled then
            -- Applique à tout ce qui existe déjà dans le monde
            for _, descendant in ipairs(workspace:GetDescendants()) do
                applyGlossyToPart(descendant)
            end

            -- Applique aussi aux nouveaux objets qui apparaissent ensuite (nouveaux meshes, props qui spawn, etc.)
            glossyDescendantConn = workspace.DescendantAdded:Connect(function(descendant)
                if glossyEnabled then
                    applyGlossyToPart(descendant)
                end
            end)
        else
            -- Restaure les matériaux et reflets d'origine
            for part, data in pairs(glossyOriginalData) do
                restoreGlossyPart(part, data)
            end
            glossyOriginalData = {}
        end
    end

    local function updateGlossyReflectance()
        if glossyEnabled then
            for part, _ in pairs(glossyOriginalData) do
                if part and part.Parent then
                    part.Reflectance = glossyReflectance
                end
            end
        end
    end

    createInfoLabel(WorldPage, 10, "Monde brillant (rend les meshes et parties du monde réfléchissants, visible uniquement par toi) :", 30)

    createToggle(WorldPage, 11, "World", "Glossy (monde brillant)", function(enabled)
        toggleGlossy(enabled)
    end)

    local _, updateGlossySlider = createSlider(WorldPage, 12, "Intensité du reflet (%)", 0, 100, 40, function(value)
        glossyReflectance = value / 100
        updateGlossyReflectance()
    end)

    registerSetting("glossyReflectance",
        function() return glossyReflectance * 100 end,
        function(v) updateGlossySlider(v) end
    )

    -- Nouveau : Monde cristal (Crystal) - rend les parties/meshes du monde translucides et teintées,
    -- comme si elles étaient taillées dans du cristal. Uniquement côté client.
    local crystalEnabled = false
    local crystalTransparency = 0.35
    local crystalColor = Color3.fromRGB(180, 220, 255)
    local crystalOriginalData = {} -- [part] = {Material, Reflectance, Transparency, Color}
    local crystalDescendantConn = nil

    local function applyCrystalToPart(part)
        if not part:IsA("BasePart") then return end
        if part:IsA("Terrain") then return end
        if isPlayerCharacterPart(part) then return end -- on ne touche pas aux joueurs
        if crystalOriginalData[part] then return end -- déjà traité

        crystalOriginalData[part] = {
            Material = part.Material,
            Reflectance = part.Reflectance,
            Transparency = part.Transparency,
            Color = part.Color,
        }

        part.Material = Enum.Material.Glass
        part.Reflectance = 0.15
        part.Transparency = crystalTransparency
        part.Color = crystalColor
    end

    local function restoreCrystalPart(part, data)
        if part and part.Parent then
            part.Material = data.Material
            part.Reflectance = data.Reflectance
            part.Transparency = data.Transparency
            part.Color = data.Color
        end
    end

    local function toggleCrystal(enabled)
        crystalEnabled = enabled

        if crystalDescendantConn then
            crystalDescendantConn:Disconnect()
            crystalDescendantConn = nil
        end

        if enabled then
            for _, descendant in ipairs(workspace:GetDescendants()) do
                applyCrystalToPart(descendant)
            end

            crystalDescendantConn = workspace.DescendantAdded:Connect(function(descendant)
                if crystalEnabled then
                    applyCrystalToPart(descendant)
                end
            end)
        else
            for part, data in pairs(crystalOriginalData) do
                restoreCrystalPart(part, data)
            end
            crystalOriginalData = {}
        end
    end

    local function updateCrystalTransparency()
        if crystalEnabled then
            for part, _ in pairs(crystalOriginalData) do
                if part and part.Parent then
                    part.Transparency = crystalTransparency
                end
            end
        end
    end

    local function updateCrystalColor()
        if crystalEnabled then
            for part, _ in pairs(crystalOriginalData) do
                if part and part.Parent then
                    part.Color = crystalColor
                end
            end
        end
    end

    createInfoLabel(WorldPage, 13, "Monde cristal (rend les meshes et parties du monde translucides et teintées, visible uniquement par toi) :", 30)

    createToggle(WorldPage, 14, "World", "Crystal (monde cristal)", function(enabled)
        toggleCrystal(enabled)
    end)

    local _, updateCrystalSlider = createSlider(WorldPage, 15, "Transparence (%)", 0, 90, 35, function(value)
        crystalTransparency = value / 100
        updateCrystalTransparency()
    end)

    createInfoLabel(WorldPage, 16, "Couleur du cristal :", 20)

    local crystalColorOptions = {
        Color3.fromRGB(180, 220, 255), -- bleu glacé (défaut)
        Color3.fromRGB(200, 255, 240), -- menthe
        Color3.fromRGB(255, 200, 230), -- rose quartz
        Color3.fromRGB(220, 180, 255), -- améthyste
        Color3.fromRGB(255, 240, 180), -- topaze
        Color3.fromRGB(255, 255, 255), -- blanc pur
    }

    local _, selectCrystalColor = createColorPalette(WorldPage, 17, "Couleur", crystalColorOptions, crystalColor, function(color)
        crystalColor = color
        updateCrystalColor()
    end)

    registerSetting("crystalTransparency",
        function() return crystalTransparency * 100 end,
        function(v) updateCrystalSlider(v) end
    )
    registerSetting("crystalColor",
        function() return colorToTable(crystalColor) end,
        function(v) selectCrystalColor(tableToColor(v)) end
    )
end

--// Helper pour un champ de saisie de texte (nom de config)
local function createTextbox(parent, order, placeholder)
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -20, 0, 32)
    Box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Box.BackgroundTransparency = 0.3
    Box.TextColor3 = Color3.fromRGB(230, 230, 230)
    Box.PlaceholderText = placeholder
    Box.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
    Box.Font = FONT
    Box.TextSize = 14
    Box.ClearTextOnFocus = false
    Box.Text = ""
    Box.LayoutOrder = order
    Box.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Box

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 10)
    Padding.PaddingRight = UDim.new(0, 10)
    Padding.Parent = Box

    return Box
end

--// Helper pour une ligne de la liste des configs sauvegardées (nom + Activer + Supprimer)
local function createConfigRow(parent, order, configName, isActive, onLoad, onDelete)
    local Row = Instance.new("Frame")
    Row.Name = "Row_" .. configName
    Row.Size = UDim2.new(1, 0, 0, 34)
    Row.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Row.BackgroundTransparency = isActive and 0.35 or 0.85
    Row.LayoutOrder = order
    Row.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Row

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -142, 1, 0)
    NameLabel.Position = UDim2.new(0, 10, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = configName .. (isActive and "  (active)" or "")
    NameLabel.TextColor3 = isActive and currentTheme.Main or Color3.fromRGB(220, 220, 220)
    NameLabel.Font = FONT
    NameLabel.TextSize = 13
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    NameLabel.Parent = Row
    if isActive then
        table.insert(mainColorElements, {NameLabel, "TextColor3"})
    end

    local LoadBtn = Instance.new("TextButton")
    LoadBtn.Size = UDim2.new(0, 62, 0, 24)
    LoadBtn.Position = UDim2.new(1, -134, 0.5, -12)
    LoadBtn.BackgroundColor3 = currentTheme.Main
    LoadBtn.BackgroundTransparency = 0.55
    LoadBtn.AutoButtonColor = false
    LoadBtn.Text = "Activer"
    LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadBtn.Font = FONT
    LoadBtn.TextSize = 12
    LoadBtn.Parent = Row
    table.insert(mainColorElements, {LoadBtn, "BackgroundColor3"})

    local LoadCorner = Instance.new("UICorner")
    LoadCorner.CornerRadius = UDim.new(0, 4)
    LoadCorner.Parent = LoadBtn

    LoadBtn.MouseButton1Click:Connect(onLoad)

    local DeleteBtn = Instance.new("TextButton")
    DeleteBtn.Size = UDim2.new(0, 62, 0, 24)
    DeleteBtn.Position = UDim2.new(1, -66, 0.5, -12)
    DeleteBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    DeleteBtn.BackgroundTransparency = 0.45
    DeleteBtn.AutoButtonColor = false
    DeleteBtn.Text = "Suppr."
    DeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DeleteBtn.Font = FONT
    DeleteBtn.TextSize = 12
    DeleteBtn.Parent = Row

    local DeleteCorner = Instance.new("UICorner")
    DeleteCorner.CornerRadius = UDim.new(0, 4)
    DeleteCorner.Parent = DeleteBtn

    DeleteBtn.MouseButton1Click:Connect(onDelete)

    return Row
end

--// ================== PAGE CONFIG (fonctionnelle, multi-configs) ==================
-- Permet de créer, nommer, sauvegarder, activer et supprimer plusieurs configs.
-- Chaque config regroupe : ToggleStates + Settings (sliders/couleurs/crosshair/particules/etc) + Thème.
-- La config active est mémorisée dans un fichier séparé (active.txt) et rechargée
-- automatiquement au prochain lancement du script, même si le hub a été fermé entre-temps.
-- (fonctions writefile/readfile/isfile/isfolder/makefolder/listfiles/delfile fournies par
-- l'exécuteur de script ; tout est protégé par pcall et ignoré proprement si absentes)

-- Ces toggles ne sont jamais inclus dans la sauvegarde/chargement de config : ils resteront
-- toujours désactivés au démarrage et devront être réactivés manuellement chaque session.
local CONFIG_EXCLUDED_TOGGLES = {
    ["Visuals_ESP (Neon Glow)"] = true,
    ["Visuals_Spirale (membres R15 en orbite autour de la tête)"] = true,
    ["Combat_Rage Bot"] = true,
    ["Combat_Spin Bot"] = true,
    ["Combat_Shotgun Rage"] = true,
    ["Combat_Mode Spirale (R15)"] = true,
}

local function sanitizeConfigName(name)
    name = name:gsub("^%s+", ""):gsub("%s+$", "") -- trim
    name = name:gsub("[^%w%s%-_]", "") -- caractères sûrs pour un nom de fichier
    return name
end

local activeConfigName = nil

local function buildConfigData()
    local togglesToSave = {}
    for key, value in pairs(ToggleStates) do
        if not CONFIG_EXCLUDED_TOGGLES[key] then
            togglesToSave[key] = value
        end
    end

    local settingsToSave = {}
    for key, entry in pairs(SettingsRegistry) do
        local success, value = pcall(entry.get)
        if success then
            settingsToSave[key] = value
        end
    end

    return {
        Toggles = togglesToSave,
        Settings = settingsToSave,
        Theme = currentTheme.Name,
    }
end

-- Mémorise (sur disque) quelle config est actuellement active, pour la retrouver
-- automatiquement même après fermeture/réouverture du hub.
local function setActiveConfig(name)
    activeConfigName = name
    pcall(function()
        if not isfolder(CONFIG_FOLDER) then
            makefolder(CONFIG_FOLDER)
        end
        writefile(ACTIVE_CONFIG_FILE, name or "")
    end)
end

local function getActiveConfigFromDisk()
    local ok, result = pcall(function()
        if not isfile(ACTIVE_CONFIG_FILE) then
            return nil
        end
        local n = readfile(ACTIVE_CONFIG_FILE)
        if n == "" then
            return nil
        end
        return n
    end)
    if ok then
        return result
    end
    return nil
end

local function listConfigs()
    local names = {}
    pcall(function()
        if isfolder(CONFIGS_FOLDER) then
            for _, path in ipairs(listfiles(CONFIGS_FOLDER)) do
                local fname = path:match("([^/\\]+)%.json$")
                if fname then
                    table.insert(names, fname)
                end
            end
        end
    end)
    table.sort(names, function(a, b) return a:lower() < b:lower() end)
    return names
end

local function saveConfigAs(name)
    local ok = pcall(function()
        if not isfolder(CONFIG_FOLDER) then
            makefolder(CONFIG_FOLDER)
        end
        if not isfolder(CONFIGS_FOLDER) then
            makefolder(CONFIGS_FOLDER)
        end
        local data = buildConfigData()
        writefile(CONFIGS_FOLDER .. "/" .. name .. ".json", HttpService:JSONEncode(data))
    end)
    return ok
end

local function applyConfigData(result)
    -- 1. Le thème d'abord (les couleurs de l'UI en dépendent)
    if result.Theme then
        for _, theme in ipairs(Themes) do
            if theme.Name == result.Theme then
                applyTheme(theme)
                break
            end
        end
    end

    -- 2. Les réglages (sliders, couleurs, crosshair, ambiance, particules...) ensuite,
    -- avant les toggles : certains effets lisent ces valeurs au moment où ils s'activent.
    if result.Settings then
        for key, value in pairs(result.Settings) do
            local entry = SettingsRegistry[key]
            if entry then
                pcall(entry.set, value)
            end
        end
    end

    -- 3. Les toggles en dernier : setState(value, false) met à jour le visuel ET
    -- déclenche réellement l'effet (onChanged), contrairement à un simple refresh visuel.
    if result.Toggles then
        for _, t in ipairs(toggleRegistry) do
            if not CONFIG_EXCLUDED_TOGGLES[t.stateKey] then
                local savedValue = result.Toggles[t.stateKey]
                if savedValue ~= nil then
                    t.setState(savedValue, false)
                end
            end
        end
    end
end

local function loadConfigByName(name)
    local readOk, result = pcall(function()
        local path = CONFIGS_FOLDER .. "/" .. name .. ".json"
        if not isfile(path) then
            return nil
        end
        return HttpService:JSONDecode(readfile(path))
    end)

    if not readOk then
        return false, "lecture: " .. tostring(result)
    end
    if not result then
        return false, "fichier introuvable"
    end

    local applyOk, applyErr = pcall(applyConfigData, result)
    if not applyOk then
        return false, "application: " .. tostring(applyErr)
    end

    setActiveConfig(name)
    return true
end

local function deleteConfigByName(name)
    local ok = pcall(function()
        local path = CONFIGS_FOLDER .. "/" .. name .. ".json"
        if isfile(path) then
            delfile(path)
        end
    end)
    if ok and activeConfigName == name then
        setActiveConfig(nil)
    end
    return ok
end

local function resetConfig()
    for _, t in ipairs(toggleRegistry) do
        t.setState(false, false)
    end
    applyTheme(Themes[1])
end

do
    local ConfigPage = pages["Config"]
    local StatusLabel = createInfoLabel(ConfigPage, 1, "Crée, nomme et active plusieurs configs (couleurs, crosshair, ambiance, particules, etc). Elles restent sauvegardées même si tu fermes le hub.", 45)

    local NameBox = createTextbox(ConfigPage, 2, "Nom de la config...")

    local refreshConfigList -- déclaration anticipée

    local function doSave()
        local name = sanitizeConfigName(NameBox.Text)
        if name == "" then
            StatusLabel.Text = "Entre un nom de config valide."
            return
        end
        if saveConfigAs(name) then
            setActiveConfig(name)
            StatusLabel.Text = "Config \"" .. name .. "\" sauvegardée et activée."
            NameBox.Text = ""
            refreshConfigList()
        else
            StatusLabel.Text = "Sauvegarde indisponible (exécuteur requis)."
        end
    end

    createActionButton(ConfigPage, 3, "Sauvegarder comme nouvelle config", doSave)
    createActionButton(ConfigPage, 4, "Réinitialiser les réglages", function()
        resetConfig()
        StatusLabel.Text = "Réglages réinitialisés."
    end)

    createInfoLabel(ConfigPage, 5, "Mes configs :", 20)

    local ConfigListHolder = Instance.new("Frame")
    ConfigListHolder.Name = "ConfigListHolder"
    ConfigListHolder.Size = UDim2.new(1, -20, 0, 0)
    ConfigListHolder.AutomaticSize = Enum.AutomaticSize.Y
    ConfigListHolder.BackgroundTransparency = 1
    ConfigListHolder.LayoutOrder = 6
    ConfigListHolder.Parent = ConfigPage

    local ConfigListLayout = Instance.new("UIListLayout")
    ConfigListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ConfigListLayout.Padding = UDim.new(0, 6)
    ConfigListLayout.Parent = ConfigListHolder

    refreshConfigList = function()
        for _, child in ipairs(ConfigListHolder:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") then
                child:Destroy()
            end
        end

        local names = listConfigs()
        if #names == 0 then
            createInfoLabel(ConfigListHolder, 1, "Aucune config sauvegardée pour l'instant.", 20)
        else
            for i, name in ipairs(names) do
                createConfigRow(ConfigListHolder, i, name, name == activeConfigName,
                    function()
                        local success, errMsg = loadConfigByName(name)
                        if success then
                            StatusLabel.Text = "Config \"" .. name .. "\" activée."
                            refreshConfigList()
                        else
                            StatusLabel.Text = "Erreur chargement (" .. tostring(errMsg) .. ")"
                            warn("[NamelessEnhancement] Echec chargement config '" .. name .. "': " .. tostring(errMsg))
                        end
                    end,
                    function()
                        deleteConfigByName(name)
                        StatusLabel.Text = "Config \"" .. name .. "\" supprimée."
                        refreshConfigList()
                    end
                )
            end
        end
    end

    refreshConfigList()

    -- Rechargement automatique de la dernière config active, même après fermeture du hub
    local savedActive = getActiveConfigFromDisk()
    if savedActive then
        local success, errMsg = loadConfigByName(savedActive)
        if success then
            StatusLabel.Text = "Config \"" .. savedActive .. "\" rechargée automatiquement."
            refreshConfigList()
        else
            warn("[NamelessEnhancement] Echec rechargement auto config '" .. savedActive .. "': " .. tostring(errMsg))
        end
    end
end

-- Sélectionne la première catégorie par défaut
selectCategory(Categories[1].Name)

--// ================== REDUCTION AVEC SHIFT ==================
local minimized = false
local isTweening = false

local function setMinimized(shouldMinimize)
    if isTweening or minimized == shouldMinimize then return end
    isTweening = true
    minimized = shouldMinimize

    local targetSize = minimized and MINIMIZED_SIZE or FULL_SIZE

    if minimized then
        CategoryList.Visible = false
        ContentArea.Visible = false
    end

    local tween = TweenService:Create(
        MainFrame,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = targetSize}
    )
    tween:Play()
    tween.Completed:Connect(function()
        if not minimized then
            CategoryList.Visible = true
            ContentArea.Visible = true
        end
        isTweening = false
    end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        setMinimized(true)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        setMinimized(false)
    end
end)
