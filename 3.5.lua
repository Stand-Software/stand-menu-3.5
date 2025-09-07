local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local Window = OrionLib:MakeWindow({Name = "💎Stand Menu V3.5", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

-- Variáveis de controle
local flyEnabled = false
local espDistance = 500 -- Distância máxima para renderizar qualquer ESP
local isFlying = false
local speed = 20
local boostSpeed = 350 -- Velocidade de boost do Shift (valor padrão para o slider)
local bodyVelocity, bodyGyro, connection
local aimbotEnabled = false
local aimSensitivity = 0.3
local fovSize = 100
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Radius = fovSize
fovCircle.Filled = false
fovCircle.Visible = false
local aimDistance = 500 -- Sincronizado com espDistance
local AimbotEnabled = false
local BoxESPEnabled = false
local NameTagsEnabled = false
local ESPObjects = {}
local NameTags = {}
local plr = game.Players.LocalPlayer
local nameTagSize = 17.5
local nameTagColor = Color3.fromRGB(255, 255, 255)
local boxColor = Color3.fromRGB(255, 255, 255)
local chamFillColor = Color3.fromRGB(175, 25, 255)
local chamOutlineColor = Color3.fromRGB(255, 255, 255)
local fovColor = Color3.fromRGB(255, 255, 255)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local aimbotKeybind = Enum.KeyCode.Q
local aimbotHolding = false
local aimbotTeam = false

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:FindFirstChildOfClass("Humanoid")

local freecamEnabled = false
local freecamToggleActive = false
local freecamToggleBind = Enum.KeyCode.N
local cameraOffset = Vector3.new(0, 5, 10)
local mouseDelta = Vector2.new(0, 0)
local mouseMovementConnection
local teleportConnection
local renderSteppedConnection
local moveSpeed = 0.5
local rotationSpeedQ = 0.001 -- Esta variável agora controla todas as rotações

-- Variáveis para a nova velocidade do mouse
local mouseSpeedX = 0.1
local mouseSpeedY = 0.1
local freecamBoostSpeed = 2 -- Velocidade de boost do freecam

-- Variáveis essenciais
local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = game:GetService("Workspace").CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function onMouseMove(input)
    if freecamEnabled and input.UserInputType == Enum.UserInputType.MouseMovement then
        mouseDelta = input.Delta
    end
end

local function enableFreecam()
    if not freecamEnabled then
        freecamEnabled = true
        Camera.CameraType = Enum.CameraType.Scriptable
        
        -- Garante que a câmera comece na posição do jogador e olhe para frente
        Camera.CFrame = HumanoidRootPart.CFrame
        
        -- Trava o mouse no centro da tela para um movimento de câmera mais suave
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        UserInputService.MouseIconEnabled = false
        
        -- Desabilitar movimentação do personagem
        if Humanoid then
            Humanoid.WalkSpeed = 0
            Humanoid.JumpPower = 0
            Humanoid.PlatformStand = true
        end
        
        -- Conexão para teleporte
        teleportConnection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
            if freecamEnabled and not gameProcessedEvent then
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    -- Cálculo do teleporte
                    local rayOrigin = Camera.CFrame.Position
                    local rayDirection = Camera.CFrame.LookVector * 1000
                    
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    raycastParams.FilterDescendantsInstances = {Character}
                    
                    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                    
                    if raycastResult then
                        HumanoidRootPart.CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, 3, 0))
                    else
                        HumanoidRootPart.CFrame = CFrame.new(rayOrigin + (Camera.CFrame.LookVector * 50))
                    end
                end
            end
        end)

        mouseMovementConnection = UserInputService.InputChanged:Connect(onMouseMove)
        
        renderSteppedConnection = RunService.RenderStepped:Connect(function()
            if freecamEnabled then
                local currentMoveSpeed = moveSpeed
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    currentMoveSpeed = currentMoveSpeed + freecamBoostSpeed
                end
                
                local moveDirection = Vector3.new(0, 0, 0)
                
                -- Controles de movimento horizontal (WASD)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Vector3.new(0, 0, -1) end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection + Vector3.new(0, 0, 1) end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection + Vector3.new(-1, 0, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Vector3.new(1, 0, 0) end
                
                -- Controles de movimento vertical (E/Q)
                if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveDirection = moveDirection + Vector3.new(0, -1, 0) end
                
                -- Aplica movimento
                Camera.CFrame = Camera.CFrame * CFrame.new(moveDirection * currentMoveSpeed)
                
                -- Rotação com mouse
                local rotationX = -mouseDelta.Y * mouseSpeedY
                local rotationY = -mouseDelta.X * mouseSpeedX
                
                -- Aplica a rotação de forma separada para evitar "roll"
                Camera.CFrame = Camera.CFrame * CFrame.Angles(rotationX, 0, 0) * CFrame.Angles(0, rotationY, 0)
                
                -- Zera o mouseDelta para evitar o movimento contínuo
                mouseDelta = Vector2.new(0, 0)
            end
        end)
        
        OrionLib:MakeNotification({
            Name = "Freecam",
            Content = "Freecam Ativado!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
end

local function disableFreecam()
    freecamEnabled = false
    Camera.CameraType = Enum.CameraType.Custom
    Camera.CFrame = HumanoidRootPart.CFrame
    
    -- Restaura o comportamento padrão do mouse
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    UserInputService.MouseIconEnabled = true
    
    -- Desconectar conexões
    if mouseMovementConnection then mouseMovementConnection:Disconnect() end
    if teleportConnection then teleportConnection:Disconnect() end
    if renderSteppedConnection then renderSteppedConnection:Disconnect() end
    
    -- Restaurar personagem
    if Humanoid then
        Humanoid.WalkSpeed = 16
        Humanoid.JumpPower = 50
        Humanoid.PlatformStand = false
    end

    OrionLib:MakeNotification({
        Name = "Freecam",
        Content = "Freecam Desativado!",
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end

-- Funções de criação e atualização dos elementos (refatoradas para o loop principal)
local function CreateBox(player)
    local box = Drawing.new("Square")
    box.Thickness = 1 -- Espessura alterada para 1
    box.Color = boxColor
    box.Visible = false
    ESPObjects[player] = box
    return box
end

local function CreateNameTag(player)
    local nametag = Drawing.new("Text")
    nametag.Size = nameTagSize
    nametag.Color = nameTagColor
    nametag.Visible = false
    NameTags[player] = nametag
    return nametag
end

local function UpdateBox(box, rootPart)
    local localChar = game.Players.LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return end

    local distance = (rootPart.Position - localChar.HumanoidRootPart.Position).Magnitude
    local viewportPoint, onScreen = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)

    if BoxESPEnabled and onScreen and distance <= espDistance then
        local size = Vector2.new(2000 / viewportPoint.Z, 4000 / viewportPoint.Z)
        box.Size = size
        box.Position = Vector2.new(viewportPoint.X - size.X / 2, viewportPoint.Y - size.Y / 2)
        box.Visible = true
        return box.Position, box.Size
    else
        box.Visible = false
    end
end

local function UpdateNameTag(nametag, player)
    local localChar = game.Players.LocalPlayer.Character
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") or not rootPart then return end

    local distance = (rootPart.Position - localChar.HumanoidRootPart.Position).Magnitude
    local viewportPoint, onScreen = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)

    if NameTagsEnabled and onScreen and distance <= espDistance then
        nametag.Text = player.Name
        nametag.Position = Vector2.new(viewportPoint.X, viewportPoint.Y - 20)
        nametag.Visible = true
    else
        nametag.Visible = false
    end
end

local function ToggleBoxESP(state)
    BoxESPEnabled = state
    if not BoxESPEnabled then
        for _, box in pairs(ESPObjects) do
            box.Visible = false
        end
    end
end

local function ToggleNameTags(state)
    NameTagsEnabled = state
    if not NameTagsEnabled then
        for _, nametag in pairs(NameTags) do
            nametag.Visible = false
        end
    end
end

function updateFovCircle()
    fovCircle.Radius = fovSize
    fovCircle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
    fovCircle.Color = fovColor -- Garante que a cor seja atualizada
end


-- Modificar a função enableAimbot para:
function enableAimbot(state)
    aimbotEnabled = state
    fovCircle.Visible = state
    
    if aimbotEnabled then
        game:GetService("RunService").RenderStepped:Connect(function()
            if aimbotEnabled and aimbotHolding then  -- Só ativa quando segurando a bind
                local camera = workspace.CurrentCamera
                local closestTarget = nil
                -- Mudei de shortestDistance para shortestDistanceToPlayer para priorizar o player mais próximo, não o mais próximo do centro da tela.
                local shortestDistanceToPlayer = math.huge
                local mousePosition = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)

                for _, player in pairs(game.Players:GetPlayers()) do
                    if player ~= plr and player.Character and player.Character:FindFirstChild("Head") then
                        -- Adicionando a verificação de time
                        if aimbotTeam and player.Team == plr.Team then
                            continue
                        end

                        local head = player.Character.Head
                        local screenPoint, onScreen = camera:WorldToScreenPoint(head.Position)
                        local distanceFromMouse = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePosition).Magnitude
                        
                        -- Calcula a distância do seu player até a cabeça do alvo
                        local playerDistance = (head.Position - plr.Character.HumanoidRootPart.Position).Magnitude

                        -- A nova condição de seleção de alvo.
                        -- 1. O alvo está na tela?
                        -- 2. Está dentro do FOV?
                        -- 3. Está dentro da distância máxima do menu?
                        -- 4. É o alvo mais próximo do seu jogador (e não da sua mira)?
                        if onScreen and distanceFromMouse < fovSize and playerDistance <= aimDistance and playerDistance < shortestDistanceToPlayer then
                            shortestDistanceToPlayer = playerDistance
                            closestTarget = head
                        end
                    end
                end

                if closestTarget then
                    local targetPosition = closestTarget.Position
                    local aimDirection = (targetPosition - camera.CFrame.Position).unit
                    camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + aimDirection:Lerp(camera.CFrame.LookVector, aimSensitivity))
                end
            end
        end)
    end
