                    math.cos(angle) * strafeDistance
                                    )
                                    strafePosition = targetRoot.Position + targetCFrame:VectorToWorldSpace(relativeOffset)
                                end

                                strafePosition = Vector3.new(strafePosition.X, targetHeight, strafePosition.Z)
                                local currentPosition = rootPart.Position
                                local newPosition = currentPosition:Lerp(strafePosition, strafeSpeed * deltaTime)
                                local lookAtPosition = Vector3.new(targetRoot.Position.X, rootPart.Position.Y, targetRoot.Position.Z)
                                local baseCFrame = CFrame.new(newPosition, lookAtPosition)
                                rootPart.CFrame = baseCFrame * CFrame.Angles(0, math.rad(30), 0)
                            end
                        end

                        if currentTime - lastAttackTime >= attackCooldown then
                            local tool = character:FindFirstChildOfClass("Tool")
                            if tool and tool:FindFirstChild("Handle") then
                                local distance = (rootPart.Position - targetRoot.Position).Magnitude
                                if distance <= killAuraRange then
                                    tool:Activate()
                                    lastAttackTime = currentTime
                                end
                            end
                        end

                        lastSelectedTarget = currentTarget
                    else
                        currentTarget = nil
                        lastAttackedTargets = {}
                        lastSelectedTarget = nil
                        highlight.Parent = nil
                        if rootPart:FindFirstChild("BodyVelocity") then
                            rootPart:FindFirstChild("BodyVelocity"):Destroy()
                        end
                    end
                else
                    if rootPart:FindFirstChild("BodyVelocity") then
                        rootPart:FindFirstChild("BodyVelocity"):Destroy()
                    end
                end
            end)
        else
            highlight.Parent = nil
            currentTarget = nil
            lastAttackedTargets = {}
            lastSelectedTarget = nil
            if rootPart and rootPart:FindFirstChild("BodyVelocity") then
                rootPart:FindFirstChild("BodyVelocity"):Destroy()
            end
        end
    end
})

CombatWindow:Toggle({
    Text = "Attack Multiple Targets",
    Default = false,
    Callback = function(state)
        attackMultipleTargets = state
        Players.LocalPlayer:WaitForChild("StarterGui"):SetCore("SendNotification", {
            Title = "Kill Aura",
            Text = "Attack Multiple Targets: " .. (state and "Enabled" or "Disabled"),
            Duration = 3
        })
    end
})

CombatWindow:Slider({
    Text = "Kill Aura Range",
    Minimum = 5,
    Maximum = 50,
    Default = killAuraRange,
    Callback = function(value)
        killAuraRange = value
    end
})

CombatWindow:Slider({
    Text = "Teleport Cooldown",
    Minimum = 0,
    Maximum = 5,
    Default = teleportCooldown,
    Callback = function(value)
        teleportCooldown = value
    end
})

CombatWindow:Slider({
    Text = "Multi-Target Teleport Cooldown",
    Minimum = 0,
    Maximum = 5,
    Default = multiTargetTeleportCooldown,
    Callback = function(value)
        multiTargetTeleportCooldown = value
    end
})

CombatWindow:Keybind({
    Text = "Kill Aura Keybind",
    Default = Enum.KeyCode.R,
    Callback = function()
        killAuraEnabled = not killAuraEnabled
        local player = Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")
        local humanoid = character:WaitForChild("Humanoid")
        local lastAttackedTargets = {}
        local lastSelectedTarget = nil

        if killAuraEnabled then
            local connection
            connection = RunService.Heartbeat:Connect(function(deltaTime)
                if not killAuraEnabled or not character or not rootPart or humanoid.Health <= 0 then
                    highlight.Parent = nil
                    currentTarget = nil
                    lastAttackedTargets = {}
                    lastSelectedTarget = nil
                    if rootPart:FindFirstChild("BodyVelocity") then
                        rootPart:FindFirstChild("BodyVelocity"):Destroy()
                    end
                    connection:Disconnect()
                    return
                end

                local validTargets = {}
                for _, otherPlayer in pairs(Players:GetPlayers()) do
                    if otherPlayer ~= player and not isFriend(otherPlayer) and otherPlayer.Character then
                   