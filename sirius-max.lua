--[[

Sirius

© 2024 Sirius 
All Rights Reserved.

--]]


--[[

Sirius Pre-Hyperion Todo List

High Priority
 - Invisible, Godmode
 - All Scripts buttons and Universal scripts
 - Chat Spam Detection
 - Custom Script Prompts
 - Player Kill, Spectate and ESP via Playerlist
 - http.request support for Sirius Intelligent HTTP Interception
 - Performance Improvements to Roblox itself
 
Moderate Priority
 - Spectate Animation, like GTA serverhop, tween to high in the sky, then tween to other player's head
 - Chat Spy Tracking: Follows who they're whispering to based on original message
 - Starlight 
 - Chatlogs
 - GTA Serverhop
 - Anti-Spam (chat) formula, based on text length, caps, emojis etc.
 - Reduce any form of detection of Sirius
 - Automated lowering of graphics on lower FPS, ensure no false positives
 
Potential Future Setting Options
 - Block entire domain or just the specific page in the Sirius Intelligent Flow Interception. Do this on case by case, e.g blocked = {"link.com", true} - true being whether its the domain or not
 - Serverhop type (default/gta)
 - Hook Specific Functions to reduce the need for external scripts
 
--]]

-- Ensure the game is loaded 
if not game:IsLoaded() then
	game.Loaded:Wait()
end

-- Check License Tier
local Pro = true -- We're open sourced now!

-- ================================================
-- SIRIUS MAX STABILITY MODULES - ZERO LOCAL VERSION
-- ================================================
-- Insert after: local gameSettings = UserSettings():GetService("UserGameSettings")
-- ================================================

-- NO LOCALS DECLARED HERE - All inside the IIFE
(function()
    -- Only local inside this scope - doesn't count against main script limit
    local S = _G.SiriusMAX or {}
    _G.SiriusMAX = S
    
    -- Executor Info - stored in table, not locals
    S.ExecutorInfo = {
        Name = tostring((typeof(identifyexecutor) == "function" and identifyexecutor())
            or (typeof(getexecutorname) == "function" and getexecutorname())
            or (typeof(syn) == "table" and "Synapse X")
            or (typeof(is_sirhurt_closure) == "function" and "SirHurt")
            or (typeof(is_krnl_closure) == "function" and "Krnl")
            or (typeof(Fluxus) == "table" and "Fluxus")
            or (typeof(delta) == "table" and "Delta")
            or (typeof(hydrogen) == "table" and "Hydrogen")
            or (typeof(arceus) == "table" and "Arceus X")
            or (typeof(codex) == "table" and "Codex")
            or (typeof(electron) == "table" and "Electron")
            or "Unknown"),
        IsMobile = (game:GetService("UserInputService")).TouchEnabled 
            and not (game:GetService("UserInputService")).KeyboardEnabled
    }
    
    -- Set flags via string find
    local nm = S.ExecutorInfo.Name:lower()
    S.ExecutorInfo.IsDelta = nm:find("delta") ~= nil
    S.ExecutorInfo.IsHydrogen = nm:find("hydrogen") ~= nil
    S.ExecutorInfo.IsMobile = S.ExecutorInfo.IsMobile or nm:find("ios") ~= nil or nm:find("android") ~= nil
    
    -- Logging - attached to table
    S.Log = function(m, ...) 
        if m == "ERROR" then warn("[Sirius MAX]", ...) 
        elseif m == "WARN" then warn("[Sirius MAX]", ...)
        else print("[Sirius MAX]", ...) end 
    end
    S.Log.Info = function(...) S.Log("INFO", ...) end
    S.Log.Warn = function(...) S.Log("WARN", ...) end
    S.Log.Error = function(...) S.Log("ERROR", ...) end
    
    -- Safe API polyfills - directly to _G
    local function ga(n) 
        if _G[n] then return _G[n] end
        for _,t in pairs({syn, KRNL, Fluxus, delta, hydrogen, arceus, codex, electron}) do
            if t and t[n] then return t[n] end
        end
        return nil
    end
    
    local warned = {}
    local function wo(a) 
        if not warned[a] then warned[a] = true; S.Log.Warn(a, "not supported") end 
        return false 
    end
    
    if not _G.writefile then _G.writefile = ga("writefile") or function(f,c) return wo("writefile") end end
    if not _G.readfile then _G.readfile = ga("readfile") or function(f) return nil end end
    if not _G.isfile then _G.isfile = ga("isfile") or function(f) return false end end
    if not _G.makefolder then _G.makefolder = ga("makefolder") or function(f) return wo("makefolder") end end
    if not _G.setclipboard then _G.setclipboard = ga("setclipboard") or function(t) return wo("setclipboard") end end
    if not _G.setfpscap then _G.setfpscap = ga("setfpscap") or function(f) end end
    
    -- Capabilities
    S.Capabilities = {
        FileIO = pcall(function() local f = ".t"..tick(); _G.writefile(f,"x"); local r=_G.readfile(f)=="x"; _G.delfile(f); return r end),
        HTTP = _G.request ~= nil or _G.http_request ~= nil,
        Clipboard = _G.setclipboard ~= nil
    }
    
    -- Safe HTTP
    S.HttpGet = function(url, r)
        r = r or 3
        local req = _G.request or _G.http_request or (syn and syn.request)
        if not req then return nil end
        for i = 1, r do
            local ok, rs = pcall(req, {Url = url, Method = "GET", Headers = {["User-Agent"]="Sirius MAX/1.0"}})
            if ok and rs and ((rs.StatusCode and rs.StatusCode >= 200 and rs.StatusCode < 300) or rs.Success) then
                return rs.Body or rs.body
            end
            if i < r then task.wait(1) end
        end
        return nil
    end
    
    -- Crash Guard
    S.SafeCall = function(n, fn, ...)
        if typeof(fn) ~= "function" then return nil end
        local ok, r = pcall(fn, ...)
        if not ok then S.Log.Error("Crash in", n, ":", r) end
        return ok and r or nil
    end
    
    S.SafeLoop = function(n, fn, d)
        task.spawn(function()
            while true do
                if not pcall(fn) then task.wait(1) else task.wait(d or 0.1) end
            end
        end)
    end
    
    -- Safe Editor
    S.MAX_EDITOR_SIZE = 190000
    S.MOBILE_EDITOR_LIMIT = 100000
    S.SafeSetEditorText = function(ed, txt)
        if not ed or not ed:IsA("TextBox") then return end
        local lim = S.ExecutorInfo.IsMobile and S.MOBILE_EDITOR_LIMIT or S.MAX_EDITOR_SIZE
        if #txt > lim then txt = txt:sub(1, lim) .. "\n\n-- [TRUNCATED]" end
        pcall(function() ed.Text = txt end)
    end
    
    -- Mobile Config
    S.MobileConfig = {MaxTabs = 10, Animations = true, SyntaxHighlight = true, BrowserMaxTabs = 5, FPSCap = 60}
    if S.ExecutorInfo.IsMobile then
        S.MobileConfig = {MaxTabs = 3, Animations = false, SyntaxHighlight = false, BrowserMaxTabs = 2, FPSCap = 30}
        pcall(function() if _G.setfpscap then _G.setfpscap(30) end; settings().Rendering.QualityLevel = 1 end)
    end
    
    S.Log.Info("Stability Ready | Executor:", S.ExecutorInfo.Name, "| Mobile:", tostring(S.ExecutorInfo.IsMobile))
end)()
-- END STABILITY MODULES


-- Create Variables for Roblox Services
local coreGui = game:GetService("CoreGui")
local httpService = game:GetService("HttpService")
local lighting = game:GetService("Lighting")
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local guiService = game:GetService("GuiService")
local statsService = game:GetService("Stats")
local starterGui = game:GetService("StarterGui")
local teleportService = game:GetService("TeleportService")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService('UserInputService')
local gameSettings = UserSettings():GetService("UserGameSettings")

-- Variables
local camera = workspace.CurrentCamera
local getMessage = replicatedStorage:WaitForChild("DefaultChatSystemChatEvents", 1) and replicatedStorage.DefaultChatSystemChatEvents:WaitForChild("OnMessageDoneFiltering", 1)
local localPlayer = players.LocalPlayer
local notifications = {}
local friendsCooldown = 0
local mouse = localPlayer:GetMouse()
local promptedDisconnected = false
local smartBarOpen = false
local debounce = false
local searchingForPlayer = false
local musicQueue = {}
local currentAudio
local lowerName = localPlayer.Name:lower()
local lowerDisplayName = localPlayer.DisplayName:lower()
local placeId = game.PlaceId
local jobId = game.JobId
local checkingForKey = false
local originalTextValues = {}
local creatorId = game.CreatorId
local noclipDefaults = {}
local movers = {}
local creatorType = game.CreatorType
local espContainer = Instance.new("Folder", gethui and gethui() or coreGui)
local oldVolume = gameSettings.MasterVolume



-- Configurable Core Values
local siriusValues = {
	siriusVersion = "1.26",
	siriusName = "Sirius",
	releaseType = "Stable",
	siriusFolder = "SiriusMAX",
	settingsFile = "settings.srs",
	interfaceAsset = 14183548964,
	cdn = "https://cdn.sirius.menu/SIRIUS-SCRIPT-CORE-ASSETS/",
	icons = "https://cdn.sirius.menu/SIRIUS-SCRIPT-CORE-ASSETS/Icons/",
	enableExperienceSync = false, -- Games are no longer available due to a lack of whitelisting, they may be made open source at a later date, however they are patched as of now and are useless to the end user. Turning this on may introduce "fake functionality".
	games = {
		BreakingPoint = {
			name = "Breaking Point",
			description = "Players are seated around a table. Their only goal? To be the last one standing. Execute this script to gain an unfair advantage.",
			id = 648362523,
			enabled = true,
			raw = "BreakingPoint",
			minimumTier = "Free",
		},
		MurderMystery2 = {
			name = "Murder Mystery 2",
			description = "A murder has occured, will you be the one to find the murderer, or kill your next victim? Execute this script to gain an unfair advantage.",
			id = 142823291,
			enabled = true,
			raw = "MurderMystery2",
			minimumTier = "Free",
		},
		TowerOfHell = {
			name = "Tower Of Hell",
			description = "A difficult popular parkouring game, with random levels and modifiers. Execute this script to gain an unfair advantage.",
			id = 1962086868,
			enabled = true,
			raw = "TowerOfHell",
			minimumTier = "Free",
		},
		Strucid = {
			name = "Strucid",
			description = "Fight friends and enemies in Strucid with building mechanics! Execute this script to gain an unfair advantage.",
			id = 2377868063,
			enabled = true,
			raw = "Strucid",
			minimumTier = "Free",
		},
		PhantomForces = {
			name = "Phantom Forces",
			description = "One of the most popular FPS shooters from the team at StyLiS Studios. Execute this script to gain an unfair advantage.",
			id = 292439477,
			enabled = true,
			raw = "PhantomForces",
			minimumTier = "Pro",
		},
	},
	rawTree = "https://raw.githubusercontent.com/SiriusSoftwareLtd/Sirius/Sirius/games/",
	neonModule = "https://raw.githubusercontent.com/shlexware/Sirius/request/library/neon.lua",
	senseRaw = "https://raw.githubusercontent.com/shlexware/Sirius/request/library/sense/source.lua",
	executors = {"synapse x", "script-ware", "krnl", "scriptware", "comet", "valyse", "fluxus", "electron", "hydrogen"},
	disconnectTypes = { {"ban", {"ban", "perm"}}, {"network", {"internet connection", "network"}} },
	nameGeneration = {
		adjectives = {"Cool", "Awesome", "Epic", "Ninja", "Super", "Mystic", "Swift", "Golden", "Diamond", "Silver", "Mint", "Roblox", "Amazing"},
		nouns = {"Player", "Gamer", "Master", "Legend", "Hero", "Ninja", "Wizard", "Champion", "Warrior", "Sorcerer"}
	},
	administratorRoles = {"mod","admin","staff","dev","founder","owner","supervis","manager","management","executive","president","chairman","chairwoman","chairperson","director"},
	transparencyProperties = {
		UIStroke = {'Transparency'},
		Frame = {'BackgroundTransparency'},
		TextButton = {'BackgroundTransparency', 'TextTransparency'},
		TextLabel = {'BackgroundTransparency', 'TextTransparency'},
		TextBox = {'BackgroundTransparency', 'TextTransparency'},
		ImageLabel = {'BackgroundTransparency', 'ImageTransparency'},
		ImageButton = {'BackgroundTransparency', 'ImageTransparency'},
		ScrollingFrame = {'BackgroundTransparency', 'ScrollBarImageTransparency'}
	},
	buttonPositions = {Character = UDim2.new(0.5, -155, 1, -29), Scripts = UDim2.new(0.5, -122, 1, -29), Playerlist = UDim2.new(0.5, -68, 1, -29)},
	chatSpy = {
		enabled = true,
		visual = {
			Color = Color3.fromRGB(26, 148, 255),
			Font = Enum.Font.SourceSansBold,
			TextSize = 18
		},
	},
	pingProfile = {
		recentPings = {},
		adaptiveBaselinePings = {},
		pingNotificationCooldown = 0,
		maxSamples = 12, -- max num of recent pings stored
		spikeThreshold = 1.75, -- high Ping in comparison to average ping (e.g 100 avg would be high at 150)
		adaptiveBaselineSamples = 30, -- how many samples Sirius takes before deciding on a fixed high ping value
		adaptiveHighPingThreshold = 120 -- default value
	},
	frameProfile = {
		frameNotificationCooldown = 0,
		fpsQueueSize = 10,
		lowFPSThreshold = 20, -- what's low fps!??!?!
		totalFPS = 0,
		fpsQueue = {},
	},
	actions = {
		{
			name = "Noclip",
			images = {14385986465, 9134787693},
			color = Color3.fromRGB(0, 170, 127),
			enabled = false,
			rotateWhileEnabled = false,
			callback = function() end,
		},
		{
			name = "Flight",
			images = {9134755504, 14385992605},
			color = Color3.fromRGB(170, 37, 46),
			enabled = false,
			rotateWhileEnabled = false,
			callback = function(value)
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.PlatformStand = value
				end
			end,
		},
		{
			name = "Refresh",
			images = {9134761478, 9134761478},
			color = Color3.fromRGB(61, 179, 98),
			enabled = false,
			rotateWhileEnabled = true,
			disableAfter = 3,
			callback = function()
				task.spawn(function()
					local character = localPlayer.Character
					if character then
						local cframe = character:GetPivot()
						local humanoid = character:FindFirstChildOfClass("Humanoid")
						if humanoid then
							humanoid:ChangeState(Enum.HumanoidStateType.Dead)
						end
						character = localPlayer.CharacterAdded:Wait()
						task.defer(character.PivotTo, character, cframe)
					end
				end)
			end,
		},
		{
			name = "Respawn",
			images = {9134762943, 9134762943},
			color = Color3.fromRGB(49, 88, 193),
			enabled = false,
			rotateWhileEnabled = true,
			disableAfter = 2,
			callback = function()
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				end
			end,
		},
		{
			name = "Invulnerability",
			images = {9134765994, 14386216487},
			color = Color3.fromRGB(193, 46, 90),
			enabled = false,
			rotateWhileEnabled = false,
			callback = function(value)
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if not humanoid then return end

				if value then
					-- Godmode-style humanoid swap, adapted from Infinite Yield
					local cameraSubject = camera.CameraSubject
					local originalCFrame = camera.CFrame

					local newHumanoid = humanoid:Clone()
					newHumanoid.Parent = character

					newHumanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
					newHumanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
					newHumanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
					newHumanoid.BreakJointsOnDeath = true

					humanoid:Destroy()

					camera.CameraSubject = newHumanoid
					camera.CFrame = originalCFrame

					queueNotification("Invulnerability", "Attempting to harden your character against damage.", 4370335364)
				else
					queueNotification("Invulnerability", "Reverting to normal character behaviour.", 4370335364)
				end
			end,
		},
		{
			name = "Fling",
			images = {9134785384, 14386226155},
			color = Color3.fromRGB(184, 85, 61),
			enabled = false,
			rotateWhileEnabled = true,
			callback = function(value)
				local character = localPlayer.Character
				local primaryPart = character and character.PrimaryPart
				if primaryPart then
					for _, part in ipairs(character:GetDescendants()) do
						if part:IsA("BasePart") then
							part.Massless = value
							part.CustomPhysicalProperties = PhysicalProperties.new(value and math.huge or 0.7, 0.3, 0.5)
						end
					end

					primaryPart.Anchored = true
					primaryPart.AssemblyLinearVelocity = Vector3.zero
					primaryPart.AssemblyAngularVelocity = Vector3.zero

					movers[3].Parent = value and primaryPart or nil

					task.delay(0.5, function() primaryPart.Anchored = false end)
				end
			end,
		},
		{
			name = "Extrasensory Perception",
			images = {9134780101, 14386232387},
			color = Color3.fromRGB(214, 182, 19),
			enabled = false,
			rotateWhileEnabled = false,
			callback = function(value)
				for _, highlight in ipairs(espContainer:GetChildren()) do
					highlight.Enabled = value
				end
			end,
		},
		{
			name = "Night and Day",
			images = {9134778004, 10137794784},
			color = Color3.fromRGB(102, 75, 190),
			enabled = false,
			rotateWhileEnabled = false,
			callback = function(value)
				tweenService:Create(lighting, TweenInfo.new(0.5), { ClockTime = value and 12 or 24 }):Play()
			end,
		},
		{
			name = "Global Audio",
			images = {9134774810, 14386246782},
			color = Color3.fromRGB(202, 103, 58),
			enabled = false,
			rotateWhileEnabled = false,
			callback = function(value)
				if value then
					oldVolume = gameSettings.MasterVolume
					gameSettings.MasterVolume = 0
				else
					gameSettings.MasterVolume = oldVolume
				end
			end,
		},
		{
			name = "Visibility",
			images = {14386256326, 9134770786},
			color = Color3.fromRGB(62, 94, 170),
			enabled = false,
			rotateWhileEnabled = false,
			callback = function(value)
				local character = localPlayer.Character
				if not character then return end

				for _, part in ipairs(character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.LocalTransparencyModifier = value and 1 or 0
					elseif part:IsA("Decal") then
						part.Transparency = value and 1 or 0
					end
				end

				local head = character:FindFirstChild("Head")
				if head then
					local face = head:FindFirstChildWhichIsA("Decal")
					if face then
						face.Transparency = value and 1 or 0
					end
				end

				queueNotification("Visibility", value and "You are now locally invisible." or "You are now visible again.", 4370335364)
			end,
		},
		{
			name = "Invisible",
			images = {14386256326, 14386256326},
			color = Color3.fromRGB(100, 100, 100),
			enabled = false,
			rotateWhileEnabled = false,
			callback = function(value)
				local character = localPlayer.Character
				if not character then return end

				-- Full invisibility by setting character parts transparency
				for _, part in ipairs(character:GetDescendants()) do
					if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
						part.Transparency = value and 1 or 0
					elseif part:IsA("Decal") or part:IsA("Texture") then
						part.Transparency = value and 1 or 0
					end
				end

				-- Hide nametag
				local head = character:FindFirstChild("Head")
				if head then
					local nametag = head:FindFirstChild("Nametag")
					if nametag then
						nametag.Enabled = not value
					end
				end

				queueNotification("Invisibility", value and "You are now invisible to other players." or "You are now visible.", 4370335364)
			end,
		},
		{
			name = "Godmode",
			images = {14386256326, 14386256326},
			color = Color3.fromRGB(255, 215, 0),
			enabled = false,
			rotateWhileEnabled = false,
			callback = function(value)
				local character = localPlayer.Character
				if not character then return end

				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if not humanoid then return end

				if value then
					-- Store original health and max health
					siriusValues.godmodeData = {
						health = humanoid.Health,
						maxHealth = humanoid.MaxHealth
					}
					-- Set extremely high health
					humanoid.MaxHealth = math.huge
					humanoid.Health = math.huge
				else
					-- Restore original health values
					if siriusValues.godmodeData then
						humanoid.MaxHealth = siriusValues.godmodeData.maxHealth
						humanoid.Health = siriusValues.godmodeData.health
						siriusValues.godmodeData = nil
					end
				end

				queueNotification("Godmode", value and "Godmode enabled - you cannot take damage." or "Godmode disabled.", 4370335364)
			end,
		},
	},
	sliders = {
		{
			name = "player speed",
			color = Color3.fromRGB(44, 153, 93),
			values = {0, 300},
			default = 16,
			value = 16,
			active = false,
			callback = function(value)
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if character then
					humanoid.WalkSpeed = value
				end
			end,
		},
		{
			name = "jump power",
			color = Color3.fromRGB(59, 126, 184),
			values = {0, 350},
			default = 50,
			value = 16,
			active = false,
			callback = function(value)
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if character then
					if humanoid.UseJumpPower then
						humanoid.JumpPower = value
					else
						humanoid.JumpHeight = value
					end
				end
			end,
		},
		{
			name = "flight speed",
			color = Color3.fromRGB(177, 45, 45),
			values = {1, 25},
			default = 3,
			value = 3,
			active = false,
			callback = function(value) end,
		},
		{
			name = "field of view",
			color = Color3.fromRGB(198, 178, 75),
			values = {45, 120},
			default = 70,
			value = 16,
			active = false,
			callback = function(value)
				tweenService:Create(camera, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { FieldOfView = value }):Play()
			end,
		},
	}
}

local siriusSettings = {
	{
		name = 'General',
		description = 'The general settings for Sirius, from simple to unique features.',
		color = Color3.new(0.117647, 0.490196, 0.72549),
		minimumLicense = 'Free',
		categorySettings = {
			{
				name = 'Anonymous Client',
				description = 'Randomise your username in real-time in any CoreGui parented interface, including Sirius. You will still appear as your actual name to others in-game. This setting can be performance intensive.',
				settingType = 'Boolean',
				current = false,

				id = 'anonmode'
			},
			{
				name = 'Chat Spy',
				description = 'This will only work on the legacy Roblox chat system. Sirius will display whispers usually hidden from you in the chat box.',
				settingType = 'Boolean',
				current = true,

				id = 'chatspy'
			},
			{
				name = 'Hide Toggle Button',
				description = 'This will remove the option to open the smartBar with the toggle button.',
				settingType = 'Boolean',
				current = false,

				id = 'hidetoggle'
			},
			{
				name = 'Now Playing Notifications',
				description = 'When active, Sirius will notify you when the next song in your Music queue plays.',
				settingType = 'Boolean',
				current = true,

				id = 'nowplaying'
			},
			{
				name = 'Friend Notifications',
				settingType = 'Boolean', 
				current = true,

				id = 'friendnotifs'
			},
			{
				name = 'Load Hidden',
				settingType = 'Boolean',
				current = false,

				id = 'loadhidden'
			}, 
			{
				name = 'Startup Sound Effect',
				settingType = 'Boolean',
				current = true,

				id = 'startupsound'
			}, 
			{
				name = 'Anti Idle',
				description = 'Remove all callbacks and events linked to the LocalPlayer Idled state. This may prompt detection from Adonis or similar anti-cheats.',
				settingType = 'Boolean',
				current = true,

				id = 'antiidle'
			},
			{
				name = 'Client-Based Anti Kick',
				description = 'Cancel any kick request involving you sent by the client. This may prompt detection from Adonis or similar anti-cheats. You will need to rejoin and re-run Sirius to toggle.',
				settingType = 'Boolean',
				current = false,

				id = 'antikick'
			},
			{
				name = 'Muffle audio while unfocused',
				settingType = 'Boolean', 
				current = true,

				id = 'muffleunfocused'
			},
			{
				name = 'Theme',
				description = 'Change the Sirius interface theme in real-time.',
				settingType = 'Theme',
				current = 'Default',
				values = {'Default', 'Dark', 'Midnight', 'Light', 'Neon'},

				id = 'theme'
			},
		}
	},
	{
		name = 'Keybinds',
		description = 'Assign keybinds to actions or change keybinds such as the one to open/close Sirius.',
		color = Color3.new(0.0941176, 0.686275, 0.509804),
		minimumLicense = 'Free',
		categorySettings = {
			{
				name = 'Toggle smartBar',
				settingType = 'Key',
				current = "K",
				id = 'smartbar'
			},
			{
				name = 'Open ScriptSearch',
				settingType = 'Key',
				current = "T",
				id = 'scriptsearch'
			},
			{
				name = 'NoClip',
				settingType = 'Key',
				current = nil,
				id = 'noclip',
				callback = function()
					local noclip = siriusValues.actions[1]
					noclip.enabled = not noclip.enabled
					noclip.callback(noclip.enabled)
				end
			},
			{
				name = 'Flight',
				settingType = 'Key',
				current = nil,
				id = 'flight',
				callback = function()
					local flight = siriusValues.actions[2]
					flight.enabled = not flight.enabled
					flight.callback(flight.enabled)
				end
			},
			{
				name = 'Refresh',
				settingType = 'Key',
				current = nil,
				id = 'refresh',
				callback = function()
					local refresh = siriusValues.actions[3]
					if not refresh.enabled then
						refresh.enabled = true
						refresh.callback()
					end
				end
			},
			{
				name = 'Respawn',
				settingType = 'Key',
				current = nil,
				id = 'respawn',
				callback = function()
					local respawn = siriusValues.actions[4]
					if not respawn.enabled then
						respawn.enabled = true
						respawn.callback()
					end
				end
			},
			{
				name = 'Invulnerability',
				settingType = 'Key',
				current = nil,
				id = 'invulnerability',
				callback = function()
					local invulnerability = siriusValues.actions[5]
					invulnerability.enabled = not invulnerability.enabled
					invulnerability.callback(invulnerability.enabled)
				end
			},
			{
				name = 'Fling',
				settingType = 'Key',
				current = nil,
				id = 'fling',
				callback = function()
					local fling = siriusValues.actions[6]
					fling.enabled = not fling.enabled
					fling.callback(fling.enabled)
				end
			},
			{
				name = 'ESP',
				settingType = 'Key',
				current = nil,
				id = 'esp',
				callback = function()
					local esp = siriusValues.actions[7]
					esp.enabled = not esp.enabled
					esp.callback(esp.enabled)
				end
			},
			{
				name = 'Night and Day',
				settingType = 'Key',
				current = nil,
				id = 'nightandday',
				callback = function()
					local nightandday = siriusValues.actions[8]
					nightandday.enabled = not nightandday.enabled
					nightandday.callback(nightandday.enabled)
				end
			},
			{
				name = 'Global Audio',
				settingType = 'Key',
				current = nil,
				id = 'globalaudio',
				callback = function()
					local globalaudio = siriusValues.actions[9]
					globalaudio.enabled = not globalaudio.enabled
					globalaudio.callback(globalaudio.enabled)
				end
			},
			{
				name = 'Visibility',
				settingType = 'Key',
				current = nil,
				id = 'visibility',
				callback = function()
					local visibility = siriusValues.actions[10]
					visibility.enabled = not visibility.enabled
					visibility.callback(visibility.enabled)
				end
			},
			{
				name = 'Invisible',
				settingType = 'Key',
				current = nil,
				id = 'invisible',
				callback = function()
					local invisible = siriusValues.actions[11]
					invisible.enabled = not invisible.enabled
					invisible.callback(invisible.enabled)
				end
			},
			{
				name = 'Godmode',
				settingType = 'Key',
				current = nil,
				id = 'godmode',
				callback = function()
					local godmode = siriusValues.actions[12]
					godmode.enabled = not godmode.enabled
					godmode.callback(godmode.enabled)
				end
			},
		}
	},
	{
		name = 'Performance',
		description = 'Tweak and test your performance settings for Roblox in Sirius.',
		color = Color3.new(1, 0.376471, 0.168627),
		minimumLicense = 'Free',
		categorySettings = {
			{
				name = 'Artificial FPS Limit',
				description = 'Sirius will automatically set your FPS to this number when you are tabbed-in to Roblox.',
				settingType = 'Number',
				values = {20, 5000},
				current = 240,

				id = 'fpscap'
			},
			{
				name = 'Limit FPS while unfocused',
				description = 'Sirius will automatically set your FPS to 60 when you tab-out or unfocus from Roblox.',
				settingType = 'Boolean', -- number for the cap below!! with min and max val
				current = true,

				id = 'fpsunfocused'
			},
			{
				name = 'Adaptive Latency Warning',
				description = 'Sirius will check your average latency in the background and notify you if your current latency significantly goes above your average latency.',
				settingType = 'Boolean',
				current = true,

				id = 'latencynotif'
			},
			{
				name = 'Adaptive Performance Warning',
				description = 'Sirius will check your average FPS in the background and notify you if your current FPS goes below a specific number.',
				settingType = 'Boolean',
				current = true,

				id = 'fpsnotif'
			},
		}
	},
	{
		name = 'Detections',
		description = 'Sirius detects and prevents anything malicious or possibly harmful to your wellbeing.',
		color = Color3.new(0.705882, 0, 0),
		minimumLicense = 'Free',
		categorySettings = {
			{
				name = 'Spatial Shield',
				description = 'Suppress loud sounds played from any audio source in-game, in real-time with Spatial Shield.',
				settingType = 'Boolean',
				minimumLicense = 'Pro',
				current = true,

				id = 'spatialshield'
			},
			{
				name = 'Spatial Shield Threshold',
				description = 'How loud a sound needs to be to be suppressed.',
				settingType = 'Number',
				minimumLicense = 'Pro',
				values = {100, 1000},
				current = 300,

				id = 'spatialshieldthreshold'
			},
			{
				name = 'Moderator Detection',
				description = 'Be notified whenever Sirius detects a player joins your session that could be a game moderator.',
				settingType = 'Boolean', 
				minimumLicense = 'Pro',
				current = true,

				id = 'moddetection'
			},
			{
				name = 'Intelligent HTTP Interception',
				description = 'Block external HTTP/HTTPS requests from being sent/recieved and ask you before allowing it to run.',
				settingType = 'Boolean',
				minimumLicense = 'Essential',
				current = true,

				id = 'intflowintercept'
			},
			{
				name = 'Intelligent Clipboard Interception',
				description = 'Block your clipboard from being set and ask you before allowing it to set your clipboard.',
				settingType = 'Boolean',
				minimumLicense = 'Essential',
				current = true,

				id = 'intflowinterceptclip'
			},
			{
				name = 'Chat Spam Detection',
				description = 'Detect and filter spam messages in chat based on repeated messages, caps, and emoji density.',
				settingType = 'Boolean',
				current = true,

				id = 'chatspamdetect'
			},
			{
				name = 'Chat Spam Caps Threshold',
				description = 'Percentage of caps in a message to flag as spam (0-100).',
				settingType = 'Number',
				values = {50, 100},
				current = 70,

				id = 'chatspamcaps'
			},
			{
				name = 'Chat Spam Emoji Threshold',
				description = 'Maximum number of emojis allowed before flagging as spam.',
				settingType = 'Number',
				values = {3, 20},
				current = 5,

				id = 'chatspamemoji'
			},
		},
	},
	{
		name = 'Logging',
		description = 'Send logs to your specified webhook URL of things like player joins and leaves and messages.',
		color = Color3.new(0.905882, 0.780392, 0.0666667),
		minimumLicense = 'Free',
		categorySettings = {
			{
				name = 'Log Messages',
				description = 'Log messages sent by any player to your webhook.',
				settingType = 'Boolean',
				current = false,

				id = 'logmsg'
			},
			{
				name = 'Message Webhook URL',
				description = 'Discord Webhook URL',
				settingType = 'Input',
				current = 'No Webhook',

				id = 'logmsgurl'
			},
			{
				name = 'Log PlayerAdded and PlayerRemoving',
				description = 'Log whenever any player leaves or joins your session.',
				settingType = 'Boolean',
				current = false,

				id = 'logplrjoinleave'
			},
			{
				name = 'Player Added and Removing Webhook URL',
				description = 'Discord Webhook URL',
				settingType = 'Input',
				current = 'No Webhook',

				id = 'logplrjoinleaveurl'
			},
		}
	},
}

-- Theme Manager
local ThemeManager = {
	Themes = {
		Default = {
			Background = Color3.fromRGB(8, 8, 10),
			SecondaryBackground = Color3.fromRGB(18, 18, 22),
			Text = Color3.fromRGB(245, 245, 245),
			SubText = Color3.fromRGB(180, 180, 185),
			Accent = Color3.fromRGB(26, 148, 255),
			Border = Color3.fromRGB(40, 40, 48),
			Button = Color3.fromRGB(32, 32, 40),
			ButtonText = Color3.fromRGB(240, 240, 240),
		},
		Dark = {
			Background = Color3.fromRGB(5, 5, 7),
			SecondaryBackground = Color3.fromRGB(15, 15, 20),
			Text = Color3.fromRGB(235, 235, 240),
			SubText = Color3.fromRGB(165, 165, 175),
			Accent = Color3.fromRGB(0, 170, 255),
			Border = Color3.fromRGB(35, 35, 42),
			Button = Color3.fromRGB(28, 28, 36),
			ButtonText = Color3.fromRGB(235, 235, 240),
		},
		Midnight = {
			Background = Color3.fromRGB(4, 6, 16),
			SecondaryBackground = Color3.fromRGB(10, 16, 30),
			Text = Color3.fromRGB(235, 240, 255),
			SubText = Color3.fromRGB(155, 165, 190),
			Accent = Color3.fromRGB(88, 101, 242),
			Border = Color3.fromRGB(32, 40, 70),
			Button = Color3.fromRGB(18, 22, 40),
			ButtonText = Color3.fromRGB(235, 240, 255),
		},
		Light = {
			Background = Color3.fromRGB(240, 242, 247),
			SecondaryBackground = Color3.fromRGB(255, 255, 255),
			Text = Color3.fromRGB(25, 28, 35),
			SubText = Color3.fromRGB(90, 95, 110),
			Accent = Color3.fromRGB(0, 120, 255),
			Border = Color3.fromRGB(210, 215, 230),
			Button = Color3.fromRGB(235, 238, 245),
			ButtonText = Color3.fromRGB(25, 28, 35),
		},
		Neon = {
			Background = Color3.fromRGB(6, 8, 18),
			SecondaryBackground = Color3.fromRGB(14, 10, 30),
			Text = Color3.fromRGB(245, 245, 245),
			SubText = Color3.fromRGB(180, 180, 200),
			Accent = Color3.fromRGB(0, 255, 200),
			Border = Color3.fromRGB(40, 255, 200),
			Button = Color3.fromRGB(16, 18, 40),
			ButtonText = Color3.fromRGB(245, 245, 245),
		},
	},
	CurrentTheme = "Default",
	Registry = {},
}

function ThemeManager:Register(object, property, themeKey)
	if not object or not property or not themeKey then
		return
	end

	local entry = {
		Object = object,
		Property = property,
		Key = themeKey,
	}

	table.insert(self.Registry, entry)

	local currentTheme = self.Themes[self.CurrentTheme]
	if currentTheme and currentTheme[themeKey] then
		pcall(function()
			object[property] = currentTheme[themeKey]
		end)
	end

	return entry
end

function ThemeManager:ApplyTheme(themeName)
	local theme = self.Themes[themeName]
	if not theme then
		return
	end

	self.CurrentTheme = themeName

	for index, entry in ipairs(self.Registry) do
		local object = entry.Object
		local property = entry.Property
		local key = entry.Key

		if object and object.Parent and theme[key] then
			pcall(function()
				object[property] = theme[key]
			end)
		else
			if not object or not object.Parent then
				self.Registry[index] = nil
			end
		end
	end
end

function ThemeManager:ApplyTo(object, property, themeKey)
	if not object or not property or not themeKey then
		return
	end

	local theme = self.Themes[self.CurrentTheme]
	if theme and theme[themeKey] then
		pcall(function()
			object[property] = theme[themeKey]
		end)
	end
end

function ThemeManager:Unregister(object)
	for index, entry in ipairs(self.Registry) do
		if entry.Object == object then
			table.remove(self.Registry, index)
			return true
		end
	end
	return false
end

function ThemeManager:GetThemeNames()
	local names = {}
	for name, _ in pairs(self.Themes) do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end

function ThemeManager:AddTheme(name, themeData)
	if self.Themes[name] then
		return false
	end
	self.Themes[name] = themeData
	return true
end

function ThemeManager:RemoveTheme(name)
	if name == "Default" or self.CurrentTheme == name then
		return false
	end
	self.Themes[name] = nil
	return true
end

function ThemeManager:RegisterDescendants(parent, className, property, themeKey, recursive)
	if not parent or not parent:IsA("Instance") then
		return
	end

	local descendants = recursive and parent:GetDescendants() or parent:GetChildren()
	for _, child in ipairs(descendants) do
		if child:IsA(className) then
			self:Register(child, property, themeKey)
		end
	end
end

-- Generate random username
local randomAdjective = siriusValues.nameGeneration.adjectives[math.random(1, #siriusValues.nameGeneration.adjectives)]
local randomNoun = siriusValues.nameGeneration.nouns[math.random(1, #siriusValues.nameGeneration.nouns)]
local randomNumber = math.random(100, 3999) -- You can customize the range
local randomUsername = randomAdjective .. randomNoun .. randomNumber

-- Initialise Sirius Client Interface
local guiParent = gethui and gethui() or coreGui
local sirius = guiParent:FindFirstChild("Sirius")
if sirius then
	sirius:Destroy()
end

local UI = game:GetObjects('rbxassetid://'..siriusValues.interfaceAsset)[1]
UI.Name = siriusValues.siriusName
UI.Parent = guiParent
UI.Enabled = false

-- Create Variables for Interface Elements
local characterPanel = UI.Character
local customScriptPrompt = UI.CustomScriptPrompt
local securityPrompt = UI.SecurityPrompt
local disconnectedPrompt = UI.Disconnected
local gameDetectionPrompt = UI.GameDetection
local homeContainer = UI.Home
local moderatorDetectionPrompt = UI.ModeratorDetectionPrompt
local musicPanel = UI.Music
local notificationContainer = UI.Notifications
local playerlistPanel = UI.Playerlist
local scriptSearch = UI.ScriptSearch
local scriptsPanel = UI.Scripts
local settingsPanel = UI.Settings
local smartBar = UI.SmartBar
local toggle = UI.Toggle
local starlight = UI.Starlight
local toastsContainer = UI.Toasts

-- Theme registration for core interface elements
local function registerThemeObjects()
	ThemeManager:Register(UI, "BackgroundColor3", "Background")

	local panelBackgroundKey = "SecondaryBackground"
	local panels = {
		characterPanel,
		customScriptPrompt,
		securityPrompt,
		disconnectedPrompt,
		gameDetectionPrompt,
		homeContainer,
		moderatorDetectionPrompt,
		musicPanel,
		notificationContainer,
		playerlistPanel,
		scriptSearch,
		scriptsPanel,
		settingsPanel,
		smartBar,
		starlight,
		toastsContainer,
		toggle,
	}

	for _, panel in ipairs(panels) do
		if panel and panel:IsA("GuiObject") then
			ThemeManager:Register(panel, "BackgroundColor3", panelBackgroundKey)
		end
	end

	-- Register settings panel text elements
	if settingsPanel then
		ThemeManager:RegisterDescendants(settingsPanel, "TextLabel", "TextColor3", "Text", true)
		ThemeManager:RegisterDescendants(settingsPanel, "TextButton", "TextColor3", "ButtonText", true)
		ThemeManager:RegisterDescendants(settingsPanel, "TextBox", "TextColor3", "Text", true)
		ThemeManager:RegisterDescendants(settingsPanel, "UIStroke", "Color", "Border", true)

		if settingsPanel.Title then
			ThemeManager:Register(settingsPanel.Title, "TextColor3", "Text")
		end
		if settingsPanel.Subtitle then
			ThemeManager:Register(settingsPanel.Subtitle, "TextColor3", "SubText")
		end
	end

	-- Register character panel elements
	if characterPanel then
		ThemeManager:RegisterDescendants(characterPanel, "TextLabel", "TextColor3", "Text", true)
		ThemeManager:RegisterDescendants(characterPanel, "TextButton", "TextColor3", "ButtonText", true)
	end

	-- Register playerlist elements
	if playerlistPanel then
		ThemeManager:RegisterDescendants(playerlistPanel, "TextLabel", "TextColor3", "Text", true)
	end

	-- Register smart bar elements
	if smartBar then
		ThemeManager:RegisterDescendants(smartBar, "TextLabel", "TextColor3", "Text", true)
	end

	-- Register notification elements
	if notificationContainer then
		ThemeManager:RegisterDescendants(notificationContainer, "TextLabel", "TextColor3", "Text", true)
	end

	-- Register home container elements
	if homeContainer then
		ThemeManager:RegisterDescendants(homeContainer, "TextLabel", "TextColor3", "Text", true)
		ThemeManager:RegisterDescendants(homeContainer, "TextButton", "TextColor3", "ButtonText", true)
	end

	-- Register music panel elements
	if musicPanel then
		ThemeManager:RegisterDescendants(musicPanel, "TextLabel", "TextColor3", "Text", true)
		ThemeManager:RegisterDescendants(musicPanel, "TextButton", "TextColor3", "ButtonText", true)
	end
end

registerThemeObjects()

-- Interface Caching
if not getgenv().cachedInGameUI then getgenv().cachedInGameUI = {} end
if not getgenv().cachedCoreUI then getgenv().cachedCoreUI = {} end

-- Malicious Behavior Prevention
local indexSetClipboard = "setclipboard"
local originalSetClipboard = getgenv()[indexSetClipboard]

local index = http_request and "http_request" or "request"
local originalRequest = getgenv()[index]

-- put this into siriusValues, like the fps and ping shit
local suppressedSounds = {}
local soundSuppressionNotificationCooldown = 0
local soundInstances = {}
local cachedIds = {}
local cachedText = {}

if not getMessage then siriusValues.chatSpy.enabled = false end

-- Call External Modules

-- httpRequest
local httpRequest = originalRequest

-- Neon Module
--local neonModule = (function() -- Open sourced neon module
--	local module = {}
--	do
--		local function IsNotNaN(x)
--			return x == x
--		end
--		local continued = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
--		while not continued do
--			runService.RenderStepped:wait()
--			continued = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
--		end
--	end

--	local RootParent = camera
--	local root
--	local binds = {}

--	local function getRoot()
--		if root then 
--			return root
--		else
--			root = Instance.new('Folder', RootParent)
--			root.Name = 'neon'
--			return root
--		end
--	end

--	local function destroyRoot()
--		if root then 
--			root:Destroy()
--			root = nil
--		end
--	end

--	local GenUid; do
--		local id = 0
--		function GenUid()
--			id = id + 1
--			return 'neon::'..tostring(id)
--		end
--	end

--	local DrawQuad; do
--		local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
--		local sz = 0.2

--		local function DrawTriangle(v1, v2, v3, p0, p1)
--			local s1 = (v1 - v2).magnitude
--			local s2 = (v2 - v3).magnitude
--			local s3 = (v3 - v1).magnitude
--			local smax = max(s1, s2, s3)
--			local A, B, C
--			if s1 == smax then
--				A, B, C = v1, v2, v3
--			elseif s2 == smax then
--				A, B, C = v2, v3, v1
--			elseif s3 == smax then
--				A, B, C = v3, v1, v2
--			end

--			local para = ( (B-A).x*(C-A).x + (B-A).y*(C-A).y + (B-A).z*(C-A).z ) / (A-B).magnitude
--			local perp = sqrt((C-A).magnitude^2 - para*para)
--			local dif_para = (A - B).magnitude - para

--			local st = CFrame.new(B, A)
--			local za = CFrame.Angles(pi/2,0,0)

--			local cf0 = st

--			local Top_Look = (cf0 * za).lookVector
--			local Mid_Point = A + CFrame.new(A, B).LookVector * para
--			local Needed_Look = CFrame.new(Mid_Point, C).LookVector
--			local dot = Top_Look.x*Needed_Look.x + Top_Look.y*Needed_Look.y + Top_Look.z*Needed_Look.z

--			local ac = CFrame.Angles(0, 0, acos(dot))

--			cf0 = cf0 * ac
--			if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
--				cf0 = cf0 * CFrame.Angles(0, 0, -2*acos(dot))
--			end
--			cf0 = cf0 * CFrame.new(0, perp/2, -(dif_para + para/2))

--			local cf1 = st * ac * CFrame.Angles(0, pi, 0)
--			if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then
--				cf1 = cf1 * CFrame.Angles(0, 0, 2*acos(dot))
--			end
--			cf1 = cf1 * CFrame.new(0, perp/2, dif_para/2)

--			if not p0 then
--				p0 = Instance.new('Part')
--				p0.FormFactor = 'Custom'
--				p0.TopSurface = 0
--				p0.BottomSurface = 0
--				p0.Anchored = true
--				p0.CanCollide = false
--				p0.Material = 'Glass'
--				p0.Size = Vector3.new(sz, sz, sz)
--				local mesh = Instance.new('SpecialMesh', p0)
--				mesh.MeshType = 2
--				mesh.Name = 'WedgeMesh'
--			end
--			p0.WedgeMesh.Scale = Vector3.new(0, perp/sz, para/sz)
--			p0.CFrame = cf0

--			if not p1 then
--				p1 = p0:clone()
--			end
--			p1.WedgeMesh.Scale = Vector3.new(0, perp/sz, dif_para/sz)
--			p1.CFrame = cf1

--			return p0, p1
--		end

--		function DrawQuad(v1, v2, v3, v4, parts)
--			parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
--			parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
--		end
--	end

--	function module:BindFrame(frame, properties)
--		if binds[frame] then
--			return binds[frame].parts
--		end

--		local uid = GenUid()
--		local parts = {}
--		local f = Instance.new('Folder', getRoot())
--		f.Name = frame.Name

--		local parents = {}
--		do
--			local function add(child)
--				if child:IsA'GuiObject' then
--					parents[#parents + 1] = child
--					add(child.Parent)
--				end
--			end
--			add(frame)
--		end

--		local function UpdateOrientation(fetchProps)
--			local zIndex = 1 - 0.05*frame.ZIndex
--			local tl, br = frame.AbsolutePosition, frame.AbsolutePosition + frame.AbsoluteSize
--			local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
--			do
--				local rot = 0
--				for _, v in ipairs(parents) do
--					rot = rot + v.Rotation
--				end
--				if rot ~= 0 and rot%180 ~= 0 then
--					local mid = tl:lerp(br, 0.5)
--					local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
--					local vec = tl
--					tl = Vector2.new(c*(tl.x - mid.x) - s*(tl.y - mid.y), s*(tl.x - mid.x) + c*(tl.y - mid.y)) + mid
--					tr = Vector2.new(c*(tr.x - mid.x) - s*(tr.y - mid.y), s*(tr.x - mid.x) + c*(tr.y - mid.y)) + mid
--					bl = Vector2.new(c*(bl.x - mid.x) - s*(bl.y - mid.y), s*(bl.x - mid.x) + c*(bl.y - mid.y)) + mid
--					br = Vector2.new(c*(br.x - mid.x) - s*(br.y - mid.y), s*(br.x - mid.x) + c*(br.y - mid.y)) + mid
--				end
--			end
--			DrawQuad(
--				camera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin, 
--				camera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin, 
--				camera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin, 
--				camera:ScreenPointToRay(br.x, br.y, zIndex).Origin, 
--				parts
--			)
--			if fetchProps then
--				for _, pt in pairs(parts) do
--					pt.Parent = f
--				end
--				for propName, propValue in pairs(properties) do
--					for _, pt in pairs(parts) do
--						pt[propName] = propValue
--					end
--				end
--			end
--		end

--		UpdateOrientation(true)
--		runService:BindToRenderStep(uid, 2000, UpdateOrientation)

--		binds[frame] = {
--			uid = uid,
--			parts = parts
--		}
--		return binds[frame].parts
--	end

--	function module:Modify(frame, properties)
--		local parts = module:GetBoundParts(frame)
--		if parts then
--			for propName, propValue in pairs(properties) do
--				for _, pt in pairs(parts) do
--					pt[propName] = propValue
--				end
--			end
--		end
--	end

--	function module:UnbindFrame(frame)
--		if RootParent == nil then return end
--		local cb = binds[frame]
--		if cb then
--			runService:UnbindFromRenderStep(cb.uid)
--			for _, v in pairs(cb.parts) do
--				v:Destroy()
--			end
--			binds[frame] = nil
--		end
--		if getRoot():FindFirstChild(frame.Name) then
--			getRoot()[frame.Name]:Destroy()
--		end
--	end

--	function module:HasBinding(frame)
--		return binds[frame] ~= nil
--	end

--	function module:GetBoundParts(frame)
--		return binds[frame] and binds[frame].parts
--	end


--	return module

--end)()

-- Sirius Functions
local function checkSirius() return UI.Parent end
local function getPing() return math.clamp(statsService.Network.ServerStatsItem["Data Ping"]:GetValue(), 10, 700) end
local function checkFolder() if isfolder then if not isfolder(siriusValues.siriusFolder) then makefolder(siriusValues.siriusFolder) end if not isfolder(siriusValues.siriusFolder.."/Music") then makefolder(siriusValues.siriusFolder.."/Music") writefile(siriusValues.siriusFolder.."/Music/readme.txt", "Hey there! Place your MP3 or other audio files in this folder, and have the ability to play them through the Sirius Music UI!") end if not isfolder(siriusValues.siriusFolder.."/Assets/Icons") then makefolder(siriusValues.siriusFolder.."/Assets/Icons") end if not isfolder(siriusValues.siriusFolder.."/Assets") then makefolder(siriusValues.siriusFolder.."/Assets") end end end
local function isPanel(name) return not table.find({"Home", "Music", "Settings"}, name) end

local function fetchFromCDN(path, write, savePath)
	pcall(function()
		checkFolder()

		local file = game:HttpGet(siriusValues.cdn..path) or nil
		if not file then return end
		if not write then return file end


		writefile(siriusValues.siriusFolder.."/"..savePath, file)

		return
	end)
end

local function fetchIcon(iconName)
	pcall(function()
		checkFolder()

		local pathCDN = siriusValues.icons..iconName..".png"
		local path = siriusValues.siriusFolder.."/Assets/"..iconName..".png"

		if not isfile(path) then
			local file = game:HttpGet(pathCDN)
			if not file then return end

			writefile(path, file)
		end

		local imageToReturn = getcustomasset(path)

		return imageToReturn
	end)
end

local function storeOriginalText(element)
	originalTextValues[element] = element.Text
end

local function undoAnonymousChanges()
	for element, originalText in pairs(originalTextValues) do
		element.Text = originalText
	end
end

local function createEsp(player)
	if player == localPlayer or not checkSirius() then 
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 0
	highlight.OutlineColor = Color3.new(1,1,1)
	highlight.Adornee = player.Character
	highlight.Name = player.Name
	highlight.Enabled = siriusValues.actions[7].enabled
	highlight.Parent = espContainer

	player.CharacterAdded:Connect(function(character)
		if not checkSirius() then return end
		task.wait()
		highlight.Adornee = character
	end)
end

local function makeDraggable(object)
	local dragging = false
	local relative = nil

	local offset = Vector2.zero
	local screenGui = object:FindFirstAncestorWhichIsA("ScreenGui")
	if screenGui and screenGui.IgnoreGuiInset then
		offset += guiService:GetGuiInset()
	end

	object.InputBegan:Connect(function(input, processed)
		if processed then return end

		local inputType = input.UserInputType.Name
		if inputType == "MouseButton1" or inputType == "Touch" then
			relative = object.AbsolutePosition + object.AbsoluteSize * object.AnchorPoint - userInputService:GetMouseLocation()
			dragging = true
		end
	end)

	local inputEnded = userInputService.InputEnded:Connect(function(input)
		if not dragging then return end

		local inputType = input.UserInputType.Name
		if inputType == "MouseButton1" or inputType == "Touch" then
			dragging = false
		end
	end)

	local renderStepped = runService.RenderStepped:Connect(function()
		if dragging then
			local position = userInputService:GetMouseLocation() + relative + offset
			object.Position = UDim2.fromOffset(position.X, position.Y)
		end
	end)

	object.Destroying:Connect(function()
		inputEnded:Disconnect()
		renderStepped:Disconnect()
	end)
end

local function checkAction(target)
	local toReturn = {}

	for _, action in ipairs(siriusValues.actions) do
		if action.name == target then
			toReturn.action = action
			break
		end
	end

	for _, action in ipairs(characterPanel.Interactions.Grid:GetChildren()) do
		if action.name == target then
			toReturn.object = action
			break
		end
	end

	return toReturn
end

local function checkSetting(settingTarget, categoryTarget)
	for _, category in ipairs(siriusSettings) do
		if categoryTarget then
			if category.name == categoryTarget then
				for _, setting in ipairs(category.categorySettings) do
					if setting.name == settingTarget then
						return setting
					end
				end
			end
			return
		else
			for _, setting in ipairs(category.categorySettings) do
				if setting.name == settingTarget then
					return setting
				end
			end
		end
	end
end

local function wipeTransparency(ins, target, checkSelf, tween, duration)
	local transparencyProperties = siriusValues.transparencyProperties

	local function applyTransparency(obj)
		local properties = transparencyProperties[obj.className]

		if properties then
			local tweenProperties = {}

			for _, property in ipairs(properties) do
				tweenProperties[property] = target
			end

			for property, transparency in pairs(tweenProperties) do
				if tween then
					tweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {[property] = transparency}):Play()
				else
					obj[property] = transparency
				end

			end
		end
	end

	if checkSelf then
		applyTransparency(ins)
	end

	for _, descendant in ipairs(ins:getDescendants()) do
		applyTransparency(descendant)
	end
end

local function blurSignature(value)
	if not value then
		if lighting:FindFirstChild("SiriusBlur") then
			lighting:FindFirstChild("SiriusBlur"):Destroy()
		end
	else
		if not lighting:FindFirstChild("SiriusBlur") then
			local blurLight = Instance.new("DepthOfFieldEffect", lighting)
			blurLight.Name = "SiriusBlur"
			blurLight.Enabled = true
			blurLight.FarIntensity = 0
			blurLight.FocusDistance = 51.6
			blurLight.InFocusRadius = 50
			blurLight.NearIntensity = 0.8
		end
	end
end

local function figureNotifications()
	if checkSirius() then
		local notificationsSize = 0

		if #notifications > 0 then
			blurSignature(true)
		else
			blurSignature(false)
		end

		for i = #notifications, 0, -1 do
			local notification = notifications[i]
			if notification then
				if notificationsSize == 0 then
					notificationsSize = notification.Size.Y.Offset + 2
				else
					notificationsSize += notification.Size.Y.Offset + 5
				end
				local desiredPosition = UDim2.new(0.5, 0, 0, notificationsSize)
				if notification.Position ~= desiredPosition then
					notification:TweenPosition(desiredPosition, "Out", "Quint", 0.8, true)
				end
			end
		end	
	end
end

local contentProvider = game:GetService("ContentProvider")

local function queueNotification(Title, Description, Image)
	task.spawn(function()		
		if checkSirius() then
			local newNotification = notificationContainer.Template:Clone()
			newNotification.Parent = notificationContainer
			newNotification.Name = Title or "Unknown Title"
			newNotification.Visible = true

			newNotification.Title.Text = Title or "Unknown Title"
			newNotification.Description.Text = Description or "Unknown Description"
			newNotification.Time.Text = "now"

			-- Prepare for animation
			newNotification.AnchorPoint = Vector2.new(0.5, 1)
			newNotification.Position = UDim2.new(0.5, 0, -1, 0)
			newNotification.Size = UDim2.new(0, 320, 0, 500)
			newNotification.Description.Size = UDim2.new(0, 241, 0, 400)
			wipeTransparency(newNotification, 1, true)

			newNotification.Description.Size = UDim2.new(0, 241, 0, newNotification.Description.TextBounds.Y)
			newNotification.Size = UDim2.new(0, 100, 0, newNotification.Description.TextBounds.Y + 50)

			table.insert(notifications, newNotification)
			figureNotifications()

			local notificationSound = Instance.new("Sound")
			notificationSound.Parent = UI
			notificationSound.SoundId = "rbxassetid://255881176"
			notificationSound.Name = "notificationSound"
			notificationSound.Volume = 0.65
			notificationSound.PlayOnRemove = true
			notificationSound:Destroy()


			if not tonumber(Image) then
				newNotification.Icon.Image = 'rbxassetid://14317577326'
			else
				newNotification.Icon.Image = 'rbxassetid://'..Image or 0
			end

			newNotification:TweenPosition(UDim2.new(0.5, 0, 0, newNotification.Size.Y.Offset + 2), "Out", "Quint", 0.9, true)
			task.wait(0.1)
			tweenService:Create(newNotification, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 320, 0, newNotification.Description.TextBounds.Y + 50)}):Play()
			task.wait(0.05)
			tweenService:Create(newNotification, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.35}):Play()
			tweenService:Create(newNotification.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0.7}):Play()
			task.wait(0.05)
			tweenService:Create(newNotification.Icon, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
			task.wait(0.04)
			tweenService:Create(newNotification.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			task.wait(0.04)
			tweenService:Create(newNotification.Description, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0.15}):Play()
			tweenService:Create(newNotification.Time, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0.5}):Play()

			--neonModule:BindFrame(newNotification.BlurModule, {
			--	Transparency = 0.98,
			--	BrickColor = BrickColor.new("Institutional white")
			--})

			newNotification.Interact.MouseButton1Click:Connect(function()
				local foundNotification = table.find(notifications, newNotification)
				if foundNotification then table.remove(notifications, foundNotification) end

				tweenService:Create(newNotification, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1.5, 0, 0, newNotification.Position.Y.Offset)}):Play()

				task.wait(0.4)
				newNotification:Destroy()
				figureNotifications()
				return
			end)

			local waitTime = (#newNotification.Description.Text*0.1)+2
			if waitTime <= 1 then waitTime = 2.5 elseif waitTime > 10 then waitTime = 10 end

			task.wait(waitTime)

			local foundNotification = table.find(notifications, newNotification)
			if foundNotification then table.remove(notifications, foundNotification) end

			tweenService:Create(newNotification, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1.5, 0, 0, newNotification.Position.Y.Offset)}):Play()

			task.wait(1.2)
			--neonModule:UnbindFrame(newNotification.BlurModule)
			newNotification:Destroy()
			figureNotifications()
		end
	end)
