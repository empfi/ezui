-- EZUI is a small Roblox UI library for tabs, sliders, toggles, selectors, and notifications.

local Players              = game:GetService("Players")
local UserInputService     = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService         = game:GetService("TweenService")
local HttpService          = game:GetService("HttpService")
local CoreGui              = game:GetService("CoreGui")
local LocalPlayer          = Players.LocalPlayer

-- Theme presets
local PRESET_THEMES = {
    Green = {
        WindowBg       = Color3.fromRGB(15, 15, 15),
        HeaderBg       = Color3.fromRGB(18, 18, 18),
        SubHeaderBg    = Color3.fromRGB(10, 10, 10),
        TabBarBg       = Color3.fromRGB(18, 18, 18),
        HighlightBg    = Color3.fromRGB(24, 58, 31),
        TextWhite      = Color3.fromRGB(255, 255, 255),
        TextGray       = Color3.fromRGB(150, 150, 150),
        AccentColor    = Color3.fromRGB(46, 180, 74),
        ToggleOff      = Color3.fromRGB(50, 50, 50),
        SliderTrack    = Color3.fromRGB(60, 60, 60),
        BorderGray     = Color3.fromRGB(30, 30, 30),
    },
    Purple = {
        WindowBg       = Color3.fromRGB(15, 15, 18),
        HeaderBg       = Color3.fromRGB(18, 18, 22),
        SubHeaderBg    = Color3.fromRGB(10, 10, 14),
        TabBarBg       = Color3.fromRGB(18, 18, 22),
        HighlightBg    = Color3.fromRGB(45, 25, 65),
        TextWhite      = Color3.fromRGB(255, 255, 255),
        TextGray       = Color3.fromRGB(150, 150, 150),
        AccentColor    = Color3.fromRGB(147, 51, 234),
        ToggleOff      = Color3.fromRGB(50, 50, 50),
        SliderTrack    = Color3.fromRGB(60, 60, 60),
        BorderGray     = Color3.fromRGB(30, 30, 30),
    },
    Blue = {
        WindowBg       = Color3.fromRGB(14, 16, 20),
        HeaderBg       = Color3.fromRGB(18, 20, 26),
        SubHeaderBg    = Color3.fromRGB(10, 12, 16),
        TabBarBg       = Color3.fromRGB(18, 20, 26),
        HighlightBg    = Color3.fromRGB(20, 45, 75),
        TextWhite      = Color3.fromRGB(255, 255, 255),
        TextGray       = Color3.fromRGB(150, 150, 150),
        AccentColor    = Color3.fromRGB(37, 99, 235),
        ToggleOff      = Color3.fromRGB(50, 50, 50),
        SliderTrack    = Color3.fromRGB(60, 60, 60),
        BorderGray     = Color3.fromRGB(30, 30, 30),
    },
    Red = {
        WindowBg       = Color3.fromRGB(18, 14, 14),
        HeaderBg       = Color3.fromRGB(22, 18, 18),
        SubHeaderBg    = Color3.fromRGB(14, 10, 10),
        TabBarBg       = Color3.fromRGB(22, 18, 18),
        HighlightBg    = Color3.fromRGB(65, 25, 25),
        TextWhite      = Color3.fromRGB(255, 255, 255),
        TextGray       = Color3.fromRGB(150, 150, 150),
        AccentColor    = Color3.fromRGB(225, 29, 72),
        ToggleOff      = Color3.fromRGB(50, 50, 50),
        SliderTrack    = Color3.fromRGB(60, 60, 60),
        BorderGray     = Color3.fromRGB(30, 30, 30),
    },
    Cyan = {
        WindowBg       = Color3.fromRGB(14, 18, 20),
        HeaderBg       = Color3.fromRGB(18, 22, 24),
        SubHeaderBg    = Color3.fromRGB(10, 14, 16),
        TabBarBg       = Color3.fromRGB(18, 22, 24),
        HighlightBg    = Color3.fromRGB(20, 60, 70),
        TextWhite      = Color3.fromRGB(255, 255, 255),
        TextGray       = Color3.fromRGB(150, 150, 150),
        AccentColor    = Color3.fromRGB(6, 182, 212),
        ToggleOff      = Color3.fromRGB(50, 50, 50),
        SliderTrack    = Color3.fromRGB(60, 60, 60),
        BorderGray     = Color3.fromRGB(30, 30, 30),
    },
    Dark = {
        WindowBg       = Color3.fromRGB(12, 12, 12),
        HeaderBg       = Color3.fromRGB(16, 16, 16),
        SubHeaderBg    = Color3.fromRGB(8, 8, 8),
        TabBarBg       = Color3.fromRGB(16, 16, 16),
        HighlightBg    = Color3.fromRGB(35, 35, 35),
        TextWhite      = Color3.fromRGB(255, 255, 255),
        TextGray       = Color3.fromRGB(150, 150, 150),
        AccentColor    = Color3.fromRGB(200, 200, 200),
        ToggleOff      = Color3.fromRGB(50, 50, 50),
        SliderTrack    = Color3.fromRGB(60, 60, 60),
        BorderGray     = Color3.fromRGB(30, 30, 30),
    }
}

local ROW_HEIGHT = 28
local MAX_VISIBLE = 9

-- Utility helpers
local function tween(obj, time, props)
    local t = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local FONT_ALIAS = {
    gotham         = "Gotham",
    gothammedium   = "GothamMedium",
    gothambold     = "GothamBold",
    roboto         = "Roboto",
    robotomedium   = "Roboto",
    sourcesans     = "SourceSans",
    sourcesansbold = "SourceSansBold",
    fredokaone     = "FredokaOne",
    arcade         = "Arcade",
    bodoni         = "Bodoni",
    fantasy        = "Fantasy",
    jura           = "Jura",
    nunito         = "Nunito",
    sarpanch       = "Sarpanch",
    ubuntu         = "Ubuntu",
    buildersans    = "BuilderSans",
    code           = "Code"
}

local function getEnumFontByName(nameStr)
    if not nameStr then return nil end
    local ok, result = pcall(function()
        return Enum.Font[nameStr]
    end)
    if ok and result then return result end
    return nil
end

local function parseFont(fontVal)
    if typeof(fontVal) == "EnumItem" then
        return fontVal
    end
    
    if type(fontVal) == "string" then
        local direct = getEnumFontByName(fontVal)
        if direct then return direct end

        local lower = fontVal:lower()
        if FONT_ALIAS[lower] then
            local aliasResult = getEnumFontByName(FONT_ALIAS[lower])
            if aliasResult then return aliasResult end
        end

        local found = nil
        pcall(function()
            for _, item in ipairs(Enum.Font:GetEnumItems()) do
                local itemName = item.Name:lower()
                if itemName == lower or itemName:find(lower) then
                    found = item
                    break
                end
            end
        end)
        if found then return found end
    end

    return getEnumFontByName("GothamMedium") or Enum.Font:GetEnumItems()[1]
end

-- Clean & Verified Standalone Icon Set (Lucide Decals & Roblox Engine Textures)
-- Supports lookup by PascalCase (EZUI.Icons.Home), lowercase ("home"), or prefix ("lucide-home")
local BUILTIN_ICONS = {
    -- ── Core Navigation & Layout ────────────────────────────────────
    Home            = "rbxassetid://10709762879",      -- Fluent Lucide Home 🏠
    Menu            = "rbxassetid://10709796014",
    Sidebar         = "rbxassetid://10709796440",
    LayoutGrid      = "rbxassetid://10709796014",

    -- ── User / Social ────────────────────────────────────────────────
    User            = "rbxassetid://10709813840",      -- Fluent Lucide User 👤
    Users           = "rbxassetid://10709814467",
    Crown           = "rbxassetid://10709788484",      -- Fluent Lucide Crown 👑
    Trophy          = "rbxassetid://10709812739",
    Star            = "rbxassetid://10709808847",      -- Fluent Lucide Star ⭐
    Medal           = "rbxassetid://10709769406",

    -- ── System & Settings ────────────────────────────────────────────
    Settings        = "rbxassetid://10709806440",      -- Fluent Lucide Settings Gear ⚙️
    Wrench          = "rbxassetid://10709816353",      -- Fluent Lucide Wrench 🔧
    Sliders         = "rbxassetid://10709807572",      -- Fluent Lucide Sliders 🎚️
    Power           = "rbxassetid://10709802260",      -- Fluent Lucide Power ⏻
    Terminal        = "rbxassetid://10709810488",
    Font            = "rbxassetid://10709811440",      -- Fluent Lucide Type/Font 'A' 🔤

    -- ── Security & Auth ──────────────────────────────────────────────
    Shield          = "rbxassetid://10709806967",      -- Fluent Lucide Shield 🛡️
    Lock            = "rbxassetid://10709797280",      -- Fluent Lucide Lock 🔒
    Unlock          = "rbxassetid://10709813426",
    Eye             = "rbxassetid://10709791583",      -- Fluent Lucide Eye 👁️
    Key             = "rbxassetid://10709795774",

    -- ── Notifications & Status ───────────────────────────────────────
    Bell            = "rbxassetid://10709775704",      -- Fluent Lucide Bell 🔔
    Info            = "rbxassetid://10709752996",      -- Fluent Lucide Info Circle ℹ️
    AlertTriangle   = "rbxassetid://10709753149",      -- Fluent Lucide Alert Triangle ⚠️
    Warning         = "rbxassetid://10709753149",      -- Fluent Lucide Alert Triangle ⚠️
    Check           = "rbxasset://textures/ui/icon_checkmark.png", -- Official Engine Checkmark ✔️
    CheckCircle     = "rbxasset://textures/ui/icon_checkmark.png",
    Cross           = "rbxasset://textures/ui/icon_close.png", -- Official Engine Close X ❌
    X               = "rbxasset://textures/ui/icon_close.png", -- Official Engine Close X ❌
    XCircle         = "rbxasset://textures/ui/icon_close.png", -- Official Engine Close X ❌
    Error           = "rbxasset://textures/ui/icon_close.png", -- Official Engine Close X ❌

    -- ── Files & Media ────────────────────────────────────────────────
    Folder          = "rbxassetid://10709791763",      -- Fluent Lucide Folder 📁
    File            = "rbxassetid://10709790948",
    Image           = "rbxassetid://10709795004",      -- Fluent Lucide Image 🖼️
    Palette         = "rbxassetid://10709796440",      -- Fluent Lucide Palette 🎨
    
    -- ── Actions & Controls ───────────────────────────────────────────
    Search          = "rbxassetid://10709805646",      -- Fluent Lucide Search 🔍
    Pencil          = "rbxassetid://10709800778",
    Trash           = "rbxasset://textures/ui/icon_close.png",
    Plus            = "rbxasset://textures/ui/icon_checkmark.png",
    Minus           = "rbxasset://textures/ui/icon_close.png",

    -- ── Gaming & Aesthetics ──────────────────────────────────────────
    Speed           = "rbxassetid://7734058803",      -- Lucide Speed ⚡
    Sword           = "rbxassetid://7734060384",      -- Lucide Sword ⚔️
    Heart           = "rbxassetid://7733954760",      -- Lucide Heart ❤️
    Car             = "rbxassetid://7733715400",      -- Lucide Car 🚗
}

