local addonName, addonTable = ...;

function addonTable.functions.GetCurrentSpellBarSpells()
  local classID, specIndex = addonTable.functions.GetClassAndSpecInfo();
	if (addonTable["Settings"]) then
		local spellList = addonTable["Settings"]["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["SpellBars"]["SpellLists"][classID][specIndex];
		return spellList;
	else
		return nil;
	end
end