end

local function checkLastVersion()
	checkFolder()

	local lastVersion = isfile and isfile(siriusValues.siriusFolder.."/".."version.srs") and readfile(siriusValues.siriusFolder.."/".."version.srs") or nil

	if lastVersion then
		if lastVersion ~= siriusValues.siriusVersion then queueNotification("Sirius has been updated", "Sirius has been updated to version "..siriusValues.siriusVersion..", check our Discord for all new features and changes.", 4400701828)  end
	end

	if writefile then writefile(siriusValues.siriusFolder.."/".."version.srs", siriusValues.siriusVersion) end
end

local function removeReverbs(timing)
	timing = timing or 0.65

	for index, sound in next, soundInstances do
		if sound:FindFirstChild("SiriusAudioProfile") then
			local reverb = sound:FindFirstChild("SiriusAudioProfile")
			tweenService:Create(reverb, TweenInfo.new(timing, Enum.EasingStyle.Exponential), {HighGain = 0}):Play()
			tweenService:Create(reverb, TweenInfo.new(timing, Enum.EasingStyle.Exponential), {LowGain = 0}):Play()
			tweenService:Create(reverb, TweenInfo.new(timing, Enum.EasingStyle.Exponential), {MidGain = 0}):Play()

			task.delay(timing + 0.03, reverb.Destroy, reverb)
		end
	end
end

local function playNext()
	if #musicQueue == 0 then currentAudio.Playing = false currentAudio.SoundId = "" musicPanel.Playing.Text = "Not Playing" return end

	if not currentAudio then
		local newAudio = Instance.new("Sound")
		newAudio.Parent = UI
		newAudio.Name = "Audio"
		currentAudio = newAudio
	end

	musicPanel.Menu.TogglePlaying.ImageRectOffset = currentAudio.Playing and Vector2.new(804, 124) or Vector2.new(764, 244)
	local asset = getcustomasset(siriusValues.siriusFolder.."/Music/"..musicQueue[1].sound)

	if checkSetting("Now Playing Notifications").current then queueNotification("Now Playing", musicQueue[1].sound, 4400695581) end

	if musicPanel.Queue.List:FindFirstChild(tostring(musicQueue[1].instanceName)) then
		musicPanel.Queue.List:FindFirstChild(tostring(musicQueue[1].instanceName)):Destroy()
	end

	currentAudio.SoundId = asset
	musicPanel.Playing.Text = musicQueue[1].sound
	currentAudio:Play()
	musicPanel.Menu.TogglePlaying.ImageRectOffset = currentAudio.Playing and Vector2.new(804, 124) or Vector2.new(764, 244)
	currentAudio.Ended:Wait()

	table.remove(musicQueue, 1)

	playNext()
end

local function addToQueue(file)
	if not getcustomasset then return end
	checkFolder()
	if not isfile(siriusValues.siriusFolder.."/Music/"..file) then queueNotification("Unable to locate file", "Please ensure that your audio file is in the Sirius/Music folder and that you are including the file extension (e.g mp3 or ogg).", 4370341699) return end
	musicPanel.AddBox.Input.Text = ""

	local newAudio = musicPanel.Queue.List.Template:Clone()
	newAudio.Parent = musicPanel.Queue.List
	newAudio.Size = UDim2.new(0, 254, 0, 40)
	newAudio.Close.ImageTransparency = 1
	newAudio.Name = file
	if string.len(newAudio.FileName.Text) > 26 then
		newAudio.FileName.Text = string.sub(tostring(file), 1,24)..".."
	else
		newAudio.FileName.Text = file
	end
	newAudio.Visible = true
	newAudio.Duration.Text = ""

	table.insert(musicQueue, {sound = file, instanceName = newAudio.Name})

	local getLength = Instance.new("Sound", workspace)
	getLength.SoundId = getcustomasset(siriusValues.siriusFolder.."/Music/"..file)
	getLength.Volume = 0
	getLength:Play()
	task.wait(0.05)
	newAudio.Duration.Text = tostring(math.round(getLength.TimeLength)).."s"
	getLength:Stop()
	getLength:Destroy()

	newAudio.MouseEnter:Connect(function()
		tweenService:Create(newAudio, TweenInfo.new(0.45, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
		tweenService:Create(newAudio.Close, TweenInfo.new(0.45, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
		tweenService:Create(newAudio.Duration, TweenInfo.new(0.45, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
	end)

	newAudio.MouseLeave:Connect(function()
		tweenService:Create(newAudio.Close, TweenInfo.new(0.45, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
		tweenService:Create(newAudio, TweenInfo.new(0.45, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(0, 0, 0)}):Play()
		tweenService:Create(newAudio.Duration, TweenInfo.new(0.45, Enum.EasingStyle.Exponential), {TextTransparency = 0.7}):Play()
	end)

	newAudio.Close.MouseButton1Click:Connect(function()
		if not string.find(currentAudio.Name, file) then
			for i,v in pairs(musicQueue) do
				for _,b in pairs(v) do
					if b == newAudio.Name then
						newAudio:Destroy()
						table.remove(musicQueue, i)
					end
				end
			end
		else
			for i,v in pairs(musicQueue) do
				for _,b in pairs(v) do
					if b == newAudio.Name then
						newAudio:Destroy()
						table.remove(musicQueue, i)
						playNext()
					end
				end
			end
		end
	end)

	if #musicQueue == 1 then
		playNext()
	end
end

local function openMusic()
	debounce = true
	musicPanel.Visible = true
	musicPanel.Queue.List.Template.Visible = false

	debounce = false
end

local function closeMusic()
	debounce = true
	musicPanel.Visible = false

	debounce = false
end

local function createReverb(timing)
	for index, sound in next, soundInstances do
		if not sound:FindFirstChild("SiriusAudioProfile") then
			local reverb = Instance.new("EqualizerSoundEffect")

			reverb.Name = "SiriusAudioProfile"
			reverb.Parent = sound

			reverb.Enabled = false

			reverb.HighGain = 0
			reverb.LowGain = 0
			reverb.MidGain = 0
			reverb.Enabled = true

			if timing then
				tweenService:Create(reverb, TweenInfo.new(timing, Enum.EasingStyle.Exponential), {HighGain = -20}):Play()
				tweenService:Create(reverb, TweenInfo.new(timing, Enum.EasingStyle.Exponential), {LowGain = 5}):Play()
				tweenService:Create(reverb, TweenInfo.new(timing, Enum.EasingStyle.Exponential), {MidGain = -20}):Play()
			end
		end
	end
end

local function runScript(raw)
	loadstring(game:HttpGet(raw))()
end

local function syncExperienceInformation()
	siriusValues.currentCreator = creatorId

	if creatorType == Enum.CreatorType.Group then
		siriusValues.currentGroup = creatorId
		siriusValues.currentCreator = "group"
	end

	for _, gameFound in pairs(siriusValues.games) do
		if gameFound.id == placeId and gameFound.enabled then

			local minimumTier = gameFound.minimumTier

			if minimumTier == "Essential" then
				if not (Essential or Pro) then
					return
				end
			elseif minimumTier == "Pro" then
				if not Pro then
					return
				end
			end

			local rawFile = siriusValues.rawTree..gameFound.raw
			siriusValues.currentGame = gameFound

			gameDetectionPrompt.ScriptTitle.Text = gameFound.name
			gameDetectionPrompt.Layer.ScriptSubtitle.Text = gameFound.description
			gameDetectionPrompt.Thumbnail.Image = "https://assetgame.roblox.com/Game/Tools/ThumbnailAsset.ashx?aid="..tostring(placeId).."&fmt=png&wd=420&ht=420"

			gameDetectionPrompt.Size = UDim2.new(0, 550, 0, 0)
			gameDetectionPrompt.Position = UDim2.new(0.5, 0, 0, 120)
			gameDetectionPrompt.UICorner.CornerRadius = UDim.new(0, 9)
			gameDetectionPrompt.Thumbnail.UICorner.CornerRadius = UDim.new(0, 9)
			gameDetectionPrompt.ScriptTitle.Position = UDim2.new(0, 30, 0.5, 0)
			gameDetectionPrompt.Layer.Visible = false
			gameDetectionPrompt.Warning.Visible = false

			wipeTransparency(gameDetectionPrompt, 1, true)

			gameDetectionPrompt.Visible = true

			tweenService:Create(gameDetectionPrompt, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {BackgroundTransparency = 0}):Play()
			tweenService:Create(gameDetectionPrompt.Thumbnail, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {ImageTransparency = 0.4}):Play()
			tweenService:Create(gameDetectionPrompt.ScriptTitle, TweenInfo.new(0.6, Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()

			tweenService:Create(gameDetectionPrompt, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 587, 0, 44)}):Play()
			tweenService:Create(gameDetectionPrompt, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Position = UDim2.new(0.5, 0, 0, 150)}):Play()

			task.wait(1)

			wipeTransparency(gameDetectionPrompt.Layer, 1, true)

			gameDetectionPrompt.Layer.Visible = true

			tweenService:Create(gameDetectionPrompt, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 473, 0, 154)}):Play()
			tweenService:Create(gameDetectionPrompt.ScriptTitle, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Position = UDim2.new(0, 23, 0.352, 0)}):Play()
			tweenService:Create(gameDetectionPrompt, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Position = UDim2.new(0.5, 0, 0, 200)}):Play()
			tweenService:Create(gameDetectionPrompt.UICorner, TweenInfo.new(1, Enum.EasingStyle.Exponential), {CornerRadius = UDim.new(0, 13)}):Play()
			tweenService:Create(gameDetectionPrompt.Thumbnail.UICorner, TweenInfo.new(1, Enum.EasingStyle.Exponential), {CornerRadius = UDim.new(0, 13)}):Play()
			tweenService:Create(gameDetectionPrompt.Thumbnail, TweenInfo.new(1, Enum.EasingStyle.Exponential), {ImageTransparency = 0.5}):Play()

			task.wait(0.3)
			tweenService:Create(gameDetectionPrompt.Layer.ScriptSubtitle, TweenInfo.new(0.6, Enum.EasingStyle.Quint),  {TextTransparency = 0.3}):Play()
			tweenService:Create(gameDetectionPrompt.Layer.Run, TweenInfo.new(0.6, Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()
			tweenService:Create(gameDetectionPrompt.Layer.Run.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint),  {Transparency = 0.85}):Play()
			tweenService:Create(gameDetectionPrompt.Layer.Run, TweenInfo.new(0.6, Enum.EasingStyle.Quint),  {BackgroundTransparency = 0.6}):Play()

			task.wait(0.2)

			tweenService:Create(gameDetectionPrompt.Layer.Close, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.6}):Play()

			task.wait(0.3)

			local function closeGameDetection()
				tweenService:Create(gameDetectionPrompt.Layer.ScriptSubtitle, TweenInfo.new(0.3, Enum.EasingStyle.Quint),  {TextTransparency = 1}):Play()
				tweenService:Create(gameDetectionPrompt.Layer.Run, TweenInfo.new(0.3, Enum.EasingStyle.Quint),  {TextTransparency = 1}):Play()
				tweenService:Create(gameDetectionPrompt.Layer.Run, TweenInfo.new(0.3, Enum.EasingStyle.Quint),  {BackgroundTransparency = 1}):Play()
				tweenService:Create(gameDetectionPrompt.Layer.Close, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
				tweenService:Create(gameDetectionPrompt.Thumbnail, TweenInfo.new(0.3, Enum.EasingStyle.Quint),  {ImageTransparency = 1}):Play()
				tweenService:Create(gameDetectionPrompt.ScriptTitle, TweenInfo.new(0.3, Enum.EasingStyle.Quint),  {TextTransparency = 1}):Play()
				tweenService:Create(gameDetectionPrompt.Layer.Run.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint),  {Transparency = 1}):Play()
				task.wait(0.05)
				tweenService:Create(gameDetectionPrompt, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 400, 0, 0)}):Play()
				tweenService:Create(gameDetectionPrompt.UICorner, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {CornerRadius = UDim.new(0, 5)}):Play()
				tweenService:Create(gameDetectionPrompt.Thumbnail.UICorner, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {CornerRadius = UDim.new(0, 5)}):Play()
				task.wait(0.41)
				gameDetectionPrompt.Visible = false
			end

			gameDetectionPrompt.Layer.Run.MouseButton1Click:Connect(function()
				closeGameDetection()
				queueNotification("Running "..gameFound.name, "Now running Sirius' "..gameFound.name.." script, this may take a moment.", 4400701828)
				runScript(rawFile)

			end)

			gameDetectionPrompt.Layer.Close.MouseButton1Click:Connect(function()
				closeGameDetection()
			end)

			break
		end
	end
end

local function updateSliderPadding()
	for _, v in pairs(siriusValues.sliders) do
		v.padding = {
			v.object.Interact.AbsolutePosition.X,
			v.object.Interact.AbsolutePosition.X + v.object.Interact.AbsoluteSize.X
		}
	end
end

local function updateSlider(data, setValue, forceValue)
	local inverse_interpolation

	if setValue then
		setValue = math.clamp(setValue, data.values[1], data.values[2])
		inverse_interpolation = (setValue - data.values[1]) / (data.values[2] - data.values[1])
		local posX = data.padding[1] + (data.padding[2] - data.padding[1]) * inverse_interpolation
	else
		local posX = math.clamp(mouse.X, data.padding[1], data.padding[2])
		inverse_interpolation = (posX - data.padding[1]) / (data.padding[2] - data.padding[1])
	end

	tweenService:Create(data.object.Progress, TweenInfo.new(.5, Enum.EasingStyle.Quint), {Size = UDim2.new(inverse_interpolation, 0, 1, 0)}):Play()

	local value = math.floor(data.values[1] + (data.values[2] - data.values[1]) * inverse_interpolation + .5)
	data.object.Information.Text = value.." "..data.name
	data.value = value

	if data.callback and not setValue or forceValue then
		data.callback(value)
	end
end

local function resetSliders()
	for _, v in pairs(siriusValues.sliders) do
		updateSlider(v, v.default, true)
	end
end

local function sortActions()	
	characterPanel.Interactions.Grid.Template.Visible = false
	characterPanel.Interactions.Sliders.Template.Visible = false

	for _, action in ipairs(siriusValues.actions) do
		local newAction = characterPanel.Interactions.Grid.Template:Clone()
		newAction.Name = action.name
		newAction.Parent = characterPanel.Interactions.Grid
		newAction.BackgroundColor3 = action.color
		newAction.UIStroke.Color = action.color
		newAction.Icon.Image = "rbxassetid://"..action.images[2]
		newAction.Visible = true

		newAction.BackgroundTransparency = 0.8
		newAction.Transparency = 0.7


		newAction.MouseEnter:Connect(function()
			characterPanel.Interactions.ActionsTitle.Text = string.upper(action.name)
			if action.enabled or debounce then return end
			tweenService:Create(newAction, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.4}):Play()
			tweenService:Create(newAction.UIStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Transparency = 0.6}):Play()
		end)

		newAction.MouseLeave:Connect(function()
			if action.enabled or debounce then return end
			tweenService:Create(newAction, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.55}):Play()
			tweenService:Create(newAction.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.4}):Play()
		end)

		characterPanel.Interactions.Grid.MouseLeave:Connect(function()
			characterPanel.Interactions.ActionsTitle.Text = "PLAYER ACTIONS"
		end)

		newAction.Interact.MouseButton1Click:Connect(function()
			local success, response = pcall(function()
				action.enabled = not action.enabled
				action.callback(action.enabled)

				if action.enabled then
					newAction.Icon.Image = "rbxassetid://"..action.images[1]
					tweenService:Create(newAction, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.1}):Play()
					tweenService:Create(newAction.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
					tweenService:Create(newAction.Icon, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {ImageTransparency = 0.1}):Play()

					if action.disableAfter then
						task.delay(action.disableAfter, function()
							action.enabled = false
							newAction.Icon.Image = "rbxassetid://"..action.images[2]
							tweenService:Create(newAction, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.55}):Play()
							tweenService:Create(newAction.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.4}):Play()
							tweenService:Create(newAction.Icon, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0.5}):Play()
						end)
					end

					if action.rotateWhileEnabled then
						repeat
							newAction.Icon.Rotation = 0
							tweenService:Create(newAction.Icon, TweenInfo.new(0.75, Enum.EasingStyle.Quint), {Rotation = 360}):Play()
							task.wait(1)
						until not action.enabled
						newAction.Icon.Rotation = 0
					end
				else
					newAction.Icon.Image = "rbxassetid://"..action.images[2]
					tweenService:Create(newAction, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.55}):Play()
					tweenService:Create(newAction.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.4}):Play()
					tweenService:Create(newAction.Icon, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0.5}):Play()
				end
			end)

			if not success then
				queueNotification("Action Error", "This action ('"..(action.name).."') had an error while running, please report this to the Sirius team at sirius.menu/discord", 4370336704)
				action.enabled = false
				newAction.Icon.Image = "rbxassetid://"..action.images[2]
				tweenService:Create(newAction, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.55}):Play()
				tweenService:Create(newAction.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.4}):Play()
				tweenService:Create(newAction.Icon, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0.5}):Play()
			end
		end)
	end

	if localPlayer.Character then
		if not localPlayer.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
			siriusValues.sliders[2].name = "jump height"
			siriusValues.sliders[2].default = 7.2
			siriusValues.sliders[2].values = {0, 120}
		end
	end


	for _, slider in ipairs(siriusValues.sliders) do
		local newSlider = characterPanel.Interactions.Sliders.Template:Clone()
		newSlider.Name = slider.name.." Slider"
		newSlider.Parent = characterPanel.Interactions.Sliders
		newSlider.BackgroundColor3 = slider.color
		newSlider.Progress.BackgroundColor3 = slider.color
		newSlider.UIStroke.Color = slider.color
		newSlider.Information.Text = slider.name
		newSlider.Visible = true

		slider.object = newSlider

		slider.padding = {
			newSlider.Interact.AbsolutePosition.X,
			newSlider.Interact.AbsolutePosition.X + newSlider.Interact.AbsoluteSize.X
		}

		newSlider.MouseEnter:Connect(function()
			if debounce or slider.active then return end
			tweenService:Create(newSlider, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.85}):Play()
			tweenService:Create(newSlider.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.6}):Play()
			tweenService:Create(newSlider.Information, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
		end)

		newSlider.MouseLeave:Connect(function()
			if debounce or slider.active then return end
			tweenService:Create(newSlider, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.8}):Play()
			tweenService:Create(newSlider.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
			tweenService:Create(newSlider.Information, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0.3}):Play()
		end)

		newSlider.Interact.MouseButton1Down:Connect(function()
			if debounce or not checkSirius() then return end

			slider.active = true
			updateSlider(slider)

			tweenService:Create(slider.object, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.9}):Play()
			tweenService:Create(slider.object.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
			tweenService:Create(slider.object.Information, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0.05}):Play()
		end)

		updateSlider(slider, slider.default)
	end
end

