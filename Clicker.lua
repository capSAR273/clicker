-- /dump select(4, GetBuildInfo()) use to get updated toc interface version number
--Load Ace3
Clicker = LibStub("AceAddon-3.0"):NewAddon("Clicker", "AceConsole-3.0", "AceTimer-3.0", "AceComm-3.0", "AceEvent-3.0")
AceConfig = LibStub("AceConfig-3.0")
AceConfigDialog = LibStub("AceConfigDialog-3.0")
local defaults = {}

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata
Clicker.playerGUID = UnitGUID("player")
Clicker.playerName = UnitName("player")
Clicker.playerLevel = UnitLevel("player")
local addonpath = "Interface\\AddOns\\Clicker\\"
local _G = _G

Clicker.window = {}
Clicker.max_window = 5
Lwin = LibStub("LibWindow-1.1")

function Clicker:BuildOptionsPanel()
    Clicker:updateColorCode()
    local options = {
        name = "Clicker Addon Configuration",
        handler = Clicker,
        type = "group",
        args = {
            titleText = {
				type = "description",
				fontSize = "large",
				order = 1,
				name = function() return "                             |c" .. Clicker.db.profile.clickChatHex .. "Clicker: v" .. GetAddOnMetadata("Clicker", "Version") end,
            },
            authorText = {
				type = "description",
				fontSize = "medium",
				order = 2,
				name = "|T" .. addonpath .. "Media\\clicker100_trans:100:100:0:20|t |cFFFFFFFFMade by  |cFFC69B6DStellarField|r \n",
			},
            numClicks = {
                type = "description",
                fontSize = "medium",
                order = 3,
                name = function() return ("Total Clicks Recorded: |c" .. Clicker.db.profile.clickChatHex .. "%d"):format(Clicker.db.profile.numClicks) end
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
                    toastEnabled = {
                        type = "toggle",
                        name = "Enable Event Popup",
                        desc = "Enable to see a Blizzard-style Achievement popup on clicker events!",
                        order = 1.1,
                        get = function(info) return Clicker.db.profile.toastEnabled end,
                        set = function(info, value) Clicker.db.profile.toastEnabled = value end,
                    },
                    toastText = {
                        type = "input",
                        name = "Click Toast Text",
                        desc = "Text the addon will congratulate you with each time a click event happens.",
                        order = 1.2,
                        get = function(info) return Clicker.db.profile.toastText end,
                        set = function(info, value) Clicker.db.profile.toastText = value end,
                    },
                    testClick = {
                        type = "execute",
                        name = "Test Click Sound",
                        desc = "Play a test click sound.",
                        order = 1.3,
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
                        order = 1.4,
                        func = function()
                            Clicker.db.profile.numClicks = 0
                            print("Clicker total clicks reset to 0.")
                        end,
                    },
                    clickChatColor = {
                        type = "color",
                        name = "Click Chat Color",
                        desc = "Click the swatch to set the color of the Clicker chat messages.",
                        order = 1.5,
                        hasAlpha = true,
                        get = function()
                            local color = Clicker.db.profile.clickChatColor
                            return color.r, color.g, color.b, color.a
                        end,
                        set = function(_,r,g,b,a)
                            Clicker.db.profile.clickChatColor = {r = r, g = g, b = b, a = a}
                            Clicker:updateColorCode()
                        end,
                    },
                    secretSetting = {
                        type = "toggle",
                        name = "Enable Secret?",
                        desc = "A mysterious setting that does nothing... or does it?",
                        order = 1.6,
                        get = function(info) return Clicker.db.profile.secret end,
                        set = function(info, value) Clicker.db.profile.secret = value end,
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
                            ["clicker12"] = "+12db",
                            ["clicker18"] = "+18db",
                            ["clicker6"] = "+6db",
                        },
                        style = "dropdown",
                        get = function(info) return Clicker.db.profile.volumeLevel end,
                        set = function(info, value) Clicker.db.profile.volumeLevel = value end,
                    },
                },
            },
            events={
                name = "Event Options",
                type = "group",
                order = 2,
                args = {
                    eventsHeader = {
						name = "Event Options",
						type = "header",
						width = "full",
						order = 2.0,
					},
                    enabledEvents = {
                        type = "multiselect",
                        name = "Event Selection",
                        desc = "Which events do you want to receive clicks for?",
                        hidden = function() return not (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC or WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC) end,
                        order = 2.1,
                        values = {
                            levelUpEnabled = "Level Up",
                            questCompleteEnabled = "Quest Complete",
                            pvpKillEnabled = "PvP Kill",
                        },
                        get = function(info, key) return Clicker.db.profile.eventsEnabled[key] end,
                        set = function(info, key, value) Clicker.db.profile.eventsEnabled[key] = value end,
                    },
                    enabledMistsEvents = {
                        type = "multiselect",
                        name = "MoP Event Selection",
                        desc = "Which events do you want to receive clicks for?",
                        hidden = function() return not (WOW_PROJECT_ID == 19) end,
                        order = 2.1,
                        values = {
                            newCMEnabled = "New Challenge Mode",
                            newCMRecordEnabled = "New Challenge Mode Record",                            
                        },
                        get = function(info, key) return Clicker.db.profile.eventsEnabled[key] end,
                        set = function(info, key, value) Clicker.db.profile.eventsEnabled[key] = value end,
                    },
                    enabledMainlineEvents = {
                        type = "multiselect",
                        name = "Retail Event Selection",
                        desc = "Which events do you want to receive clicks for?",
                        hidden = function() return not (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) end,
                        order = 2.1,
                        values = {
                            newHousingItemEnabled = "New Housing Item Unlocked",
                            mPlusWkRecordEnabled = "Mythic+ Weekly Record",
                            newHouseLvlEnabled = "New House Level Unlocked",
                        },
                        get = function(info, key) return Clicker.db.profile.eventsEnabled[key] end,
                        set = function(info, key, value) Clicker.db.profile.eventsEnabled[key] = value end,
                    },
                    enabledMistsMainlineEvents = {
                        type = "multiselect",
                        name = "Other Event Selection",
                        desc = "Which events do you want to receive clicks for?",
                        hidden = function() return not (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE or WOW_PROJECT_ID == 19) end,
                        order = 2.1,
                        values = {
                            achievementEnabled = "Achievement Unlocked",
                            newPetEnabled = "New Pet Unlocked",
                            newToyEnabled = "New Toy Unlocked",
                            bMarketWinEnabled = "BMAH Item Won",
                            newMountEnabled = "New Mount Unlocked",
                            newAppearanceEnabled = "New Appearance Unlocked",
                        },
                        get = function(info, key) return Clicker.db.profile.eventsEnabled[key] end,
                        set = function(info, key, value) Clicker.db.profile.eventsEnabled[key] = value end,
                    }
                }
            },
            easterEgg = {
                name = "Secret Options",
                type = "group",
                order = 3,
                hidden = function() return not Clicker.db.profile.secret end,
                args = {
                    secretHeader = {
                        name = "Secret Options",
						type = "header",
						width = "full",
						order = 3.0,
                    },
                    validChatChannels = {
                        type = "multiselect",
                        name = "Allowed Chat Channels",
                        desc = "Which chat channels allow modified speech?",
                        order = 3.1,
                        values = {
                            say = "Say",
                            yell = "Yell",
                            party = "Party",
                            raid = "Raid",
                            guild = "Guild",
                            officer = "Officer",
                            whisper = "Whisper",
                        },
                        get = function(info, key) return Clicker.db.profile.speakChannels[key] end,
                        set = function(info, key, value) Clicker.db.profile.speakChannels[key] = value end,
                    },
                }
            }
        }
    }
    Clicker.optionsFrame = AceConfigDialog:AddToBlizOptions("Clicker_options", "Clicker")
    AceConfig:RegisterOptionsTable("Clicker_options", options, nil)
