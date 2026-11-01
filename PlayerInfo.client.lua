local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Alternar entre primera y tercera persona con I
local thirdPerson = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.I then
        thirdPerson = not thirdPerson

        if thirdPerson then
            localPlayer.CameraMode = Enum.CameraMode.Classic
            localPlayer.CameraMinZoomDistance = 8
            localPlayer.CameraMaxZoomDistance = 12
        else
            localPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
            localPlayer.CameraMinZoomDistance = 0.5
            localPlayer.CameraMaxZoomDistance = 0.5
        end
    end
end)

-- Fuente para todos los textos.
-- Roblox debe tener disponible la familia "Tiny5 Duo" para mostrarla.
local TINY5_DUO = Font.new("rbxasset://fonts/families/Tiny5.json")

-- Panel del jugador apuntado
local gui = Instance.new("ScreenGui")
gui.Name = "TargetInfoGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(280, 58)
panel.Position = UDim2.new(0.5, -140, 0.72, 0)
panel.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui

local border = Instance.new("UIStroke")
border.Color = Color3.fromRGB(55, 55, 60)
border.Thickness = 1
border.Parent = panel

local portrait = Instance.new("ImageLabel")
portrait.Position = UDim2.fromOffset(5, 5)
portrait.Size = UDim2.fromOffset(48, 48)
portrait.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
portrait.BorderSizePixel = 0
portrait.Parent = panel

local nameLabel = Instance.new("TextLabel")
nameLabel.Position = UDim2.fromOffset(58, 5)
nameLabel.Size = UDim2.new(1, -63, 0, 14)
nameLabel.BackgroundTransparency = 1
nameLabel.FontFace = TINY5_DUO
nameLabel.TextSize = 14
nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
nameLabel.Parent = panel

local healthBack = Instance.new("Frame")
healthBack.Position = UDim2.fromOffset(58, 21)
healthBack.Size = UDim2.new(1, -63, 0, 13)
healthBack.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
healthBack.BorderSizePixel = 0
healthBack.Parent = panel

local healthFill = Instance.new("Frame")
healthFill.Size = UDim2.fromScale(1, 1)
healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 70)
healthFill.BorderSizePixel = 0
healthFill.Parent = healthBack

local healthText = Instance.new("TextLabel")
healthText.Size = UDim2.fromScale(1, 1)
healthText.BackgroundTransparency = 1
healthText.FontFace = TINY5_DUO
healthText.TextSize = 13
healthText.TextColor3 = Color3.fromRGB(0, 255, 70)
healthText.TextStrokeTransparency = 0.4
healthText.Parent = healthBack

local details = Instance.new("TextLabel")
details.Position = UDim2.fromOffset(58, 37)
details.Size = UDim2.new(1, -63, 0, 16)
details.BackgroundTransparency = 1
details.FontFace = TINY5_DUO
details.TextSize = 13
details.TextColor3 = Color3.fromRGB(205, 205, 205)
details.TextXAlignment = Enum.TextXAlignment.Left
details.TextTruncate = Enum.TextTruncate.AtEnd
details.Parent = panel

-- Resaltado persistente en los demás jugadores
local highlights = {}

local function addHighlight(player, character)
    if player == localPlayer or not character then
        return
    end

    local highlight = highlights[player]
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "RedWhiteHighlight"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.25
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = gui
        highlights[player] = highlight
    end

    highlight.Adornee = character
    highlight.Enabled = true
end

-- Etiqueta con nombre blanco y salud verde sobre cada jugador
local nameplates = {}

