-- GuildChatAI.lua
local addonName, addon = ...

-- Initialize SavedVariables
GuildChatAIDB = GuildChatAIDB or { guildMessages = {}, guildRoster = {} }

-- Create frame for event handling
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("CHAT_MSG_GUILD")
frame:RegisterEvent("GUILD_ROSTER_UPDATE")

-- Event handler
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        print("GuildChatAI loaded. Use /gcai <message> to send to guild chat.")
    elseif event == "CHAT_MSG_GUILD" then
        local message, sender = ...
        local timestamp = date("%m/%d %H:%M:%S.%f")
        -- Store in SavedVariables
        table.insert(GuildChatAIDB.guildMessages, { timestamp = timestamp, sender = sender, message = message })
        -- Print to chat frame to ensure it logs to WoWChatLog.txt
        print(string.format("[Guild] %s %s: %s", timestamp, sender, message))
    elseif event == "GUILD_ROSTER_UPDATE" then
        -- Update guild roster
        GuildChatAIDB.guildRoster = {}
        GuildRoster() -- Trigger roster update
        local numMembers = GetNumGuildMembers()
        for i = 1, numMembers do
            local name = GetGuildRosterInfo(i)
            if name then
                GuildChatAIDB.guildRoster[name] = true
            end
        end
    end
end)

-- Slash command to send AI responses to guild chat
SLASH_GCAI1 = "/gcai"
SlashCmdList["GCAI"] = function(msg)
    if msg and msg ~= "" then
        SendChatMessage(msg, "GUILD")
        print("Sent to guild chat: " .. msg)
    else
        print("Usage: /gcai <message>")
    end
end