end


local function enableFly()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")

    humanoid.PlatformStand = true

    -- Cria controles físicos
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new()
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.P = 1000
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 1000
    bodyGyro.D = 100
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root

    -- Conexão principal para voo e noclip
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isFlying then return end
        
        -- Captura direção do movimento
        local cam = workspace.CurrentCamera.CFrame
        local moveDir = Vector3.new()
        
        -- NOVOS: Controles de movimento para frente e lados (W,A,S,D)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + Vector3.new(0, 0, -1)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir + Vector3.new(0, 0, 1)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir + Vector3.new(-1, 0, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + Vector3.new(1, 0, 0)
        end
        
        -- NOVOS: Controles de subir e descer (E/Q)
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            moveDir = moveDir + Vector3.new(0, -1, 0)
        end

        local currentSpeed = speed
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            currentSpeed = speed + boostSpeed
        end

        -- Aplica velocidade
        local velocity = cam:VectorToWorldSpace(moveDir) * currentSpeed
        bodyVelocity.Velocity = velocity

        -- Noclip
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function disableFly()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
        
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            if bodyVelocity then
                bodyVelocity:Destroy()
                bodyVelocity = nil
            end
            if bodyGyro then
                bodyGyro:Destroy()
                bodyGyro = nil
            end
        end
        
        -- Reativa colisões
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

local Tab = Window:MakeTab({
    Name = "🙍Self",
    Icon = "rbxassetid://",
    PremiumOnly = false
})


OrionLib:MakeNotification({
    Name = "Japa Menu V3",
    Content = "Menu injetado Com Sucesso!",
    Image = "rbxassetid://4483345998",
    Time = 5
})

local WallTab = Window:MakeTab({
    Name = "👁️Visuals",
    Icon = "rbxassetid://",
    PremiumOnly = false
})

local Section = WallTab:AddSection({
    Name = "Esp"
})

local AimbotTab = Window:MakeTab({
    Name = "🔫Aimbot",
    Icon = "",
    PremiumOnly = false
})

local Section = AimbotTab:AddSection({
    Name = "Aimbot"
})

local Section = Tab:AddSection({
    Name = "Self"
})

-- Adicionar no início com as outras variáveis
local spectatingPlayer = nil
local spectateEnabled = false
local spectateDistance = 10
local spectateConnection = nil
local spectateRotation = 0
local baseSpectateOffset = Vector3.new(0, 0, 0) -- Offset base dentro da cabeça


-- Nova aba Players
local PlayersTab = Window:MakeTab({
    Name = "👪Players",
    Icon = "rbxassetid://",
    PremiumOnly = false
})

-- Adicionar no início com as outras variáveis
local spectatingPlayer = nil
local spectateEnabled = false
local spectateDistance = 10
local spectateConnection = nil
local selectedPlayer = nil
local spectateMouseConnection = nil
local originalCameraType = Enum.CameraType.Custom

-- Container para os elementos dinâmicos
local playerListContainer = {}

-- Função para atualizar a lista de jogadores
local function UpdatePlayerList()
    -- Limpar apenas os elementos da lista
    for _, v in ipairs(playerListContainer) do
        v:Destroy()
    end
    playerListContainer = {}

    -- Obter jogadores (exceto o local) e ordenar por nome
    local players = {}
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            table.insert(players, player)
        end
    end
    table.sort(players, function(a, b)
        return a.Name:lower() < b.Name:lower()
    end)

    -- Criar botões ordenados
    for _, player in ipairs(players) do
        local btn = PlayersTab:AddButton({
            Name = player.Name,
            Callback = function()
                selectedPlayer = player
                SpectatePlayer() -- <== ADICIONE ISSO AQUI
                OrionLib:MakeNotification({
                    Name = "Japa Menu",
                    Content = "Selecionado: "..player.Name,
                    Image = "rbxassetid://4483345998",
                    Time = 2
                })
            end
        })
        table.insert(playerListContainer, btn)
    end
end

-- Função para espectar o jogador (substituir a anterior)
local function SpectatePlayer()
    if spectateConnection then
        spectateConnection:Disconnect()
    end
    
    spectateConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if spectateEnabled and selectedPlayer and selectedPlayer.Character then
            local targetChar = selectedPlayer.Character
            local head = targetChar:FindFirstChild("Head")
            local root = targetChar:FindFirstChild("HumanoidRootPart")
            
            if head and root then
                -- Calcula a direção da câmera com rotação
                local cameraDirection = CFrame.Angles(0, math.rad(spectateRotation), 0)
                
                -- Offset base + distância
                local offset = cameraDirection * CFrame.new(0, 0, -spectateDistance)
                
                -- Posição final da câmera
                local cameraPos = head.CFrame:ToWorldSpace(offset).Position
                
                -- Mantém o foco na cabeça
                workspace.CurrentCamera.CFrame = CFrame.new(cameraPos, head.Position)
            end
        end
    end)
