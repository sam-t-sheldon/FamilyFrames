local addonName, addonTable = ...;

addonTable.functions = {};

if (not addonTable["Version"]) then
  addonTable["Version"] = "0.1.3";
end
if (not addonTable["Settings"]) then
  addonTable["Settings"] = {};
end
if (not addonTable["UnitInfo"]) then
  addonTable["UnitInfo"] = {};
end
if (not addonTable["Warnings"]) then
  addonTable["Warnings"] = {};
  addonTable["Warnings"]["Combat"] = {};
end
if (not addonTable.spellBars) then
  addonTable.spellBars = {};
end

FamilyFrames_AnchorSpellBarsTo = "TOPRIGHT";
FamilyFrames_SpellBarAnchorPoint = "TOPLEFT";