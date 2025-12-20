local ArrowsModule = {}
ArrowsModule.Arrows = {}
ArrowsModule.Connections = {}

function ArrowsModule:Enable()
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local RS = game:GetService("RunService")
    
    local V3 = Vector3.new
    local V2 = Vector2.new
    local CF = CFrame.new
    local COS = math.cos
    local SIN = math.sin
    local RAD = math.rad
    local DRAWING = Drawing.new
    local CWRAP = coroutine.wrap
    local ROUND = math.round
    
    local function GetRelative(pos, char)
        if not char then return V2(0,0) end
        local rootP = char.PrimaryPart.Position
        local camP = Camera.CFrame.Position
        local relative = CF(V3(rootP.X, camP.Y, rootP.Z), camP):PointToObjectSpace(pos)
        return V2(relative.X, relative.Z)
    end
    
    local function RelativeToCenter(v)
        return Camera.ViewportSize/2 - v
    end
    
    local function RotateVect(v, a)
        a = RAD(a)
        local x = v.x * COS(a) - v.y * SIN(a)
        local y = v.x * SIN(a) + v.y * COS(a)
        return V2(x, y)
    end
    
    local function DrawTriangle(color)
        local l = DRAWING("Triangle")
        l.Visible = false
        l.Color = color
        l.Filled = true
        l.Thickness = 1
        l.Transparency = 1
        return l
    end
    
    local function AntiA(v)
        return V2(ROUND(v.x), ROUND(v.y))
    end
    
    local function ShowArrow(PLAYER)
        local Arrow = DrawTriangle(Color3.fromRGB(255, 255, 255))
        table.insert(ArrowsModule.Arrows, Arrow)
        
        local function Update()
            local c = RS.RenderStepped:Connect(function()
                if not _G.GUI or not _G.GUI.Library or not _G.GUI.Library.options or not _G.GUI.Library.options.Visuals_Arrows_Enabled or not _G.GUI.Library.options.Visuals_Arrows_Enabled.state then
                    Arrow.Visible = false
                    return
                end
                
                if PLAYER and PLAYER.Character then
                    local CHAR = PLAYER.Character
                    local HUM = CHAR:FindFirstChildOfClass("Humanoid")
                    
                    if HUM and CHAR.PrimaryPart ~= nil and HUM.Health > 0 then
                        local _,vis = Camera:WorldToViewportPoint(CHAR.PrimaryPart.Position)
                        if vis == false then
                            local rel = GetRelative(CHAR.PrimaryPart.Position, Player.Character)
                            local direction = rel.unit
                            
                            local DistFromCenter = _G.GUI.Library.options.Visuals_Arrow_Radius and _G.GUI.Library.options.Visuals_Arrow_Radius.value or 150
                            local TriangleHeight = _G.GUI.Library.options.Visuals_Arrow_Size and _G.GUI.Library.options.Visuals_Arrow_Size.value or 15
                            local TriangleWidth = TriangleHeight
                            
                            local base = direction * DistFromCenter
                            local sideLength = TriangleWidth/2
                            local baseL = base + RotateVect(direction, 90) * sideLength
                            local baseR = base + RotateVect(direction, -90) * sideLength
                            local tip = direction * (DistFromCenter + TriangleHeight)
                            
                            Arrow.PointA = AntiA(RelativeToCenter(baseL))
                            Arrow.PointB = AntiA(RelativeToCenter(baseR))
                            Arrow.PointC = AntiA(RelativeToCenter(tip))
                            Arrow.Visible = true
                        else
                            Arrow.Visible = false
                        end
                    else
                        Arrow.Visible = false
                    end
                else
                    Arrow.Visible = false
                    if not PLAYER or not PLAYER.Parent then
                        Arrow:Remove()
                        c:Disconnect()
                    end
                end
            end)
            table.insert(ArrowsModule.Connections, c)
        end
        CWRAP(Update)()
    end
    
    for _,v in pairs(Players:GetPlayers()) do
        if v ~= Player then
            ShowArrow(v)
        end
    end
    
    local conn = Players.PlayerAdded:Connect(function(v)
        if v ~= Player then
            ShowArrow(v)
        end
    end)
    table.insert(ArrowsModule.Connections, conn)
end

function ArrowsModule:Disable()
    for _, arrow in pairs(self.Arrows) do
        pcall(function() arrow:Remove() end)
    end
    for _, conn in pairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Arrows = {}
    self.Connections = {}
end

return ArrowsModule