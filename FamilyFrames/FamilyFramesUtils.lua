-- modified version of the base action bar cooldown update
function FamilyFrames_UpdateCooldown(self, actionType, actionID)
	local locStart, locDuration = 0, 0;
	local start, duration, enable, charges, maxCharges, chargeStart, chargeDuration = 0, 0, false, 0, 0, 0, 0;
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

-- abstracting out spell/macro/item(later) info calls into a unified button metadata calls
function FamilyFrames_GetButtonData(button)
  local type = button:GetAttribute("type");
  local spellName = button:GetAttribute("spell");
  local macroName = button:GetAttribute("macro");
  return type, spellName, macroName;
end

function FamilyFrames_GetButtonTexture(button)
  local type, spellName, macroName = FamilyFrames_GetButtonData(button);
  local iconID = nil;
  if (type) then
    if (type == "spell") then
      iconID = C_Spell.GetSpellTexture(spellName);
    elseif (type == "macro") then
      print("in macro button");
      print(GetMacroInfo(macroName));
      _, iconID = GetMacroInfo(macroName);
    end
  end
  return iconID;
end

function FamilyFrames_GetSpellID(button)
  local type, spellName, macroName = FamilyFrames_GetButtonData(button);
  local spellID = nil;
  if (type) then
    if (type == "spell") then
      spellID = C_Spell.GetSpellIDForSpellIdentifier(spellName);
    elseif (type == "macro") then
      spellID = GetMacroSpell(macroName);
    end
  end
  return spellID;
end

function FamilyFrames_GetPartyFrameInfo()
  -- group number to add (0 if either not in party or party is too large)
  local num = GetNumGroupMembers();
  if (num > 5) then
    num = 0;
  end

  local raidStyle = EditModeManagerFrame:UseRaidStylePartyFrames();

  return num, raidStyle;
end

function FamilyFrames_SetupSpellBar(targetUnit, anchorFrame, ...)
  local frameName = format("FamilyFramesSpellBarFrame%s", targetUnit:sub(1,1):upper()..targetUnit:sub(2));
  local parentFrame = _G["FamilyFramesSpellBarContainer"];
  local frame = CreateFrame("Frame", frameName, parentFrame, "FamilyFramesSpellBarTemplate");
  frame:SetPoint(FamilyFrames_SpellBarAnchorPoint, anchorFrame, FamilyFrames_AnchorSpellBarsTo, 5, 0);
  --FamilyFrames_PopulateSpellBarButtons(targetUnit);
end

function FamilyFrames_CreateSpellBars()
  -- all possible spell bar frames need to be created at startup
  -- player frame spell bar
  FamilyFrames_SetupSpellBar("player", "PlayerFrame");
  -- player frame for first compact party frame
  FamilyFrames_SetupSpellBar("player", "CompactPartyFrameMember1");

  -- party member spell bars
  for ii = 2, 5, 1
  do
    local nonRaidFrame = format("PartyFrame.MemberFrame%s", ii - 1);
    local raidFrame = format("CompactPartyFrameMember%s", ii);
    local unitName = format("party%s", ii - 1);
    FamilyFrames_SetupSpellBar(unitName, nonRaidFrame);
    FamilyFrames_SetupSpellBar(unitName, raidFrame);
  end
end