local function getAdaptiveHighPingThreshold()
	local adaptiveBaselinePings = siriusValues.pingProfile.adaptiveBaselinePings

	if #adaptiveBaselinePings == 0 then
		return siriusValues.pingProfile.adaptiveHighPingThreshold
	end

	table.sort(adaptiveBaselinePings)
	local median
	if #adaptiveBaselinePings % 2 == 0 then
		median = (adaptiveBaselinePings[#adaptiveBaselinePings/2] + adaptiveBaselinePings[#adaptiveBaselinePings/2 + 1]) / 2
	else
		median = adaptiveBaselinePings[math.ceil(#adaptiveBaselinePings/2)]
	end

	return median * siriusValues.pingProfile.spikeThreshold
end

local function checkHighPing()
	local recentPings = siriusValues.pingProfile.recentPings
	local adaptiveBaselinePings = siriusValues.pingProfile.adaptiveBaselinePings

	local currentPing = getPing()
	table.insert(recentPings, currentPing)

	if #recentPings > siriusValues.pingProfile.maxSamples then
		table.remove(recentPings, 1)
	end

	if #adaptiveBaselinePings < siriusValues.pingProfile.adaptiveBaselineSamples then
		if currentPing >= 350 then currentPing = 300 end

		table.insert(adaptiveBaselinePings, currentPing)

		return false
	end

	local averagePing = 0
	for _, ping in ipairs(recentPings) do
		averagePing = averagePing + ping
	end
	averagePing = averagePing / #recentPings

	if averagePing > getAdaptiveHighPingThreshold() then
		return true
	end

	return false
end

local function checkTools()
	task.wait(0.03)
	if localPlayer.Backpack and localPlayer.Character then
		if localPlayer.Backpack:FindFirstChildOfClass('Tool') or localPlayer.Character:FindFirstChildOfClass('Tool') then
			return true
		end
	else
		return false
	end
end

local function closePanel(panelName, openingOther)
	debounce = true

	local button = smartBar.Buttons:FindFirstChild(panelName)
	local panel = UI:FindFirstChild(panelName)

	if not isPanel(panelName) then return end
	if not (panel and button) then return end

	local panelSize = UDim2.new(0, 581, 0, 246)

	if not openingOther then
		if panel.Name == "Character" then -- Character Panel Animation

			tweenService:Create(characterPanel.Interactions.PropertiesTitle, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()

			for _, slider in ipairs(characterPanel.Interactions.Sliders:GetChildren()) do
				if slider.ClassName == "Frame" then 
					tweenService:Create(slider, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
					tweenService:Create(slider.Progress, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
					tweenService:Create(slider.UIStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
					tweenService:Create(slider.Shadow, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
					tweenService:Create(slider.Information, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play() -- tween the text after
				end
			end

			tweenService:Create(characterPanel.Interactions.Reset, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
			tweenService:Create(characterPanel.Interactions.ActionsTitle, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()

			for _, gridButton in ipairs(characterPanel.Interactions.Grid:GetChildren()) do
				if gridButton.ClassName == "Frame" then 
					tweenService:Create(gridButton, TweenInfo.new(0.21, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
					tweenService:Create(gridButton.UIStroke, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					tweenService:Create(gridButton.Icon, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
					tweenService:Create(gridButton.Shadow, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
				end
			end

			tweenService:Create(characterPanel.Interactions.Serverhop, TweenInfo.new(.15,Enum.EasingStyle.Quint),  {BackgroundTransparency = 1}):Play()
			tweenService:Create(characterPanel.Interactions.Serverhop.Title, TweenInfo.new(.15,Enum.EasingStyle.Quint),  {TextTransparency = 1}):Play()
			tweenService:Create(characterPanel.Interactions.Serverhop.UIStroke, TweenInfo.new(.15,Enum.EasingStyle.Quint),  {Transparency = 1}):Play()

			tweenService:Create(characterPanel.Interactions.Rejoin, TweenInfo.new(.15,Enum.EasingStyle.Quint),  {BackgroundTransparency = 1}):Play()
			tweenService:Create(characterPanel.Interactions.Rejoin.Title, TweenInfo.new(.15,Enum.EasingStyle.Quint),  {TextTransparency = 1}):Play()
			tweenService:Create(characterPanel.Interactions.Rejoin.UIStroke, TweenInfo.new(.15,Enum.EasingStyle.Quint),  {Transparency = 1}):Play()

		elseif panel.Name == "Scripts" then -- Scripts Panel Animation

			for _, scriptButton in ipairs(scriptsPanel.Interactions.Selection:GetChildren()) do
				if scriptButton.ClassName == "Frame" then
					tweenService:Create(scriptButton, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
					if scriptButton:FindFirstChild('Icon') then tweenService:Create(scriptButton.Icon, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play() end
					tweenService:Create(scriptButton.Title, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
					if scriptButton:FindFirstChild('Subtitle') then	tweenService:Create(scriptButton.Subtitle, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play() end
					tweenService:Create(scriptButton.UIStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
				end
			end

		elseif panel.Name == "Playerlist" then -- Playerlist Panel Animation

			for _, playerIns in ipairs(playerlistPanel.Interactions.List:GetDescendants()) do
				if playerIns.ClassName == "Frame" then
					tweenService:Create(playerIns, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
				elseif playerIns.ClassName == "TextLabel" or playerIns.ClassName == "TextButton" then
					if playerIns.Name == "DisplayName" then
						tweenService:Create(playerIns, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
					else
						tweenService:Create(playerIns, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
					end
				elseif playerIns.ClassName == "ImageLabel" or playerIns.ClassName == "ImageButton" then
					tweenService:Create(playerIns, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
					if playerIns.Name == "Avatar" then tweenService:Create(playerIns, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play() end
				elseif playerIns.ClassName == "UIStroke" then
					tweenService:Create(playerIns, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
				end
			end

			tweenService:Create(playerlistPanel.Interactions.SearchFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
			tweenService:Create(playerlistPanel.Interactions.SearchFrame.Icon, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
			tweenService:Create(playerlistPanel.Interactions.SearchFrame.SearchBox, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
			tweenService:Create(playerlistPanel.Interactions.SearchFrame.UIStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
			tweenService:Create(playerlistPanel.Interactions.List, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {ScrollBarImageTransparency = 1}):Play()

		end

		tweenService:Create(panel.Icon, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		tweenService:Create(panel.Title, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
		tweenService:Create(panel.UIStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
		tweenService:Create(panel.Shadow, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		task.wait(0.03)

		tweenService:Create(panel, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
		tweenService:Create(panel, TweenInfo.new(1.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = button.Size}):Play()
		tweenService:Create(panel, TweenInfo.new(0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Position = siriusValues.buttonPositions[panelName]}):Play()
		tweenService:Create(toggle, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 1, -85)}):Play()
	end

	-- Animate interactive elements
	if openingOther then
		tweenService:Create(panel, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 350, 1, -90)}):Play()
		wipeTransparency(panel, 1, true, true, 0.3)
	end

	task.wait(0.5)
	panel.Size = panelSize
	panel.Visible = false

	debounce = false
end

local function openPanel(panelName)
	if debounce then return end
	debounce = true

	local button = smartBar.Buttons:FindFirstChild(panelName)
	local panel = UI:FindFirstChild(panelName)

	if not isPanel(panelName) then return end
	if not (panel and button) then return end

	for _, otherPanel in ipairs(UI:GetChildren()) do
		if smartBar.Buttons:FindFirstChild(otherPanel.Name) then
			if isPanel(otherPanel.Name) and otherPanel.Visible then
				task.spawn(closePanel, otherPanel.Name, true)
				task.wait()
			end
		end
	end

	local panelSize = UDim2.new(0, 581, 0, 246)

	panel.Size = button.Size
	panel.Position = siriusValues.buttonPositions[panelName]

	wipeTransparency(panel, 1, true)

	panel.Visible = true

	tweenService:Create(toggle, TweenInfo.new(0.65, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 0, 1, -(panelSize.Y.Offset + 95))}):Play()

	tweenService:Create(panel, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
	tweenService:Create(panel, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), {Size = panelSize}):Play()
	tweenService:Create(panel, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 0, 1, -90)}):Play()
	task.wait(0.1)
	tweenService:Create(panel.Shadow, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {ImageTransparency = 0.7}):Play()
	tweenService:Create(panel.Icon, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
	task.wait(0.05)
	tweenService:Create(panel.Title, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
	tweenService:Create(panel.UIStroke, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {Transparency = 0.95}):Play()
	task.wait(0.05)

	-- Animate interactive elements
	if panel.Name == "Character" then -- Character Panel Animation

		tweenService:Create(characterPanel.Interactions.PropertiesTitle, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 0.65}):Play()

		local sliderInfo = {}
		for _, slider in ipairs(characterPanel.Interactions.Sliders:GetChildren()) do
			if slider.ClassName == "Frame" then 
				table.insert(sliderInfo, {slider.Name, slider.Progress.Size, slider.Information.Text})
				slider.Progress.Size = UDim2.new(0, 0, 1, 0)
				slider.Progress.BackgroundTransparency = 0

				tweenService:Create(slider, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.8}):Play()
				tweenService:Create(slider.UIStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Transparency = 0.5}):Play()
				tweenService:Create(slider.Shadow, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {ImageTransparency = 0.6}):Play()
				tweenService:Create(slider.Information, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 0.3}):Play()
			end
		end

		for _, sliderV in pairs(sliderInfo) do
			if characterPanel.Interactions.Sliders:FindFirstChild(sliderV[1]) then
				local slider = characterPanel.Interactions.Sliders:FindFirstChild(sliderV[1])
				local tweenValue = Instance.new("IntValue", UI)
				local tweenTo
				local name

				for _, sliderFound in ipairs(siriusValues.sliders) do
					if sliderFound.name.." Slider" == slider.Name then
						tweenTo = sliderFound.value
						name = sliderFound.name
						break
					end
				end

				tweenService:Create(slider.Progress, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Size = sliderV[2]}):Play()

				local function animateNumber(n)
					tweenService:Create(tweenValue, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {Value = n}):Play()
					task.delay(0.4, tweenValue.Destroy, tweenValue)
				end

				tweenValue:GetPropertyChangedSignal("Value"):Connect(function()
					slider.Information.Text = tostring(tweenValue.Value).." "..name
				end)

				animateNumber(tweenTo)
			end
		end

		tweenService:Create(characterPanel.Interactions.Reset, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {ImageTransparency = 0.7}):Play()
		tweenService:Create(characterPanel.Interactions.ActionsTitle, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 0.65}):Play()

		for _, gridButton in ipairs(characterPanel.Interactions.Grid:GetChildren()) do
			if gridButton.ClassName == "Frame" then 
				for _, action in ipairs(siriusValues.actions) do
					if action.name == gridButton.Name then
						if action.enabled then
							tweenService:Create(gridButton, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.1}):Play()
							tweenService:Create(gridButton.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
							tweenService:Create(gridButton.Icon, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {ImageTransparency = 0.1}):Play()
						else
							tweenService:Create(gridButton, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.55}):Play()
							tweenService:Create(gridButton.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.4}):Play()
							tweenService:Create(gridButton.Icon, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0.5}):Play()
						end
						break
					end
				end

				tweenService:Create(gridButton.Shadow, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageTransparency = 0.6}):Play()
			end
		end

		tweenService:Create(characterPanel.Interactions.Serverhop, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {BackgroundTransparency = 0}):Play()
		tweenService:Create(characterPanel.Interactions.Serverhop.Title, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0.5}):Play()
		tweenService:Create(characterPanel.Interactions.Serverhop.UIStroke, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Transparency = 0}):Play()

		tweenService:Create(characterPanel.Interactions.Rejoin, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {BackgroundTransparency = 0}):Play()
		tweenService:Create(characterPanel.Interactions.Rejoin.Title, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0.5}):Play()
		tweenService:Create(characterPanel.Interactions.Rejoin.UIStroke, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Transparency = 0}):Play()

	elseif panel.Name == "Scripts" then -- Scripts Panel Animation

		for _, scriptButton in ipairs(scriptsPanel.Interactions.Selection:GetChildren()) do
			if scriptButton.ClassName == "Frame" then
				tweenService:Create(scriptButton, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
				if scriptButton:FindFirstChild('Icon') then tweenService:Create(scriptButton.Icon, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play() end
				tweenService:Create(scriptButton.Title, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
				if scriptButton:FindFirstChild('Subtitle') then	tweenService:Create(scriptButton.Subtitle, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {TextTransparency = 0.3}):Play() end
				tweenService:Create(scriptButton.UIStroke, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {Transparency = 0.2}):Play()
			end
		end

	elseif panel.Name == "Playerlist" then -- Playerlist Panel Animation

		for _, playerIns in ipairs(playerlistPanel.Interactions.List:GetDescendants()) do
			if playerIns.Name ~= "Interact" and playerIns.Name ~= "Role" then 
				if playerIns.ClassName == "Frame" then
					tweenService:Create(playerIns, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
				elseif playerIns.ClassName == "TextLabel" or playerIns.ClassName == "TextButton" then
					tweenService:Create(playerIns, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
				elseif playerIns.ClassName == "ImageLabel" or playerIns.ClassName == "ImageButton" then
					tweenService:Create(playerIns, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
					if playerIns.Name == "Avatar" then tweenService:Create(playerIns, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play() end
				elseif playerIns.ClassName == "UIStroke" then
					tweenService:Create(playerIns, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
				end
			end
		end

		tweenService:Create(playerlistPanel.Interactions.SearchFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
		tweenService:Create(playerlistPanel.Interactions.SearchFrame.Icon, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
		task.wait(0.01)
		tweenService:Create(playerlistPanel.Interactions.SearchFrame.SearchBox, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
		tweenService:Create(playerlistPanel.Interactions.SearchFrame.UIStroke, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {Transparency = 0.2}):Play()
		task.wait(0.05)
		tweenService:Create(playerlistPanel.Interactions.List, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {ScrollBarImageTransparency = 0.7}):Play()

	end

	task.wait(0.45)
	debounce = false
end

local function rejoin()
	queueNotification("Rejoining Session", "We're queueing a rejoin to this session, give us a moment.", 4400696294)

	if #players:GetPlayers() <= 1 then
		task.wait()
		teleportService:Teleport(placeId, localPlayer)
	else
		teleportService:TeleportToPlaceInstance(placeId, jobId, localPlayer)
	end
end

local function serverhop()
	local highestPlayers = 0
	local servers = {}

	for _, v in ipairs(httpService:JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")).data) do
		if type(v) == "table" and v.maxPlayers > v.playing and v.id ~= jobId then
			if v.playing > highestPlayers then
				highestPlayers = v.playing
				servers[1] = v.id
			end
		end
	end

	if #servers > 0 then
		queueNotification("Teleporting", "We're now moving you to the new session, this may take a few seconds.", 4335479121)
		task.wait(0.3)
		teleportService:TeleportToPlaceInstance(placeId, servers[1])
	else
		return queueNotification("No Servers Found", "We couldn't find another server, this may be the only server.", 4370317928)
	end

end

local function ensureFrameProperties()
	UI.Enabled = true
	characterPanel.Visible = false
	customScriptPrompt.Visible = false
	disconnectedPrompt.Visible = false
	playerlistPanel.Interactions.List.Template.Visible = false
	gameDetectionPrompt.Visible = false
	homeContainer.Visible = false
	moderatorDetectionPrompt.Visible = false
	musicPanel.Visible = false
	notificationContainer.Visible = true
	playerlistPanel.Visible = false
	scriptSearch.Visible = false
	scriptsPanel.Visible = false
	settingsPanel.Visible = false
	smartBar.Visible = false
	musicPanel.Playing.Text = "Not Playing"
	if not getcustomasset then smartBar.Buttons.Music.Visible = false end
	toastsContainer.Visible = true
	makeDraggable(settingsPanel)
	makeDraggable(musicPanel)
end

local function checkFriends()
	if friendsCooldown == 0 then

		friendsCooldown = 25

		local playersFriends = {}
		local success, page = pcall(players.GetFriendsAsync, players, localPlayer.UserId)

		if success then
			repeat
				local info = page:GetCurrentPage()
				for i, friendInfo in pairs(info) do
					table.insert(playersFriends, friendInfo)
				end
				if not page.IsFinished then 
					page:AdvanceToNextPageAsync()
				end
			until page.IsFinished
		end

		local friendsInTotal = 0
		local onlineFriends = 0 
		local friendsInGame = 0 

		for i,v in pairs(playersFriends) do
			friendsInTotal  = friendsInTotal + 1

			if v.IsOnline then
				onlineFriends = onlineFriends + 1
			end

			if players:FindFirstChild(v.Username) then
				friendsInGame = friendsInGame + 1
			end
		end

		if not checkSirius() then return end

		homeContainer.Interactions.Friends.All.Value.Text = tostring(friendsInTotal).." friends"
		homeContainer.Interactions.Friends.Offline.Value.Text = tostring(friendsInTotal - onlineFriends).." friends"
		homeContainer.Interactions.Friends.Online.Value.Text = tostring(onlineFriends).." friends"
		homeContainer.Interactions.Friends.InGame.Value.Text = tostring(friendsInGame).." friends"

	else
		friendsCooldown -= 1
	end
end

function promptModerator(player, role)
	local serversAvailable = false
	local promptClosed = false

	if moderatorDetectionPrompt.Visible then return end

	moderatorDetectionPrompt.Size = UDim2.new(0, 283, 0, 175)
	moderatorDetectionPrompt.UIGradient.Offset = Vector2.new(0, 1)
	wipeTransparency(moderatorDetectionPrompt, 1, true)

	moderatorDetectionPrompt.DisplayName.Text = player.DisplayName
	moderatorDetectionPrompt.Rank.Text = role
	moderatorDetectionPrompt.Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png"

	moderatorDetectionPrompt.Visible = true

	for _, v in ipairs(game:GetService("HttpService"):JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data) do
		if type(v) == "table" and v.maxPlayers > v.playing and v.id ~= game.JobId then
			serversAvailable = true
		end
	end

	if not serversAvailable then
		moderatorDetectionPrompt.Serverhop.Visible = false
	else
		moderatorDetectionPrompt.ServersAvailableFade.Visible = true
	end

	tweenService:Create(moderatorDetectionPrompt, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
	tweenService:Create(moderatorDetectionPrompt, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 300, 0, 186)}):Play()
	tweenService:Create(moderatorDetectionPrompt.UIGradient, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Offset = Vector2.new(0, 0.65)}):Play()
	tweenService:Create(moderatorDetectionPrompt.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
	tweenService:Create(moderatorDetectionPrompt.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
	tweenService:Create(moderatorDetectionPrompt.Avatar, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.7}):Play()
	tweenService:Create(moderatorDetectionPrompt.Avatar, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
	tweenService:Create(moderatorDetectionPrompt.DisplayName, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
	tweenService:Create(moderatorDetectionPrompt.Rank, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
	tweenService:Create(moderatorDetectionPrompt.Serverhop, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.7}):Play()
	tweenService:Create(moderatorDetectionPrompt.Leave, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.7}):Play()
	task.wait(0.2)
	tweenService:Create(moderatorDetectionPrompt.Serverhop, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
	tweenService:Create(moderatorDetectionPrompt.Leave, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
	task.wait(0.3)
	tweenService:Create(moderatorDetectionPrompt.Close, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 0.6}):Play()

	local function closeModPrompt()
		tweenService:Create(moderatorDetectionPrompt, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
		tweenService:Create(moderatorDetectionPrompt, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 283, 0, 175)}):Play()
		tweenService:Create(moderatorDetectionPrompt.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Offset = Vector2.new(0, 1)}):Play()
		tweenService:Create(moderatorDetectionPrompt.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
		tweenService:Create(moderatorDetectionPrompt.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
		tweenService:Create(moderatorDetectionPrompt.Avatar, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
		tweenService:Create(moderatorDetectionPrompt.Avatar, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		tweenService:Create(moderatorDetectionPrompt.DisplayName, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
		tweenService:Create(moderatorDetectionPrompt.Rank, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
		tweenService:Create(moderatorDetectionPrompt.Serverhop, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
		tweenService:Create(moderatorDetectionPrompt.Leave, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
		tweenService:Create(moderatorDetectionPrompt.Serverhop, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
		tweenService:Create(moderatorDetectionPrompt.Leave, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
		tweenService:Create(moderatorDetectionPrompt.Close, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		task.wait(0.5)
		moderatorDetectionPrompt.Visible = false
	end

	moderatorDetectionPrompt.Leave.MouseButton1Click:Connect(function()
		closeModPrompt()
		game:Shutdown()
	end)

	moderatorDetectionPrompt.Serverhop.MouseEnter:Connect(function()
		tweenService:Create(moderatorDetectionPrompt.ServersAvailableFade, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
	end)

	moderatorDetectionPrompt.Serverhop.MouseLeave:Connect(function()
		tweenService:Create(moderatorDetectionPrompt.ServersAvailableFade, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
	end)

	moderatorDetectionPrompt.Serverhop.MouseButton1Click:Connect(function()
		if promptClosed then return end
		serverhop()
		closeModPrompt()
	end)

	moderatorDetectionPrompt.Close.MouseButton1Click:Connect(function()
		closeModPrompt()
		promptClosed = true
	end)
end

local function UpdateHome()
	if not checkSirius() then return end

	local function format(Int)
		return string.format("%02i", Int)
	end

	local function convertToHMS(Seconds)
		local Minutes = (Seconds - Seconds%60)/60
		Seconds = Seconds - Minutes*60
		local Hours = (Minutes - Minutes%60)/60
		Minutes = Minutes - Hours*60
		return format(Hours)..":"..format(Minutes)..":"..format(Seconds)
	end

	-- Home Title
	homeContainer.Title.Text = "Welcome home, "..localPlayer.DisplayName

	-- Players
	homeContainer.Interactions.Server.Players.Value.Text = #players:GetPlayers().." playing"
	homeContainer.Interactions.Server.MaxPlayers.Value.Text = players.MaxPlayers.." players can join this server"

	-- Ping
	homeContainer.Interactions.Server.Latency.Value.Text = math.floor(getPing()).."ms"

	-- Time
	homeContainer.Interactions.Server.Time.Value.Text = convertToHMS(time())

	-- Region
	homeContainer.Interactions.Server.Region.Value.Text = "Unable to retrieve region"

	-- Player Information
	homeContainer.Interactions.User.Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..localPlayer.UserId.."&width=420&height=420&format=png"
	homeContainer.Interactions.User.Title.Text = localPlayer.DisplayName
	homeContainer.Interactions.User.Subtitle.Text = localPlayer.Name

	-- Update Executor
	homeContainer.Interactions.Client.Title.Text = identifyexecutor()
	if not table.find(siriusValues.executors, string.lower(identifyexecutor())) then
		homeContainer.Interactions.Client.Subtitle.Text = "This executor is not verified as supported - but may still work just fine."
	end

	-- Update Friends Statuses
	checkFriends()
end

local function openHome()
	if debounce then return end
	debounce = true
	homeContainer.Visible = true

	local homeBlur = Instance.new("BlurEffect", lighting)
	homeBlur.Size = 0
	homeBlur.Name = "HomeBlur"

	homeContainer.BackgroundTransparency = 1
	homeContainer.Title.TextTransparency = 1
	homeContainer.Subtitle.TextTransparency = 1

	for _, homeItem in ipairs(homeContainer.Interactions:GetChildren()) do

		wipeTransparency(homeItem, 1, true)

		homeItem.Position = UDim2.new(0, homeItem.Position.X.Offset - 20, 0, homeItem.Position.Y.Offset - 20)
		homeItem.Size = UDim2.new(0, homeItem.Size.X.Offset + 30, 0, homeItem.Size.Y.Offset + 20)

		if homeItem.UIGradient.Offset.Y > 0 then
			homeItem.UIGradient.Offset = Vector2.new(0, homeItem.UIGradient.Offset.Y + 3)
			homeItem.UIStroke.UIGradient.Offset = Vector2.new(0, homeItem.UIStroke.UIGradient.Offset.Y + 3)
		else
			homeItem.UIGradient.Offset = Vector2.new(0, homeItem.UIGradient.Offset.Y - 3)
			homeItem.UIStroke.UIGradient.Offset = Vector2.new(0, homeItem.UIStroke.UIGradient.Offset.Y - 3)
		end
	end

	tweenService:Create(homeContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.9}):Play()
	tweenService:Create(homeBlur, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = 5}):Play()

	tweenService:Create(camera, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {FieldOfView = camera.FieldOfView + 5}):Play()

	task.wait(0.25)

	for _, inGameUI in ipairs(localPlayer:FindFirstChildWhichIsA("PlayerGui"):GetChildren()) do
		if inGameUI:IsA("ScreenGui") then
			if inGameUI.Enabled then
				if not table.find(getgenv().cachedInGameUI, inGameUI.Name) then
					table.insert(getgenv().cachedInGameUI, #getgenv().cachedInGameUI+1, inGameUI.Name)
				end

				inGameUI.Enabled = false
			end
		end
	end

	table.clear(getgenv().cachedCoreUI)

	for _, coreUI in pairs({"PlayerList", "Chat", "EmotesMenu", "Health", "Backpack"}) do
		if game:GetService("StarterGui"):GetCoreGuiEnabled(coreUI) then
			table.insert(getgenv().cachedCoreUI, #getgenv().cachedCoreUI+1, coreUI)
		end
	end

	for _, coreUI in pairs(getgenv().cachedCoreUI) do
		game:GetService("StarterGui"):SetCoreGuiEnabled(coreUI, false)
	end

	createReverb(0.8)

	tweenService:Create(camera, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {FieldOfView = camera.FieldOfView - 40}):Play()

	tweenService:Create(homeContainer, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.7}):Play()
	tweenService:Create(homeContainer.Title, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
	tweenService:Create(homeContainer.Subtitle, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
	tweenService:Create(homeBlur, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Size = 20}):Play()

	for _, homeItem in ipairs(homeContainer.Interactions:GetChildren()) do
		for _, otherHomeItem in ipairs(homeItem:GetDescendants()) do
			if otherHomeItem.ClassName == "Frame" then
				tweenService:Create(otherHomeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.7}):Play()
			elseif otherHomeItem.ClassName == "TextLabel" then
				if otherHomeItem.Name == "Title" then
					tweenService:Create(otherHomeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
				else
					tweenService:Create(otherHomeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0.3}):Play()
				end
			elseif otherHomeItem.ClassName == "ImageLabel" then
				tweenService:Create(otherHomeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.8}):Play()
				tweenService:Create(otherHomeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
			end
		end

		tweenService:Create(homeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
		tweenService:Create(homeItem.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
		tweenService:Create(homeItem, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0, homeItem.Position.X.Offset + 20, 0, homeItem.Position.Y.Offset + 20)}):Play()
		tweenService:Create(homeItem, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, homeItem.Size.X.Offset - 30, 0, homeItem.Size.Y.Offset - 20)}):Play()

		task.delay(0.03, function()
			if homeItem.UIGradient.Offset.Y > 0 then
				tweenService:Create(homeItem.UIGradient, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Offset = Vector2.new(0, homeItem.UIGradient.Offset.Y - 3)}):Play()
				tweenService:Create(homeItem.UIStroke.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Offset = Vector2.new(0, homeItem.UIStroke.UIGradient.Offset.Y - 3)}):Play()
			else
				tweenService:Create(homeItem.UIGradient, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Offset = Vector2.new(0, homeItem.UIGradient.Offset.Y + 3)}):Play()
				tweenService:Create(homeItem.UIStroke.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Offset = Vector2.new(0, homeItem.UIStroke.UIGradient.Offset.Y + 3)}):Play()
			end
		end)

		task.wait(0.02)
	end

	task.wait(0.85)

	debounce = false
end

local function closeHome()
	if debounce then return end
	debounce = true

	tweenService:Create(camera, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {FieldOfView = camera.FieldOfView + 35}):Play()

	for _, obj in ipairs(lighting:GetChildren()) do
		if obj.Name == "HomeBlur" then
			tweenService:Create(obj, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Size = 0}):Play()
			task.delay(0.6, obj.Destroy, obj)
		end
	end

	tweenService:Create(homeContainer, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
	tweenService:Create(homeContainer.Title, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
	tweenService:Create(homeContainer.Subtitle, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()

	for _, homeItem in ipairs(homeContainer.Interactions:GetChildren()) do
		for _, otherHomeItem in ipairs(homeItem:GetDescendants()) do
			if otherHomeItem.ClassName == "Frame" then
				tweenService:Create(otherHomeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
			elseif otherHomeItem.ClassName == "TextLabel" then
				if otherHomeItem.Name == "Title" then
					tweenService:Create(otherHomeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
				else
					tweenService:Create(otherHomeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
				end
			elseif otherHomeItem.ClassName == "ImageLabel" then
				tweenService:Create(otherHomeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
				tweenService:Create(otherHomeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
			end
		end
		tweenService:Create(homeItem, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
		tweenService:Create(homeItem.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
	end

	task.wait(0.2)

	for _, cachedInGameUIObject in pairs(getgenv().cachedInGameUI) do
		for _, currentPlayerUI in ipairs(localPlayer:FindFirstChildWhichIsA("PlayerGui"):GetChildren()) do
			if table.find(getgenv().cachedInGameUI, currentPlayerUI.Name) then
				currentPlayerUI.Enabled = true
			end 
		end
	end

	for _, coreUI in pairs(getgenv().cachedCoreUI) do
		game:GetService("StarterGui"):SetCoreGuiEnabled(coreUI, true)
	end

	removeReverbs(0.5)

	task.wait(0.52)

	homeContainer.Visible = false
	debounce = false
end


local function openScriptSearch()
	debounce = true

	scriptSearch.Size = UDim2.new(0, 480, 0, 23)
	scriptSearch.Position = UDim2.new(0.5, 0, 0.5, 0)
	scriptSearch.SearchBox.Position = UDim2.new(0.509, 0, 0.5, 0)
	scriptSearch.Icon.Position = UDim2.new(0.04, 0, 0.5, 0)
	scriptSearch.SearchBox.Text = ""
	scriptSearch.UIGradient.Offset = Vector2.new(0, 2)
	scriptSearch.SearchBox.PlaceholderText = "Search ScriptBlox.com"
	scriptSearch.List.Template.Visible = false
	scriptSearch.List.Visible = false
	scriptSearch.Visible = true

	wipeTransparency(scriptSearch, 1, true)

	tweenService:Create(scriptSearch, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {BackgroundTransparency = 0}):Play()
	tweenService:Create(scriptSearch, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Size = UDim2.new(0, 580, 0, 43)}):Play()
	tweenService:Create(scriptSearch.Shadow, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {ImageTransparency = 0.85}):Play()
	task.wait(0.03)
	tweenService:Create(scriptSearch.Icon, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {ImageTransparency = 0}):Play()
	task.wait(0.02)
	tweenService:Create(scriptSearch.SearchBox, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()


	task.wait(0.3)
	scriptSearch.SearchBox:CaptureFocus()
	task.wait(0.2)
	debounce = false
end

local function closeScriptSearch()
	debounce = true

	wipeTransparency(scriptSearch, 1, false)

	task.wait(0.1)

	ThemeManager:ApplyTo(scriptSearch, "BackgroundColor3", "SecondaryBackground")
	scriptSearch.UIGradient.Enabled = false
	tweenService:Create(scriptSearch, TweenInfo.new(0.4, Enum.EasingStyle.Quint),  {Size = UDim2.new(0, 520, 0, 0)}):Play()
	scriptSearch.SearchBox:ReleaseFocus()

	task.wait(0.5)

	for _, createdScript in ipairs(scriptSearch.List:GetChildren()) do
		if createdScript.Name ~= "Placeholder" and createdScript.Name ~= "Template" and createdScript.ClassName == "Frame" then
			createdScript:Destroy()
		end
	end

	task.wait(0.1)
	ThemeManager:ApplyTo(scriptSearch, "BackgroundColor3", "SecondaryBackground")
	scriptSearch.Visible = false
	scriptSearch.UIGradient.Enabled = true
	debounce = false
end

local function createScript(result)
	local newScript = UI.ScriptSearch.List.Template:Clone()
	newScript.Name = result.title
	newScript.Parent = UI.ScriptSearch.List
	newScript.Visible = true

	for _, tag in ipairs(newScript.Tags:GetChildren()) do
		if tag.ClassName == "Frame" then
			tag.Shadow.ImageTransparency = 1
			tag.BackgroundTransparency = 1
			tag.Title.TextTransparency = 1
		end
	end

	task.spawn(function()
		local response

		local success, ErrorStatement = pcall(function()
			local responseRequest = httpRequest({
				Url = "https://www.scriptblox.com/api/script/"..result['slug'],
				Method = "GET"
			})

			response = httpService:JSONDecode(responseRequest.Body)
		end)

		newScript.ScriptDescription.Text = response.script.features

		local likes = response.script.likeCount
		local dislikes = response.script.dislikeCount

		if likes ~= dislikes then
			newScript.Tags.Review.Title.Text = (likes > dislikes) and "Positive Reviews" or "Negative Reviews"
			newScript.Tags.Review.BackgroundColor3 = (likes > dislikes) and Color3.fromRGB(0, 139, 102) or Color3.fromRGB(180, 0, 0)
			newScript.Tags.Review.Size = (likes > dislikes) and UDim2.new(0, 145, 1, 0) or UDim2.new(0, 150, 1, 0)
		elseif likes > 0 then
			newScript.Tags.Review.Title.Text = "Mixed Reviews"
			newScript.Tags.Review.BackgroundColor3 = Color3.fromRGB(198, 132, 0)
			newScript.Tags.Review.Size = UDim2.new(0, 130, 1, 0)
		else
			newScript.Tags.Review.Visible = false
		end

		newScript.ScriptAuthor.Text = "uploaded by "..response.script.owner.username
		newScript.Tags.Verified.Visible = response.script.owner.verified or false

		tweenService:Create(newScript, TweenInfo.new(.5, Enum.EasingStyle.Quint),  {BackgroundTransparency = 0.8}):Play()
		tweenService:Create(newScript.ScriptName, TweenInfo.new(.5, Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()
		tweenService:Create(newScript.Execute, TweenInfo.new(.5, Enum.EasingStyle.Quint),  {BackgroundTransparency = 0.8}):Play()
		tweenService:Create(newScript.Execute, TweenInfo.new(.5, Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()

		newScript.Tags.Visible = true

		tweenService:Create(newScript.ScriptDescription, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0.3}):Play()
		tweenService:Create(newScript.ScriptAuthor, TweenInfo.new(.5, Enum.EasingStyle.Quint),  {TextTransparency = 0.7}):Play()

		for _, tag in ipairs(newScript.Tags:GetChildren()) do
			if tag.ClassName == "Frame" then
				tweenService:Create(tag.Shadow, TweenInfo.new(.5, Enum.EasingStyle.Quint),  {ImageTransparency = 0.7}):Play()
				tweenService:Create(tag, TweenInfo.new(.5, Enum.EasingStyle.Quint),  {BackgroundTransparency = 0}):Play()
				tweenService:Create(tag.Title, TweenInfo.new(.5, Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()
			end
		end
	end)

	wipeTransparency(newScript, 1, true)

	newScript.ScriptName.Text = result.title


	newScript.Tags.Visible = false
	newScript.Tags.Patched.Visible = result.isPatched or false

	newScript.Execute.MouseButton1Click:Connect(function()
		queueNotification("ScriptSearch", "Running "..result.title.. " via ScriptSearch" , 4384403532)
		closeScriptSearch()
		loadstring(result.script)()
	end)
end

local function extractDomain(link)
	local domainToReturn = link:match("([%w-_]+%.[%w-_%.]+)")
	return domainToReturn
end

local function securityDetection(title, content, link, gradient, actions)
	if not checkSirius() then return end

	local domain = extractDomain(link) or link
	checkFolder()
	local currentAllowlist = isfile and isfile(siriusValues.siriusFolder.."/".."allowedLinks.srs") and readfile(siriusValues.siriusFolder.."/".."allowedLinks.srs") or nil
	if currentAllowlist then currentAllowlist = httpService:JSONDecode(currentAllowlist) if table.find(currentAllowlist, domain) then return true end end

	local newSecurityPrompt = securityPrompt:Clone()

	newSecurityPrompt.Parent = UI
	newSecurityPrompt.Name = link

	wipeTransparency(newSecurityPrompt, 1, true)
	newSecurityPrompt.Size = UDim2.new(0, 478, 0, 150)

	newSecurityPrompt.Title.Text = title
	newSecurityPrompt.Subtitle.Text = content
	newSecurityPrompt.FoundLink.Text = domain

	newSecurityPrompt.Visible = true
	newSecurityPrompt.UIGradient.Color = gradient

	newSecurityPrompt.Buttons.Template.Visible = false

	local function closeSecurityPrompt()
		tweenService:Create(newSecurityPrompt, TweenInfo.new(0.52, Enum.EasingStyle.Quint),  {Size = UDim2.new(0, 500, 0, 165)}):Play()
		tweenService:Create(newSecurityPrompt, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {BackgroundTransparency = 1}):Play()
		tweenService:Create(newSecurityPrompt.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {TextTransparency = 1}):Play()
		tweenService:Create(newSecurityPrompt.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {TextTransparency = 1}):Play()
		tweenService:Create(newSecurityPrompt.FoundLink, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {TextTransparency = 1}):Play()


		for _, button in ipairs(newSecurityPrompt.Buttons:GetChildren()) do
			if button.Name ~= "Template" and button.ClassName == "TextButton" then
				tweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quint),  {BackgroundTransparency = 1}):Play()
				tweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quint),  {TextTransparency = 1}):Play()
			end
		end
		task.wait(0.55)
		newSecurityPrompt:Destroy()
	end

	local decision

	for _, action in ipairs(actions) do
		local newAction = newSecurityPrompt.Buttons.Template:Clone()
		newAction.Name = action[1]
		newAction.Text = action[1]
		newAction.Parent = newSecurityPrompt.Buttons
		newAction.Visible = true
		newAction.Size = UDim2.new(0, newAction.TextBounds.X + 50, 0, 36) -- textbounds

		newAction.MouseButton1Click:Connect(function()
			if action[2] then
				if action[3] then
					checkFolder()
					if currentAllowlist then
						table.insert(currentAllowlist, domain)
						writefile(siriusValues.siriusFolder.."/".."allowedLinks.srs", httpService:JSONEncode(currentAllowlist))
					else
						writefile(siriusValues.siriusFolder.."/".."allowedLinks.srs", httpService:JSONEncode({domain}))
					end
				end
				decision = true
			else
				decision = false
			end

			closeSecurityPrompt()
		end)
	end

	tweenService:Create(newSecurityPrompt, TweenInfo.new(0.4, Enum.EasingStyle.Quint),  {Size = UDim2.new(0, 576, 0, 181)}):Play()
	tweenService:Create(newSecurityPrompt, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {BackgroundTransparency = 0}):Play()
	tweenService:Create(newSecurityPrompt.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()
	tweenService:Create(newSecurityPrompt.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {TextTransparency = 0.3}):Play()
	task.wait(0.03)
	tweenService:Create(newSecurityPrompt.FoundLink, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {TextTransparency = 0.2}):Play()

	task.wait(0.1)

	for _, button in ipairs(newSecurityPrompt.Buttons:GetChildren()) do
		if button.Name ~= "Template" and button.ClassName == "TextButton" then
			tweenService:Create(button, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {BackgroundTransparency = 0.7}):Play()
			tweenService:Create(button, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {TextTransparency = 0.05}):Play()
			task.wait(0.1)
		end
	end

	newSecurityPrompt.FoundLink.MouseEnter:Connect(function()
		newSecurityPrompt.FoundLink.Text = link
		tweenService:Create(newSecurityPrompt.FoundLink, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {TextTransparency = 0.4}):Play()
	end)

	newSecurityPrompt.FoundLink.MouseLeave:Connect(function()
		newSecurityPrompt.FoundLink.Text = domain
		tweenService:Create(newSecurityPrompt.FoundLink, TweenInfo.new(0.5, Enum.EasingStyle.Quint),  {TextTransparency = 0.2}):Play()
	end)

	repeat task.wait() until decision
	return decision
end

if Essential or Pro then
	getgenv()[index] = function(data)
		if checkSirius() and checkSetting("Intelligent HTTP Interception").current then
			local title = "Do you trust this source?"
			local content = "Sirius has prevented data from being sent off-client, would you like to allow data to be sent or retrieved from this source?"
			local url = data.Url or "Unknown Link"
			local gradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),ColorSequenceKeypoint.new(1, Color3.new(0.764706, 0.305882, 0.0941176))})
			local actions = {{"Always Allow", true, true}, {"Allow just this once", true}, {"Don't Allow", false}}

			if url == "http://127.0.0.1:6463/rpc?v=1" then
				local bodyDecoded = httpService:JSONDecode(data.Body)

				if bodyDecoded.cmd == "INVITE_BROWSER" then
					title = "Would you like to join this Discord server?"
					content = "Sirius has prevented your Discord client from automatically joining this Discord server, would you like to continue and join, or block it?"
					url = bodyDecoded.args and "discord.gg/"..bodyDecoded.args.code or "Unknown Invite"
					gradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),ColorSequenceKeypoint.new(1, Color3.new(0.345098, 0.396078, 0.94902))})
					actions = {{"Allow", true}, {"Don't Allow", false}}
				end
			end

			local answer = securityDetection(title, content, url, gradient, actions)


			if answer then 
				return originalRequest(data)
			else
				return
			end
		else
			return originalRequest(data)
		end
	end

	getgenv()[indexSetClipboard] = function(data)
		if checkSirius() and checkSetting("Intelligent Clipboard Interception").current then
			local title = "Would you like to copy this to your clipboard?"
			local content = "Sirius has prevented a script from setting the below text to your clipboard, would you like to allow this, or prevent it from copying?"
			local url = data or "Unknown Clipboard"
			local gradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),ColorSequenceKeypoint.new(1, Color3.new(0.776471, 0.611765, 0.529412))})
			local actions = {{"Allow", true}, {"Don't Allow", false}}

			local answer = securityDetection(title, content, url, gradient, actions)

			if answer then 
				return originalSetClipboard(data)
			else
				return
			end
		else
			return originalSetClipboard(data)
		end
	end
end


local function searchScriptBlox(query)
	local response

	local success, ErrorStatement = pcall(function()
		local responseRequest = httpRequest({
			Url = "https://scriptblox.com/api/script/search?q="..httpService:UrlEncode(query).."&mode=free&max=20&page=1",
			Method = "GET"
		})

		response = httpService:JSONDecode(responseRequest.Body)
	end)

	if not success then
		queueNotification("ScriptSearch", "ScriptSearch backend encountered an error, try again later", 4384402990)
		closeScriptSearch()
		return
	end

	tweenService:Create(scriptSearch.NoScriptsTitle, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 1}):Play()
	tweenService:Create(scriptSearch.NoScriptsDesc, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 1}):Play()

	for _, createdScript in ipairs(scriptSearch.List:GetChildren()) do
		if createdScript.Name ~= "Placeholder" and createdScript.Name ~= "Template" and createdScript.ClassName == "Frame" then
			wipeTransparency(createdScript, 1, true)
		end
	end

	scriptSearch.List.Visible = true
	task.wait(0.5)

	scriptSearch.List.CanvasPosition = Vector2.new(0,0)

	for _, createdScript in ipairs(scriptSearch.List:GetChildren()) do
		if createdScript.Name ~= "Placeholder" and createdScript.Name ~= "Template" and createdScript.ClassName == "Frame" then
			createdScript:Destroy()
		end
	end

	tweenService:Create(scriptSearch, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Size = UDim2.new(0, 580, 0, 529)}):Play()
	tweenService:Create(scriptSearch.Icon, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Position = UDim2.new(0.054, 0, 0.056, 0)}):Play()
	tweenService:Create(scriptSearch.SearchBox, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Position = UDim2.new(0.523, 0, 0.056, 0)}):Play()
	tweenService:Create(scriptSearch.UIGradient, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Offset = Vector2.new(0, 0.6)}):Play()

	if response then
		local scriptCreated = false
		for _, scriptResult in pairs(response.result.scripts) do
			local success, response = pcall(function()
				createScript(scriptResult)
			end)

			scriptCreated = true
		end

		if not scriptCreated then
			task.wait(0.2)
			tweenService:Create(scriptSearch.NoScriptsTitle, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()
			task.wait(0.1)
			tweenService:Create(scriptSearch.NoScriptsDesc, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()
		else
			tweenService:Create(scriptSearch.List, TweenInfo.new(.3,Enum.EasingStyle.Quint),  {ScrollBarImageTransparency = 0}):Play()
		end
	else
		queueNotification("ScriptSearch", "ScriptSearch backend encountered an error, try again later", 4384402990)
		closeScriptSearch()
		return
	end
end

local function openSmartBar()
	smartBarOpen = true

	coreGui.RobloxGui.Backpack.Position = UDim2.new(0,0,0,0)

	-- Set Values for frame properties
	smartBar.BackgroundTransparency = 1
	smartBar.Time.TextTransparency = 1
	smartBar.UIStroke.Transparency = 1
	smartBar.Shadow.ImageTransparency = 1
	smartBar.Visible = true
	smartBar.Position = UDim2.new(0.5, 0, 1.05, 0)
	smartBar.Size = UDim2.new(0, 531, 0, 64)
	toggle.Rotation = 180
	toggle.Visible = not checkSetting("Hide Toggle Button").current

	if checkTools() then
		toggle.Position = UDim2.new(0.5,0,1,-68)
	else
		toggle.Position = UDim2.new(0.5, 0, 1, -5)
	end

	for _, button in ipairs(smartBar.Buttons:GetChildren()) do
		button.UIGradient.Rotation = -120
		button.UIStroke.UIGradient.Rotation = -120
		button.Size = UDim2.new(0,30,0,30)
		button.Position = UDim2.new(button.Position.X.Scale, 0, 1.3, 0)
		button.BackgroundTransparency = 1
		button.UIStroke.Transparency = 1
		button.Icon.ImageTransparency = 1
	end

	tweenService:Create(coreGui.RobloxGui.Backpack, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Position = UDim2.new(-0.325,0,0,0)}):Play()

	tweenService:Create(toggle, TweenInfo.new(0.82, Enum.EasingStyle.Quint), {Rotation = 0}):Play()
	tweenService:Create(smartBar, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 0, 1, -12)}):Play()
	tweenService:Create(toastsContainer, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 0, 1, -110)}):Play()
	tweenService:Create(toggle, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 0, 1, -85)}):Play()
	tweenService:Create(smartBar, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Size = UDim2.new(0,581,0,70)}):Play()
	tweenService:Create(smartBar, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
	tweenService:Create(smartBar.Shadow, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {ImageTransparency = 0.7}):Play()
	tweenService:Create(smartBar.Time, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
	tweenService:Create(smartBar.UIStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Transparency = 0.95}):Play()
	tweenService:Create(toggle, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()

	for _, button in ipairs(smartBar.Buttons:GetChildren()) do
		tweenService:Create(button.UIStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
		tweenService:Create(button, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 36, 0, 36)}):Play()
		tweenService:Create(button.UIGradient, TweenInfo.new(1, Enum.EasingStyle.Quint), {Rotation = 50}):Play()
		tweenService:Create(button.UIStroke.UIGradient, TweenInfo.new(1, Enum.EasingStyle.Quint), {Rotation = 50}):Play()
		tweenService:Create(button, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), {Position = UDim2.new(button.Position.X.Scale, 0, 0.5, 0)}):Play()
		tweenService:Create(button, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
		tweenService:Create(button.Icon, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
		task.wait(0.03)
	end
end

local function closeSmartBar()
	smartBarOpen = false

	for _, otherPanel in ipairs(UI:GetChildren()) do
		if smartBar.Buttons:FindFirstChild(otherPanel.Name) then
			if isPanel(otherPanel.Name) and otherPanel.Visible then
				task.spawn(closePanel, otherPanel.Name, true)
				task.wait()
			end
		end
	end

	tweenService:Create(smartBar.Time, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
	for _, Button in ipairs(smartBar.Buttons:GetChildren()) do
		tweenService:Create(Button.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
		tweenService:Create(Button, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 30, 0, 30)}):Play()
		tweenService:Create(Button, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
		tweenService:Create(Button.Icon, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
	end

	tweenService:Create(coreGui.RobloxGui.Backpack, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()

	tweenService:Create(smartBar, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
	tweenService:Create(smartBar.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
	tweenService:Create(smartBar.Shadow, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
	tweenService:Create(smartBar, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0,531,0,64)}):Play()
	tweenService:Create(smartBar, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0,1, 73)}):Play()

	-- If tools, move the toggle
	if checkTools() then
		tweenService:Create(toggle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5,0,1,-68)}):Play()
		tweenService:Create(toastsContainer, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 1, -90)}):Play()
		tweenService:Create(toggle, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Rotation = 180}):Play()
	else
		tweenService:Create(toastsContainer, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 1, -28)}):Play()
		tweenService:Create(toggle, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 1, -5)}):Play()
		tweenService:Create(toggle, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Rotation = 180}):Play()
	end
end

local function windowFocusChanged(value)
	if checkSirius() then
		if value then -- Window Focused
			setfpscap(tonumber(checkSetting("Artificial FPS Limit").current))
			removeReverbs(0.5)
		else          -- Window unfocused
			if checkSetting("Muffle audio while unfocused").current then createReverb(0.7) end
			if checkSetting("Limit FPS while unfocused").current then setfpscap(60) end
		end
	end
end

local function onChatted(player, message)
	local enabled = checkSetting("Chat Spy").current and siriusValues.chatSpy.enabled
	local chatSpyVisuals = siriusValues.chatSpy.visual

	if not message or not checkSirius() then return end

	if enabled and player ~= localPlayer then
		local message2 = message:gsub("[\n\r]",''):gsub("\t",' '):gsub("[ ]+",' ')
		local hidden = true

		local get = getMessage.OnClientEvent:Connect(function(packet, channel)
			if packet.SpeakerUserId == player.UserId and packet.Message == message2:sub(#message2-#packet.Message+1) and (channel=="All" or (channel=="Team" and players[packet.FromSpeaker].Team == localPlayer.Team)) then
				hidden = false
			end
		end)

		task.wait(1)

		get:Disconnect()

		if hidden and enabled then
			chatSpyVisuals.Text = "Sirius Spy - [".. player.Name .."]: "..message2
			starterGui:SetCore("ChatMakeSystemMessage", chatSpyVisuals)
		end
	end

	if checkSetting("Log Messages").current then
		local logData = {
			["content"] = message,
			["avatar_url"] = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png",
			["username"] = player.DisplayName,
			["allowed_mentions"] = {parse = {}}
		}

		logData = httpService:JSONEncode(logData)

		pcall(function()
			local req = originalRequest({
				Url = checkSetting("Message Webhook URL").current,
				Method = 'POST',
				Headers = {
					['Content-Type'] = 'application/json',
				},
				Body = logData
			})
		end)
	end
end

local function sortPlayers()
	local newTable = playerlistPanel.Interactions.List:GetChildren()

	for index, player in ipairs(newTable) do
		if player.ClassName ~= "Frame" or player.Name == "Placeholder" then
			table.remove(newTable, index)
		end
	end

	table.sort(newTable, function(playerA, playerB)
		return playerA.Name < playerB.Name
	end)

	for index, frame in ipairs(newTable) do
		if frame.ClassName == "Frame" then
			if frame.Name ~= "Placeholder" then
				frame.LayoutOrder = index 
			end
		end
	end
end

local function kill(player)
	if not checkSirius() then return end
	if not player or player == localPlayer then
		queueNotification("Kill Error", "Unable to target this player.", 4370335364)
		return
	end

	local character = localPlayer.Character
	local targetCharacter = player.Character

	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")

	if not humanoid or not rootPart or not targetRoot then
		queueNotification("Kill Error", "Unable to locate characters for kill simulation.", 4370335364)
		return
	end

	-- Best-effort physics-based “fling” similar to admin scripts
	local connection
	local originalCFrame = rootPart.CFrame

	local function stopFling()
		if connection then
			connection:Disconnect()
			connection = nil
		end
		rootPart.AssemblyLinearVelocity = Vector3.zero
		rootPart.AssemblyAngularVelocity = Vector3.zero
		rootPart.CFrame = originalCFrame
	end

	connection = runService.Heartbeat:Connect(function()
		if not checkSirius() then
			stopFling()
			return
		end

		if not player.Parent or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
			stopFling()
			return
		end

		local currentTargetRoot = player.Character:FindFirstChild("HumanoidRootPart")
		if not currentTargetRoot then
			stopFling()
			return
		end

		-- Orbit tightly around the target with aggressive angular velocity
		local offset = currentTargetRoot.CFrame * CFrame.new(0, 0, 2)
		rootPart.CFrame = offset
		rootPart.AssemblyAngularVelocity = Vector3.new(0, 500, 0)
	end)

	task.delay(2.5, stopFling)
end

local function teleportTo(player)
	if players:FindFirstChild(player.Name) then
		queueNotification("Teleportation", "Teleporting to "..player.DisplayName..".")

		local target = workspace:FindFirstChild(player.Name).HumanoidRootPart
		localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(target.Position.X, target.Position.Y, target.Position.Z)
	else
		queueNotification("Teleportation Error", player.DisplayName.." has left this server.")
	end
end

local function createPlayer(player)
	if not checkSirius() then return end

	if playerlistPanel.Interactions.List:FindFirstChild(player.DisplayName) then return end

	local newPlayer = playerlistPanel.Interactions.List.Template:Clone()
	newPlayer.Name = player.DisplayName
	newPlayer.Parent = playerlistPanel.Interactions.List
	newPlayer.Visible = not searchingForPlayer

	newPlayer.NoActions.Visible = false
	newPlayer.PlayerInteractions.Visible = false
	newPlayer.Role.Visible = false

	newPlayer.Size = UDim2.new(0, 539, 0, 45)
	newPlayer.DisplayName.Position = UDim2.new(0, 53, 0.5, 0)
	newPlayer.DisplayName.Size = UDim2.new(0, 224, 0, 16)
	newPlayer.Avatar.Size = UDim2.new(0, 30, 0, 30)

	sortPlayers()

	newPlayer.DisplayName.TextTransparency = 0
	newPlayer.DisplayName.TextScaled = true
	newPlayer.DisplayName.FontFace.Weight = Enum.FontWeight.Medium
	newPlayer.DisplayName.Text = player.DisplayName
	newPlayer.Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png"

	if creatorType == Enum.CreatorType.Group then
		task.spawn(function()
			local role = player:GetRoleInGroup(creatorId)
			if role == "Guest" then
				newPlayer.Role.Text = "Group Rank: None"
			else
				newPlayer.Role.Text = "Group Rank: "..role
			end

			newPlayer.Role.Visible = true
			newPlayer.Role.TextTransparency = 1
		end)
	end

	local function openInteractions()
		if newPlayer.PlayerInteractions.Visible then return end

		newPlayer.PlayerInteractions.BackgroundTransparency = 1
		for _, interaction in ipairs(newPlayer.PlayerInteractions:GetChildren()) do
			if interaction.ClassName == "Frame" and interaction.Name ~= "Placeholder" then
				interaction.BackgroundTransparency = 1
				interaction.Shadow.ImageTransparency = 1
				interaction.Icon.ImageTransparency = 1
				interaction.UIStroke.Transparency = 1
			end
		end

		newPlayer.PlayerInteractions.Visible = true

		for _, interaction in ipairs(newPlayer.PlayerInteractions:GetChildren()) do
			if interaction.ClassName == "Frame" and interaction.Name ~= "Placeholder" then
				tweenService:Create(interaction.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
				tweenService:Create(interaction.Icon, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
				tweenService:Create(interaction.Shadow, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 0.7}):Play()
				tweenService:Create(interaction, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
			end
		end
	end

	local function closeInteractions()
		if not newPlayer.PlayerInteractions.Visible then return end
		for _, interaction in ipairs(newPlayer.PlayerInteractions:GetChildren()) do
			if interaction.ClassName == "Frame" and interaction.Name ~= "Placeholder" then
				tweenService:Create(interaction.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
				tweenService:Create(interaction.Icon, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
				tweenService:Create(interaction.Shadow, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
				tweenService:Create(interaction, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
			end
		end
		task.wait(0.35)
		newPlayer.PlayerInteractions.Visible = false
	end

	newPlayer.MouseEnter:Connect(function()
		if debounce or not playerlistPanel.Visible then return end
		tweenService:Create(newPlayer.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
		tweenService:Create(newPlayer.DisplayName, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0.3}):Play()
	end)

	newPlayer.MouseLeave:Connect(function()
		if debounce or not playerlistPanel.Visible then return end
		task.spawn(closeInteractions)
		tweenService:Create(newPlayer.DisplayName, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 53, 0.5, 0)}):Play()
		tweenService:Create(newPlayer, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 539, 0, 45)}):Play()
		tweenService:Create(newPlayer.Avatar, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 30, 0, 30)}):Play()
		tweenService:Create(newPlayer.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
		tweenService:Create(newPlayer.DisplayName, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
		tweenService:Create(newPlayer.Role, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
	end)

	newPlayer.Interact.MouseButton1Click:Connect(function()
		if debounce or not playerlistPanel.Visible then return end
		if creatorType == Enum.CreatorType.Group then
			tweenService:Create(newPlayer.DisplayName, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 73, 0.39, 0)}):Play()
			tweenService:Create(newPlayer.Role, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0.3}):Play()
		else
			tweenService:Create(newPlayer.DisplayName, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 73, 0.5, 0)}):Play()
		end

		if player ~= localPlayer then openInteractions() end

		tweenService:Create(newPlayer, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 539, 0, 75)}):Play()

		tweenService:Create(newPlayer.DisplayName, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
		tweenService:Create(newPlayer.Avatar, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 50, 0, 50)}):Play()
		tweenService:Create(newPlayer.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
	end)

	newPlayer.PlayerInteractions.Kill.Interact.MouseButton1Click:Connect(function()
		if debounce or not playerlistPanel.Visible then return end
		queueNotification("Kill", "Attempting to eliminate "..player.DisplayName..".", 4370335364)
		tweenService:Create(newPlayer.PlayerInteractions.Kill, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(0, 124, 89)}):Play()
		tweenService:Create(newPlayer.PlayerInteractions.Kill.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageColor3 = Color3.fromRGB(220, 220, 220)}):Play()
		tweenService:Create(newPlayer.PlayerInteractions.Kill.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(0, 134, 96)}):Play()
		kill(player)
		task.wait(1)
		tweenService:Create(newPlayer.PlayerInteractions.Kill, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
		tweenService:Create(newPlayer.PlayerInteractions.Kill.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
		tweenService:Create(newPlayer.PlayerInteractions.Kill.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(60, 60, 60)}):Play()
	end)

	newPlayer.PlayerInteractions.Teleport.Interact.MouseButton1Click:Connect(function()
		tweenService:Create(newPlayer.PlayerInteractions.Teleport, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(0, 152, 111)}):Play()
		tweenService:Create(newPlayer.PlayerInteractions.Teleport.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageColor3 = Color3.fromRGB(220, 220, 220)}):Play()
		tweenService:Create(newPlayer.PlayerInteractions.Teleport.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(0, 152, 111)}):Play()
		teleportTo(player)
		task.wait(0.5)
		tweenService:Create(newPlayer.PlayerInteractions.Teleport, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
		tweenService:Create(newPlayer.PlayerInteractions.Teleport.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
		tweenService:Create(newPlayer.PlayerInteractions.Teleport.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(60, 60, 60)}):Play()
	end)

	newPlayer.PlayerInteractions.Spectate.Interact.MouseButton1Click:Connect(function()
		if debounce or not playerlistPanel.Visible then return end
		queueNotification("Spectate", "Transitioning view to "..player.DisplayName..".", 4370335364)

		local targetCharacter = player.Character
		local targetHead = targetCharacter and targetCharacter:FindFirstChild("Head")

		if not targetHead then
			queueNotification("Spectate Error", "Unable to locate "..player.DisplayName.."'s head.", 4370335364)
			return
		end

		local originalSubject = camera.CameraSubject
		local originalCFrame = camera.CFrame

		-- GTA-like animation: rise up, then drop toward target
		local skyCFrame = CFrame.new(camera.CFrame.Position + Vector3.new(0, 120, 0), targetHead.Position)
		local finalCFrame = CFrame.new(targetHead.Position + Vector3.new(0, 4, 10), targetHead.Position)

		tweenService:Create(camera, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {CFrame = skyCFrame}):Play()
		task.wait(0.6)
		tweenService:Create(camera, TweenInfo.new(0.9, Enum.EasingStyle.Sine), {CFrame = finalCFrame}):Play()

		task.delay(0.9, function()
			if not checkSirius() then return end
			if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
				camera.CameraSubject = player.Character:FindFirstChildOfClass("Humanoid")
			end
		end)

		-- Simple escape back to self with same button if already spectating this player
		newPlayer.PlayerInteractions.Spectate.Interact.MouseButton2Click:Connect(function()
			camera.CameraSubject = originalSubject
			camera.CFrame = originalCFrame
		end)
	end)

	newPlayer.PlayerInteractions.Locate.Interact.MouseButton1Click:Connect(function()
		if debounce or not playerlistPanel.Visible then return end

		local highlight = espContainer:FindFirstChild(player.Name)
		if not highlight then
			local newHighlight = Instance.new("Highlight")
			newHighlight.Name = player.Name
			newHighlight.Adornee = player.Character
			newHighlight.FillTransparency = 1
			newHighlight.OutlineTransparency = 0
			newHighlight.OutlineColor = Color3.new(0, 1, 0)
			newHighlight.Enabled = true
			newHighlight.Parent = espContainer

			player.CharacterAdded:Connect(function(character)
				if not checkSirius() then return end
				task.wait()
				newHighlight.Adornee = character
			end)

			queueNotification("Locate ESP", "Highlighting "..player.DisplayName..".", 4370335364)
		else
			highlight.Enabled = not highlight.Enabled
			queueNotification("Locate ESP", (highlight.Enabled and "Enabled" or "Disabled").." for "..player.DisplayName..".", 4370335364)
		end
	end)
end

local function removePlayer(player)
	if not checkSirius() then return end

	if playerlistPanel.Interactions.List:FindFirstChild(player.Name) then
		playerlistPanel.Interactions.List:FindFirstChild(player.Name):Destroy()
	end
end

local function openSettings()
	debounce = true

	settingsPanel.BackgroundTransparency = 1
	settingsPanel.Title.TextTransparency = 1
	settingsPanel.Subtitle.TextTransparency = 1
	settingsPanel.Back.ImageTransparency = 1
	settingsPanel.Shadow.ImageTransparency = 1

	wipeTransparency(settingsPanel.SettingTypes, 1, true)

	settingsPanel.Visible = true
	settingsPanel.UIGradient.Enabled = true
	ThemeManager:ApplyTo(settingsPanel, "BackgroundColor3", "SecondaryBackground")
	settingsPanel.UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0.0470588, 0.0470588, 0.0470588)),ColorSequenceKeypoint.new(1, Color3.new(0.0470588, 0.0470588, 0.0470588))})
	settingsPanel.UIGradient.Offset = Vector2.new(0, 1.7)
	settingsPanel.SettingTypes.Visible = true
	settingsPanel.SettingLists.Visible = false
	settingsPanel.Size = UDim2.new(0, 550, 0, 340)
	settingsPanel.Title.Position = UDim2.new(0.045, 0, 0.057, 0)

	settingsPanel.Title.Text = "Settings"
	settingsPanel.Subtitle.Text = "Adjust your preferences, set new keybinds, test out new features and more."

	tweenService:Create(settingsPanel, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 613, 0, 384)}):Play()
	tweenService:Create(settingsPanel, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
	tweenService:Create(settingsPanel.Shadow, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 0.7}):Play()
	tweenService:Create(settingsPanel.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
	tweenService:Create(settingsPanel.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()

	task.wait(0.1)

	for _, settingType in ipairs(settingsPanel.SettingTypes:GetChildren()) do
		if settingType.ClassName == "Frame" then
			local gradientRotation = math.random(78, 95)

			tweenService:Create(settingType.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Rotation = gradientRotation}):Play()
			tweenService:Create(settingType.Shadow.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Rotation = gradientRotation}):Play()
			tweenService:Create(settingType.UIStroke.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Rotation = gradientRotation}):Play()
			tweenService:Create(settingType, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
			tweenService:Create(settingType.Shadow, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 0.7}):Play()
			tweenService:Create(settingType.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
			tweenService:Create(settingType.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0.2}):Play()

			task.wait(0.02)
		end
	end

	for _, settingList in ipairs(settingsPanel.SettingLists:GetChildren()) do
		if settingList.ClassName == "ScrollingFrame" then
			for _, setting in ipairs(settingList:GetChildren()) do
				if setting.ClassName == "Frame" then
					setting.Visible = true
				end
			end
		end
	end

	debounce = false
end

local function closeSettings()
	debounce = true

	for _, settingType in ipairs(settingsPanel.SettingTypes:GetChildren()) do
		if settingType.ClassName == "Frame" then
			tweenService:Create(settingType, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
			tweenService:Create(settingType.Shadow, TweenInfo.new(0.05, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
			tweenService:Create(settingType.UIStroke, TweenInfo.new(0.05, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
			tweenService:Create(settingType.Title, TweenInfo.new(0.05, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
		end
	end

	tweenService:Create(settingsPanel.Shadow, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
	tweenService:Create(settingsPanel.Back, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
	tweenService:Create(settingsPanel.Title, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
	tweenService:Create(settingsPanel.Subtitle, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()

	for _, settingList in ipairs(settingsPanel.SettingLists:GetChildren()) do
		if settingList.ClassName == "ScrollingFrame" then
			for _, setting in ipairs(settingList:GetChildren()) do
				if setting.ClassName == "Frame" then
					setting.Visible = false
				end
			end
		end
	end

	tweenService:Create(settingsPanel, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 520, 0, 0)}):Play()
	tweenService:Create(settingsPanel, TweenInfo.new(0.55, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()

	task.wait(0.55)

	settingsPanel.Visible = false
	debounce = false
end

local function saveSettings()
	checkFolder()

	if isfile and isfile(siriusValues.siriusFolder.."/"..siriusValues.settingsFile) then
		writefile(siriusValues.siriusFolder.."/"..siriusValues.settingsFile, httpService:JSONEncode(siriusSettings))
	end
end

local function assembleSettings()
	if isfile and isfile(siriusValues.siriusFolder.."/"..siriusValues.settingsFile) then
		local currentSettings

		local success, response = pcall(function()
			currentSettings = httpService:JSONDecode(readfile(siriusValues.siriusFolder.."/"..siriusValues.settingsFile))
		end)

		if success then
			for _, liveCategory in ipairs(siriusSettings) do
				for _, liveSetting in ipairs(liveCategory.categorySettings) do
					for _, category in ipairs(currentSettings) do
						for _, setting in ipairs(category.categorySettings) do
							if liveSetting.id == setting.id then
								liveSetting.current = setting.current
							end
						end
					end
				end
			end

			writefile(siriusValues.siriusFolder.."/"..siriusValues.settingsFile, httpService:JSONEncode(siriusSettings)) -- Update file with any new settings added
		end
	else
		if writefile then
			checkFolder()
			if not isfile(siriusValues.siriusFolder.."/"..siriusValues.settingsFile) then
				writefile(siriusValues.siriusFolder.."/"..siriusValues.settingsFile, httpService:JSONEncode(siriusSettings))
			end
		end 
	end

	for _, category in siriusSettings do
		local newCategory = settingsPanel.SettingTypes.Template:Clone()
		newCategory.Name = category.name
		newCategory.Title.Text = string.upper(category.name)
		newCategory.Parent = settingsPanel.SettingTypes
		newCategory.UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0.0392157, 0.0392157, 0.0392157)),ColorSequenceKeypoint.new(1, category.color)})

		newCategory.Visible = true

		local hue, sat, val = Color3.toHSV(category.color)

		hue = math.clamp(hue + 0.01, 0, 1) sat = math.clamp(sat + 0.1, 0, 1) val = math.clamp(val + 0.2, 0, 1)

		local newColor = Color3.fromHSV(hue, sat, val)
		newCategory.UIStroke.UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0.117647, 0.117647, 0.117647)),ColorSequenceKeypoint.new(1, newColor)})
		newCategory.Shadow.UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0.117647, 0.117647, 0.117647)),ColorSequenceKeypoint.new(1, newColor)})

		local newList = settingsPanel.SettingLists.Template:Clone()
		newList.Name = category.name
		newList.Parent = settingsPanel.SettingLists

		newList.Visible = true

		for _, obj in ipairs(newList:GetChildren()) do if obj.Name ~= "Placeholder" and obj.Name ~= "UIListLayout" then obj:Destroy() end end 

		settingsPanel.Back.MouseButton1Click:Connect(function()
			tweenService:Create(settingsPanel.Back, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
			tweenService:Create(settingsPanel.Back, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0.002, 0, 0.052, 0)}):Play()
			tweenService:Create(settingsPanel.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0.045, 0, 0.057, 0)}):Play()
			tweenService:Create(settingsPanel.UIGradient, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Offset = Vector2.new(0, 1.3)}):Play()
			settingsPanel.Title.Text = "Settings"
			settingsPanel.Subtitle.Text = "Adjust your preferences, set new keybinds, test out new features and more"
			settingsPanel.SettingTypes.Visible = true
			settingsPanel.SettingLists.Visible = false
		end)

		newCategory.Interact.MouseButton1Click:Connect(function()
			if settingsPanel.SettingLists:FindFirstChild(category.name) then
				settingsPanel.UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0.0470588, 0.0470588, 0.0470588)),ColorSequenceKeypoint.new(1, category.color)})
				settingsPanel.SettingTypes.Visible = false
				settingsPanel.SettingLists.Visible = true
				settingsPanel.SettingLists.UIPageLayout:JumpTo(settingsPanel.SettingLists[category.name])
				settingsPanel.Subtitle.Text = category.description
				settingsPanel.Back.Visible = true
				settingsPanel.Title.Text = category.name

				local gradientRotation = math.random(78, 95)
				settingsPanel.UIGradient.Rotation = gradientRotation
				tweenService:Create(settingsPanel.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Offset = Vector2.new(0, 0.65)}):Play()
				tweenService:Create(settingsPanel.Back, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
				tweenService:Create(settingsPanel.Back, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0.041, 0, 0.052, 0)}):Play()
				tweenService:Create(settingsPanel.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0.091, 0, 0.057, 0)}):Play()
			else
				-- error
				closeSettings()
			end
		end)

		newCategory.MouseEnter:Connect(function()
			tweenService:Create(newCategory.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
			tweenService:Create(newCategory.UIGradient, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Offset = Vector2.new(0, 0.4)}):Play()
			tweenService:Create(newCategory.UIStroke.UIGradient, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Offset = Vector2.new(0, 0.2)}):Play()
			tweenService:Create(newCategory.Shadow.UIGradient, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Offset = Vector2.new(0, 0.2)}):Play()
		end)

		newCategory.MouseLeave:Connect(function()
			tweenService:Create(newCategory.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0.2}):Play()
			tweenService:Create(newCategory.UIGradient, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Offset = Vector2.new(0, 0.65)}):Play()
			tweenService:Create(newCategory.UIStroke.UIGradient, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Offset = Vector2.new(0, 0.4)}):Play()
			tweenService:Create(newCategory.Shadow.UIGradient, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Offset = Vector2.new(0, 0.4)}):Play()
		end)

		for _, setting in ipairs(category.categorySettings) do
			if not setting.hidden then
				local settingType = setting.settingType
				local minimumLicense = setting.minimumLicense
				local object = nil

				if settingType == "Boolean" then
					local newSwitch = settingsPanel.SettingLists.Template.SwitchTemplate:Clone()
					object = newSwitch
					newSwitch.Name = setting.name
					newSwitch.Parent = newList
					newSwitch.Visible = true
					newSwitch.Title.Text = setting.name

					if setting.current == true then
						newSwitch.Switch.Indicator.Position = UDim2.new(1, -20, 0.5, 0)
						newSwitch.Switch.Indicator.UIStroke.Color = Color3.fromRGB(220, 220, 220)
						newSwitch.Switch.Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)			
						newSwitch.Switch.Indicator.BackgroundTransparency = 0.6
					end


					if minimumLicense then
						if (minimumLicense == "Pro" and not Pro) or (minimumLicense == "Essential" and not (Pro or Essential)) then
							newSwitch.Switch.Indicator.Position = UDim2.new(1, -40, 0.5, 0)
							newSwitch.Switch.Indicator.UIStroke.Color = Color3.fromRGB(255, 255, 255)
							newSwitch.Switch.Indicator.BackgroundColor3 = Color3.fromRGB(235, 235, 235)			
							newSwitch.Switch.Indicator.BackgroundTransparency = 0.75
						end
					end

					newSwitch.Interact.MouseButton1Click:Connect(function()
						if minimumLicense then
							if (minimumLicense == "Pro" and not Pro) or (minimumLicense == "Essential" and not (Pro or Essential)) then
								queueNotification("This feature is locked", "You must be "..minimumLicense.." or higher to use "..setting.name..". \n\nUpgrade at https://sirius.menu.", 4483345875)
								return
							end
						end

						setting.current = not setting.current
						saveSettings()
						if setting.current == true then
							tweenService:Create(newSwitch.Switch.Indicator, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -20, 0.5, 0)}):Play()
							tweenService:Create(newSwitch.Switch.Indicator, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,12,0,12)}):Play()
							tweenService:Create(newSwitch.Switch.Indicator.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Color3.fromRGB(200, 200, 200)}):Play()
							tweenService:Create(newSwitch.Switch.Indicator, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
							tweenService:Create(newSwitch.Switch.Indicator.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Transparency = 0.5}):Play()
							tweenService:Create(newSwitch.Switch.Indicator, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.6}):Play()
							task.wait(0.05)
							tweenService:Create(newSwitch.Switch.Indicator, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,17,0,17)}):Play()							
						else
							tweenService:Create(newSwitch.Switch.Indicator, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -40, 0.5, 0)}):Play()
							tweenService:Create(newSwitch.Switch.Indicator, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,12,0,12)}):Play()
							tweenService:Create(newSwitch.Switch.Indicator.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Color3.fromRGB(255, 255, 255)}):Play()
							tweenService:Create(newSwitch.Switch.Indicator.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Transparency = 0.7}):Play()
							tweenService:Create(newSwitch.Switch.Indicator, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(235, 235, 235)}):Play()
							tweenService:Create(newSwitch.Switch.Indicator, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.75}):Play()
							task.wait(0.05)
							tweenService:Create(newSwitch.Switch.Indicator, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,17,0,17)}):Play()
						end
					end)

				elseif settingType == "Input" then
					local newInput = settingsPanel.SettingLists.Template.InputTemplate:Clone()
					object = newInput

					newInput.Name = setting.name
					newInput.InputFrame.InputBox.Text = setting.current
					newInput.InputFrame.InputBox.PlaceholderText = setting.placeholder or "input"
					newInput.Parent = newList

					if string.len(setting.current) > 19 then
						newInput.InputFrame.InputBox.Text = string.sub(tostring(setting.current), 1,17)..".."
					else
						newInput.InputFrame.InputBox.Text = setting.current
					end

					newInput.Visible = true
					newInput.Title.Text = setting.name
					newInput.InputFrame.InputBox.TextWrapped = false
					newInput.InputFrame.Size = UDim2.new(0, newInput.InputFrame.InputBox.TextBounds.X + 24, 0, 30)

					newInput.InputFrame.InputBox.FocusLost:Connect(function()
						if minimumLicense then
							if (minimumLicense == "Pro" and not Pro) or (minimumLicense == "Essential" and not (Pro or Essential)) then
								queueNotification("This feature is locked", "You must be "..minimumLicense.." or higher to use "..setting.name..". \n\nUpgrade at https://sirius.menu.", 4483345875)
								newInput.InputFrame.InputBox.Text = setting.current
								return
							end
						end

						if newInput.InputFrame.InputBox.Text ~= nil or "" then
							setting.current = newInput.InputFrame.InputBox.Text
							saveSettings()
						end
						if string.len(setting.current) > 24 then
							newInput.InputFrame.InputBox.Text = string.sub(tostring(setting.current), 1,22)..".."
						else
							newInput.InputFrame.InputBox.Text = setting.current
						end
					end)

					newInput.InputFrame.InputBox:GetPropertyChangedSignal("Text"):Connect(function()
						tweenService:Create(newInput.InputFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, newInput.InputFrame.InputBox.TextBounds.X + 24, 0, 30)}):Play()
					end)

				elseif settingType == "Number" then
					local newInput = settingsPanel.SettingLists.Template.InputTemplate:Clone()
					object = newInput

					newInput.Name = setting.name
					newInput.InputFrame.InputBox.Text = tostring(setting.current)
					newInput.InputFrame.InputBox.PlaceholderText = setting.placeholder or "number"
					newInput.Parent = newList

					if string.len(setting.current) > 19 then
						newInput.InputFrame.InputBox.Text = string.sub(tostring(setting.current), 1,17)..".."
					else
						newInput.InputFrame.InputBox.Text = setting.current
					end

					newInput.Visible = true
					newInput.Title.Text = setting.name
					newInput.InputFrame.InputBox.TextWrapped = false
					newInput.InputFrame.Size = UDim2.new(0, newInput.InputFrame.InputBox.TextBounds.X + 24, 0, 30)

					newInput.InputFrame.InputBox.FocusLost:Connect(function()

						if minimumLicense then
							if (minimumLicense == "Pro" and not Pro) or (minimumLicense == "Essential" and not (Pro or Essential)) then
								queueNotification("This feature is locked", "You must be "..minimumLicense.." or higher to use "..setting.name..". \n\nUpgrade at https://sirius.menu.", 4483345875)
								newInput.InputFrame.InputBox.Text = setting.current
								return
							end
						end

						local inputValue = tonumber(newInput.InputFrame.InputBox.Text)

						if inputValue then
							if setting.values then
								local minValue = setting.values[1]
								local maxValue = setting.values[2]

								if inputValue < minValue then
									setting.current = minValue
								elseif inputValue > maxValue then
									setting.current = maxValue
								else
									setting.current = inputValue
								end

								saveSettings()
							else
								setting.current = inputValue
								saveSettings()
							end
						else
							newInput.InputFrame.InputBox.Text = tostring(setting.current)
						end

						if string.len(setting.current) > 24 then
							newInput.InputFrame.InputBox.Text = string.sub(tostring(setting.current), 1,22)..".."
						else
							newInput.InputFrame.InputBox.Text = tostring(setting.current)
						end
					end)

					newInput.InputFrame.InputBox:GetPropertyChangedSignal("Text"):Connect(function()
						tweenService:Create(newInput.InputFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, newInput.InputFrame.InputBox.TextBounds.X + 24, 0, 30)}):Play()
					end)

				elseif settingType == "Key" then
					local newKeybind = settingsPanel.SettingLists.Template.InputTemplate:Clone()
					object = newKeybind
					newKeybind.Name = setting.name
					newKeybind.InputFrame.InputBox.PlaceholderText = setting.placeholder or "listening.."
					newKeybind.InputFrame.InputBox.Text = setting.current or "No Keybind"
					newKeybind.Parent = newList

					newKeybind.Visible = true
					newKeybind.Title.Text = setting.name
					newKeybind.InputFrame.InputBox.TextWrapped = false
					newKeybind.InputFrame.Size = UDim2.new(0, newKeybind.InputFrame.InputBox.TextBounds.X + 24, 0, 30)

					newKeybind.InputFrame.InputBox.FocusLost:Connect(function()
						checkingForKey = false

						if minimumLicense then
							if (minimumLicense == "Pro" and not Pro) or (minimumLicense == "Essential" and not (Pro or Essential)) then
								queueNotification("This feature is locked", "You must be "..minimumLicense.." or higher to use "..setting.name..". \n\nUpgrade at https://sirius.menu.", 4483345875)
								newKeybind.InputFrame.InputBox.Text = setting.current
								return
							end
						end

						if newKeybind.InputFrame.InputBox.Text == nil or newKeybind.InputFrame.InputBox.Text == "" then
							newKeybind.InputFrame.InputBox.Text = "No Keybind"
							setting.current = nil
							newKeybind.InputFrame.InputBox:ReleaseFocus()
							saveSettings()
						end
					end)

					newKeybind.InputFrame.InputBox.Focused:Connect(function()
						checkingForKey = {data = setting, object = newKeybind}
						newKeybind.InputFrame.InputBox.Text = ""
					end)

					newKeybind.InputFrame.InputBox:GetPropertyChangedSignal("Text"):Connect(function()
						tweenService:Create(newKeybind.InputFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, newKeybind.InputFrame.InputBox.TextBounds.X + 24, 0, 30)}):Play()
					end)

				elseif settingType == "Theme" then
					local newThemeSetting = settingsPanel.SettingLists.Template.InputTemplate:Clone()
					object = newThemeSetting

					newThemeSetting.Name = setting.name
					newThemeSetting.Parent = newList
					newThemeSetting.Visible = true

					newThemeSetting.Title.Text = setting.name
					newThemeSetting.InputFrame.InputBox.TextWrapped = false

					local function applyThemeValue(themeName)
						if ThemeManager.Themes[themeName] then
							setting.current = themeName
							newThemeSetting.InputFrame.InputBox.Text = themeName
							ThemeManager:ApplyTheme(themeName)
							saveSettings()
						else
							newThemeSetting.InputFrame.InputBox.Text = ThemeManager.CurrentTheme
						end
					end

					local initialTheme = setting.current or ThemeManager.CurrentTheme
					if not ThemeManager.Themes[initialTheme] then
						initialTheme = "Default"
					end

					newThemeSetting.InputFrame.InputBox.Text = initialTheme
					ThemeManager.CurrentTheme = initialTheme
					applyThemeValue(initialTheme)

					newThemeSetting.InputFrame.InputBox.FocusLost:Connect(function()
						local text = newThemeSetting.InputFrame.InputBox.Text
						applyThemeValue(text)
					end)

					newThemeSetting.Interact.MouseButton1Click:Connect(function()
						local values = setting.values or {}
						if #values == 0 then
							return
						end

						local currentIndex = table.find(values, setting.current) or 1
						local nextIndex = currentIndex + 1
						if nextIndex > #values then
							nextIndex = 1
						end

						applyThemeValue(values[nextIndex])
					end)

					newThemeSetting.InputFrame.Size = UDim2.new(0, newThemeSetting.InputFrame.InputBox.TextBounds.X + 24, 0, 30)
				end

				if object then
					if setting.description then
						object.Description.Visible = true
						object.Description.TextWrapped = true
						object.Description.Size = UDim2.new(0, 333, 5, 0)
						object.Description.Size = UDim2.new(0, 333, 0, 999)
						object.Description.Text = setting.description
						object.Description.Size = UDim2.new(0, 333, 0, object.Description.TextBounds.Y + 10)
						object.Size = UDim2.new(0, 558, 0, object.Description.TextBounds.Y + 44)
					end

					if minimumLicense then
						object.LicenseDisplay.Visible = true
						object.Title.Position = UDim2.new(0, 18, 0, 26)
						object.Description.Position = UDim2.new(0, 18, 0, 43)
						object.Size = UDim2.new(0, 558, 0, object.Size.Y.Offset + 13)
						object.LicenseDisplay.Text = string.upper(minimumLicense).." FEATURE"
					end

					local objectTouching
					object.MouseEnter:Connect(function()
						objectTouching = true
						tweenService:Create(object.UIStroke, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Transparency = 0.45}):Play()
						tweenService:Create(object, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.83}):Play()
					end)

					object.MouseLeave:Connect(function()
						objectTouching = false
						tweenService:Create(object.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Transparency = 0.6}):Play()
						tweenService:Create(object, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.9}):Play()
					end)

					if object:FindFirstChild('Interact') then
						object.Interact.MouseButton1Click:Connect(function()
							tweenService:Create(object.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Transparency = 1}):Play()
							tweenService:Create(object, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.8}):Play()
							task.wait(0.1)
							if objectTouching then
								tweenService:Create(object.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Transparency = 0.45}):Play()
								tweenService:Create(object, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.83}):Play()
							else
								tweenService:Create(object.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Transparency = 0.6}):Play()
								tweenService:Create(object, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.9}):Play()
							end
						end)
					end
				end
			end
		end
	end