end

function Clicker:OnInitialize()
    defaults = {
        profile = {
            clickerEnabled = true,
            toastEnabled = true,
            toastText = "Good Job!",
            clickChatColor = {r = 1.0, g = 0.45, b = 0.65, a = 1.0},
            clickChatHex = "FFFF73A5",
            muted = false,
            soundChannel = "Master",
            volumeLevel = "clicker",
            numClicks = 0,
            secret = false,
            eventsEnabled = {
                levelUpEnabled = true,
                achievementEnabled = true,
                newPetEnabled = true,
                questCompleteEnabled = true,
                newHouseLvlEnabled = true,
                newMountEnabled = true,
                newHousingItemEnabled = true,
                newToyEnabled = true,
                bMarketWinEnabled = true,
                mPlusWkRecordEnabled = true,
                newCMEnabled = true,
                newCMRecordEnabled = true,
                newAppearanceEnabled = true,
                pvpKillEnabled = true,
            },
            speakChannels = {
                say = false,
                yell = false,
                party = false,
                raid = false,
                guild = false,
                officer = false,
                whisper = false,
            },
            debug=false,
        },
    }
end

function Clicker:updateColorCode()
    Clicker.db.profile.clickChatHex = CreateColor(Clicker.db.profile.clickChatColor.r, 
                            Clicker.db.profile.clickChatColor.g, 
                            Clicker.db.profile.clickChatColor.b, 
                            Clicker.db.profile.clickChatColor.a):GenerateHexColor()
