-- /dump select(4, GetBuildInfo()) use to get updated toc interface version number
--Load Ace3
Clicker = LibStub("AceAddon-3.0"):NewAddon("Clicker", "AceConsole-3.0", "AceTimer-3.0", "AceComm-3.0", "AceEvent-3.0")
AceConfig = LibStub("AceConfig-3.0")
AceConfigDialog = LibStub("AceConfigDialog-3.0")

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
Clicker.playerGUID = UnitGUID("player")
Clicker.playerName = UnitName("player")

local _G = _G
print ("Clicker Loaded Successfully")

function Clicker:BuildOptionsPanel()
    print("Building Clicker Options Panel")
    local options = {
        name = "Clicker Options",
        handler = Clicker,
        type = "group",
        args = {
            titleText = {
				type = "description",
				fontSize = "large",
				order = 1,
				name = "                             |cFF36F7BC" .. "Clicker: v" .. GetAddOnMetadata("Clicker", "Version"),
            },
            authorText = {
				type = "description",
				fontSize = "medium",
				order = 2,
				name = "|TInterface\\AddOns\\Clicker\\Media\\clicker100_trans:100:100:0:20|t |cFFFFFFFFMade by  |cFFC41E3ARatrampage-Nazgrim|r \n",
			},
            spacer = {
                type = "description",
                fontSize = "large",
                order = 3,
                name = " ",
            },
            numClicks = {
                type = "description",
                fontSize = "medium",
                order = 4,
                name = "Total Clicks Recorded: |cFF36F7BC" .. self.db.profile.numClicks .. "|r \n",
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
                        get = function(info) return self.db.profile.clickerEnabled end,
                        set = function(info, value) self.db.profile.clickerEnabled = value end,
                    },
                    toastEnabled = {
                        type = "toggle",
                        name = "Enable Greeting Toast",
                        desc = "Enable to see a greeting toast on clicker events!",
                        order = 1.2,
                        get = function(info) return self.db.profile.toastEnabled end,
                        set = function(info, value) self.db.profile.toastEnabled = value end,
                    },
                    toastText = {
                        type = "input",
                        name = "Label Text",
                        desc = "Text the addon will congratulate you with each time a click event happens.",
                        order = 1.3,
                        get = function(info) return self.db.profile.toastText end,
                        set = function(info, value) self.db.profile.toastText = value end,
                    },
                    testClick = {
                        type = "execute",
                        name = "Test Click Sound",
                        desc = "Play a test click sound.",
                        order = 1.4,
                        func = function()
                            if not self.db.profile.muted then 
                                PlaySoundFile("Interface\\AddOns\\Clicker\\Media\\" .. self.db.profile.volumeLevel .. ".ogg", self.db.profile.soundChannel)
                                print("Clicker test sound played on channel " .. self.db.profile.soundChannel .. ", filename is " .. self.db.profile.volumeLevel)
                            end
                        end,
                    },
                    resetClicks = {
                        type = "execute",
                        name = "Reset Clicks",
                        desc = "Reset the click counter :(",
                        order = 1.5,
                        func = function()
                            self.db.profile.numClicks = 0
                            print("Clicker total clicks reset to 0.")
                        end,
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
                        get = function(info) return self.db.profile.muted end,
                        set = function(info, value) self.db.profile.muted = value end,
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
                        get = function(info) return self.db.profile.soundChannel end,
                        set = function(info, value) self.db.profile.soundChannel = value end,
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
                        get = function(info) return self.db.profile.volumeLevel end,
                        set = function(info, value) self.db.profile.volumeLevel = value end,
                    },
                },
            },
        },
    }
    Clicker.optionsFrame = AceConfigDialog:AddToBlizOptions("Clicker_options", "Clicker")
    print("Clicker Options Panel Built")
    AceConfig:RegisterOptionsTable("Clicker_options", options, nil)
    print("Clicker Options Registered")
    print(self.db.profile.muted)
end