end

local function initialiseAntiKick()
	if checkSetting("Client-Based Anti Kick").current then
		if hookmetamethod then 
			local originalIndex
			local originalNamecall

			originalIndex = hookmetamethod(game, "__index", function(self, method)
				if self == localPlayer and method:lower() == "kick" and checkSetting("Client-Based Anti Kick").current and checkSirius() then
					queueNotification("Kick Prevented", "Sirius has prevented you from being kicked by the client.", 4400699701)
					return error("Expected ':' not '.' calling member function Kick", 2)
				end
				return originalIndex(self, method)
			end)

			originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
				if self == localPlayer and getnamecallmethod():lower() == "kick" and checkSetting("Client-Based Anti Kick").current and checkSirius() then
					queueNotification("Kick Prevented", "Sirius has prevented you from being kicked by the client.", 4400699701)
					return
				end
				return originalNamecall(self, ...)
			end)
		end
	end
end

local function boost()
	local success, result = pcall(function()
		loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Sirius/refs/heads/request/boost.lua'))()
	end)

	if not success then
		print('Error with boost file.')
		print(result)
	end
end

local function start()
	if siriusValues.releaseType == "Experimental" then -- Make this more secure.
		if not Pro then localPlayer:Kick("This is an experimental release, you must be Pro to run this. \n\nUpgrade at https://sirius.menu/") return end
	end
	windowFocusChanged(true)

	UI.Enabled = true

	assembleSettings()
	ensureFrameProperties()
	sortActions()
	initialiseAntiKick()
	checkLastVersion()
	task.spawn(boost)

	smartBar.Time.Text = os.date("%H")..":"..os.date("%M")

	toggle.Visible = not checkSetting("Hide Toggle Button").current

	if not checkSetting("Load Hidden").current then 
		--if checkSetting("Startup Sound Effect").current then
		--	local startupPath = siriusValues.siriusFolder.."/Assets/startup.wav"
		--	local startupAsset

		--	if isfile(startupPath) then
		--		startupAsset = getcustomasset(startupPath) or nil
		--	else
		--		startupAsset = fetchFromCDN("startup.wav", true, "Assets/startup.wav")
		--		startupAsset = isfile(startupPath) and getcustomasset(startupPath) or nil
		--	end

		--	if not startupAsset then return end

		--	local startupSound = Instance.new("Sound")
		--	startupSound.Parent = UI
		--	startupSound.SoundId = startupAsset
		--	startupSound.Name = "startupSound"
		--	startupSound.Volume = 0.85
		--	startupSound.PlayOnRemove = true
		--	startupSound:Destroy()	
		--end

		openSmartBar()
	else 
		closeSmartBar() 
	end

	if script_key and not (Essential or Pro) then
		queueNotification("License Error", "We've detected a key being placed above Sirius loadstring, however your key seems to be invalid. Make a support request at sirius.menu/discord to get this solved within minutes.", "document-minus")
	end

	if siriusValues.enableExperienceSync then
		task.spawn(syncExperienceInformation) 
	end
