local addonName, addonTable = ...;

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