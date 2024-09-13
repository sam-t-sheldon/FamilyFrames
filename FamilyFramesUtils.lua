local addonName, addonTable = ...;

--[[

    string.split (s, p)
    ====================================================================
    Splits the string [s] into substrings wherever pattern [p] occurs.

    Returns: a table of substrings or, if no match is made [nil].

		Source: https://stackoverflow.com/questions/12014382/split-string-and-replace-dot-char-in-lua

--]]
FamilyFrames_StringSplit = function(s, p)
	local temp = {}
	local index = 0
	local last_index = string.len(s)

	while true do
			local i, e = string.find(s, p, index)

			if i and e then
					local next_index = e + 1
					local word_bound = i - 1
					table.insert(temp, string.sub(s, index, word_bound))
					index = next_index
			else
					if index > 0 and index <= last_index then
							table.insert(temp, string.sub(s, index, last_index))
					elseif index == 0 then
							temp = nil
					end
					break
			end
	end

	return temp
end


-- modified version of the base action bar cooldown update
-- TODO: move this into the button mixin at some point
function FamilyFrames_UpdateCooldown(self, actionType, actionID)
	local locStart, locDuration = 0, 0;
	local start, duration, enable, charges, maxCharges, chargeStart, chargeDuration = 0, 0, nil, 0, 0, 0, 0;
	local modRate = 1.0;
	local chargeModRate = 1.0;
	local auraData = nil;
	local passiveCooldownSpellID = nil;
	local onEquipPassiveSpellID = nil;
  -- temp
  local spellID = actionID;

	--[[if(actionID) then 
		onEquipPassiveSpellID = C_ActionBar.GetItemActionOnEquipSpellID(self.action);
	end]]--

	if (onEquipPassiveSpellID) then
		passiveCooldownSpellID = C_UnitAuras.GetCooldownAuraBySpellID(onEquipPassiveSpellID);
	elseif ((actionType and actionType == "spell") and actionID ) then
		passiveCooldownSpellID = C_UnitAuras.GetCooldownAuraBySpellID(actionID);
	elseif(spellID) then
		passiveCooldownSpellID = C_UnitAuras.GetCooldownAuraBySpellID(spellID);
	end

	if(passiveCooldownSpellID and passiveCooldownSpellID ~= 0) then
		auraData = C_UnitAuras.GetPlayerAuraBySpellID(passiveCooldownSpellID);
	end

	if(auraData) then
		local currentTime = GetTime();
		local timeUntilExpire = auraData.expirationTime - currentTime;
		local howMuchTimeHasPassed = auraData.duration - timeUntilExpire;

		locStart =  currentTime - howMuchTimeHasPassed;
		locDuration = auraData.expirationTime - currentTime;
		start = currentTime - howMuchTimeHasPassed;
		duration =  auraData.duration
		modRate = auraData.timeMod;
		charges = auraData.charges;
		maxCharges = auraData.maxCharges;
		chargeStart = currentTime * 0.001;
		chargeDuration = duration * 0.001;
		chargeModRate = modRate;
		enable = 1;
	elseif (spellID) then
		locStart, locDuration = C_Spell.GetSpellLossOfControlCooldown(spellID);

		local spellCooldownInfo = C_Spell.GetSpellCooldown(spellID) or {startTime = 0, duration = 0, isEnabled = false, modRate = 0};
		start, duration, enable, modRate = spellCooldownInfo.startTime, spellCooldownInfo.duration, spellCooldownInfo.isEnabled, spellCooldownInfo.modRate;

		local chargeInfo = C_Spell.GetSpellCharges(spellID) or {currentCharges = 0, maxCharges = 0, cooldownStartTime = 0, cooldownDuration = 0, chargeModRate = 0};
		charges, maxCharges, chargeStart, chargeDuration, chargeModRate = chargeInfo.currentCharges, chargeInfo.maxCharges, chargeInfo.cooldownStartTime, chargeInfo.cooldownDuration, chargeInfo.chargeModRate;
	end

	if ( (locStart + locDuration) > (start + duration) ) then
		if ( self.cooldown.currentCooldownType ~= COOLDOWN_TYPE_LOSS_OF_CONTROL ) then
			self.cooldown:SetEdgeTexture("Interface\\Cooldown\\UI-HUD-ActionBar-LoC");
			self.cooldown:SetSwipeColor(0.17, 0, 0);
			self.cooldown:SetHideCountdownNumbers(true);
			self.cooldown.currentCooldownType = COOLDOWN_TYPE_LOSS_OF_CONTROL;
		end

		CooldownFrame_Set(self.cooldown, locStart, locDuration, true, true, modRate);
		self.cooldown:SetScript("OnCooldownDone", ActionButtonCooldown_OnCooldownDone, false);
		ClearChargeCooldown(self);
	else
		if ( self.cooldown.currentCooldownType ~= COOLDOWN_TYPE_NORMAL ) then
			self.cooldown:SetEdgeTexture("Interface\\Cooldown\\UI-HUD-ActionBar-SecondaryCooldown");
			self.cooldown:SetSwipeColor(0, 0, 0);
			self.cooldown:SetHideCountdownNumbers(false);
			self.cooldown.currentCooldownType = COOLDOWN_TYPE_NORMAL;
		end


		self.cooldown:SetScript("OnCooldownDone", ActionButtonCooldown_OnCooldownDone, locStart > 0);

		if ( charges and maxCharges and maxCharges > 1 and charges < maxCharges ) then
			StartChargeCooldown(self, chargeStart, chargeDuration, chargeModRate);
		else
			ClearChargeCooldown(self);
		end

		CooldownFrame_Set(self.cooldown, start, duration, enable, false, modRate);
	end
end

function addonTable.functions.GetClassAndSpecInfo()
	local playerLoc = PlayerLocation:CreateFromUnit("player");

	local _, _, classID = C_PlayerInfo.GetClass(playerLoc);
	local specIndex = GetSpecialization();
	return classID, specIndex;
end

function addonTable.functions.GetCurrentSpellBarSpells()
  local classID, specIndex = addonTable.functions.GetClassAndSpecInfo();
	if (addonTable["Settings"]) then
		local spellList = addonTable["Settings"]["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["SpellBars"]["SpellLists"][classID][specIndex];
		return spellList;
	else
		return nil;
	end
end

-- function to print combat warnings without spamming the chat (the combat warnings will reset per combat through the FamilyFramesEventMixin code)
function addonTable.functions.PrintCombatWarning(message, warning)
	if (not addonTable["Warnings"]["Combat"][warning]) then
		addonTable.functions.PrintWarning(message, warning);
		addonTable["Warnings"]["Combat"][warning] = true;
	end
end

function addonTable.functions.PrintWarning(message, warning)
	print("|cFFFF4000Family Frames Warning: |r"..message);
end

-- function to print info messages
function addonTable.functions.PrintInfo(message)
	print("|cFF00FF00Family Frames Info: |r"..message);
end