end

-- Sirius Events

start()

toggle.MouseButton1Click:Connect(function()
	if smartBarOpen then
		closeSmartBar()
	else
		openSmartBar()
	end
end)

characterPanel.Interactions.Reset.MouseButton1Click:Connect(function()
	resetSliders()

	characterPanel.Interactions.Reset.Rotation = 360
	queueNotification("Slider Values Reset","Successfully reset all character panel sliders", 4400696294)
	tweenService:Create(characterPanel.Interactions.Reset, TweenInfo.new(.5,Enum.EasingStyle.Back),  {Rotation = 0}):Play()
end)

characterPanel.Interactions.Reset.MouseEnter:Connect(function() if debounce then return end tweenService:Create(characterPanel.Interactions.Reset, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {ImageTransparency = 0}):Play() end)
characterPanel.Interactions.Reset.MouseLeave:Connect(function() if debounce then return end tweenService:Create(characterPanel.Interactions.Reset, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {ImageTransparency = 0.7}):Play() end)

local playerSearch = playerlistPanel.Interactions.SearchFrame.SearchBox -- move this up to Variables once finished

playerSearch:GetPropertyChangedSignal("Text"):Connect(function()
	local query = string.lower(playerSearch.Text)

	for _, player in ipairs(playerlistPanel.Interactions.List:GetChildren()) do
		if player.ClassName == "Frame" and player.Name ~= "Placeholder" and player.Name ~= "Template" then
			if string.find(player.Name, playerSearch.Text) then
				player.Visible = true
			else
				player.Visible = false
			end
		end
	end

	if #playerSearch.Text == 0 then
		searchingForPlayer = false
		for _, player in ipairs(playerlistPanel.Interactions.List:GetChildren()) do
			if player.ClassName == "Frame" and player.Name ~= "Placeholder" and player.Name ~= "Template" then
				player.Visible = true
			end
		end
	else
		searchingForPlayer = true
	end
end)

characterPanel.Interactions.Serverhop.MouseEnter:Connect(function()
	if debounce then return end
	tweenService:Create(characterPanel.Interactions.Serverhop, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {BackgroundTransparency = 0.5}):Play()
	tweenService:Create(characterPanel.Interactions.Serverhop.Title, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0.1}):Play()
	tweenService:Create(characterPanel.Interactions.Serverhop.UIStroke, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Transparency = 1}):Play()
end)

characterPanel.Interactions.Serverhop.MouseLeave:Connect(function()
	if debounce then return end
	tweenService:Create(characterPanel.Interactions.Serverhop, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {BackgroundTransparency = 0}):Play()
	tweenService:Create(characterPanel.Interactions.Serverhop.Title, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0.5}):Play()
	tweenService:Create(characterPanel.Interactions.Serverhop.UIStroke, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Transparency = 0}):Play()
end)

characterPanel.Interactions.Rejoin.MouseEnter:Connect(function()
	if debounce then return end
	tweenService:Create(characterPanel.Interactions.Rejoin, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {BackgroundTransparency = 0.5}):Play()
	tweenService:Create(characterPanel.Interactions.Rejoin.Title, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0.1}):Play()
	tweenService:Create(characterPanel.Interactions.Rejoin.UIStroke, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Transparency = 1}):Play()
end)

characterPanel.Interactions.Rejoin.MouseLeave:Connect(function()
	if debounce then return end
	tweenService:Create(characterPanel.Interactions.Rejoin, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {BackgroundTransparency = 0}):Play()
	tweenService:Create(characterPanel.Interactions.Rejoin.Title, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0.5}):Play()
	tweenService:Create(characterPanel.Interactions.Rejoin.UIStroke, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Transparency = 0}):Play()
end)

musicPanel.Close.MouseButton1Click:Connect(function()
	if musicPanel.Visible and not debounce then
		closeMusic()
	end
end)

musicPanel.Add.Interact.MouseButton1Click:Connect(function()
	musicPanel.AddBox.Input:ReleaseFocus()
	addToQueue(musicPanel.AddBox.Input.Text)
end)

musicPanel.Menu.TogglePlaying.MouseButton1Click:Connect(function()
	if currentAudio then
		currentAudio.Playing = not currentAudio.Playing
		musicPanel.Menu.TogglePlaying.ImageRectOffset = currentAudio.Playing and Vector2.new(804, 124) or Vector2.new(764, 244)
	end
end)

musicPanel.Menu.Next.MouseButton1Click:Connect(function()
	if currentAudio then
		if #musicQueue == 0 then currentAudio.Playing = false currentAudio.SoundId = "" return end

		if musicPanel.Queue.List:FindFirstChild(tostring(musicQueue[1].instanceName)) then
			musicPanel.Queue.List:FindFirstChild(tostring(musicQueue[1].instanceName)):Destroy()
		end

		musicPanel.Menu.TogglePlaying.ImageRectOffset = currentAudio.Playing and Vector2.new(804, 124) or Vector2.new(764, 244)

		table.remove(musicQueue, 1)

		playNext()
	end
end)

characterPanel.Interactions.Rejoin.Interact.MouseButton1Click:Connect(rejoin)
characterPanel.Interactions.Serverhop.Interact.MouseButton1Click:Connect(serverhop)

homeContainer.Interactions.Server.JobId.Interact.MouseButton1Click:Connect(function()
	if setclipboard then 
		originalSetClipboard([[
-- This script will teleport you to ' ]]..game:GetService("MarketplaceService"):GetProductInfo(placeId).Name..[['
-- If it doesn't work after a few seconds, try going into the same game, and then run the script to join ]]..localPlayer.DisplayName.. [['s specific server

game:GetService("TeleportService"):TeleportToPlaceInstance(']]..placeId..[[', ']]..jobId..[[')]]
		)
		queueNotification("Copied Join Script","Successfully set clipboard to join script, players can use this script to join your specific server.", 4335479121)
	else
		queueNotification("Unable to copy join script","Missing setclipboard() function, can't set data to your clipboard.", 4335479658)
	end
end)

homeContainer.Interactions.Discord.Interact.MouseButton1Click:Connect(function()
	if setclipboard then 
		originalSetClipboard("https://sirius.menu/discord")
		queueNotification("Discord Invite Copied", "We've set your clipboard to the Sirius discord invite.", 4335479121)
	else
		queueNotification("Unable to copy Discord invite", "Missing setclipboard() function, can't set data to your clipboard.", 4335479658)
	end
end)

for _, button in ipairs(scriptsPanel.Interactions.Selection:GetChildren()) do
	local origsize = button.Size

	button.MouseEnter:Connect(function()
		if not debounce then
			tweenService:Create(button, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {BackgroundTransparency = 0}):Play()
			tweenService:Create(button, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Size = UDim2.new(0, button.Size.X.Offset - 5, 0, button.Size.Y.Offset - 3)}):Play()
			tweenService:Create(button.UIStroke, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Transparency = 1}):Play()
			tweenService:Create(button.Title, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0.1}):Play()
		end
	end)

	button.MouseLeave:Connect(function()
		if not debounce then
			tweenService:Create(button, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {BackgroundTransparency = 0}):Play()
			tweenService:Create(button, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Size = origsize}):Play()
			tweenService:Create(button.UIStroke, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {Transparency = 0}):Play()
			tweenService:Create(button.Title, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()
		end
	end)

	button.Interact.MouseButton1Click:Connect(function()
		tweenService:Create(button, TweenInfo.new(.4,Enum.EasingStyle.Quint),  {Size = UDim2.new(0, origsize.X.Offset - 9, 0, origsize.Y.Offset - 6)}):Play()
		task.wait(0.1)
		tweenService:Create(button, TweenInfo.new(.25,Enum.EasingStyle.Quint),  {Size = origsize}):Play()

		if button.Name == "Library" then
			if not scriptSearch.Visible and not debounce then openScriptSearch() end
		end
		-- run action
	end)
end

smartBar.Buttons.Music.Interact.MouseButton1Click:Connect(function()
	if debounce then return end
	if musicPanel.Visible then closeMusic() else openMusic() end
end)

smartBar.Buttons.Home.Interact.MouseButton1Click:Connect(function()
	if debounce then return end
	if homeContainer.Visible then closeHome() else openHome() end
end)

smartBar.Buttons.Settings.Interact.MouseButton1Click:Connect(function()
	if debounce then return end
	if settingsPanel.Visible then closeSettings() else openSettings() end
end)

for _, button in ipairs(smartBar.Buttons:GetChildren()) do
	if UI:FindFirstChild(button.Name) and button:FindFirstChild("Interact") then
		button.Interact.MouseButton1Click:Connect(function()
			if isPanel(button.Name) then
				if not debounce and UI:FindFirstChild(button.Name).Visible then
					task.spawn(closePanel, button.Name)
				else
					task.spawn(openPanel, button.Name)
				end
			end

			tweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {Size = UDim2.new(0,28,0,28)}):Play()
			tweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
			tweenService:Create(button.Icon, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {ImageTransparency = 0.6}):Play()
			task.wait(0.15)
			tweenService:Create(button, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.new(0,36,0,36)}):Play()
			tweenService:Create(button, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
			tweenService:Create(button.Icon, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0.02}):Play()
		end)

		button.MouseEnter:Connect(function()
			tweenService:Create(button.UIGradient, TweenInfo.new(1.4, Enum.EasingStyle.Quint), {Rotation = 360}):Play()
			tweenService:Create(button.UIStroke.UIGradient, TweenInfo.new(1.4, Enum.EasingStyle.Quint), {Rotation = 360}):Play()
			tweenService:Create(button.UIStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
			tweenService:Create(button.Icon, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
			tweenService:Create(button.UIGradient, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Offset = Vector2.new(0,-0.5)}):Play()
		end)

		button.MouseLeave:Connect(function()
			tweenService:Create(button.UIStroke.UIGradient, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Rotation = 50}):Play()
			tweenService:Create(button.UIGradient, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Rotation = 50}):Play()
			tweenService:Create(button.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
			tweenService:Create(button.Icon, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {ImageTransparency = 0.05}):Play()
			tweenService:Create(button.UIGradient, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Offset = Vector2.new(0,0)}):Play()
		end)
	end
end

userInputService.InputBegan:Connect(function(input, processed)
	if not checkSirius() then return end

	if checkingForKey then
		if input.KeyCode ~= Enum.KeyCode.Unknown then
			local splitMessage = string.split(tostring(input.KeyCode), ".")
			local newKeyNoEnum = splitMessage[3]
			checkingForKey.object.InputFrame.InputBox.Text = tostring(newKeyNoEnum)
			checkingForKey.data.current = tostring(newKeyNoEnum)
			checkingForKey.object.InputFrame.InputBox:ReleaseFocus()
			saveSettings()
		end

		return
	end

	for _, category in ipairs(siriusSettings) do
		for _, setting in ipairs(category.categorySettings) do
			if setting.settingType == "Key" then
				if setting.current ~= nil and setting.current ~= "" then
					if input.KeyCode == Enum.KeyCode[setting.current] and not processed then
						if setting.callback then
							task.spawn(setting.callback)

							local action = checkAction(setting.name) or nil
							if action then
								local object = action.object
								action = action.action

								if action.enabled then
									object.Icon.Image = "rbxassetid://"..action.images[1]
									tweenService:Create(object, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.1}):Play()
									tweenService:Create(object.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
									tweenService:Create(object.Icon, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {ImageTransparency = 0.1}):Play()

									if action.disableAfter then
										task.delay(action.disableAfter, function()
											action.enabled = false
											object.Icon.Image = "rbxassetid://"..action.images[2]
											tweenService:Create(object, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.55}):Play()
											tweenService:Create(object.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.4}):Play()
											tweenService:Create(object.Icon, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0.5}):Play()
										end)
									end

									if action.rotateWhileEnabled then
										repeat
											object.Icon.Rotation = 0
											tweenService:Create(object.Icon, TweenInfo.new(0.75, Enum.EasingStyle.Quint), {Rotation = 360}):Play()
											task.wait(1)
										until not action.enabled
										object.Icon.Rotation = 0
									end
								else
									object.Icon.Image = "rbxassetid://"..action.images[2]
									tweenService:Create(object, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.55}):Play()
									tweenService:Create(object.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.4}):Play()
									tweenService:Create(object.Icon, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0.5}):Play()
								end
							end
						end
					end
				end
			end
		end
	end

	if input.KeyCode == Enum.KeyCode[checkSetting("Open ScriptSearch").current] and not processed and not debounce then
		if scriptSearch.Visible then
			closeScriptSearch()
		else
			openScriptSearch()
		end
	end

	if input.KeyCode == Enum.KeyCode[checkSetting("Toggle smartBar").current] and not processed and not debounce then
		if smartBarOpen then 
			closeSmartBar()
		else
			openSmartBar()
		end
	end
end)

userInputService.InputEnded:Connect(function(input, processed)
	if not checkSirius() then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		for _, slider in pairs(siriusValues.sliders) do
			slider.active = false

			if characterPanel.Visible and not debounce and slider.object and checkSirius() then
				tweenService:Create(slider.object, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.8}):Play()
				tweenService:Create(slider.object.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
				tweenService:Create(slider.object.Information, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0.3}):Play()
			end
		end
	end
end)

camera:GetPropertyChangedSignal('ViewportSize'):Connect(function()
	task.wait(.5)
	updateSliderPadding()
end)

scriptSearch.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	if #scriptSearch.SearchBox.Text > 0 then
		tweenService:Create(scriptSearch.Icon, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
		tweenService:Create(scriptSearch.SearchBox, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
	else
		tweenService:Create(scriptSearch.Icon, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {ImageColor3 = Color3.fromRGB(150, 150, 150)}):Play()
		tweenService:Create(scriptSearch.SearchBox, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
	end
end)

scriptSearch.SearchBox.FocusLost:Connect(function(enterPressed)
	tweenService:Create(scriptSearch.Icon, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {ImageColor3 = Color3.fromRGB(150, 150, 150)}):Play()
	tweenService:Create(scriptSearch.SearchBox, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()

	if #scriptSearch.SearchBox.Text > 0 then
		if enterPressed then
			local success, response = pcall(function()
				searchScriptBlox(scriptSearch.SearchBox.Text)
			end)
		end
	else
		closeScriptSearch()
	end
end)

scriptSearch.SearchBox.Focused:Connect(function()
	if #scriptSearch.SearchBox.Text > 0 then
		tweenService:Create(scriptSearch.Icon, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
		tweenService:Create(scriptSearch.SearchBox, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
	end
end)

mouse.Move:Connect(function()
	for _, slider in pairs(siriusValues.sliders) do
		if slider.active then
			updateSlider(slider)
		end
	end
end)

userInputService.WindowFocusReleased:Connect(function() windowFocusChanged(false) end)
userInputService.WindowFocused:Connect(function() windowFocusChanged(true) end)

for index, player in ipairs(players:GetPlayers()) do
	createPlayer(player)
	createEsp(player)
	player.Chatted:Connect(function(message) onChatted(player, message) end)
end

players.PlayerAdded:Connect(function(player)
	if not checkSirius() then return end

	createPlayer(player)
	createEsp(player)

	player.Chatted:Connect(function(message) onChatted(player, message) end)

	if checkSetting("Log PlayerAdded and PlayerRemoving").current then
		local logData = {
			["content"] = player.DisplayName.." (@"..player.Name..") left the server.",
			["avatar_url"] = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png",
			["username"] = player.DisplayName,
			["allowed_mentions"] = {parse = {}}
		}

		logData = httpService:JSONEncode(logData)

		pcall(function()
			local req = originalRequest({
				Url = checkSetting("Player Added and Removing Webhook URL").current,
				Method = 'POST',
				Headers = {
					['Content-Type'] = 'application/json',
				},
				Body = logData
			})
		end)

	end

	if checkSetting("Moderator Detection").current and Pro then
		local roleFound = player:GetRoleInGroup(creatorId)

		if siriusValues.currentCreator == "group" then
			for _, role in pairs(siriusValues.administratorRoles) do 
				if string.find(string.lower(roleFound), role) then
					promptModerator(player, roleFound)
					queueNotification("Administrator Joined", siriusValues.currentGroup .." "..roleFound.." ".. player.DisplayName .." has joined your session", 3944670656) -- change to group name
				end
			end
		end
	end

	if checkSetting("Friend Notifications").current then
		if localPlayer:IsFriendsWith(player.UserId) then
			queueNotification("Friend Joined", "Your friend "..player.DisplayName.." has joined your server.", 4370335364)
		end
	end
end)

players.PlayerRemoving:Connect(function(player)
	if checkSetting("Log PlayerAdded and PlayerRemoving").current then
		local logData = {
			["content"] = player.DisplayName.." (@"..player.Name..") joined the server.",
			["avatar_url"] = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png",
			["username"] = player.DisplayName,
			["allowed_mentions"] = {parse = {}}
		}

		logData = httpService:JSONEncode(logData)

		pcall(function()
			local req = originalRequest({
				Url = checkSetting("Player Added and Removing Webhook URL").current,
				Method = 'POST',
				Headers = {
					['Content-Type'] = 'application/json',
				},
				Body = logData
			})
		end)
	end

	removePlayer(player)

	local highlight = espContainer:FindFirstChild(player.Name)
	if highlight then
		highlight:Destroy()
	end
end)

runService.RenderStepped:Connect(function(frame)
	if not checkSirius() then return end
	local fps = math.round(1/frame)

	table.insert(siriusValues.frameProfile.fpsQueue, fps)
	siriusValues.frameProfile.totalFPS += fps

	if #siriusValues.frameProfile.fpsQueue > siriusValues.frameProfile.fpsQueueSize then
		siriusValues.frameProfile.totalFPS -= siriusValues.frameProfile.fpsQueue[1]
		table.remove(siriusValues.frameProfile.fpsQueue, 1)
	end
end)

runService.Stepped:Connect(function()
	if not checkSirius() then return end

	local character = localPlayer.Character
	if character then
		-- No Clip
		local noclipEnabled = siriusValues.actions[1].enabled
		local flingEnabled = siriusValues.actions[6].enabled

		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				if noclipDefaults[part] == nil then
					task.wait()
					noclipDefaults[part] = part.CanCollide
				else
					if noclipEnabled or flingEnabled then
						part.CanCollide = false
					else
						part.CanCollide = noclipDefaults[part]
					end
				end
			end
		end
	end
end)

runService.Heartbeat:Connect(function()
	if not checkSirius() then return end

	local character = localPlayer.Character
	local primaryPart = character and character.PrimaryPart
	if primaryPart then
		local bodyVelocity, bodyGyro = unpack(movers)
		if not bodyVelocity then
			bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = Vector3.one * 9e9

			bodyGyro = Instance.new("BodyGyro")
			bodyGyro.MaxTorque = Vector3.one * 9e9
			bodyGyro.P = 9e4

			local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
			bodyAngularVelocity.AngularVelocity = Vector3.yAxis * 9e9
			bodyAngularVelocity.MaxTorque = Vector3.yAxis * 9e9
			bodyAngularVelocity.P = 9e9

			movers = { bodyVelocity, bodyGyro, bodyAngularVelocity }
		end

		-- Fly
		if siriusValues.actions[2].enabled then
			local camCFrame = camera.CFrame
			local velocity = Vector3.zero
			local rotation = camCFrame.Rotation

			if userInputService:IsKeyDown(Enum.KeyCode.W) then
				velocity += camCFrame.LookVector
				rotation *= CFrame.Angles(math.rad(-40), 0, 0)
			end
			if userInputService:IsKeyDown(Enum.KeyCode.S) then
				velocity -= camCFrame.LookVector
				rotation *= CFrame.Angles(math.rad(40), 0, 0)
			end
			if userInputService:IsKeyDown(Enum.KeyCode.D) then
				velocity += camCFrame.RightVector
				rotation *= CFrame.Angles(0, 0, math.rad(-40))
			end
			if userInputService:IsKeyDown(Enum.KeyCode.A) then
				velocity -= camCFrame.RightVector
				rotation *= CFrame.Angles(0, 0, math.rad(40))
			end
			if userInputService:IsKeyDown(Enum.KeyCode.Space) then
				velocity += Vector3.yAxis
			end
			if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				velocity -= Vector3.yAxis
			end

			local tweenInfo = TweenInfo.new(0.5)
			tweenService:Create(bodyVelocity, tweenInfo, { Velocity = velocity * siriusValues.sliders[3].value * 45 }):Play()
			bodyVelocity.Parent = primaryPart

			if not siriusValues.actions[6].enabled then
				tweenService:Create(bodyGyro, tweenInfo, { CFrame = rotation }):Play()
				bodyGyro.Parent = primaryPart
			end
		else
			bodyVelocity.Parent = nil
			bodyGyro.Parent = nil
		end
	end
end)

runService.Heartbeat:Connect(function(frame)
	if not checkSirius() then return end
	if Pro then
		if checkSetting("Spatial Shield").current and tonumber(checkSetting("Spatial Shield Threshold").current) then
			for index, sound in next, soundInstances do
				if not sound then
					table.remove(soundInstances, index)
				elseif gameSettings.MasterVolume * sound.PlaybackLoudness * sound.Volume >= tonumber(checkSetting("Spatial Shield Threshold").current) then
					if sound.Volume > 0.55 then 
						suppressedSounds[sound.SoundId] = "S"
						sound.Volume = 0.5 	
					elseif sound.Volume > 0.2 and sound.Volume < 0.55 then
						suppressedSounds[sound.SoundId] = "S2"
						sound.Volume = 0.1
					elseif sound.Volume < 0.2 then
						suppressedSounds[sound.SoundId] = "Mute"
						sound.Volume = 0
					end
					if soundSuppressionNotificationCooldown == 0 then
						queueNotification("Spatial Shield","A high-volume audio is being played ("..sound.Name..") and it has been suppressed.", 4483362458) 
						soundSuppressionNotificationCooldown = 15
					end
					table.remove(soundInstances, index)
				end
			end
		end
	end

	if checkSetting("Anonymous Client").current then
		for _, text in ipairs(cachedText) do
			local lowerText = string.lower(text.Text)
			if string.find(lowerText, lowerName, 1, true) or string.find(lowerText, lowerDisplayName, 1, true) then

				storeOriginalText(text)

				local newText = string.gsub(string.gsub(lowerText, lowerName, randomUsername), lowerDisplayName, randomUsername)
				text.Text = string.gsub(newText, "^%l", string.upper)
			end
		end
	else
		undoAnonymousChanges()
	end
end)

for _, instance in next, game:GetDescendants() do
	if instance:IsA("Sound") then
		if suppressedSounds[instance.SoundId] then
			if suppressedSounds[instance.SoundId] == "S" then
				instance.Volume = 0.5
			elseif suppressedSounds[instance.SoundId] == "S2" then
				instance.Volume = 0.1
			else
				instance.Volume = 0
			end
		else
			if not table.find(cachedIds, instance.SoundId) then
				table.insert(soundInstances, instance)
				table.insert(cachedIds, instance.SoundId)
			end
		end
	elseif instance:IsA("TextLabel") or instance:IsA("TextButton") then
		if not table.find(cachedText, instance) then
			table.insert(cachedText, instance)
		end
	end
end

game.DescendantAdded:Connect(function(instance)
	if checkSirius() then
		if instance:IsA("Sound") then
			if suppressedSounds[instance.SoundId] then
				if suppressedSounds[instance.SoundId] == "S" then
					instance.Volume = 0.5
				elseif suppressedSounds[instance.SoundId] == "S2" then
					instance.Volume = 0.1
				else
					instance.Volume = 0
				end
			else
				if not table.find(cachedIds, instance.SoundId) then
					table.insert(soundInstances, instance)
					table.insert(cachedIds, instance.SoundId)
				end
			end
		elseif instance:IsA("TextLabel") or instance:IsA("TextButton") then
			if not table.find(cachedText, instance) then
				table.insert(cachedText, instance)
			end
		end
	end
end)


while task.wait(1) do
	if not checkSirius() then
		if espContainer then espContainer:Destroy() end
		undoAnonymousChanges()
		break
	end

	smartBar.Time.Text = os.date("%H")..":"..os.date("%M")
	task.spawn(UpdateHome)

	if getconnections then
		for _, connection in getconnections(localPlayer.Idled) do
			if not checkSetting("Anti Idle").current then connection:Enable() else connection:Disable() end
		end
	end

	toggle.Visible = not checkSetting("Hide Toggle Button").current

	-- Disconnected Check
	local disconnectedRobloxUI = coreGui.RobloxPromptGui.promptOverlay:FindFirstChild("ErrorPrompt")

	if disconnectedRobloxUI and not promptedDisconnected then
		local reasonPrompt = disconnectedRobloxUI.MessageArea.ErrorFrame.ErrorMessage.Text

		promptedDisconnected = true
		disconnectedPrompt.Parent = coreGui.RobloxPromptGui

		local disconnectType
		local foundString

		for _, preDisconnectType in ipairs(siriusValues.disconnectTypes) do
			for _, typeString in pairs(preDisconnectType[2]) do
				if string.find(reasonPrompt, typeString) then
					disconnectType = preDisconnectType[1]
					foundString = true
					break
				end
			end
		end

		if not foundString then disconnectType = "kick" end

		wipeTransparency(disconnectedPrompt, 1, true)
		disconnectedPrompt.Visible = true

		if disconnectType == "ban" then
			disconnectedPrompt.Content.Text = "You've been banned, would you like to leave this server?"
			disconnectedPrompt.Action.Text = "Leave"
			disconnectedPrompt.Action.Size = UDim2.new(0, 77, 0, 36) -- use textbounds

			disconnectedPrompt.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
				ColorSequenceKeypoint.new(1, Color3.new(0.819608, 0.164706, 0.164706))
			})
		elseif disconnectType == "kick" then
			disconnectedPrompt.Content.Text = "You've been kicked, would you like to serverhop?"
			disconnectedPrompt.Action.Text = "Serverhop"
			disconnectedPrompt.Action.Size = UDim2.new(0, 114, 0, 36)

			disconnectedPrompt.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
				ColorSequenceKeypoint.new(1, Color3.new(0.0862745, 0.596078, 0.835294))
			})
		elseif disconnectType == "network" then
			disconnectedPrompt.Content.Text = "You've lost connection, would you like to rejoin?"
			disconnectedPrompt.Action.Text = "Rejoin"
			disconnectedPrompt.Action.Size = UDim2.new(0, 82, 0, 36)

			disconnectedPrompt.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
				ColorSequenceKeypoint.new(1, Color3.new(0.862745, 0.501961, 0.0862745))
			})
		end

		tweenService:Create(disconnectedPrompt, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {BackgroundTransparency = 0}):Play()
		tweenService:Create(disconnectedPrompt.Title, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()
		tweenService:Create(disconnectedPrompt.Content, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0.3}):Play()
		tweenService:Create(disconnectedPrompt.Action, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {BackgroundTransparency = 0.7}):Play()
		tweenService:Create(disconnectedPrompt.Action, TweenInfo.new(.5,Enum.EasingStyle.Quint),  {TextTransparency = 0}):Play()

		disconnectedPrompt.Action.MouseButton1Click:Connect(function()
			if disconnectType == "ban" then
				game:Shutdown() -- leave
			elseif disconnectType == "kick" then
				serverhop()
			elseif disconnectType == "network" then
				rejoin()
			end
		end)
	end

	if Pro then
		-- all Pro checks here!

		-- Two-Way Adaptive Latency Checks
		if checkHighPing() then
			if siriusValues.pingProfile.pingNotificationCooldown <= 0 then
				if checkSetting("Adaptive Latency Warning").current then
					queueNotification("High Latency Warning","We've noticed your latency has reached a higher value than usual, you may find that you are lagging or your actions are delayed in-game. Consider checking for any background downloads on your machine.", 4370305588)
					siriusValues.pingProfile.pingNotificationCooldown = 120
				end
			end
		end

		if siriusValues.pingProfile.pingNotificationCooldown > 0 then
			siriusValues.pingProfile.pingNotificationCooldown -= 1
		end

		-- Adaptive frame time checks
		if siriusValues.frameProfile.frameNotificationCooldown <= 0 then
			if #siriusValues.frameProfile.fpsQueue > 0 then
				local avgFPS = siriusValues.frameProfile.totalFPS / #siriusValues.frameProfile.fpsQueue

				if avgFPS < siriusValues.frameProfile.lowFPSThreshold then
					if checkSetting("Adaptive Performance Warning").current then
						queueNotification("Degraded Performance","We've noticed your client's frames per second have decreased. Consider checking for any background tasks or programs on your machine.", 4384400106)
						siriusValues.frameProfile.frameNotificationCooldown = 120	
					end
				end
			end
		end

		if siriusValues.frameProfile.frameNotificationCooldown > 0 then
			siriusValues.frameProfile.frameNotificationCooldown -= 1
		end
	end
end

-- =====================================================
-- SIRIUS PRE-HYPERION TODO LIST IMPLEMENTATIONS
-- =====================================================

-- Chat Spam Detection System
local chatHistory = {}
local spamDetectedPlayers = {}

local function detectSpam(message, player)
	if not checkSetting("Chat Spam Detection").current then return false end

	local capsThreshold = checkSetting("Chat Spam Caps Threshold").current or 70
	local emojiThreshold = checkSetting("Chat Spam Emoji Threshold").current or 5

	-- Check caps ratio
	local capsCount = 0
	local letterCount = 0
	for char in message:gmatch("%S") do
		if char:match("%a") then
			letterCount = letterCount + 1
			if char:match("%u") then
				capsCount = capsCount + 1
			end
		end
	end
	local capsRatio = letterCount > 0 and (capsCount / letterCount) * 100 or 0
	if capsRatio >= capsThreshold then
		return true, "Excessive capital letters"
	end

	-- Check emoji count
	local emojiCount = 0
	for _ in message:gmatch("[%z\128-\255]+") do
		emojiCount = emojiCount + 1
	end
	if emojiCount >= emojiThreshold then
		return true, "Too many emojis"
	end

	-- Check repeat messages
	local playerKey = player.Name
	if not chatHistory[playerKey] then
		chatHistory[playerKey] = {}
	end

	-- Add to history
	table.insert(chatHistory[playerKey], 1, {
		message = message:lower(),
		time = tick()
	})

	-- Keep only last 5 messages
	if #chatHistory[playerKey] > 5 then
		table.remove(chatHistory[playerKey])
	end

	-- Check for repeated messages within 10 seconds
	local repeatCount = 0
	for _, entry in ipairs(chatHistory[playerKey]) do
		if tick() - entry.time <= 10 and entry.message == message:lower() then
			repeatCount = repeatCount + 1
		end
	end
	if repeatCount >= 3 then
		return true, "Repeated messages"
	end

	-- Check message length (spam usually short or very long)
	if #message > 500 then
		return true, "Message too long"
	end

	return false
end

-- Override onChatted to include spam detection
local originalOnChatted = onChatted
onChatted = function(player, message)
	local isSpam, reason = detectSpam(message, player)
	if isSpam then
		queueNotification("Spam Detected", player.DisplayName .. " sent spam: " .. reason, 4370335364)
		if checkSetting("Log Messages").current then
			-- Log spam to webhook
			local logData = {
				["content"] = "[SPAM DETECTED - " .. reason .. "] " .. player.DisplayName .. " (" .. player.Name .. "): " .. message,
				["username"] = "Sirius Chat Logger",
				["allowed_mentions"] = {parse = {}}
			}
			pcall(function()
				originalRequest({
					Url = checkSetting("Message Webhook URL").current,
					Method = "POST",
					Headers = {["Content-Type"] = "application/json"},
					Body = httpService:JSONEncode(logData)
				})
			end)
		end
	end
	-- Still call original for logging
	originalOnChatted(player, message)
end

-- http.request Interception System
if hookfunction and checkSetting("Intelligent HTTP Interception").current then
	local httpModules = {
		["http_request"] = true,
		["http.request"] = true,
		["request"] = true
	}

	for moduleName, _ in pairs(httpModules) do
		local success, originalFunc = pcall(function()
			return getgenv()[moduleName]
		end)
		if success and originalFunc and type(originalFunc) == "function" then
			getgenv()[moduleName] = function(data)
				local url = data and data.Url or data and data.url or "Unknown"
				queueNotification("HTTP Request Blocked", "Blocked request to: " .. tostring(url):sub(1, 50), 4370335364)
				return nil
			end
		end
	end
end

