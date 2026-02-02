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
    local options = {
        name = "Clicker Addon Configuration",
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
                        type = "input",
                        name = "Click Chat Color",
                        desc = "Enter an 8 digit hex color code here for the Clicker texts. Example: FF36F7BC for a light blue color.",
                        order = 1.5,
                        get = function(info) return Clicker.db.profile.clickChatColor end,
                        set = function(info, value) Clicker.db.profile.clickChatColor = value end,
                    },
                    secretSetting = {
                        type = "toggle",
                        name = "Enable Secret?",
                        desc = "A mysterious setting that does nothing... or does it?",
                        order = 1.6,
                        get = function(info) return Clicker.db.profile.bark end,
                        set = function(info, value) Clicker.db.profile.bark = value end,
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
                    levelUpEnabled = {
                        type = "toggle",
                        name = "Level Up",
                        desc = "Enable click sound and popup on level up events.",
                        order = 2.1,
                        get = function(info) return Clicker.db.profile.levelUpEnabled end,
                        set = function(info, value) Clicker.db.profile.levelUpEnabled = value end,
                    },
                    achievementEnabled = {
                        type = "toggle",
                        name = "Achievement Unlocked",
                        desc = "Enable click sound and popup on achievement earned events.",
                        order = 2.2,
                        get = function(info) return Clicker.db.profile.achievementEnabled end,
                        set = function(info, value) Clicker.db.profile.achievementEnabled = value end,
                    },
                    newPetEnabled = {
                        type = "toggle",
                        name = "New Pet Unlocked",
                        desc = "Enable click sound and popup on new pet added events.",
                        order = 2.3,
                        get = function(info) return Clicker.db.profile.newPetEnabled end,
                        set = function(info, value) Clicker.db.profile.newPetEnabled = value end,
                    },
                    zoneEnabled = {
                        type = "toggle",
                        name = "Zone Change",
                        desc = "Enable click sound and popup on zone change events.",
                        order = 2.4,
                        get = function(info) return Clicker.db.profile.zoneEnabled end,
                        set = function(info, value) Clicker.db.profile.zoneEnabled = value end,
                    },
                    questCompleteEnabled = {
                        type = "toggle",
                        name = "Quest Complete",
                        desc = "Enable click sound and popup on quest complete events.",
                        order = 2.5,
                        get = function(info) return Clicker.db.profile.questCompleteEnabled end,
                        set = function(info, value) Clicker.db.profile.questCompleteEnabled = value end,
                    },
                    newHouseLvlEnabled = {
                        type = "toggle",
                        name = "New House Level Unlocked",
                        desc = "Enable click sound and popup on new house level events.",
                        order = 2.6,
                        get = function(info) return Clicker.db.profile.newHouseLvlEnabled end,
                        set = function(info, value) Clicker.db.profile.newHouseLvlEnabled = value end,
                    },
                    newMountEnabled = {
                        type = "toggle",
                        name = "New Mount Unlocked",
                        desc = "Enable click sound and popup on new mount added events.",
                        order = 2.7,
                        get = function(info) return Clicker.db.profile.newMountEnabled end,
                        set = function(info, value) Clicker.db.profile.newMountEnabled = value end,
                    },
                    newHousingItemEnabled = {
                        type = "toggle",
                        name = "New Housing Item Unlocked",
                        desc = "Enable click sound and popup on new housing item acquired events.",
                        order = 2.8,
                        get = function(info) return Clicker.db.profile.newHousingItemEnabled end,
                        set = function(info, value) Clicker.db.profile.newHousingItemEnabled = value end,
                    },
                    newToyEnabled = {
                        type = "toggle",
                        name = "New Toy Unlocked",
                        desc = "Enable click sound and popup on new toy added events.",
                        order = 2.9,
                        get = function(info) return Clicker.db.profile.newToyEnabled end,
                        set = function(info, value) Clicker.db.profile.newToyEnabled = value end,
                    },
                    bMarketWinEnabled = {
                        type = "toggle",
                        name = "BMAH Won",
                        desc = "Enable click sound and popup on Black Market Auction House win events.",
                        order = 2.10,
                        get = function(info) return Clicker.db.profile.bMarketWinEnabled end,
                        set = function(info, value) Clicker.db.profile.bMarketWinEnabled = value end,
                    },
                    mPlusWkRecordEnabled = {
                        type = "toggle",
                        name = "Mythic+ Weekly Record",
                        desc = "Enable click sound and popup on new Mythic+ weekly record events.",
                        order = 2.11,
                        get = function(info) return Clicker.db.profile.mPlusWkRecordEnabled end,
                        set = function(info, value) Clicker.db.profile.mPlusWkRecordEnabled = value end,
                    },
                }
            }
        },
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
            clickChatColor = "FFFF73A5",
            muted = false,
            soundChannel = "Master",
            volumeLevel = "clicker",
            numClicks = 0,
            bark = false,
            levelUpEnabled = true,
            achievementEnabled = true,
            newPetEnabled = true,
            zoneEnabled = true,
            questCompleteEnabled = true,
            newHouseLvlEnabled = true,
            newMountEnabled = true,
            newHousingItemEnabled = true,
            newToyEnabled = true,
            bMarketWinEnabled = true,
            mPlusWkRecordEnabled = true,

        },
    }
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
            self.db.profile.clickChatColor = "FFFF73A5"
            self.db.profile.muted = false
            self.db.profile.soundChannel = "Master"
            self.db.profile.volumeLevel = "Default"
            print("All Clicker settings have been reset to defaults.")
        elseif command == "secret" then
            self.db.profile.bark = not self.db.profile.bark
            if not self.db.profile.bark then
                print("Your normal speech is magically restored!")
            elseif self.db.profile.bark then
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
    Clicker:regCommands(mFrame)
    Lwin.RestorePosition(mFrame)
    Clicker:registerEvents()