-- Comprehensive Lucide Icon Dataset (from https://lucide.dev/icons/)
local LUCIDE_EXTENDED = {
    ["accessibility"] = "rbxassetid://10709751939",
    ["activity"] = "rbxassetid://10709752035",
    ["air-vent"] = "rbxassetid://10709752131",
    ["airplay"] = "rbxassetid://10709752254",
    ["alarm-check"] = "rbxassetid://10709752405",
    ["alarm-clock"] = "rbxassetid://10709752630",
    ["alarm-clock-off"] = "rbxassetid://10709752508",
    ["alarm-minus"] = "rbxassetid://10709752732",
    ["alarm-plus"] = "rbxassetid://10709752825",
    ["album"] = "rbxassetid://10709752906",
    ["alert-circle"] = "rbxassetid://10709752996",
    ["alert-octagon"] = "rbxassetid://10709753064",
    ["alert-triangle"] = "rbxassetid://7733658504",
    ["align-center"] = "rbxassetid://10709753570",
    ["align-left"] = "rbxassetid://10709759764",
    ["align-right"] = "rbxassetid://10709759895",
    ["anchor"] = "rbxassetid://10709761530",
    ["aperture"] = "rbxassetid://10709761813",
    ["apple"] = "rbxassetid://10709761889",
    ["archive"] = "rbxassetid://10709762233",
    ["arrow-big-down"] = "rbxassetid://10747796644",
    ["arrow-big-left"] = "rbxassetid://10709762574",
    ["arrow-big-right"] = "rbxassetid://10709762727",
    ["arrow-big-up"] = "rbxassetid://10709762879",
    ["arrow-down"] = "rbxassetid://10709767827",
    ["arrow-left"] = "rbxassetid://10709768114",
    ["arrow-right"] = "rbxassetid://10709768347",
    ["arrow-up"] = "rbxassetid://10709768939",
    ["at-sign"] = "rbxassetid://10709769286",
    ["award"] = "rbxassetid://10709769406",
    ["axe"] = "rbxassetid://10709769508",
    ["backpack"] = "rbxassetid://10709769841",
    ["badge-check"] = "rbxassetid://10709769406",
    ["banana"] = "rbxassetid://10709770005",
    ["banknote"] = "rbxassetid://10709770178",
    ["bar-chart"] = "rbxassetid://10709773755",
    ["battery"] = "rbxassetid://10709774640",
    ["battery-charging"] = "rbxassetid://10709774068",
    ["beaker"] = "rbxassetid://10709774756",
    ["bell"] = "rbxassetid://7733674670",
    ["bell-off"] = "rbxassetid://10709775176",
    ["bike"] = "rbxassetid://10709775367",
    ["binary"] = "rbxassetid://10709775463",
    ["bookmark"] = "rbxassetid://10709775986",
    ["box"] = "rbxassetid://10709776260",
    ["bug"] = "rbxassetid://10709776735",
    ["building"] = "rbxassetid://10709776856",
    ["calculator"] = "rbxassetid://10709777114",
    ["calendar"] = "rbxassetid://10709777620",
    ["camera"] = "rbxassetid://10709777953",
    ["car"] = "rbxassetid://7733715400",
    ["check"] = "rbxasset://textures/ui/icon_checkmark.png",
    ["check-circle"] = "rbxasset://textures/ui/icon_checkmark.png",
    ["chevron-down"] = "rbxassetid://10709782230",
    ["chevron-left"] = "rbxassetid://10709782358",
    ["chevron-right"] = "rbxassetid://10709782519",
    ["chevron-up"] = "rbxassetid://10709782758",
    ["circle"] = "rbxassetid://10709783511",
    ["clipboard"] = "rbxassetid://10709784384",
    ["clock"] = "rbxassetid://10709784777",
    ["cloud"] = "rbxassetid://10709785888",
    ["code"] = "rbxassetid://10709786480",
    ["coins"] = "rbxassetid://10709786930",
    ["compass"] = "rbxassetid://10709787262",
    ["cpu"] = "rbxassetid://10709787720",
    ["credit-card"] = "rbxassetid://10709787948",
    ["crown"] = "rbxassetid://7733765398",
    ["database"] = "rbxassetid://10709788484",
    ["disc"] = "rbxassetid://10709789329",
    ["download"] = "rbxassetid://10709789785",
    ["eye"] = "rbxassetid://7733765398",
    ["eye-off"] = "rbxassetid://10709790435",
    ["file"] = "rbxassetid://10709790948",
    ["file-text"] = "rbxassetid://10709791437",
    ["film"] = "rbxassetid://10709791583",
    ["filter"] = "rbxassetid://10709791763",
    ["flame"] = "rbxassetid://10709791983",
    ["folder"] = "rbxassetid://7733799915",
    ["font"] = "rbxassetid://7734056608",
    ["gamepad"] = "rbxassetid://10709792671",
    ["gift"] = "rbxassetid://10709792984",
    ["globe"] = "rbxassetid://10709793479",
    ["hash"] = "rbxassetid://10709794017",
    ["headphones"] = "rbxassetid://10709794176",
    ["heart"] = "rbxassetid://7733954760",
    ["home"] = "rbxassetid://7733960981",
    ["image"] = "rbxassetid://7733964126",
    ["info"] = "rbxassetid://7733964808",
    ["key"] = "rbxassetid://10709795774",
    ["layers"] = "rbxassetid://10709796014",
    ["layout"] = "rbxassetid://10709796440",
    ["life-buoy"] = "rbxassetid://10709796683",
    ["link"] = "rbxassetid://10709796987",
    ["lock"] = "rbxassetid://10709797280",
    ["mail"] = "rbxassetid://10709797686",
    ["map"] = "rbxassetid://10709798085",
    ["message-square"] = "rbxassetid://10709798486",
    ["mic"] = "rbxassetid://10709798939",
    ["moon"] = "rbxassetid://10709799298",
    ["music"] = "rbxassetid://10709799637",
    ["navigation"] = "rbxassetid://10709799962",
    ["palette"] = "rbxassetid://7733978098",
    ["paperclip"] = "rbxassetid://10709800332",
    ["pencil"] = "rbxassetid://10709800778",
    ["phone"] = "rbxassetid://10709801067",
    ["pie-chart"] = "rbxassetid://10709801452",
    ["pin"] = "rbxassetid://10709801691",
    ["play"] = "rbxassetid://10709802085",
    ["plus"] = "rbxasset://textures/ui/icon_checkmark.png",
    ["power"] = "rbxassetid://7733987483",
    ["printer"] = "rbxassetid://10709802422",
    ["qr-code"] = "rbxassetid://10709802778",
    ["radio"] = "rbxassetid://10709803130",
    ["refresh-cw"] = "rbxassetid://10709803623",
    ["rocket"] = "rbxassetid://10709804077",
    ["rotate-cw"] = "rbxassetid://10709804364",
    ["rss"] = "rbxassetid://10709804675",
    ["save"] = "rbxassetid://10709804987",
    ["scissors"] = "rbxassetid://10709805260",
    ["search"] = "rbxassetid://7734052925",
    ["send"] = "rbxassetid://10709805646",
    ["server"] = "rbxassetid://10709805988",
    ["settings"] = "rbxassetid://7734053495",
    ["share"] = "rbxassetid://10709806440",
    ["shield"] = "rbxassetid://7733987483",
    ["shopping-cart"] = "rbxassetid://10709806967",
    ["shuffle"] = "rbxassetid://10709807314",
    ["skull"] = "rbxassetid://10709807572",
    ["sliders"] = "rbxassetid://7734053495",
    ["smartphone"] = "rbxassetid://10709807897",
    ["smile"] = "rbxassetid://10709808223",
    ["sparkles"] = "rbxassetid://10709808544",
    ["speaker"] = "rbxassetid://10709808847",
    ["speed"] = "rbxassetid://7734058803",
    ["star"] = "rbxassetid://7734056608",
    ["sun"] = "rbxassetid://10709809310",
    ["sword"] = "rbxassetid://7734060384",
    ["swords"] = "rbxassetid://7734060384",
    ["tag"] = "rbxassetid://10709809772",
    ["target"] = "rbxassetid://10709810143",
    ["terminal"] = "rbxassetid://10709810488",
    ["thermometer"] = "rbxassetid://10709810817",
    ["thumbs-down"] = "rbxassetid://10709811130",
    ["thumbs-up"] = "rbxassetid://10709811440",
    ["ticket"] = "rbxassetid://10709811770",
    ["timer"] = "rbxassetid://10709812130",
    ["trash"] = "rbxasset://textures/ui/icon_close.png",
    ["trophy"] = "rbxassetid://7734056608",
    ["tv"] = "rbxassetid://10709812739",
    ["twitter"] = "rbxassetid://10709813083",
    ["unlock"] = "rbxassetid://10709813426",
    ["upload"] = "rbxassetid://10709813840",
    ["user"] = "rbxassetid://7734053426",
    ["users"] = "rbxassetid://7734053426",
    ["video"] = "rbxassetid://10709814467",
    ["volume-2"] = "rbxassetid://10709814890",
    ["wallet"] = "rbxassetid://10709815340",
    ["wand"] = "rbxassetid://10709815668",
    ["warning"] = "rbxassetid://7733658504",
    ["watch"] = "rbxassetid://10709815998",
    ["wifi"] = "rbxassetid://10709816353",
    ["wrench"] = "rbxassetid://7734098254",
    ["x"] = "rbxasset://textures/ui/icon_close.png",
    ["x-circle"] = "rbxasset://textures/ui/icon_close.png",
    ["zap"] = "rbxassetid://7734058803"
}

-- Normalized Lucide & Custom Icon Resolver
-- Resolves any icon format from https://lucide.dev/icons/
-- Examples: EZUI.Icons.Home, "home", "lucide-home", "user_check", "user-check", "UserCheck"
local function _resolveIconName(str)
    if not str then return nil end
    local cleanStr = tostring(str):match("^lucide%-(.+)$") or tostring(str)
    local lower = cleanStr:lower():gsub("_", "-"):gsub("%s+", "-")

    for key, assetId in pairs(BUILTIN_ICONS) do
        local keyLower = key:lower():gsub("_", "-"):gsub("%s+", "-")
        if keyLower == lower then
            return assetId
        end
    end

    if LUCIDE_EXTENDED[lower] then
        return LUCIDE_EXTENDED[lower]
    end

    return nil
end

local function formatAssetId(icon)
    if not icon then return "" end
    local str = tostring(icon)
    -- PascalCase or exact match
    if BUILTIN_ICONS[str] then
        return BUILTIN_ICONS[str]
    end
    -- Case-insensitive / lucide- prefix lookup
    local resolved = _resolveIconName(str)
    if resolved then return resolved end

    -- Direct asset path or URL
    if str:find("rbxasset") or str:find("rbxthumb") or str:find("http") or str:find("://") then
        return str
    end
    local digits = str:match("%d+")
    if digits then
        return "rbxassetid://" .. digits
    end
    return str
local function setIconImage(imgLabel, icon)
    if not imgLabel or not icon or icon == "" then
        if imgLabel then
            imgLabel.Image = ""
            imgLabel.ImageRectOffset = Vector2.new(0, 0)
            imgLabel.ImageRectSize = Vector2.new(0, 0)
        end
        return
    end

    local res = formatAssetId(icon)
    if type(res) == "table" then
        imgLabel.Image = tostring(res.Url or res.Id or "")
        imgLabel.ImageRectOffset = res.ImageRectOffset or Vector2.new(0, 0)
        imgLabel.ImageRectSize = res.ImageRectSize or Vector2.new(0, 0)
    else
        imgLabel.Image = tostring(res)
        imgLabel.ImageRectOffset = Vector2.new(0, 0)
        imgLabel.ImageRectSize = Vector2.new(0, 0)
    end
end

local function cleanupExistingUI()
    if getgenv then
        local active = getgenv().EZUI_ActiveInstance
        if active and typeof(active) == "table" and active.Destroy then
            pcall(function() active:Destroy() end)
        end
        getgenv().EZUI_ActiveInstance = nil
    end

    local parents = {CoreGui, LocalPlayer:FindFirstChild("PlayerGui")}
    for _, parent in ipairs(parents) do
        if parent then
            for _, child in ipairs(parent:GetChildren()) do
                if child.Name == "EZUI_Library" or child.Name == "EZCleanUI" then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end
end

----------------------------------------------------------------
-- Main UI class
----------------------------------------------------------------
local EZUI = {}
EZUI.__index = EZUI
EZUI.Presets = PRESET_THEMES
EZUI.Icons = BUILTIN_ICONS

function EZUI.new(config)
    cleanupExistingUI()
    config = config or {}
    local self = setmetatable({}, EZUI)
    self.UserConfig = config
    
    self.Title = config.Title or "EZUI"
    self.LogoText = config.LogoText or "EZ"
    self.FooterText = config.FooterText or "EZUI Library | discord.gg/ezui"
    self.ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    self.Font = parseFont(config.Font or Enum.Font.GothamMedium)
    self.NotifyPosition = config.NotifyPosition or "TopRight"
    self.NotifyDuration = tonumber(config.NotifyDuration) or 4
    
    if type(config.Theme) == "string" and PRESET_THEMES[config.Theme] then
        self.Theme = table.clone(PRESET_THEMES[config.Theme])
        self.CurrentThemeName = config.Theme
    elseif type(config.Theme) == "table" then
        self.Theme = table.clone(config.Theme)
    else
        self.Theme = table.clone(PRESET_THEMES.Green)
        self.CurrentThemeName = "Green"
    end

    if config.AccentColor then
        self.Theme.AccentColor = config.AccentColor
    end

    self.Screens = {}
    self.CurrentScreen = "main"
    self.CurrentTabIndex = 1
    self.SelectedIndex = 1
    self.ScrollOffset = 0
    self.MenuVisible = true
    self.RowInstances = {}
    self.Connections = {}
    self.OnUninjectCallbacks = {}
    self.ActiveHeldKey = nil
    self.HoldThread = nil
    
    self:_buildGui()
    self:_setupInputs()

    if config.Title then
        self:SetTitle(config.Title)
    end

    if config.FooterText then
        self:SetFooterText(config.FooterText)
    end

    if config.Logo or config.LogoImage or config.LogoText then
        self:SetLogo(config.Logo or config.LogoImage or config.LogoText)
    end

    if config.Banner then
        self:SetBanner(config.Banner)
    end
    
    if getgenv then
        getgenv().EZUI_ActiveInstance = self
    end

    return self
end

function EZUI:OnUninject(callback)
    if type(callback) == "function" then
        table.insert(self.OnUninjectCallbacks, callback)
    end
end

function EZUI:Uninject()
    self:_stopKeyHold()
    self:_unbindKeys()
    
    if self.Connections then
        for _, conn in ipairs(self.Connections) do
            pcall(function() conn:Disconnect() end)
        end
        table.clear(self.Connections)
    end

    if self.OnUninjectCallbacks then
        for _, cb in ipairs(self.OnUninjectCallbacks) do
            pcall(cb)
        end
        table.clear(self.OnUninjectCallbacks)
    end

    pcall(function()
        local char = LocalPlayer and LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
    end)

    if self.Gui then
        pcall(function() self.Gui:Destroy() end)
    end

    if getgenv and getgenv().EZUI_ActiveInstance == self then
        getgenv().EZUI_ActiveInstance = nil
    end
end

function EZUI:Destroy()
    self:Uninject()
end

local NOTIFY_CONTAINERS = {}

local function getNotifyContainer(posName)
    posName = posName or "TopRight"
    if NOTIFY_CONTAINERS[posName] and NOTIFY_CONTAINERS[posName].Parent then
        return NOTIFY_CONTAINERS[posName]
    end

    local gui = CoreGui:FindFirstChild("EZUI_Notifications")
    if not gui then
        gui = Instance.new("ScreenGui")
        gui.Name = "EZUI_Notifications"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 1000
        pcall(function() gui.Parent = CoreGui end)
        if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    end

    local container = Instance.new("Frame")
    container.Name = posName .. "Container"
    container.Size = UDim2.fromOffset(260, 500)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Parent = gui

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container

    if posName == "TopRight" then
        container.AnchorPoint = Vector2.new(1, 0)
        container.Position = UDim2.new(1, -20, 0, 20)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
    elseif posName == "TopLeft" then
        container.AnchorPoint = Vector2.new(0, 0)
        container.Position = UDim2.new(0, 20, 0, 20)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
    elseif posName == "BottomRight" then
        container.AnchorPoint = Vector2.new(1, 1)
        container.Position = UDim2.new(1, -20, 1, -20)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    elseif posName == "BottomLeft" then
        container.AnchorPoint = Vector2.new(0, 1)
        container.Position = UDim2.new(0, 20, 1, -20)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    end

    NOTIFY_CONTAINERS[posName] = container
    return container
end

function EZUI:SetNotifyPosition(posName, skipSave)
    self.NotifyPosition = posName or "TopRight"
    if not skipSave then self:SaveConfig() end
end

function EZUI:SetNotifyDuration(seconds)
    self.NotifyDuration = tonumber(seconds) or 4
end

function EZUI:Notify(data)
    if type(data) == "string" then
        data = { Text = data, Type = "Info" }
    end
    data = data or {}

    local state = data.Type or data.State or "Info"
    local titleText = data.Title or data.Header or state
    local bodyText = data.Text or data.Content or data.Message or ""
    local duration = tonumber(data.Duration or data.Time or self.NotifyDuration) or 4
    local posName = data.Position or self.NotifyPosition or "TopRight"
    local font = self.Font or Enum.Font.GothamMedium

    local stateColors = {
        Info    = Color3.fromRGB(59, 130, 246),
        Warning = Color3.fromRGB(245, 158, 11),
        Error   = Color3.fromRGB(239, 68, 68)
    }

    stateColors.info = stateColors.Info
    stateColors.warning = stateColors.Warning
    stateColors.error = stateColors.Error

    local accentColor = stateColors[state] or stateColors.Info

    local defaultIcons = {
        Info    = BUILTIN_ICONS.Info,
        Warning = BUILTIN_ICONS.Warning,
        Error   = BUILTIN_ICONS.Error
    }
    defaultIcons.info = defaultIcons.Info
    defaultIcons.warning = defaultIcons.Warning
    defaultIcons.error = defaultIcons.Error

    local iconId = data.Icon or defaultIcons[state] or BUILTIN_ICONS.Info

    local container = getNotifyContainer(posName)

    local card = Instance.new("Frame")
    card.Size = UDim2.fromOffset(250, 52)
    card.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    card.BackgroundTransparency = 1
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.Parent = container

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 6)
    cardCorner.Parent = card

    local leftBar = Instance.new("Frame")
    leftBar.Size = UDim2.new(0, 3, 1, 0)
    leftBar.Position = UDim2.fromOffset(0, 0)
    leftBar.BackgroundColor3 = accentColor
    leftBar.BorderSizePixel = 0
    leftBar.BackgroundTransparency = 1
    leftBar.Parent = card

    local iconImg = Instance.new("ImageLabel")
    iconImg.Size = UDim2.fromOffset(16, 16)
    iconImg.Position = UDim2.fromOffset(12, 18)
    iconImg.BackgroundTransparency = 1
    setIconImage(iconImg, iconId)
    iconImg.ImageTransparency = 1
    iconImg.ScaleType = Enum.ScaleType.Fit
    iconImg.Parent = card

    local headerLabel = Instance.new("TextLabel")
    headerLabel.Size = UDim2.new(1, -40, 0, 18)
    headerLabel.Position = UDim2.fromOffset(36, 8)
    headerLabel.BackgroundTransparency = 1
    headerLabel.Text = titleText
    headerLabel.Font = font
    headerLabel.TextSize = 11
    headerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    headerLabel.TextTransparency = 1
    headerLabel.TextXAlignment = Enum.TextXAlignment.Left
    headerLabel.Parent = card

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -40, 0, 20)
    textLabel.Position = UDim2.fromOffset(36, 26)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = bodyText
    textLabel.Font = font
    textLabel.TextSize = 10
    textLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    textLabel.TextTransparency = 1
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.Parent = card

    tween(card, 0.3, {BackgroundTransparency = 0.15})
    tween(leftBar, 0.3, {BackgroundTransparency = 0})
    tween(iconImg, 0.3, {ImageTransparency = 0})
    tween(headerLabel, 0.3, {TextTransparency = 0})
    tween(textLabel, 0.3, {TextTransparency = 0})

    task.delay(duration, function()
        if card and card.Parent then
            local t = tween(card, 0.3, {BackgroundTransparency = 1})
            tween(leftBar, 0.3, {BackgroundTransparency = 1})
            tween(iconImg, 0.3, {ImageTransparency = 1})
            tween(headerLabel, 0.3, {TextTransparency = 1})
            tween(textLabel, 0.3, {TextTransparency = 1})
            t.Completed:Connect(function()
                card:Destroy()
            end)
        end
    end)

    return card
