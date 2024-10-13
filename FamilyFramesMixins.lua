local addonName, addonTable = ...;

-- general event catching (for party numbers changing, instance type, etc)
FamilyFramesEventMixin = {};

function FamilyFramesEventMixin:OnLoad()
  self:RegisterEvent("ADDON_LOADED");
  self:RegisterEvent("PLAYER_REGEN_ENABLED");
end

function FamilyFramesEventMixin:OnEvent(event, ...)
  local arg1 = ...;
  if (event == "ADDON_LOADED" and arg1 == addonName) then
    -- load up the settings
    addonTable.functions.LoadSavedSettings();
    -- load up options panel
    addonTable.functions.CreateSettingsPanel();
		-- initialize the spell bars (TODO: have this be a setting)
    if (true) then
      local spellBarFrame = CreateFrame("Frame", "FamilyFramesSpellBarEventFrame", UIParent, "FamilyFramesSpellBarEventFrameTemplate");
      spellBarFrame:CreateSpellBars();
    end
  elseif (event == "PLAYER_REGEN_ENABLED") then
    -- clear any combat warnings
    addonTable["Warnings"]["Combat"] = {};
  end
end