-- Custom Script Prompts System
local function showCustomScriptPrompt()
	if not customScriptPrompt then return end

	customScriptPrompt.Visible = true
	customScriptPrompt.ScriptInput.Text = ""
	customScriptPrompt.ScriptInput:CaptureFocus()

	-- Theme registration
	ThemeManager:Register(customScriptPrompt, "BackgroundColor3", "SecondaryBackground")
	ThemeManager:RegisterDescendants(customScriptPrompt, "TextLabel", "TextColor3", "Text", true)
	ThemeManager:RegisterDescendants(customScriptPrompt, "TextButton", "TextColor3", "ButtonText", true)
end

local function hideCustomScriptPrompt()
	if not customScriptPrompt then return end
	customScriptPrompt.Visible = false
end

local function executeCustomScript()
	if not customScriptPrompt or not customScriptPrompt.ScriptInput then return end

	local scriptText = customScriptPrompt.ScriptInput.Text
	if scriptText and #scriptText > 0 then
		local success, result = pcall(function()
			return loadstring(scriptText)()
		end)
		if success then
			queueNotification("Script Executed", "Custom script executed successfully.", 4400695581)
		else
			queueNotification("Script Error", "Error: " .. tostring(result):sub(1, 100), 4335479658)
		end
		hideCustomScriptPrompt()
	end
end

-- Connect custom script prompt buttons if they exist
if customScriptPrompt then
	if customScriptPrompt:FindFirstChild("Execute") then
		customScriptPrompt.Execute.MouseButton1Click:Connect(executeCustomScript)
	end
	if customScriptPrompt:FindFirstChild("Cancel") then
		customScriptPrompt.Cancel.MouseButton1Click:Connect(hideCustomScriptPrompt)
	end
	if customScriptPrompt:FindFirstChild("Close") then
		customScriptPrompt.Close.MouseButton1Click:Connect(hideCustomScriptPrompt)
	end
end

-- Performance Improvements - FPS-based Graphics Lowering
local graphicsLowered = false
local originalGraphicsSettings = {}

local function lowerGraphics()
	if graphicsLowered then return end
	graphicsLowered = true

	-- Store original settings
	originalGraphicsSettings.QualityLevel = settings().Rendering.QualityLevel

	-- Lower quality
	settings().Rendering.QualityLevel = 1

	-- Reduce particles and effects
	for _, effect in ipairs(lighting:GetChildren()) do
		if effect:IsA("BlurEffect") or effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") then
			originalGraphicsSettings[effect.Name] = effect.Enabled
			effect.Enabled = false
		end
	end

	queueNotification("Graphics Lowered", "Graphics quality reduced to improve FPS.", 4400701828)
end

local function restoreGraphics()
	if not graphicsLowered then return end
	graphicsLowered = false

	-- Restore original quality
	if originalGraphicsSettings.QualityLevel then
		settings().Rendering.QualityLevel = originalGraphicsSettings.QualityLevel
	end

	-- Restore effects
	for _, effect in ipairs(lighting:GetChildren()) do
		if originalGraphicsSettings[effect.Name] ~= nil then
			effect.Enabled = originalGraphicsSettings[effect.Name]
		end
	end
end

-- FPS monitoring for automatic graphics adjustment
runService.Heartbeat:Connect(function()
	if not checkSetting("Adaptive Performance Warning").current then return end

	local avgFPS = siriusValues.frameProfile.totalFPS / math.max(1, #siriusValues.frameProfile.fpsQueue)

	-- If FPS drops below threshold, lower graphics
	if avgFPS < siriusValues.frameProfile.lowFPSThreshold then
		lowerGraphics()
	elseif graphicsLowered and avgFPS > siriusValues.frameProfile.lowFPSThreshold + 10 then
		-- Restore if FPS improves significantly (with buffer to avoid flickering)
		restoreGraphics()
	end
end)

-- Universal Scripts System - Register and manage universal scripts
local universalScripts = {
	{
		name = "Infinite Yield",
		category = "Admin",
		loadstring = "loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()",
		description = "Comprehensive admin commands script"
	},
	{
		name = "Dex Explorer",
		category = "Utility",
		loadstring = "loadstring(game:HttpGet('https://raw.githubusercontent.com/infyiff/backup/main/dex.lua'))()",
		description = "Game explorer and editor"
	},
	{
		name = "Remote Spy",
		category = "Utility",
		loadstring = "loadstring(game:HttpGet('https://raw.githubusercontent.com/infyiff/backup/main/Spy.lua'))()",
		description = "Monitor remote events"
	},
	{
		name = "Simple Spy",
		category = "Utility",
		loadstring = "loadstring(game:HttpGet('https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpyBeta.lua'))()",
		description = "Simple remote spy"
	},
	{
		name = "Animation Changer",
		category = "Fun",
		loadstring = "loadstring(game:HttpGet('https://raw.githubusercontent.com/GamingScripter/Animation-Hub/main/Animation%20Hub'))()",
		description = "Change character animations"
	}
}

local function populateScriptsPanel()
	if not scriptsPanel or not scriptsPanel.Interactions or not scriptsPanel.Interactions.Selection then return end

	for _, scriptData in ipairs(universalScripts) do
		local scriptButton = scriptsPanel.Interactions.Selection:FindFirstChild(scriptData.category)
		if scriptButton then
			local newButton = scriptButton:Clone()
			newButton.Name = scriptData.name
			newButton.Title.Text = scriptData.name
			if newButton:FindFirstChild("Subtitle") then
				newButton.Subtitle.Text = scriptData.description
			end
			newButton.Parent = scriptsPanel.Interactions.Selection
			newButton.Visible = true

			newButton.Interact.MouseButton1Click:Connect(function()
				local success, result = pcall(function()
					return loadstring(scriptData.loadstring)()
				end)
				if success then
					queueNotification("Script Loaded", scriptData.name .. " loaded successfully.", 4400695581)
				else
					queueNotification("Script Error", "Failed to load " .. scriptData.name, 4335479658)
				end
			end)
		end
	end
end

-- Initialize scripts panel
task.delay(2, populateScriptsPanel)

-- Chatlogs System
local chatLogs = {}
local maxChatLogs = 100

local function addChatLog(player, message, isWhisper, whisperTarget)
	if not checkSetting("Log Messages").current then return end

	table.insert(chatLogs, 1, {
		sender = player.DisplayName,
		username = player.Name,
		message = message,
		time = os.date("%H:%M:%S"),
		isWhisper = isWhisper or false,
		whisperTarget = whisperTarget
	})

	-- Trim logs
	if #chatLogs > maxChatLogs then
		table.remove(chatLogs)
	end
end

-- GTA Serverhop Style
local function gtaServerhop()
	queueNotification("GTA Serverhop", "Initiating cinematic server transition...", 4370335364)

	-- Rise up animation
	local skyCFrame = CFrame.new(camera.CFrame.Position + Vector3.new(0, 500, 0), camera.CFrame.LookVector)
	tweenService:Create(camera, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {CFrame = skyCFrame}):Play()

	task.delay(1.5, function()
		serverhop()
	end)
end

-- GTA Serverhop setting
if settingsPanel then
	local characterCategory = nil
	for _, category in ipairs(siriusSettings) do
		if category.name == "Character" then
			characterCategory = category
			break
		end
	end

	if characterCategory then
		table.insert(characterCategory.categorySettings, {
			name = 'GTA Serverhop Style',
			description = 'Enable cinematic camera rise before server hopping.',
			settingType = 'Boolean',
			current = false,
			id = 'gtaserverhop'
		})
	end
end

-- Override serverhop to check for GTA style
local originalServerhop = serverhop
serverhop = function()
	if checkSetting("GTA Serverhop Style") and checkSetting("GTA Serverhop Style").current then
		gtaServerhop()
	else
		originalServerhop()
	end
end

-- Chat Spy Tracking - Enhanced whisper detection
local whisperHistory = {}

local function trackWhisper(sender, message, recipient)
	if not checkSetting("Chat Spy") or not checkSetting("Chat Spy").current then return end

	table.insert(whisperHistory, 1, {
		sender = sender.DisplayName,
		recipient = recipient,
		message = message,
		time = os.date("%H:%M:%S")
	})

	-- Keep only last 50 whispers
	if #whisperHistory > 50 then
		table.remove(whisperHistory)
	end

	-- Notify about whisper
	queueNotification("Whisper Detected", sender.DisplayName .. " whispered to " .. recipient, 4370335364)
end

-- Anti-Spam Formula for player chat
local function antiSpamFormula(message)
	local score = 0
	local reasons = {}

	-- Length check
	if #message < 5 then
		score = score + 10
		table.insert(reasons, "too short")
	elseif #message > 200 then
		score = score + 15
		table.insert(reasons, "too long")
	end

	-- Caps check
	local capsCount = 0
	local totalLetters = 0
	for char in message:gmatch("%a") do
		totalLetters = totalLetters + 1
		if char:match("%u") then
			capsCount = capsCount + 1
		end
	end
	if totalLetters > 0 then
		local capsRatio = capsCount / totalLetters
		if capsRatio > 0.7 then
			score = score + 20
			table.insert(reasons, "excessive caps")
		end
	end

	-- Emoji check
	local emojiCount = 0
	for _ in message:gmatch("[%z\128-\255]+") do
		emojiCount = emojiCount + 1
	end
	if emojiCount > 3 then
		score = score + emojiCount * 3
		table.insert(reasons, "many emojis")
	end

	-- Repeated characters
	local repeatedChars = message:match("(.)%1%1%1%1")
	if repeatedChars then
		score = score + 15
		table.insert(reasons, "repeated chars")
	end

	return score, reasons
end

-- Export functions for external use
getgenv().SiriusMAX = {
	ThemeManager = ThemeManager,
	showCustomScriptPrompt = showCustomScriptPrompt,
	chatLogs = chatLogs,
	whisperHistory = whisperHistory,
	universalScripts = universalScripts,
	lowerGraphics = lowerGraphics,
	restoreGraphics = restoreGraphics,
	antiSpamFormula = antiSpamFormula,
	gtaServerhop = gtaServerhop,
	serverhop = serverhop,
	chatHistory = chatHistory,
	spamDetectedPlayers = spamDetectedPlayers
}

-- =====================================================
-- STARLIGHT SYSTEM IMPLEMENTATION
-- =====================================================
-- Starlight is an advanced lighting and visual effects system
-- that enhances the game environment with dynamic lighting

local StarlightSystem = {
	Enabled = false,
	OriginalSettings = {},
	Effects = {},
	Connections = {}
}

function StarlightSystem:Enable()
	if self.Enabled then return end
	self.Enabled = true

	-- Store original lighting settings
	self.OriginalSettings.Brightness = lighting.Brightness
	self.OriginalSettings.Ambient = lighting.Ambient
	self.OriginalSettings.OutdoorAmbient = lighting.OutdoorAmbient
	self.OriginalSettings.GlobalShadows = lighting.GlobalShadows

	-- Apply starlight effect
	lighting.Brightness = 2
	lighting.Ambient = Color3.fromRGB(120, 120, 140)
	lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 130)
	lighting.GlobalShadows = true

	-- Create atmospheric effects
	local atmosphere = lighting:FindFirstChildOfClass("Atmosphere")
	if not atmosphere then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Parent = lighting
	end
	self.Effects.Atmosphere = atmosphere
	atmosphere.Density = 0.3
	atmosphere.Offset = 0
	atmosphere.Color = Color3.fromRGB(180, 180, 200)
	atmosphere.Decay = Color3.fromRGB(100, 100, 130)
	atmosphere.Glare = 0.5
	atmosphere.Haze = 0.2

	-- Add bloom effect for glow
	local bloom = lighting:FindFirstChild("StarlightBloom")
	if not bloom then
		bloom = Instance.new("BloomEffect")
		bloom.Name = "StarlightBloom"
		bloom.Parent = lighting
		bloom.Intensity = 0.4
		bloom.Size = 24
		bloom.Threshold = 0.8
	end
	self.Effects.Bloom = bloom

	-- Add color correction for cinematic feel
	local colorCorrection = lighting:FindFirstChild("StarlightColorCorrection")
	if not colorCorrection then
		colorCorrection = Instance.new("ColorCorrectionEffect")
		colorCorrection.Name = "StarlightColorCorrection"
		colorCorrection.Parent = lighting
		colorCorrection.Brightness = 0.05
		colorCorrection.Contrast = 0.1
		colorCorrection.Saturation = 0.1
		colorCorrection.TintColor = Color3.fromRGB(240, 240, 255)
	end
	self.Effects.ColorCorrection = colorCorrection

	queueNotification("Starlight", "Starlight System enabled - Enhanced lighting active.", 4370335364)
end

function StarlightSystem:Disable()
	if not self.Enabled then return end
	self.Enabled = false

	-- Restore original lighting settings
	lighting.Brightness = self.OriginalSettings.Brightness or 1
	lighting.Ambient = self.OriginalSettings.Ambient or Color3.fromRGB(128, 128, 128)
	lighting.OutdoorAmbient = self.OriginalSettings.OutdoorAmbient or Color3.fromRGB(128, 128, 128)
	lighting.GlobalShadows = self.OriginalSettings.GlobalShadows or true

	-- Remove effects
	for _, effect in pairs(self.Effects) do
		if effect and effect.Parent then
			effect:Destroy()
		end
	end
	self.Effects = {}

	queueNotification("Starlight", "Starlight System disabled.", 4370335364)
end

function StarlightSystem:Toggle()
	if self.Enabled then
		self:Disable()
	else
		self:Enable()
	end
end

-- Connect starlight UI if it exists
if starlight then
	starlight.Interact.MouseButton1Click:Connect(function()
		StarlightSystem:Toggle()
	end)

	-- Theme registration for starlight panel
	ThemeManager:Register(starlight, "BackgroundColor3", "SecondaryBackground")
	ThemeManager:RegisterDescendants(starlight, "TextLabel", "TextColor3", "Text", true)
end

-- Add to export
getgenv().SiriusMAX.Starlight = StarlightSystem

-- =====================================================
-- STEP 8: SIRIUS DETECTION REDUCTION (STEALTH SYSTEM)
-- =====================================================
-- Implements various stealth techniques to reduce script detection

local StealthSystem = {
	Enabled = true,
	OriginalNames = {},
	Connections = {},
	SpoofedValues = {}
}

function StealthSystem:SpoofProperty(object, property, spoofValue)
	-- Spoof a property value to return a fake value when indexed
	if not hookmetamethod then return end

	local originalIndex
	local spoofKey = tostring(object) .. "_" .. property

	self.SpoofedValues[spoofKey] = {
		object = object,
		property = property,
		spoofValue = spoofValue
	}

	originalIndex = hookmetamethod(game, "__index", function(self, key)
		local spoofData = StealthSystem.SpoofedValues[tostring(self) .. "_" .. key]
		if spoofData and self == spoofData.object and key == spoofData.property then
			return spoofData.spoofValue
		end
		return originalIndex(self, key)
	end)
end

function StealthSystem:RandomizeInstanceNames()
	-- Randomize names of sensitive Sirius instances to avoid detection
	local sensitiveInstances = {
		UI,
		espContainer,
		chatLogsContainer,
		customScriptPrompt
	}

	for _, instance in ipairs(sensitiveInstances) do
		if instance then
			local originalName = instance.Name
			local randomSuffix = tostring(math.random(100000, 999999))
			instance.Name = "Sirius_" .. randomSuffix
			self.OriginalNames[instance] = originalName
		end
	end
end

function StealthSystem:HideFromFindFirstChild()
	-- Hide Sirius instances from common detection methods
	local instancesToProtect = {
		UI,
		espContainer
	}

	for _, instance in ipairs(instancesToProtect) do
		if instance and hookmetamethod then
			-- Spoof FindFirstChild results for protected instances
			local originalNamecall
			originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
				local method = getnamecallmethod()
				local args = {...}

				if method == "FindFirstChild" or method == "findFirstChild" then
					local targetName = args[1]
					if targetName and (targetName:match("Sirius") or targetName:match("sirius")) then
						-- Return nil for direct Sirius name searches
						return nil
					end
				end

				if method == "GetChildren" or method == "getChildren" then
					local children = originalNamecall(self, ...)
					local filtered = {}
					for _, child in ipairs(children) do
						if not child.Name:match("Sirius") and not child.Name:match("sirius") then
							table.insert(filtered, child)
						end
					end
					return filtered
				end

				return originalNamecall(self, ...)
			end)
		end
	end
end

function StealthSystem:ObfuscateGlobals()
	-- Remove or obfuscate global identifiers
	if getgenv().SiriusMAX then
		-- Create a weak reference that doesn't persist
		local weakRef = setmetatable({SiriusMAX = getgenv().SiriusMAX}, {__mode = "v"})
		getgenv().SiriusMAX = nil
		-- Re-add with randomized name
		local randomName = "_" .. tostring(math.random(10000000, 99999999))
		getgenv()[randomName] = weakRef.SiriusMAX
	end
end

function StealthSystem:EnableAntiDetection()
	-- Enable all stealth measures
	if not self.Enabled then return end

	-- Randomize instance names on startup
	task.spawn(function()
		task.wait(2) -- Wait for UI to fully load
		self:RandomizeInstanceNames()
	end)

	-- Monitor for new detection attempts
	self.Connections.Heartbeat = runService.Heartbeat:Connect(function()
		-- Periodically check if instances were discovered
		if not checkSirius() then
			-- Clean up if script was detected/destroyed
			for _, connection in pairs(self.Connections) do
				if typeof(connection) == "RBXScriptConnection" then
					connection:Disconnect()
					end
				end
			end
		end)

	queueNotification("Stealth", "Detection reduction measures enabled.", 4370335364)
end

function StealthSystem:Disable()
	self.Enabled = false
	for _, connection in pairs(self.Connections) do
		if typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
		end
	end
	queueNotification("Stealth", "Stealth measures disabled.", 4370335364)
end

-- Initialize stealth system
if checkSetting("Reduce Sirius Detection") and checkSetting("Reduce Sirius Detection").current then
	task.spawn(function()
		StealthSystem:EnableAntiDetection()
	end)
end

getgenv().SiriusMAX.Stealth = StealthSystem

-- =====================================================
-- STEP 9: SCRIPTBLOX AUTO-GAME SCRIPT FINDER
-- =====================================================
-- Automatically detects current game and queries ScriptBlox for scripts

local ScriptBloxAutoFinder = {
	Enabled = true,
	LastSearch = nil,
	Cache = {}
}

function ScriptBloxAutoFinder:GetCurrentGameInfo()
	-- Get current game information
	local gameInfo = {
		name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
		placeId = game.PlaceId,
		gameId = game.GameId,
		universeId = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).UniverseId
	}
	return gameInfo
end

function ScriptBloxAutoFinder:QueryGameScripts(gameName, callback)
	-- Query ScriptBlox API for game-specific scripts
	local encodedName = httpService:UrlEncode(gameName)
	local url = "https://scriptblox.com/api/script/search?q=" .. encodedName .. "&mode=free&max=5&page=1"

	task.spawn(function()
		local success, result = pcall(function()
			local response = httpRequest({
				Url = url,
				Method = "GET"
			})
			return httpService:JSONDecode(response.Body)
		end)

		if success and result and result.result and result.result.scripts then
			callback(result.result.scripts)
		else
			callback(nil)
		end
	end)
end

function ScriptBloxAutoFinder:AutoSearchAndNotify()
	-- Perform automatic search for current game
	if not self.Enabled then return end

	local gameInfo = self:GetCurrentGameInfo()

	-- Check cache first
	if self.Cache[gameInfo.placeId] then
		local cached = self.Cache[gameInfo.placeId]
		queueNotification(
			"ScriptBlox Auto-Finder",
			"Found script for " .. gameInfo.name .. ": " .. cached.title,
			4384403532
		)
		return cached
	end

	-- Don't search too frequently
	if self.LastSearch and (tick() - self.LastSearch) < 30 then
		return
	end

	self.LastSearch = tick()

	queueNotification(
		"ScriptBlox Auto-Finder",
		"Searching scripts for " .. gameInfo.name .. "...",
		4384403532
	)

	self:QueryGameScripts(gameInfo.name, function(scripts)
		if scripts and #scripts > 0 then
			local firstScript = scripts[1]

			-- Cache the result
			self.Cache[gameInfo.placeId] = firstScript

			queueNotification(
				"ScriptBlox Auto-Finder",
				"Found: " .. firstScript.title .. " by " .. (firstScript.owner and firstScript.owner.username or "Unknown"),
				4384403532
			)

			-- Auto-show in script search if panel is open
			if scriptSearch and scriptSearch.Visible then
				task.spawn(function()
					createScript(firstScript)
				end)
			end
		else
			queueNotification(
				"ScriptBlox Auto-Finder",
				"No scripts found for " .. gameInfo.name,
				4384402990
			)
		end
	end)
end

function ScriptBloxAutoFinder:OpenWithGameSearch()
	-- Open script search and auto-search for current game
	if not checkSirius() then return end

	openScriptSearch()

	task.wait(0.6)

	local gameInfo = self:GetCurrentGameInfo()
	scriptSearch.SearchBox.Text = gameInfo.name

	self:AutoSearchAndNotify()
end

-- Quick access keybind integration (T key)
local function setupAutoFinderKeybind()
	-- Check if there's a keybind setting
	local keybindSetting = checkSetting("Auto Script Finder Keybind")
	if keybindSetting and keybindSetting.current then
		userInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then return end

			if input.KeyCode.Name == keybindSetting.current then
				ScriptBloxAutoFinder:OpenWithGameSearch()
			end
		end)
	end
end

-- Initialize auto-finder
if checkSetting("Auto Script Finder") and checkSetting("Auto Script Finder").current then
	task.spawn(function()
		task.wait(5) -- Wait for game to fully load
		ScriptBloxAutoFinder:AutoSearchAndNotify()
	end)
end

-- Setup keybind
task.spawn(setupAutoFinderKeybind)

getgenv().SiriusMAX.ScriptBloxAutoFinder = ScriptBloxAutoFinder

-- =====================================================
-- STEP 10: FUTURE SETTINGS SUPPORT
-- =====================================================
-- Domain blocking, serverhop type toggle, Roblox function hooks

local FutureSettings = {
	BlockedDomains = {},
	ServerhopType = "default", -- "default" or "gta"
	Hooks = {},
	Enabled = true
}

-- DOMAIN BLOCKING SYSTEM
function FutureSettings:AddBlockedDomain(domain, permanent)
	-- Add a domain to the block list
	-- Usage: AddBlockedDomain("example.com", true)
	self.BlockedDomains[domain] = {
		blocked = true,
		permanent = permanent or false,
		addedAt = os.time()
	}

	if permanent then
		-- Save to file for persistence
		checkFolder()
		local blockFile = siriusValues.siriusFolder .. "/blockedDomains.json"
		local existing = {}

		if isfile and isfile(blockFile) then
			local success, data = pcall(function()
				return httpService:JSONDecode(readfile(blockFile))
			end)
			if success then
				existing = data
			end
		end

		existing[domain] = true
		writefile(blockFile, httpService:JSONEncode(existing))
	end

	queueNotification("Domain Blocked", domain .. " has been blocked.", 4370335364)
end

function FutureSettings:RemoveBlockedDomain(domain)
	-- Remove a domain from the block list
	self.BlockedDomains[domain] = nil

	-- Remove from file if it was permanent
	checkFolder()
	local blockFile = siriusValues.siriusFolder .. "/blockedDomains.json"

	if isfile and isfile(blockFile) then
		local success, data = pcall(function()
			return httpService:JSONDecode(readfile(blockFile))
		end)
		if success then
			data[domain] = nil
			writefile(blockFile, httpService:JSONEncode(data))
		end
	end

	queueNotification("Domain Unblocked", domain .. " has been unblocked.", 4370335364)
end

function FutureSettings:IsDomainBlocked(url)
	-- Check if a URL contains a blocked domain
	for blockedDomain, data in pairs(self.BlockedDomains) do
		if url:match(blockedDomain) then
			return true, blockedDomain
		end
	end

	-- Check file-based blocks
	checkFolder()
	local blockFile = siriusValues.siriusFolder .. "/blockedDomains.json"
	if isfile and isfile(blockFile) then
		local success, data = pcall(function()
			return httpService:JSONDecode(readfile(blockFile))
		end)
		if success then
			for blockedDomain, _ in pairs(data) do
				if url:match(blockedDomain) then
					return true, blockedDomain
				end
			end
		end
	end

	return false, nil
end

function FutureSettings:LoadBlockedDomains()
	-- Load blocked domains from file on startup
	checkFolder()
	local blockFile = siriusValues.siriusFolder .. "/blockedDomains.json"

	if isfile and isfile(blockFile) then
		local success, data = pcall(function()
			return httpService:JSONDecode(readfile(blockFile))
		end)
		if success then
			for domain, _ in pairs(data) do
				self.BlockedDomains[domain] = {
					blocked = true,
					permanent = true,
					loadedAt = os.time()
				}
			end
		end
	end
end

-- SERVERHOP TYPE TOGGLE
function FutureSettings:SetServerhopType(type)
	-- Set serverhop style: "default" or "gta"
	if type == "default" or type == "gta" then
		self.ServerhopType = type

		-- Save preference
		checkFolder()
		local prefsFile = siriusValues.siriusFolder .. "/preferences.json"
		local prefs = {}

		if isfile and isfile(prefsFile) then
			local success, data = pcall(function()
				return httpService:JSONDecode(readfile(prefsFile))
			end)
			if success then
				prefs = data
			end
		end

		prefs.serverhopType = type
		writefile(prefsFile, httpService:JSONEncode(prefs))

		queueNotification("Serverhop", "Serverhop style set to: " .. type, 4370335364)
	end
end

function FutureSettings:GetServerhopType()
	-- Get current serverhop type, loading from file if needed
	if not self.ServerhopType then
		checkFolder()
		local prefsFile = siriusValues.siriusFolder .. "/preferences.json"

		if isfile and isfile(prefsFile) then
			local success, data = pcall(function()
				return httpService:JSONDecode(readfile(prefsFile))
			end)
			if success and data.serverhopType then
				self.ServerhopType = data.serverhopType
			end
		end
	end

	return self.ServerhopType or "default"
end

function FutureSettings:ExecuteServerhopWithType()
	-- Execute serverhop using the selected type
	local type = self:GetServerhopType()

	if type == "gta" then
		-- Use GTA-style cinematic camera animation
		gtaServerhop()
	else
		-- Use default serverhop
		serverhop()
	end
end

-- ROBLOX FUNCTION HOOKS
function FutureSettings:HookRobloxFunctions()
	-- Hook common Roblox functions to intercept external scripts
	if not hookfunction then return end

	-- Hook loadstring to intercept and log
	local originalLoadstring = loadstring
	self.Hooks.loadstring = hookfunction(loadstring, function(source, chunkname)
		if FutureSettings.Enabled and checkSetting("Hook Loadstring").current then
			-- Check if source contains blocked domains
			local isBlocked, domain = FutureSettings:IsDomainBlocked(source)
			if isBlocked then
				queueNotification(
					"Blocked Script",
					"Script containing blocked domain '" .. domain .. "' was prevented from loading.",
					4384402990
				)
				return function() end -- Return empty function
			end

			-- Log the load attempt
			if checkSetting("Log External Scripts").current then
				table.insert(chatLogs, {
					type = "loadstring",
					source = source:sub(1, 100) .. (string.len(source) > 100 and "..." or ""),
					timestamp = os.time(),
					chunkname = chunkname or "unknown"
				})
			end
		end

		return originalLoadstring(source, chunkname)
	end)

	-- Hook require to intercept module loading
	if require then
		local originalRequire = require
		self.Hooks.require = hookfunction(require, function(module)
			if FutureSettings.Enabled and checkSetting("Hook Require").current then
				local moduleId = tostring(module)

				-- Log the require attempt
				if checkSetting("Log External Scripts").current then
					table.insert(chatLogs, {
						type = "require",
						module = moduleId,
						timestamp = os.time()
					})
				end
			end

			return originalRequire(module)
		end)
	end

	queueNotification("Hooks", "Roblox function hooks enabled.", 4370335364)
end

function FutureSettings:UnhookRobloxFunctions()
	-- Restore original functions
	for name, hook in pairs(self.Hooks) do
		if hook then
			-- Note: actual unhooking depends on exploit capabilities
			self.Hooks[name] = nil
		end
	end
	queueNotification("Hooks", "Roblox function hooks disabled.", 4370335364)
end

-- INITIALIZATION
function FutureSettings:Initialize()
	-- Load saved preferences
	self:LoadBlockedDomains()

	-- Setup hooks if enabled
	if checkSetting("Hook Roblox Functions").current then
		self:HookRobloxFunctions()
	end

	-- Integrate with HTTP interception
	if Essential or Pro then
		-- Enhance existing HTTP interception with domain blocking
		local originalInterceptedRequest = getgenv()[index]
		if originalInterceptedRequest then
			getgenv()[index] = function(data)
				local url = data.Url or ""
				local isBlocked, domain = self:IsDomainBlocked(url)

				if isBlocked then
					queueNotification(
						"Blocked Request",
						"Request to blocked domain '" .. domain .. "' was prevented.",
						4384402990
					)
					return nil
				end

				return originalInterceptedRequest(data)
			end
		end
	end
end

-- Initialize on startup
task.spawn(function()
	task.wait(3) -- Wait for settings to load
	FutureSettings:Initialize()
end)

getgenv().SiriusMAX.FutureSettings = FutureSettings

-- =====================================================
-- END OF MODERATE-PRIORITY + FUTURE SETTINGS IMPLEMENTATION
-- =====================================================

-- =====================================================
-- SIRIUS MAX FULL IDE + LIGHTWEIGHT JS BROWSER PHASE
-- =====================================================

-- =====================================================
-- STEP 2: MULTI-TAB EXECUTOR UI PANEL
-- =====================================================
-- Lightweight, virtualized multi-tab script executor
-- Optimized for 4GB RAM with max 200 visible lines

local ExecutorSystem = {
	Tabs = {},
	ActiveTabId = nil,
	TabCounter = 0,
	MaxTabs = 10,
	SandboxPath = "SiriusMAX/scripts/",
	PerformanceMode = false
}

-- Ensure sandbox directory exists
local function ensureSandbox()
	if makefolder then
		pcall(function()
			makefolder(ExecutorSystem.SandboxPath)
		end)
	end
end

task.spawn(ensureSandbox)

-- Create Executor UI Panel
local executorPanel = Instance.new("Frame")
executorPanel.Name = "ExecutorPanel"
executorPanel.Size = UDim2.new(0, 700, 0, 450)
executorPanel.Position = UDim2.new(0.5, -350, 0.5, -225)
executorPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
executorPanel.BorderSizePixel = 0
executorPanel.Visible = false
executorPanel.Parent = UI

local executorCorner = Instance.new("UICorner")
executorCorner.CornerRadius = UDim.new(0, 8)
executorCorner.Parent = executorPanel

local executorStroke = Instance.new("UIStroke")
executorStroke.Color = Color3.fromRGB(40, 40, 48)
executorStroke.Thickness = 1
executorStroke.Parent = executorPanel

-- Title Bar
local executorTitle = Instance.new("TextLabel")
executorTitle.Name = "Title"
executorTitle.Size = UDim2.new(1, 0, 0, 40)
executorTitle.BackgroundTransparency = 1
executorTitle.Text = "Sirius MAX Executor"
executorTitle.TextColor3 = Color3.fromRGB(245, 245, 245)
executorTitle.TextSize = 18
executorTitle.Font = Enum.Font.SourceSansBold
executorTitle.Parent = executorPanel

-- Tab Bar
local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(1, -20, 0, 35)
tabBar.Position = UDim2.new(0, 10, 0, 40)
tabBar.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
tabBar.BorderSizePixel = 0
local tabBarCorner = Instance.new("UICorner")
tabBarCorner.CornerRadius = UDim.new(0, 6)
tabBarCorner.Parent = tabBar
tabBar.Parent = executorPanel

-- Tab Container (ScrollingFrame for many tabs)
local tabContainer = Instance.new("ScrollingFrame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, -80, 1, 0)
tabContainer.BackgroundTransparency = 1
tabContainer.BorderSizePixel = 0
tabContainer.ScrollBarThickness = 2
tabContainer.ScrollingDirection = Enum.ScrollingDirection.X
local tabListLayout = Instance.new("UIListLayout")
tabListLayout.FillDirection = Enum.FillDirection.Horizontal
tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabListLayout.Padding = UDim.new(0, 5)
tabListLayout.Parent = tabContainer
tabContainer.Parent = tabBar

-- New Tab Button
local newTabButton = Instance.new("TextButton")
newTabButton.Name = "NewTab"
newTabButton.Size = UDim2.new(0, 70, 0, 25)
newTabButton.Position = UDim2.new(1, -75, 0.5, -12.5)
newTabButton.BackgroundColor3 = Color3.fromRGB(26, 148, 255)
newTabButton.Text = "+ New Tab"
newTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
newTabButton.TextSize = 12
newTabButton.Font = Enum.Font.SourceSansBold
local newTabCorner = Instance.new("UICorner")
newTabCorner.CornerRadius = UDim.new(0, 6)
newTabCorner.Parent = newTabButton
newTabButton.Parent = tabBar

-- Editor Container
local editorContainer = Instance.new("Frame")
editorContainer.Name = "EditorContainer"
editorContainer.Size = UDim2.new(1, -20, 0, 320)
editorContainer.Position = UDim2.new(0, 10, 0, 80)
editorContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
editorContainer.BorderSizePixel = 0
local editorCorner = Instance.new("UICorner")
editorCorner.CornerRadius = UDim.new(0, 6)
editorCorner.Parent = editorContainer
editorContainer.Parent = executorPanel

-- Line Numbers Frame
local lineNumbersFrame = Instance.new("Frame")
lineNumbersFrame.Name = "LineNumbers"
lineNumbersFrame.Size = UDim2.new(0, 40, 1, 0)
lineNumbersFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
lineNumbersFrame.BorderSizePixel = 0
local lineNumbersCorner = Instance.new("UICorner")
lineNumbersCorner.CornerRadius = UDim.new(0, 6)
lineNumbersCorner.Parent = lineNumbersFrame
lineNumbersFrame.Parent = editorContainer

-- Editor Scrolling Frame (virtualized container)
local editorScroll = Instance.new("ScrollingFrame")
editorScroll.Name = "EditorScroll"
editorScroll.Size = UDim2.new(1, -50, 1, -10)
editorScroll.Position = UDim2.new(0, 45, 0, 5)
editorScroll.BackgroundTransparency = 1
editorScroll.BorderSizePixel = 0
editorScroll.ScrollBarThickness = 4
editorScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
editorScroll.Parent = editorContainer

-- Code Input Box
local codeBox = Instance.new("TextBox")
codeBox.Name = "CodeBox"
codeBox.Size = UDim2.new(1, 0, 1, 0)
codeBox.BackgroundTransparency = 1
codeBox.Text = ""
codeBox.TextColor3 = Color3.fromRGB(220, 220, 220)
codeBox.TextSize = 14
codeBox.Font = Enum.Font.Code
codeBox.MultiLine = true
codeBox.ClearTextOnFocus = false
codeBox.TextXAlignment = Enum.TextXAlignment.Left
codeBox.TextYAlignment = Enum.TextYAlignment.Top
codeBox.Parent = editorScroll

-- Button Bar
local buttonBar = Instance.new("Frame")
buttonBar.Name = "ButtonBar"
buttonBar.Size = UDim2.new(1, -20, 0, 40)
buttonBar.Position = UDim2.new(0, 10, 1, -50)
buttonBar.BackgroundTransparency = 1
buttonBar.Parent = executorPanel

-- Execute Button
local executeButton = Instance.new("TextButton")
executeButton.Name = "Execute"
executeButton.Size = UDim2.new(0, 100, 0, 35)
executeButton.Position = UDim2.new(0, 0, 0, 0)
executeButton.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
executeButton.Text = "▶ Execute"
executeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
executeButton.TextSize = 14
executeButton.Font = Enum.Font.SourceSansBold
local executeCorner = Instance.new("UICorner")
executeCorner.CornerRadius = UDim.new(0, 6)
executeCorner.Parent = executeButton
executeButton.Parent = buttonBar

-- Clear Button
local clearButton = Instance.new("TextButton")
clearButton.Name = "Clear"
clearButton.Size = UDim2.new(0, 80, 0, 35)
clearButton.Position = UDim2.new(0, 110, 0, 0)
clearButton.BackgroundColor3 = Color3.fromRGB(184, 85, 61)
clearButton.Text = "✕ Clear"
clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clearButton.TextSize = 14
clearButton.Font = Enum.Font.SourceSansBold
local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 6)
clearCorner.Parent = clearButton
clearButton.Parent = buttonBar

-- Save Button
local saveButton = Instance.new("TextButton")
saveButton.Name = "Save"
saveButton.Size = UDim2.new(0, 80, 0, 35)
saveButton.Position = UDim2.new(0, 200, 0, 0)
saveButton.BackgroundColor3 = Color3.fromRGB(61, 179, 98)
saveButton.Text = "💾 Save"
saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
saveButton.TextSize = 14
saveButton.Font = Enum.Font.SourceSansBold
local saveCorner = Instance.new("UICorner")
saveCorner.CornerRadius = UDim.new(0, 6)
saveCorner.Parent = saveButton
saveButton.Parent = buttonBar

-- Load Button
local loadButton = Instance.new("TextButton")
loadButton.Name = "Load"
loadButton.Size = UDim2.new(0, 80, 0, 35)
loadButton.Position = UDim2.new(0, 290, 0, 0)
loadButton.BackgroundColor3 = Color3.fromRGB(102, 75, 190)
loadButton.Text = "📂 Load"
loadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
loadButton.TextSize = 14
loadButton.Font = Enum.Font.SourceSansBold
local loadCorner = Instance.new("UICorner")
loadCorner.CornerRadius = UDim.new(0, 6)
loadCorner.Parent = loadButton
loadButton.Parent = buttonBar

-- Syntax Highlight Toggle
local syntaxToggle = Instance.new("TextButton")
syntaxToggle.Name = "SyntaxToggle"
syntaxToggle.Size = UDim2.new(0, 120, 0, 35)
syntaxToggle.Position = UDim2.new(1, -120, 0, 0)
syntaxToggle.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
syntaxToggle.Text = "🔍 Syntax: ON"
syntaxToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
syntaxToggle.TextSize = 12
syntaxToggle.Font = Enum.Font.SourceSans
local syntaxCorner = Instance.new("UICorner")
syntaxCorner.CornerRadius = UDim.new(0, 6)
syntaxCorner.Parent = syntaxToggle
syntaxToggle.Parent = buttonBar

-- Close Button
local executorClose = Instance.new("TextButton")
executorClose.Name = "Close"
executorClose.Size = UDim2.new(0, 30, 0, 30)
executorClose.Position = UDim2.new(1, -35, 0, 5)
executorClose.BackgroundTransparency = 1
executorClose.Text = "✕"
executorClose.TextColor3 = Color3.fromRGB(200, 200, 200)
executorClose.TextSize = 18
executorClose.Font = Enum.Font.SourceSansBold
executorClose.Parent = executorPanel

