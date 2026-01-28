if not ClickerDB then
    ClickerDB = {
        muted = false,
        useClick = "clicker",
        useChannel = "Master",
    }
end

print ("Clicker Loaded Successfully")
local mainFrame = CreateFrame("Frame", "ClickerMainFrame", UIParent, "BasicFrameTemplateWithInset")
mainFrame:SetSize(300, 300)
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
mainFrame.TitleBg:SetHeight(30)
mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
mainFrame.title:SetPoint("TOPLEFT", mainFrame.TitleBg, "TOPLEFT", 5, -3)
mainFrame.title:SetText("Clicker Addon Settings")
mainFrame:Hide()
mainFrame:EnableMouse(true)
mainFrame:SetMovable(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", function(self) mainFrame.StartMoving(self) end)
mainFrame:SetScript("OnDragStop", function(self) mainFrame.StopMovingOrSizing(self) end)
mainFrame:SetScript("OnShow", function(self)
    print("Clicker Main Frame Shown")
end)

SLASH_CLICKER1 = "/clicker"
function SlashCmdList.CLICKER(msg, editbox)
    local command, rest = msg:match("^(%S*)%s*(.-)$")
    command = strlower(command or "")
    rest = strlower(rest or "")

    if command == "show" then
        mainFrame:Show()

    elseif command == "mute" then
        -- Toggle mute functionality here
        local clickerMuted = not ClickerDB.muted
        ClickerDB.muted = clickerMuted
        print("Clicker Mute Toggled to " .. tostring(clickerMuted))

    elseif command == "volume" then
        local volume = tonumber(rest)
        if volume == 1 then
            ClickerDB.useClick = "clicker"
            print("Clicker Volume Set to default")
        elseif volume == 6 then
            ClickerDB.useClick = "clicker6"
            print("Clicker Volume Set to +6db")
        elseif volume == 12 then
            ClickerDB.useClick = "clicker12"
            print("Clicker Volume Set to +12db")
        else
            print("Invalid volume. Please enter a value between 0 and 100.")
        end

    elseif command == "channel" then
        local channel = tonumber(rest)
        if channel == 1 then
            ClickerDB.useChannel = "Master"
            print("Clicker Channel Set to Master")
        elseif channel == 2 then
            ClickerDB.useChannel = "SFX"
            print("Clicker Channel Set to SFX")
        elseif channel == 3 then
            ClickerDB.useChannel = "Dialog"
            print("Clicker Channel Set to Dialog")
        else
            print("Invalid channel. Please enter 1 for Master, 2 for SFX, or 3 for Dialog.")
        end

    elseif command == "test" then
        if not ClickerDB.muted then 
            PlaySoundFile("Interface\\Addons\\Clicker\\Media\\" .. ClickerDB.useClick .. ".ogg", ClickerDB.useChannel)
        print("Clicker Test Sound Played, filename is " .. ClickerDB.useClick .. ".ogg")
        end

    elseif command == "test6" then
        if not ClickerDB.muted then PlaySoundFile("Interface\\Addons\\Clicker\\Media\\clicker6.ogg", ClickerDB.useChannel)
        print("Clicker Test +6db Sound Played")
        end

    elseif command == "test12" then
        if not ClickerDB.muted then PlaySoundFile("Interface\\Addons\\Clicker\\Media\\clicker12.ogg", ClickerDB.useChannel)
        print("Clicker Test +12db Sound Played")
        end
    else
        print("Clicker Addon Commands:")
        print("/clicker show - Show the Clicker settings frame.")
        print("/clicker mute - Toggle mute on/off for Clicker.")
        print("/clicker volume [0|6|12] - Set click sound volume. 0=default, 6=+6db, 12=+12db.")
        print("/clicker test - Play test click sound.")
        print("/clicker test6 - Play test +6db click sound.")
        print("/clicker test12 - Play test +12db click sound.")
    end
end

-- Hide the frame when the user presses the Escape key
table.insert(UISpecialFrames, "ClickerMainFrame")

local eventListenerFrame = CreateFrame("Frame", "ClickerEventListenerFrame", UIParent)
local function eventHandler(self, event, ...)
    if event == "PLAYER_LEVEL_UP" then
        print("Player has leveled up. Click Time!.")
        if not ClickerDB.muted then PlaySoundFile("Interface\\Addons\\Clicker\\Media\\" .. ClickerDB.useClick .. ".ogg", ClickerDB.useChannel)
        end
    end
    if event == "PLAYER_PVP_KILLS_CHANGED" then
        print("Player received credit for a PvP kill. Click Time!.")
        if not ClickerDB.muted then PlaySoundFile("Interface\\Addons\\Clicker\\Media\\" .. ClickerDB.useClick .. ".ogg", ClickerDB.useChannel)
        end
    end
end

eventListenerFrame:SetScript("OnEvent", eventHandler)
eventListenerFrame:RegisterEvent("PLAYER_LEVEL_UP")