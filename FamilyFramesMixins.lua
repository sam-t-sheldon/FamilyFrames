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

function FamilyFramesEventMixin:CreateSpellBars()
  addonTable.spellBars.frames = {};
  -- raid frame 1
  addonTable.spellBars.frames["FamilyFramesSpellBarCompactParty1"] = CreateFrame("Frame", "FamilyFramesSpellBarPlayer", _G["CompactPartyFrameMember1"], "FamilyFramesSpellBarTemplate");
  addonTable.spellBars.frames["FamilyFramesSpellBarCompactParty1"].targetUnit = "player";
  -- raid frame 2
  addonTable.spellBars.frames["FamilyFramesSpellBarCompactParty2"] = CreateFrame("Frame", "FamilyFramesSpellBarPlayer", _G["CompactPartyFrameMember2"], "FamilyFramesSpellBarTemplate");
  addonTable.spellBars.frames["FamilyFramesSpellBarCompactParty2"].targetUnit = "party1";
  -- raid frame 3
  addonTable.spellBars.frames["FamilyFramesSpellBarCompactParty3"] = CreateFrame("Frame", "FamilyFramesSpellBarPlayer", _G["CompactPartyFrameMember3"], "FamilyFramesSpellBarTemplate");
  addonTable.spellBars.frames["FamilyFramesSpellBarCompactParty3"].targetUnit = "party2";
  -- raid frame 4
  addonTable.spellBars.frames["FamilyFramesSpellBarCompactParty4"] = CreateFrame("Frame", "FamilyFramesSpellBarPlayer", _G["CompactPartyFrameMember4"], "FamilyFramesSpellBarTemplate");
  addonTable.spellBars.frames["FamilyFramesSpellBarCompactParty4"].targetUnit = "party3";
  -- raid frame 5
  addonTable.spellBars.frames["FamilyFramesSpellBarCompactParty5"] = CreateFrame("Frame", "FamilyFramesSpellBarPlayer", _G["CompactPartyFrameMember5"], "FamilyFramesSpellBarTemplate");
  addonTable.spellBars.frames["FamilyFramesSpellBarCompactParty5"].targetUnit = "party4";

  -- party frame 1
  addonTable.spellBars.frames["FamilyFramesSpellBarParty1"] = CreateFrame("Frame", "FamilyFramesSpellBarPlayer", _G["PartyFrame"]["MemberFrame1"], "FamilyFramesSpellBarTemplate");
  addonTable.spellBars.frames["FamilyFramesSpellBarParty1"].targetUnit = "party1";
  -- party frame 2
  addonTable.spellBars.frames["FamilyFramesSpellBarParty2"] = CreateFrame("Frame", "FamilyFramesSpellBarPlayer", _G["PartyFrame"]["MemberFrame2"], "FamilyFramesSpellBarTemplate");
  addonTable.spellBars.frames["FamilyFramesSpellBarParty2"].targetUnit = "party2";
  -- party frame 3
  addonTable.spellBars.frames["FamilyFramesSpellBarParty3"] = CreateFrame("Frame", "FamilyFramesSpellBarPlayer", _G["PartyFrame"]["MemberFrame3"], "FamilyFramesSpellBarTemplate");
  addonTable.spellBars.frames["FamilyFramesSpellBarParty3"].targetUnit = "party3";
  -- party frame 4
  addonTable.spellBars.frames["FamilyFramesSpellBarParty4"] = CreateFrame("Frame", "FamilyFramesSpellBarPlayer", _G["PartyFrame"]["MemberFrame4"], "FamilyFramesSpellBarTemplate");
  addonTable.spellBars.frames["FamilyFramesSpellBarParty4"].targetUnit = "party4";

  -- player frame (this needs some extra handling to hide if the raid frames are up)
  addonTable.spellBars.frames["FamilyFramesSpellBarPlayer"] = CreateFrame("Frame", "FamilyFramesSpellBarPlayer", _G["PlayerFrame"], "FamilyFramesSpellBarTemplate");
  addonTable.spellBars.frames["FamilyFramesSpellBarPlayer"].targetUnit = "player";
  SecureHandlerSetFrameRef(addonTable.spellBars.frames["FamilyFramesSpellBarPlayer"], "ffraidplayerframe", addonTable.spellBars.frames["FamilyFramesSpellBarCompactParty1"]);
  RegisterStateDriver(addonTable.spellBars.frames["FamilyFramesSpellBarPlayer"], "ffsshowframe", "[@party1,exists] hide; show");
  addonTable.spellBars.frames["FamilyFramesSpellBarPlayer"]:SetAttribute("_onstate-ffsshowframe", [=[
    local raidPlayerFrame = self:GetFrameRef("ffraidplayerframe");
    if (raidPlayerFrame:IsVisible()) then
      self:Hide();
    else
      self:Show();
    end
  ]=]);

end