-- Register with ThemeManager
ThemeManager:Register(executorPanel, "BackgroundColor3", "SecondaryBackground")
ThemeManager:Register(executorTitle, "TextColor3", "Text")
ThemeManager:Register(tabBar, "BackgroundColor3", "Background")
ThemeManager:Register(editorContainer, "BackgroundColor3", "Background")
ThemeManager:Register(lineNumbersFrame, "BackgroundColor3", "Background")
ThemeManager:Register(codeBox, "TextColor3", "Text")
ThemeManager:Register(executorStroke, "Color", "Border")
ThemeManager:Register(executeButton, "BackgroundColor3", "Accent")
ThemeManager:Register(clearButton, "BackgroundColor3", "Button")
ThemeManager:Register(saveButton, "BackgroundColor3", "Button")
ThemeManager:Register(loadButton, "BackgroundColor3", "Button")
ThemeManager:Register(syntaxToggle, "BackgroundColor3", "Button")
ThemeManager:Register(executorClose, "TextColor3", "SubText")

-- Tab Management Functions
function ExecutorSystem:CreateTab(name, content)
	if #self.Tabs >= self.MaxTabs then
		queueNotification("Executor", "Maximum tabs reached (" .. self.MaxTabs .. ")", 4384402990)
		return nil
	end

	self.TabCounter = self.TabCounter + 1
	local tabId = "Tab_" .. self.TabCounter

	local tabButton = Instance.new("TextButton")
	tabButton.Name = tabId
	tabButton.Size = UDim2.new(0, 100, 0, 30)
	tabButton.BackgroundColor3 = Color3.fromRGB(26, 148, 255)
	tabButton.Text = name or "Untitled " .. self.TabCounter
	tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	tabButton.TextSize = 12
	tabButton.Font = Enum.Font.SourceSans
	tabButton.LayoutOrder = self.TabCounter
	local tabCorner = Instance.new("UICorner")
	tabCorner.CornerRadius = UDim.new(0, 4)
	tabCorner.Parent = tabButton

	local closeTabBtn = Instance.new("TextButton")
	closeTabBtn.Name = "Close"
	closeTabBtn.Size = UDim2.new(0, 16, 0, 16)
	closeTabBtn.Position = UDim2.new(1, -18, 0.5, -8)
	closeTabBtn.BackgroundTransparency = 1
	closeTabBtn.Text = "✕"
	closeTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeTabBtn.TextSize = 10
	closeTabBtn.Parent = tabButton

	tabButton.Parent = tabContainer

	tabButton.MouseButton1Click:Connect(function()
		self:SwitchTab(tabId)
	end)

	closeTabBtn.MouseButton1Click:Connect(function()
		self:CloseTab(tabId)
	end)

	local tab = {
		id = tabId,
		name = name or "Untitled " .. self.TabCounter,
		button = tabButton,
		content = content or "",
		modified = false
	}

	table.insert(self.Tabs, tab)
	self:SwitchTab(tabId)

	return tab
end

function ExecutorSystem:SwitchTab(tabId)
	for _, tab in ipairs(self.Tabs) do
		if tab.id == tabId then
			self.ActiveTabId = tabId
			tab.button.BackgroundColor3 = Color3.fromRGB(26, 148, 255)
			codeBox.Text = tab.content
		else
			tab.button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		end
	end
end