end

function EZUI:_syncConfigToControls(cfg)
    if not cfg then return end
    for _, screen in pairs(self.Screens) do
        for _, tab in ipairs(screen.tabs or {}) do
            for _, item in ipairs(tab.items or {}) do
                local nameLower = item.name and item.name:lower() or ""
                
                -- Theme Selector
                if item.type == "selector" and (nameLower:find("theme") or item.isThemeSelector) then
                    if cfg.Theme and item.options then
                        for idx, opt in ipairs(item.options) do
                            local idStr = tostring(opt.id or opt.name or opt)
                            if idStr:lower() == tostring(cfg.Theme):lower() then
                                item.value = idx
                                break
                            end
                        end
                    end
                -- Font Selector
                elseif item.type == "selector" and (nameLower:find("font") or item.isFontSelector) then
                    if cfg.Font and item.options then
                        for idx, opt in ipairs(item.options) do
                            local idStr = tostring(opt.id or opt.name or opt)
                            if idStr:lower() == tostring(cfg.Font):lower() then
                                item.value = idx
                                break
                            end
                        end
                    end
                -- Banner Selector
                elseif item.type == "selector" and (nameLower:find("banner") or item.isBanner) then
                    if cfg.Banner and item.options then
                        for idx, opt in ipairs(item.options) do
                            local idStr = tostring(opt.id or opt.name or opt)
                            local formattedOptId = formatAssetId(opt.id or opt.name or opt)
                            if idStr:lower() == tostring(cfg.Banner):lower() or formattedOptId == cfg.Banner then
                                item.value = idx
                                break
                            end
                        end
                    end
                -- Notify Position Selector
                elseif item.type == "selector" and (nameLower:find("notify") or nameLower:find("position")) then
                    if cfg.NotifyPosition and item.options then
                        for idx, opt in ipairs(item.options) do
                            local idStr = tostring(opt.id or opt.name or opt)
                            if idStr:lower() == tostring(cfg.NotifyPosition):lower() then
                                item.value = idx
                                break
                            end
                        end
                    end
                -- Menu Opacity Slider
                elseif item.type == "slider" and nameLower:find("opacity") then
                    if cfg.Opacity then
                        item.value = cfg.Opacity
                    end
                -- Watermark Toggle
                elseif item.type == "toggle" and nameLower:find("watermark") then
                    if cfg.ShowWatermark ~= nil then
                        item.value = cfg.ShowWatermark
                    end
                end
            end
        end
    end
