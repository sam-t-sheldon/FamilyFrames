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
		print("FamilyFrames loaded.");
		-- initialize the spell bars (TODO: have this be a setting)
		CreateFrame("Frame", "FamilyFramesSpellBarContainer", UIParent, "FamilyFramesSpellBarContainerTemplate");
  end
end

-- mixin for the spell bar frame
FamilyFramesSpellBarMixin = {};

function FamilyFramesSpellBarMixin:OnLoad()
  self:Hide();
  self:SetScale(1); -- for resizing later

  self:SetAnchor();
  self:SetVisibility();
  self:SetButtonAttributes();

	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("INSTANCE_GROUP_SIZE_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function FamilyFramesSpellBarMixin:OnEvent(event, ...)
	if (event == "GROUP_ROSTER_UPDATE" or event == "INSTANCE_GROUP_SIZE_CHANGED" or event == "PLAYER_ENTERING_WORLD") then
		-- rerun the anchor and visibility code in case of frame changes
		self:SetAnchor();
		self:SetVisibility();
	end
end

function FamilyFramesSpellBarMixin:GetAnchorFrame()
	local anchorFrameName, anchorFrameChildName = nil, nil;
	local anchorFrameSplit = FamilyFrames_StringSplit(self.anchorFrameName, "%.");
	if (anchorFrameSplit) then
		anchorFrameName = anchorFrameSplit[1];
		anchorFrameChildName = anchorFrameSplit[2];
	else
		anchorFrameName = self.anchorFrameName;
	end
	local anchorFrame = _G[anchorFrameName];
	if (anchorFrame) then
		if (anchorFrameChildName) then
			anchorFrame = anchorFrame[anchorFrameChildName];
		end
	end
	return anchorFrame;
end

function FamilyFramesSpellBarMixin:SetAnchor()
  -- check if the designated anchor frame exists
  --local anchorFrame = _G[self.anchorFrameName];
	local anchorFrame = self:GetAnchorFrame();
  if (anchorFrame) then
    self:SetPoint(FamilyFrames_SpellBarAnchorPoint, anchorFrame, FamilyFrames_AnchorSpellBarsTo, 5, 0);
  end
end

function FamilyFramesSpellBarMixin:SetVisibility()
  -- check if our anchor frame exists and is visible, then match that
  -- one exception - if we're in raid style party frames, don't show on our player frame spell bar
  if (self.anchorFrameName == "PlayerFrame" and EditModeManagerFrame:UseRaidStylePartyFrames() and GetNumGroupMembers() > 0) then
    self:Hide();
  else
    --local anchorFrame = _G[self.anchorFrameName];
		local anchorFrame = self:GetAnchorFrame();
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

    -- update the charge count when first setting
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
	self:RegisterEvent("SPELLS_CHANGED");
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
	elseif (event == "SPELLS_CHANGED") then
		self:SetIcon();
		self:UpdateCount();
  end
end

function FamilyFramesButtonMixin:GetSpellID()
  local type, spellName, macroName = self:GetButtonData();
  local spellID = nil;
	--print(spellName);
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