end

-- Adicione esta nova versão:
local qDown = false
local eDown = false
local rotationSpeed = 2 -- Ajuste a velocidade conforme necessário

UserInputService.InputBegan:Connect(function(input)
    if spectateEnabled then
        if input.KeyCode == Enum.KeyCode.Q then
            qDown = true
        elseif input.KeyCode == Enum.KeyCode.E then
            eDown = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        qDown = false
    elseif input.KeyCode == Enum.KeyCode.E then
        eDown = false
    end
end)

RunService.RenderStepped:Connect(function(deltaTime)
    if spectateEnabled then
        if qDown then
            spectateRotation = spectateRotation - (rotationSpeed * deltaTime * 60)
        end
        if eDown then
            spectateRotation = spectateRotation + (rotationSpeed * deltaTime * 60)
        end
    end
end)

local Section = PlayersTab:AddSection({
    Name = "opções"
})

PlayersTab:AddButton({
    Name = "Teleportar para Player",
    Callback = function()
        if selectedPlayer and selectedPlayer.Character then
            local targetPos = selectedPlayer.Character.HumanoidRootPart.Position
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        end
    end
})

-- Variável que controla o estado do teleporte em loop
local tpCheckboxChecked = false
local puxarCheckboxEnabled = false -- NOVO: Variável para o puxar instantâneo
local arrastarCheckboxEnabled = false -- NOVO: Variável para o arrastar suave
local puxarLoopConnection = nil
local arrastarLoopConnection = nil


-- NOVO: Função para o teleporte em loop do seu jogador para o player selecionado (em 0.01s)
local function teleportLoop_PlayerToMe()
    while true do
        if tpCheckboxChecked then
            if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = selectedPlayer.Character.HumanoidRootPart.Position
                -- Teleporte instantâneo para você (0.01 segundos)
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
            end
        end
        task.wait(0.01)
    end
end

-- NOVA FUNÇÃO: Arrastar Player (suave)
local function arrastarPlayerLoop()
    while arrastarCheckboxEnabled do
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = selectedPlayer.Character.HumanoidRootPart
            local myHRP = game.Players.LocalPlayer.Character.HumanoidRootPart
            
            -- Teleporte mais lento e suave para o player (0.5 segundos)
            local startPos = targetHRP.Position
            local endPos = myHRP.Position + Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))
            
            local startTime = tick()
            local duration = 0.5
            while (tick() - startTime) < duration do
                local alpha = (tick() - startTime) / duration
                if targetHRP and targetHRP.Parent and targetHRP.Anchored then
                    targetHRP.CFrame = CFrame.new(startPos:Lerp(endPos, alpha))
                end
                task.wait() -- Espera o próximo frame
            end
            
            targetHRP.CFrame = CFrame.new(endPos)
            targetHRP.Anchored = true
        end
        task.wait(0.5) -- Espera 0.5 segundos para a próxima puxada
    end
    
    -- Desancora o player quando a checkbox é desativada
    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        selectedPlayer.Character.HumanoidRootPart.Anchored = false
    end
end

-- NOVA FUNÇÃO: Puxar Player (antiga, instantânea)
local function puxarPlayerLoop()
    while puxarCheckboxEnabled do
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = selectedPlayer.Character.HumanoidRootPart
            local myHRP = game.Players.LocalPlayer.Character.HumanoidRootPart
            
            -- Puxa o player para a sua posição com um pequeno offset aleatório
            targetHRP.CFrame = myHRP.CFrame * CFrame.new(math.random(-2, 2), 0, math.random(-2, 2))
            targetHRP.Anchored = true -- Ancora o player para que ele não fuja
        end
        task.wait()
    end
    
    -- Desancora o player quando a checkbox é desativada
    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        selectedPlayer.Character.HumanoidRootPart.Anchored = false
    end
end

-- Adicionando o toggle para o teleporte em loop
PlayersTab:AddToggle({
    Name = "Teleporte ( Loop )",
    Default = false,
    Callback = function(value)
        tpCheckboxChecked = value
        if value then
            spawn(teleportLoop_PlayerToMe)
        end
    end
})

-- Adicionando o toggle para Arrastar o player (o teleporte suave)
PlayersTab:AddToggle({
    Name = "Arrastar Player ( Loop )",
    Default = false,
    Callback = function(value)
        arrastarCheckboxEnabled = value
        if value then
            if puxarLoopConnection then
                puxarLoopConnection:Disconnect()
                puxarLoopConnection = nil
            end
            arrastarLoopConnection = game:GetService("RunService").Heartbeat:Connect(arrastarPlayerLoop)
        else
            if arrastarLoopConnection then
                arrastarLoopConnection:Disconnect()
                arrastarLoopConnection = nil
            end
        end
    end
})

-- Adicionando o toggle para Puxar o player (o teleporte instantâneo)
PlayersTab:AddToggle({
    Name = "Puxar Player ( Loop )",
    Default = false,
    Callback = function(value)
        puxarCheckboxEnabled = value
        if value then
            if arrastarLoopConnection then
                arrastarLoopConnection:Disconnect()
                arrastarLoopConnection = nil
            end
            puxarLoopConnection = game:GetService("RunService").Heartbeat:Connect(puxarPlayerLoop)
        else
            if puxarLoopConnection then
                puxarLoopConnection:Disconnect()
                puxarLoopConnection = nil
            end
        end
    end
})

-- Atualizar o toggle de espectar
PlayersTab:AddToggle({
    Name = "Espectar Player",
    Default = false,
    Callback = function(value)
        spectateEnabled = value
        if value and selectedPlayer then
            workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
            SpectatePlayer()
        else
            if spectateConnection then
                spectateConnection:Disconnect()
            end
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            spectateRotation = 0 -- Resetar rotação
        end
    end
})

-- Atualizar o slider na UI
PlayersTab:AddSlider({
    Name = "Distância da Câmera",
    Min = 0, -- 0 = Dentro da cabeça
    Max = 50,
    Default = 10,
    Color = Color3.fromRGB(119, 18, 169),
    Increment = 1,
    ValueName = "Metros",
    Callback = function(value)
        spectateDistance = value
    end
})