end

function EZUI:SaveConfig()
    if not writefile then return end
    local filename = self.ConfigFileName or ((self.Title or "EZUI") .. "_config.json")
    local cfg = {
        Theme = self.CurrentThemeName or (type(self.Theme) == "string" and self.Theme or "Green"),
        Font = self.FontName or "GothamMedium",
        Banner = self.CurrentBannerId or "",
        NotifyPosition = self.NotifyPosition or "TopRight",
        Opacity = self.OpacityValue or 85,
        ShowWatermark = self.ShowWatermark ~= false
    }
    pcall(function()
        if isfolder and not isfolder("EZUI_Configs") then
            makefolder("EZUI_Configs")
        end
        local path = (isfolder and isfolder("EZUI_Configs")) and ("EZUI_Configs/" .. filename) or filename
        writefile(path, HttpService:JSONEncode(cfg))
    end)
end

function EZUI:LoadConfig()
    if not readfile then return end
    local filename = self.ConfigFileName or ((self.Title or "EZUI") .. "_config.json")
    local path = (isfolder and isfolder("EZUI_Configs")) and ("EZUI_Configs/" .. filename) or filename
    local exists = false
    if isfile then
        pcall(function() exists = isfile(path) end)
    end
    if not exists then return end

    local content = nil
    pcall(function() content = readfile(path) end)
    if not content or #content == 0 then return end

    local ok, cfg = pcall(function() return HttpService:JSONDecode(content) end)
    if not ok or type(cfg) ~= "table" then return end

    local userCfg = self.UserConfig or {}
    if cfg.Theme and not userCfg.Theme then 
        self:SetTheme(cfg.Theme, true) 
    end
    if cfg.Font and not userCfg.Font then 
        self:SetFont(cfg.Font, true) 
    end
    if cfg.Banner and cfg.Banner ~= "" and not userCfg.Banner then 
        self:SetBanner(cfg.Banner, true) 
    end
    if cfg.NotifyPosition and not userCfg.NotifyPosition then 
        self:SetNotifyPosition(cfg.NotifyPosition, true) 
    end
    if cfg.Opacity and not userCfg.Opacity then 
        self:SetOpacity(cfg.Opacity, true) 
    end
    if cfg.ShowWatermark ~= nil and userCfg.ShowWatermark == nil then 
        self:SetWatermarkVisible(cfg.ShowWatermark, true) 
    end

    self:_syncConfigToControls(cfg)
end

function EZUI:_applyFont()
    local font = self.Font or Enum.Font.GothamMedium
    if self.EzLogoText then self.EzLogoText.Font = font end
    if self.TitleText then self.TitleText.Font = font end
    if self.ScreenTitleText then self.ScreenTitleText.Font = font end
    if self.FooterLeft then self.FooterLeft.Font = font end
    if self.FooterCounter then self.FooterCounter.Font = font end
    if self.SideTitle then self.SideTitle.Font = font end
    if self.PreviewText then self.PreviewText.Font = font end

    for _, c in ipairs(self.TabBar:GetChildren()) do
        if c:IsA("TextButton") then
            c.Font = font
        end
    end

    for _, inst in pairs(self.RowInstances) do
        if inst.Label then inst.Label.Font = font end
        if inst.SelectorLabel then inst.SelectorLabel.Font = font end
        if inst.SepText then inst.SepText.Font = font end
    end
end

function EZUI:SetFont(fontVal, skipSave)
    self.FontName = typeof(fontVal) == "EnumItem" and fontVal.Name or tostring(fontVal)
    self.Font = parseFont(fontVal)
    self:_applyFont()
    if not skipSave then self:SaveConfig() end
end

function EZUI:SetTheme(themePresetOrTable, skipSave)
    if type(themePresetOrTable) == "string" and PRESET_THEMES[themePresetOrTable] then
        self.Theme = table.clone(PRESET_THEMES[themePresetOrTable])
        self.CurrentThemeName = themePresetOrTable
    elseif type(themePresetOrTable) == "table" then
        self.Theme = table.clone(themePresetOrTable)
    end
    self:_applyTheme()
    if not skipSave then self:SaveConfig() end
end

function EZUI:SetAccentColor(color3)
    self.Theme.AccentColor = color3
    self:_applyTheme()
end

function EZUI:SetTitle(titleText)
    self.Title = titleText or ""
    if self.TitleText then
        self.TitleText.Text = self.Title
    end
end

function EZUI:SetFooterText(text)
    self.FooterText = text or ""
    if self.FooterLeft then
        self.FooterLeft.Text = self.FooterText
    end
end

function EZUI:SetSubHeaderTitle(titleText)
    if self.ScreenTitleText then
        self.ScreenTitleText.Text = titleText or ""
    end
end

function EZUI:SetSubHeaderVisible(visible)
    if self.SubHeader then
        self.SubHeader.Visible = visible
        if self.TabBar then
            self.TabBar.Position = visible and UDim2.new(0, 0, 0, 104) or UDim2.new(0, 0, 0, 80)
        end
    end
end

