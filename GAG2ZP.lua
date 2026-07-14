local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local RunService       = game:GetService("RunService")
local RS               = game:GetService("ReplicatedStorage")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LP               = Players.LocalPlayer
local PGui             = LP:WaitForChild("PlayerGui")
local blur = Instance.new("BlurEffect", Lighting)

loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/loader/main/ui-main/sffinder.lua"))() -- server finder pets/server/event gw kasi gratis kalo kga mau apus ae

local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local bypassCount = 0

local function SendBypassNotification(isInitial)
    local title = "Anti-AFK Active!"
    local text = "Script is running and ready to bypass the idle kick."
    local duration = 5
    
    if not isInitial then
        title = "AFK Bypass Successful!"
        text = "Idle timer reset. Bypassed " .. bypassCount .. " time" .. (bypassCount ~= 1 and "s" or "") .. "."
        duration = 3
    end
    
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration,
            Button1 = "OK"
        })
    end)
end

SendBypassNotification(true)

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0, 0))
    bypassCount = bypassCount + 1
    SendBypassNotification(false)
end)


local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Networking = require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Networking"))

local isGodMode = false
local isAntiAFK = true

task.spawn(function()
    pcall(function()
        local packetFire = Networking.AntiAfk.RequestHop.Fire
        if hookfunction then
            local oldFire
            oldFire = hookfunction(packetFire, function(self, ...)
                if isAntiAFK and self == Networking.AntiAfk.RequestHop then return end
                if isGodMode and (
                    self == Networking.Bee.Sting or 
                    self == Networking.FlytrapService.Chomp or 
                    self == Networking.GhostPepperService.TouchBegan or 
                    self == Networking.PoisonIvyService.TouchBegan
                ) then 
                    return 
                end
                return oldFire(self, ...)
            end)
        else
            Networking.AntiAfk.RequestHop.Fire = function(self, ...)
                if isAntiAFK then return end
                return packetFire(self, ...)
            end
            Networking.Bee.Sting.Fire = function(self, ...)
                if isGodMode then return end
                return packetFire(self, ...)
            end
            Networking.FlytrapService.Chomp.Fire = function(self, ...)
                if isGodMode then return end
                return packetFire(self, ...)
            end
            Networking.GhostPepperService.TouchBegan.Fire = function(self, ...)
                if isGodMode then return end
                return packetFire(self, ...)
            end
            Networking.PoisonIvyService.TouchBegan.Fire = function(self, ...)
                if isGodMode then return end
                return packetFire(self, ...)
            end
        end
    end)
end)

local moveMethod = "Semi-Tween"
local interactMethod = "Hold Proximity"