local mainSection = PlayersTab:AddSection({Name = "Lista de Jogadores"})

-- Inicialização
-- Atualização automática quando jogador entra ou sai
game.Players.PlayerAdded:Connect(UpdatePlayerList)
game.Players.PlayerRemoving:Connect(UpdatePlayerList)
UpdatePlayerList()

-- Observador para novos jogadores
game.Players.PlayerAdded:Connect(UpdatePlayerList)
game.Players.PlayerRemoving:Connect(UpdatePlayerList)

local ExploitsTab = Window:MakeTab({
    Name = "💻Exploits",
    Icon = "rbxassetid://",
    PremiumOnly = false
})

local Section = ExploitsTab:AddSection({
    Name = "Freecam"
})

ExploitsTab:AddToggle({
    Name = "Habilitar Keybind (Freecam)",
    Default = false,
    Callback = function(value)
        freecamToggleActive = value
    end
})

ExploitsTab:AddBind({
    Name = "Toggle Freecam",
    Default = Enum.KeyCode.Z,
    Hold = false,
    Callback = function()
        if freecamToggleActive then
            if freecamEnabled then
                disableFreecam()
            else
                enableFreecam()
            end
        end
    end
})

ExploitsTab:AddSlider({
    Name = "Velocidade Freecam",
    Min = 0.5,
    Max = 5,
    Default = 1,
    Increment = 0.5,
    Callback = function(value)
        moveSpeed = value
    end
})

ExploitsTab:AddSlider({
    Name = "Velocidade do Boost (Freecam)",
    Min = 1,
    Max = 10,
    Default = 3.5,
    Increment = 0.5,
    Callback = function(value)
        freecamBoostSpeed = value
    end
})

ExploitsTab:AddSlider({
    Name = "Velocidade X (Mouse)",
    Min = 0.01,
    Max = 2,
    Default = 0.01,
    Increment = 0.01,
    Callback = function(value)
        mouseSpeedX = value
    end
})

ExploitsTab:AddSlider({
    Name = "Velocidade Y (Mouse)",
    Min = 0.01,
    Max = 2,
    Default = 0.01,
    Increment = 0.01,
    Callback = function(value)
        mouseSpeedY = value
    end
})

-- Seções da aba Exploits
local sectionVoice = ExploitsTab:AddSection({ Name = "Voice" })

-- Botão: Voltar Ao Voice
ExploitsTab:AddButton({
    Name = "Voltar Ao Voice",
    Callback = function()
        local vci = cloneref and cloneref(game:GetService("VoiceChatInternal"))
        local vcs = cloneref and cloneref(game:GetService("VoiceChatService"))

        if vci and vcs then
            local success, err = pcall(function()
                vci:Leave()
                task.wait(0.2)
                vcs:rejoinVoice()
                vcs:joinVoice()
            end)

            if success then
                print("✅ Voice reconectado com sucesso.")
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Voice Chat",
                    Text = "Reconectado com sucesso!",
                    Duration = 3
                })
            else
                warn("❌ Erro ao reconectar:", err)
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Voice Chat",
                    Text = "Erro ao reconectar.",
                    Duration = 3
                    
                    })
        end
        else
            print("❌ VoiceChatService não disponível neste jogo.")
            game.StarterGui:SetCore("SendNotification", {
                Title = "Voice Chat",
                Text = "VoiceChatService indisponível.",
                Duration = 3
                
                })
        end
    end
})


local sectionPuxar = ExploitsTab:AddSection({ Name = "Puxar Players" })

-- Funções auxiliares
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local function safeExecute(func)
    local success, result = pcall(func)
    if not success then
        warn("Erro: " .. result)
    end
end

local function teleportAllPlayers()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local otherHRP = player.Character.HumanoidRootPart
            otherHRP.Anchored = true
            otherHRP.CanCollide = false
            otherHRP.CFrame = hrp.CFrame * CFrame.new(math.random(-5,5), 0, math.random(-5,5))
        end
    end
end

local function unanchorAllPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            hrp.Anchored = false
            hrp.CanCollide = true
        end
    end
end

-- Botão: Puxar jogadores
ExploitsTab:AddButton({
    Name = "Puxar Todos os Jogadores",
    Callback = function()
        safeExecute(teleportAllPlayers)
        print("Jogadores puxados para perto.")
    end
})

-- Botão: Destravar jogadores
ExploitsTab:AddButton({
    Name = "Destravar Jogadores",
    Callback = function()
        safeExecute(unanchorAllPlayers)
        print("Jogadores destravados.")
    end
})

-- Toggle (checkbox) para puxar em loop
local puxarLoopAtivado = false

ExploitsTab:AddToggle({
    Name = "Puxar Players ( Loop )",
    Default = false,
    Callback = function(state)
        puxarLoopAtivado = state
    end
})

-- Loop que roda em background
spawn(function()
    while true do
        if puxarLoopAtivado then
            safeExecute(teleportAllPlayers)
        end
        wait(3) -- tempo entre puxadas (ajuste se quiser mais rápido ou mais lento)
    end
end)


local ConfigTab = Window:MakeTab({
    Name = "⚙️Misc",
    Icon = "rbxassetid://",
    PremiumOnly = false
})

local Section = ConfigTab:AddSection({
    Name = "Configurações"
})

local mouseLocked = false
local UIS = game:GetService("UserInputService")

-- Começa destravado
UIS.MouseBehavior = Enum.MouseBehavior.Default
UIS.MouseIconEnabled = true

-- Tira da primeira pessoa
local function resetCamera()
    local camera = workspace.CurrentCamera
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        camera.CameraSubject = player.Character:FindFirstChild("Humanoid")
        camera.CameraType = Enum.CameraType.Custom
        camera.CFrame = camera.CFrame * CFrame.new(0, 0, 3)
    end
end

-- Travar/destravar o mouse
local function toggleMouseLock()
    mouseLocked = not mouseLocked
    if mouseLocked then
        UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
        UIS.MouseIconEnabled = false
    else
        UIS.MouseBehavior = Enum.MouseBehavior.Default
        UIS.MouseIconEnabled = true
        resetCamera()
    end
end

-- Removido: InputBegan com lockKey

-- Bind configurável
ConfigTab:AddBind({
    Name = "Travar/Destravar O Mouse",
    Default = Enum.KeyCode.V,
    Hold = false,
    Callback = function()
        toggleMouseLock()
    end
})

local shadersAtivos = false
local lighting = game:GetService("Lighting")