function EZUI:SetLogo(logo)
    if not logo then return end
    local logoStr = tostring(logo)
    local digits = logoStr:match("%d+")
    local isAsset = logoStr:find("rbxasset") 
                 or logoStr:find("rbxthumb") 
                 or logoStr:find("http") 
                 or logoStr:find("://") 
                 or (digits and #digits >= 5)

    if isAsset then
        local assetId = logoStr
        if not logoStr:find("://") and digits then
            assetId = "rbxassetid://" .. digits
        end
        if self.EzLogoImage then
            self.EzLogoImage.Image = assetId
            self.EzLogoImage.BackgroundTransparency = 1
            self.EzLogoImage.ImageTransparency = 0
            self.EzLogoImage.Visible = true
        end
        if self.EzLogoText then
            self.EzLogoText.Visible = false
        end
    else
        if self.EzLogoText then
            self.EzLogoText.Text = logoStr
            self.EzLogoText.Visible = true
        end
        if self.EzLogoImage then
            self.EzLogoImage.Visible = false
        end
    end
end

function EZUI:SetWatermarkVisible(visible, skipSave)
    self.ShowWatermark = (visible ~= false)
    if self.EzLogoImage and self.EzLogoImage.Image ~= "" then
        self.EzLogoImage.Visible = self.ShowWatermark
        if self.EzLogoText then self.EzLogoText.Visible = false end
    elseif self.EzLogoText then
        self.EzLogoText.Visible = self.ShowWatermark
        if self.EzLogoImage then self.EzLogoImage.Visible = false end
    end
    if self.TitleText then
        self.TitleText.Visible = self.ShowWatermark
    end
    if not skipSave then self:SaveConfig() end
end

function EZUI:SetBanner(bannerUrlOrAssetId, skipSave)
    if not self.BannerImage then return end
    local id = formatAssetId(bannerUrlOrAssetId)
    self.BannerImage.Image = id
    self.CurrentBannerId = id
    if not skipSave then self:SaveConfig() end
end

function EZUI:SetOpacity(val, skipSave)
    local pctNum = tonumber(val) or 85
    self.OpacityValue = pctNum
    local pct = math.clamp(pctNum, 0, 100) / 100
    self.OpacityFraction = pct
    
    local transBg = 1 - (0.85 * pct)
    local transSolid = 1 - (1.0 * pct)
    
    if self.Window then self.Window.BackgroundTransparency = transBg end
    if self.Banner then self.Banner.BackgroundTransparency = transSolid end
    if self.BannerFiller then self.BannerFiller.BackgroundTransparency = transSolid end
    if self.BannerImage then self.BannerImage.ImageTransparency = transSolid end
    if self.SubHeader then self.SubHeader.BackgroundTransparency = transSolid end
    if self.TabBar then self.TabBar.BackgroundTransparency = transSolid end
    if self.HighlightBox then self.HighlightBox.BackgroundTransparency = transBg end
    if self.FooterBar then self.FooterBar.BackgroundTransparency = transSolid end
    if self.FooterFiller then self.FooterFiller.BackgroundTransparency = transSolid end
    if self.SidePanel then self.SidePanel.BackgroundTransparency = transBg end
    if self.PreviewImage then self.PreviewImage.ImageTransparency = transSolid end
    if self.SideTopAccent then self.SideTopAccent.BackgroundTransparency = transSolid end
    
    if self.EzLogoText then self.EzLogoText.TextTransparency = transSolid end
    if self.EzLogoImage then self.EzLogoImage.ImageTransparency = transSolid end
    if self.TitleText then self.TitleText.TextTransparency = transSolid end
    if self.ScreenTitleText then self.ScreenTitleText.TextTransparency = transSolid end
    if self.SideTitle then self.SideTitle.TextTransparency = transSolid end
    if self.PreviewText then self.PreviewText.TextTransparency = transSolid end
    if self.FooterLeft then self.FooterLeft.TextTransparency = transSolid end
    if self.FooterCounter then self.FooterCounter.TextTransparency = transSolid end

    for _, inst in pairs(self.RowInstances) do
        if inst.IconImage then
            inst.IconImage.ImageTransparency = transSolid
        end
    end

    if not skipSave then self:SaveConfig() end
end

function EZUI:SetSidePreview(item, previewConfig)
    if type(item) == "table" then
        item.preview = previewConfig
    end
    self:_updateSidePanel()
    return item
end

function EZUI:SetItemIcon(item, icon)
    if type(item) == "table" then
        item.icon = icon
    end
    self:_buildTabContent()
    return item
end

function EZUI:_applyTheme()
    local theme = self.Theme
    if self.Window then self.Window.BackgroundColor3 = theme.WindowBg end
    if self.Banner then self.Banner.BackgroundColor3 = theme.HeaderBg end
    if self.BannerFiller then self.BannerFiller.BackgroundColor3 = theme.HeaderBg end
    if self.SubHeader then self.SubHeader.BackgroundColor3 = theme.SubHeaderBg or Color3.fromRGB(10, 10, 10) end
    if self.EzLogoText then
        self.EzLogoText.TextColor3 = theme.AccentColor
        self.EzLogoText.Font = self.Font
    end
    if self.EzLogoImage then self.EzLogoImage.ImageColor3 = Color3.new(1, 1, 1) end
    if self.TitleText then
        self.TitleText.TextColor3 = theme.AccentColor
        self.TitleText.Font = self.Font
    end
    if self.ScreenTitleText then self.ScreenTitleText.Font = self.Font end
    if self.TabBar then self.TabBar.BackgroundColor3 = theme.TabBarBg end
    if self.ActiveLine then self.ActiveLine.BackgroundColor3 = theme.AccentColor end
    if self.HighlightBox then self.HighlightBox.BackgroundColor3 = theme.HighlightBg end
    if self.FooterBar then self.FooterBar.BackgroundColor3 = theme.HeaderBg end
    if self.FooterFiller then self.FooterFiller.BackgroundColor3 = theme.HeaderBg end
    if self.FooterLeft then
        self.FooterLeft.TextColor3 = theme.TextGray
        self.FooterLeft.Font = self.Font
    end
    if self.FooterCounter then
        self.FooterCounter.TextColor3 = theme.TextGray
        self.FooterCounter.Font = self.Font
    end
    if self.SidePanel then self.SidePanel.BackgroundColor3 = theme.WindowBg end
    if self.SideTopAccent then self.SideTopAccent.BackgroundColor3 = theme.AccentColor end
    if self.SideTitle then self.SideTitle.Font = self.Font end
    if self.PreviewText then self.PreviewText.Font = self.Font end
    
    self:_buildHeaders()
    self:_buildTabContent()
end

function EZUI:_buildGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "EZUI_Library"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    self.Gui = gui

    local window = Instance.new("Frame")
    window.Size = UDim2.fromOffset(320, 388)
    window.Position = UDim2.new(0, 25, 0.5, -194)
    window.BackgroundColor3 = self.Theme.WindowBg
    window.BackgroundTransparency = 0.15 
    window.BorderSizePixel = 0
    window.Parent = gui
    self.Window = window

    local windowCorner = Instance.new("UICorner")
    windowCorner.CornerRadius = UDim.new(0, 6)
    windowCorner.Parent = window

    local banner = Instance.new("Frame")
    banner.Size = UDim2.new(1, 0, 0, 80)
    banner.BackgroundColor3 = self.Theme.HeaderBg
    banner.BorderSizePixel = 0
    banner.ClipsDescendants = true
    banner.Parent = window
    self.Banner = banner

    local bannerCorner = Instance.new("UICorner")
    bannerCorner.CornerRadius = UDim.new(0, 6)
    bannerCorner.Parent = banner

    local bannerFiller = Instance.new("Frame")
    bannerFiller.Size = UDim2.new(1, 0, 0, 6)
    bannerFiller.Position = UDim2.new(0, 0, 1, -6)
    bannerFiller.BackgroundColor3 = self.Theme.HeaderBg
    bannerFiller.BorderSizePixel = 0
    bannerFiller.Parent = banner
    self.BannerFiller = bannerFiller

    local bannerImage = Instance.new("ImageLabel")
    bannerImage.Size = UDim2.new(1, 0, 1, 6) 
    bannerImage.Position = UDim2.new(0, 0, 0, 0)
    bannerImage.BackgroundTransparency = 1
    bannerImage.Image = ""
    bannerImage.ScaleType = Enum.ScaleType.Crop
    bannerImage.ZIndex = 1
    bannerImage.Parent = banner
    self.BannerImage = bannerImage

    local bannerImgCorner = Instance.new("UICorner")
    bannerImgCorner.CornerRadius = UDim.new(0, 6)
    bannerImgCorner.Parent = bannerImage

    local ezLogoImg = Instance.new("ImageLabel")
    ezLogoImg.Size = UDim2.fromOffset(40, 40)
    ezLogoImg.Position = UDim2.fromOffset(16, 20)
    ezLogoImg.BackgroundTransparency = 1
    ezLogoImg.ScaleType = Enum.ScaleType.Fit
    ezLogoImg.ZIndex = 2
    ezLogoImg.Visible = false
    ezLogoImg.Parent = banner
    self.EzLogoImage = ezLogoImg

    local ezLogoImgCorner = Instance.new("UICorner")
    ezLogoImgCorner.CornerRadius = UDim.new(0, 6)
    ezLogoImgCorner.Parent = ezLogoImg

    local ezLogoText = Instance.new("TextLabel")
    ezLogoText.Size = UDim2.fromOffset(60, 46)
    ezLogoText.Position = UDim2.fromOffset(16, 16)
    ezLogoText.BackgroundTransparency = 1
    ezLogoText.Text = self.LogoText or "EZ"
    ezLogoText.Font = self.Font
    ezLogoText.TextSize = 34
    ezLogoText.TextColor3 = self.Theme.AccentColor
    ezLogoText.TextStrokeTransparency = 0.7 
    ezLogoText.ZIndex = 2
    ezLogoText.Visible = true
    ezLogoText.Parent = banner
    self.EzLogoText = ezLogoText

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.fromOffset(150, 30)
    titleText.Position = UDim2.new(1, -166, 0, 25)
    titleText.BackgroundTransparency = 1
    titleText.Text = self.Title or "EZUI"
    titleText.Font = self.Font
    titleText.TextSize = 24
    titleText.TextXAlignment = Enum.TextXAlignment.Right
    titleText.TextColor3 = self.Theme.AccentColor
    titleText.TextStrokeTransparency = 0.7
    titleText.ZIndex = 2
    titleText.Parent = banner
    self.TitleText = titleText

    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, 0, 0, 30)
    tabBar.Position = UDim2.new(0, 0, 0, 80)
    tabBar.BackgroundColor3 = self.Theme.TabBarBg
    tabBar.BorderSizePixel = 0
    tabBar.Parent = window
    self.TabBar = tabBar

    local tabBorder = Instance.new("Frame")
    tabBorder.Size = UDim2.new(1, 0, 0, 1)
    tabBorder.Position = UDim2.new(0, 0, 1, 0)
    tabBorder.BackgroundColor3 = self.Theme.BorderGray
    tabBorder.BorderSizePixel = 0
    tabBorder.Parent = tabBar

    local activeLine = Instance.new("Frame")
    activeLine.AnchorPoint = Vector2.new(0, 1)
    activeLine.Position = UDim2.new(0, 0, 1, 0)
    activeLine.BackgroundColor3 = self.Theme.AccentColor
    activeLine.BorderSizePixel = 0
    activeLine.Parent = tabBar
    self.ActiveLine = activeLine

    local bodyContainer = Instance.new("Frame")
    bodyContainer.Size = UDim2.new(1, 0, 0, MAX_VISIBLE * ROW_HEIGHT)
    bodyContainer.Position = UDim2.new(0, 0, 0, 110)
    bodyContainer.BackgroundTransparency = 1
    bodyContainer.BorderSizePixel = 0
    bodyContainer.ClipsDescendants = true
    bodyContainer.Parent = window

    local innerScroll = Instance.new("Frame")
    innerScroll.Size = UDim2.fromScale(1, 1)
    innerScroll.BackgroundTransparency = 1
    innerScroll.Parent = bodyContainer
    self.InnerScroll = innerScroll

    local highlightBox = Instance.new("Frame")
    highlightBox.Size = UDim2.new(1, 0, 0, ROW_HEIGHT)
    highlightBox.Position = UDim2.new(0, 0, 0, 0)
    highlightBox.BackgroundColor3 = self.Theme.HighlightBg
    highlightBox.BorderSizePixel = 0
    highlightBox.Parent = innerScroll
    self.HighlightBox = highlightBox

    local footerBar = Instance.new("Frame")
    footerBar.Size = UDim2.new(1, 0, 0, 26)
    footerBar.Position = UDim2.new(0, 0, 1, -26)
    footerBar.BackgroundColor3 = self.Theme.HeaderBg
    footerBar.BorderSizePixel = 0
    footerBar.Parent = window
    self.FooterBar = footerBar

    local footerCorner = Instance.new("UICorner")
    footerCorner.CornerRadius = UDim.new(0, 6)
    footerCorner.Parent = footerBar

    local footerFiller = Instance.new("Frame")
    footerFiller.Size = UDim2.new(1, 0, 0, 6)
    footerFiller.Position = UDim2.new(0, 0, 0, 0)
    footerFiller.BackgroundColor3 = self.Theme.HeaderBg
    footerFiller.BorderSizePixel = 0
    footerFiller.Parent = footerBar
    self.FooterFiller = footerFiller

    local footerLeft = Instance.new("TextLabel")
    footerLeft.Size = UDim2.new(0.7, 0, 1, 0)
    footerLeft.Position = UDim2.fromOffset(12, 0)
    footerLeft.BackgroundTransparency = 1
    footerLeft.Text = self.FooterText
    footerLeft.TextColor3 = self.Theme.TextGray
    footerLeft.Font = self.Font
    footerLeft.TextSize = 10
    footerLeft.TextXAlignment = Enum.TextXAlignment.Left
    footerLeft.Parent = footerBar
    self.FooterLeft = footerLeft

    local footerCounter = Instance.new("TextLabel")
    footerCounter.Size = UDim2.fromOffset(60, 26)
    footerCounter.Position = UDim2.new(1, -72, 0, 0)
    footerCounter.BackgroundTransparency = 1
    footerCounter.Font = self.Font
    footerCounter.TextSize = 10
    footerCounter.TextColor3 = self.Theme.TextGray
    footerCounter.TextXAlignment = Enum.TextXAlignment.Right
    footerCounter.Parent = footerBar
    self.FooterCounter = footerCounter

    local sidePanel = Instance.new("Frame")
    sidePanel.Size = UDim2.fromOffset(180, 110)
    sidePanel.Position = UDim2.new(1, 10, 0, 0)
    sidePanel.BackgroundColor3 = self.Theme.WindowBg
    sidePanel.BackgroundTransparency = 0.15
    sidePanel.BorderSizePixel = 0
    sidePanel.Visible = false
    sidePanel.Parent = window 
    self.SidePanel = sidePanel

    local sideCorner = Instance.new("UICorner")
    sideCorner.CornerRadius = UDim.new(0, 6)
    sideCorner.Parent = sidePanel

    local sideTitle = Instance.new("TextLabel")
    sideTitle.Size = UDim2.new(1, -20, 0, 26)
    sideTitle.Position = UDim2.fromOffset(10, 0)
    sideTitle.BackgroundTransparency = 1
    sideTitle.Text = "Preview"
    sideTitle.Font = self.Font
    sideTitle.TextSize = 11
    sideTitle.TextColor3 = self.Theme.TextWhite
    sideTitle.TextXAlignment = Enum.TextXAlignment.Left
    sideTitle.Parent = sidePanel
    self.SideTitle = sideTitle

    local sideTopAccent = Instance.new("Frame")
    sideTopAccent.Size = UDim2.new(1, 0, 0, 2)
    sideTopAccent.Position = UDim2.new(0, 0, 0, 26)
    sideTopAccent.BackgroundColor3 = self.Theme.AccentColor
    sideTopAccent.BorderSizePixel = 0
    sideTopAccent.Parent = sidePanel
    self.SideTopAccent = sideTopAccent

    local previewImage = Instance.new("ImageLabel")
    previewImage.Size = UDim2.new(1, -20, 1, -40)
    previewImage.Position = UDim2.fromOffset(10, 32)
    previewImage.BackgroundTransparency = 1
    previewImage.ScaleType = Enum.ScaleType.Crop
    previewImage.Parent = sidePanel
    self.PreviewImage = previewImage

    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 4)
    previewCorner.Parent = previewImage

    local previewText = Instance.new("TextLabel")
    previewText.Size = UDim2.new(1, -20, 1, -40)
    previewText.Position = UDim2.fromOffset(10, 32)
    previewText.BackgroundTransparency = 1
    previewText.Font = self.Font
    previewText.TextSize = 11
    previewText.TextColor3 = self.Theme.TextGray
    previewText.TextWrapped = true
    previewText.TextYAlignment = Enum.TextYAlignment.Top
    previewText.TextXAlignment = Enum.TextXAlignment.Left
    previewText.Visible = false
    previewText.Parent = sidePanel
    self.PreviewText = previewText