function Clicker:OnInitialize()
    print("clicker OnInitialize ran")
    local defaults = {
        profile = {
            clickerEnabled = true,
            toastEnabled = true,
            toastText = "Good Job!",
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

        if command == "resetClicks" then
            self.db.profile.numClicks = 0
            print("Clicker total clicks reset to 0.")

        elseif command == "test" then
            if not self.db.profile.muted then PlaySoundFile("Interface\\AddOns\\Clicker\\Media\\" .. self.db.profile.volumeLevel .. ".ogg", self.db.profile.soundChannel)
            print("Clicker test sound played on channel " .. self.db.profile.soundChannel .. ", filename is " .. self.db.profile.volumeLevel)
            end

        elseif command == "test6" then
            if not self.db.profile.muted then PlaySoundFile("Interface\\AddOns\\Clicker\\Media\\clicker6.ogg", self.db.profile.soundChannel)
            print("Clicker test +6db sound played on the channel " .. self.db.profile.soundChannel)
            end

        elseif command == "test12" then
            if not self.db.profile.muted then PlaySoundFile("Interface\\AddOns\\Clicker\\Media\\clicker12.ogg", self.db.profile.soundChannel)
            print("Clicker test +12db sound played on the channel " .. self.db.profile.soundChannel)
            end

        elseif command == "test18" then
            if not self.db.profile.muted then PlaySoundFile("Interface\\AddOns\\Clicker\\Media\\clicker18.ogg", self.db.profile.soundChannel)
            print("Clicker test +18db sound played on the channel " .. self.db.profile.soundChannel)
            end

        else
            print("Clicker Addon Commands:")
            print("/clicker resetClicks - Reset total click count to 0 :(")
            print("/clicker test - Play test click sound.")
            print("/clicker test6 - Play test +6db click sound.")
            print("/clicker test12 - Play test +12db click sound.")
            print("/clicker test18 - Play test +18db click sound.")
        end
    end
    self.db = LibStub("AceDB-3.0"):New("ClickerDB", defaults, true)
    print("ClickerDB initialized.")
end

function Clicker:OnEnable()
    Clicker:BuildOptionsPanel()
end

local kbTracker = CreateFrame("Frame", "KBTracker", UIParent)
local function kbHandler(self, event, subevent, ...)
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags
    if subevent == "PARTY_KILL" and sourceGUID == Clicker.playerGUID then
        print("Player killed an enemy. Click Time!.")
        if not self.db.profile.muted then PlaySoundFile("Interface\\AddOns\\Clicker\\Media\\" .. self.db.profile.volumeLevel .. ".ogg", self.db.profile.soundChannel)
        self.db.profile.numClicks = self.db.profile.numClicks + 1
        end
    end
end
kbTracker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
kbTracker:SetScript("OnEvent", kbHandler)


--Magic happens here! Event Listener Frame and functions
local eventListenerFrame = CreateFrame("Frame", "ClickerEventListenerFrame", UIParent)

local function playClick(self)
    print("Calling playClick function")
    if not self.db.profile.muted then
        PlaySoundFile("Interface\\AddOns\\Clicker\\Media\\" .. self.db.profile.volumeLevel .. ".ogg", self.db.profile.soundChannel)
        print("Played Sound")
        print("Clicker test sound played on channel " .. self.db.profile.soundChannel .. ", filename is " .. self.db.profile.volumeLevel)
        self.db.profile.numClicks = self.db.profile.numClicks + 1
        print("Incremented numClicks to " .. self.db.profile.numClicks)
    end
end

local function eventHandler(self, event, ...)
    if event == "PLAYER_LEVEL_UP" then
        print("Player has leveled up. Click Time!.")
        if not self.db.profile.muted then
            playClick(self)
            print("Clicker test sound played on channel " .. self.db.profile.soundChannel .. ", filename is " .. self.db.profile.volumeLevel)
            self.db.profile.numClicks = self.db.profile.numClicks + 1
        end
    elseif event == "ACHIEVEMENT_EARNED" then
        print("Player earned an achievement. Click Time!.")
        if not self.db.profile.muted then
            playClick(self)
            print("Clicker test sound played on channel " .. self.db.profile.soundChannel .. ", filename is " .. self.db.profile.volumeLevel)
            self.db.profile.numClicks = self.db.profile.numClicks + 1
        end
    elseif event == "NEW_PET_ADDED" then
        print("Player added a new pet to their collection. Click Time!.")
        if not self.db.profile.muted then
            playClick(self)            
            print("Clicker test sound played on channel " .. self.db.profile.soundChannel .. ", filename is " .. self.db.profile.volumeLevel)
            self.db.profile.numClicks = self.db.profile.numClicks + 1
        end
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        print("Player moused over a unit (debug). Click Time!.")
        playClick(self) 
        print("Clicker test sound played on channel " .. self.db.profile.soundChannel .. ", filename is " .. self.db.profile.volumeLevel)
        self.db.profile.numClicks = self.db.profile.numClicks + 1
    elseif event == "ZONE_CHANGED" then
        print("Player changed zones (debug). Click Time!.")
        if not self.db.profile.muted then
            print("Inside ZONE_CHANGED event handler")
            playClick(self)
            print("Clicker test sound played on channel " .. self.db.profile.soundChannel .. ", filename is " .. self.db.profile.volumeLevel)
            self.db.profile.numClicks = self.db.profile.numClicks + 1
        end
        print("Failed the if statement on zone change")
    end
end
eventListenerFrame:SetScript("OnEvent", eventHandler)
eventListenerFrame:RegisterEvent("PLAYER_LEVEL_UP")
eventListenerFrame:RegisterEvent("ACHIEVEMENT_EARNED")
eventListenerFrame:RegisterEvent("NEW_PET_ADDED")
eventListenerFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
eventListenerFrame:RegisterEvent("ZONE_CHANGED")