ConfigTab:AddToggle({
    Name = "Ativar Shaders",
    Default = false,
    Callback = function(estado)
        shadersAtivos = estado

        if estado then
            -- Color Correction (suave e sem laranja)
            local cc = Instance.new("ColorCorrectionEffect", lighting)
            cc.Name = "JapaColor"
            cc.Brightness = 0.05
            cc.Contrast = 0.2
            cc.Saturation = 0.3
            cc.TintColor = Color3.fromRGB(240, 240, 255) -- Azul claro levemente frio

            -- Bloom (brilho suave)
            local bloom = Instance.new("BloomEffect", lighting)
            bloom.Name = "JapaBloom"
            bloom.Intensity = 0.25
            bloom.Threshold = 0.8
            bloom.Size = 64

            -- Depth of Field (foco de câmera)
            local dof = Instance.new("DepthOfFieldEffect", lighting)
            dof.Name = "JapaDOF"
            dof.FarIntensity = 0.2
            dof.FocusDistance = 35
            dof.InFocusRadius = 50
            dof.NearIntensity = 0.1

            -- Luz ambiente refinada
            lighting.Ambient = Color3.fromRGB(100, 100, 120)
            lighting.OutdoorAmbient = Color3.fromRGB(130, 130, 145)
            lighting.Brightness = 3

            print("✨ Shaders estilosos ativados.")
        else
            -- Remover efeitos
            for _, name in ipairs({"JapaColor", "JapaBloom", "JapaDOF"}) do
                local e = lighting:FindFirstChild(name)
                if e then e:Destroy() end
            end

            -- Restaurar iluminação padrão
            lighting.Ambient = Color3.fromRGB(127, 127, 127)
            lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
            lighting.Brightness = 2

            print("❌ Shaders desativados.")
        end
    end
})

ConfigTab:AddButton({
    Name = "Reiniciar Script",
    Callback = function()
        loadstring(game:HttpGet(('https://raw.githubusercontent.com/Stand-Software/Stand-Menu-3.4/refs/heads/main/README.md')))() 
    end
})

ConfigTab:AddButton({
    Name = "Voltar Ao Menu Principal",
    Callback = function()
        loadstring(game:HttpGet(('https://raw.githubusercontent.com/Stand-Software/Stand-Menu/refs/heads/main/README.md')))() 
    end
})

Tab:AddToggle({
    Name = "Voar",
    Default = false,
    Callback = function(Value)
        flyEnabled = Value
        if not flyEnabled then
            isFlying = false
            disableFly()
        end
    end    
})

Tab:AddBind({
    Name = "Bind Voar",
    Default = Enum.KeyCode.CapsLock,
    Hold = false,
    Callback = function()
        if flyEnabled then
            isFlying = not isFlying
            if isFlying then
                enableFly()
            else
                disableFly()
            end
        end
    end    
})

Tab:AddSlider({
    Name = "Velocidade",
    Min = 20,
    Max = 500,
    Default = 20,
    Color = Color3.fromRGB(119, 18, 169),
    Increment = 1,
    ValueName = "Velocidade",
    Callback = function(Value)
        speed = Value
    end    
})

Tab:AddSlider({
    Name = "Velocidade do Shift",
    Min = 100,
    Max = 1000,
    Default = 350,
    Color = Color3.fromRGB(119, 18, 169),
    Increment = 1,
    ValueName = "Velocidade",
    Callback = function(value)
        boostSpeed = value
    end
})

local sectionVoice = Tab:AddSection({ Name = "Teleport Forward" })

-- Função de teleporte para frente
local function teleportForward()
    local player = game:GetService("Players").LocalPlayer
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local lookVector = hrp.CFrame.LookVector
    local distance = 5
    hrp.CFrame = hrp.CFrame + (lookVector * distance)
end

Tab:AddButton({
    Name = "Teleport Forward",
    Callback = teleportForward
})

local sectionVoice = Tab:AddSection({ Name = "Pulos Infinitos" })

-- Infinite Jump lógica
local infiniteJumpEnabled = false
local UserInputService = game:GetService("UserInputService")

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local player = game:GetService("Players").LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Checkbox para ativar/desativar pulo infinito
Tab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(state)
        infiniteJumpEnabled = state
    end
})

-- Funções para ESP
local function esp(enabled)
    if not enabled then
        if game:GetService("CoreGui"):FindFirstChild("Highlight_Storage") then
            game:GetService("CoreGui").Highlight_Storage:Destroy()
        end
        return
    end

    local FillColor = chamFillColor
    local OutlineColor = chamOutlineColor
    local DepthMode = "AlwaysOnTop"
    local FillTransparency = 0.5
    local OutlineTransparency = 0

    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local connections = {}

    local Storage = Instance.new("Folder")
    Storage.Parent = CoreGui
    Storage.Name = "Highlight_Storage"

    local function Highlight(plr)
        local Highlight = Instance.new("Highlight")
        Highlight.Name = plr.Name
        Highlight.FillColor = FillColor
        Highlight.DepthMode = DepthMode
        Highlight.FillTransparency = FillTransparency
        Highlight.OutlineColor = OutlineColor
        Highlight.OutlineTransparency = OutlineTransparency
        Highlight.Parent = Storage
        
        local plrchar = plr.Character
        if plrchar then
            Highlight.Adornee = plrchar
        end

        connections[plr] = plr.CharacterAdded:Connect(function(char)
            Highlight.Adornee = char
        end)
    end

    Players.PlayerAdded:Connect(Highlight)
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= lp then
            Highlight(v)
        end
    end

    Players.PlayerRemoving:Connect(function(plr)
        local plrname = plr.Name
        if Storage:FindFirstChild(plrname) then
            Storage[plrname]:Destroy()
        end
        if connections[plr] then
            connections[plr]:Disconnect()
        end
    end)
end


-- Corrigir os Toggles
WallTab:AddToggle({
    Name = "Nametags",
    Default = false,
    Callback = function(Value)
        ToggleNameTags(Value) -- Corrigido para usar Value
    end
})

WallTab:AddToggle({
    Name = "Box",
    Default = false,
    Callback = function(Value)
        ToggleBoxESP(Value) -- Corrigido para usar Value
    end
})

-- Adicione estas variáveis no início do script com as outras configurações
local DistanceLineEnabled = false
local SkeletonEnabled = false
local HeadCircleEnabled = false
local DistanceTextEnabled = false
local ESPAdvancedColor = Color3.new(1, 1, 1)
local ESPAdvancedData = {
    Skeletons = {},
    HeadCircles = {},
    DistanceLines = {},
    DistanceTexts = {}
}

-- Variáveis para a nova função de barra de vida
local HealthBarEnabled = false
local HealthBarData = {}
local localPlayerEspEnabled = false