end

-- Screen and item builders
function EZUI:CreateScreen(id, data)
    data = data or {}
    self.Screens[id] = {
        parent = data.parent,
        tabs = data.tabs or {},
        initialTab = data.initialTab or 1,
        initialSelected = data.initialSelected or 1
    }
    return self.Screens[id]
end

function EZUI:AddTab(screenId, name, icon)
    local screen = self.Screens[screenId]
    if not screen then
        screen = self:CreateScreen(screenId)
    end
    local tab = { name = name, items = {}, icon = icon }
    table.insert(screen.tabs, tab)
    return tab
end

function EZUI:AddToggle(tab, name, default, onChange, icon)
    local item = { type = "toggle", name = name, value = default or false, onChange = onChange, icon = icon }
    table.insert(tab.items, item)
    return item
end

function EZUI:AddSlider(tab, name, min, max, default, step, onChange, icon)
    local item = { type = "slider", name = name, min = min, max = max, value = default or min, inc = step or 1, onChange = onChange, icon = icon }
    table.insert(tab.items, item)
    return item
end

function EZUI:AddSelector(tab, name, options, default, onChange, icon)
    local item = { type = "selector", name = name, options = options, value = default or 1, onChange = onChange, icon = icon }
    table.insert(tab.items, item)
    return item
end

function EZUI:AddBannerSelector(tab, name, userOptions, defaultIndex, onChange, icon)
    name = name or "Banner"
    userOptions = userOptions or {}
    defaultIndex = defaultIndex or 1
    
    local item = self:AddSelector(tab, name, userOptions, defaultIndex, function(valIndex, itemObj)
        local selected = itemObj.options[valIndex]
        if selected then
            self:SetBanner(selected.id)
        end
        if onChange then
            onChange(valIndex, selected, itemObj)
        end
    end, icon)
    item.isBanner = true
    
    if userOptions[defaultIndex] then
        self:SetBanner(userOptions[defaultIndex].id)
    end
    
    return item
end

function EZUI:AddButton(tab, name, onClick, icon)
    local item = { type = "button", name = name, onClick = onClick, icon = icon }
    table.insert(tab.items, item)
    return item
end

function EZUI:AddSeparator(tab, name, icon)
    local item = { type = "sep", name = name or "", icon = icon }
    table.insert(tab.items, item)
    return item
end

function EZUI:AddNav(tab, name, targetScreen, icon)
    local item = { type = "nav", name = name, target = targetScreen, icon = icon }
    table.insert(tab.items, item)
    return item
end

-- Render logic
function EZUI:GetScreen()
    return self.Screens[self.CurrentScreen]
end

function EZUI:GetTab()
    local s = self:GetScreen()
    return s and s.tabs[self.CurrentTabIndex]
end

function EZUI:GetItems()
    local t = self:GetTab()
    return t and t.items or {}
end

function EZUI:_updateSidePanel()
    if not self.SidePanel then return end

    local items = self:GetItems()
    local item = items[self.SelectedIndex]
    
    if item and item.preview then
        local p = item.preview
        self.SidePanel.Visible = true
        if self.SideTitle then
            self.SideTitle.Text = p.title or "Preview"
        end
        
        if p.type == "text" or p.text then
            if self.PreviewText then
                self.PreviewText.Text = p.text or ""
                self.PreviewText.Visible = true
            end
            if self.PreviewImage then
                self.PreviewImage.Visible = false
            end
        elseif p.type == "image" or p.image or p.id then
            local imgId = p.image or p.id or ""
            if self.PreviewImage then
                self.PreviewImage.Image = formatAssetId(imgId)
                self.PreviewImage.Visible = true
            end
            if self.PreviewText then
                self.PreviewText.Visible = false
            end
        else
            if self.PreviewText then
                self.PreviewText.Text = ""
                self.PreviewText.Visible = true
            end
            if self.PreviewImage then
                self.PreviewImage.Visible = false
            end
        end
    elseif item and (item.isBanner or item.name == "Banner") and item.options then
        self.SidePanel.Visible = true
        if self.SideTitle then
            self.SideTitle.Text = "Banner Preview"
        end
        local opt = item.options[item.value]
        if opt then
            if self.PreviewImage then
                self.PreviewImage.Image = formatAssetId(opt.id)
                self.PreviewImage.Visible = true
            end
            if self.PreviewText then
                self.PreviewText.Visible = false
            end
        end
    else
        self.SidePanel.Visible = false
    end