local function SmartMove(targetCFrame)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if moveMethod == "Teleport Instant" then
        hrp.CFrame = targetCFrame
        task.wait(0.1)
    else
        local dist = (hrp.Position - targetCFrame.Position).Magnitude
        if dist > 15 then
            local safeSpeed = 130 
            local tweenTime = dist / safeSpeed
            
            local tween = TweenService:Create(hrp, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
            tween:Play()
            
            local conn
            conn = RunService.Heartbeat:Connect(function()
                if hrp and (hrp.Position - targetCFrame.Position).Magnitude <= 15 then
                    tween:Cancel()
                    hrp.CFrame = targetCFrame
                    if conn then conn:Disconnect() end
                end
            end)
            
            tween.Completed:Wait()
            if conn then conn:Disconnect() end
            task.wait(0.1)
        else
            hrp.CFrame = targetCFrame
            task.wait(0.1)
        end
    end
end

local function SmartInteract(prompt)
    if not prompt or not prompt.Parent then return end
    
    if interactMethod == "Instant Proximity" then
        prompt.HoldDuration = 0
        fireproximityprompt(prompt, 0)
        task.wait(0.1)
    else
        local holdTime = prompt.HoldDuration > 0 and prompt.HoldDuration or 0.5
        prompt:InputHoldBegin()
        task.wait(holdTime + 0.1) 
        prompt:InputHoldEnd()
    end
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ZuperMingUI.lua"))()

local MainWindow = Library:CreateWindow({
    Title = "ZUPERMING x NEMESIS",
    SubText = ".gg/zuperming",
    Image = "rbxassetid://76140924722866",
    IsMobile = true
})

local function ExtractGameData(moduleName, key1, key2)
    local extractedList = {}
    pcall(function()
        local moduleScript = ReplicatedStorage.SharedModules:FindFirstChild(moduleName)
        if not moduleScript then return end
        local module = require(moduleScript)

        if moduleName == "CrateData" then
            for _, child in ipairs(moduleScript:GetChildren()) do
                if child:IsA("ModuleScript") and not table.find(extractedList, child.Name) then
                    table.insert(extractedList, child.Name)
                end
            end
            return
        end

        local dataTable = module.Data or module
        for _, item in pairs(dataTable) do
            local name = item[key1] or item[key2]
            if name and type(name) == "string" and not table.find(extractedList, name) then
                table.insert(extractedList, name)
            end
        end
    end)
    table.sort(extractedList)
    if #extractedList == 0 then return {"No Data"} end
    return extractedList
end

local function getFruitWeight(fruitObject)
    for _, desc in ipairs(fruitObject:GetDescendants()) do
        if desc:IsA("TextLabel") and string.lower(desc.Text):match("kg") then
            local weightStr = desc.Text:match("(%d+%.?%d*)")
            if weightStr then return tonumber(weightStr) end
        end
    end
    return nil
end

local function ExtractPets()
    local extractedList = {"All Pets"}
    pcall(function()
        local petFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Pets")
        for _, pet in ipairs(petFolder:GetChildren()) do
            if not table.find(extractedList, pet.Name) then table.insert(extractedList, pet.Name) end
        end
    end)
    table.sort(extractedList)
    return extractedList
end

local function ExtractMutations()
    local extractedList = {"Any", "None"}
    pcall(function()
        local mutFolder = ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("MutationData")
        for _, mut in ipairs(mutFolder:GetChildren()) do
            if mut:IsA("ModuleScript") and not table.find(extractedList, mut.Name) then 
                table.insert(extractedList, mut.Name) 
            end
        end
    end)
    return extractedList
end

local function IsMatch(itemName, itemMutation, targetNames, targetMuts)
    local nameMatch = false
    if table.find(targetNames, "All") then
        nameMatch = true
    else
        for _, n in ipairs(targetNames) do
            if string.lower(n) == string.lower(itemName) then nameMatch = true break end
        end
    end
    
    if not nameMatch then return false end
    if table.find(targetMuts, "Any") then return true end
    
    local actualMut = (itemMutation == nil or itemMutation == "") and "None" or itemMutation
    for _, m in ipairs(targetMuts) do
        if string.lower(m) == string.lower(actualMut) then return true end
    end
    
    return false
end

local function GetPlotOwners()
    local list = {"Anyone"}
    pcall(function()
        local gardens = workspace:FindFirstChild("Gardens")
        if gardens then
            for _, plot in ipairs(gardens:GetChildren()) do
                local ownerId = plot:GetAttribute("OwnerUserId")
                if ownerId then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.UserId == ownerId and p ~= LocalPlayer then
                            if not table.find(list, p.Name) then table.insert(list, p.Name) end
                        end
                    end
                end
            end
        end
    end)
    return list
end

local listPlantsRaw = ExtractGameData("SeedData", "SeedName", "Name")
local listPlants = {"All"}
for _, v in ipairs(listPlantsRaw) do table.insert(listPlants, v) end

local listGears = ExtractGameData("GearShopData", "ItemName", "Name")
local listPacks = ExtractGameData("SeedPackData", "PackName", "Name")
local listCrates = ExtractGameData("CrateData", "", "")
local listEggs = ExtractGameData("EggData", "EggName", "Name")
local listSprinklers = ExtractGameData("SprinklerData", "SprinklerName", "Name")
local listWateringCans = ExtractGameData("WateringcanData", "Name", "ItemName")
local listPets = ExtractPets()
local listMutations = ExtractMutations()

local listAllSeeds = {}
for _, v in ipairs(listPlantsRaw) do table.insert(listAllSeeds, v) end
for _, v in ipairs(listPacks) do 
    if not table.find(listAllSeeds, v) then table.insert(listAllSeeds, v) end 
end
table.sort(listAllSeeds)

local defaultPlant = {"All"}
local defaultMut = {"Any"}
local defaultSprinkler = {listSprinklers[1] or "Basic Sprinkler"}
local defaultWater = {listWateringCans[1] or "Basic Watering Can"}

if listSprinklers[1] == "No Data" then listSprinklers = {"All Sprinklers"} defaultSprinkler = {"All Sprinklers"} end
if listWateringCans[1] == "No Data" then listWateringCans = {"All Watering Cans"} defaultWater = {"All Watering Cans"} end


local FarmTab = MainWindow:AddTab({ Text = "Farming", Icon = "rbxassetid://108020878442937" })
local EconTab = MainWindow:AddTab({ Text = "Economy", Icon = "rbxassetid://108020878442937" })
local MgmtTab = MainWindow:AddTab({ Text = "Storage", Icon = "rbxassetid://108020878442937" })
local MiscTab = MainWindow:AddTab({ Text = "Misc", Icon = "rbxassetid://108020878442937" })
local ConfigTab = MainWindow:AddTab({ Text = "Settings", Icon = "rbxassetid://108020878442937" })

local isAutoHarvest, isHarvestBest = false, false
local targetHarvest, targetHarvMut = defaultPlant, defaultMut
local pauseHarvestWeather = {"None"} 
local weatherList = {"None", "Rain", "Lightning", "Rainbow", "Snowfall", "Starfall", "Bloodmoon", "Blizzard"}
local minHarvestKg = 0
local maxHarvestKg = 9999

local HarvestGroup = FarmTab:AddSection({ Title = "Harvesting", Side = "Left" })
HarvestGroup:AddDropdown({ Text = "Select Name", Options = listPlants, Default = defaultPlant[1], Flag = "D_HarvSel", Callback = function(arr) targetHarvest = type(arr) == "table" and arr or {arr} end })
HarvestGroup:AddDropdown({ Text = "Select Mutation", Options = listMutations, Default = defaultMut[1], Flag = "D_HarvMut", Callback = function(arr) targetHarvMut = type(arr) == "table" and arr or {arr} end })
HarvestGroup:AddDropdown({ Text = "Pause on Weather", Options = weatherList, Default = "None", Flag = "D_HarvWeather", Callback = function(arr) pauseHarvestWeather = type(arr) == "table" and arr or {arr} end })
HarvestGroup:AddInput({ Text = "Minimum Weight (Kg)", PlaceHolder = "e.g. 20", Default = "1", Flag = "In_MinKg", Callback = function(t) local val = tonumber(t) if val then minHarvestKg = val end end })
HarvestGroup:AddInput({ Text = "Maximum Weight (Kg)", PlaceHolder = "e.g. 50", Default = "50", Flag = "In_MaxKg", Callback = function(t) local val = tonumber(t) if val then maxHarvestKg = val end end })
HarvestGroup:AddToggle({ Text = "Auto Harvest", Default = false, Flag = "T_HarvSel", Callback = function(s) isAutoHarvest = s end })

local SafetyGroup = FarmTab:AddSection({ Title = "Global Movements", Side = "Right" })
SafetyGroup:AddDropdown({ Text = "Movement Method", Options = {"Semi-Tween", "Teleport Instant"}, Default = "Semi-Tween", Flag = "D_MoveMethod", Callback = function(opt) moveMethod = opt end })
SafetyGroup:AddDropdown({ Text = "Interact Method", Options = {"Hold Proximity", "Instant Proximity"}, Default = "Hold Proximity", Flag = "D_InteractMethod", Callback = function(opt) interactMethod = opt end })

local isAutoPlant = false
local targetPlant, targetPlantMut = defaultPlant, defaultMut
local customDistance, customMaxPlant = 1.5, 0

local PlantGroup = FarmTab:AddSection({ Title = "Planting", Side = "Left" })
PlantGroup:AddDropdown({ Text = "Select Seed Name", Options = listPlants, Default = defaultPlant[1], Flag = "D_Plant", Callback = function(arr) targetPlant = type(arr) == "table" and arr or {arr} end })
PlantGroup:AddDropdown({ Text = "Select Seed Mutation", Options = listMutations, Default = defaultMut[1], Flag = "D_PlantMut", Callback = function(arr) targetPlantMut = type(arr) == "table" and arr or {arr} end })
PlantGroup:AddInput({ Text = "Grid Distance (Studs)", PlaceHolder = "Min 1.2 | Default 1.5", Flag = "In_Dist", Callback = function(t) local v = tonumber(t) customDistance = (v and v>=1.2) and v or 1.5 end })
PlantGroup:AddInput({ Text = "Plant Limit", PlaceHolder = "0 = Infinite", Flag = "In_Limit", Callback = function(t) local v = tonumber(t) customMaxPlant = (v and v>=0) and v or 0 end })
local PlantToggle = PlantGroup:AddToggle({ Text = "Auto Plant", Default = false, Flag = "T_Plant", Callback = function(s) isAutoPlant = s end })

local isShovelDead, isAutoShovel = false, false
local targetShovel, targetShovelMut = defaultPlant, defaultMut

local ShovelGroup = FarmTab:AddSection({ Title = "Shoveling", Side = "Left" })
ShovelGroup:AddDropdown({ Text = "Select Name", Options = listPlants, Default = defaultPlant[1], Flag = "D_ShovelSel", Callback = function(arr) targetShovel = type(arr) == "table" and arr or {arr} end })
ShovelGroup:AddDropdown({ Text = "Select Mutation", Options = listMutations, Default = defaultMut[1], Flag = "D_ShovelMut", Callback = function(arr) targetShovelMut = type(arr) == "table" and arr or {arr} end })
ShovelGroup:AddToggle({ Text = "Auto Shovel Dead/Decaying", Default = false, Flag = "T_ShovelDead", Callback = function(s) isShovelDead = s end })
ShovelGroup:AddToggle({ Text = "Auto Shovel", Default = false, Flag = "T_ShovelSel", Callback = function(s) isAutoShovel = s end })

local isAutoTrowel = false
local trowelMode = "Center Stack"
local targetTrowel, targetTrowelMut = defaultPlant, defaultMut
local customTrowelDist = 1.5

local TrowelGroup = FarmTab:AddSection({ Title = "Trowel", Side = "Left" })
TrowelGroup:AddDropdown({ Text = "Trowel Mode", Options = {"Center Stack", "Grid Tractor"}, Default = "Center Stack", Flag = "D_TrowelMode", Callback = function(opt) trowelMode = opt end })
TrowelGroup:AddDropdown({ Text = "Select Name", Options = listPlants, Default = defaultPlant[1], Flag = "D_TrowelSel", Callback = function(arr) targetTrowel = type(arr) == "table" and arr or {arr} end })
TrowelGroup:AddDropdown({ Text = "Select Mutation", Options = listMutations, Default = defaultMut[1], Flag = "D_TrowelMut", Callback = function(arr) targetTrowelMut = type(arr) == "table" and arr or {arr} end })
TrowelGroup:AddInput({ Text = "Grid Distance (For Tractor)", PlaceHolder = "1.5", Flag = "In_TrowelDist", Callback = function(t) local v = tonumber(t) customTrowelDist = (v and v>=1.2) and v or 1.5 end })
TrowelGroup:AddToggle({ Text = "Auto Trowel Plants", Default = false, Flag = "T_Trowel", Callback = function(s) isAutoTrowel = s end })

local isAutoCollect = false
local collectMode = "Collect All"
local collectTargets = {"Gold", "Rainbow"} 
local isCollectingDrops = false
local collectIdleTimer = 0
local collectWaitTime = 4 

local CollectGroup = FarmTab:AddSection({ Title = "Collecting", Side = "Right" })
CollectGroup:AddDropdown({ Text = "Mode", Options = {"Collect All", "Collect & Back"}, Default = "Collect All", Flag = "D_ColMode", Callback = function(opt) collectMode = opt end })
CollectGroup:AddDropdown({ Text = "Select Target", Options = {"All", "Gold", "Rainbow", "Random Seed"}, Default = "Gold", Flag = "D_ColTarget", Callback = function(arr) collectTargets = type(arr) == "table" and arr or {arr} end })
CollectGroup:AddInput({ Text = "Back Delay (sec)", PlaceHolder = "Default 4", Flag = "In_ColDelay", Callback = function(t) 
    local v = tonumber(t) 
    if v and v > 0 then collectWaitTime = v else collectWaitTime = 4 end 
end })
CollectGroup:AddToggle({ Text = "Auto Collect Dropped Seeds", Default = false, Flag = "T_CollectDrops", Callback = function(s) isAutoCollect = s; isCollectingDrops = false; collectIdleTimer = 0; end })
CollectGroup:AddLabel({ Text = "Info: Collect All (Tanpa pulang)\nCollect & Back (Pulang setelah delay)" })

local isAutoWater = false
local targetWaterTool = defaultWater
local targetWaterPlant, targetWaterMut = defaultPlant, defaultMut

local WaterGroup = FarmTab:AddSection({ Title = "Watering", Side = "Left" })
WaterGroup:AddDropdown({ Text = "Select Watering Can", Options = listWateringCans, Default = defaultWater[1], Flag = "D_WaterTool", Callback = function(arr) targetWaterTool = type(arr) == "table" and arr or {arr} end })
WaterGroup:AddDropdown({ Text = "Select Plant Name", Options = listPlants, Default = defaultPlant[1], Flag = "D_WaterPlant", Callback = function(arr) targetWaterPlant = type(arr) == "table" and arr or {arr} end })
WaterGroup:AddDropdown({ Text = "Select Mutation", Options = listMutations, Default = defaultMut[1], Flag = "D_WaterMut", Callback = function(arr) targetWaterMut = type(arr) == "table" and arr or {arr} end })
WaterGroup:AddToggle({ Text = "Auto Water Plants", Default = false, Flag = "T_AutoWater", Callback = function(s) isAutoWater = s end })

local isEspPlayers, isEspPlants, isEspPets = false, false, false
local isEspPlantName, isEspPlantMut, isEspPlantKG = true, true, true
local isEspPlantVal = true 
local isWeatherPredictor = true
local isShowGardenValue = false
local isShowInventoryValues = false

local EspGroup = FarmTab:AddSection({ Title = "Visuals", Side = "Right" })
EspGroup:AddToggle({ Text = "ESP Players", Default = false, Flag = "T_EspPlyr", Callback = function(s) isEspPlayers = s end })
EspGroup:AddToggle({ Text = "ESP Ready Plants", Default = false, Flag = "T_EspPlant", Callback = function(s) isEspPlants = s end })
EspGroup:AddToggle({ Text = "ESP Wild Pets", Default = false, Flag = "T_EspPet", Callback = function(s) isEspPets = s end })
EspGroup:AddToggle({ Text = "Show Plant Name", Default = true, Flag = "T_EspPName", Callback = function(s) isEspPlantName = s end })
EspGroup:AddToggle({ Text = "Show Mutation", Default = true, Flag = "T_EspPMut", Callback = function(s) isEspPlantMut = s end })
EspGroup:AddToggle({ Text = "Show Multiplier", Default = true, Flag = "T_EspPKG", Callback = function(s) isEspPlantKG = s end })
EspGroup:AddToggle({ Text = "Show Fruit Value", Default = true, Flag = "T_EspPVal", Callback = function(s) isEspPlantVal = s end }) 
EspGroup:AddToggle({ Text = "Weather Predictor UI", Default = true, Flag = "T_WeatherPred", Callback = function(s) isWeatherPredictor = s end })
EspGroup:AddToggle({ Text = "Show Value Garden", Default = false, Flag = "T_EspGardenVal", Callback = function(s) isShowGardenValue = s end })
EspGroup:AddToggle({ Text = "Show Inventory Values", Default = false, Flag = "T_EspInvVal", Callback = function(s) isShowInventoryValues = s end }) 

local isAutoSprinkler, targetSprinkler, customSprinklerDist = false, defaultSprinkler, 8
local SprinklerGroup = FarmTab:AddSection({ Title = "Sprinklers", Side = "Right" })
SprinklerGroup:AddDropdown({ Text = "Select Sprinkler", Options = listSprinklers, Default = defaultSprinkler[1], Flag = "D_Sprinkler", Callback = function(arr) targetSprinkler = type(arr) == "table" and arr or {arr} end })
SprinklerGroup:AddInput({ Text = "Sprinkler Grid (Studs)", PlaceHolder = "Default 8", Flag = "In_SprDist", Callback = function(t) local v = tonumber(t) customSprinklerDist = (v and v>=2) and v or 8 end })
SprinklerGroup:AddToggle({ Text = "Auto Place Sprinklers", Default = false, Flag = "T_AutoSprinkler", Callback = function(s) isAutoSprinkler = s end })

local isAutoSteal, stealInProgress, savedGardenCFrame = false, false, nil
local stealTargetPlayer, stealMode, stealMinValue = "Anyone", "Highest Value", 0;
local isAutoRejoinSteal, isAntiStealEnabled = false, false
local targetSteal, targetStealMut = defaultPlant, defaultMut
local stealReturnLimit = 50

local StealGroup = FarmTab:AddSection({ Title = "Auto Stealing", Side = "Right" })
local DDP_Steal = StealGroup:AddDropdown({ Text = "Target Player", Options = GetPlotOwners(), Default = "Anyone", Flag = "D_StealPlr", Callback = function(opt) stealTargetPlayer = opt end })
StealGroup:AddDropdown({ Text = "Steal Sort Mode", Options = {"Any", "Highest Value", "Lowest Value"}, Default = "Highest Value", Flag = "D_StealMode", Callback = function(opt) stealMode = opt end })
StealGroup:AddDropdown({ Text = "Select Fruit Name", Options = listPlants, Default = defaultPlant[1], Flag = "D_StealSel", Callback = function(arr) targetSteal = type(arr) == "table" and arr or {arr} end })
StealGroup:AddDropdown({ Text = "Select Mutation", Options = listMutations, Default = defaultMut[1], Flag = "D_StealMut", Callback = function(arr) targetStealMut = type(arr) == "table" and arr or {arr} end })
StealGroup:AddInput({ Text = "Min Value/Multiplier", PlaceHolder = "0", Flag = "In_StealMin", Callback = function(t) local v = tonumber(t) if v then stealMinValue = v else stealMinValue = 0 end end })
StealGroup:AddInput({ Text = "Return After X Stolen", PlaceHolder = "50", Flag = "In_StealLimit", Callback = function(t) local v = tonumber(t) if v and v > 0 then stealReturnLimit = v else stealReturnLimit = 50 end end })
StealGroup:AddToggle({ Text = "Auto Rejoin After Steal", Default = false, Flag = "T_AutoRejoinSteal", Callback = function(s) isAutoRejoinSteal = s end })
StealGroup:AddToggle({ Text = "Auto Anti-Stealing (Fling)", Default = false, Flag = "T_AntiSteal", Callback = function(s) isAntiStealEnabled = s end })
local AutoStealToggle = StealGroup:AddToggle({ Text = "Enable Auto Steal", Default = false, Flag = "T_AutoSteal", Callback = function(s) isAutoSteal = s; stealInProgress = false; end })

StealGroup:AddButton({ Text = "Refresh Player List", Callback = function() DDP_Steal:SetValues(GetPlotOwners()) end })
StealGroup:AddButton({ Text = "Set My Garden Base Pos", Callback = function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        savedGardenCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        Library:Notify({ Title = "Auto Steal", Text = "Garden base position saved!", Lifetime = 3 })
    end
end })

local isAutoSell, isAutoSellFull, isAutoSellTimer = false, false, false
local targetSell, targetSellMut = defaultPlant, defaultMut
local autoSellInterval, sellTimerCount = 60, 0

local SellGroup = EconTab:AddSection({ Title = "Selling", Side = "Left" })
SellGroup:AddDropdown({ Text = "Select Name", Options = listPlants, Default = defaultPlant[1], Flag = "D_SellSel", Callback = function(arr) targetSell = type(arr) == "table" and arr or {arr} end })
SellGroup:AddDropdown({ Text = "Select Mutation", Options = listMutations, Default = defaultMut[1], Flag = "D_SellMut", Callback = function(arr) targetSellMut = type(arr) == "table" and arr or {arr} end })
SellGroup:AddInput({ Text = "Timer Interval (Secs)", PlaceHolder = "60", Flag = "In_SellTimer", Callback = function(t) local v = tonumber(t) autoSellInterval = (v and v>0) and v or 60 end })
SellGroup:AddToggle({ Text = "Auto Sell Backpack Full", Default = false, Flag = "T_SellFull", Callback = function(s) isAutoSellFull = s end })
SellGroup:AddToggle({ Text = "Auto Sell On Timer", Default = false, Flag = "T_SellTimer", Callback = function(s) isAutoSellTimer = s sellTimerCount = 0 end })
SellGroup:AddToggle({ Text = "Auto Sell", Default = false, Flag = "T_SellSel", Callback = function(s) isAutoSell = s end })
local isAutoBargain = false
SellGroup:AddToggle({ Text = "Auto Bargain (Ask Bid All)", Default = false, Flag = "T_AutoBargain", Callback = function(s) isAutoBargain = s end })

local isBuySeed, isBuyGear, isBuyCrate = false, false, false
local targetSeeds, targetGears, targetCrates = {listAllSeeds[1]}, {listGears[1]}, {listCrates[1]}
local crateAmount = 1

local BuyGroup = EconTab:AddSection({ Title = "Shopping", Side = "Right" })
BuyGroup:AddDropdown({ Text = "Select Seed/Pack", Options = listAllSeeds, Default = listAllSeeds[1], Flag = "D_BuySeed", Callback = function(arr) targetSeeds = type(arr) == "table" and arr or {arr} end })
BuyGroup:AddToggle({ Text = "Auto Buy Seed", Default = false, Flag = "T_BuySeed", Callback = function(s) isBuySeed = s end })
BuyGroup:AddDropdown({ Text = "Select Gear", Options = listGears, Default = listGears[1], Flag = "D_BuyGear", Callback = function(arr) targetGears = type(arr) == "table" and arr or {arr} end })
BuyGroup:AddToggle({ Text = "Auto Buy Gear", Default = false, Flag = "T_BuyGear", Callback = function(s) isBuyGear = s end })
BuyGroup:AddDropdown({ Text = "Select Crate", Options = listCrates, Default = listCrates[1], Flag = "D_BuyCrate", Callback = function(arr) targetCrates = type(arr) == "table" and arr or {arr} end })
BuyGroup:AddSlider({ Text = "Crate Amount", Min = 1, Max = 100, Default = 1, Flag = "S_CrateAmount", Callback = function(v) crateAmount = v end })
BuyGroup:AddToggle({ Text = "Auto Buy Crate", Default = false, Flag = "T_BuyCrate", Callback = function(s) isBuyCrate = s end })

local isAutoOpenPacks, isAutoOpenCrates, isAutoOpenEggs = false, false, false
local isAutoExpand, isAutoPetSlot = false, false

local GachaGroup = EconTab:AddSection({ Title = "Gacha & Loot", Side = "Left" })
GachaGroup:AddToggle({ Text = "Auto Open Seed Packs", Default = false, Flag = "T_OpenPack", Callback = function(s) isAutoOpenPacks = s end })
GachaGroup:AddToggle({ Text = "Auto Open Crates", Default = false, Flag = "T_OpenCrate", Callback = function(s) isAutoOpenCrates = s end })
GachaGroup:AddToggle({ Text = "Auto Open Eggs", Default = false, Flag = "T_OpenEgg", Callback = function(s) isAutoOpenEggs = s end })
GachaGroup:AddToggle({ Text = "Auto Expand Garden", Default = false, Flag = "T_ExpGarden", Callback = function(s) isAutoExpand = s end })
GachaGroup:AddToggle({ Text = "Auto Purchase Pet Slots", Default = false, Flag = "T_ExpPet", Callback = function(s) isAutoPetSlot = s end })

local isAutoTameName = false
local isAutoTameRarity = false
local targetTame = {"All Pets"}
local targetRarity = {"Any"}
local isPetAutoReturn = false

local PetGroup = EconTab:AddSection({ Title = "Pets", Side = "Right" })
PetGroup:AddDropdown({ Text = "Select Pet Name", Options = listPets, Default = "All Pets", Flag = "D_TamePet", Callback = function(arr) targetTame = type(arr) == "table" and arr or {arr} end })
PetGroup:AddToggle({ Text = "Auto Tame by Name", Default = false, Flag = "T_TameName", Callback = function(s) isAutoTameName = s end })
PetGroup:AddDropdown({ Text = "Select Pet Rarity", Options = {"Any", "Common", "Uncommon", "Rare", "Legendary", "Mythic", "Super"}, Default = "Any", Flag = "D_PetRarity", Callback = function(arr) targetRarity = type(arr) == "table" and arr or {arr} end })
PetGroup:AddToggle({ Text = "Auto Tame by Rarity", Default = false, Flag = "T_TameRarity", Callback = function(s) isAutoTameRarity = s end })
PetGroup:AddToggle({ Text = "Return to Plot After Catch", Default = false, Flag = "T_PetReturn", Callback = function(s) isPetAutoReturn = s end })

local isPetFinder = false
local finderTargetName = {"All Pets"}
local finderTargetRarity = {"Any"}

local FinderGroup = EconTab:AddSection({ Title = "Pet Finder", Side = "Right" })
FinderGroup:AddLabel({ Text = "Warning! This feature will automatically move servers if Pet is not found!" })
FinderGroup:AddDropdown({ Text = "Target Pet Name", Options = listPets, Default = "All Pets", Flag = "D_FindPetName", Callback = function(arr) finderTargetName = type(arr) == "table" and arr or {arr} end })
FinderGroup:AddDropdown({ Text = "Target Rarity", Options = {"Any", "Common", "Uncommon", "Rare", "Legendary", "Mythic", "Super"}, Default = "Any", Flag = "D_FindPetRarity", Callback = function(arr) finderTargetRarity = type(arr) == "table" and arr or {arr} end })
FinderGroup:AddToggle({ Text = "Auto Pet Finder (Hop & Buy)", Default = false, Flag = "T_PetFinderStart", Callback = function(s) 
    isPetFinder = s 
    if s then Library:Notify({ Title = "Pet Finder", Text = "Hunting! Will hop if target not found.", Lifetime = 3 }) end
end })

local isAutoFavorite = false
local isAutoUnfavorite = false
local targetFavFruits = {"All"}

local InvGroup = MgmtTab:AddSection({ Title = "Favorite & Unfavorite", Side = "Left" })
InvGroup:AddDropdown({ Text = "Select Fruit", Options = listPlants, Default = "All", Flag = "D_InvFruit", Callback = function(arr) targetFavFruits = type(arr) == "table" and arr or {arr} end })

InvGroup:AddButton({ Text = "Favorite Selected Now", Callback = function()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        local count = 0
        for _, item in ipairs(bp:GetChildren()) do
            if item:GetAttribute("FruitName") or item:GetAttribute("IsFruit") then
                local fruitName = item:GetAttribute("FruitName") or item:GetAttribute("Fruit") or string.gsub(item.Name, "%s*%[%d+%.%d+kg%]", "")
                local isMatch = false
                if table.find(targetFavFruits, "All") then isMatch = true
                elseif fruitName then
                    for _, target in ipairs(targetFavFruits) do
                        if string.find(string.lower(fruitName), string.lower(target)) then isMatch = true break end
                    end
                end
                
                if isMatch then
                    local itemId = item:GetAttribute("Id") or item:GetAttribute("UniqueId")
                    if itemId then Networking.Backpack.SetFruitFavorite:Fire(itemId, true) count = count + 1 end
                end
            end
        end
        Library:Notify({ Title = "Inventory", Text = "Favorited " .. count .. " selected fruits!", Lifetime = 3 })
    end
end })

InvGroup:AddButton({ Text = "Unfavorite Selected Now", Callback = function()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        local count = 0
        for _, item in ipairs(bp:GetChildren()) do
            if item:GetAttribute("FruitName") or item:GetAttribute("IsFruit") then
                local fruitName = item:GetAttribute("FruitName") or item:GetAttribute("Fruit") or string.gsub(item.Name, "%s*%[%d+%.%d+kg%]", "")
                local isMatch = false
                if table.find(targetFavFruits, "All") then isMatch = true
                elseif fruitName then
                    for _, target in ipairs(targetFavFruits) do
                        if string.find(string.lower(fruitName), string.lower(target)) then isMatch = true break end
                    end
                end
                
                if isMatch then
                    local itemId = item:GetAttribute("Id") or item:GetAttribute("UniqueId")
                    if itemId then Networking.Backpack.SetFruitFavorite:Fire(itemId, false) count = count + 1 end
                end
            end
        end
        Library:Notify({ Title = "Inventory", Text = "Unfavorited " .. count .. " selected fruits!", Lifetime = 3 })
    end
end })

InvGroup:AddToggle({ Text = "Auto Favorite Selected", Default = false, Flag = "T_AutoFav", Callback = function(s) isAutoFavorite = s end })
InvGroup:AddToggle({ Text = "Auto Unfavorite Selected", Default = false, Flag = "T_AutoUnfav", Callback = function(s) isAutoUnfavorite = s end })

local isAutoDoN = false
local targetDoNStreak = 2

local DoNGroup = MgmtTab:AddSection({ Title = "Double Or Nothing", Side = "Left" })
DoNGroup:AddSlider({ Text = "Target Wins (Cashout)", Min = 1, Max = 10, Default = 2, Flag = "S_DoNStreak", Callback = function(val) targetDoNStreak = val end })
DoNGroup:AddToggle({ Text = "Auto Double or Nothing", Default = false, Flag = "T_AutoDoN", Callback = function(s) isAutoDoN = s end })

task.spawn(function()
    local RS = game:GetService("ReplicatedStorage")
    local Networking = require(RS:WaitForChild("SharedModules"):WaitForChild("Networking"))
    
    while task.wait(1.5) do
        pcall(function()
            if isAutoDoN then
                local steven = workspace:FindFirstChild("NPCS") and workspace.NPCS:FindFirstChild("Steven")
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if steven and hrp then
                    local stevenPos = steven:GetPivot().Position
                    if (hrp.Position - stevenPos).Magnitude > 15 then
                        if SmartMove then SmartMove(CFrame.new(stevenPos) * CFrame.new(0, 0, 4)) else hrp.CFrame = CFrame.new(stevenPos) * CFrame.new(0, 0, 4) end
                        task.wait(0.5)
                        hrp.Velocity = Vector3.new(0,0,0)
                        hrp.RotVelocity = Vector3.new(0,0,0)
                    end
                    
                    local roll = Networking.NPCS.DoubleOrNothing:Fire()
                    if roll then
                        if roll.Busted then
                            Library:Notify({ Title = "Steven's Gamble", Text = "Busted! Lost all the fruit", Lifetime = 2 })
                            task.wait(3)
                        elseif roll.Won then
                            local wins = roll.Wins or 0
                            if wins >= targetDoNStreak then
                                Networking.NPCS.CashOutDoubleOrNothing:Fire()
                                Library:Notify({ Title = "JACKPOT!", Text = "Successful Cashout in " .. tostring(wins) .. "x Streak!", Lifetime = 3 })
                                task.wait(2)
                            else
                                Library:Notify({ Title = "Gamble Won", Text = "Win " .. tostring(wins) .. "x Streak (Roll again...)", Lifetime = 1 })
                                task.wait(0.5) 
                            end
                        elseif roll.Reason == "NoFruits" then
                            Library:Notify({ Title = "Steven's Gamble", Text = "Bag is empty! Waiting for the harvest...", Lifetime = 3 })
                            task.wait(5) 
                        elseif roll.Reason == "Cooldown" then
                            task.wait(roll.Remaining or 2)
                        end
                    end
                end
            end
        end)
    end
end)

local dynamicAuctionList = {"Any"}
for _, v in ipairs(listAllSeeds) do table.insert(dynamicAuctionList, v) end
for _, v in ipairs(listPets) do table.insert(dynamicAuctionList, v) end
for _, v in ipairs(listGears) do table.insert(dynamicAuctionList, v) end
for _, v in ipairs(listCrates) do table.insert(dynamicAuctionList, v) end
for _, v in ipairs(listEggs) do table.insert(dynamicAuctionList, v) end 
table.sort(dynamicAuctionList)

local isAutoAuction = false
local targetAuctionItems = {"Any"}
local targetAuctionRarities = {"Any"}
local minAuctionPrice = 0
local maxAuctionPrice = 50000

local AuctionGroup = MgmtTab:AddSection({ Title = "Auction Manager", Side = "Left" })
AuctionGroup:AddDropdown({ Text = "Target Item", Options = dynamicAuctionList, Default = "Any", Flag = "D_AuctItem", Callback = function(arr) targetAuctionItems = type(arr) == "table" and arr or {arr} end })
AuctionGroup:AddDropdown({ Text = "Target Rarity", Options = {"Any", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Super"}, Default = "Any", Flag = "D_AuctRarity", Callback = function(arr) targetAuctionRarities = type(arr) == "table" and arr or {arr} end })
AuctionGroup:AddInput({ Text = "Min Price (¢)", PlaceHolder = "0", Flag = "In_AuctMin", Callback = function(t) local val = tonumber(t) if val then minAuctionPrice = val end end })
AuctionGroup:AddInput({ Text = "Max Price (¢)", PlaceHolder = "50000", Flag = "In_AuctMax", Callback = function(t) local val = tonumber(t) if val then maxAuctionPrice = val end end })
AuctionGroup:AddLabel({ Text = "------------------------" })
AuctionGroup:AddToggle({ Text = "Auto Auction", Default = false, Flag = "T_AutoAuction", Callback = function(s) isAutoAuction = s end })

task.spawn(function()
    local RS = game:GetService("ReplicatedStorage")
    local Networking = require(RS:WaitForChild("SharedModules"):WaitForChild("Networking"))
    local AuctioneerLogic = require(RS:WaitForChild("SharedModules"):WaitForChild("Auctioneer"))
    
    local MailboxCatalog
    pcall(function() MailboxCatalog = require(game:GetService("StarterPlayer").StarterPlayerScripts.Controllers.MailboxController.MailboxItemCatalog) end)
    
    while task.wait(1.5) do
        pcall(function()
            if isAutoAuction then
                local snapshot = Networking.Auctioneer.RequestSnapshot:Fire()
                
                if snapshot and type(snapshot) == "table" and type(snapshot.manifest) == "table" and type(snapshot.manifest.lots) == "table" then
                    local serverTime = workspace:GetServerTimeNow()
                    
                    for _, lot in pairs(snapshot.manifest.lots) do
                        local stock = snapshot.stock and snapshot.stock[lot.lotId] or lot.stockQuantity
                        if stock == nil or stock > 0 then
                            local itemName = AuctioneerLogic.DisplayName(lot) or lot.item
                            local itemRarity = "Common"
                            
                            if MailboxCatalog and MailboxCatalog.ResolveRarity then
                                local success, rarityResult = pcall(MailboxCatalog.ResolveRarity, lot.category, lot.item)
                                if success and rarityResult and rarityResult ~= "" then itemRarity = rarityResult end
                            end
                            
                            local isNameMatch = table.find(targetAuctionItems, "Any") or false
                            if not isNameMatch then
                                for _, target in ipairs(targetAuctionItems) do
                                    if string.find(string.lower(itemName), string.lower(target)) then isNameMatch = true break end
                                end
                            end

                            local isRarityMatch = table.find(targetAuctionRarities, "Any") or false
                            if not isRarityMatch then
                                for _, targetR in ipairs(targetAuctionRarities) do
                                    if string.lower(targetR) == string.lower(itemRarity) then isRarityMatch = true break end
                                end
                            end
                            
                            if isNameMatch and isRarityMatch then
                                local currentPrice = AuctioneerLogic.CurrentPrice(lot, serverTime)
                                if currentPrice >= minAuctionPrice and currentPrice <= maxAuctionPrice then
                                    Networking.Auctioneer.PurchaseLot:Fire(lot.lotId, currentPrice)
                                    Library:Notify({ Title = "Auction Manager", Text = "Purchased " .. itemName .. " for ¢" .. getgenv().NemesisAbbreviate(currentPrice), Lifetime = 3 })
                                    task.wait(0.3)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

local isAutoClaimMail = false
local isAutoAcceptGift = false
local isAutoSendMail = false
local targetMailPlayer = ""
local targetMailSeeds = {} 
local targetMailPets = {}  
local targetMailAmount = 0 
local mailSentCount = 0    
local isAutoSendByValue = false
local mailMinValue = 0
local mailMaxValue = 0
local currentSentValue = 0
local isAutoSendByFruitValue = false
local mailMinFruitValue = 0
local mailMaxFruitValue = 10000
local customMailMessage = "Special Delivery via Nemesis Hub!"

local function getPlayerNamesInServer()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    return names
end

local MailGroup = MgmtTab:AddSection({ Title = "Mailbox & Gifts", Side = "Right" })
MailGroup:AddToggle({ Text = "Auto Claim All Mailbox", Default = false, Flag = "T_AutoClaimMail", Callback = function(s) isAutoClaimMail = s end })
MailGroup:AddToggle({ Text = "Auto Accept All Gifts", Default = false, Flag = "T_AutoAcceptGift", Callback = function(s) isAutoAcceptGift = s end })
MailGroup:AddLabel({ Text = "------------------------" })

local playerDrop = MailGroup:AddDropdown({ Text = "Target Player", Options = getPlayerNamesInServer(), Default = "", Flag = "D_MailPlr", Callback = function(s) targetMailPlayer = s end })
MailGroup:AddButton({ Text = "Refresh Player List", Callback = function()
    -- *Catatan: Jika Dropdown lib ZuperMing tidak memiliki metode update (seperti :SetValues), Anda bisa menghilangkan baris di bawah, atau implementasi kustom jika lib mendukungnya.*
    pcall(function() playerDrop:SetValues(getPlayerNamesInServer()) end)
    Library:Notify({ Title = "Mailbox", Text = "Player list refreshed!", Lifetime = 2 })
end })

MailGroup:AddInput({ Text = "Custom Message", PlaceHolder = "Special Delivery via Nemesis Hub!", Flag = "In_MailMsg", Callback = function(t) 
    if t and t ~= "" then customMailMessage = t else customMailMessage = "Special Delivery via Nemesis Hub!" end
end })

MailGroup:AddLabel({ Text = "------------------------" })
MailGroup:AddLabel({ Text = "Mode 1: Send by Quantity\nSend seeds or pets based on limit." })
MailGroup:AddDropdown({ Text = "Target Seeds", Options = listPlants, Default = "", Flag = "D_MailSeed", Callback = function(arr) targetMailSeeds = type(arr) == "table" and arr or {arr} end })
MailGroup:AddDropdown({ Text = "Target Pets", Options = listPets, Default = "", Flag = "D_MailPet", Callback = function(arr) targetMailPets = type(arr) == "table" and arr or {arr} end })
MailGroup:AddInput({ Text = "Send Amount Limit", PlaceHolder = "0 = Infinite", Flag = "In_MailAmount", Callback = function(t) 
    local v = tonumber(t) 
    targetMailAmount = (v and v > 0) and v or 0 
end })
local SendMailToggle = MailGroup:AddToggle({ Text = "Auto Send Seeds/Pets", Default = false, Flag = "T_AutoSendMail", Callback = function(s) 
    isAutoSendMail = s 
    if s then mailSentCount = 0 Library:Notify({ Title = "Auto Send", Text = "Preparing to send items to " .. targetMailPlayer, Lifetime = 3 }) end
end }) 

MailGroup:AddLabel({ Text = "------------------------" })
MailGroup:AddLabel({ Text = "Mode 2: Send by Total Value\nTransfer money automatically." })
MailGroup:AddInput({ Text = "Min Target Total (¢)", PlaceHolder = "e.g. 500000000", Flag = "In_MailMinVal", Callback = function(t) 
    local v = tonumber(t)
    mailMinValue = (v and v > 0) and v or 0 
end })
MailGroup:AddInput({ Text = "Max Limit Total (¢)", PlaceHolder = "e.g. 550000000", Flag = "In_MailMaxVal", Callback = function(t) 
    local v = tonumber(t)
    mailMaxValue = (v and v > 0) and v or 0 
end })
local SendValueToggle = MailGroup:AddToggle({ Text = "Auto Send by Total Value", Default = false, Flag = "T_AutoSendVal", Callback = function(s) 
    isAutoSendByValue = s 
    if s then currentSentValue = 0 Library:Notify({ Title = "Auto Send Total", Text = "Target set to " .. mailMinValue, Lifetime = 4 }) end
end })

MailGroup:AddLabel({ Text = "------------------------" })
MailGroup:AddLabel({ Text = "Mode 3: Send by Fruit Value\nInventory Sorter." })
MailGroup:AddInput({ Text = "Min Fruit Price (¢)", PlaceHolder = "0", Flag = "In_MailMinFruit", Callback = function(t) 
    local v = tonumber(t)
    mailMinFruitValue = (v and v >= 0) and v or 0 
end })
MailGroup:AddInput({ Text = "Max Fruit Price (¢)", PlaceHolder = "10000", Flag = "In_MailMaxFruit", Callback = function(t) 
    local v = tonumber(t)
    mailMaxFruitValue = (v and v > 0) and v or 10000 
end })
MailGroup:AddToggle({ Text = "Auto Send by Fruit Price", Default = false, Flag = "T_AutoSendFruitVal", Callback = function(s) 
    isAutoSendByFruitValue = s 
    if s then Library:Notify({ Title = "Auto Sort", Text = "Mailing fruits between ¢" .. mailMinFruitValue .. " and ¢" .. mailMaxFruitValue, Lifetime = 4 }) end
end })
local isFlingEnabled = false
local flingThread
local movel = 0.1

local function doFling()
    while isFlingEnabled do
        RunService.Heartbeat:Wait()
        local c = LocalPlayer.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if hrp then
            local vel = hrp.Velocity
            hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
            RunService.RenderStepped:Wait()
            hrp.Velocity = vel
            RunService.Stepped:Wait()
            hrp.Velocity = vel + Vector3.new(0, movel, 0)
            movel = -movel
        end
    end
end

local isAutoSkip = true
local function executeSkip()
    pcall(function()
        local pgui = LocalPlayer:FindFirstChild("PlayerGui")
        if pgui then
            for _, gui in ipairs(pgui:GetChildren()) do
                local gName = string.lower(gui.Name)
                if string.find(gName, "cutscene") or string.find(gName, "intro") or string.find(gName, "cinematic") then
                    gui:Destroy()
                    for _, obj in ipairs(Lighting:GetChildren()) do
                        if obj:IsA("BlurEffect") and obj.Name ~= "NemesisBlur" then obj:Destroy() end
                    end
                    if Camera.CameraType == Enum.CameraType.Scriptable then
                        Camera.CameraType = Enum.CameraType.Custom
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                            Camera.CameraSubject = LocalPlayer.Character.Humanoid
                        end
                    end
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.Anchored = false
                    end
                    pcall(function()
                        local pm = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
                        if pm and pm:GetControls() then pm:GetControls():Enable() end
                    end)
                end
            end
        end
    end)
end

local MiscGroup = MiscTab:AddSection({ Title = "Miscellaneous", Side = "Left" })
local FlingToggle = MiscGroup:AddToggle({ 
    Text = "Touch Fling", Default = false, Flag = "T_Fling", 
    Callback = function(s) 
        isFlingEnabled = s 
        if s then
            flingThread = coroutine.create(doFling)
            coroutine.resume(flingThread)
        end
    end 
})

MiscGroup:AddToggle({ 
    Text = "Anti-AFK", Default = true, Flag = "T_AntiAFK", 
    Callback = function(s) 
        isAntiAFK = s 
        if s then
            pcall(function() LocalPlayer:SetAttribute("AntiAfkIdleOverride", math.huge) end)
        else
            pcall(function() LocalPlayer:SetAttribute("AntiAfkIdleOverride", 1140) end)
        end
    end 
})

MiscGroup:AddToggle({ 
    Text = "Auto Skip Cutscene/Intro", Default = true, Flag = "T_AutoSkip", 
    Callback = function(s) 
        isAutoSkip = s 
        if s then
            task.spawn(function()
                for i = 1, 5 do
                    if not isAutoSkip then break end
                    executeSkip()
                    task.wait(1)
                end
            end)
        end
    end 
})

local isFrozen = false
local isDestroyPlots, isDestroyPlants, isDestroyFruits = false, false, false
local hiddenPlotsCache, hiddenPlantsCache, hiddenFruitsCache = {}, {}, {}

local function restoreCache(cacheTable)
    for obj, parent in pairs(cacheTable) do
        if obj then pcall(function() obj.Parent = parent end) end
    end
    table.clear(cacheTable)
end

local ExploitGroup = MiscTab:AddSection({ Title = "Exploits", Side = "Right" })
ExploitGroup:AddToggle({ Text = "God Mode", Default = false, Flag = "T_GodMode", Callback = function(s) isGodMode = s end })
ExploitGroup:AddToggle({ 
    Text = "Freeze Character", Default = false, Flag = "T_Freeze", 
    Callback = function(s) 
        isFrozen = s 
        pcall(function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.Anchored = isFrozen end end)
    end 
})

ExploitGroup:AddToggle({ Text = "Destroy Other Plots (All)", Default = false, Flag = "T_HidePlots", Callback = function(s) isDestroyPlots = s; if not s then restoreCache(hiddenPlotsCache) end end })
ExploitGroup:AddToggle({ Text = "Destroy Other Plants", Default = false, Flag = "T_HidePlants", Callback = function(s) isDestroyPlants = s; if not s then restoreCache(hiddenPlantsCache) end end })
ExploitGroup:AddToggle({ Text = "Destroy Other Fruits", Default = false, Flag = "T_HideFruits", Callback = function(s) isDestroyFruits = s; if not s then restoreCache(hiddenFruitsCache) end end })

local extractedPets = {}
pcall(function()
    local petModules = require(game:GetService("ReplicatedStorage"):WaitForChild("SharedModules"):WaitForChild("PetModules"))
    for petName, _ in pairs(petModules) do table.insert(extractedPets, petName) end
    table.sort(extractedPets)
end)
if #extractedPets == 0 then extractedPets = {"Dragon", "Unicorn", "Owl", "Frog", "Cat", "Dog"} end 

local spoofPet = extractedPets[1]
local spoofType = "Rainbow"
local spoofSize = "Huge"
local fakePetCounter = 100

local VisualPetGroup = MiscTab:AddSection({ Title = "Visual Pet Spoofer", Side = "Left" }) 
VisualPetGroup:AddDropdown({ Text = "Select Pet", Options = extractedPets, Default = spoofPet, Flag = "D_SpoofPet", Callback = function(opt) spoofPet = type(opt) == "table" and opt[1] or opt end })
VisualPetGroup:AddDropdown({ Text = "Select Type", Options = {"Normal", "Gold", "Rainbow", "DarkMatter"}, Default = "Rainbow", Flag = "D_SpoofType", Callback = function(opt) spoofType = type(opt) == "table" and opt[1] or opt end })
VisualPetGroup:AddDropdown({ Text = "Select Size", Options = {"Normal", "Big", "Huge"}, Default = "Huge", Flag = "D_SpoofSize", Callback = function(opt) spoofSize = type(opt) == "table" and opt[1] or opt end })

VisualPetGroup:AddButton({ 
    Text = "Spawn as Pets (Visual)", 
    Callback = function()
        fakePetCounter = fakePetCounter + 1
        local refs = workspace:FindFirstChild("PlayerPetReferences")
        if not refs then return end
        
        local myFolder = refs:FindFirstChild(LocalPlayer.Name)
        if not myFolder then
            myFolder = Instance.new("Folder")
            myFolder.Name = LocalPlayer.Name
            myFolder.Parent = refs
        end
        
        local slotName = "PetPart" .. tostring(fakePetCounter)
        local fakeSlot = Instance.new("Part")
        fakeSlot.Name = slotName
        fakeSlot.Transparency = 1
        fakeSlot.CanCollide = false
        fakeSlot.Anchored = true
        fakeSlot.Parent = myFolder

        fakeSlot:SetAttribute("PetId", "Nemesis_" .. fakePetCounter)
        fakeSlot:SetAttribute("PetSpecies", spoofPet)
        fakeSlot:SetAttribute("PetType", spoofType)
        fakeSlot:SetAttribute("PetSize", spoofSize)
        fakeSlot:SetAttribute("PetVisible", true)
        
        fakeSlot:SetAttribute("SlotOffsetX", math.random(-8, 8))
        fakeSlot:SetAttribute("SlotOffsetZ", math.random(3, 8))
        
        Library:Notify({ Title = "Visual Mod", Text = "Spawned " .. spoofType .. " " .. spoofPet, Lifetime = 2 })
    end 
})

VisualPetGroup:AddButton({ 
    Text = "Give to Inventory (Visual)", 
    Callback = function()
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if not bp then return end

        local fakeTool = Instance.new("Tool")
        fakeTool.Name = spoofPet .. " (" .. spoofType .. ")"
        fakeTool.RequiresHandle = false
        
        fakeTool:SetAttribute("Pet", spoofPet)
        fakeTool:SetAttribute("PetType", spoofType)
        fakeTool:SetAttribute("PetSize", spoofSize)

        fakeTool.Parent = bp
        Library:Notify({ Title = "Visual Mod", Text = "Added to Inventory!", Lifetime = 2 })
    end 
})

VisualPetGroup:AddButton({ 
    Text = "Clear All Pets Spawner", 
    Callback = function()
        local refs = workspace:FindFirstChild("PlayerPetReferences")
        if refs and refs:FindFirstChild(LocalPlayer.Name) then
            for _, v in pairs(refs[LocalPlayer.Name]:GetChildren()) do
                if v.Name:match("^PetPart") then v:Destroy() end
            end
        end
    end 
})

VisualPetGroup:AddButton({ 
    Text = "Clear Fake Inventory", 
    Callback = function()
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then
            for _, v in pairs(bp:GetChildren()) do
                if v:IsA("Tool") and not v:FindFirstChild("Handle") then v:Destroy() end
            end
        end
    end 
})

Library:InitConfigs(MainWindow)

local function getMyPlot()
    local gardens = workspace:FindFirstChild("Gardens")
    if not gardens then return nil end
    for _, plot in ipairs(gardens:GetChildren()) do
        if plot:GetAttribute("OwnerUserId") == LocalPlayer.UserId then return plot end
    end
    return nil
end

local function getPlotOwnerName(plotModel)
    local ownerId = plotModel:GetAttribute("OwnerUserId")
    if ownerId then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.UserId == ownerId then return p.Name end
        end
    end
    return ""
end

local function getToolFromBackpack(attributeName, targetList)
    local containers = {LocalPlayer.Character, LocalPlayer:FindFirstChild("Backpack")}
    for _, container in ipairs(containers) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                local attr = item:GetAttribute(attributeName)
                if attr then
                    if not targetList then return item, attr end
                    if table.find(targetList, "All Sprinklers") or table.find(targetList, "All Watering Cans") then return item, attr end
                    for _, target in ipairs(targetList) do
                        if string.lower(attr) == string.lower(target) then return item, attr end
                    end
                end
            end
        end
    end
    return nil, nil
end

local function equipToolByName(toolName)
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    
    if humanoid and backpack then
        local tool = backpack:FindFirstChild(toolName)
        if tool then
            humanoid:EquipTool(tool)
        end
    end
end

local function getSeedToolFiltered(targetNames, targetMuts)
    local containers = {LocalPlayer.Character, LocalPlayer:FindFirstChild("Backpack")}
    for _, container in ipairs(containers) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                local seedName = item:GetAttribute("SeedTool")
                if seedName then
                    local seedMut = item:GetAttribute("Mutation")
                    if IsMatch(seedName, seedMut, targetNames, targetMuts) then
                        return item, seedName
                    end
                end
            end
        end
    end
    return nil, nil
end

getgenv()._VisitedServers = getgenv()._VisitedServers or {}
table.insert(getgenv()._VisitedServers, game.JobId) 

local function ServerHop()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local placeId = game.PlaceId
    
    pcall(function()
        local serversApi = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Desc&limit=100"
        local response = game:HttpGet(serversApi)
        if response then
            local data = HttpService:JSONDecode(response)
            if data and data.data then
                local servers = data.data
                for i = #servers, 2, -1 do
                    local j = math.random(i)
                    servers[i], servers[j] = servers[j], servers[i]
                end
                for _, server in ipairs(servers) do
                    if type(server) == "table" and server.playing < server.maxPlayers and not table.find(getgenv()._VisitedServers, server.id) then
                        table.insert(getgenv()._VisitedServers, server.id) 
                        TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
                        task.wait(2)
                    end
                end
            end
        end
    end)
    task.wait(2)
    TeleportService:Teleport(placeId, LocalPlayer)
end

local function doRejoin()
    if savedGardenCFrame and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = savedGardenCFrame
    end
    task.wait(0.8)
    while true do
        pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end)
        task.wait(2)
    end
end

local function tpToMyGarden()
    if savedGardenCFrame and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = savedGardenCFrame
        return
    end
    local myPlot = getMyPlot()
    if myPlot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local totalPos = Vector3.new(0, 0, 0)
        local count = 0
        for _, area in ipairs(CollectionService:GetTagged("PlantArea")) do
            if area:IsDescendantOf(myPlot) then
                totalPos = totalPos + area.Position
                count = count + 1
            end
        end
        local targetCFrame = myPlot:GetPivot() + Vector3.new(0, 3, 0)
        if count > 0 then targetCFrame = CFrame.new((totalPos / count) + Vector3.new(0, 3, 0)) end
        LocalPlayer.Character.HumanoidRootPart.CFrame = targetCFrame
    end
end

local SM = RS:WaitForChild("SharedModules")
local FruitValueCalc = require(SM:WaitForChild("FruitValueCalc"))
local SellValueData = require(SM:WaitForChild("SellValueData"))
local MutationData = require(SM:WaitForChild("MutationData"))
local SeedData = require(SM:WaitForChild("SeedData"))
local SellFlags = require(SM:WaitForChild("Flags"):WaitForChild("SellFlags"))
local WeightFormat = require(SM:WaitForChild("WeightFormat"))

local isSingleHarvest = {}
pcall(function()
    for _, data in ipairs(SeedData) do
        if data.IsSingleHarvest then isSingleHarvest[data.SeedName] = true end
    end
end)

local function Abbreviate(number)
    if not number then return "0" end
    if number >= 1000000000 then return string.format("%.2fB", number / 1000000000)
    elseif number >= 1000000 then return string.format("%.2fM", number / 1000000)
    elseif number >= 1000 then return string.format("%.2fK", number / 1000)
    else return tostring(math.floor(number)) end
end

local function getSafeWeightStr(weight)
    local str = ""
    pcall(function() str = WeightFormat.FormatGrams(weight) end)
    if str == "" then str = string.format("%.2fkg", weight) end
    return str:gsub("%s+", "")
end

local function getAccurateFruitValue(fName, sMulti, mut, decay)
    if not fName then return 0 end
    local cleanMut = mut
    if type(cleanMut) == "string" and (cleanMut == "" or cleanMut == "None" or cleanMut == " ") then cleanMut = nil end
    local sNum = tonumber(sMulti) or 1
    local dNum = tonumber(decay) or 0
    local finalValue = 0
    local success, err = pcall(function()
        local baseVal = FruitValueCalc(fName, sNum, cleanMut, LocalPlayer, dNum)
        if SellFlags and type(SellFlags.Apply) == "function" then finalValue = SellFlags.Apply(fName, baseVal) else finalValue = baseVal end
    end)
    
    if success and finalValue > 0 then return math.floor(finalValue) end
    local baseValue = SellValueData[fName] or 0
    local sizeExponent = 2.65
    if fName == "Mushroom" then sizeExponent = 1.9 elseif fName == "Bamboo" then sizeExponent = 1.75 end
    local sizeCalc = sNum ^ sizeExponent
    local knee, tailExp = 5, 1.5
    if sNum > knee then
        local minTail = math.min(tailExp, sizeExponent)
        sizeCalc = (knee ^ sizeExponent) * ((sNum / knee) ^ minTail)
    end
    local mutMulti = 1
    if cleanMut then
        pcall(function() 
            if type(MutationData) == "table" and MutationData[cleanMut] and MutationData[cleanMut].PriceMultiplier then
                mutMulti = MutationData[cleanMut].PriceMultiplier
            elseif type(MutationData) == "table" and MutationData.ReturnPriceMultiplier then
                mutMulti = MutationData.ReturnPriceMultiplier(cleanMut)
            end
        end)
        if isSingleHarvest[fName] and mutMulti > 1 then mutMulti = 1 + (mutMulti - 1) * 0.15 end
    end
    local decayMult = 1 - math.clamp(dNum, 0, 1) * 0.8
    local friendsBoost = 1 + (LocalPlayer:GetAttribute("Friends") or 0) * 0.1
    finalValue = math.floor(baseValue * sizeCalc * mutMulti * decayMult * friendsBoost)
    if fName == "Carrot" and finalValue < 4 then finalValue = 4 end
    return finalValue
end

getgenv().NemesisGetFruitValue = getAccurateFruitValue
getgenv().NemesisAbbreviate = Abbreviate
getgenv().NemesisInvTotal = 0
getgenv().NemesisGardenTotal = 0
getgenv().NemesisGardenCount = 0

getgenv().NemesisTruePrices = getgenv().NemesisTruePrices or {}
getgenv().NemesisPriceQueue = getgenv().NemesisPriceQueue or {}

task.spawn(function()
    local RS = game:GetService("ReplicatedStorage")
    local Networking = require(RS:WaitForChild("SharedModules"):WaitForChild("Networking"))
    while task.wait(0.2) do
        if #getgenv().NemesisPriceQueue > 0 then
            local itemId = table.remove(getgenv().NemesisPriceQueue, 1)
            pcall(function()
                local bid = Networking.NPCS.GetFruitBid:Fire(itemId)
                if bid then
                    local trueVal = bid.CurrentSellValue or bid.BidPrice
                    if trueVal and trueVal > 0 then getgenv().NemesisTruePrices[itemId] = trueVal end
                end
            end)
        end
    end
end)

task.spawn(function()
    local RS = game:GetService("ReplicatedStorage")
    local Networking = require(RS:WaitForChild("SharedModules"):WaitForChild("Networking"))
    while task.wait(0.5) do
        pcall(function()
            local valueMap = {}
            local currentInvTotal = 0 
            local sources = {LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character}
            local currentQueueMap = {}
            getgenv().NemesisPriceQueue = {} 
            
            for _, source in ipairs(sources) do
                if source then
                    for _, obj in ipairs(source:GetChildren()) do
                        local fName = obj:GetAttribute("FruitName") or obj:GetAttribute("Fruit")
                        local tWeight = obj:GetAttribute("Weight")
                        local itemId = obj:GetAttribute("Id") or obj:GetAttribute("UniqueId")
                        if fName and tWeight then
                            local uiKey = fName .. "_" .. getSafeWeightStr(tWeight)
                            local fruitPrice = 0
                            if itemId and getgenv().NemesisTruePrices[itemId] then
                                fruitPrice = getgenv().NemesisTruePrices[itemId]
                            else
                                local sMulti = obj:GetAttribute("SizeMultiplier") or obj:GetAttribute("SizeMulti") or 1
                                local mut = obj:GetAttribute("Mutation")
                                local decay = obj:GetAttribute("DecayAlpha") or 0
                                fruitPrice = getgenv().NemesisGetFruitValue(fName, sMulti, mut, decay)
                                if itemId and not currentQueueMap[itemId] then
                                    table.insert(getgenv().NemesisPriceQueue, itemId)
                                    currentQueueMap[itemId] = true
                                end
                            end
                            if not valueMap[uiKey] or fruitPrice > valueMap[uiKey] then valueMap[uiKey] = fruitPrice end
                            currentInvTotal = currentInvTotal + fruitPrice
                        end
                    end
                end
            end
            pcall(function()
                local preview = Networking.NPCS.PreviewSellAll:Fire()
                if preview and preview.TotalSellValue then currentInvTotal = preview.TotalSellValue end
            end)
            getgenv().NemesisInvTotal = currentInvTotal

            local currentGardenTotal = 0
            local currentPlantCount = 0
            local myPlot = getMyPlot()
            if myPlot then
                local plantsFolder = myPlot:FindFirstChild("Plants")
                if plantsFolder then
                    local children = plantsFolder:GetChildren()
                    currentPlantCount = #children
                    for _, plantModel in ipairs(children) do
                        local seedName = plantModel:GetAttribute("SeedName")
                        if seedName then
                            local fruitsFolder = plantModel:FindFirstChild("Fruits")
                            local pSize = plantModel:GetAttribute("SizeMultiplier") or plantModel:GetAttribute("SizeMulti") or 1
                            local pMut = plantModel:GetAttribute("Mutation")
                            local pDecay = plantModel:GetAttribute("DecayAlpha") or 0
                            if fruitsFolder and #fruitsFolder:GetChildren() > 0 then
                                for _, fruitModel in ipairs(fruitsFolder:GetChildren()) do
                                    local fSize = fruitModel:GetAttribute("SizeMultiplier") or fruitModel:GetAttribute("SizeMulti") or 1
                                    local actualSize = math.max(pSize, fSize)
                                    local fMut = fruitModel:GetAttribute("Mutation")
                                    if not fMut or fMut == "" or fMut == "None" then fMut = pMut end
                                    local fDecay = fruitModel:GetAttribute("DecayAlpha") or pDecay
                                    currentGardenTotal = currentGardenTotal + getgenv().NemesisGetFruitValue(seedName, actualSize, fMut, fDecay)
                                end
                            else
                                currentGardenTotal = currentGardenTotal + getgenv().NemesisGetFruitValue(seedName, pSize, pMut, pDecay)
                            end
                        end
                    end
                end
            end
            getgenv().NemesisGardenTotal = currentGardenTotal
            getgenv().NemesisGardenCount = currentPlantCount

            local BackpackGui = LocalPlayer.PlayerGui:FindFirstChild("BackpackGui")
            if BackpackGui then
                if not isShowInventoryValues then
                    for _, btn in ipairs(BackpackGui:GetDescendants()) do
                        if btn:IsA("TextButton") then
                            local tag = btn:FindFirstChild("NemesisPriceTag")
                            if tag then tag.Visible = false end
                        end
                    end
                    return 
                end

                for _, btn in ipairs(BackpackGui:GetDescendants()) do
                    if btn:IsA("TextButton") and btn.Name ~= "VRInventorySelector" then
                        local toolNameLbl = btn:FindFirstChild("ToolName")
                        local toolCountLbl = btn:FindFirstChild("ToolCount")
                        if toolNameLbl and toolCountLbl and toolNameLbl.Visible and toolCountLbl.Visible then
                            local uiKey = toolNameLbl.Text .. "_" .. toolCountLbl.Text:gsub("%s+", "")
                            local fruitPrice = valueMap[uiKey]
                            local priceTag = btn:FindFirstChild("NemesisPriceTag")
                            if fruitPrice and fruitPrice > 0 then
                                if not priceTag then
                                    priceTag = Instance.new("TextLabel")
                                    priceTag.Name = "NemesisPriceTag"
                                    priceTag.Size = UDim2.new(1, -4, 0, 16)
                                    priceTag.Position = UDim2.new(0, 2, 0, 2)
                                    priceTag.BackgroundTransparency = 1
                                    priceTag.TextColor3 = Color3.fromRGB(85, 255, 85)
                                    priceTag.TextStrokeTransparency = 0
                                    priceTag.TextStrokeColor3 = Color3.fromRGB(0, 30, 0)
                                    priceTag.Font = Enum.Font.GothamBlack
                                    priceTag.TextSize = 12
                                    priceTag.ZIndex = 50 
                                    priceTag.Parent = btn
                                end
                                priceTag.Text = getgenv().NemesisAbbreviate(fruitPrice) .. " ¢"
                                priceTag.Visible = true
                            else
                                if priceTag then priceTag.Visible = false end
                            end
                        else
                            local priceTag = btn:FindFirstChild("NemesisPriceTag")
                            if priceTag then priceTag.Visible = false end
                        end
                    end
                end
            end
        end)
    end
end)

local predGui = Instance.new("ScreenGui")
predGui.Name = "NemesisModernPredictor"
predGui.ResetOnSpawn = false
local suc = pcall(function() predGui.Parent = game:GetService("CoreGui") end)
if not suc then predGui.Parent = LP:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame", predGui)
mainFrame.Size = UDim2.new(0, 200, 0, 0)
mainFrame.AutomaticSize = Enum.AutomaticSize.Y
mainFrame.Position = UDim2.new(0, 15, 0.4, 0)
mainFrame.BackgroundTransparency = 1 
mainFrame.BorderSizePixel = 0
mainFrame.Visible = isWeatherPredictor

local listLayout = Instance.new("UIListLayout", mainFrame)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 4)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 16)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "WEATHER PREDICTOR"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextStrokeTransparency = 0 
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 12
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.LayoutOrder = 1

local currentValue = Instance.new("TextLabel", mainFrame)
currentValue.Size = UDim2.new(1, 0, 0, 16)
currentValue.BackgroundTransparency = 1
currentValue.Text = "Loading..."
currentValue.TextColor3 = Color3.fromRGB(255, 255, 255)
currentValue.TextStrokeTransparency = 0 
currentValue.Font = Enum.Font.GothamBold
currentValue.TextSize = 12
currentValue.TextXAlignment = Enum.TextXAlignment.Left
currentValue.RichText = true
currentValue.LayoutOrder = 2

local predLabel = Instance.new("TextLabel", mainFrame)
predLabel.Size = UDim2.new(1, 0, 0, 0)
predLabel.AutomaticSize = Enum.AutomaticSize.Y
predLabel.BackgroundTransparency = 1
predLabel.Text = ""
predLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
predLabel.TextStrokeTransparency = 0 
predLabel.Font = Enum.Font.GothamSemibold
predLabel.TextSize = 12
predLabel.LineHeight = 1.2
predLabel.TextXAlignment = Enum.TextXAlignment.Left
predLabel.TextYAlignment = Enum.TextYAlignment.Top
predLabel.RichText = true
predLabel.LayoutOrder = 3

local watermark = Instance.new("TextLabel", mainFrame)
watermark.Size = UDim2.new(1, 0, 0, 14)
watermark.BackgroundTransparency = 1
watermark.Text = ".gg/nemesishub"
watermark.TextColor3 = Color3.fromRGB(160, 80, 255)
watermark.TextStrokeTransparency = 0 
watermark.Font = Enum.Font.GothamBold
watermark.TextSize = 11
watermark.TextXAlignment = Enum.TextXAlignment.Left
watermark.LayoutOrder = 4

local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local gardenGui = Instance.new("ScreenGui")
gardenGui.Name = "NemesisGardenStats"
gardenGui.ResetOnSpawn = false
local sucG = pcall(function() gardenGui.Parent = game:GetService("CoreGui") end)
if not sucG then gardenGui.Parent = LP:WaitForChild("PlayerGui") end

local gardenFrame = Instance.new("Frame", gardenGui)
gardenFrame.Size = UDim2.new(0, 150, 0, 0)
gardenFrame.AutomaticSize = Enum.AutomaticSize.Y
gardenFrame.Position = UDim2.new(0, 15, 0.55, 0) 
gardenFrame.BackgroundTransparency = 1 
gardenFrame.BorderSizePixel = 0
gardenFrame.Visible = isShowGardenValue

local gardenText = Instance.new("TextLabel", gardenFrame)
gardenText.Size = UDim2.new(1, 0, 0, 0)
gardenText.AutomaticSize = Enum.AutomaticSize.Y
gardenText.BackgroundTransparency = 1
gardenText.TextStrokeTransparency = 0 
gardenText.Font = Enum.Font.GothamSemibold
gardenText.TextSize = 13
gardenText.LineHeight = 1.2
gardenText.TextXAlignment = Enum.TextXAlignment.Left
gardenText.RichText = true
gardenText.Text = "<font color=\"#7cd675\">🌱 Garden Stats</font>\n<font color=\"#cccccc\">Plants: 0\nGarden Value: 0\nInv Value: 0</font>"

local dragG, dragInpG, dragStartG, startPosG
gardenFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragG = true
        dragStartG = input.Position
        startPosG = gardenFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragG = false end
        end)
    end
end)
gardenFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInpG = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInpG and dragG then
        local delta = input.Position - dragStartG
        gardenFrame.Position = UDim2.new(startPosG.X.Scale, startPosG.X.Offset + delta.X, startPosG.Y.Scale, startPosG.Y.Offset + delta.Y)
    end
end)


