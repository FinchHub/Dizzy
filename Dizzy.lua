local ADDON_NAME = "Dizzy"
local DizzySavedVars

local menuScenes = {
    "skills",
    "questJournal",
    "collectionsBook",
    "dlcBook",
    "housingBook",
    "itemSetsBook",
    "tributePatronBook",
    "groupMenuKeyboard",
    "friendsList",
    "ignoreList",
    "guildHome",
    "guildRoster",
    "guildRanks",
    "guildRecruitmentKeyboard",
    "guildHistory",
    "guildBrowserKeyboard",
    "mailInbox",
    "mailSend",
    "notifications",
    "scribingLibraryKeyboard",
    "antiquityJournalKeyboard",
    "loreLibrary",
    "achievements",
    "leaderboards",
    "helpTutorials",
    "helpCustomerSupport",
    "helpEmotes",
    "campaignBrowser",
    "campaignOverview",
    "gamepadCollectionsBook",
    "gamepad_inventory_root",
    "gamepad_friends",
    "gamepad_groupList",
    "gamepad_campaign_root",
    "gamepad_skills_root",
    "gamepadCollectionsBook",
    "mailGamepad",
}



local function ToggleCameraRotation(sceneName, enable)
    local scene = SCENE_MANAGER.scenes[sceneName]
    if not scene then return end

    if enable then
        if not scene:HasFragment(FRAME_PLAYER_FRAGMENT) then
            scene:AddFragment(FRAME_PLAYER_FRAGMENT)
        end
    else
        if scene:HasFragment(FRAME_PLAYER_FRAGMENT) then
            scene:RemoveFragment(FRAME_PLAYER_FRAGMENT)
        end
    end
end

local function ApplySettings()
    -- I separated these three out for a little more creative control. The stats menu also breaks outfit selection when turned on.
    ToggleCameraRotation("stats", not DizzySavedVars.preventStatsRotation)
    ToggleCameraRotation("inventory", not DizzySavedVars.preventInventoryRotation)
    ToggleCameraRotation("gameMenuInGame", not DizzySavedVars.preventPauseRotation)

    for _, sceneName in ipairs(menuScenes) do
        ToggleCameraRotation(sceneName, not DizzySavedVars.preventOtherMenusRotation)
    end
end



-- Settings Menu. Requires LibAddonMenu.
local function CreateSettingsMenu()
    if not LibAddonMenu2 then
        d("|cFF0000[Dizzy]|r Missing dependency: LibAddonMenu-2.0")
        return
    end

    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = ADDON_NAME,
        displayName = "Dizzy",
        author = "|cB55AFFPurpleFinch|r",
        version = "1.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(ADDON_NAME .. "Panel", panelData)

    local optionsTable = {
        {
            type = "header",
            name = "OPTIONS",
        },
        {
            type = "checkbox",
            name = "Prevent Rotation in Character Menu",
            tooltip = "Enables or disables camera rotation in the Character menu. CAUTION - Turning this on will PREVENT you from switching outfits.",
            getFunc = function() return DizzySavedVars.preventStatsRotation end,
            setFunc = function(value)
                DizzySavedVars.preventStatsRotation = value
                ApplySettings()
            end,
            default = false,
        },
        {
            type = "checkbox",
            name = "Prevent Rotation in Inventory Menus",
            tooltip = "Enables or disables camera rotation in inventory menus.",
            getFunc = function() return DizzySavedVars.preventInventoryRotation end,
            setFunc = function(value)
                DizzySavedVars.preventInventoryRotation = value
                ApplySettings()
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Prevent Rotation in Pause Menu",
            tooltip = "Enables or disables camera rotation in the pause menu.",
            getFunc = function() return DizzySavedVars.preventPauseRotation end,
            setFunc = function(value)
                DizzySavedVars.preventPauseRotation = value
                ApplySettings()
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Prevent Rotation in All Other Menus",
            tooltip = "Enables or disables camera rotation in all menus except Stats, Inventory, and Pause menus.",
            getFunc = function() return DizzySavedVars.preventOtherMenusRotation end,
            setFunc = function(value)
                DizzySavedVars.preventOtherMenusRotation = value
                ApplySettings()
            end,
            default = true,
        },
    }

    LAM:RegisterOptionControls(ADDON_NAME .. "Panel", optionsTable)
end


local function OnAddonLoaded(event, addonName)
    if addonName == ADDON_NAME then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

        DizzySavedVars = ZO_SavedVars:NewAccountWide("DizzySavedVars", 1, nil, {
            preventStatsRotation = false, --I keep the character menu rotation off by default because it breaks outfit selection.
            preventOtherMenusRotation = true, 
            preventInventoryRotation = true,
            preventPauseRotation = true,
        })

        ApplySettings()
        CreateSettingsMenu()
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)