end

function EZUI:_updateHighlightAndScroll()
    local items = self:GetItems()
    if #items == 0 then self.HighlightBox.Visible = false; return end
    
    if self.SelectedIndex > #items then self.SelectedIndex = #items end
    if self.SelectedIndex < 1 then self.SelectedIndex = 1 end

    local item = items[self.SelectedIndex]
    self.HighlightBox.Visible = not (item and item.type == "sep")

    if self.SelectedIndex > self.ScrollOffset + MAX_VISIBLE then
        self.ScrollOffset = self.SelectedIndex - MAX_VISIBLE
    elseif self.SelectedIndex <= self.ScrollOffset then
        self.ScrollOffset = self.SelectedIndex - 1
    end
    if self.ScrollOffset < 0 then self.ScrollOffset = 0 end

    tween(self.InnerScroll, 0.2, {Position = UDim2.new(0, 0, 0, -self.ScrollOffset * ROW_HEIGHT)})
    tween(self.HighlightBox, 0.2, {Position = UDim2.new(0, 0, 0, (self.SelectedIndex - 1) * ROW_HEIGHT)})
    
    self.FooterCounter.Text = tostring(self.SelectedIndex).." / "..tostring(#items)

    for i, inst in pairs(self.RowInstances) do
        local isSel = (i == self.SelectedIndex)
        if inst.Label then
            tween(inst.Label, 0.2, {TextColor3 = isSel and self.Theme.TextWhite or self.Theme.TextGray})
        end
        if inst.SelectorLabel then
            tween(inst.SelectorLabel, 0.2, {TextColor3 = isSel and self.Theme.TextWhite or self.Theme.TextGray})
        end
        if inst.Chevron1 then
            tween(inst.Chevron1, 0.2, {BackgroundColor3 = isSel and self.Theme.TextWhite or self.Theme.TextGray})
            tween(inst.Chevron2, 0.2, {BackgroundColor3 = isSel and self.Theme.TextWhite or self.Theme.TextGray})
        end
    end
    
    self:_updateSidePanel()
end

local function createChevron(parent, theme)
    local c = Instance.new("Frame")
    c.Size = UDim2.fromOffset(12, 12)
    c.BackgroundTransparency = 1
    c.Parent = parent
    local t1 = Instance.new("Frame")
    t1.Size = UDim2.fromOffset(7, 1)
    t1.AnchorPoint = Vector2.new(0.5, 0.5)
    t1.Position = UDim2.fromScale(0.4, 0.35)
    t1.Rotation = 45
    t1.BackgroundColor3 = theme.TextGray
    t1.BorderSizePixel = 0
    t1.Parent = c
    local t2 = t1:Clone()
    t2.Position = UDim2.fromScale(0.4, 0.65)
    t2.Rotation = -45
    t2.Parent = c
    return c
end

function EZUI:_buildTabContent()
    for _, child in ipairs(self.InnerScroll:GetChildren()) do
        if child ~= self.HighlightBox then child:Destroy() end
    end
    table.clear(self.RowInstances)
    
    local items = self:GetItems()
    self.InnerScroll.Size = UDim2.new(1, 0, 0, #items * ROW_HEIGHT)

    for i, item in ipairs(items) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, ROW_HEIGHT)
        row.Position = UDim2.new(0, 0, 0, (i - 1) * ROW_HEIGHT)
        row.BackgroundTransparency = 1
        row.Parent = self.InnerScroll
        
        self.RowInstances[i] = {Frame = row, Type = item.type}

        if item.type == "sep" then
            local sepFrame = Instance.new("Frame")
            sepFrame.Size = UDim2.fromScale(1, 1)
            sepFrame.BackgroundTransparency = 1
            sepFrame.Parent = row

            if item.name ~= "" then
                local lineLeft = Instance.new("Frame")
                lineLeft.Size = UDim2.new(0.2, 0, 0, 1)
                lineLeft.Position = UDim2.new(0.05, 0, 0.5, 0)
                lineLeft.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                lineLeft.BorderSizePixel = 0
                lineLeft.Parent = sepFrame

                local txt = Instance.new("TextLabel")
                txt.Size = UDim2.new(0.5, 0, 1, 0)
                txt.Position = UDim2.new(0.25, 0, 0, 0)
                txt.BackgroundTransparency = 1
                txt.Text = item.name
                txt.Font = self.Font
                txt.TextSize = 10
                txt.TextColor3 = Color3.fromRGB(120, 120, 120)
                txt.Parent = sepFrame
                self.RowInstances[i].SepText = txt

                local lineRight = Instance.new("Frame")
                lineRight.Size = UDim2.new(0.2, 0, 0, 1)
                lineRight.Position = UDim2.new(0.75, 0, 0.5, 0)
                lineRight.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                lineRight.BorderSizePixel = 0
                lineRight.Parent = sepFrame
            else
                local fullLine = Instance.new("Frame")
                fullLine.Size = UDim2.new(0.9, 0, 0, 1)
                fullLine.Position = UDim2.new(0.05, 0, 0.5, 0)
                fullLine.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                fullLine.BorderSizePixel = 0
                fullLine.Parent = sepFrame
            end
        else
            local labelX = 16
            local labelWidthOffset = 130

            if item.icon and item.icon ~= "" then
                local iconImg = Instance.new("ImageLabel")
                iconImg.Size = UDim2.fromOffset(14, 14)
                iconImg.Position = UDim2.fromOffset(16, 7)
                iconImg.BackgroundTransparency = 1
                setIconImage(iconImg, item.icon)
                iconImg.ScaleType = Enum.ScaleType.Fit
                iconImg.Parent = row
                self.RowInstances[i].IconImage = iconImg
                
                labelX = 36
                labelWidthOffset = 150
            end

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -labelWidthOffset, 1, 0)
            label.Position = UDim2.fromOffset(labelX, 0)
            label.BackgroundTransparency = 1
            label.Text = item.type == "slider" and (item.name..": "..tostring(item.value)) or item.name
            label.Font = self.Font
            label.TextSize = 11
            label.TextColor3 = self.Theme.TextGray
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = row
            
            self.RowInstances[i].Label = label

            if item.type == "toggle" then
                local bg = Instance.new("Frame")
                bg.Size = UDim2.fromOffset(30, 14)
                bg.AnchorPoint = Vector2.new(1, 0.5)
                bg.Position = UDim2.new(1, -12, 0.5, 0)
                bg.BackgroundColor3 = item.value and self.Theme.AccentColor or self.Theme.ToggleOff
                bg.BorderSizePixel = 0
                bg.Parent = row
                local bgCorner = Instance.new("UICorner")
                bgCorner.CornerRadius = UDim.new(1, 0)
                bgCorner.Parent = bg
                
                local knob = Instance.new("Frame")
                knob.Size = UDim2.fromOffset(10, 10)
                knob.Position = item.value and UDim2.fromOffset(18, 2) or UDim2.fromOffset(2, 2)
                knob.BackgroundColor3 = self.Theme.TextWhite
                knob.BorderSizePixel = 0
                knob.Parent = bg
                local knobCorner = Instance.new("UICorner")
                knobCorner.CornerRadius = UDim.new(1, 0)
                knobCorner.Parent = knob
                
                self.RowInstances[i].ToggleBg = bg
                self.RowInstances[i].ToggleKnob = knob

            elseif item.type == "slider" then
                local track = Instance.new("Frame")
                track.Size = UDim2.fromOffset(110, 4)
                track.AnchorPoint = Vector2.new(1, 0.5)
                track.Position = UDim2.new(1, -12, 0.5, 0)
                track.BackgroundColor3 = self.Theme.SliderTrack
                track.BorderSizePixel = 0
                track.Parent = row
                local trackCorner = Instance.new("UICorner")
                trackCorner.CornerRadius = UDim.new(1, 0)
                trackCorner.Parent = track
                
                local pct = (item.value - item.min)/(item.max - item.min)
                local fill = Instance.new("Frame")
                fill.Size = UDim2.new(pct, 0, 1, 0)
                fill.BackgroundColor3 = self.Theme.TextWhite
                fill.BorderSizePixel = 0
                fill.Parent = track
                local fillCorner = Instance.new("UICorner")
                fillCorner.CornerRadius = UDim.new(1, 0)
                fillCorner.Parent = fill
                
                local thumb = Instance.new("Frame")
                thumb.Size = UDim2.fromOffset(10, 10)
                thumb.AnchorPoint = Vector2.new(0.5, 0.5)
                thumb.Position = UDim2.new(1, 0, 0.5, 0)
                thumb.BackgroundColor3 = self.Theme.TextWhite
                thumb.BorderSizePixel = 0
                thumb.Parent = fill
                local thumbCorner = Instance.new("UICorner")
                thumbCorner.CornerRadius = UDim.new(1, 0)
                thumbCorner.Parent = thumb
                
                self.RowInstances[i].Track = track
                self.RowInstances[i].Fill = fill
                self.RowInstances[i].Thumb = thumb

            elseif item.type == "selector" then
                local valLabel = Instance.new("TextLabel")
                valLabel.Size = UDim2.new(0, 120, 1, 0)
                valLabel.Position = UDim2.new(1, -132, 0, 0)
                valLabel.BackgroundTransparency = 1
                valLabel.Text = "< " .. item.options[item.value].name .. " >"
                valLabel.Font = self.Font
                valLabel.TextSize = 11
                valLabel.TextColor3 = self.Theme.TextGray
                valLabel.TextXAlignment = Enum.TextXAlignment.Right
                valLabel.Parent = row
                
                self.RowInstances[i].SelectorLabel = valLabel

            elseif item.type == "nav" then
                local chev = createChevron(row, self.Theme)
                chev.Position = UDim2.new(1, -20, 0.5, -6)
                local chChildren = chev:GetChildren()
                self.RowInstances[i].Chevron1 = chChildren[1]
                self.RowInstances[i].Chevron2 = chChildren[2]
            end
        end
    end

    self.InnerScroll.Position = UDim2.new(0, 0, 0, -self.ScrollOffset * ROW_HEIGHT)
    self:_updateHighlightAndScroll()
end