local espDrawings = {}
local mutColors = {
    ["Gold"] = Color3.fromRGB(255, 215, 0),
    ["Rainbow"] = Color3.fromRGB(255, 50, 255),
    ["Frozen"] = Color3.fromRGB(0, 255, 255),
    ["Electric"] = Color3.fromRGB(255, 255, 0),
    ["Bloodlit"] = Color3.fromRGB(255, 0, 0),
    ["Chained"] = Color3.fromRGB(150, 150, 150),
    ["Starstruck"] = Color3.fromRGB(255, 255, 150),
    ["Shiny"] = Color3.fromRGB(200, 200, 255),
    ["Diamond"] = Color3.fromRGB(100, 200, 255),
    ["Dark Matter"] = Color3.fromRGB(150, 0, 200),
    ["None"] = Color3.fromRGB(50, 255, 50)
}

local function getMutColor(mutStr)
    if not mutStr or mutStr == "" or mutStr == "None" then return mutColors["None"] end
    for k, v in pairs(mutColors) do
        if string.find(mutStr, k) then return v end
    end
    return Color3.fromRGB(255, 150, 50)
end

local function getDrawing(inst)
    if not espDrawings[inst] then
        local txt = Drawing.new("Text")
        txt.Visible = false
        txt.Center = true
        txt.Outline = true
        txt.Font = 2
        txt.Size = 13
        espDrawings[inst] = txt
    end
    return espDrawings[inst]
