-- /dump select(4, GetBuildInfo()) use to get updated toc interface version number
--Load Ace3
Clicker = LibStub("AceAddon-3.0"):NewAddon("Clicker", "AceConsole-3.0", "AceTimer-3.0", "AceComm-3.0", "AceEvent-3.0")
AceConfig = LibStub("AceConfig-3.0")
AceConfigDialog = LibStub("AceConfigDialog-3.0")

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata
Clicker.playerGUID = UnitGUID("player")
Clicker.playerName = UnitName("player")
Clicker.playerLevel = UnitLevel("player")
local addonpath = "Interface\\AddOns\\Clicker\\"
local _G = _G

Clicker.window = {}
Clicker.max_window = 5

function Clicker:BuildOptionsPanel()
    local options = {
        name = "Clicker Options",
        handler = Clicker,
        type = "group",
        args = {
            titleText = {
				type = "description",
				fontSize = "large",
				order = 1,
				name = "                             |c" .. Clicker.db.profile.clickChatColor .. "Clicker: v" .. GetAddOnMetadata("Clicker", "Version"),
            },
            authorText = {
				type = "description",
				fontSize = "medium",
				order = 2,
				name = "|T" .. addonpath .. "Media\\clicker100_trans:100:100:0:20|t |cFFFFFFFFMade by  |cFFC69B6DFatrat|r \n",
			},
            numClicks = {
                type = "description",
                fontSize = "medium",
                order = 3,
                name = function() return ("Total Clicks Recorded: |c" .. Clicker.db.profile.clickChatColor .. "%d"):format(Clicker.db.profile.numClicks) end
            },
            main = {
                name = "General Options",
                type = "group",
                order = 1,
                args = {
                    generalHeader = {
						name = "General Options",
						type = "header",
						width = "full",
						order = 1.0,
					},
                    clickerEnabled = {
                        type = "toggle",
                        name = "Enable Clicker",
                        desc = "Toggle the Clicker addon functions on or off.",
                        order = 1.1,
                        get = function(info) return Clicker.db.profile.clickerEnabled end,
                        set = function(info, value) Clicker.db.profile.clickerEnabled = value end,
                    },
                    toastEnabled = {
                        type = "toggle",
                        name = "Enable Achievement Popup",
                        desc = "Enable to see a Blizzard-style Achievement popup on clicker events!",
                        order = 1.2,
                        get = function(info) return Clicker.db.profile.toastEnabled end,
                        set = function(info, value) Clicker.db.profile.toastEnabled = value end,
                    },
                    toastText = {
                        type = "input",
                        name = "Click Toast Text",
                        desc = "Text the addon will congratulate you with each time a click event happens.",
                        order = 1.3,
                        get = function(info) return Clicker.db.profile.toastText end,
                        set = function(info, value) Clicker.db.profile.toastText = value end,
                    },
                    testClick = {
                        type = "execute",
                        name = "Test Click Sound",
                        desc = "Play a test click sound.",
                        order = 1.4,
                        func = function()
                            if not Clicker.db.profile.muted then 
                                PlaySoundFile(addonpath .."Media\\" .. Clicker.db.profile.volumeLevel .. ".ogg", Clicker.db.profile.soundChannel)
                                print("Clicker test sound played on channel " .. Clicker.db.profile.soundChannel .. ", filename is " .. Clicker.db.profile.volumeLevel)
                            end
                        end,
                    },
                    resetClicks = {
                        type = "execute",
                        name = "Reset Clicks",
                        desc = "Reset the click counter :(",
                        order = 1.5,
                        func = function()
                            Clicker.db.profile.numClicks = 0
                            print("Clicker total clicks reset to 0.")
                        end,
                    },
                    clickChatColor = {
                        type = "input",
                        name = "Click Chat Color",
                        desc = "Enter an 8 digit hex color code here for the Clicker texts. Example: FF36F7BC for a light blue color.",
                        order = 1.6,
                        get = function(info) return Clicker.db.profile.clickChatColor end,
                        set = function(info, value) Clicker.db.profile.clickChatColor = value end,
                    },
                    volumeHeader = {
						name = "Volume Settings",
						type = "header",
						width = "full",
						order = 2.0,
					},
                    muted = {
                        type = "toggle",
                        name = "Mute Clicker Sound",
                        desc = "Enable to mute the clicker sound on events!",
                        order = 2.1,
                        get = function(info) return Clicker.db.profile.muted end,
                        set = function(info, value) Clicker.db.profile.muted = value end,
                    },
                    soundChannel = {
                        type = "select",
                        name = "Sound Channel",
                        desc = "Set the sound channel for the click sound.",
                        order = 2.2,
                        values = {
                            ["Master"] = "Master",
                            ["SFX"] = "SFX",
                            ["Dialog"] = "Dialog",
                        },
                        style = "dropdown",
                        get = function(info) return Clicker.db.profile.soundChannel end,
                        set = function(info, value) Clicker.db.profile.soundChannel = value end,
                    },
                    volumeLevel = {
                        type = "select",
                        name = "Click Sound Volume",
                        desc = "Set the volume of the click sound.",
                        order = 2.3,
                        values = {
                            ["clicker"] = "Default",
                            ["clicker6"] = "+6db",
                            ["clicker12"] = "+12db",
                            ["clicker18"] = "+18db",
                        },
                        style = "dropdown",
                        get = function(info) return Clicker.db.profile.volumeLevel end,
                        set = function(info, value) Clicker.db.profile.volumeLevel = value end,
                    },
                },
            },
        },
    }
    Clicker.optionsFrame = AceConfigDialog:AddToBlizOptions("Clicker_options", "Clicker")
    AceConfig:RegisterOptionsTable("Clicker_options", options, nil)