-- Funções de criação dos elementos -----------------------------------------------------------------
local function createSkeleton(player)
    -- Mapeamento para R15
    local r15Parts = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
    }
    -- Mapeamento para R6 (corrigido)
    local r6Parts = {
        {"Head", "Torso"},
        {"Torso", "Left Arm"},
        {"Torso", "Right Arm"},
        {"Torso", "Left Leg"},
        {"Torso", "Right Leg"},
        -- Para conectar as pernas ao tronco
        {"Left Leg", "Right Leg"} 
    }

    local skeleton = {}
    local character = player.Character

    -- Verifica se o boneco é R6 (procurando por 'Torso' e 'Left Leg')
    if character and character:FindFirstChild("Torso") and character:FindFirstChild("Left Leg") then
        for _, pair in ipairs(r6Parts) do
            local part1 = character:FindFirstChild(pair[1])
            local part2 = character:FindFirstChild(pair[2])
            if part1 and part2 then
                local line = Drawing.new("Line")
                line.Thickness = 1
                line.Color = ESPAdvancedColor
                line.Visible = false
                skeleton[pair[1].."-"..pair[2]] = line
            end
        end
    else -- Senão, assume que é R15
        for _, pair in ipairs(r15Parts) do
            local part1 = character:FindFirstChild(pair[1])
            local part2 = character:FindFirstChild(pair[2])
            if part1 and part2 then
                local line = Drawing.new("Line")
                line.Thickness = 1
                line.Color = ESPAdvancedColor
                line.Visible = false
                skeleton[pair[1].."-"..pair[2]] = line
            end
        end
    end
    
    return skeleton
end

local function createHeadCircle()
    local circle = Drawing.new("Circle")
    circle.Visible = false
    circle.Color = ESPAdvancedColor
    circle.Thickness = 2
    circle.Radius = 8
    circle.Filled = false
    return circle
end

local function createDistanceLine()
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = ESPAdvancedColor
    line.Thickness = 1
    return line
end

local function createDistanceText()
    local text = Drawing.new("Text")
    text.Visible = false
    text.Color = ESPAdvancedColor
    text.Size = 14
    text.Outline = true
    return text
end

local function createHealthBar(player)
    local background = Drawing.new("Square")
    background.Color = Color3.fromRGB(0, 0, 0)
    background.Thickness = 1
    background.Visible = false
    background.Filled = true
    
    local bar = Drawing.new("Square")
    bar.Color = Color3.fromRGB(0, 255, 0)
    bar.Thickness = 1
    bar.Visible = false
    bar.Filled = true

    local text = Drawing.new("Text")
    text.Color = Color3.fromRGB(255, 255, 255)
    text.Size = 12
    text.Visible = false

    return {background = background, bar = bar, text = text}
end

-- Funções de atualização ---------------------------------------------------------------------------
local function updateSkeleton(player)
    local character = player.Character
    if not character or not ESPAdvancedData.Skeletons[player] then return end

    -- Mapeamento para R15
    local r15Parts = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
    }
    -- Mapeamento para R6 (corrigido)
    local r6Parts = {
        {"Head", "Torso"},
        {"Torso", "Left Arm"},
        {"Torso", "Right Arm"},
        {"Torso", "Left Leg"},
        {"Torso", "Right Leg"},
        {"Left Leg", "Right Leg"}
    }
    
    -- Verifica se o boneco é R6
    local partsToDraw = {}
    if character:FindFirstChild("Torso") and character:FindFirstChild("Left Leg") then
        partsToDraw = r6Parts
    else
        partsToDraw = r15Parts
    end
    
    for _, pair in ipairs(partsToDraw) do
        local part1 = character:FindFirstChild(pair[1]) -- Não remove mais os espaços
        local part2 = character:FindFirstChild(pair[2]) -- Não remove mais os espaços
        local line = ESPAdvancedData.Skeletons[player][pair[1].."-"..pair[2]]
        
        if part1 and part2 and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and line then
            local distance = (part1.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance <= espDistance then
                local pos1 = Camera:WorldToViewportPoint(part1.Position)
                local pos2 = Camera:WorldToViewportPoint(part2.Position)

                line.Visible = SkeletonEnabled and pos1.Z > 0 and pos2.Z > 0
                line.From = Vector2.new(pos1.X, pos1.Y)
                line.To = Vector2.new(pos2.X, pos2.Y)
            else
                line.Visible = false
            end
        elseif line then
            line.Visible = false
        end
    end
end

local function updateHeadCircle(player)
    local character = player.Character
    if not character or not ESPAdvancedData.HeadCircles[player] or not LocalPlayer.Character then return end

    local head = character:FindFirstChild("Head")
    local localHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if head and localHRP then
        local pos = Camera:WorldToViewportPoint(head.Position)
        local distance = (head.Position - localHRP.Position).Magnitude
        local circle = ESPAdvancedData.HeadCircles[player]
        circle.Visible = HeadCircleEnabled and pos.Z > 0 and distance <= espDistance
        circle.Position = Vector2.new(pos.X, pos.Y)
    end
end

local function updateDistanceElements(player)
    local character = player.Character
    local localChar = LocalPlayer.Character
    if not character or not localChar then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("LowerTorso")
    local localRoot = localChar:FindFirstChild("HumanoidRootPart") or localChar:FindFirstChild("LowerTorso")
    
    if rootPart and localRoot then
        local distance = (rootPart.Position - localRoot.Position).Magnitude

        local line = ESPAdvancedData.DistanceLines[player]
        local text = ESPAdvancedData.DistanceTexts[player]

        if distance > espDistance then
            if line then line.Visible = false end
            if text then text.Visible = false end
            return
        end

        local enemyPos = Camera:WorldToViewportPoint(rootPart.Position)
        local playerPos = Camera:WorldToViewportPoint(localRoot.Position)

        if line then
            line.Visible = DistanceLineEnabled and enemyPos.Z > 0 and playerPos.Z > 0
            if line.Visible then
                line.From = Vector2.new(playerPos.X, playerPos.Y)
                line.To = Vector2.new(enemyPos.X, enemyPos.Y)
            end
        end

        if text then
            text.Visible = DistanceTextEnabled and enemyPos.Z > 0
            text.Position = Vector2.new(enemyPos.X, enemyPos.Y + 15)
            text.Text = string.format("[%.1fm]", distance)
        end
    end
end

local function updateHealthBar(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local healthBarElements = HealthBarData[player]

    if not HealthBarEnabled or not humanoid or not rootPart or not healthBarElements or (not localPlayerEspEnabled and player == plr) then
        if healthBarElements then
            healthBarElements.background.Visible = false
            healthBarElements.bar.Visible = false
            healthBarElements.text.Visible = false
        end
        return
    end

    local distance = (rootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
    local viewportPoint, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

    if onScreen and distance <= espDistance then
        -- A barra de vida agora é calculada independentemente da box
        local viewportPoint = Camera:WorldToViewportPoint(rootPart.Position)
        local boxSizeY = 2000 / viewportPoint.Z 
        local barWidth = 5
        local barX = viewportPoint.X - boxSizeY / 4 -- Posição horizontal à esquerda, proporcional
        local barY = viewportPoint.Y - boxSizeY / 2
        
        local healthPercentage = humanoid.Health / humanoid.MaxHealth
        local barHeight = boxSizeY * healthPercentage

        -- Atualiza o fundo da barra de vida
        healthBarElements.background.Size = Vector2.new(barWidth, boxSizeY)
        healthBarElements.background.Position = Vector2.new(barX, barY)
        healthBarElements.background.Visible = true

        -- Atualiza a barra de vida
        healthBarElements.bar.Size = Vector2.new(barWidth, barHeight)
        healthBarElements.bar.Position = Vector2.new(barX, barY + (boxSizeY - barHeight))
        healthBarElements.bar.Visible = true

        -- Move o texto da vida para a esquerda
        healthBarElements.text.Text = math.floor(humanoid.Health + 0.5) .. "/" .. humanoid.MaxHealth
        healthBarElements.text.Position = Vector2.new(barX - 45, barY + boxSizeY / 2)
        healthBarElements.text.Visible = true

        -- Reajusta a cor da barra de vida com base na vida
        if humanoid.Health < (humanoid.MaxHealth / 4) then
            healthBarElements.bar.Color = Color3.fromRGB(255, 0, 0) -- Vermelho
        elseif humanoid.Health < (humanoid.MaxHealth / 2) then
            healthBarElements.bar.Color = Color3.fromRGB(255, 255, 0) -- Amarelo
        else
            healthBarElements.bar.Color = Color3.fromRGB(0, 255, 0) -- Verde
        end
    else
        healthBarElements.background.Visible = false
        healthBarElements.bar.Visible = false
        healthBarElements.text.Visible = false
    end
end


-- Loop principal de atualização --------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if localPlayerEspEnabled or player ~= LocalPlayer then
            local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                -- Updates for Box and Nametags
                if ESPObjects[player] then
                    UpdateBox(ESPObjects[player], rootPart)
                end
                if NameTags[player] then
                    UpdateNameTag(NameTags[player], player)
                end
            end
            -- Updates for Advanced ESP
            updateSkeleton(player)
            updateHeadCircle(player)
            updateDistanceElements(player)
        end
        -- A barra de vida agora é sempre atualizada se estiver ativada, independentemente de outras opções
        updateHealthBar(player)
    end
end)

-- Gerenciamento de jogadores -----------------------------------------------------------------------
local function addPlayer(player)
    -- ESPObjects e NameTags
    if not ESPObjects[player] then
        CreateBox(player)
    end
    if not NameTags[player] then
        CreateNameTag(player)
    end

    -- ESP Avançado
    ESPAdvancedData.Skeletons[player] = createSkeleton(player)
    ESPAdvancedData.HeadCircles[player] = createHeadCircle()
    ESPAdvancedData.DistanceLines[player] = createDistanceLine()
    ESPAdvancedData.DistanceTexts[player] = createDistanceText()
    
    -- Nova barra de vida
    HealthBarData[player] = createHealthBar(player)
end

local function removePlayer(player)
    -- Remove ESPObjects e NameTags
    if ESPObjects[player] and ESPObjects[player]:IsA("Drawing") then
        ESPObjects[player]:Remove()
    end
    ESPObjects[player] = nil
    
    if NameTags[player] and NameTags[player]:IsA("Drawing") then
        NameTags[player]:Remove()
    end
    NameTags[player] = nil

    -- Remove ESP Avançado
    for elementType, data in pairs(ESPAdvancedData) do
        if data[player] then
            if elementType == "Skeletons" then
                for _, line in pairs(data[player]) do
                    if line and line:IsA("Drawing") then
                        line:Remove()
                    end
                end
            else
                if data[player] and data[player]:IsA("Drawing") then
                    data[player]:Remove()
                end
            end
            data[player] = nil
        end
    end

    -- Remove barra de vida
    if HealthBarData[player] then
        HealthBarData[player].background:Remove()
        HealthBarData[player].bar:Remove()
        HealthBarData[player].text:Remove()
    end
    HealthBarData[player] = nil
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        addPlayer(player)
    end)
end)