end

function Clicker:regCommands(mFrame)
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
            self.db.profile.clickChatColor = {r = 1.0, g = 0.45, b = 0.65, a = 1.0}
            self.db.profile.muted = false
            self.db.profile.soundChannel = "Master"
            self.db.profile.volumeLevel = "Default"
            print("All Clicker settings have been reset to defaults.")
        elseif command == "secret" then
            self.db.profile.secret = not self.db.profile.secret
            if not self.db.profile.secret then
                print("Your normal speech is magically restored!")
            elseif self.db.profile.secret then
                print("You found the easter egg! Your speech has been enhanced!")
            end
        elseif command == "move" then
            if mFrame:GetAlpha() == 1 then
                mFrame:SetAlpha(0)
                print("Clicker popup mover hidden.")
            else
                mFrame:SetAlpha(1)
                print("Clicker popup mover shown. Drag it to reposition the popup location.")
            end
        elseif command == "debug" then
            self.db.profile.debug = not self.db.profile.debug
            if self.db.profile.debug then
                print("Clicker debug mode enabled.")
            else
                print("Clicker debug mode disabled.")
            end
        else
            print("Clicker Addon Commands:")
            print("/clicker test - Play test click sound.")
            print("/clicker test6 - Play test +6db click sound.")
            print("/clicker test12 - Play test +12db click sound.")
            print("/clicker test18 - Play test +18db click sound.")
            print("/clicker resetAll - Reset all Clicker settings to defaults.")
            print("/clicker secret - ???");
        end
    end
end

function Clicker:createMoveFrame()
    local moveFrame = CreateFrame("Frame", "ClickerMoveFrame", UIParent, "BackdropTemplate")
    moveFrame:SetSize(300, 500)
    moveFrame:SetPoint("CENTER")
    moveFrame:SetBackdrop(BACKDROP_TUTORIAL_16_16)
    moveFrame.title = moveFrame:CreateFontString(nil, "OVERLAY")
    moveFrame.title:SetFontObject("GameFontHighlight")
    moveFrame.title:SetPoint("TOP", moveFrame, "CENTER", 0, 0)
    moveFrame.title:SetText("Clicker Popup Mover")
    moveFrame:SetAlpha(0)
    Lwin.RegisterConfig(moveFrame, Clicker.db.profile)
    Lwin.MakeDraggable(moveFrame)
    Lwin.EnableMouseOnAlt(moveFrame)
    Lwin.RestorePosition(moveFrame)
    return moveFrame
end

function Clicker:OnEnable()
    self.db = LibStub("AceDB-3.0"):New("ClickerDB", defaults, true)
    Clicker:BuildOptionsPanel()
    local mFrame = Clicker:createMoveFrame()
    for i=1, Clicker.max_window do
        Clicker.window[i] = Clicker:createToastFrame(mFrame)
        Clicker.window[i]:SetPoint("BOTTOM", 0, -100 + (100*i))
    end
    Clicker:updateColorCode()
    Clicker:regCommands(mFrame)
    Lwin.RestorePosition(mFrame)
    Clicker:registerEvents()
end

local kbTracker = CreateFrame("Frame", "KBTracker", UIParent)
local function kbHandler(...)
    local sourceGUID = select(4, ...)
    local subevent = select(2, ...)
    if subevent == "PARTY_KILL" and sourceGUID == Clicker.playerGUID and Clicker.db.profile.eventsEnabled.pvpKillEnabled then
        print("Player killed an enemy. Click Time!.")
        Clicker:playClick()
    end
end
kbTracker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
kbTracker:SetScript("OnEvent", kbHandler)


--Magic happens here! Event Listener Frame and functions
local eventListenerFrame = CreateFrame("Frame", "ClickerEventListenerFrame", UIParent)

function Clicker:playClick()
    if not Clicker.db.profile.muted and Clicker.db.profile.clickerEnabled then
        PlaySoundFile(addonpath .."Media\\" .. Clicker.db.profile.volumeLevel .. ".ogg", Clicker.db.profile.soundChannel)
        Clicker.db.profile.numClicks = Clicker.db.profile.numClicks + 1
        print("|c" .. Clicker.db.profile.clickChatHex .. "Click! " .. Clicker.db.profile.toastText .. " You have clicked " .. Clicker.db.profile.numClicks .. " times.|r")
    end
end