end

function Clicker:OnInitialize()
    local defaults = {
        profile = {
            clickerEnabled = true,
            toastEnabled = true,
            toastText = "Good Job!",
            clickChatColor = "FFFF73A5",
            muted = false,
            soundChannel = "Master",
            volumeLevel = "Default",
            numClicks = 0,
        },
    }
    SLASH_CLICKER1 = "/clicker"
    SlashCmdList["CLICKER"] = function(msg, editbox)
        local command, rest = msg:match("^(%S*)%s*(.-)$")
        command = strlower(command or "")
        rest = strlower(rest or "")

        if command == "test" then
            if not self.db.profile.muted then PlaySoundFile(addonpath .."Media\\" .. self.db.profile.volumeLevel .. ".ogg", self.db.profile.soundChannel)
            print("Clicker test sound played on channel " .. self.db.profile.soundChannel .. ", filename is " .. self.db.profile.volumeLevel)
            end

        elseif command == "test6" then
            if not self.db.profile.muted then PlaySoundFile(addonpath .."Media\\clicker6.ogg", self.db.profile.soundChannel)
            print("Clicker test +6db sound played on the channel " .. self.db.profile.soundChannel)
            end

        elseif command == "test12" then
            if not self.db.profile.muted then PlaySoundFile(addonpath .."Media\\clicker12.ogg", self.db.profile.soundChannel)
            print("Clicker test +12db sound played on the channel " .. self.db.profile.soundChannel)
            end

        elseif command == "test18" then
            if not self.db.profile.muted then PlaySoundFile(addonpath .."Media\\clicker18.ogg", self.db.profile.soundChannel)
            print("Clicker test +18db sound played on the channel " .. self.db.profile.soundChannel)
            end
        elseif command == "resetAll" then
            self.db.profile.clickerEnabled = true
            self.db.profile.toastEnabled = true
            self.db.profile.toastText = "Good Job!"
            self.db.profile.clickChatColor = "FFFF73A5"
            self.db.profile.muted = false
            self.db.profile.soundChannel = "Master"
            self.db.profile.volumeLevel = "Default"
            print("All Clicker settings have been reset to defaults.")

        else
            print("Clicker Addon Commands:")
            print("/clicker test - Play test click sound.")
            print("/clicker test6 - Play test +6db click sound.")
            print("/clicker test12 - Play test +12db click sound.")
            print("/clicker test18 - Play test +18db click sound.")
        end
    end
    self.db = LibStub("AceDB-3.0"):New("ClickerDB", defaults, true)
end

function Clicker:OnEnable()
    Clicker:BuildOptionsPanel()
    for i=1, Clicker.max_window do
        Clicker.window[i] = Clicker:createToastFrame()
        Clicker.window[i]:SetPoint("RIGHT", -350, 0)
    end
end

local kbTracker = CreateFrame("Frame", "KBTracker", UIParent)
local function kbHandler(...)
    local sourceGUID = select(4, ...)
    local subevent = select(2, ...)
    if subevent == "PARTY_KILL" and sourceGUID == Clicker.playerGUID then
        print("Player killed an enemy. Click Time!.")
        if not Clicker.db.profile.muted then PlaySoundFile(addonpath .."Media\\" .. Clicker.db.profile.volumeLevel .. ".ogg", Clicker.db.profile.soundChannel)
        Clicker.db.profile.numClicks = Clicker.db.profile.numClicks + 1
        end
    end
