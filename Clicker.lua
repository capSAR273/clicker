-- /dump select(4, GetBuildInfo()) use to get updated toc interface version number
--Load Ace3
Clicker = LibStub("AceAddon-3.0"):NewAddon("Clicker", "AceConsole-3.0", "AceTimer-3.0", "AceComm-3.0", "AceEvent-3.0")
AceConfig = LibStub("AceConfig-3.0")
AceConfigDialog = LibStub("AceConfigDialog-3.0")

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
Clicker.playerGUID = UnitGUID("player")
Clicker.playerName = UnitName("player")
local addonpath = "Interface\\AddOns\\Clicker\\"
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
                        name = "Enable Greeting Toast",
                        desc = "Enable to see a greeting toast on clicker events!",
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
    print("Clicker Options Panel Built")
    AceConfig:RegisterOptionsTable("Clicker_options", options, nil)
    print("Clicker Options Registered")
end

function Clicker:OnInitialize()
    print("clicker OnInitialize ran")
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

        if command == "resetClicks" then
            self.db.profile.numClicks = 0
            print("Clicker total clicks reset to 0.")

        elseif command == "test" then
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
local function kbHandler(self, ...)
    local sourceGUID = select(4, ...)
    local subevent = select(2, ...)
    if subevent == "PARTY_KILL" and sourceGUID == Clicker.playerGUID then
        print("Player killed an enemy. Click Time!.")
        if not self.db.profile.muted then PlaySoundFile(addonpath .."Media\\" .. self.db.profile.volumeLevel .. ".ogg", self.db.profile.soundChannel)
        self.db.profile.numClicks = self.db.profile.numClicks + 1
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

local function eventHandler(self, event, ...)
    if event == "PLAYER_LEVEL_UP" then
        if not Clicker.db.profile.muted then
            print("Player has leveled up. Click Time!")
            Clicker:playClick()
        end
    elseif event == "ACHIEVEMENT_EARNED" then
        if not Clicker.db.profile.muted then
            print("Player earned an achievement. Click Time!")
            Clicker:playClick()
        end
    elseif event == "NEW_PET_ADDED" then
        if not Clicker.db.profile.muted then
            print("Player added a new pet to their collection. Click Time!")
            Clicker:playClick()
        end
    elseif event == "ZONE_CHANGED" then
        if not Clicker.db.profile.muted then
            print("Player changed zones (debug). Click Time!")
            Clicker:playClick()
        end
    end
end
eventListenerFrame:SetScript("OnEvent", eventHandler)
eventListenerFrame:RegisterEvent("PLAYER_LEVEL_UP")
eventListenerFrame:RegisterEvent("ACHIEVEMENT_EARNED")
eventListenerFrame:RegisterEvent("NEW_PET_ADDED")
eventListenerFrame:RegisterEvent("ZONE_CHANGED")

function Clicker:showToast()
    local clickerToastFrame = CreateFrame("Button", "Achievement", UIParent)
    clickerToastFrame:SetSize(300, 88)
    clickerToastFrame:SetFrameStrata("DIALOG")
    clickerToastFrame:Hide()

    do --animations
        clickerToastFrame:SetScript("OnShow", function()
           this.modifyA = 1
           this.modifyB = 0
           this.stateA = 0
           this.stateB = 0
           this.animate = true

           this.showTime = GetTime()
        end)

        clickerToastFrame:SetScript("OnUpdate", function()
           if ( this.animate ) then
              local elapsed = GetTime() - this.showTime

              if ( this.stateA == 0 ) then
                 this.modifyA = this.modifyA - 0.05
                 if ( this.modifyA <= 0 ) then
                    this.modifyA = 0
                    this.stateA = 1
                    this.showTime = GetTime()
                 end
                 this:SetAlpha( 1 - this.modifyA )
              elseif ( this.stateA == 1 ) then
                 if ( elapsed >= 3 ) then
                    this.stateA = 2
                 end
              elseif ( this.stateA == 2 ) then
                 this.modifyA = this.modifyA + 0.05
                 if ( this.modifyA >= 1 ) then
                    this.modifyA = 1
                    this.animate = false
                    this:Hide()
                 end
                 this:SetAlpha( 1 - this.modifyA )
              end
           end
        end)    

        clickerToastFrame.background = clickerToastFrame:CreateTexture("background", "BACKGROUND")
        clickerToastFrame.background:SetTexture(addonpath .. "Media\\ui-achievement-alert-background")
        clickerToastFrame.background:SetPoint("TOPLEFT", 0, 0)
        clickerToastFrame.background:SetPoint("BOTTOMRIGHT", 0, 0)
        clickerToastFrame.background:SetTexCoord(0, .605, 0, .703)

        clickerToastFrame.unlocked = clickerToastFrame:CreateFontString("Unlocked", "OVERLAY", Clicker.db.profile.clickChatColor)
        clickerToastFrame.unlocked:SetPoint("LEFT", clickerToastFrame, "LEFT", 60, 15)
        clickerToastFrame.unlocked:SetFont(addonpath .. "Media\\PB-JyRM.ttf", 16, "OUTLINE")
        clickerToastFrame.unlocked:SetText(Clicker.db.profile.toastText)


    if Clicker.db.profile.toastEnabled then
        C_Timer.After(0.5, function()
            --print("Showing Clicker Toast")
            local toast = C_Toast.New( {
                text = Clicker.db.profile.toastText,
                icon = addonpath .. "Media\\ui-achievement-alert-icon"