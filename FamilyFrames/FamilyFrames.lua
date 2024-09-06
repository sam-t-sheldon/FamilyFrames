print("Welcome to debug mode for FamilyFrames!");

--[[local testBtn = CreateFrame("CheckButton", "testButton", UIParent, "SecureActionButtonTemplate, ActionBarButtonTemplate", 0);
testBtn:ClearAllPoints();
testBtn:SetAttribute("type", "spell");
testBtn:SetAttribute("spell", "Flash Heal");
testBtn:SetAttribute("unit", "party1");
testBtn:SetAttribute("action", 2061);
--testBtn:SetAttribute("type", "macro");
--testBtn:SetAttribute("macrotext", "/cast [@player] Flash Heal")
testBtn:RegisterForClicks("AnyUp", "AnyDown");
testBtn:SetPoint("CENTER", 0, 0);
--testBtn:SetNormalTexture("Interface\\Icons\\ability_monk_guard");
ActionBarActionEventsFrame:RegisterFrame(testBtn);
testBtn:Show();]]--



-- list of spells in order
FamilyFrames_CurrentSpells = {
  [1] = {
    ["type"] = "spell",
    ["spell"] = "Renew",
    ["macro"] = nil
  },
  [2] = {
    ["type"] = "spell",
    ["spell"] = "Flash Heal",
    ["macro"] = nil
  },
  [3] = {
    ["type"] = "spell",
    ["spell"] = "Heal",
    ["macro"] = nil
  },
  [4] = {
    ["type"] = "spell",
    ["spell"] = "Power Word: Shield",
    ["macro"] = nil
  },
  [5] = {
    ["type"] = "spell",
    ["spell"] = "Holy Word: Serenity",
    ["macro"] = nil
  },
  [6] = {
    ["type"] = "macro",
    ["spell"] = nil,
    ["macro"] = "121"
  },
  [7] = {
    ["type"] = "spell",
    ["spell"] = "Heal",
    ["macro"] = nil
  },
  [8] = {
    ["type"] = "spell",
    ["spell"] = "Heal",
    ["macro"] = nil
  },
  [9] = {
    ["type"] = "spell",
    ["spell"] = "Heal",
    ["macro"] = nil
  },
  [10] = {
    ["type"] = "spell",
    ["spell"] = "Heal",
    ["macro"] = nil
  },
  [11] = {
    ["type"] = "spell",
    ["spell"] = "Heal",
    ["macro"] = nil
  },
  [12] = {
    ["type"] = "spell",
    ["spell"] = "Heal",
    ["macro"] = nil
  },
  [13] = {
    ["type"] = "spell",
    ["spell"] = "Heal",
    ["macro"] = nil
  },
  [14] = {
    ["type"] = "spell",
    ["spell"] = "Heal",
    ["macro"] = nil
  },
  [15] = {
    ["type"] = "spell",
    ["spell"] = "Heal",
    ["macro"] = nil
  },
};

local function getCurrentSpells()
  return FamilyFrames_CurrentSpells;
end

FamilyFrames_AnchorSpellBarsTo = "TOPRIGHT";
FamilyFrames_SpellBarAnchorPoint = "TOPLEFT";

-- listing of current spell bars
FamilyFrames_SpellBars = {};



--FamilyFrames_SpellBars["player"] = FamilyFrames_SetupSpellBar("player", "UIParent", "CENTER", "CENTER");
--FamilyFrames_CreateSpellBar("party1", "CompactPartyFrameMember2");
--FamilyFrames_CreateSpellBar("party2", "CompactPartyFrameMember3");
--FamilyFrames_CreateSpellBar("party3", "CompactPartyFrameMember4");
--FamilyFrames_CreateSpellBar("party4", "CompactPartyFrameMember5");