Players.PlayerRemoving:Connect(removePlayer)

-- Loop de verificação de jogadores para evitar bugs e jogadores que se reconectam
spawn(function()
    while task.wait(2) do
        if BoxESPEnabled or NameTagsEnabled or DistanceLineEnabled or SkeletonEnabled or HeadCircleEnabled or DistanceTextEnabled or HealthBarEnabled or localPlayerEspEnabled then
            -- Verificação para adicionar novos jogadores ou jogadores que se reconectaram
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer or localPlayerEspEnabled then
                    if not ESPObjects[player] then
                        addPlayer(player)
                    end
                end
            end

            -- Verificação para remover jogadores que saíram
            local playersInMap = {}
            for _, player in ipairs(Players:GetPlayers()) do
                playersInMap[player] = true
            end
            
            for player, _ in pairs(ESPObjects) do
                if not playersInMap[player] then
                    removePlayer(player)
                end
            end
            for player, _ in pairs(NameTags) do
                if not playersInMap[player] then
                    removePlayer(player)
                end
            end
            for player, _ in pairs(ESPAdvancedData.Skeletons) do
                if not playersInMap[player] then
                    removePlayer(player)
                end
            end
            for player, _ in pairs(HealthBarData) do
                if not playersInMap[player] then
                    removePlayer(player)
                end
            end
        end
    end
end)

-- UI (WallTab) --------------------------------------------------------------------------------------
WallTab:AddToggle({
    Name = "Head",
    Default = false,
    Callback = function(state)
        HeadCircleEnabled = state
    end
})

WallTab:AddToggle({
    Name = "Skeleton",
    Default = false,
    Callback = function(state)
        SkeletonEnabled = state
    end
})

WallTab:AddToggle({
    Name = "Lines",
    Default = false,
    Callback = function(state)
        DistanceLineEnabled = state
    end
})

WallTab:AddToggle({
    Name = "Distance",
    Default = false,
    Callback = function(state)
        DistanceTextEnabled = state
    end
})

WallTab:AddToggle({
    Name = "Barra de Vida",
    Default = false,
    Callback = function(state)
        HealthBarEnabled = state
    end
})

local localPlayerSection = WallTab:AddSection({
    Name = "Localplayer"
})

localPlayerSection:AddToggle({
    Name = "Localplayer",
    Default = false,
    Callback = function(state)
        localPlayerEspEnabled = state
        if state then
            addPlayer(plr)
        else
            removePlayer(plr) -- Remove o ESP do seu jogador se a opção for desativada
        end
    end
})

WallTab:AddSlider({
    Name = "Tamanho das Nametags",
    Min = 10,
    Max = 35,
    Default = 15,
    Color = Color3.fromRGB(119, 18, 169),
    Increment = 1,
    ValueName = "Tamanho",
    Callback = function(Value)
        nameTagSize = Value
        for _, nametag in pairs(NameTags) do
            nametag.Size = Value
        end
    end
})

WallTab:AddSlider({
    Name = "Tamanho do Texto de Distância",
    Min = 10,
    Max = 35,
    Default = 14,
    Color = Color3.fromRGB(119, 18, 169),
    Increment = 1,
    ValueName = "Tamanho",
    Callback = function(Value)
        for _, text in pairs(ESPAdvancedData.DistanceTexts) do
            text.Size = Value
        end
    end
})