end
kbTracker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
kbTracker:SetScript("OnEvent", kbHandler)


--Magic happens here! Event Listener Frame and functions
local eventListenerFrame = CreateFrame("Frame", "ClickerEventListenerFrame", UIParent)

function Clicker:playClick()
    if not Clicker.db.profile.muted then
        PlaySoundFile(addonpath .."Media\\" .. Clicker.db.profile.volumeLevel .. ".ogg", Clicker.db.profile.soundChannel)
        --print("Clicker test sound played on channel " .. Clicker.db.profile.soundChannel .. ", filename is " .. Clicker.db.profile.volumeLevel)
        Clicker.db.profile.numClicks = Clicker.db.profile.numClicks + 1
        print("|c" .. Clicker.db.profile.clickChatColor .. "Click! " .. Clicker.db.profile.toastText .. " You have clicked " .. Clicker.db.profile.numClicks .. " times.|r")
        --print(Clicker.db.profile.numClicks .. " total clicks recorded.")
    end
end

local function eventHandler(self,event, ...)
    print("Clicker Event Handler triggered for event: " .. event)
    if event == "PLAYER_LEVEL_UP" then
        print("Player has leveled up. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("Level: " .. Clicker.playerLevel, Clicker.playerLevel, addonpath .. "Media\\bone_bw64", nil)
        end
    elseif event == "ACHIEVEMENT_EARNED" then
        print("Player earned an achievement. Click Time!")
        Clicker:playClick()
    elseif event == "NEW_PET_ADDED" then
        print("Player added a new pet to their collection. Click Time!")
        Clicker:playClick()
    elseif event == "ZONE_CHANGED" then
        print("ZONE_CHANGED event detected.")
        print("Player changed zones (debug). Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("Zone Changed!")
            print("Showing toast (debug).")
        end
    end
end
--Register events to watch here
eventListenerFrame:SetScript("OnEvent", eventHandler)
eventListenerFrame:RegisterEvent("PLAYER_LEVEL_UP")
eventListenerFrame:RegisterEvent("ACHIEVEMENT_EARNED")
eventListenerFrame:RegisterEvent("NEW_PET_ADDED")
eventListenerFrame:RegisterEvent("ZONE_CHANGED")

function Clicker:createToastFrame()
    local clickerTF = CreateFrame("Button", "Achievement", UIParent)
    print("Creating Toast Frame")
    clickerTF:SetSize(300, 88)
    clickerTF:SetFrameStrata("DIALOG")
    clickerTF:Hide()

    do --animations
        clickerTF:SetScript("OnShow", function()
           clickerTF.modifyA = 1
           clickerTF.modifyB = 0
           clickerTF.stateA = 0
           clickerTF.stateB = 0
           clickerTF.animate = true
           clickerTF.showTime = GetTime()
        end)

    clickerTF:SetScript("OnUpdate", function()
    if ( clickerTF.tick or 1) > GetTime() then return else clickerTF.tick = GetTime() + .01 end

        if clickerTF.animate == true then
            if clickerTF.stateA > .50 and clickerTF.modifyA == 1 then
                clickerTF.modifyB = 1
            end

            if clickerTF.stateA > .75 then
                clickerTF.modifyA = -1
            end

            if clickerTF.stateB > .50 then
                clickerTF.modifyB = -1
            end

            clickerTF.stateA = clickerTF.stateA + clickerTF.modifyA/50
            clickerTF.stateB = clickerTF.stateB + clickerTF.modifyB/50

            clickerTF.glow:SetGradient("HORIZONTAL",{r=clickerTF.stateA, g=clickerTF.stateA, b=clickerTF.stateA, a=clickerTF.stateA},
                {r=clickerTF.stateB, g=clickerTF.stateB, b=clickerTF.stateB, a=clickerTF.stateB})

            clickerTF.shine:SetGradient("VERTICAL",{r=clickerTF.stateA, g=clickerTF.stateA, b=clickerTF.stateA, a=clickerTF.stateA},
                {r=clickerTF.stateB, g=clickerTF.stateB, b=clickerTF.stateB, a=clickerTF.stateB})

            if clickerTF.stateA < 0 and clickerTF.stateB < 0 then
                clickerTF.animate = false
            end
        end

        if clickerTF.showTime + 10 < GetTime() then
            clickerTF:SetAlpha(clickerTF:GetAlpha() - .05)
            if clickerTF:GetAlpha() <= .05 then
                clickerTF:Hide()
                clickerTF:SetAlpha(1)
            end
        end
    end)

        clickerTF.background = clickerTF:CreateTexture("background", "BACKGROUND")
        clickerTF.background:SetTexture(addonpath .. "Media\\ui-achievement-alert-background")
        clickerTF.background:SetPoint("TOPLEFT", 0, 0)
        clickerTF.background:SetPoint("BOTTOMRIGHT", 0, 0)
        clickerTF.background:SetTexCoord(0, .605, 0, .703)

        clickerTF.toastGreet = clickerTF:CreateFontString("Unlocked", "OVERLAY", "GameFontBlack")
        clickerTF.toastGreet:SetSize(200, 12)
        clickerTF.toastGreet:SetPoint("TOP", 7, -23)
        clickerTF.toastGreet:SetFont(addonpath .. "Media\\PB-JyRM.ttf", 16, "OUTLINE")

        clickerTF.name = clickerTF:CreateFontString("Name", "OVERLAY", "GameFontHighlight")
        clickerTF.name:SetSize(240, 16)
        clickerTF.name:SetPoint("BOTTOMLEFT", 72, 36)
        clickerTF.name:SetPoint("BOTTOMRIGHT", -60, 36)
        clickerTF.name:SetFont(addonpath .. "Media\\PB-JyRM.ttf", 16, "")

        clickerTF.glow = clickerTF:CreateTexture("glow", "OVERLAY")
        clickerTF.glow:SetTexture(addonpath .. "Media\\ui-achievement-alert-glow")
        clickerTF.glow:SetBlendMode("ADD")
        clickerTF.glow:SetWidth(400)
        clickerTF.glow:SetHeight(171)
        clickerTF.glow:SetPoint("CENTER", 0, 0)
        clickerTF.glow:SetTexCoord(0, 0.78125, 0, 0.66796875)
        clickerTF.glow:SetAlpha(0)

        clickerTF.shine = clickerTF:CreateTexture("shine", "OVERLAY")
        clickerTF.shine:SetBlendMode("ADD")
        clickerTF.shine:SetTexture(addonpath .. "Media\\ui-achievement-alert-glow")
        clickerTF.shine:SetWidth(67)
        clickerTF.shine:SetHeight(72)
        clickerTF.shine:SetPoint("BOTTOMLEFT", 0, 8)
        clickerTF.shine:SetTexCoord(0.78125, 0.912109375, 0, 0.28125)
        clickerTF.shine:SetAlpha(0)

        clickerTF.icon = CreateFrame("Frame", "icon", clickerTF)
        clickerTF.icon:SetWidth(128)
        clickerTF.icon:SetHeight(128)
        clickerTF.icon:SetPoint("TOPLEFT", -26, 16)

        clickerTF.icon.texture = clickerTF.icon:CreateTexture("texture", "ARTWORK")
        clickerTF.icon.texture:SetPoint("CENTER", 0, 3)
        clickerTF.icon.texture:SetWidth(40)
        clickerTF.icon.texture:SetHeight(40)
        
        clickerTF.icon.backfill = clickerTF.icon:CreateTexture("backfill", "BACKGROUND")
        clickerTF.icon.backfill:SetBlendMode("ADD")
        clickerTF.icon.backfill:SetTexture(addonpath .. "Media\\ui-achievement-iconframe-backfill")
        clickerTF.icon.backfill:SetPoint("CENTER", 0, 0)
        clickerTF.icon.backfill:SetWidth(64)
        clickerTF.icon.backfill:SetHeight(64)

        clickerTF.icon.overlay = clickerTF.icon:CreateTexture("overlay", "OVERLAY")
        clickerTF.icon.overlay:SetTexture(addonpath .. "Media\\ui-achievement-iconframe")
        clickerTF.icon.overlay:SetPoint("CENTER", -1, 2)
        clickerTF.icon.overlay:SetHeight(72)
        clickerTF.icon.overlay:SetWidth(72)
        clickerTF.icon.overlay:SetTexCoord(0, 0.5625, 0, 0.5625)

        return clickerTF
    end
end

function Clicker:showToast(text)
    print("Entered showToast")
    for i=1, Clicker.max_window do
        if not Clicker.window[i]:IsVisible() then
            Clicker.window[i].toastGreet:SetText("|c" .. Clicker.db.profile.clickChatColor .. Clicker.db.profile.toastText .. "|r")
            Clicker.window[i].name:SetText("|c" .. Clicker.db.profile.clickChatColor .. text .. "|r")

            Clicker.window[i]:Show()
            print("Showing Toast Frame")
            return
        end
    end
end