local randEvents = {
    "Level Up! Woohoo!",
    "Fresh Achievement!",
    "New Pet Added!",
    "Quest Complete!",
    "House Level Increased!",
    "New Mount Unlocked!",
    "New Housing Item!",
    "New Toy Added!",
    "BMAH Bid Won!",
    "New M+ Record!",
    "New Appearance!"
}

local function pickRandEvent()
    return randEvents[math.random(#randEvents)]
end

local function eventHandler(self,event, ...)
    if event == "PLAYER_LEVEL_UP" and Clicker.db.profile.eventsEnabled.levelUp then
        print("(debug) Player has leveled up. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("Level Up! Woohoo!")
        end
    elseif event == "ACHIEVEMENT_EARNED" and Clicker.db.profile.eventsEnabled.achievementEnabled then
        print("(debug) Player earned an achievement. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("Achievement Unlocked!")
        end
    elseif event == "NEW_PET_ADDED" and Clicker.db.profile.eventsEnabled.newPetEnabled then
        print("(debug) Player added a new pet to their collection. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("New Pet Added!")
        end
    elseif event == "ZONE_CHANGED" and Clicker.db.profile.debug then
        print("(debug) Player changed zones. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast(pickRandEvent())
        end
    elseif event == "QUEST_TURNED_IN" and Clicker.db.profile.eventsEnabled.questCompleteEnabled then
        print("(debug) Player completed a quest. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("Quest Complete!")
        end
    elseif event == "HOUSE_LEVEL_CHANGED" and Clicker.db.profile.eventsEnabled.newHouseLvlEnabled then
        print("(debug) Player increased house level. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("House Level Up!")
        end
    elseif event == "NEW_MOUNT_ADDED" and Clicker.db.profile.eventsEnabled.newMountEnabled then
        print("(debug) Player added a new mount. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("New Mount Unlocked!")
        end
    elseif event == "NEW_HOUSING_ITEM_ACQUIRED" and Clicker.db.profile.eventsEnabled.newHousingItemEnabled then
        print("(debug) Player acquired a new housing item. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("New Housing Item!")
        end
    elseif event == "NEW_TOY_ADDED" and Clicker.db.profile.eventsEnabled.newToyEnabled then
        print("(debug) Player acquired a new toy. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("New Toy Added!")
        end
    elseif event == "BLACK_MARKET_WON" and Clicker.db.profile.eventsEnabled.bMarketWinEnabled then
        print("(debug) Player won a BMAH bid. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("BMAH Bid Won!")
        end
    elseif event == "MYTHIC_PLUS_NEW_WEEKLY_RECORD" and Clicker.db.profile.eventsEnabled.mPlusWkRecordEnabled then
        print("(debug) Player set a new weekly Mythic+ record. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("New M+ Record!")
        end
    elseif event == "TRANSMOG_COLLECTION_SOURCE_ADDED" and Clicker.db.profile.eventsEnabled.newAppearanceEnabled then
        print("(debug) Player added a new transmog source. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("New Appearance!")
        end
    elseif event == "CHALLENGE_MODE_COMPLETED" and Clicker.db.profile.eventsEnabled.newCMEnabled then
        print("(debug) Player completed a challenge mode. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("CM Complete!")
        end
    elseif event == "CHALLENGE_MODE_NEW_RECORD" and Clicker.db.profile.eventsEnabled.newCMRecordEnabled then
        print("(debug) Player set a new challenge mode record. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("New CM Record!")
        end
    end
end

function Clicker:registerEvents()
    --Events that fit all versions
    eventListenerFrame:SetScript("OnEvent", eventHandler)
    eventListenerFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    eventListenerFrame:RegisterEvent("PLAYER_LEVEL_UP")
    eventListenerFrame:RegisterEvent("ZONE_CHANGED")
    eventListenerFrame:RegisterEvent("QUEST_TURNED_IN")
    --Mists unique events
    if WOW_PROJECT_ID == 19 then
        eventListenerFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
        eventListenerFrame:RegisterEvent("CHALLENGE_MODE_NEW_RECORD")
    end

    --Retail unique events
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        eventListenerFrame:RegisterEvent("HOUSE_LEVEL_CHANGED")
        eventListenerFrame:RegisterEvent("NEW_HOUSING_ITEM_ACQUIRED")
        eventListenerFrame:RegisterEvent("MYTHIC_PLUS_NEW_WEEKLY_RECORD")
    end

    --Retail or Mists events
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE or WOW_PROJECT_ID == 19 then
        eventListenerFrame:RegisterEvent("NEW_MOUNT_ADDED")
        eventListenerFrame:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED")
        eventListenerFrame:RegisterEvent("NEW_TOY_ADDED")
        eventListenerFrame:RegisterEvent("BLACK_MARKET_WON")
        eventListenerFrame:RegisterEvent("ACHIEVEMENT_EARNED")
        eventListenerFrame:RegisterEvent("NEW_PET_ADDED")
    end
end


function Clicker:createToastFrame(mFrame)
    local clickerTF = CreateFrame("Button", "Achievement", mFrame)
    clickerTF:SetSize(300, 88)
    clickerTF:SetFrameStrata("DIALOG")
    clickerTF:SetIgnoreParentAlpha(true)
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
        --Time to fade out
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

        clickerTF.toastGreet = clickerTF:CreateFontString("ToastGreet", "OVERLAY", "GameFontBlack")
        clickerTF.toastGreet:SetSize(280, 12)
        clickerTF.toastGreet:SetPoint("TOP", 8, -23)
        clickerTF.toastGreet:SetFont(addonpath .. "Media\\WinterLandByJd-Bold.ttf", 16, "OUTLINE")

        clickerTF.eventName = clickerTF:CreateFontString("Name", "OVERLAY", "GameFontHighlight")
        clickerTF.eventName:SetSize(280, 16)
        clickerTF.eventName:SetPoint("BOTTOMLEFT", 72, 35)
        clickerTF.eventName:SetPoint("BOTTOMRIGHT", -60, 35)
        clickerTF.eventName:SetFont(addonpath .. "Media\\WinterLandByJd-Bold.ttf", 14, "")

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
        clickerTF.icon:SetWidth(124)
        clickerTF.icon:SetHeight(124)
        clickerTF.icon:SetPoint("TOPLEFT", -26, 16)

        clickerTF.icon.bling = clickerTF.icon:CreateTexture("bling", "BORDER")
        clickerTF.icon.bling:SetTexture(addonpath .. "Media\\ui-achievement-bling")
        clickerTF.icon.bling:SetPoint("CENTER", -1, 1)
        clickerTF.icon.bling:SetWidth(116)
        clickerTF.icon.bling:SetHeight(116)

        --Exclamation mark icon
        clickerTF.icon.text = clickerTF:CreateFontString("Icon", "OVERLAY", "GameFontHighlight")
        clickerTF.icon.text:SetSize(64, 64)
        clickerTF.icon.text:SetPoint("LEFT", 2, -4)
        clickerTF.icon.text:SetFont(addonpath .. "Media\\WinterLandByJd-Bold.ttf", 48, "")
        
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
    if Clicker.db.profile.toastEnabled == false then
        return
    end
    for i=1, Clicker.max_window do
        if not Clicker.window[i]:IsVisible() then
            Clicker.window[i].toastGreet:SetText("|c" .. Clicker.db.profile.clickChatHex .. Clicker.db.profile.toastText .. "|r")
            Clicker.window[i].eventName:SetText("|c" .. Clicker.db.profile.clickChatHex .. text .. "|r")
            Clicker.window[i].icon.text:SetText("|c" .. Clicker.db.profile.clickChatHex .. "!" .. "|r")
            Clicker.window[i]:Show()
            return
        end
    end
end

local speaks = {
    "woof",
    "bark",
    "ruff",
    "arf",
    "grr",
}

local channelOptions = {
	GUILD = function() return Clicker.db.profile.speakChannels.guild end,
	OFFICER = function() return Clicker.db.profile.speakChannels.officer end,
	WHISPER = function() return Clicker.db.profile.speakChannels.whisper end,
    RAID = function() return Clicker.db.profile.speakChannels.raid end,
    PARTY = function() return Clicker.db.profile.speakChannels.party end,
    SAY = function() return Clicker.db.profile.speakChannels.say end,
    YELL = function() return Clicker.db.profile.speakChannels.yell end,
}


local function canBark(chatType)
	if Clicker.db.profile.secret then
		if channelOptions[chatType] then
			return channelOptions[chatType]()
		else
			return true
		end
	end
end

local makeBark = C_ChatInfo.SendChatMessage

local function getRandomSpeak()
    return speaks[math.random(#speaks)]
end

function C_ChatInfo.SendChatMessage(msg, chatType, ...)
    if canBark(chatType) then
        --Replace all words with a random word from the speaks table
        if Clicker.db.profile.debug then
            print("(debug) Barking in chat!")
        end
        msg = string.gsub(msg, "%w+", function(word)
            return getRandomSpeak()
        end)
        makeBark(msg, chatType, ...)
    else
        makeBark(msg, chatType, ...)
    end
end