end

local gardenValueCache = {}

RunService.RenderStepped:Connect(function()
    local activeDrawings = {}

    if isWeatherPredictor then
        mainFrame.Visible = true
        local nightNode = ReplicatedStorage:FindFirstChild("Night")
        local tod = (nightNode and nightNode.Value) and "Night" or "Day"
        
        local activeW = "Clear"
        local weatherValues = ReplicatedStorage:FindFirstChild("WeatherValues")
        if weatherValues then
            local weathers = {"Rain", "Lightning", "Rainbow", "Snowfall", "Starfall", "Bloodmoon", "Blizzard"}
            for _, w in ipairs(weathers) do
                if weatherValues:GetAttribute(w .. "_Playing") == true then
                    activeW = w
                    break
                end
            end
        end

        local nowUnix = DateTime.now().UnixTimestamp
        local weathersData = {
            { name = "Rain", interval = 120 * 60, color = "#55FF55" },
            { name = "Lightning", interval = 90 * 60, color = "#FFD700" },
            { name = "Rainbow", interval = 60 * 60, color = "#AA00FF" },
            { name = "Snowfall", interval = 30 * 60, color = "#88DDFF" },
            { name = "Starfall", interval = 30 * 60, color = "#e88bff" }
        }

        currentValue.Text = string.format("Live: %s <font color=\"#AAAAAA\">|</font> %s", activeW, tod)
        
        local str = ""
        for _, w in ipairs(weathersData) do
            local rem = w.interval - (nowUnix % w.interval)
            local m = math.floor(rem / 60)
            local s = rem % 60
            str = str .. string.format("<font color=\"%s\">%s</font> <font color=\"#888888\">in</font> %dm %ds\n", w.color, w.name, m, s)
        end
        predLabel.Text = str
    else
        mainFrame.Visible = false
    end
    
    if isShowGardenValue then
        gardenFrame.Visible = true
        local pCount = getgenv().NemesisGardenCount or 0
        local gTotal = getgenv().NemesisGardenTotal or 0
        local iTotal = getgenv().NemesisInvTotal or 0
        
        local abbrevG = getgenv().NemesisAbbreviate and getgenv().NemesisAbbreviate(gTotal) or tostring(gTotal)
        local abbrevI = getgenv().NemesisAbbreviate and getgenv().NemesisAbbreviate(iTotal) or tostring(iTotal)
        
        gardenText.Text = string.format("<font color=\"#7cd675\">🌱 Garden Stats</font>\n<font color=\"#cccccc\">Plants: %d\nGarden Value: ¢%s\nInv Value: ¢%s</font>", pCount, abbrevG, abbrevI)
    else
        gardenFrame.Visible = false
    end

    if isEspPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = plr.Character.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    activeDrawings[plr] = true
                    local d = getDrawing(plr)
                    d.Text = plr.Name
                    d.Color = Color3.fromRGB(255, 50, 50)
                    d.Position = Vector2.new(pos.X, pos.Y)
                    d.Visible = true
                end
            end
        end
    end

    if isEspPlants then
        local gardens = workspace:FindFirstChild("Gardens")
        if gardens then
            for _, plot in ipairs(gardens:GetChildren()) do
                local plantsFolder = plot:FindFirstChild("Plants")
                if plantsFolder then
                    for _, plant in ipairs(plantsFolder:GetChildren()) do
                        local fruitModel = nil
                        local fFolder = plant:FindFirstChild("Fruits")
                        if fFolder then fruitModel = fFolder:GetChildren()[1] end

                        local isReady = plant:GetAttribute("PlantGrowthReady") == true
                        if isReady or fruitModel then
                            local targetModel = fruitModel or plant
                            local part = targetModel.PrimaryPart or targetModel:FindFirstChildWhichIsA("BasePart", true) or plant.PrimaryPart or plant:FindFirstChildWhichIsA("BasePart", true)

                            if part then
                                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                                if onScreen then
                                    local name = plant:GetAttribute("SeedName") or plant.Name
                                    local pMut = plant:GetAttribute("Mutation")
                                    local pSize = plant:GetAttribute("SizeMultiplier") or plant:GetAttribute("SizeMulti") or 1
                                    local pDecay = plant:GetAttribute("DecayAlpha") or 0
                                    local fMut = fruitModel and fruitModel:GetAttribute("Mutation") or nil
                                    
                                    local mutStr = ""
                                    if pMut and pMut ~= "" and pMut ~= "None" then mutStr = pMut end
                                    if fMut and fMut ~= "" and fMut ~= "None" then
                                        if mutStr == "" then mutStr = fMut
                                        elseif mutStr ~= fMut then mutStr = mutStr .. " + " .. fMut end
                                    end

                                    local isMutated = (mutStr ~= "")
                                    local textLines = {}

                                    if isEspPlantName then
                                        local nameLine = name
                                        if isEspPlantMut and isMutated then nameLine = nameLine .. " [" .. mutStr .. "]" end
                                        table.insert(textLines, nameLine)
                                    elseif isEspPlantMut and isMutated then
                                        table.insert(textLines, "[" .. mutStr .. "]")
                                    end

                                    local displaySize = pSize
                                    if fFolder and #fFolder:GetChildren() > 0 then
                                        local fS = fFolder:GetChildren()[1]:GetAttribute("SizeMultiplier") or fFolder:GetChildren()[1]:GetAttribute("SizeMulti") or 1
                                        displaySize = math.max(pSize, fS)
                                    end

                                    if isEspPlantKG and displaySize > 1 then table.insert(textLines, string.format("[x%.2f]", displaySize)) end

                                    if isEspPlantVal and getgenv().NemesisGetFruitValue then
                                        local totalPlantVal = 0
                                        if fFolder and #fFolder:GetChildren() > 0 then
                                            for _, fModel in ipairs(fFolder:GetChildren()) do
                                                local fS = fModel:GetAttribute("SizeMultiplier") or fModel:GetAttribute("SizeMulti") or 1
                                                local actualSize = math.max(pSize, fS)
                                                local cMut = fModel:GetAttribute("Mutation")
                                                if not cMut or cMut == "" or cMut == "None" then cMut = pMut end
                                                local cDecay = fModel:GetAttribute("DecayAlpha") or pDecay
                                                local cacheKey = name .. "_" .. tostring(actualSize) .. "_" .. tostring(cMut) .. "_" .. tostring(cDecay)
                                                if not gardenValueCache[cacheKey] then
                                                    gardenValueCache[cacheKey] = getgenv().NemesisGetFruitValue(name, actualSize, cMut, cDecay)
                                                end
                                                totalPlantVal = totalPlantVal + gardenValueCache[cacheKey]
                                            end
                                        else
                                            local cacheKey = name .. "_" .. tostring(pSize) .. "_" .. tostring(pMut) .. "_" .. tostring(pDecay)
                                            if not gardenValueCache[cacheKey] then
                                                gardenValueCache[cacheKey] = getgenv().NemesisGetFruitValue(name, pSize, pMut, pDecay)
                                            end
                                            totalPlantVal = totalPlantVal + gardenValueCache[cacheKey]
                                        end
                                        if totalPlantVal > 0 then
                                            table.insert(textLines, "¢" .. (getgenv().NemesisAbbreviate and getgenv().NemesisAbbreviate(totalPlantVal) or tostring(totalPlantVal)))
                                        end
                                    end

                                    if #textLines > 0 then
                                        activeDrawings[plant] = true
                                        local d = getDrawing(plant)
                                        d.Text = table.concat(textLines, "\n")
                                        d.Color = getMutColor(mutStr)
                                        d.Position = Vector2.new(pos.X, pos.Y)
                                        d.Visible = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    if isEspPets then
        local wildSpawns = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("WildPetSpawns")
        if wildSpawns then
            for _, petModel in ipairs(wildSpawns:GetChildren()) do
                if petModel:IsA("Model") then
                    local part = petModel.PrimaryPart or petModel:FindFirstChildWhichIsA("BasePart", true)
                    if part then
                        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            activeDrawings[petModel] = true
                            local d = getDrawing(petModel)
                            local cleanName = petModel:GetAttribute("PetName")
                            if not cleanName then cleanName = string.split(petModel.Name, "_")[2] or petModel.Name end
                            d.Text = cleanName .. "\n[Wild Pet]"
                            d.Color = Color3.fromRGB(255, 105, 180) 
                            d.Position = Vector2.new(pos.X, pos.Y)
                            d.Visible = true
                        end
                    end
                end
            end
        end
    end

    for inst, drawing in pairs(espDrawings) do
        if not activeDrawings[inst] then
            drawing:Remove()
            espDrawings[inst] = nil
        end
    end
end)
task.spawn(function()
    while task.wait(0.5) do

        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if isFrozen then
                    LocalPlayer.Character.HumanoidRootPart.Anchored = true
                end
            end
        end)

        pcall(function()
            local myPlot = getMyPlot()
            local gardens = workspace:FindFirstChild("Gardens")
            
            if gardens then
                for _, plot in ipairs(gardens:GetChildren()) do
                    if plot ~= myPlot then
                        if isDestroyPlots then
                            local targetFolders = {"Plants", "Signs", "Sprinklers", "Visual"}
                            for _, fName in ipairs(targetFolders) do
                                local folder = plot:FindFirstChild(fName)
                                if folder then
                                    for _, child in ipairs(folder:GetChildren()) do
                                        if child.Parent == folder then
                                            hiddenPlotsCache[child] = folder
                                            child.Parent = nil
                                        end
                                    end
                                end
                            end
                        end
                        if isDestroyPlants and not isDestroyPlots then
                            local plantsFolder = plot:FindFirstChild("Plants")
                            if plantsFolder then
                                for _, child in ipairs(plantsFolder:GetChildren()) do
                                    if child.Parent == plantsFolder then
                                        hiddenPlantsCache[child] = plantsFolder
                                        child.Parent = nil
                                    end
                                end
                            end
                        end
                        if isDestroyFruits and not isDestroyPlots and not isDestroyPlants then
                            local plantsFolder = plot:FindFirstChild("Plants")
                            if plantsFolder then
                                for _, plantModel in ipairs(plantsFolder:GetChildren()) do
                                    local fruitsFolder = plantModel:FindFirstChild("Fruits")
                                    if fruitsFolder then
                                        for _, child in ipairs(fruitsFolder:GetChildren()) do
                                            if child.Parent == fruitsFolder then
                                                hiddenFruitsCache[child] = fruitsFolder
                                                child.Parent = nil
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)

        pcall(function()
            if isAutoSkip then
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                if pgui then
                    for _, gui in ipairs(pgui:GetChildren()) do
                        local gName = string.lower(gui.Name)
                        if string.find(gName, "cutscene") or string.find(gName, "intro") or string.find(gName, "cinematic") then
                            gui:Destroy() 
                            for _, obj in ipairs(Lighting:GetChildren()) do
                                if obj:IsA("BlurEffect") and obj.Name ~= "NemesisBlur" then obj:Destroy() end
                            end
                            if Camera.CameraType == Enum.CameraType.Scriptable then
                                Camera.CameraType = Enum.CameraType.Custom
                                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                                    Camera.CameraSubject = LocalPlayer.Character.Humanoid
                                end
                            end
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                LocalPlayer.Character.HumanoidRootPart.Anchored = false
                            end
                            pcall(function()
                                local pm = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
                                if pm and pm:GetControls() then pm:GetControls():Enable() end
                            end)
                        end
                    end
                end
            end
        end)

        pcall(function()
            if isBuySeed and #targetSeeds > 0 then
                for _, seed in ipairs(targetSeeds) do Networking.SeedShop.PurchaseSeed:Fire(seed) task.wait(0.3) end
            end
            if isBuyGear and #targetGears > 0 then
                for _, gear in ipairs(targetGears) do Networking.GearShop.PurchaseGear:Fire(gear) task.wait(0.3) end
            end
            if isBuyCrate and #targetCrates > 0 then
                for _, crate in ipairs(targetCrates) do Networking.CrateShop.PurchaseCrate:Fire(crate) task.wait(0.3) end
            end
            if isAutoExpand then Networking.Actions.ExpandGarden:Fire() task.wait(1) end
            if isAutoPetSlot then Networking.Pets.RequestPurchasePetSlot:Fire() task.wait(1) end
        end)

        if not getgenv()._isAutoSellRunning then
            getgenv()._isAutoSellRunning = true
            task.spawn(function()
                pcall(function()
                    if isAutoSellTimer then
                        sellTimerCount = sellTimerCount + 0.5
                        if sellTimerCount >= autoSellInterval then
                            Networking.NPCS.SellAll:Fire()
                            sellTimerCount = 0
                            task.wait(1)
                        end
                    end
                    if isAutoSellFull then
                        local currentFruit = LocalPlayer:GetAttribute("FruitCount") or 0
                        local maxFruit = LocalPlayer:GetAttribute("MaxFruitCapacity") or 100
                        if currentFruit > 0 and currentFruit >= maxFruit then
                            Networking.NPCS.SellAll:Fire() task.wait(1)
                        end
                    end
                    if isAutoSell then
                        if table.find(targetSell, "All") and table.find(targetSellMut, "Any") then
                            Networking.NPCS.SellAll:Fire() 
                            task.wait(1)
                        else
                            local backpack = LocalPlayer:FindFirstChild("Backpack")
                            if backpack then
                                for _, item in ipairs(backpack:GetChildren()) do
                                    local fruitName = item:GetAttribute("FruitName") or item:GetAttribute("Fruit") or string.gsub(item.Name, "%s*%[%d+%.%d+kg%]", "")
                                    if fruitName then
                                        local mut = item:GetAttribute("Mutation")
                                        if IsMatch(fruitName, mut, targetSell, targetSellMut) then
                                            local itemId = item:GetAttribute("Id") or item:GetAttribute("UniqueId")
                                            if itemId then Networking.NPCS.SellFruit:Fire(itemId) task.wait(0.1) end
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
                getgenv()._isAutoSellRunning = false
            end)
        end
        
        if not getgenv()._isAutoHarvestRunning then
            getgenv()._isAutoHarvestRunning = true
            task.spawn(function()
                pcall(function()
                    if isAutoHarvest then 
                        local activeW = "Clear"
                        local weatherValues = game:GetService("ReplicatedStorage"):FindFirstChild("WeatherValues")
                        if weatherValues then
                            local weathers = {"Rain", "Lightning", "Rainbow", "Snowfall", "Starfall", "Bloodmoon", "Blizzard"}
                            for _, w in ipairs(weathers) do
                                if weatherValues:GetAttribute(w .. "_Playing") == true then activeW = w break end
                            end
                        end

                        local isPaused = false
                        if not table.find(pauseHarvestWeather, "None") then
                            for _, w in ipairs(pauseHarvestWeather) do
                                if string.lower(w) == string.lower(activeW) then isPaused = true break end
                            end
                        end

                        if isPaused then 
                            getgenv()._isAutoHarvestRunning = false
                            return 
                        end

                        local myPlot = getMyPlot()
                        if not myPlot then getgenv()._isAutoHarvestRunning = false return end
                        
                        for _, obj in ipairs(myPlot:GetDescendants()) do
                            if not isAutoHarvest then break end 
                            if obj:IsA("ProximityPrompt") and string.find(string.lower(obj.ActionText), "harvest") then
                                local seedName, mutation = nil, nil
                                local plantModel = obj.Parent
                                
                                while plantModel and plantModel ~= workspace do
                                    if plantModel:GetAttribute("SeedName") then
                                        seedName = plantModel:GetAttribute("SeedName")
                                        mutation = plantModel:GetAttribute("Mutation")
                                        break
                                    end
                                    plantModel = plantModel.Parent
                                end

                                if seedName and IsMatch(seedName, mutation, targetHarvest, targetHarvMut) then
                                    local fFolder = plantModel:FindFirstChild("Fruits")
                                    local currentWeight = 0
                                    
                                    if fFolder then
                                        local firstF = fFolder:GetChildren()[1]
                                        if firstF then
                                            currentWeight = firstF:GetAttribute("Weight") or 0
                                            
                                            if currentWeight <= 0 then
                                                pcall(function()
                                                    local coreName = firstF:GetAttribute("CorePartName") or seedName
                                                    local rs = game:GetService("ReplicatedStorage")
                                                    local fruitMod = rs:FindFirstChild("PlantGenerationModules") 
                                                        and rs.PlantGenerationModules:FindFirstChild("Fruits") 
                                                        and rs.PlantGenerationModules.Fruits:FindFirstChild(coreName)
                                                    
                                                    if fruitMod then
                                                        local data = require(fruitMod)
                                                        local baseWeight = (data and data.GrowData and data.GrowData.BaseWeight) or 0
                                                        local sMulti = firstF:GetAttribute("SizeMulti") or 1
                                                        currentWeight = baseWeight * sMulti
                                                    end
                                                end)
                                            end
                                            
                                            if currentWeight <= 0 then
                                                local fullText = string.lower((obj.ObjectText or "") .. " " .. (obj.ActionText or ""))
                                                local weightStr = string.match(fullText, "(%d+[%.%,]?%d*)%s*kg")
                                                if weightStr then
                                                    weightStr = string.gsub(weightStr, ",", ".")
                                                    currentWeight = tonumber(weightStr) or 0
                                                end
                                            end
                                            
                                            if currentWeight > 0 then
                                                if currentWeight >= minHarvestKg and currentWeight <= maxHarvestKg then
                                                    obj.HoldDuration = 0
                                                    fireproximityprompt(obj)
                                                    task.wait(0.05)
                                                end
                                            else
                                                if maxHarvestKg >= 9000 then
                                                    obj.HoldDuration = 0
                                                    fireproximityprompt(obj)
                                                    task.wait(0.05)
                                                end
                                            end
                                            
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
                getgenv()._isAutoHarvestRunning = false
            end)
        end
        
        pcall(function()
            if isShovelDead or isAutoShovel then
                local myPlot = getMyPlot()
                if not myPlot then return end
                local plantsFolder = myPlot:FindFirstChild("Plants")
                if not plantsFolder then return end
                local shovelTool, shovelAttr = getToolFromBackpack("Shovel")
                if not shovelTool then return end

                for _, plant in ipairs(plantsFolder:GetChildren()) do
                    if not (isShovelDead or isAutoShovel) then break end
                    local isDecaying = plant:GetAttribute("Decaying") == true
                    local seedName = plant:GetAttribute("SeedName")
                    local mut = plant:GetAttribute("Mutation")
                    local shouldShovel = false
                    
                    if isShovelDead and isDecaying then shouldShovel = true
                    elseif isAutoShovel and seedName then
                        if IsMatch(seedName, mut, targetShovel, targetShovelMut) then shouldShovel = true end
                    end
                    
                    if shouldShovel then
                        Networking.Shovel.UseShovel:Fire(plant.Name, "", shovelAttr, shovelTool) task.wait(0.15)
                    end
                end
            end
        end)

        pcall(function()
            if isAutoPlant then
                local myPlot = getMyPlot()
                if not myPlot then return end
                local plantAreas = {}
                for _, area in ipairs(CollectionService:GetTagged("PlantArea")) do
                    if area:IsDescendantOf(myPlot) then table.insert(plantAreas, area) end
                end
                if #plantAreas == 0 then return end
                local seedTool, seedName = getSeedToolFiltered(targetPlant, targetPlantMut)
                if not seedTool then return end
                local size, cframe = plantAreas[1].Size, plantAreas[1].CFrame
                local step = customDistance
                local plantsFolder = myPlot:FindFirstChild("Plants")
                local plantedCount = 0

                for x = -size.X/2 + step, size.X/2 - step, step do
                    for z = -size.Z/2 + step, size.Z/2 - step, step do
                        if not isAutoPlant then return end
                        if customMaxPlant > 0 and plantedCount >= customMaxPlant then
                            isAutoPlant = false if PlantToggle then PlantToggle:Set(false) end return
                        end
                        local pos = (cframe * CFrame.new(x, size.Y/2, z)).Position
                        local tooClose = false
                        if plantsFolder then
                            for _, plant in ipairs(plantsFolder:GetChildren()) do
                                local pPart = plant:IsA("Model") and plant.PrimaryPart or plant:FindFirstChildWhichIsA("BasePart", true)
                                if pPart and (Vector2.new(pos.X, pos.Z) - Vector2.new(pPart.Position.X, pPart.Position.Z)).Magnitude < 1.2 then
                                    tooClose = true break
                                end
                            end
                        end
                        if not tooClose then
                            Networking.Plant.PlantSeed:Fire(pos, seedName, seedTool)
                            plantedCount = plantedCount + 1
                            task.wait(0.1)
                            seedTool, seedName = getSeedToolFiltered(targetPlant, targetPlantMut)
                            if not seedTool then return end
                        end
                    end
                end
            end
        end)

        pcall(function()
            if isAutoTrowel then
                local myPlot = getMyPlot()
                if not myPlot then return end
                local plantAreas = {}
                for _, area in ipairs(CollectionService:GetTagged("PlantArea")) do
                    if area:IsDescendantOf(myPlot) then table.insert(plantAreas, area) end
                end
                if #plantAreas == 0 then return end
                
                local plantsFolder = myPlot:FindFirstChild("Plants")
                if not plantsFolder then return end
                
                local plantsToMove = {}
                for _, plant in ipairs(plantsFolder:GetChildren()) do
                    local sName = plant:GetAttribute("SeedName")
                    local sMut = plant:GetAttribute("Mutation")
                    if IsMatch(sName, sMut, targetTrowel, targetTrowelMut) then table.insert(plantsToMove, plant) end
                end
                
                if #plantsToMove > 0 then
                    if trowelMode == "Center Stack" then
                        local center = plantAreas[1].Position
                        for _, plant in ipairs(plantsToMove) do
                            if not isAutoTrowel then break end
                            local pPart = plant:IsA("Model") and plant.PrimaryPart or plant:FindFirstChildWhichIsA("BasePart", true)
                            if pPart and (Vector2.new(pPart.Position.X, pPart.Position.Z) - Vector2.new(center.X, center.Z)).Magnitude > 1.5 then
                                Networking.Trowel.MovePlant:Fire(plant.Name, center, 0)
                                task.wait(0.1)
                            end
                        end
                    elseif trowelMode == "Grid Tractor" then
                        local size, cframe = plantAreas[1].Size, plantAreas[1].CFrame
                        local step = customTrowelDist
                        local plantIdx = 1
                        
                        for x = -size.X/2 + step, size.X/2 - step, step do
                            for z = -size.Z/2 + step, size.Z/2 - step, step do
                                if not isAutoTrowel or plantIdx > #plantsToMove then break end
                                local pos = (cframe * CFrame.new(x, size.Y/2, z)).Position
                                local isOccupied = false
                                for _, plant in ipairs(plantsFolder:GetChildren()) do
                                    local pPart = plant:IsA("Model") and plant.PrimaryPart or plant:FindFirstChildWhichIsA("BasePart", true)
                                    if pPart and (Vector2.new(pPart.Position.X, pPart.Position.Z) - Vector2.new(pos.X, pos.Z)).Magnitude < 1.2 then
                                        isOccupied = true break
                                    end
                                end
                                
                                if not isOccupied then
                                    local targetPlantObj = plantsToMove[plantIdx]
                                    local tpPart = targetPlantObj:IsA("Model") and targetPlantObj.PrimaryPart or targetPlantObj:FindFirstChildWhichIsA("BasePart", true)
                                    if tpPart and (Vector2.new(tpPart.Position.X, tpPart.Position.Z) - Vector2.new(pos.X, pos.Z)).Magnitude > 1.2 then
                                        Networking.Trowel.MovePlant:Fire(targetPlantObj.Name, pos, 0)
                                        task.wait(0.1)
                                    end
                                    plantIdx = plantIdx + 1
                                end
                            end
                        end
                    end
                end
            end
        end)

        pcall(function()
            if isAutoWater and #targetWaterTool > 0 then
                local myPlot = getMyPlot()
                if not myPlot then return end
                
                local canTool, canAttr = getToolFromBackpack("WateringCan", targetWaterTool)
                local plantsFolder = myPlot:FindFirstChild("Plants")
                
                if canTool and plantsFolder then
                    for _, plant in ipairs(plantsFolder:GetChildren()) do
                        if not isAutoWater then break end
                        local seedName = plant:GetAttribute("SeedName")
                        local mut = plant:GetAttribute("Mutation")
                        
                        if IsMatch(seedName, mut, targetWaterPlant, targetWaterMut) then
                            local pPart = plant:IsA("Model") and plant.PrimaryPart or plant:FindFirstChildWhichIsA("BasePart", true)
                            if pPart then
                                Networking.WateringCan.UseWateringCan:Fire(pPart.Position - Vector3.new(0, 0.3, 0), canAttr, canTool)
                                task.wait(0.15)
                            end
                        end
                    end
                end
            end
        end)

        pcall(function()
            if isAutoSprinkler and #targetSprinkler > 0 then
                local myPlot = getMyPlot()
                if not myPlot then return end
                local plantAreas = {}
                for _, area in ipairs(CollectionService:GetTagged("PlantArea")) do
                    if area:IsDescendantOf(myPlot) then table.insert(plantAreas, area) end
                end
                if #plantAreas > 0 then
                    local plotId = LocalPlayer:GetAttribute("PlotId") or tonumber(string.match(myPlot.Name, "%d+"))
                    local sprTool, sprAttr = getToolFromBackpack("Sprinkler", targetSprinkler)
					if sprTool and plotId then
						local size, cframe = plantAreas[1].Size, plantAreas[1].CFrame
						local step = customSprinklerDist
						for x = -size.X/2 + step, size.X/2 - step, step do
							for z = -size.Z/2 + step, size.Z/2 - step, step do
								if not isAutoSprinkler then return end
								local pos = (cframe * CFrame.new(x, size.Y/2, z)).Position
								local tooClose = false

								for _, obj in ipairs(myPlot:GetDescendants()) do
									if obj:IsA("Model") and table.find(listSprinklers, obj.Name) then
										local pp = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
										if pp and (Vector2.new(pos.X, pos.Z) - Vector2.new(pp.Position.X, pp.Position.Z)).Magnitude < 1 then
											tooClose = true break
										end
									end
								end

								if not tooClose then
									Networking.Place.PlaceSprinkler:Fire(pos, sprAttr, sprTool, plotId)
									task.wait(0.2)
									sprTool, sprAttr = getToolFromBackpack("Sprinkler", targetSprinkler)
									if not sprTool then return end
								end
							end
						end
					end
				end
			end
		end)

        pcall(function()
            if not isAutoSteal or stealInProgress then return end
            local Night = ReplicatedStorage:FindFirstChild("Night")
            if not Night or Night.Value ~= true then return end

            stealInProgress = true
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local rawPrompts = {}
            
            for _, v in pairs(workspace.Gardens:GetDescendants()) do
                if v.Name == "StealPrompt" and v.Parent then 
                    local plotModel = v.Parent
                    while plotModel and plotModel.Parent ~= workspace.Gardens do plotModel = plotModel.Parent end
                    
                    local pOwner = ""
                    local ownerPlayer = nil
                    
                    if plotModel then
                        local ownerId = plotModel:GetAttribute("OwnerUserId")
                        if ownerId then
                            for _, p in ipairs(Players:GetPlayers()) do
                                if p.UserId == ownerId then
                                    pOwner = p.Name
                                    ownerPlayer = p
                                    break
                                end
                            end
                        end
                    end
                    
                    local isOwnerInPlot = false
                    if ownerPlayer and ownerPlayer.Character and ownerPlayer.Character:FindFirstChild("HumanoidRootPart") and plotModel then
                        local ownerHRP = ownerPlayer.Character.HumanoidRootPart
                        local plotCenter = plotModel:GetPivot().Position
                        local distance = (ownerHRP.Position - plotCenter).Magnitude
                        if distance < 150 then isOwnerInPlot = true end
                    end
                    
                    local isTargetMatch = (stealTargetPlayer == "Anyone" or stealTargetPlayer == "" or string.find(string.lower(pOwner), string.lower(stealTargetPlayer)))
                    
                    if isTargetMatch and not isOwnerInPlot then
                        local currentObj = v.Parent
                        local sizeMulti = 0
                        local seedName, fMut = nil, nil
                        
                        while currentObj and currentObj ~= workspace do
                            if currentObj:GetAttribute("SeedName") then
                                seedName = currentObj:GetAttribute("SeedName")
                                fMut = currentObj:GetAttribute("Mutation")
                            end
                            if currentObj:GetAttribute("SizeMulti") then sizeMulti = currentObj:GetAttribute("SizeMulti") end
                            currentObj = currentObj.Parent
                        end
                        
                        local fruitModel = v.Parent
                        if fruitModel and fruitModel:GetAttribute("Mutation") then
                            local actMut = fruitModel:GetAttribute("Mutation")
                            if actMut ~= "" and actMut ~= "None" then fMut = actMut end
                        end
                        
                        if sizeMulti >= stealMinValue and IsMatch(seedName, fMut, targetSteal, targetStealMut) then
                            table.insert(rawPrompts, {prompt = v, size = sizeMulti, owner = pOwner})
                        end
                    end
                end
            end

            if #rawPrompts == 0 then stealInProgress = false return end

            if stealMode == "Highest Value" then table.sort(rawPrompts, function(a, b) return a.size > b.size end)
            elseif stealMode == "Lowest Value" then table.sort(rawPrompts, function(a, b) return a.size < b.size end) end

            local stolen = 0
            
            for _, data in ipairs(rawPrompts) do
                if not isAutoSteal then break end
                if data.prompt and data.prompt.Parent then
                    local prompt = data.prompt
                    local fruitModel = prompt.Parent
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    
                    SmartMove(fruitModel:GetPivot() * CFrame.new(0, 2.8, 0))
                    
                    if hrp then
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        hrp.RotVelocity = Vector3.new(0, 0, 0)
                        hrp.Anchored = true
                    end

                    if not prompt.Parent or not fruitModel.Parent then
                        if hrp then hrp.Anchored = isFrozen end
                        continue
                    end

                    SmartInteract(prompt)

                    local stoleSuccess = false
                    local checkStart = tick()
                    while tick() - checkStart < 0.6 do
                        if not fruitModel.Parent then
                            stoleSuccess = true
                            break
                        end
                        task.wait(0.05)
                    end

                    if not stoleSuccess and prompt.Parent and fruitModel.Parent then
                        SmartInteract(prompt)
                        task.wait(0.2)
                    end
                    
                    if hrp then hrp.Anchored = isFrozen end
                    stolen = stolen + 1
                    task.wait(0.05)
                    
                    if stolen >= stealReturnLimit or stolen >= #rawPrompts then
                        if isAutoRejoinSteal then
                            Library:Notify({ Title = "Auto Steal", Text = "Limit reached! Rejoining...", Lifetime = 3 })
                            task.wait(0.5)
                            doRejoin()
                        else
                            Library:Notify({ Title = "Auto Steal", Text = "Limit reached! Returning to garden...", Lifetime = 3 })
                            task.wait(0.5)
                            if savedGardenCFrame then SmartMove(savedGardenCFrame) else tpToMyGarden() end
                        end
                        stealInProgress = false
                        return
                    end
                end
            end
            
            if isAutoRejoinSteal then
                Library:Notify({ Title = "Auto Steal", Text = "Finished stealing! Rejoining...", Lifetime = 3 })
                task.wait(0.5)
                doRejoin()
            else
                Library:Notify({ Title = "Auto Steal", Text = "Finished stealing! Returning to garden...", Lifetime = 3 })
                task.wait(0.5)
                if savedGardenCFrame then SmartMove(savedGardenCFrame) else tpToMyGarden() end
            end
            stealInProgress = false
        end)

        pcall(function()
            if isAutoOpenPacks or isAutoOpenCrates or isAutoOpenEggs then
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if backpack then
                    for _, item in ipairs(backpack:GetChildren()) do
                        if isAutoOpenPacks and item:GetAttribute("SeedPack") then Networking.SeedPack.OpenSeedPack:Fire(item:GetAttribute("SeedPack")) task.wait(0.5) end
                        if isAutoOpenCrates and item:GetAttribute("Crate") then Networking.Crate.OpenCrate:Fire(item:GetAttribute("Crate")) task.wait(0.5) end
                        if isAutoOpenEggs and item:GetAttribute("Egg") then Networking.Egg.OpenEgg:Fire(item:GetAttribute("Egg")) task.wait(0.5) end
                    end
                end
            end
        end)

        pcall(function()
            if not isAutoTame then return end
            
            local wildSpawns = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("WildPetSpawns")
            local wildRefs = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("WildPetRef")
            
            if wildSpawns and wildRefs then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                for _, pet in ipairs(wildSpawns:GetChildren()) do
                    if not isAutoTame then break end 
                    if pet:IsA("Model") then
                        local petName = pet:GetAttribute("PetName") or string.split(pet.Name, "_")[2] or pet.Name
                        local uuid = pet.Name:match("WildPet_%w+_WildPet_(.+)")
                        local refPart = uuid and wildRefs:FindFirstChild("WildPet_" .. uuid)
                        local rarity = refPart and refPart:GetAttribute("Rarity") or "Common"
                        
                        local isMatch = false
                        if table.find(tameTargets, "All") then isMatch = true
                        elseif table.find(tameTargets, petName) or table.find(tameTargets, rarity) then isMatch = true end
                        
                        if isMatch then
                            local prompt = pet:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt and prompt.Enabled and prompt.Parent then
                                local targetPos = (prompt.Parent.CFrame and prompt.Parent.CFrame.Position) or pet:GetPivot().Position
                                SmartMove(CFrame.new(targetPos) * CFrame.new(0, 3, 0))
                                hrp.Velocity = Vector3.new(0,0,0)
                                hrp.RotVelocity = Vector3.new(0,0,0)
                                SmartInteract(prompt)
                                task.wait(0.5)
                            end
                        end
                    end
                end
            end
        end)

        pcall(function()
            if isAutoCollect and collectTargets and #collectTargets > 0 then
                local targets = {
                    workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("SeedPackSpawnServerLocations"),
                    workspace:FindFirstChild("DroppedItems")
                }
                
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local foundAnyThisTick = false
                
                for _, folder in ipairs(targets) do
                    if folder then
                        for _, item in ipairs(folder:GetChildren()) do
                            local itemName = string.lower(item.Name)
                            local isGold = (item:GetAttribute("GoldSeed") == true) or string.find(itemName, "gold")
                            local isRainbow = (item:GetAttribute("RainbowSeed") == true) or string.find(itemName, "rainbow")
                            
                            local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt and not isGold and not isRainbow then
                                local promptText = string.lower((prompt.ObjectText or "") .. " " .. (prompt.ActionText or ""))
                                if string.find(promptText, "gold") then isGold = true end
                                if string.find(promptText, "rainbow") then isRainbow = true end
                            end

                            local isRandom = not isGold and not isRainbow
                            local shouldCollect = false
                            if table.find(collectTargets, "All") then shouldCollect = true
                            else
                                if isGold and table.find(collectTargets, "Gold") then shouldCollect = true end
                                if isRainbow and table.find(collectTargets, "Rainbow") then shouldCollect = true end
                                if isRandom and table.find(collectTargets, "Random Seed") then shouldCollect = true end
                            end

                            if shouldCollect and prompt and prompt.Parent then
                                foundAnyThisTick = true
                                isCollectingDrops = true
                                collectIdleTimer = 0 
                                local targetPos = (prompt.Parent.CFrame and prompt.Parent.CFrame.Position) or item:GetPivot().Position
                                SmartMove(CFrame.new(targetPos) * CFrame.new(0, 3, 0))
                                SmartInteract(prompt)
                            end
                        end
                    end
                end

                if isCollectingDrops and not foundAnyThisTick then
                    if collectMode == "Collect & Back" then
                        collectIdleTimer = collectIdleTimer + 0.5 
                        if collectIdleTimer >= collectWaitTime then
                            isCollectingDrops = false
                            collectIdleTimer = 0
                            tpToMyGarden()
                            task.wait(0.5) 
                        end
                    else
                        isCollectingDrops = false
                        collectIdleTimer = 0
                    end
                end
            end
        end)

        pcall(function()
            if isAntiStealEnabled then
                local Night = ReplicatedStorage:FindFirstChild("Night")
                if Night and Night.Value == true then
                    local myPlot = getMyPlot()
                    if myPlot then
                        local plotCenter = myPlot:GetPivot().Position
                        local char = LocalPlayer.Character
                        local myHrp = char and char:FindFirstChild("HumanoidRootPart")
                        local myHum = char and char:FindFirstChild("Humanoid")
                        local intruderHRP = nil
                        
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                local targetHRP = p.Character.HumanoidRootPart
                                local dist = (targetHRP.Position - plotCenter).Magnitude
                                if dist < 120 then 
                                    intruderHRP = targetHRP
                                    break
                                end
                            end
                        end
                        
                        if intruderHRP and myHrp and myHum then
                            equipToolByName("Shovel")
                            if not isFlingEnabled and FlingToggle then FlingToggle:Set(true) end
                            myHum.Sit = false
                            myHrp.RotVelocity = Vector3.new(0, 50000, 0)
                            local bounceEffect = math.sin(tick() * 15) * 3 
                            myHrp.CFrame = intruderHRP.CFrame * CFrame.new(0, bounceEffect, 0)
                        end
                    end
                end
            end
        end)
        
        pcall(function()
            if isPetFinder then
                local wildSpawns = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("WildPetSpawns")
                local wildRefs = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("WildPetRef")
                
                if wildSpawns then
                    local targetFoundInServer = false
                    for _, petModel in ipairs(wildSpawns:GetChildren()) do
                        if petModel:IsA("Model") then
                            local prompt = petModel:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt and (string.find(string.lower(prompt.ActionText), "tame") or string.find(string.lower(prompt.ActionText), "buy")) then
                                local petName = petModel:GetAttribute("PetName")
                                if not petName then petName = string.split(petModel.Name, "_")[2] or petModel.Name end
                                local uuid = petModel.Name:match("WildPet_%w+_WildPet_(.+)")
                                local refPart = uuid and wildRefs and wildRefs:FindFirstChild("WildPet_" .. uuid)
                                local rarity = refPart and refPart:GetAttribute("Rarity") or "Common"
                                local isMatch = false
                                
                                if table.find(finderTargetName, "All Pets") then isMatch = true
                                else
                                    for _, target in ipairs(finderTargetName) do
                                        if string.find(string.lower(petName), string.lower(target)) then isMatch = true break end
                                    end
                                end
                                
                                if isMatch and not table.find(finderTargetRarity, "Any") then
                                    local rarityMatch = false
                                    for _, targetR in ipairs(finderTargetRarity) do
                                        if string.lower(targetR) == string.lower(rarity) then rarityMatch = true break end
                                    end
                                    isMatch = rarityMatch 
                                end

                                if isMatch then
                                    targetFoundInServer = true
                                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    if hrp then
                                        SmartMove(petModel:GetPivot() * CFrame.new(0, 3, 0))
                                        hrp.Velocity = Vector3.new(0, 0, 0)
                                        hrp.RotVelocity = Vector3.new(0, 0, 0)
                                        Networking.Pets.WildPetTame:Fire(petModel)
                                        SmartInteract(prompt)
                                        task.wait(1)
                                    end
                                end
                            end
                        end
                    end
                    
                    if not targetFoundInServer then
                        if tick() - serverStartTime > 10 then
                            isPetFinder = false
                            Library:Notify({ Title = "Pet Finder", Text = "No targets found! Server Hopping...", Lifetime = 3 })
                            task.wait(1)
                            ServerHop()
                        end
                    end
                end
            end
        end)

        getgenv()._favCache = getgenv()._favCache or {}
        getgenv()._unfavCache = getgenv()._unfavCache or {}

        if not getgenv()._isAutoFavRunning and (isAutoFavorite or isAutoUnfavorite) then
            getgenv()._isAutoFavRunning = true
            task.spawn(function()
                pcall(function()
                    local bp = LocalPlayer:FindFirstChild("Backpack")
                    if bp then
                        for _, item in ipairs(bp:GetChildren()) do
                            if item:GetAttribute("FruitName") or item:GetAttribute("IsFruit") then
                                local fruitName = item:GetAttribute("FruitName") or item:GetAttribute("Fruit") or string.gsub(item.Name, "%s*%[%d+%.%d+kg%]", "")
                                local isMatch = false
                                if table.find(targetFavFruits, "All") then isMatch = true
                                elseif fruitName then
                                    for _, target in ipairs(targetFavFruits) do
                                        if string.find(string.lower(fruitName), string.lower(target)) then isMatch = true break end
                                    end
                                end
                                
                                if isMatch then
                                    local itemId = item:GetAttribute("Id") or item:GetAttribute("UniqueId")
                                    if itemId then
                                        if isAutoFavorite and not getgenv()._favCache[itemId] then
                                            Networking.Backpack.SetFruitFavorite:Fire(itemId, true)
                                            getgenv()._favCache[itemId] = true
                                            getgenv()._unfavCache[itemId] = nil 
                                            task.wait(0.05)
                                        elseif isAutoUnfavorite and not getgenv()._unfavCache[itemId] then
                                            Networking.Backpack.SetFruitFavorite:Fire(itemId, false)
                                            getgenv()._unfavCache[itemId] = true
                                            getgenv()._favCache[itemId] = nil 
                                            task.wait(0.05)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
                getgenv()._isAutoFavRunning = false
            end)
        end

        if not getgenv()._isAutoBargainRunning and isAutoBargain then
            getgenv()._isAutoBargainRunning = true
            task.spawn(function()
                pcall(function()
                    Networking.NPCS.AskBidAll:Fire()
                    task.wait(2) 
                end)
                getgenv()._isAutoBargainRunning = false
            end)
        end

if not getgenv()._giftHooked then
    getgenv()._giftHooked = true
    pcall(function()
        Networking.Gifting.Prompted.OnClientEvent:Connect(function(playerInstance, giftId)
            if isAutoAcceptGift and playerInstance then
                Networking.Gifting.Response:Fire(playerInstance, true)
                Library:Notify({ Title = "Gift Accepted", Text = "Received gift directly from " .. tostring(playerInstance), Lifetime = 3 })
            end
        end)
    end)
end

if not getgenv()._isAutoMailRunning and (isAutoClaimMail or isAutoSendMail or isAutoSendByValue or isAutoSendByFruitValue) then
    getgenv()._isAutoMailRunning = true
    task.spawn(function()
        pcall(function()
            if isAutoClaimMail then
                local success, inboxData = pcall(function() return Networking.Mailbox.OpenInbox:Fire() end)
                if success and type(inboxData) == "table" then
                    local claimCount = 0
                    for mailId, mailInfo in pairs(inboxData) do
                        local cSuccess, cRes = pcall(function() return Networking.Mailbox.Claim:Fire(mailId) end)
                        if cSuccess then claimCount = claimCount + 1 task.wait(0.8) end
                    end
                    if claimCount > 0 then
                        Library:Notify({ Title = "Mailbox", Text = "Successfully claimed " .. claimCount .. " packages!", Lifetime = 3 })
                    end
                end
            end

            if (isAutoSendMail or isAutoSendByValue or isAutoSendByFruitValue) and targetMailPlayer ~= "" then
                if isAutoSendMail and targetMailAmount > 0 and mailSentCount >= targetMailAmount then
                    isAutoSendMail = false
                    if SendMailToggle then SendMailToggle:Set(false) end
                    Library:Notify({ Title = "Auto Send", Text = "Quantity Limit reached! Sent " .. mailSentCount .. " items.", Lifetime = 4 })
                end

                if isAutoSendByValue and mailMinValue > 0 and currentSentValue >= mailMinValue then
                    isAutoSendByValue = false
                    if SendValueToggle then SendValueToggle:Set(false) end
                    local abbrevTotal = getgenv().NemesisAbbreviate and getgenv().NemesisAbbreviate(currentSentValue) or tostring(currentSentValue)
                    Library:Notify({ Title = "Auto Send Value", Text = "Target Reached! Sent ¢" .. abbrevTotal .. " in total.", Lifetime = 5 })
                end

                if not isAutoSendMail and not isAutoSendByValue and not isAutoSendByFruitValue then return end

                local targetUserId = nil
                local tPlayer = Players:FindFirstChild(targetMailPlayer)
                if tPlayer then targetUserId = tPlayer.UserId
                else
                    local isFound, uId = pcall(function() return Networking.Mailbox.LookupPlayer:Fire(targetMailPlayer) end)
                    if isFound and type(uId) == "number" then targetUserId = uId end
                end

                if targetUserId then
                    local PlayerStateClient = require(game:GetService("ReplicatedStorage").ClientModules.PlayerStateClient)
                    local replica = PlayerStateClient:GetLocalReplica()
                    
                    if replica and replica.Data and replica.Data.Inventory then
                        local inventory = replica.Data.Inventory
                        local batchPayload = {}
                        local currentBatchCount = 0

                        if isAutoSendMail and #targetMailSeeds > 0 and inventory.Seeds then
                            for seedName, seedCount in pairs(inventory.Seeds) do
                                local isMatch = false
                                if table.find(targetMailSeeds, "All") or table.find(targetMailSeeds, "All Seeds") then
                                    isMatch = true
                                else
                                    for _, tName in ipairs(targetMailSeeds) do
                                        if string.find(string.lower(seedName), string.lower(tName)) then isMatch = true break end
                                    end
                                end

                                if isMatch and seedCount > 0 then
                                    local amountToSend = seedCount
                                    if targetMailAmount > 0 then
                                        local remaining = targetMailAmount - mailSentCount - currentBatchCount
                                        if amountToSend > remaining then amountToSend = remaining end
                                    end
                                    if currentBatchCount + amountToSend > 18 then amountToSend = 18 - currentBatchCount end
                                    if amountToSend > 0 then
                                        table.insert(batchPayload, { Category = "Seeds", ItemKey = seedName, Count = amountToSend })
                                        currentBatchCount = currentBatchCount + amountToSend
                                    end
                                end
                                if currentBatchCount >= 18 then break end
                            end
                        end

                        if isAutoSendMail and #targetMailPets > 0 and inventory.Pets and currentBatchCount < 18 then
                            for petUUID, petData in pairs(inventory.Pets) do
                                if petData.Equipped ~= true then
                                    local petName = petData.Name or petData.PetName or petData.Pet or ""
                                    local isMatch = false
                                    
                                    if table.find(targetMailPets, "All") or table.find(targetMailPets, "All Pets") then
                                        isMatch = true
                                    else
                                        for _, tName in ipairs(targetMailPets) do
                                            if string.find(string.lower(petName), string.lower(tName)) then isMatch = true break end
                                        end
                                    end

                                    if isMatch then
                                        if targetMailAmount > 0 and (mailSentCount + currentBatchCount) >= targetMailAmount then break end
                                        if currentBatchCount >= 18 then break end
                                        pcall(function() Networking.Backpack.SetFruitFavorite:Fire(petUUID, false) end)
                                        table.insert(batchPayload, { Category = "Pets", ItemKey = petUUID, Count = 1 })
                                        currentBatchCount = currentBatchCount + 1
                                    end
                                end
                            end
                        end

                        if isAutoSendByValue and currentBatchCount < 18 then
                            local fruitList = {}
                            local sources = {LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character}
                            for _, source in ipairs(sources) do
                                if source then
                                    for _, obj in ipairs(source:GetChildren()) do
                                        local fName = obj:GetAttribute("FruitName") or obj:GetAttribute("Fruit")
                                        local itemId = obj:GetAttribute("Id") or obj:GetAttribute("UniqueId")
                                        if fName and itemId and not obj:GetAttribute("MailProcessing") then
                                            local sMulti = obj:GetAttribute("SizeMultiplier") or obj:GetAttribute("SizeMulti") or 1
                                            local mut = obj:GetAttribute("Mutation")
                                            local decay = obj:GetAttribute("DecayAlpha") or 0
                                            local fruitValue = 0
                                            if getgenv().NemesisGetFruitValue then fruitValue = getgenv().NemesisGetFruitValue(fName, sMulti, mut, decay) end
                                            
                                            if fruitValue > 0 then
                                                table.insert(fruitList, { obj = obj, id = itemId, value = fruitValue })
                                            end
                                        end
                                    end
                                end
                            end
                            table.sort(fruitList, function(a, b) return a.value > b.value end)
                            
                            for _, data in ipairs(fruitList) do
                                if currentBatchCount >= 18 then break end
                                if mailMaxValue > 0 and (currentSentValue + data.value) > mailMaxValue then continue end
                                pcall(function() Networking.Backpack.SetFruitFavorite:Fire(data.id, false) end)
                                table.insert(batchPayload, { Category = "HarvestedFruits", ItemKey = data.id, Count = 1 })
                                currentBatchCount = currentBatchCount + 1
                                currentSentValue = currentSentValue + data.value
                                data.obj:SetAttribute("MailProcessing", true)
                                if mailMinValue > 0 and currentSentValue >= mailMinValue then break end
                            end
                        end

                        if isAutoSendByFruitValue and currentBatchCount < 18 then
                            local sources = {LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character}
                            for _, source in ipairs(sources) do
                                if source then
                                    for _, obj in ipairs(source:GetChildren()) do
                                        if currentBatchCount >= 18 then break end
                                        local fName = obj:GetAttribute("FruitName") or obj:GetAttribute("Fruit")
                                        local itemId = obj:GetAttribute("Id") or obj:GetAttribute("UniqueId")
                                        if fName and itemId and not obj:GetAttribute("MailProcessing") then
                                            local sMulti = obj:GetAttribute("SizeMultiplier") or obj:GetAttribute("SizeMulti") or 1
                                            local mut = obj:GetAttribute("Mutation")
                                            local decay = obj:GetAttribute("DecayAlpha") or 0
                                            local fruitValue = 0
                                            if getgenv().NemesisGetFruitValue then fruitValue = getgenv().NemesisGetFruitValue(fName, sMulti, mut, decay) end
                                            if fruitValue >= mailMinFruitValue and fruitValue <= mailMaxFruitValue then
                                                pcall(function() Networking.Backpack.SetFruitFavorite:Fire(itemId, false) end)
                                                table.insert(batchPayload, { Category = "HarvestedFruits", ItemKey = itemId, Count = 1 })
                                                currentBatchCount = currentBatchCount + 1
                                                obj:SetAttribute("MailProcessing", true)
                                            end
                                        end
                                    end
                                end
                                if currentBatchCount >= 18 then break end
                            end
                        end

                        if #batchPayload > 0 then
                            local isSent = false
                            pcall(function()
                                local response = nil
                                if Networking.Mailbox.SendBatch.Invoke then response = Networking.Mailbox.SendBatch:Invoke(targetUserId, batchPayload, customMailMessage)
                                else response = Networking.Mailbox.SendBatch:Fire(targetUserId, batchPayload, customMailMessage) end
                                if type(response) == "table" and response.Success == false then isSent = false else isSent = true end
                            end)
                            
                            if isSent then
                                if isAutoSendMail then mailSentCount = mailSentCount + currentBatchCount end
                                local displayMsg = ""
                                if isAutoSendByValue then
                                    local abbrevProgress = getgenv().NemesisAbbreviate and getgenv().NemesisAbbreviate(currentSentValue) or tostring(currentSentValue)
                                    local abbrevMin = getgenv().NemesisAbbreviate and getgenv().NemesisAbbreviate(mailMinValue) or tostring(mailMinValue)
                                    displayMsg = "Package Sent! Total Transfer: ¢" .. abbrevProgress .. " / ¢" .. abbrevMin
                                elseif isAutoSendByFruitValue then displayMsg = "Filtered & Sent " .. currentBatchCount .. " fruits!"
                                else displayMsg = "Sent a batch of " .. currentBatchCount .. " items..." end
                                
                                Library:Notify({ Title = "Auto Send", Text = displayMsg, Lifetime = 2 })
                                task.wait(2.5) 
                            else
                                Library:Notify({ Title = "Send Failed", Text = "Server rejected the mail. Retrying...", Lifetime = 3 })
                                task.wait(3)
                            end
                            
                            local sources = {LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character}
                            for _, source in ipairs(sources) do
                                if source then
                                    for _, obj in ipairs(source:GetChildren()) do
                                        if obj:GetAttribute("MailProcessing") then obj:SetAttribute("MailProcessing", nil) end
                                    end
                                end
                            end
                        else
                            Library:Notify({ Title = "Auto Send", Text = "Items/Fruits not found! Waiting...", Lifetime = 3 })
                            task.wait(3) 
                        end
                    end
                else
                    Library:Notify({ Title = "Auto Send", Text = "Player '".. targetMailPlayer .."' not found! Typo?", Lifetime = 3 })
                    task.wait(3)
                end
            end
        end)
        getgenv()._isAutoMailRunning = false
    end)
end

    end
end)

Library:Notify({ Title = "ZUPERMING", Text = "Thanks for using our script!", Lifetime = 5 })