function EZUI:SwitchTab(index)
    local s = self:GetScreen()
    if not s or not s.tabs[index] then return end
    
    self.CurrentTabIndex = index
    self.SelectedIndex = 1
    self.ScrollOffset = 0
    
    self:_buildHeaders()

    if self.InnerScroll then
        local currentY = -self.ScrollOffset * ROW_HEIGHT
        tween(self.InnerScroll, 0.08, {Position = UDim2.new(0, -12, 0, currentY)})
        task.wait(0.08)
        self:_buildTabContent()
        self.InnerScroll.Position = UDim2.new(0, 12, 0, 0)
        tween(self.InnerScroll, 0.18, {Position = UDim2.new(0, 0, 0, 0)})
    else
        self:_buildTabContent()
    end
end

function EZUI:_buildHeaders()
    for _, c in ipairs(self.TabBar:GetChildren()) do 
        if c:IsA("TextButton") or c.Name == "TabBg" then c:Destroy() end 
    end
    
    local s = self:GetScreen()
    if not s then return end
    local n = #s.tabs
    if n == 0 then return end

    if self.ActiveLine then
        self.ActiveLine.Size = UDim2.new(1/n, 0, 0, 2)
        self.ActiveLine.BackgroundColor3 = self.Theme.AccentColor
        tween(self.ActiveLine, 0.25, {Position = UDim2.new((self.CurrentTabIndex-1)/n, 0, 1, 0)})
    end

    for idx, tab in ipairs(s.tabs) do
        local isSelected = (idx == self.CurrentTabIndex)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1/n, 0, 1, 0)
        btn.Position = UDim2.new((idx-1)/n, 0, 0, 0)
        btn.BackgroundTransparency = 1
        btn.Text = tab.name
        btn.Font = self.Font
        btn.TextSize = 11
        btn.TextColor3 = isSelected and self.Theme.TextWhite or self.Theme.TextGray
        btn.Parent = self.TabBar

        btn.MouseButton1Click:Connect(function()
            self:SwitchTab(idx)
        end)

        if tab.icon and tab.icon ~= "" then
            local tabIcon = Instance.new("ImageLabel")
            tabIcon.Size = UDim2.fromOffset(12, 12)
            tabIcon.Position = UDim2.new(0, 6, 0.5, -6)
            tabIcon.BackgroundTransparency = 1
            setIconImage(tabIcon, tab.icon)
            tabIcon.ScaleType = Enum.ScaleType.Fit
            tabIcon.Parent = btn
        end
    end
end

function EZUI:_activateItem()
    local items = self:GetItems()
    local item = items[self.SelectedIndex]
    local inst = self.RowInstances[self.SelectedIndex]
    if not item or item.type == "sep" then return end

    if item.type == "toggle" then
        item.value = not item.value
        tween(inst.ToggleBg, 0.15, {BackgroundColor3 = item.value and self.Theme.AccentColor or self.Theme.ToggleOff})
        tween(inst.ToggleKnob, 0.15, {Position = item.value and UDim2.fromOffset(18, 2) or UDim2.fromOffset(2, 2)})
        if item.onChange then item.onChange(item.value, item) end
    elseif item.type == "button" then
        if item.onClick then item.onClick(item) end
    elseif item.type == "nav" then
        self.CurrentScreen = item.target
        local targetScr = self:GetScreen()
        self.CurrentTabIndex = targetScr and targetScr.initialTab or 1
        self.SelectedIndex = targetScr and targetScr.initialSelected or 1
        self.ScrollOffset = 0
        self:_buildHeaders()
        self:_buildTabContent()
    end
end

function EZUI:_updateSliderOrSelector(amount)
    local items = self:GetItems()
    local item = items[self.SelectedIndex]
    local inst = self.RowInstances[self.SelectedIndex]
    if not item then return end

    if item.type == "slider" then
        item.value = math.clamp(item.value + (amount * item.inc), item.min, item.max)
        inst.Label.Text = item.name..": "..tostring(item.value)
        local pct = (item.value - item.min)/(item.max - item.min)
        tween(inst.Fill, 0.1, {Size = UDim2.new(pct, 0, 1, 0)})
        if item.onChange then item.onChange(item.value, item) end
    
    elseif item.type == "selector" then
        item.value = item.value + amount
        if item.value > #item.options then item.value = 1 end
        if item.value < 1 then item.value = #item.options end
        
        inst.SelectorLabel.Text = "< " .. item.options[item.value].name .. " >"
        if item.onChange then item.onChange(item.value, item) end
        self:_updateSidePanel()
    end
end

function EZUI:Init()
    for _, screen in pairs(self.Screens) do
        for _, tab in pairs(screen.tabs) do
            for _, item in pairs(tab.items) do
                if item.onChange then
                    item.onChange(item.value, item)
                end
            end
        end
    end
    self:LoadConfig()
    self:_buildHeaders()
    self:_buildTabContent()
    self:_bindKeys()
end

-- Input blocking and hold repeat
local BLOCK_NAME = "EZKeyBlock_Final"

local blockedKeys = {
    [Enum.KeyCode.Left] = true,
    [Enum.KeyCode.Right] = true,
    [Enum.KeyCode.Up] = true,
    [Enum.KeyCode.Down] = true,
    [Enum.KeyCode.Tab] = true,
    [Enum.KeyCode.Return] = true,
    [Enum.KeyCode.KeypadEnter] = true,
    [Enum.KeyCode.Backspace] = true,
    [Enum.KeyCode.Delete] = true,
}

-- Block navigation keys from regular game input
pcall(function()
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if not checkcaller() and (method == "IsKeyDown" or method == "isKeyDown") then
                local key = ...
                if blockedKeys[key] then return false end
            end
            return oldNamecall(self, ...)
        end)
    end
end)

pcall(function()
    if hookfunction and UserInputService.IsKeyDown then
        local oldIsKeyDown
        oldIsKeyDown = hookfunction(UserInputService.IsKeyDown, function(self, key, ...)
            if not checkcaller() then
                if blockedKeys[key] then return false end
            end
            return oldIsKeyDown(self, key, ...)
        end)
    end
end)

local function sinkInput(actionName, inputState, inputObject)
    return Enum.ContextActionResult.Sink
end

local StarterGui = game:GetService("StarterGui")

function EZUI:_bindKeys()
    pcall(function()
        self.SavedPlayerListEnabled = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
    end)

    ContextActionService:BindActionAtPriority(
        BLOCK_NAME, 
        sinkInput, 
        false, 
        2147483647, 
        Enum.KeyCode.Left, Enum.KeyCode.Right, 
        Enum.KeyCode.Up, Enum.KeyCode.Down,
        Enum.KeyCode.Tab, Enum.KeyCode.Return, Enum.KeyCode.KeypadEnter,
        Enum.KeyCode.Backspace, Enum.KeyCode.Delete
    )
end

function EZUI:_unbindKeys()
    pcall(function()
        if self.SavedPlayerListEnabled ~= nil then
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, self.SavedPlayerListEnabled)
        else
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
        end
    end)
    ContextActionService:UnbindAction(BLOCK_NAME)
end

local function isWASDDown()
    return UserInputService:IsKeyDown(Enum.KeyCode.W) 
        or UserInputService:IsKeyDown(Enum.KeyCode.A) 
        or UserInputService:IsKeyDown(Enum.KeyCode.S) 
        or UserInputService:IsKeyDown(Enum.KeyCode.D)
end

function EZUI:_stopKeyHold()
    self.ActiveHeldKey = nil
    if self.HoldThread then
        task.cancel(self.HoldThread)
        self.HoldThread = nil
    end
end

function EZUI:_processKeyAction(keyCode)
    if not isWASDDown() then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:Move(Vector3.zero, false)
        end
    end

    local items = self:GetItems()
    if keyCode == Enum.KeyCode.Up then
        if #items == 0 then return end
        repeat
            self.SelectedIndex = self.SelectedIndex - 1
            if self.SelectedIndex < 1 then self.SelectedIndex = #items end
        until items[self.SelectedIndex].type ~= "sep"
        self:_updateHighlightAndScroll()

    elseif keyCode == Enum.KeyCode.Down then
        if #items == 0 then return end
        repeat
            self.SelectedIndex = self.SelectedIndex + 1
            if self.SelectedIndex > #items then self.SelectedIndex = 1 end
        until items[self.SelectedIndex].type ~= "sep"
        self:_updateHighlightAndScroll()

    elseif keyCode == Enum.KeyCode.Left then
        self:_updateSliderOrSelector(-1)

    elseif keyCode == Enum.KeyCode.Right then
        self:_updateSliderOrSelector(1)
    end
end

function EZUI:_startKeyHold(keyCode)
    self:_stopKeyHold()
    self.ActiveHeldKey = keyCode
    self:_processKeyAction(keyCode)
    
    self.HoldThread = task.spawn(function()
        task.wait(0.25)
        while self.ActiveHeldKey == keyCode and self.MenuVisible do
            self:_processKeyAction(keyCode)
            task.wait(0.04)
        end
    end)
end

function EZUI:_setupInputs()
    local conn1 = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == self.ToggleKey then
            self.MenuVisible = not self.MenuVisible
            self.Window.Visible = self.MenuVisible
            if self.MenuVisible then self:_bindKeys() else self:_unbindKeys(); self:_stopKeyHold() end
            return
        end

        if not self.MenuVisible then return end

        if input.KeyCode == Enum.KeyCode.Tab then
            pcall(function()
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
            end)
            local s = self:GetScreen()
            if s and #s.tabs > 0 then
                local nextTab = (self.CurrentTabIndex % #s.tabs) + 1
                task.spawn(function()
                    self:SwitchTab(nextTab)
                end)
            end
        elseif input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
            local s = self:GetScreen()
            if s and s.parent then
                self.CurrentScreen = s.parent
                self.CurrentTabIndex = 1; self.SelectedIndex = 1; self.ScrollOffset = 0
                self:_buildHeaders()
                self:_buildTabContent()
            end
        elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
            self:_activateItem()
        elseif input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.Down 
            or input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.Right then
            self:_startKeyHold(input.KeyCode)
        end
    end)
    table.insert(self.Connections, conn1)

    local conn2 = UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == self.ActiveHeldKey then
            self:_stopKeyHold()
        end
    end)
    table.insert(self.Connections, conn2)
end

return EZUI
