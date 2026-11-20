-- Slash-Befehle registrieren
SLASH_ROCKON1 = "/rockon"
SlashCmdList["ROCKON"] = function()
    if IsShiftKeyDown() then
        Rockon_Invite(true)  -- Shift gedrückt = Raid
    else
        Rockon_Invite(false) -- Normaler Klick = Party
    end
end

SLASH_ROCKONRAID1 = "/rockonraid"
SlashCmdList["ROCKONRAID"] = function()
    Rockon_Invite(true)
end

SLASH_ROCKONPARTY1 = "/rockonparty"
SlashCmdList["ROCKONPARTY"] = function()
    Rockon_Invite(false)
end

-- Hauptfunktion: isRaid = true (Raid-Modus) | isRaid = false (Nur Party)
function Rockon_Invite(isRaid)
    if isRaid and GetNumPartyMembers() > 0 and not UnitInRaid("player") then
        ConvertToRaid()
    end

    local names = {}
    for i = 0, 30 do
        if UnitExists("target") and UnitIsPlayer("target") and not UnitIsUnit("player", "target") then
            local name = GetUnitName("target")
            if name and not Rockon_PlayerInGrp(name) and not names[name] then
                if not isRaid and (UnitInRaid("player") or GetNumPartyMembers() >= 4) then
                    break
                end
                
                names[name] = true
                InviteByName(name)
            end    
        end
        TargetNearestFriend()
    end
    ClearTarget()

    if isRaid and UnitInRaid("player") then
        for i = 1, GetNumRaidMembers() do
            local u = "raid" .. i
            local n = UnitName(u)
            if n and UnitIsConnected(u) then
                PromoteToAssistant(n)
            end
        end
    end

    mb_message("AOE Invite, let's go! Rock on", 5)
end

function Rockon_PlayerInGrp(name)
    local InRaid = UnitInRaid("player")
    local group = nil
    local NumMembers = nil
    local counter = nil
    local u = nil

    if InRaid then
        NumMembers = GetNumRaidMembers()
        counter = 1
        group = "raid"
    else
        NumMembers = GetNumPartyMembers()
        counter = 0
        group = "party"
    end

    while counter <= NumMembers do
        if counter == 0 then
            u = "player"
        else
            u = group .. counter
        end
        if GetUnitName(u) == name then
            return true
        end
        counter = counter + 1
    end
    return false
end

function mb_message(msg, timer)
    local cooldown = timer or 5
    local time = GetTime()
    if MB_prev_msg == msg and (mb_messagecd or 0) + cooldown > time then
        return
    end
    MB_prev_msg = msg
    mb_messagecd = time
    SendChatMessage(msg, "YELL")
end