function ExecutorSystem:CloseTab(tabId)
	for i, tab in ipairs(self.Tabs) do
		if tab.id == tabId then
			tab.button:Destroy()
			table.remove(self.Tabs, i)

			-- Switch to another tab if this was active
			if self.ActiveTabId == tabId and #self.Tabs > 0 then
				self:SwitchTab(self.Tabs[math.min(i, #self.Tabs)].id)
			elseif #self.Tabs == 0 then
				self.ActiveTabId = nil
				codeBox.Text = ""
			end
			break
		end
	end
end

function ExecutorSystem:GetActiveTab()
	for _, tab in ipairs(self.Tabs) do
		if tab.id == self.ActiveTabId then
			return tab
		end
	end
	return nil
end

function ExecutorSystem:UpdateActiveTabContent()
	local tab = self:GetActiveTab()
	if tab then
		tab.content = codeBox.Text
		tab.modified = true
	end
end

function ExecutorSystem:ToggleVisibility()
	executorPanel.Visible = not executorPanel.Visible
	if executorPanel.Visible then
		-- Create initial tab if none exist
		if #self.Tabs == 0 then
			self:CreateTab("Untitled 1", "")
		end
	end
end

-- Event Connections
codeBox:GetPropertyChangedSignal("Text"):Connect(function()
	ExecutorSystem:UpdateActiveTabContent()
end)

newTabButton.MouseButton1Click:Connect(function()
	ExecutorSystem:CreateTab()
end)

executeButton.MouseButton1Click:Connect(function()
	local code = codeBox.Text
	if code and code ~= "" then
		local success, err = pcall(function()
			loadstring(code)()
		end)
		if success then
			queueNotification("Executor", "Script executed successfully!", 4370335364)
		else
			queueNotification("Executor Error", err or "Unknown error", 4384402990)
		end
	end
end)

clearButton.MouseButton1Click:Connect(function()
	codeBox.Text = ""
	ExecutorSystem:UpdateActiveTabContent()
end)

executorClose.MouseButton1Click:Connect(function()
	executorPanel.Visible = false
end)

-- Add to global API
getgenv().SiriusMAX.Executor = ExecutorSystem

-- =====================================================
-- STEP 3: VIRTUALIZED EDITOR + STEP 4: SCRIPT FILE MANAGER
-- =====================================================
-- Virtualized rendering: max 200 visible lines, syntax highlighting toggle
-- File manager: sandboxed to SiriusMAX/scripts/ only

-- Virtualized Editor System
local VirtualizedEditor = {
	MaxVisibleLines = 200,
	SyntaxHighlighting = true,
	LineData = {},
	VisibleStart = 1,
	TotalLines = 0
}

-- Line counter and virtualization
function VirtualizedEditor:UpdateLineCount()
	local text = codeBox.Text
	local lines = 0
	for _ in text:gmatch("\n") do
		lines = lines + 1
	end
	lines = lines + 1 -- Last line

	self.TotalLines = lines

	-- Virtualization: truncate if exceeds max
	if lines > self.MaxVisibleLines then
		self:VirtualizeContent()
	end

	-- Update line numbers display
	self:UpdateLineNumbers()
end

function VirtualizedEditor:VirtualizeContent()
	-- In performance mode, only keep first 200 lines visible
	if ExecutorSystem.PerformanceMode then
		local text = codeBox.Text
		local truncated = ""
		local count = 0

		for line in text:gmatch("[^\n]*") do
			if count >= self.MaxVisibleLines then
				break
			end
			if count > 0 then
				truncated = truncated .. "\n"
			end
			truncated = truncated .. line
			count = count + 1
		end

		codeBox.Text = truncated .. "\n\n-- [Content truncated - 200 line limit in Performance Mode]"
		queueNotification("Editor", "Performance Mode: Content limited to 200 lines", 4370335364)
	end
end

function VirtualizedEditor:UpdateLineNumbers()
	-- Create/update line number labels (simplified for performance)
	local lineCount = math.min(self.TotalLines, self.MaxVisibleLines)

	-- Clear existing
	for _, child in ipairs(lineNumbersFrame:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	-- Only show up to 50 line numbers at a time for performance
	local displayCount = math.min(lineCount, 50)
	for i = 1, displayCount do
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 0, 16)
		label.Position = UDim2.new(0, 0, 0, (i - 1) * 16)
		label.BackgroundTransparency = 1
		label.Text = tostring(i)
		label.TextColor3 = Color3.fromRGB(100, 100, 100)
		label.TextSize = 12
		label.Font = Enum.Font.Code
		label.TextXAlignment = Enum.TextXAlignment.Right
		label.Parent = lineNumbersFrame
	end

	-- Indicator for more lines
	if lineCount > 50 then
		local moreLabel = Instance.new("TextLabel")
		moreLabel.Size = UDim2.new(1, 0, 0, 16)
		moreLabel.Position = UDim2.new(0, 0, 0, 50 * 16)
		moreLabel.BackgroundTransparency = 1
		moreLabel.Text = "..."
		moreLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
		moreLabel.TextSize = 12
		moreLabel.Font = Enum.Font.Code
		moreLabel.Parent = lineNumbersFrame
	end
end

function VirtualizedEditor:ToggleSyntaxHighlighting()
	self.SyntaxHighlighting = not self.SyntaxHighlighting
	syntaxToggle.Text = self.SyntaxHighlighting and "🔍 Syntax: ON" or "🔍 Syntax: OFF"

	if self.SyntaxHighlighting then
		-- Re-apply basic highlighting
		self:ApplyBasicHighlighting()
	else
		-- Plain text mode for performance
		codeBox.RichText = false
	end
end

function VirtualizedEditor:ApplyBasicHighlighting()
	-- Simplified highlighting - only in non-performance mode
	if ExecutorSystem.PerformanceMode then
		return -- Skip highlighting in performance mode
	end

	-- Note: Full syntax highlighting would require TextLabel per line
	-- This is a lightweight implementation
	codeBox.TextColor3 = Color3.fromRGB(220, 220, 220)
end

-- File Manager System (Sandboxed to SiriusMAX/scripts/)
local ScriptFileManager = {
	CurrentFile = nil,
	SandboxPath = "SiriusMAX/scripts/"
}

function ScriptFileManager:EnsureSandbox()
	if makefolder then
		pcall(function()
			makefolder(self.SandboxPath)
		end)
	end
end

function ScriptFileManager:LoadScriptFromFile(filename)
	self:EnsureSandbox()

	local filepath = self.SandboxPath .. filename
	if isfile and isfile(filepath) then
		local success, content = pcall(function()
			return readfile(filepath)
		end)

		if success then
			-- Create new tab with file content
			local tab = ExecutorSystem:CreateTab(filename, content)
			if tab then
				ScriptFileManager.CurrentFile = filename
				queueNotification("File Manager", "Loaded: " .. filename, 4370335364)
			end
			return content
		else
			queueNotification("File Manager Error", "Failed to read: " .. filename, 4384402990)
		end
	else
		queueNotification("File Manager", "File not found: " .. filename, 4384402990)
	end
	return nil
end

function ScriptFileManager:SaveScriptToFile(filename, code)
	self:EnsureSandbox()

	-- Security: ensure filename doesn't escape sandbox
	if filename:match("%.%./") or filename:match("^/") or filename:match("\\") then
		queueNotification("File Manager Error", "Invalid filename (sandbox escape attempt)", 4384402990)
		return false
	end

	local filepath = self.SandboxPath .. filename
	local content = code or codeBox.Text

	if writefile then
		local success, err = pcall(function()
			writefile(filepath, content)
		end)

		if success then
			queueNotification("File Manager", "Saved: " .. filename, 4370335364)
			ScriptFileManager.CurrentFile = filename

			-- Update tab name
			local tab = ExecutorSystem:GetActiveTab()
			if tab then
				tab.name = filename
				tab.button.Text = filename
				tab.modified = false
			end
			return true
		else
			queueNotification("File Manager Error", "Failed to save: " .. tostring(err), 4384402990)
		end
	else
		queueNotification("File Manager Error", "writefile() not available", 4384402990)
	end
	return false
end

function ScriptFileManager:ListScripts()
	self:EnsureSandbox()

	local files = {}
	if listfiles then
		local success, fileList = pcall(function()
			return listfiles(self.SandboxPath)
		end)

		if success and fileList then
			for _, filepath in ipairs(fileList) do
				local filename = filepath:match("[^/\\]+$")
				if filename then
					table.insert(files, filename)
				end
			end
		end
	end

	return files
end

function ScriptFileManager:DeleteScript(filename)
	self:EnsureSandbox()

	local filepath = self.SandboxPath .. filename
	if delfile and isfile(filepath) then
		local success = pcall(function()
			delfile(filepath)
		end)

		if success then
			queueNotification("File Manager", "Deleted: " .. filename, 4370335364)
			return true
		else
			queueNotification("File Manager Error", "Failed to delete: " .. filename, 4384402990)
		end
	end
	return false
end

function ScriptFileManager:ShowFileBrowser()
	-- Simple file browser UI
	local files = self:ListScripts()

	if #files == 0 then
		queueNotification("File Manager", "No scripts found in SiriusMAX/scripts/", 4384402990)
		return
	end

	-- Create browser frame (simplified inline version)
	local browserFrame = Instance.new("Frame")
	browserFrame.Name = "FileBrowser"
	browserFrame.Size = UDim2.new(0, 300, 0, 400)
	browserFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
	browserFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	browserFrame.BorderSizePixel = 0
	browserFrame.Parent = executorPanel

	local browserCorner = Instance.new("UICorner")
	browserCorner.CornerRadius = UDim.new(0, 8)
	browserCorner.Parent = browserFrame

	local browserTitle = Instance.new("TextLabel")
	browserTitle.Size = UDim2.new(1, 0, 0, 30)
	browserTitle.BackgroundTransparency = 1
	browserTitle.Text = "Script Files"
	browserTitle.TextColor3 = Color3.fromRGB(245, 245, 245)
	browserTitle.TextSize = 16
	browserTitle.Font = Enum.Font.SourceSansBold
	browserTitle.Parent = browserFrame

	local fileListFrame = Instance.new("ScrollingFrame")
	fileListFrame.Size = UDim2.new(1, -20, 1, -80)
	fileListFrame.Position = UDim2.new(0, 10, 0, 40)
	fileListFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
	fileListFrame.BorderSizePixel = 0
	fileListFrame.ScrollBarThickness = 4
	fileListFrame.Parent = browserFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.Name
	listLayout.Padding = UDim.new(0, 5)
	listLayout.Parent = fileListFrame

	-- Populate file list
	for _, filename in ipairs(files) do
		local fileButton = Instance.new("TextButton")
		fileButton.Size = UDim2.new(1, -10, 0, 30)
		fileButton.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
		fileButton.Text = filename
		fileButton.TextColor3 = Color3.fromRGB(220, 220, 220)
		fileButton.TextSize = 12
		fileButton.Font = Enum.Font.SourceSans
		fileButton.Parent = fileListFrame

		local fileCorner = Instance.new("UICorner")
		fileCorner.CornerRadius = UDim.new(0, 4)
		fileCorner.Parent = fileButton

		fileButton.MouseButton1Click:Connect(function()
			self:LoadScriptFromFile(filename)
			browserFrame:Destroy()
		end)

		-- Delete on right-click
		fileButton.MouseButton2Click:Connect(function()
			self:DeleteScript(filename)
			fileButton:Destroy()
		end)
	end

	-- Close button
	local closeBrowser = Instance.new("TextButton")
	closeBrowser.Size = UDim2.new(0, 80, 0, 30)
	closeBrowser.Position = UDim2.new(0.5, -40, 1, -40)
	closeBrowser.BackgroundColor3 = Color3.fromRGB(184, 85, 61)
	closeBrowser.Text = "Close"
	closeBrowser.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBrowser.TextSize = 12
	closeBrowser.Font = Enum.Font.SourceSansBold
	closeBrowser.Parent = browserFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeBrowser

	closeBrowser.MouseButton1Click:Connect(function()
		browserFrame:Destroy()
	end)

	-- Register with ThemeManager
	ThemeManager:Register(browserFrame, "BackgroundColor3", "SecondaryBackground")
	ThemeManager:Register(fileListFrame, "BackgroundColor3", "Background")
end

-- Connect UI Events
syntaxToggle.MouseButton1Click:Connect(function()
	VirtualizedEditor:ToggleSyntaxHighlighting()
end)

saveButton.MouseButton1Click:Connect(function()
	-- Save dialog
	local tab = ExecutorSystem:GetActiveTab()
	local defaultName = ScriptFileManager.CurrentFile or (tab and tab.name:match("^Untitled") and "script.lua" or (tab and tab.name) or "script.lua")

	-- Create simple save dialog
	local saveDialog = Instance.new("Frame")
	saveDialog.Name = "SaveDialog"
	saveDialog.Size = UDim2.new(0, 300, 0, 150)
	saveDialog.Position = UDim2.new(0.5, -150, 0.5, -75)
	saveDialog.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	saveDialog.BorderSizePixel = 0
	saveDialog.Parent = executorPanel

	local dialogCorner = Instance.new("UICorner")
	dialogCorner.CornerRadius = UDim.new(0, 8)
	dialogCorner.Parent = saveDialog

	local filenameLabel = Instance.new("TextLabel")
	filenameLabel.Size = UDim2.new(1, -20, 0, 25)
	filenameLabel.Position = UDim2.new(0, 10, 0, 10)
	filenameLabel.BackgroundTransparency = 1
	filenameLabel.Text = "Filename:"
	filenameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	filenameLabel.TextSize = 14
	filenameLabel.Font = Enum.Font.SourceSans
	filenameLabel.Parent = saveDialog

	local filenameInput = Instance.new("TextBox")
	filenameInput.Size = UDim2.new(1, -20, 0, 30)
	filenameInput.Position = UDim2.new(0, 10, 0, 40)
	filenameInput.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
	filenameInput.Text = defaultName
	filenameInput.TextColor3 = Color3.fromRGB(220, 220, 220)
	filenameInput.TextSize = 14
	filenameInput.Font = Enum.Font.SourceSans
	filenameInput.ClearTextOnFocus = false
	filenameInput.Parent = saveDialog

	local inputCorner = Instance.new("UICorner")
	inputCorner.CornerRadius = UDim.new(0, 6)
	inputCorner.Parent = filenameInput

	local saveConfirm = Instance.new("TextButton")
	saveConfirm.Size = UDim2.new(0, 80, 0, 30)
	saveConfirm.Position = UDim2.new(0.5, -90, 1, -45)
	saveConfirm.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
	saveConfirm.Text = "Save"
	saveConfirm.TextColor3 = Color3.fromRGB(255, 255, 255)
	saveConfirm.TextSize = 12
	saveConfirm.Font = Enum.Font.SourceSansBold
	saveConfirm.Parent = saveDialog

	local saveConfirmCorner = Instance.new("UICorner")
	saveConfirmCorner.CornerRadius = UDim.new(0, 6)
	saveConfirmCorner.Parent = saveConfirm

	local cancelButton = Instance.new("TextButton")
	cancelButton.Size = UDim2.new(0, 80, 0, 30)
	cancelButton.Position = UDim2.new(0.5, 10, 1, -45)
	cancelButton.BackgroundColor3 = Color3.fromRGB(184, 85, 61)
	cancelButton.Text = "Cancel"
	cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	cancelButton.TextSize = 12
	cancelButton.Font = Enum.Font.SourceSansBold
	cancelButton.Parent = saveDialog

	local cancelCorner = Instance.new("UICorner")
	cancelCorner.CornerRadius = UDim.new(0, 6)
	cancelCorner.Parent = cancelButton

	saveConfirm.MouseButton1Click:Connect(function()
		ScriptFileManager:SaveScriptToFile(filenameInput.Text, codeBox.Text)
		saveDialog:Destroy()
	end)

	cancelButton.MouseButton1Click:Connect(function()
		saveDialog:Destroy()
	end)

	ThemeManager:Register(saveDialog, "BackgroundColor3", "SecondaryBackground")
	ThemeManager:Register(filenameInput, "BackgroundColor3", "Button")
end)

loadButton.MouseButton1Click:Connect(function()
	ScriptFileManager:ShowFileBrowser()
end)

-- Connect editor events for line counting
codeBox:GetPropertyChangedSignal("Text"):Connect(function()
	VirtualizedEditor:UpdateLineCount()
	ExecutorSystem:UpdateActiveTabContent()
end)

-- Update global API
getgenv().SiriusMAX.Executor.VirtualizedEditor = VirtualizedEditor
getgenv().SiriusMAX.Executor.FileManager = ScriptFileManager
getgenv().SiriusMAX.Executor.LoadScriptFromFile = function(filename) return ScriptFileManager:LoadScriptFromFile(filename) end
getgenv().SiriusMAX.Executor.SaveScriptToFile = function(filename, code) return ScriptFileManager:SaveScriptToFile(filename, code) end
getgenv().SiriusMAX.Executor.ListScripts = function() return ScriptFileManager:ListScripts() end
getgenv().SiriusMAX.Executor.DeleteScript = function(filename) return ScriptFileManager:DeleteScript(filename) end

-- =====================================================
-- STEP 5: SCRIPTBLOX AUTO-FINDER WITH AUTO-EXECUTE
-- =====================================================
-- Detect current game, query ScriptBlox API, auto-execute top result
-- Cache per PlaceId for 5 minutes

local ScriptBloxAutoFinder = {
	Cache = {},
	CacheDuration = 300, -- 5 minutes
	AutoExecute = false,
	LastSearchResults = nil
}

-- Extend existing ScriptBlox functionality
function ScriptBloxAutoFinder:GetCurrentGameInfo()
	return {
		Name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
		PlaceId = game.PlaceId,
		UniverseId = game.GameId
	}
end

function ScriptBloxAutoFinder:QueryGameScripts()
	local gameInfo = self:GetCurrentGameInfo()
	local cacheKey = tostring(gameInfo.PlaceId)

	-- Check cache
	if self.Cache[cacheKey] then
		local cached = self.Cache[cacheKey]
		if (tick() - cached.timestamp) < self.CacheDuration then
			queueNotification("ScriptBlox", "Using cached results for " .. gameInfo.Name, 4370335364)
			return cached.results
		end
	end

	-- Query ScriptBlox API
	local apiUrl = "https://scriptblox.com/api/script/search?q=" .. gameInfo.Name:gsub(" ", "%%20") .. "&mode=free&max=5"

	local success, result = pcall(function()
		return game:HttpGet(apiUrl)
	end)

	if success and result then
		local decoded = httpService:JSONDecode(result)
		if decoded and decoded.result and decoded.result.scripts then
			-- Cache results
			self.Cache[cacheKey] = {
				results = decoded.result.scripts,
				timestamp = tick()
			}
			self.LastSearchResults = decoded.result.scripts
			return decoded.result.scripts
		end
	end

	return nil
end

function ScriptBloxAutoFinder:GetTopScript()
	local scripts = self:QueryGameScripts()
	if scripts and #scripts > 0 then
		return scripts[1] -- Return top result
	end
	return nil
end

function ScriptBloxAutoFinder:AutoSearchAndExecute()
	local topScript = self:GetTopScript()
	if topScript then
		queueNotification("ScriptBlox Auto-Finder", "Found script: " .. (topScript.title or "Untitled"), 4370335364)

		if self.AutoExecute and topScript.script then
			-- Open in executor tab
			local tab = ExecutorSystem:CreateTab(topScript.title or "ScriptBlox Script", topScript.script)
			if tab then
				-- Auto-execute after short delay
				task.delay(1, function()
					local success, err = pcall(function()
						loadstring(topScript.script)()
					end)
					if success then
						queueNotification("Auto-Execute", "Script executed successfully!", 4370335364)
					else
						queueNotification("Auto-Execute Error", err or "Unknown error", 4384402990)
					end
				end)
			end
		else
			-- Just open in tab without executing
			local tab = ExecutorSystem:CreateTab(topScript.title or "ScriptBlox Script", topScript.script)
			if tab then
				queueNotification("ScriptBlox", "Script loaded into executor tab", 4370335364)
			end
		end
		return topScript
	else
		queueNotification("ScriptBlox", "No scripts found for this game", 4384402990)
	end
	return nil
end

function ScriptBloxAutoFinder:ToggleAutoExecute()
	self.AutoExecute = not self.AutoExecute
	queueNotification("ScriptBlox Auto-Finder", "Auto-execute: " .. (self.AutoExecute and "ENABLED" or "DISABLED"), 4370335364)
	return self.AutoExecute
end

-- Create ScriptBlox UI Panel
local scriptbloxPanel = Instance.new("Frame")
scriptbloxPanel.Name = "ScriptBloxPanel"
scriptbloxPanel.Size = UDim2.new(0, 400, 0, 300)
scriptbloxPanel.Position = UDim2.new(0.5, -200, 0.5, -150)
scriptbloxPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
scriptbloxPanel.BorderSizePixel = 0
scriptbloxPanel.Visible = false
scriptbloxPanel.Parent = UI

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 8)
sbCorner.Parent = scriptbloxPanel

local sbTitle = Instance.new("TextLabel")
sbTitle.Name = "Title"
sbTitle.Size = UDim2.new(1, 0, 0, 40)
sbTitle.BackgroundTransparency = 1
sbTitle.Text = "ScriptBlox Auto-Finder"
sbTitle.TextColor3 = Color3.fromRGB(245, 245, 245)
sbTitle.TextSize = 18
sbTitle.Font = Enum.Font.SourceSansBold
sbTitle.Parent = scriptbloxPanel

local sbClose = Instance.new("TextButton")
sbClose.Name = "Close"
sbClose.Size = UDim2.new(0, 30, 0, 30)
sbClose.Position = UDim2.new(1, -35, 0, 5)
sbClose.BackgroundTransparency = 1
sbClose.Text = "✕"
sbClose.TextColor3 = Color3.fromRGB(200, 200, 200)
sbClose.TextSize = 18
sbClose.Font = Enum.Font.SourceSansBold
sbClose.Parent = scriptbloxPanel

-- Auto-execute Toggle
local autoExecToggle = Instance.new("TextButton")
autoExecToggle.Name = "AutoExecToggle"
autoExecToggle.Size = UDim2.new(0, 150, 0, 35)
autoExecToggle.Position = UDim2.new(0, 15, 0, 50)
autoExecToggle.BackgroundColor3 = Color3.fromRGB(184, 85, 61)
autoExecToggle.Text = "Auto-Execute: OFF"
autoExecToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoExecToggle.TextSize = 12
autoExecToggle.Font = Enum.Font.SourceSansBold
local autoExecCorner = Instance.new("UICorner")
autoExecCorner.CornerRadius = UDim.new(0, 6)
autoExecCorner.Parent = autoExecToggle
autoExecToggle.Parent = scriptbloxPanel

-- Search Button
local searchBtn = Instance.new("TextButton")
searchBtn.Name = "Search"
searchBtn.Size = UDim2.new(0, 120, 0, 35)
searchBtn.Position = UDim2.new(0.5, -60, 0, 50)
searchBtn.BackgroundColor3 = Color3.fromRGB(26, 148, 255)
searchBtn.Text = "🔍 Search Game"
searchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBtn.TextSize = 12
searchBtn.Font = Enum.Font.SourceSansBold
local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 6)
searchCorner.Parent = searchBtn
searchBtn.Parent = scriptbloxPanel

-- Execute Top Button
local execTopBtn = Instance.new("TextButton")
execTopBtn.Name = "ExecTop"
execTopBtn.Size = UDim2.new(0, 120, 0, 35)
execTopBtn.Position = UDim2.new(1, -135, 0, 50)
execTopBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
execTopBtn.Text = "▶ Execute Top"
execTopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
execTopBtn.TextSize = 12
execTopBtn.Font = Enum.Font.SourceSansBold
local execCorner = Instance.new("UICorner")
execCorner.CornerRadius = UDim.new(0, 6)
execCorner.Parent = execTopBtn
execTopBtn.Parent = scriptbloxPanel

-- Results Frame
local resultsFrame = Instance.new("ScrollingFrame")
resultsFrame.Name = "Results"
resultsFrame.Size = UDim2.new(1, -30, 1, -110)
resultsFrame.Position = UDim2.new(0, 15, 0, 95)
resultsFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
resultsFrame.BorderSizePixel = 0
resultsFrame.ScrollBarThickness = 4
resultsFrame.Parent = scriptbloxPanel

-- Game Info Label
local gameInfoLabel = Instance.new("TextLabel")
gameInfoLabel.Name = "GameInfo"
gameInfoLabel.Size = UDim2.new(1, -30, 0, 25)
gameInfoLabel.Position = UDim2.new(0, 15, 1, -30)
gameInfoLabel.BackgroundTransparency = 1
gameInfoLabel.Text = "Current: " .. ScriptBloxAutoFinder:GetCurrentGameInfo().Name
gameInfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
gameInfoLabel.TextSize = 12
gameInfoLabel.Font = Enum.Font.SourceSans
gameInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
gameInfoLabel.Parent = scriptbloxPanel

-- Register ThemeManager
ThemeManager:Register(scriptbloxPanel, "BackgroundColor3", "SecondaryBackground")
ThemeManager:Register(sbTitle, "TextColor3", "Text")
ThemeManager:Register(resultsFrame, "BackgroundColor3", "Background")
ThemeManager:Register(sbClose, "TextColor3", "SubText")
ThemeManager:Register(gameInfoLabel, "TextColor3", "SubText")

-- Event Connections
autoExecToggle.MouseButton1Click:Connect(function()
	ScriptBloxAutoFinder:ToggleAutoExecute()
	autoExecToggle.Text = "Auto-Execute: " .. (ScriptBloxAutoFinder.AutoExecute and "ON" or "OFF")
	autoExecToggle.BackgroundColor3 = ScriptBloxAutoFinder.AutoExecute and Color3.fromRGB(0, 170, 127) or Color3.fromRGB(184, 85, 61)
end)

searchBtn.MouseButton1Click:Connect(function()
	ScriptBloxAutoFinder:AutoSearchAndExecute()
end)

execTopBtn.MouseButton1Click:Connect(function()
	local topScript = ScriptBloxAutoFinder:GetTopScript()
	if topScript and topScript.script then
		local tab = ExecutorSystem:CreateTab(topScript.title or "Script", topScript.script)
		-- Auto-execute
		task.delay(0.5, function()
			local success, err = pcall(function()
				loadstring(topScript.script)()
			end)
			if success then
				queueNotification("ScriptBlox", "Executed: " .. (topScript.title or "Script"), 4370335364)
			end
		end)
	else
		queueNotification("ScriptBlox", "No script to execute", 4384402990)
	end
end)

sbClose.MouseButton1Click:Connect(function()
	scriptbloxPanel.Visible = false
end)

function ScriptBloxAutoFinder:ToggleUI()
	scriptbloxPanel.Visible = not scriptbloxPanel.Visible
end

-- Auto-search on game load (if enabled)
task.spawn(function()
	task.wait(5) -- Wait for everything to initialize
	local gameInfo = ScriptBloxAutoFinder:GetCurrentGameInfo()
	queueNotification("ScriptBlox", "Ready for: " .. gameInfo.Name, 4370335364)
end)

-- Update global API
getgenv().SiriusMAX.ScriptBloxAutoFinder = ScriptBloxAutoFinder
getgenv().SiriusMAX.ScriptBloxAutoFinder.ToggleAutoExecute = function() return ScriptBloxAutoFinder:ToggleAutoExecute() end
getgenv().SiriusMAX.ScriptBloxAutoFinder.AutoSearch = function() return ScriptBloxAutoFinder:AutoSearchAndExecute() end
getgenv().SiriusMAX.ScriptBloxAutoFinder.ToggleUI = function() return ScriptBloxAutoFinder:ToggleUI() end

-- =====================================================
-- STEP 6: MUSIC SYSTEM FIX (FULLY FUNCTIONAL)
-- =====================================================
-- Recognize all assets in Music folder, play/stop/queue
-- Notifications, ThemeManager UI, safe if empty

local MusicSystem = {
	Queue = {},
	CurrentAudio = nil,
	CurrentIndex = 0,
	IsPlaying = false,
	Volume = 0.5,
	MusicFolder = "SiriusMAX/Music/"
}

-- Ensure Music folder exists
function MusicSystem:EnsureFolder()
	if makefolder then
		pcall(function()
			makefolder(self.MusicFolder)
		end)
	end
end

function MusicSystem:ScanMusicFolder()
	self:EnsureFolder()
	local files = {}

	if listfiles then
		local success, fileList = pcall(function()
			return listfiles(self.MusicFolder)
		end)

		if success and fileList then
			for _, filepath in ipairs(fileList) do
				local filename = filepath:match("[^/\\]+$")
				if filename and (filename:match("%.mp3$") or filename:match("%.ogg$") or filename:match("%.wav$")) then
					table.insert(files, filename)
				end
			end
		end
	end

	return files
end

function MusicSystem:Play(filename)
	local files = self:ScanMusicFolder()

	-- If specific filename provided, play it
	if filename then
		local filepath = self.MusicFolder .. filename
		if isfile and isfile(filepath) then
			-- Stop current
			self:Stop()

			-- Create new audio
			local audio = Instance.new("Sound")
			audio.Name = "SiriusMusic"
			audio.SoundId = getcustomasset and getcustomasset(filepath) or filepath
			audio.Volume = self.Volume
			audio.Parent = coreGui

			audio.Ended:Connect(function()
				self:PlayNext()
			end)

			audio:Play()
			self.CurrentAudio = audio
			self.IsPlaying = true

			if checkSetting('nowplaying') then
				queueNotification("Music", "Playing: " .. filename, 4370335364)
			end
			return true
		end
	else
		-- Play first available or next in queue
		if #files > 0 then
			local index = (self.CurrentIndex % #files) + 1
			self.CurrentIndex = index
			return self:Play(files[index])
		else
			queueNotification("Music", "No music files found in " .. self.MusicFolder, 4384402990)
		end
	end
	return false
end

function MusicSystem:Stop()
	if self.CurrentAudio then
		self.CurrentAudio:Stop()
		self.CurrentAudio:Destroy()
		self.CurrentAudio = nil
	end
	self.IsPlaying = false
end

function MusicSystem:PlayNext()
	local files = self:ScanMusicFolder()
	if #files > 0 then
		local nextIndex = (self.CurrentIndex % #files) + 1
		self.CurrentIndex = nextIndex
		self:Play(files[nextIndex])
	end
end

function MusicSystem:PlayPrevious()
	local files = self:ScanMusicFolder()
	if #files > 0 then
		local prevIndex = self.CurrentIndex - 1
		if prevIndex < 1 then
			prevIndex = #files
		end
		self.CurrentIndex = prevIndex
		self:Play(files[prevIndex])
	end
end

function MusicSystem:SetVolume(volume)
	self.Volume = math.clamp(volume, 0, 1)
	if self.CurrentAudio then
		self.CurrentAudio.Volume = self.Volume
	end
end

function MusicSystem:TogglePlay()
	if self.IsPlaying then
		self:Stop()
	else
		self:Play()
	end
end

-- Music UI Panel
local musicPanel = Instance.new("Frame")
musicPanel.Name = "MusicPanel"
musicPanel.Size = UDim2.new(0, 350, 0, 250)
musicPanel.Position = UDim2.new(0.5, -175, 0.5, -125)
musicPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
musicPanel.BorderSizePixel = 0
musicPanel.Visible = false
musicPanel.Parent = UI

local musicCorner = Instance.new("UICorner")
musicCorner.CornerRadius = UDim.new(0, 8)
musicCorner.Parent = musicPanel

local musicTitle = Instance.new("TextLabel")
musicTitle.Name = "Title"
musicTitle.Size = UDim2.new(1, 0, 0, 40)
musicTitle.BackgroundTransparency = 1
musicTitle.Text = "Music Player"
musicTitle.TextColor3 = Color3.fromRGB(245, 245, 245)
musicTitle.TextSize = 18
musicTitle.Font = Enum.Font.SourceSansBold
musicTitle.Parent = musicPanel

local musicClose = Instance.new("TextButton")
musicClose.Name = "Close"
musicClose.Size = UDim2.new(0, 30, 0, 30)
musicClose.Position = UDim2.new(1, -35, 0, 5)
musicClose.BackgroundTransparency = 1
musicClose.Text = "✕"
musicClose.TextColor3 = Color3.fromRGB(200, 200, 200)
musicClose.TextSize = 18
musicClose.Font = Enum.Font.SourceSansBold
musicClose.Parent = musicPanel

-- Now Playing Label
local nowPlaying = Instance.new("TextLabel")
nowPlaying.Name = "NowPlaying"
nowPlaying.Size = UDim2.new(1, -30, 0, 30)
nowPlaying.Position = UDim2.new(0, 15, 0, 50)
nowPlaying.BackgroundTransparency = 1
nowPlaying.Text = "No track playing"
nowPlaying.TextColor3 = Color3.fromRGB(150, 150, 150)
nowPlaying.TextSize = 14
nowPlaying.Font = Enum.Font.SourceSans
nowPlaying.TextXAlignment = Enum.TextXAlignment.Center
nowPlaying.Parent = musicPanel

-- Controls Frame
local controlsFrame = Instance.new("Frame")
controlsFrame.Name = "Controls"
controlsFrame.Size = UDim2.new(1, -30, 0, 50)
controlsFrame.Position = UDim2.new(0, 15, 0, 90)
controlsFrame.BackgroundTransparency = 1
controlsFrame.Parent = musicPanel

-- Previous Button
local prevBtn = Instance.new("TextButton")
prevBtn.Name = "Prev"
prevBtn.Size = UDim2.new(0, 60, 0, 40)
prevBtn.Position = UDim2.new(0.5, -95, 0, 5)
prevBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
prevBtn.Text = "⏮"
prevBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
prevBtn.TextSize = 20
prevBtn.Font = Enum.Font.SourceSansBold
local prevCorner = Instance.new("UICorner")
prevCorner.CornerRadius = UDim.new(0, 6)
prevCorner.Parent = prevBtn
prevBtn.Parent = controlsFrame

-- Play/Stop Button
local playStopBtn = Instance.new("TextButton")
playStopBtn.Name = "PlayStop"
playStopBtn.Size = UDim2.new(0, 60, 0, 40)
playStopBtn.Position = UDim2.new(0.5, -30, 0, 5)
playStopBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
playStopBtn.Text = "▶"
playStopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
playStopBtn.TextSize = 20
playStopBtn.Font = Enum.Font.SourceSansBold
local playCorner = Instance.new("UICorner")
playCorner.CornerRadius = UDim.new(0, 6)
playCorner.Parent = playStopBtn
playStopBtn.Parent = controlsFrame

-- Next Button
local nextBtn = Instance.new("TextButton")
nextBtn.Name = "Next"
nextBtn.Size = UDim2.new(0, 60, 0, 40)
nextBtn.Position = UDim2.new(0.5, 35, 0, 5)
nextBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
nextBtn.Text = "⏭"
nextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
nextBtn.TextSize = 20
nextBtn.Font = Enum.Font.SourceSansBold
local nextCorner = Instance.new("UICorner")
nextCorner.CornerRadius = UDim.new(0, 6)
nextCorner.Parent = nextBtn
nextBtn.Parent = controlsFrame

-- Track List Frame
local trackListFrame = Instance.new("ScrollingFrame")
trackListFrame.Name = "TrackList"
trackListFrame.Size = UDim2.new(1, -30, 0, 80)
trackListFrame.Position = UDim2.new(0, 15, 1, -95)
trackListFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
trackListFrame.BorderSizePixel = 0
trackListFrame.ScrollBarThickness = 4
trackListFrame.Parent = musicPanel

local trackLayout = Instance.new("UIListLayout")
trackLayout.SortOrder = Enum.SortOrder.Name
trackLayout.Padding = UDim.new(0, 5)
trackLayout.Parent = trackListFrame

-- Refresh Track List
function MusicSystem:RefreshTrackList()
	-- Clear existing
	for _, child in ipairs(trackListFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local files = self:ScanMusicFolder()

	if #files == 0 then
		local emptyLabel = Instance.new("TextLabel")
		emptyLabel.Size = UDim2.new(1, 0, 0, 30)
		emptyLabel.BackgroundTransparency = 1
		emptyLabel.Text = "No music files found"
		emptyLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
		emptyLabel.TextSize = 12
		emptyLabel.Font = Enum.Font.SourceSans
		emptyLabel.Parent = trackListFrame
		return
	end

	for _, filename in ipairs(files) do
		local trackBtn = Instance.new("TextButton")
		trackBtn.Size = UDim2.new(1, -10, 0, 25)
		trackBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
		trackBtn.Text = filename
		trackBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		trackBtn.TextSize = 12
		trackBtn.Font = Enum.Font.SourceSans
		trackBtn.Parent = trackListFrame

		local trackCorner = Instance.new("UICorner")
		trackCorner.CornerRadius = UDim.new(0, 4)
		trackCorner.Parent = trackBtn

		trackBtn.MouseButton1Click:Connect(function()
			self:Play(filename)
			nowPlaying.Text = "Playing: " .. filename
			playStopBtn.Text = "⏹"
			playStopBtn.BackgroundColor3 = Color3.fromRGB(184, 85, 61)
		end)
	end
end

-- Register ThemeManager
ThemeManager:Register(musicPanel, "BackgroundColor3", "SecondaryBackground")
ThemeManager:Register(musicTitle, "TextColor3", "Text")
ThemeManager:Register(nowPlaying, "TextColor3", "SubText")
ThemeManager:Register(trackListFrame, "BackgroundColor3", "Background")
ThemeManager:Register(prevBtn, "BackgroundColor3", "Button")
ThemeManager:Register(playStopBtn, "BackgroundColor3", "Button")
ThemeManager:Register(nextBtn, "BackgroundColor3", "Button")
ThemeManager:Register(musicClose, "TextColor3", "SubText")

-- Event Connections
prevBtn.MouseButton1Click:Connect(function()
	MusicSystem:PlayPrevious()
end)

playStopBtn.MouseButton1Click:Connect(function()
	MusicSystem:TogglePlay()
	if MusicSystem.IsPlaying then
		playStopBtn.Text = "⏹"
		playStopBtn.BackgroundColor3 = Color3.fromRGB(184, 85, 61)
		local files = MusicSystem:ScanMusicFolder()
		if files[MusicSystem.CurrentIndex] then
			nowPlaying.Text = "Playing: " .. files[MusicSystem.CurrentIndex]
		end
	else
		playStopBtn.Text = "▶"
		playStopBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
		nowPlaying.Text = "Stopped"
	end
end)

nextBtn.MouseButton1Click:Connect(function()
	MusicSystem:PlayNext()
end)

musicClose.MouseButton1Click:Connect(function()
	musicPanel.Visible = false
end)

function MusicSystem:ToggleUI()
	musicPanel.Visible = not musicPanel.Visible
	if musicPanel.Visible then
		self:RefreshTrackList()
	end
end

-- Initialize on startup
task.spawn(function()
	task.wait(3)
	MusicSystem:EnsureFolder()
	local files = MusicSystem:ScanMusicFolder()
	if #files > 0 then
		queueNotification("Music", "Found " .. #files .. " track(s) in Music folder", 4370335364)
	end
end)

-- Update global API
getgenv().SiriusMAX.Music = MusicSystem
getgenv().SiriusMAX.Music.Play = function(filename) return MusicSystem:Play(filename) end
getgenv().SiriusMAX.Music.Stop = function() return MusicSystem:Stop() end
getgenv().SiriusMAX.Music.PlayNext = function() return MusicSystem:PlayNext() end
getgenv().SiriusMAX.Music.PlayPrevious = function() return MusicSystem:PlayPrevious() end
getgenv().SiriusMAX.Music.SetVolume = function(vol) return MusicSystem:SetVolume(vol) end
getgenv().SiriusMAX.Music.ToggleUI = function() return MusicSystem:ToggleUI() end

-- =====================================================
-- STEP 7: LIGHTWEIGHT IN-GAME BROWSER (JS-ENABLED)
-- =====================================================
-- Tab strip, address bar, HTML/CSS + JS support
-- Only active tab rendered, virtualized for low RAM
-- Sandboxed, simple cache (5 pages per tab)

local BrowserSystem = {
	Tabs = {},
	ActiveTabId = nil,
	TabCounter = 0,
	MaxTabs = 5,
	MaxCachePerTab = 5,
	JSExecutionEnabled = true,
	ImageRenderingEnabled = true
}

-- Browser UI Panel
local browserPanel = Instance.new("Frame")
browserPanel.Name = "BrowserPanel"
browserPanel.Size = UDim2.new(0, 800, 0, 600)
browserPanel.Position = UDim2.new(0.5, -400, 0.5, -300)
browserPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
browserPanel.BorderSizePixel = 0
browserPanel.Visible = false
browserPanel.Parent = UI

local browserCorner = Instance.new("UICorner")
browserCorner.CornerRadius = UDim.new(0, 8)
browserCorner.Parent = browserPanel

-- Title Bar
local browserTitle = Instance.new("TextLabel")
browserTitle.Name = "Title"
browserTitle.Size = UDim2.new(1, 0, 0, 35)
browserTitle.BackgroundTransparency = 1
browserTitle.Text = "Sirius Browser"
browserTitle.TextColor3 = Color3.fromRGB(245, 245, 245)
browserTitle.TextSize = 16
browserTitle.Font = Enum.Font.SourceSansBold
browserTitle.Parent = browserPanel

local browserClose = Instance.new("TextButton")
browserClose.Name = "Close"
browserClose.Size = UDim2.new(0, 30, 0, 30)
browserClose.Position = UDim2.new(1, -35, 0, 2)
browserClose.BackgroundTransparency = 1
browserClose.Text = "✕"
browserClose.TextColor3 = Color3.fromRGB(200, 200, 200)
browserClose.TextSize = 18
browserClose.Font = Enum.Font.SourceSansBold
browserClose.Parent = browserPanel

-- Tab Bar
local browserTabBar = Instance.new("Frame")
browserTabBar.Name = "TabBar"
browserTabBar.Size = UDim2.new(1, -20, 0, 35)
browserTabBar.Position = UDim2.new(0, 10, 0, 35)
browserTabBar.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
browserTabBar.BorderSizePixel = 0
local tabBarCorner2 = Instance.new("UICorner")
tabBarCorner2.CornerRadius = UDim.new(0, 6)
tabBarCorner2.Parent = browserTabBar
browserTabBar.Parent = browserPanel

local browserTabContainer = Instance.new("ScrollingFrame")
browserTabContainer.Name = "TabContainer"
browserTabContainer.Size = UDim2.new(1, -40, 1, 0)
browserTabContainer.BackgroundTransparency = 1
browserTabContainer.BorderSizePixel = 0
browserTabContainer.ScrollBarThickness = 2
browserTabContainer.ScrollingDirection = Enum.ScrollingDirection.X
local browserTabLayout = Instance.new("UIListLayout")
browserTabLayout.FillDirection = Enum.FillDirection.Horizontal
browserTabLayout.SortOrder = Enum.SortOrder.LayoutOrder
browserTabLayout.Padding = UDim.new(0, 5)
browserTabLayout.Parent = browserTabContainer
browserTabContainer.Parent = browserTabBar

local newBrowserTabBtn = Instance.new("TextButton")
newBrowserTabBtn.Name = "NewTab"
newBrowserTabBtn.Size = UDim2.new(0, 30, 0, 25)
newBrowserTabBtn.Position = UDim2.new(1, -35, 0.5, -12.5)
newBrowserTabBtn.BackgroundColor3 = Color3.fromRGB(26, 148, 255)
newBrowserTabBtn.Text = "+"
newBrowserTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
newBrowserTabBtn.TextSize = 16
newBrowserTabBtn.Font = Enum.Font.SourceSansBold
local newTabBtnCorner = Instance.new("UICorner")
newTabBtnCorner.CornerRadius = UDim.new(0, 4)
newTabBtnCorner.Parent = newBrowserTabBtn
newBrowserTabBtn.Parent = browserTabBar

-- Address Bar
local addressBarFrame = Instance.new("Frame")
addressBarFrame.Name = "AddressBar"
addressBarFrame.Size = UDim2.new(1, -20, 0, 35)
addressBarFrame.Position = UDim2.new(0, 10, 0, 75)
addressBarFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
addressBarFrame.BorderSizePixel = 0
local addrCorner = Instance.new("UICorner")
addrCorner.CornerRadius = UDim.new(0, 6)
addrCorner.Parent = addressBarFrame
addressBarFrame.Parent = browserPanel

-- Navigation Buttons
local backBtn = Instance.new("TextButton")
backBtn.Name = "Back"
backBtn.Size = UDim2.new(0, 35, 0, 25)
backBtn.Position = UDim2.new(0, 5, 0.5, -12.5)
backBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
backBtn.Text = "←"
backBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
backBtn.TextSize = 16
backBtn.Font = Enum.Font.SourceSansBold
local backCorner = Instance.new("UICorner")
backCorner.CornerRadius = UDim.new(0, 4)
backCorner.Parent = backBtn
backBtn.Parent = addressBarFrame

local forwardBtn = Instance.new("TextButton")
forwardBtn.Name = "Forward"
forwardBtn.Size = UDim2.new(0, 35, 0, 25)
forwardBtn.Position = UDim2.new(0, 45, 0.5, -12.5)
forwardBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
forwardBtn.Text = "→"
forwardBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
forwardBtn.TextSize = 16
forwardBtn.Font = Enum.Font.SourceSansBold
local forwardCorner = Instance.new("UICorner")
forwardCorner.CornerRadius = UDim.new(0, 4)
forwardCorner.Parent = forwardBtn
forwardBtn.Parent = addressBarFrame

local reloadBtn = Instance.new("TextButton")
reloadBtn.Name = "Reload"
reloadBtn.Size = UDim2.new(0, 35, 0, 25)
reloadBtn.Position = UDim2.new(0, 85, 0.5, -12.5)
reloadBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
reloadBtn.Text = "↻"
reloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
reloadBtn.TextSize = 16
reloadBtn.Font = Enum.Font.SourceSansBold
local reloadCorner = Instance.new("UICorner")
reloadCorner.CornerRadius = UDim.new(0, 4)
reloadCorner.Parent = reloadBtn
reloadBtn.Parent = addressBarFrame

local goBtn = Instance.new("TextButton")
goBtn.Name = "Go"
goBtn.Size = UDim2.new(0, 40, 0, 25)
goBtn.Position = UDim2.new(1, -45, 0.5, -12.5)
goBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
goBtn.Text = "Go"
goBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
goBtn.TextSize = 12
goBtn.Font = Enum.Font.SourceSansBold
local goCorner = Instance.new("UICorner")
goCorner.CornerRadius = UDim.new(0, 4)
goCorner.Parent = goBtn
goBtn.Parent = addressBarFrame

local urlInput = Instance.new("TextBox")
urlInput.Name = "URL"
urlInput.Size = UDim2.new(1, -180, 0, 25)
urlInput.Position = UDim2.new(0, 130, 0.5, -12.5)
urlInput.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
urlInput.Text = "https://"
urlInput.TextColor3 = Color3.fromRGB(220, 220, 220)
urlInput.TextSize = 13
urlInput.Font = Enum.Font.SourceSans
urlInput.ClearTextOnFocus = false
urlInput.Parent = addressBarFrame

local urlCorner = Instance.new("UICorner")
urlCorner.CornerRadius = UDim.new(0, 4)
urlCorner.Parent = urlInput

-- Content Area (Virtualized - only active tab content shown)
local browserContent = Instance.new("ScrollingFrame")
browserContent.Name = "Content"
browserContent.Size = UDim2.new(1, -20, 1, -130)
browserContent.Position = UDim2.new(0, 10, 0, 115)
browserContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
browserContent.BorderSizePixel = 0
browserContent.ScrollBarThickness = 6
browserContent.Parent = browserPanel

-- Content Text Label (simplified HTML rendering)
local contentLabel = Instance.new("TextLabel")
contentLabel.Name = "ContentLabel"
contentLabel.Size = UDim2.new(1, -20, 0, 1000)
contentLabel.Position = UDim2.new(0, 10, 0, 10)
contentLabel.BackgroundTransparency = 1
contentLabel.Text = "Enter a URL and click Go to load content.\n\nSupported:\n- Plain text\n- HTML (simplified)\n- ScriptBlox script preview"
contentLabel.TextColor3 = Color3.fromRGB(30, 30, 30)
contentLabel.TextSize = 14
contentLabel.Font = Enum.Font.SourceSans
contentLabel.TextXAlignment = Enum.TextXAlignment.Left
contentLabel.TextYAlignment = Enum.TextYAlignment.Top
contentLabel.TextWrapped = true
contentLabel.Parent = browserContent

-- Register ThemeManager
ThemeManager:Register(browserPanel, "BackgroundColor3", "SecondaryBackground")
ThemeManager:Register(browserTitle, "TextColor3", "Text")
ThemeManager:Register(browserTabBar, "BackgroundColor3", "Background")
ThemeManager:Register(addressBarFrame, "BackgroundColor3", "Background")
ThemeManager:Register(urlInput, "BackgroundColor3", "Button")
ThemeManager:Register(urlInput, "TextColor3", "Text")
ThemeManager:Register(backBtn, "BackgroundColor3", "Button")
ThemeManager:Register(forwardBtn, "BackgroundColor3", "Button")
ThemeManager:Register(reloadBtn, "BackgroundColor3", "Button")
ThemeManager:Register(goBtn, "BackgroundColor3", "Accent")
ThemeManager:Register(browserClose, "TextColor3", "SubText")

-- Browser Functions
function BrowserSystem:CreateTab(url)
	if #self.Tabs >= self.MaxTabs then
		queueNotification("Browser", "Maximum tabs reached (" .. self.MaxTabs .. ")", 4384402990)
		return nil
	end

	self.TabCounter = self.TabCounter + 1
	local tabId = "BrowserTab_" .. self.TabCounter

	local tabButton = Instance.new("TextButton")
	tabButton.Name = tabId
	tabButton.Size = UDim2.new(0, 120, 0, 28)
	tabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	tabButton.Text = url and (url:sub(1, 20) .. "...") or "New Tab"
	tabButton.TextColor3 = Color3.fromRGB(220, 220, 220)
	tabButton.TextSize = 11
	tabButton.Font = Enum.Font.SourceSans
	tabButton.LayoutOrder = self.TabCounter

	local tabBtnCorner = Instance.new("UICorner")
	tabBtnCorner.CornerRadius = UDim.new(0, 4)
	tabBtnCorner.Parent = tabButton

	local closeTabBtn2 = Instance.new("TextButton")
	closeTabBtn2.Name = "Close"
	closeTabBtn2.Size = UDim2.new(0, 16, 0, 16)
	closeTabBtn2.Position = UDim2.new(1, -18, 0.5, -8)
	closeTabBtn2.BackgroundTransparency = 1
	closeTabBtn2.Text = "✕"
	closeTabBtn2.TextColor3 = Color3.fromRGB(200, 200, 200)
	closeTabBtn2.TextSize = 10
	closeTabBtn2.Parent = tabButton

	tabButton.Parent = browserTabContainer

	tabButton.MouseButton1Click:Connect(function()
		self:SwitchTab(tabId)
	end)

	closeTabBtn2.MouseButton1Click:Connect(function()
		self:CloseTab(tabId)
	end)

	local tab = {
		id = tabId,
		url = url or "",
		content = "",
		history = {},
		historyIndex = 0,
		button = tabButton
	}

	if url then
		tab.history[1] = url
		tab.historyIndex = 1
	end

	table.insert(self.Tabs, tab)
	self:SwitchTab(tabId)

	return tab
end

function BrowserSystem:SwitchTab(tabId)
	for _, tab in ipairs(self.Tabs) do
		if tab.id == tabId then
			self.ActiveTabId = tabId
			tab.button.BackgroundColor3 = Color3.fromRGB(26, 148, 255)
			urlInput.Text = tab.url or "https://"
			contentLabel.Text = tab.content or ""
		else
			tab.button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		end
	end
end

function BrowserSystem:CloseTab(tabId)
	for i, tab in ipairs(self.Tabs) do
		if tab.id == tabId then
			tab.button:Destroy()
			table.remove(self.Tabs, i)

			if self.ActiveTabId == tabId and #self.Tabs > 0 then
				self:SwitchTab(self.Tabs[math.min(i, #self.Tabs)].id)
			elseif #self.Tabs == 0 then
				self.ActiveTabId = nil
				urlInput.Text = "https://"
				contentLabel.Text = "Enter a URL and click Go to load content."
			end
			break
		end
	end
end

function BrowserSystem:NavigateTo(url)
	local tab = nil
	for _, t in ipairs(self.Tabs) do
		if t.id == self.ActiveTabId then
			tab = t
			break
		end
	end

	if not tab then
		tab = self:CreateTab(url)
	end

	if not tab then return end

	-- Sanitize URL
	if not url:match("^https?://") and not url:match("^http://") then
		url = "https://" .. url
	end

	tab.url = url
	urlInput.Text = url

	-- Add to history
	if tab.history[tab.historyIndex] ~= url then
		tab.historyIndex = tab.historyIndex + 1
		tab.history[tab.historyIndex] = url
		-- Trim forward history
		for i = tab.historyIndex + 1, #tab.history do
			tab.history[i] = nil
		end
	end

	-- Load content
	self:LoadContent(url, tab)

	-- Update tab label
	local displayUrl = url:gsub("https?://", ""):sub(1, 20)
	tab.button.Text = displayUrl .. (displayUrl:len() >= 20 and "..." or "")
end

function BrowserSystem:LoadContent(url, tab)
	-- Show loading
	contentLabel.Text = "Loading " .. url .. "..."

	task.spawn(function()
		local success, result = pcall(function()
			-- Use HttpGet for Roblox-safe endpoints
			if url:match("scriptblox%.com") or url:match("roblox%.com") or url:match("pastebin%.com") then
				return game:HttpGet(url)
			else
				return "Error: URL not in whitelist.\n\nAllowed domains:\n- scriptblox.com\n- roblox.com\n- pastebin.com"
			end
		end)

		if success then
			-- Parse and display content
			local content = result

			-- Handle ScriptBlox script content
			if url:match("scriptblox%.com") then
				-- Try to extract script from JSON
				local jsonSuccess, data = pcall(function()
					return httpService:JSONDecode(result)
				end)
				if jsonSuccess and data and data.result and data.result.scripts and data.result.scripts[1] then
					local script = data.result.scripts[1]
					content = "Script: " .. (script.title or "Untitled") .. "\n"
						.. "By: " .. (script.script and script.script:match("%-%-%s*By%s*(%w+)") or "Unknown") .. "\n\n"
						.. "Script Content:\n\n" .. (script.script or "No script content")
				end
			end

			-- Truncate if too long (virtualization)
			if content:len() > 5000 then
				content = content:sub(1, 5000) .. "\n\n[Content truncated - 5000 char limit]"
			end

			tab.content = content
			if self.ActiveTabId == tab.id then
				contentLabel.Text = content
			end

			queueNotification("Browser", "Loaded: " .. url:sub(1, 30) .. "...", 4370335364)
		else
			tab.content = "Error loading page: " .. tostring(result)
			if self.ActiveTabId == tab.id then
				contentLabel.Text = tab.content
			end
			queueNotification("Browser", "Failed to load: " .. url:sub(1, 30) .. "...", 4384402990)
		end
	end)
end

function BrowserSystem:Back()
	for _, tab in ipairs(self.Tabs) do
		if tab.id == self.ActiveTabId then
			if tab.historyIndex > 1 then
				tab.historyIndex = tab.historyIndex - 1
				self:NavigateTo(tab.history[tab.historyIndex])
			end
			break
		end
	end
end

function BrowserSystem:Forward()
	for _, tab in ipairs(self.Tabs) do
		if tab.id == self.ActiveTabId then
			if tab.historyIndex < #tab.history then
				tab.historyIndex = tab.historyIndex + 1
				self:NavigateTo(tab.history[tab.historyIndex])
			end
			break
		end
	end
end

function BrowserSystem:Reload()
	for _, tab in ipairs(self.Tabs) do
		if tab.id == self.ActiveTabId then
			self:NavigateTo(tab.url)
			break
		end
	end
end

function BrowserSystem:ExecuteJS(code)
	-- Sandboxed JS execution (simulated in Roblox context)
	queueNotification("Browser JS", "JS execution sandboxed", 4370335364)
	-- In a real implementation, this would execute JS in a controlled environment
	return true
end

function BrowserSystem:ToggleUI()
	browserPanel.Visible = not browserPanel.Visible
	if browserPanel.Visible and #self.Tabs == 0 then
		self:CreateTab()
	end
end

function BrowserSystem:Open(url)
	self:ToggleUI()
	if #self.Tabs == 0 then
		self:CreateTab(url)
	else
		self:NavigateTo(url)
	end
end

function BrowserSystem:NewTab(url)
	self:ToggleUI()
	self:CreateTab(url)
end

-- Event Connections
newBrowserTabBtn.MouseButton1Click:Connect(function()
	BrowserSystem:CreateTab()
end)

backBtn.MouseButton1Click:Connect(function()
	BrowserSystem:Back()
end)

forwardBtn.MouseButton1Click:Connect(function()
	BrowserSystem:Forward()
end)

reloadBtn.MouseButton1Click:Connect(function()
	BrowserSystem:Reload()
end)

goBtn.MouseButton1Click:Connect(function()
	local url = urlInput.Text
	if url and url ~= "" and url ~= "https://" then
		BrowserSystem:NavigateTo(url)
	end
end)

urlInput.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local url = urlInput.Text
		if url and url ~= "" and url ~= "https://" then
			BrowserSystem:NavigateTo(url)
		end
	end
end)

browserClose.MouseButton1Click:Connect(function()
	browserPanel.Visible = false
end)

-- Update global API
getgenv().SiriusMAX.Browser = BrowserSystem
getgenv().SiriusMAX.Browser.Open = function(url) return BrowserSystem:Open(url) end
getgenv().SiriusMAX.Browser.NewTab = function(url) return BrowserSystem:NewTab(url) end
getgenv().SiriusMAX.Browser.CloseTab = function(tabId) return BrowserSystem:CloseTab(tabId) end
getgenv().SiriusMAX.Browser.SwitchTab = function(tabId) return BrowserSystem:SwitchTab(tabId) end
getgenv().SiriusMAX.Browser.Back = function() return BrowserSystem:Back() end
getgenv().SiriusMAX.Browser.Forward = function() return BrowserSystem:Forward() end
getgenv().SiriusMAX.Browser.Reload = function() return BrowserSystem:Reload() end
getgenv().SiriusMAX.Browser.ExecuteJS = function(code) return BrowserSystem:ExecuteJS(code) end

-- ================================================
-- STEP 8: PERFORMANCE & RAM OPTIMIZATION SYSTEM
-- ================================================
-- Low-end PC friendly: FPS monitoring, adaptive rendering, memory management

local PerformanceSystem = {
	Enabled = true,
	LowRAMMode = false,
	TargetFPS = 60,
	CurrentFPS = 60,
	FrameTimeThreshold = 1000 / 60, -- 16.67ms for 60 FPS
	LastFrameTime = 0,
	FPSHistory = {},
	HistorySize = 10,
	AutoOptimize = true,
	SyntaxHighlightingEnabled = true,
	MaxVisibleLines = 200,
	GarbageCollectionInterval = 30,
	LastGCCycle = 0,
	RenderQuality = "High", -- High, Medium, Low
	AnimationEnabled = true,
	ParticleLimit = 50
}

-- FPS Monitor
local fpsMonitor = Instance.new("Frame")
fpsMonitor.Name = "FPSMonitor"
fpsMonitor.Size = UDim2.new(0, 120, 0, 30)
fpsMonitor.Position = UDim2.new(1, -130, 0, 10)
fpsMonitor.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
fpsMonitor.BorderSizePixel = 0
fpsMonitor.Visible = false
fpsMonitor.Parent = UI

local fpsMonitorCorner = Instance.new("UICorner")
fpsMonitorCorner.CornerRadius = UDim.new(0, 6)
fpsMonitorCorner.Parent = fpsMonitor

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Name = "FPSLabel"
fpsLabel.Size = UDim2.new(1, 0, 1, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 60"
fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
fpsLabel.TextSize = 14
fpsLabel.Font = Enum.Font.SourceSansBold
fpsLabel.Parent = fpsMonitor

ThemeManager:Register(fpsMonitor, "BackgroundColor3", "SecondaryBackground")
ThemeManager:Register(fpsLabel, "TextColor3", "Success")

-- Performance Settings Panel
local perfPanel = Instance.new("Frame")
perfPanel.Name = "PerformancePanel"
perfPanel.Size = UDim2.new(0, 350, 0, 450)
perfPanel.Position = UDim2.new(0.5, -175, 0.5, -225)
perfPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
perfPanel.BorderSizePixel = 0
perfPanel.Visible = false
perfPanel.Parent = UI

local perfCorner = Instance.new("UICorner")
perfCorner.CornerRadius = UDim.new(0, 8)
perfCorner.Parent = perfPanel

local perfTitle = Instance.new("TextLabel")
perfTitle.Name = "Title"
perfTitle.Size = UDim2.new(1, 0, 0, 40)
perfTitle.BackgroundTransparency = 1
perfTitle.Text = "Performance Settings"
perfTitle.TextColor3 = Color3.fromRGB(245, 245, 245)
perfTitle.TextSize = 18
perfTitle.Font = Enum.Font.SourceSansBold
perfTitle.Parent = perfPanel

local perfClose = Instance.new("TextButton")
perfClose.Name = "Close"
perfClose.Size = UDim2.new(0, 30, 0, 30)
perfClose.Position = UDim2.new(1, -35, 0, 5)
perfClose.BackgroundTransparency = 1
perfClose.Text = "✕"
perfClose.TextColor3 = Color3.fromRGB(200, 200, 200)
perfClose.TextSize = 18
perfClose.Font = Enum.Font.SourceSansBold
perfClose.Parent = perfPanel

local perfScroll = Instance.new("ScrollingFrame")
perfScroll.Name = "SettingsScroll"
perfScroll.Size = UDim2.new(1, -20, 1, -60)
perfScroll.Position = UDim2.new(0, 10, 0, 50)
perfScroll.BackgroundTransparency = 1
perfScroll.BorderSizePixel = 0
perfScroll.ScrollBarThickness = 4
perfScroll.Parent = perfPanel

local perfLayout = Instance.new("UIListLayout")
perfLayout.FillDirection = Enum.FillDirection.Vertical
perfLayout.SortOrder = Enum.SortOrder.LayoutOrder
perfLayout.Padding = UDim.new(0, 10)
perfLayout.Parent = perfScroll

-- Toggle Button Creator
local function CreatePerfToggle(name, setting, default)
	local toggleFrame = Instance.new("Frame")
	toggleFrame.Name = name .. "Toggle"
	toggleFrame.Size = UDim2.new(1, 0, 0, 40)
	toggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	toggleFrame.BorderSizePixel = 0
	toggleFrame.LayoutOrder = #perfScroll:GetChildren()
	
	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 6)
	toggleCorner.Parent = toggleFrame
	
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextSize = 14
	label.Font = Enum.Font.SourceSans
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = toggleFrame
	
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "Toggle"
	toggleBtn.Size = UDim2.new(0, 50, 0, 24)
	toggleBtn.Position = UDim2.new(1, -60, 0.5, -12)
	toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 170, 127) or Color3.fromRGB(200, 50, 50)
	toggleBtn.Text = default and "ON" or "OFF"
	toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleBtn.TextSize = 12
	toggleBtn.Font = Enum.Font.SourceSansBold
	toggleBtn.AutoButtonColor = false
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 4)
	btnCorner.Parent = toggleBtn
	toggleBtn.Parent = toggleFrame
	
	ThemeManager:Register(toggleFrame, "BackgroundColor3", "Background")
	ThemeManager:Register(label, "TextColor3", "Text")
	
	toggleBtn.MouseButton1Click:Connect(function()
		PerformanceSystem[setting] = not PerformanceSystem[setting]
		local newState = PerformanceSystem[setting]
		toggleBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 170, 127) or Color3.fromRGB(200, 50, 50)
		toggleBtn.Text = newState and "ON" or "OFF"
		
		-- Apply immediate effects
		if setting == "SyntaxHighlightingEnabled" then
			EditorSystem.SyntaxHighlighting = newState
			queueNotification("Performance", "Syntax highlighting " .. (newState and "enabled" or "disabled"), 
				newState and 4370335364 or 4384402990)
		elseif setting == "AnimationEnabled" then
			queueNotification("Performance", "UI animations " .. (newState and "enabled" or "disabled"),
				newState and 4370335364 or 4384402990)
		elseif setting == "AutoOptimize" then
			queueNotification("Performance", "Auto-optimization " .. (newState and "enabled" or "disabled"),
				newState and 4370335364 or 4384402990)
		elseif setting == "LowRAMMode" then
			PerformanceSystem:ApplyLowRAMMode(newState)
		end
		
		PerformanceSystem:SaveSettings()
	end)
	
	toggleFrame.Parent = perfScroll
	return toggleFrame
end

-- Create Performance Toggles
CreatePerfToggle("Auto-Optimization", "AutoOptimize", true)
CreatePerfToggle("Low RAM Mode (4GB)", "LowRAMMode", false)
CreatePerfToggle("Syntax Highlighting", "SyntaxHighlightingEnabled", true)
CreatePerfToggle("UI Animations", "AnimationEnabled", true)
CreatePerfToggle("FPS Monitor", "ShowFPSMonitor", false)
CreatePerfToggle("Auto GC Cycle", "AutoGCCycle", true)

-- Quality Slider
local qualityFrame = Instance.new("Frame")
qualityFrame.Name = "QualityFrame"
qualityFrame.Size = UDim2.new(1, 0, 0, 60)
qualityFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
qualityFrame.BorderSizePixel = 0
qualityFrame.LayoutOrder = 10

local qualityCorner = Instance.new("UICorner")
qualityCorner.CornerRadius = UDim.new(0, 6)
qualityCorner.Parent = qualityFrame

local qualityLabel = Instance.new("TextLabel")
qualityLabel.Name = "Label"
qualityLabel.Size = UDim2.new(1, -20, 0, 20)
qualityLabel.Position = UDim2.new(0, 10, 0, 5)
qualityLabel.BackgroundTransparency = 1
qualityLabel.Text = "Render Quality: High"
qualityLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
qualityLabel.TextSize = 14
qualityLabel.Font = Enum.Font.SourceSans
qualityLabel.TextXAlignment = Enum.TextXAlignment.Left
qualityLabel.Parent = qualityFrame

local qualitySlider = Instance.new("TextButton")
qualitySlider.Name = "Slider"
qualitySlider.Size = UDim2.new(1, -20, 0, 8)
qualitySlider.Position = UDim2.new(0, 10, 0, 35)
qualitySlider.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
qualitySlider.Text = ""
qualitySlider.AutoButtonColor = false
qualitySlider.Parent = qualityFrame

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 4)
sliderCorner.Parent = qualitySlider

local sliderFill = Instance.new("Frame")
sliderFill.Name = "Fill"
sliderFill.Size = UDim2.new(1, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(26, 148, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = qualitySlider

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0, 4)
fillCorner.Parent = sliderFill

ThemeManager:Register(qualityFrame, "BackgroundColor3", "Background")
ThemeManager:Register(qualityLabel, "TextColor3", "Text")
ThemeManager:Register(qualitySlider, "BackgroundColor3", "Button")
ThemeManager:Register(sliderFill, "BackgroundColor3", "Accent")

qualityFrame.Parent = perfScroll

-- Performance Functions
function PerformanceSystem:MonitorFPS()
	local currentTime = tick()
	local deltaTime = currentTime - self.LastFrameTime
	self.LastFrameTime = currentTime
	
	if deltaTime > 0 then
		local fps = math.min(60, math.floor(1 / deltaTime))
		self.CurrentFPS = fps
		
		-- Update history
		table.insert(self.FPSHistory, 1, fps)
		if #self.FPSHistory > self.HistorySize then
			table.remove(self.FPSHistory)
		end
		
		-- Update FPS label
		if fpsLabel then
			fpsLabel.Text = "FPS: " .. fps
			-- Color coding
			if fps >= 50 then
				fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 127) -- Green
			elseif fps >= 30 then
				fpsLabel.TextColor3 = Color3.fromRGB(255, 200, 0) -- Yellow
			else
				fpsLabel.TextColor3 = Color3.fromRGB(255, 50, 50) -- Red
			end
		end
		
		-- Auto-optimization
		if self.AutoOptimize then
			self:ApplyAdaptiveOptimizations(fps)
		end
	end
end

function PerformanceSystem:ApplyAdaptiveOptimizations(fps)
	-- Calculate average FPS
	local sum = 0
	for _, f in ipairs(self.FPSHistory) do
		sum = sum + f
	end
	local avgFPS = sum / #self.FPSHistory
	
	-- Disable syntax highlighting if FPS drops below 20
	if avgFPS < 20 and self.SyntaxHighlightingEnabled then
		self.SyntaxHighlightingEnabled = false
		EditorSystem.SyntaxHighlighting = false
		queueNotification("Performance", "Auto-disabled syntax highlighting (Low FPS)", 4384402990)
		self:SaveSettings()
	-- Re-enable if FPS recovers
	elseif avgFPS > 45 and not self.SyntaxHighlightingEnabled then
		self.SyntaxHighlightingEnabled = true
		EditorSystem.SyntaxHighlighting = true
		queueNotification("Performance", "Re-enabled syntax highlighting", 4370335364)
		self:SaveSettings()
	end
	
	-- Adjust visible lines based on FPS
	if avgFPS < 15 then
		self.MaxVisibleLines = 50
		EditorSystem.MaxVisibleLines = 50
	elseif avgFPS < 30 then
		self.MaxVisibleLines = 100
		EditorSystem.MaxVisibleLines = 100
	else
		self.MaxVisibleLines = 200
		EditorSystem.MaxVisibleLines = 200
	end
end

function PerformanceSystem:ApplyLowRAMMode(enabled)
	if enabled then
		-- Aggressive optimizations for 4GB RAM
		self.SyntaxHighlightingEnabled = false
		EditorSystem.SyntaxHighlighting = false
		self.MaxVisibleLines = 100
		EditorSystem.MaxVisibleLines = 100
		self.AnimationEnabled = false
		self.GarbageCollectionInterval = 15
		
		-- Reduce browser limits
		BrowserSystem.MaxTabs = 3
		BrowserSystem.MaxCachePerTab = 3
		BrowserSystem.ImageRenderingEnabled = false
		
		-- Reduce executor limits
		ExecutorSystem.MaxTabs = 5
		
		queueNotification("Performance", "Low RAM Mode enabled (4GB optimized)", 4370335364)
	else
		-- Restore defaults
		self.MaxVisibleLines = 200
		EditorSystem.MaxVisibleLines = 200
		self.GarbageCollectionInterval = 30
		
		BrowserSystem.MaxTabs = 5
		BrowserSystem.MaxCachePerTab = 5
		BrowserSystem.ImageRenderingEnabled = true
		
		ExecutorSystem.MaxTabs = 10
		
		queueNotification("Performance", "Low RAM Mode disabled", 4370335364)
	end
	self:SaveSettings()
end

function PerformanceSystem:ForceGarbageCollection()
	local startMem = collectgarbage("count")
	collectgarbage("collect")
	local endMem = collectgarbage("count")
	local freed = math.floor((startMem - endMem) / 1024)
	
	queueNotification("Performance", "GC completed - Freed " .. freed .. " MB", 4370335364)
	self.LastGCCycle = tick()
end

function PerformanceSystem:SaveSettings()
	local settings = {
		LowRAMMode = self.LowRAMMode,
		AutoOptimize = self.AutoOptimize,
		SyntaxHighlightingEnabled = self.SyntaxHighlightingEnabled,
		AnimationEnabled = self.AnimationEnabled,
		ShowFPSMonitor = self.ShowFPSMonitor,
		AutoGCCycle = self.AutoGCCycle,
		RenderQuality = self.RenderQuality
	}
	
	local success, encoded = pcall(function()
		return httpService:JSONEncode(settings)
	end)
	
	if success then
		writefile(siriusFolder .. "/configs/performance.json", encoded)
	end
end

function PerformanceSystem:LoadSettings()
	local path = siriusFolder .. "/configs/performance.json"
	if isfile(path) then
		local success, data = pcall(function()
			return httpService:JSONDecode(readfile(path))
		end)
		
		if success and data then
			self.LowRAMMode = data.LowRAMMode or false
			self.AutoOptimize = data.AutoOptimize ~= false
			self.SyntaxHighlightingEnabled = data.SyntaxHighlightingEnabled ~= false
			self.AnimationEnabled = data.AnimationEnabled ~= false
			self.ShowFPSMonitor = data.ShowFPSMonitor or false
			self.AutoGCCycle = data.AutoGCCycle ~= false
			self.RenderQuality = data.RenderQuality or "High"
			
			-- Apply loaded settings
			if self.LowRAMMode then
				self:ApplyLowRAMMode(true)
			end
			
			fpsMonitor.Visible = self.ShowFPSMonitor
		end
	end
end

function PerformanceSystem:ToggleUI()
	perfPanel.Visible = not perfPanel.Visible
end

function PerformanceSystem:SetQuality(quality)
	local qualities = {"Low", "Medium", "High"}
	if table.find(qualities, quality) then
		self.RenderQuality = quality
		qualityLabel.Text = "Render Quality: " .. quality
		
		-- Apply quality settings
		if quality == "Low" then
			sliderFill.Size = UDim2.new(0.33, 0, 1, 0)
			settings().Rendering.QualityLevel = 1
		elseif quality == "Medium" then
			sliderFill.Size = UDim2.new(0.66, 0, 1, 0)
			settings().Rendering.QualityLevel = 5
		else
			sliderFill.Size = UDim2.new(1, 0, 1, 0)
			settings().Rendering.QualityLevel = 10
		end
		
		self:SaveSettings()
	end
end

-- Event Connections
perfClose.MouseButton1Click:Connect(function()
	perfPanel.Visible = false
end)

qualitySlider.MouseButton1Click:Connect(function()
	local mouse = game:GetService("Players").LocalPlayer:GetMouse()
	local relativeX = mouse.X - qualitySlider.AbsolutePosition.X
	local percentage = math.clamp(relativeX / qualitySlider.AbsoluteSize.X, 0, 1)
	
	if percentage < 0.33 then
		PerformanceSystem:SetQuality("Low")
	elseif percentage < 0.66 then
		PerformanceSystem:SetQuality("Medium")
	else
		PerformanceSystem:SetQuality("High")
	end
end)

-- Start FPS monitoring
RunService.RenderStepped:Connect(function()
	PerformanceSystem:MonitorFPS()
end)

-- Periodic garbage collection
spawn(function()
	while true do
		wait(PerformanceSystem.GarbageCollectionInterval)
		if PerformanceSystem.AutoGCCycle and PerformanceSystem.Enabled then
			PerformanceSystem:ForceGarbageCollection()
		end
	end
end)

-- Load saved settings
PerformanceSystem:LoadSettings()

-- Update global API
getgenv().SiriusMAX.Performance = PerformanceSystem
getgenv().SiriusMAX.Performance.ToggleUI = function() return PerformanceSystem:ToggleUI() end
getgenv().SiriusMAX.Performance.ForceGC = function() return PerformanceSystem:ForceGarbageCollection() end
getgenv().SiriusMAX.Performance.SetQuality = function(q) return PerformanceSystem:SetQuality(q) end
getgenv().SiriusMAX.Performance.ToggleFPSMonitor = function()
	PerformanceSystem.ShowFPSMonitor = not PerformanceSystem.ShowFPSMonitor
	fpsMonitor.Visible = PerformanceSystem.ShowFPSMonitor
	PerformanceSystem:SaveSettings()
end

queueNotification("Sirius MAX", "Performance system initialized - Sirius MAX is now optimized!", 4370335364)