local function addNameplate(player, character)
    if player == localPlayer or not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
        or character:WaitForChild("Humanoid", 5)
    local head = character:FindFirstChild("Head")
        or character:WaitForChild("Head", 5)

    if not humanoid or not head then
        return
    end

    local previous = nameplates[player]
    if previous then
        previous:Destroy()
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerNameplate"
    billboard.Adornee = head
    billboard.Size = UDim2.fromOffset(200, 42)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = gui

    local nameText = Instance.new("TextLabel")
    nameText.Position = UDim2.fromScale(0, 0)
    nameText.Size = UDim2.new(1, 0, 0.5, 0)
    nameText.BackgroundTransparency = 1
    nameText.FontFace = TINY5_DUO
    nameText.TextSize = 16
    nameText.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameText.TextStrokeColor3 = Color3.fromRGB(20, 20, 20)
    nameText.TextStrokeTransparency = 0.25
    nameText.Text = player.DisplayName
    nameText.Parent = billboard

    local healthTextOnPlayer = Instance.new("TextLabel")
    healthTextOnPlayer.Position = UDim2.new(0, 0, 0.5, 0)
    healthTextOnPlayer.Size = UDim2.new(1, 0, 0.5, 0)
    healthTextOnPlayer.BackgroundTransparency = 1
    healthTextOnPlayer.FontFace = TINY5_DUO
    healthTextOnPlayer.TextSize = 15
    healthTextOnPlayer.TextColor3 = Color3.fromRGB(0, 255, 70)
    healthTextOnPlayer.TextStrokeColor3 = Color3.fromRGB(20, 20, 20)
    healthTextOnPlayer.TextStrokeTransparency = 0.25
    healthTextOnPlayer.Text = string.format("%d HP", math.ceil(humanoid.Health))
    healthTextOnPlayer.Parent = billboard

    nameplates[player] = billboard

    humanoid.HealthChanged:Connect(function(health)
        if healthTextOnPlayer.Parent then
            healthTextOnPlayer.Text = string.format("%d HP", math.ceil(health))
        end
    end)

    player:GetPropertyChangedSignal("DisplayName"):Connect(function()
        if nameText.Parent then
            nameText.Text = player.DisplayName
        end
    end)
end

local function connectPlayer(player)
    if player == localPlayer then
        return
    end

    if player.Character then
        addHighlight(player, player.Character)
        addNameplate(player, player.Character)
    end

    player.CharacterAdded:Connect(function(character)
        addHighlight(player, character)
        addNameplate(player, character)
    end)
end

local function removePlayer(player)
    local highlight = highlights[player]
    if highlight then
        highlight:Destroy()
        highlights[player] = nil
    end

    local nameplate = nameplates[player]
    if nameplate then
        nameplate:Destroy()
        nameplates[player] = nil
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    connectPlayer(player)
end

Players.PlayerAdded:Connect(connectPlayer)
Players.PlayerRemoving:Connect(removePlayer)

-- Panel del jugador apuntado desde el centro de la cámara
local thumbnailCache = {}

local function setPortrait(player)
    local cached = thumbnailCache[player.UserId]
    if cached then
        portrait.Image = cached
        return
    end

    task.spawn(function()
        local ok, image = pcall(function()
            return Players:GetUserThumbnailAsync(
                player.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size100x100
            )
        end)

        if ok then
            thumbnailCache[player.UserId] = image
            if nameLabel.Text == player.DisplayName then
                portrait.Image = image
            end
        end
    end)
end

RunService.RenderStepped:Connect(function()
    local camera = Workspace.CurrentCamera
    if not camera then
        panel.Visible = false
        return
    end

    local viewport = camera.ViewportSize
    local ray = camera:ViewportPointToRay(viewport.X / 2, viewport.Y / 2)

    local closestPlayer
    local closestCharacter
    local closestHumanoid
    local closestDistance

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local targetRoot = character and character:FindFirstChild("HumanoidRootPart")

            if humanoid and targetRoot and humanoid.Health > 0 then
                local offset = targetRoot.Position - ray.Origin
                local distance = offset.Magnitude

                if distance >= 1 then
                    local dot = ray.Direction:Dot(offset.Unit)

                    if dot > 0.995 then
                        local closestPoint = ray.Origin + ray.Direction * distance
                        local missDistance = (targetRoot.Position - closestPoint).Magnitude

                        if missDistance < 5
                            and (not closestDistance or distance < closestDistance) then
                            closestPlayer = player
                            closestCharacter = character
                            closestHumanoid = humanoid
                            closestDistance = distance
                        end
                    end
                end
            end
        end
    end

    if not closestPlayer then
        panel.Visible = false
        return
    end

    local myRoot = localPlayer.Character
        and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = closestCharacter:FindFirstChild("HumanoidRootPart")
    local distance = closestDistance

    if myRoot and targetRoot then
        distance = (myRoot.Position - targetRoot.Position).Magnitude
    end

    local health = math.max(0, math.floor(closestHumanoid.Health + 0.5))
    local maxHealth = math.max(1, math.floor(closestHumanoid.MaxHealth + 0.5))
    local ratio = math.clamp(closestHumanoid.Health / maxHealth, 0, 1)

    nameLabel.Text = closestPlayer.DisplayName
    healthText.Text = string.format("%d/%d", health, maxHealth)
    healthFill.Size = UDim2.fromScale(ratio, 1)
    details.Text = string.format(
        "dist: %dm   cuenta: %d días",
        math.floor(distance + 0.5),
        closestPlayer.AccountAge
    )

    setPortrait(closestPlayer)
    panel.Visible = true
end)
