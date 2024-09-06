local addonName, addonTable = ...;

-- general event catching (for party numbers changing, instance type, etc)
FamilyFramesEventMixin = {};

function FamilyFramesEventMixin:OnLoad()
  self:RegisterEvent("ADDON_LOADED");
end

function FamilyFramesEventMixin:OnEvent(event, ...)
  local arg1 = ...;
  if (event == "ADDON_LOADED" and arg1 == addonName) then
    -- check for saved variables and set defaults as necessary
  end
end

-- mixin for the button bar frame
FamilyFramesSpellBarMixin = {};

function FamilyFramesSpellBarMixin:OnLoad()
  self:Hide();
  self:SetScale(1); -- for resizing later

  self:SetAnchor();
  self:SetVisibility();
  self:SetButtonAttributes();
end

function FamilyFramesSpellBarMixin:SetAnchor()
  -- check if the designated anchor frame exists
  local anchorFrame = _G[self.anchorFrameName];
  if (anchorFrame) then
    self:SetPoint(FamilyFrames_SpellBarAnchorPoint, anchorFrame, FamilyFrames_AnchorSpellBarsTo, 5, 0);
  end
end

function FamilyFramesSpellBarMixin:SetVisibility()
  -- check if our anchor frame exists and is visible, then match that
  -- one exception - if we're in raid style party frames, don't show on our player frame spell bar
  if (self.anchorFrameName == "player" and EditModeManagerFrame:UseRaidStylePartyFrames() and GetNumGroupMembers() > 0) then
    self:Hide();
  else
    local anchorFrame = _G[self.anchorFrameName];
    if (anchorFrame and anchorFrame:IsVisible()) then
      self:Show();
    else
      self:Hide();
    end
  end
end

function FamilyFramesSpellBarMixin:SetButtonAttributes()
  for ii, button in pairs(self.buttons) do
    button:SetAttribute("type", FamilyFrames_CurrentSpells[ii]["type"]);
    button:SetAttribute("spell", FamilyFrames_CurrentSpells[ii]["spell"]);
    button:SetAttribute("macro", FamilyFrames_CurrentSpells[ii]["macro"]);
    button:SetAttribute("unit", self.targetUnit);
    local spellID = button:GetSpellID();
    
    -- try to set the icon as part of this update
    button:SetIcon();

    -- update the charge count on load
    button:UpdateCount(FamilyFrames_CurrentSpells[ii]["type"], spellID);
  end
end

-- creating a new mixin to ape limited functions of the built-in ActionBarActionButtonMixin

FamilyFramesButtonMixin = {};

function FamilyFramesButtonMixin:OnLoad()
  -- try to set the icon here
  self:SetIcon();

  -- Registered Events
	self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW");
	self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE");
  self:RegisterEvent("LOSS_OF_CONTROL_UPDATE");
  self:RegisterEvent("LOSS_OF_CONTROL_ADDED");
  self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
  self:RegisterEvent("SPELL_UPDATE_CHARGES");
  self:RegisterEvent("UPDATE_MACROS");
end

function FamilyFramesButtonMixin:OnEvent(event, ...)
  local idArg = ...;
  local type = self:GetAttribute("type");
  local spellID = self:GetSpellID();
  if (event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW") then
		if (spellID == idArg) then
			ActionButton_ShowOverlayGlow(self);
		end
	elseif (event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE") then
		if (spellID == idArg) then
			ActionButton_HideOverlayGlow(self);
		end
  elseif (event == "LOSS_OF_CONTROL_UPDATE") then
		FamilyFrames_UpdateCooldown(self, type, spellID);
	elseif (event == "ACTIONBAR_UPDATE_COOLDOWN" or event == "LOSS_OF_CONTROL_ADDED") then
		FamilyFrames_UpdateCooldown(self, type, spellID);
  elseif (event == "SPELL_UPDATE_CHARGES") then
		self:UpdateCount();
  elseif (event == "UPDATE_MACROS") then
    if (self:GetAttribute("type") == "macro") then
      self:SetIcon();
      self:UpdateCount();
    end
  end
end

function FamilyFramesButtonMixin:GetSpellID()
  local type, spellName, macroName = self:GetButtonData();
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

function FamilyFramesButtonMixin:UpdateCount()
	local text = self.Count;
  local spellID = self:GetSpellID();
	--[[if ( IsConsumableAction(action) or IsStackableAction(action) or (not IsItemAction(action) and GetActionCount(action) > 0) ) then
		local count = GetActionCount(action);
		if ( count > (self.maxDisplayCount or 9999 ) ) then
			text:SetText("*");
		else
			text:SetText(count);
		end
	else]]--
  if (spellID) then
		local chargeInfo = C_Spell.GetSpellCharges(spellID);
		if (chargeInfo and chargeInfo.maxCharges > 1) then
			text:SetText(chargeInfo.currentCharges);
		else
			text:SetText("");
		end
	end
end

function FamilyFramesButtonMixin:GetButtonData()
  local type = self:GetAttribute("type");
  local spellName = self:GetAttribute("spell");
  local macroName = self:GetAttribute("macro");
  return type, spellName, macroName;
end

function FamilyFramesButtonMixin:GetButtonTexture()
  local type, spellName, macroName = self:GetButtonData();
  local iconID = nil;
  if (type) then
    if (type == "spell") then
      iconID = C_Spell.GetSpellTexture(spellName);
    elseif (type == "macro") then
      _, iconID = GetMacroInfo(macroName);
    end
  end
  return iconID;
end

function FamilyFramesButtonMixin:SetIcon()
  local iconID = self:GetButtonTexture();
  if (iconID) then
    self.icon:SetTexture(iconID);
  end
end

function FamilyFramesButtonMixin:UpdateCooldown(self, actionType, actionID)
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



  -- TODO: need to add cooldown swipe (probably some events)
  -- TODO: need to add charges (probably also events)
  -- TODO: might want to add range check