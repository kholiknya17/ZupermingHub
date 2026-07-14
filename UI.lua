local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ZuperMingUI.lua"))()

local MainWindow = Library:CreateWindow({
    Title = "ZUPERMING",
    SubText = ".gg/zuperming",
    Image = "rbxassetid://76140924722866",
    IsMobile = true
})

local CombatTab = MainWindow:AddTab({
    Text = "Combat",
    Icon = "rbxassetid://108020878442937"
})

local TestingTab = MainWindow:AddTab({
    Text = "Testing",
    Icon = "rbxassetid://108020878442937"
})

local AimSection = CombatTab:AddSection({
    Title = "Aimbot Settings",
    Side = "Left"
})

AimSection:AddToggle({
    Text = "Enable Aimbot",
    Flag = "aimbot_toggle",
    Default = true,
    Callback = function(value)
        print("Aimbot:", value)
    end
})

AimSection:AddSlider({
    Text = "FOV Radius",
    Flag = "aimbot_fov",
    Min = 0,
    Max = 360,
    Default = 120,
    Suffix = "°",
    Callback = function(value)
        print("FOV:", value)
    end
})

AimSection:AddDropdown({
    Text = "Hit Part",
    Flag = "aimbot_hit_part",
    Options = {"Head", "Chest", "Legs"},
    Default = "Head",
    Callback = function(value)
        print("Target:", value)
    end
})

local VisualSection = CombatTab:AddSection({
    Title = "Visual Settings",
    Side = "Right"
})

VisualSection:AddColorPicker({
    Text = "FOV Color",
    Flag = "visual_fov_color",
    Default = Color3.fromRGB(233, 30, 99),
    Transparency = 0.5,
    Callback = function(color, alpha)
        print("Color set")
    end
})

VisualSection:AddKeyPicker({
    Text = "ESP Key",
    Flag = "visual_esp_key",
    Default = "RightShift",
    Mode = "Toggle",
    Callback = function(value)
        print("Key state:", value)
    end
})

local MiscSection = TestingTab:AddSection({
    Title = "Misc Elements",
    Side = "Left"
})

MiscSection:AddLabel({
    Text = "Status: Premium User"
})

MiscSection:AddButton({
    Text = "Execute Speed Hack",
    Callback = function()
        print("Speed Hack Activated")
    end
})

MiscSection:AddInput({
    Text = "Custom Jump Power",
    Flag = "misc_jump_power",
    Default = "50",
    PlaceHolder = "Type value...",
    Callback = function(text)
        print("Jump Power:", text)
    end
})

Library:InitConfigs(MainWindow)

Library:Notify({
    Title = ".gg/x2zu",
    Text = "Welcome to ZUPERMING",
    Lifetime = 3
})