end

local kbTracker = CreateFrame("Frame", "KBTracker", UIParent)
local function kbHandler(...)
    local sourceGUID = select(4, ...)
    local subevent = select(2, ...)
    if subevent == "PARTY_KILL" and sourceGUID == Clicker.playerGUID then
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
        print("|c" .. Clicker.db.profile.clickChatColor .. "Click! " .. Clicker.db.profile.toastText .. " You have clicked " .. Clicker.db.profile.numClicks .. " times.|r")
    end
end

local randEvents = {
    "Level Up! Woohoo!",
    "Fresh Achievement!",
    "New Pet Added!",
    "Zone Changed",
    "Quest Complete!",
    "House Level Increased!",
    "New Mount Unlocked!",
    "New Housing Item!",
    "New Toy Acquired!",
    "BMAH Bid Won!",
    "New Weekly M+ Record!",
}

local function pickRandEvent()
    return randEvents[math.random(#randEvents)]
end

local function eventHandler(self,event, ...)
    if event == "PLAYER_LEVEL_UP" and Clicker.db.profile.levelUpEnabled then
        print("(debug) Player has leveled up. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("Level Up! Woohoo!")
        end
    elseif event == "ACHIEVEMENT_EARNED" and Clicker.db.profile.newAchieveEnabled then
        print("(debug) Player earned an achievement. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("Fresh Achievement!")
        end
    elseif event == "NEW_PET_ADDED" and Clicker.db.profile.newPetEnabled then
        print("(debug) Player added a new pet to their collection. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("New Pet Added!")
        end
    elseif event == "ZONE_CHANGED" and Clicker.db.profile.zoneEnabled then
        print("(debug) Player changed zones. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast(pickRandEvent())
        end
    elseif event == "QUEST_COMPLETE" and Clicker.db.profile.questCompleteEnabled then
        print("(debug) Player completed a quest. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("Quest Complete!")
        end
    elseif event == "HOUSE_LEVEL_CHANGED" and Clicker.db.profile.newHouseLvlEnabled then
        print("(debug) Player increased house level. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("House Level Increased!")
        end
    elseif event == "NEW_MOUNT_ADDED" and Clicker.db.profile.newMountEnabled then
        print("(debug) Player added a new mount. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("New Mount Unlocked!")
        end
    elseif event == "NEW_HOUSING_ITEM_ACQUIRED" and Clicker.db.profile.newHousingItemEnabled then
        print("(debug) Player acquired a new housing item. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("New Housing Item!")
        end
    elseif event == "NEW_TOY_ADDED" and Clicker.db.profile.newToyEnabled then
        print("(debug) Player acquired a new toy. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("New Toy Acquired!")
        end
    elseif event == "BLACK_MARKET_WON" and Clicker.db.profile.bMarketWinEnabled then
        print("(debug) Player won a BMAH bid. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("BMAH Bid Won!")
        end
    elseif event == "MYTHIC_PLUS_NEW_WEEKLY_RECORD" and Clicker.db.profile.mPlusWkRecordEnabled then
        print("(debug) Player set a new weekly Mythic+ record. Click Time!")
        Clicker:playClick()
        if Clicker.db.profile.toastEnabled then
            Clicker:showToast("New Weekly M+ Record!")
        end
    end
end

function Clicker:registerEvents()
    --Register events to watch here
    eventListenerFrame:SetScript("OnEvent", eventHandler)
    eventListenerFrame:RegisterEvent("PLAYER_LEVEL_UP")
    eventListenerFrame:RegisterEvent("ACHIEVEMENT_EARNED")
    eventListenerFrame:RegisterEvent("NEW_PET_ADDED")
    eventListenerFrame:RegisterEvent("ZONE_CHANGED")
    eventListenerFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    eventListenerFrame:RegisterEvent("CHALLENGE_MODE_NEW_RECORD")
    eventListenerFrame:RegisterEvent("QUEST_COMPLETE")
    eventListenerFrame:RegisterEvent("HOUSE_LEVEL_CHANGED")
    eventListenerFrame:RegisterEvent("NEW_MOUNT_ADDED")
    eventListenerFrame:RegisterEvent("NEW_HOUSING_ITEM_ACQUIRED")
    eventListenerFrame:RegisterEvent("NEW_TOY_ADDED")
    eventListenerFrame:RegisterEvent("BLACK_MARKET_WON")
    eventListenerFrame:RegisterEvent("MYTHIC_PLUS_NEW_WEEKLY_RECORD")
end


function Clicker:createToastFrame(mFrame)
    --AchievementAlertFrameTemplate?
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

        if clickerTF.showTime + 8 < GetTime() then
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
        clickerTF.toastGreet:SetSize(200, 12)
        clickerTF.toastGreet:SetPoint("TOP", 8, -22)
        clickerTF.toastGreet:SetFont(addonpath .. "Media\\WinterLandByJd-Bold.ttf", 16, "OUTLINE")

        clickerTF.eventName = clickerTF:CreateFontString("Name", "OVERLAY", "GameFontHighlight")
        clickerTF.eventName:SetSize(240, 16)
        clickerTF.eventName:SetPoint("CENTER", 10, -2)
        --clickerTF.eventName:SetPoint("BOTTOMRIGHT", -60, 35)
        clickerTF.eventName:SetFont(addonpath .. "Media\\WinterLandByJd-Bold.ttf", 16, "")

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
            Clicker.window[i].toastGreet:SetText("|c" .. Clicker.db.profile.clickChatColor .. Clicker.db.profile.toastText .. "|r")
            Clicker.window[i].eventName:SetText("|c" .. Clicker.db.profile.clickChatColor .. text .. "|r")
            Clicker.window[i].icon.text:SetText("|c" .. Clicker.db.profile.clickChatColor .. "!" .. "|r")
            Clicker.window[i]:Show()
            return
        end
    end
end

local barkChannels = {
	guild = false,
	officer = false,
    raid = false,
    party = false,
    say = true,
	whisper = true,
}

local speaks = {
    "woof",
    "bark",
    "ruff",
    "arf",
    "grr",
}

local channelOptions = {
	GUILD = function() return barkChannels.guild end,
	OFFICER = function() return barkChannels.officer end,
	WHISPER = function() return barkChannels.whisper end,
    RAID = function() return barkChannels.raid end,
    PARTY = function() return barkChannels.party end,
    SAY = function() return barkChannels.say end,
}


local function canBark(chatType)
	if Clicker.db.profile.bark then
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
        print("(debug) Barking in chat!")
        msg = string.gsub(msg, "%w+", function(word)
            return getRandomSpeak()
        end)
        makeBark(msg, chatType, ...)
    else
        makeBark(msg, chatType, ...)
    end
end