WallTab:AddSlider({
    Name = "Distância do ESP",
    Min = 50,
    Max = 1000,
    Default = 500,
    Color = Color3.fromRGB(119, 18, 169),
    Increment = 25,
    ValueName = "Metros",
    Callback = function(value)
        espDistance = value
        aimDistance = value -- Sincroniza a distância do Aimbot
    end
})

WallTab:AddColorpicker({
    Name = "Colors",
    Default = Color3.new(1, 1, 1),
    Callback = function(color)
        ESPAdvancedColor = color
        nameTagColor = color
        boxColor = color
        chamFillColor = color

        for _, nametag in pairs(NameTags) do
            nametag.Color = color
        end

        for _, box in pairs(ESPObjects) do
            box.Color = color
        end

        local highlightStorage = game:GetService("CoreGui"):FindFirstChild("Highlight_Storage")
        if highlightStorage then
            for _, highlight in pairs(highlightStorage:GetChildren()) do
                if highlight:IsA("Highlight") then
                    highlight.FillColor = color
                    highlight.OutlineColor = color
                end
            end
        end

        for _, player in ipairs(Players:GetPlayers()) do
            if ESPAdvancedData.Skeletons[player] then
                for _, line in pairs(ESPAdvancedData.Skeletons[player]) do
                    line.Color = color
                end
            end
            if ESPAdvancedData.HeadCircles[player] then
                ESPAdvancedData.HeadCircles[player].Color = color
            end
            if ESPAdvancedData.DistanceLines[player] then
                ESPAdvancedData.DistanceLines[player].Color = color
            end
            if ESPAdvancedData.DistanceTexts[player] then
                ESPAdvancedData.DistanceTexts[player].Color = color
            end
        end
    end
})

-- Inicialização para jogadores existentes
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        addPlayer(player)
    end
end

-- Corrigir o Toggle do Aimbot
AimbotTab:AddToggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(Value)
        enableAimbot(Value) -- Chamar a função correta
    end
})

-- Na seção AimbotTab, adicione:
AimbotTab:AddBind({
    Name = "Bind Aimbot (Segurar)",
    Default = Enum.KeyCode.Q,
    Hold = true,
    Callback = function(value)
        aimbotHolding = value
    end
})

AimbotTab:AddToggle({
    Name = "Team",
    Default = false,
    Callback = function(state)
        aimbotTeam = state
    end
})

-- Corrigir os Sliders
AimbotTab:AddSlider({
    Name = "Aimbot Fov",
    Min = 50,
    Max = 500,
    Default = 100,
    Color = Color3.fromRGB(119, 18, 169),
    Increment = 1,
    ValueName = "FOV",
    Callback = function(Value)
        fovSize = Value
        updateFovCircle()
    end
})

AimbotTab:AddSlider({
    Name = "Aimbot Distance",
    Min = 50,
    Max = 500,
    Default = 100,
    Color = Color3.fromRGB(119, 18, 169),
    Increment = 1,
    ValueName = "Distance",
    Callback = function(Value)
        aimDistance = Value
    end
})


-- Na seção Aimbot (adicionar após os sliders existentes)
AimbotTab:AddColorpicker({
    Name = "Cor do FOV",
    Default = Color3.new(1, 1, 1),
    Callback = function(Value)
        fovColor = Value
        fovCircle.Color = Value
    end
})

--- Reset ESP
WallTab:AddButton({
    Name = "Resetar ESP",
    Callback = function()
        -- Desliga todas as checkboxes visuais
        BoxESPEnabled = false
        NameTagsEnabled = false
        HeadCircleEnabled = false
        SkeletonEnabled = false
        DistanceLineEnabled = false
        DistanceTextEnabled = false
        HealthBarEnabled = false
        localPlayerEspEnabled = false

        -- Remove todos os desenhos da tela
        for _, drawingObject in pairs(ESPObjects) do
            drawingObject:Remove()
        end
        ESPObjects = {}
        for _, drawingObject in pairs(NameTags) do
            drawingObject:Remove()
        end
        NameTags = {}

        for _, skeleton in pairs(ESPAdvancedData.Skeletons) do
            for _, line in pairs(skeleton) do
                line:Remove()
            end
        end
        ESPAdvancedData.Skeletons = {}
        
        for _, circle in pairs(ESPAdvancedData.HeadCircles) do
            circle:Remove()
        end
        ESPAdvancedData.HeadCircles = {}

        for _, line in pairs(ESPAdvancedData.DistanceLines) do
            line:Remove()
        end
        ESPAdvancedData.DistanceLines = {}
        
        for _, text in pairs(ESPAdvancedData.DistanceTexts) do
            text:Remove()
        end
        ESPAdvancedData.DistanceTexts = {}
        
        for _, healthBar in pairs(HealthBarData) do
            healthBar.background:Remove()
            healthBar.bar:Remove()
            healthBar.text:Remove()
        end
        HealthBarData = {}

        -- Remove qualquer Highlight ESP
        local highlightStorage = game:GetService("CoreGui"):FindFirstChild("Highlight_Storage")
        if highlightStorage then
            highlightStorage:Destroy()
        end
        
        -- Adiciona o ESP novamente para todos os jogadores que já estão no servidor.
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                addPlayer(player)
            end
        end
        
        -- Atualiza a interface do usuário para refletir as mudanças
        OrionLib:MakeNotification({
            Name = "Reset",
            Content = "Todas as funções do ESP foram resetadas!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- Atualizar a função esp para usar as variáveis de cor
function esp(enabled)
    if not enabled then
        if game:GetService("CoreGui"):FindFirstChild("Highlight_Storage") then
            game:GetService("CoreGui").Highlight_Storage:Destroy()
        end
        return
    end

    local FillColor = chamFillColor
    local OutlineColor = chamOutlineColor
    local DepthMode = "AlwaysOnTop"
    local FillTransparency = 0.5
    local OutlineTransparency = 0

    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local connections = {}

    local Storage = Instance.new("Folder")
    Storage.Parent = CoreGui
    Storage.Name = "Highlight_Storage"

    local function Highlight(plr)
        local Highlight = Instance.new("Highlight")
        Highlight.Name = plr.Name
        Highlight.FillColor = FillColor
        Highlight.DepthMode = DepthMode
        Highlight.FillTransparency = FillTransparency
        Highlight.OutlineColor = OutlineColor
        Highlight.OutlineTransparency = OutlineTransparency
        Highlight.Parent = Storage
        
        local plrchar = plr.Character
        if plrchar then
            Highlight.Adornee = plrchar
        end

        connections[plr] = plr.CharacterAdded:Connect(function(char)
            Highlight.Adornee = char
        end)
    end

    Players.PlayerAdded:Connect(Highlight)
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= lp then
            Highlight(v)
        end
    end

    Players.PlayerRemoving:Connect(function(plr)
        local plrname = plr.Name
        if Storage:FindFirstChild(plrname) then
            Storage[plrname]:Destroy()
        end
        if connections[plr] then
            connections[plr]:Disconnect()
        end
    end)
end

-- Atualizar a criação do FOV Circle para usar a variável de cor
fovCircle.Color = fovColor
