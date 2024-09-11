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
		CreateFrame("Frame", "FamilyFramesSpellBarContainer", UIParent, "FamilyFramesSpellBarContainerTemplate");
  elseif (event == "PLAYER_REGEN_ENABLED") then
    -- clear any combat warnings
    addonTable["Warnings"]["Combat"] = {};
  end
end

FamilyFramesSpellBarContainerMixin = {};

function FamilyFramesSpellBarContainerMixin:UpdateAllButtons()
  for ii, spellBar in pairs(self.spellBars) do
    spellBar:SetButtonAttributes();
  end
end

-- mixin for the spell bar frame
FamilyFramesSpellBarMixin = {};

function FamilyFramesSpellBarMixin:OnLoad()
  self:Hide();

  self:LoadSettings();

  -- testing setting an anchor frame with secure handlers
  self:SetAttribute("_onattributechanged", [=[
    -- check if this is adding a frame reference and populate value if so
    local isFrameRef = false;
    local frameRefName = nil;
    if (name:match("frameref%-.+")) then
      -- value is nil, since the original type is userdata
      -- We can fix that by asking for the frame ref:
      frameRefName = name:match("frameref%-(.+)");
      value = self:GetFrameRef(frameRefName);
      isFrameRef = true;
    end
    if (isFrameRef and frameRefName == "ffanchorframe") then
      -- Now set the anchor point and initial visibility
      -- TODO: need to get the settings for anchor points in here by setting attributes before this
      self:SetPoint("TOPLEFT", value, "TOPRIGHT", 5, 0);
      -- set visibility now that we have an anchor
      -- get the raid style value we got from LoadSettings
      local usingRaidStyle = self:GetAttribute("ffusingraidstyle");
      local currentState = self:GetAttribute("state-ffsshowframe");
      if (currentState == "show" and value:IsVisible()) then
        self:Show();
      elseif (value == "grouped") then
        if (usingRaidStyle) then
          self:Hide();
        else
          self:Show();
        end
      else
        self:Hide();
      end
    end
    
    -- STATE (handling this manually because the state and attribute templates can't seem to get along)
    if (name == "state-ffsshowframe") then
      -- get the anchor frame to check if it's visible as well
      local anchorFrame = self:GetFrameRef("ffanchorframe");
      -- get the raid style value we got from LoadSettings
      local usingRaidStyle = self:GetAttribute("ffusingraidstyle");
      if (not anchorFrame) then
        -- always hide if we don't have an anchor frame
        self:Hide();
      elseif (value == "show" and anchorFrame:IsVisible()) then
        self:Show();
      elseif (value == "grouped") then
        -- this can only be player frame, need to hide if we're using raid style
        if (usingRaidStyle) then
          self:Hide();
        else
          self:Show();
        end
      else
        self:Hide();
      end
    end
  ]=]);

  -- make the macro conditional for this using this frame's unit attribute
  local showConditional = "[@"..self:GetAttribute("unit")..",exists] show; hide";
  -- special show condition for player frame
  if (self.anchorFrameName == "PlayerFrame") then
    showConditional = "[@"..self:GetAttribute("unit")..",exists,nogroup] show; [@"..self:GetAttribute("unit")..",exists] grouped; hide";
  end
  RegisterStateDriver(self, "ffsshowframe", showConditional);

  self:SetAnchor();
  self:SetButtonAttributes();

	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("INSTANCE_GROUP_SIZE_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
  self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
  self:RegisterEvent("SETTINGS_LOADED");
  self:RegisterEvent("PLAYER_REGEN_ENABLED");
end

function FamilyFramesSpellBarMixin:LoadSettings()
  if (InCombatLockdown()) then
    addonTable.functions.PrintCombatWarning("Cannot update settings while in combat. Changes will be loaded when combat ends.", "SpellBarSettings");
    return;
  end
  self:SetScale(addonTable["Settings"]["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["SpellBars"]["BarScale"]);
  self:SetAttribute("ffusingraidstyle", EditModeManagerFrame:UseRaidStylePartyFrames());
  self:SetButtonAttributes();
end

function FamilyFramesSpellBarMixin:OnEvent(event, ...)
  local arg1 = ...;
	if (event == "GROUP_ROSTER_UPDATE" or event == "INSTANCE_GROUP_SIZE_CHANGED" or event == "PLAYER_ENTERING_WORLD") then
		-- rerun the anchor and visibility code in case of frame changes
		self:SetAnchor();
  elseif (event == "PLAYER_SPECIALIZATION_CHANGED") then
    if (arg1 == "player") then
      -- rerun anything different per spec
      self:SetButtonAttributes();
    end
  elseif (event == "SETTINGS_LOADED") then
    self:LoadSettings();
  elseif (event == "PLAYER_REGEN_ENABLED") then
    -- load the settings in case they were changed in combat
    self:LoadSettings();
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
  SecureHandlerSetFrameRef(self, "ffanchorframe", self:GetAnchorFrame());
end

function FamilyFramesSpellBarMixin:SetButtonAttributes()
  if (InCombatLockdown()) then
    addonTable.functions.PrintCombatWarning("Cannot change spell bars in combat.", "SpellBarChange");
    return;
  end
  local currentSpells = addonTable.functions.GetCurrentSpellBarSpells();
  if (currentSpells) then
    for ii, button in pairs(self.buttons) do
      button:SetAttribute("type1", currentSpells[ii]["type"]);
      button:SetAttribute("spell", currentSpells[ii]["spell"]);
      button:SetAttribute("macro", currentSpells[ii]["macro"]);
      button:SetAttribute("unit", self.targetUnit);
      local spellID = button:GetSpellID();
      
      -- try to set the icon as part of this update
      button:SetIcon();

      -- update the charge count when first setting
      button:UpdateCount(currentSpells[ii]["type"], spellID);
    end
  end
end

-- creating a new mixin to ape limited functions of the built-in ActionBarActionButtonMixin

FamilyFramesButtonMixin = {};

function FamilyFramesButtonMixin:OnLoad()
  -- try to set the icon here
  self:SetIcon();

  -- register for drag
  self:RegisterForDrag("LeftButton");

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

function FamilyFramesButtonMixin:OnDragStart()
  -- TODO: check modifier key and see if we're allowed to drag
  self:PickupAction();
end

function FamilyFramesButtonMixin:OnDragStop()
  self:AllowButtonClicksAfterChanging();
end

function FamilyFramesButtonMixin:PickupAction()
  if (InCombatLockdown()) then
    addonTable.functions.PrintCombatWarning("Cannot change spell bars in combat.", "SpellBarChange");
    return;
  end
  -- some general info we'll need
  local classID, specIndex = addonTable.functions.GetClassAndSpecInfo();
  -- pick up the spell from the button, removing it from the slot
  -- TODO: only do this while the modifier key is held down
  local type, spellName, macroName = self:GetButtonData();
  if (type == "spell") then
    local spellID = self:GetSpellID();
    C_Spell.PickupSpell(spellID);
    addonTable["Settings"]["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["SpellBars"]["SpellLists"][classID][specIndex][self.spellBarSlot]["type"] = nil;
    addonTable["Settings"]["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["SpellBars"]["SpellLists"][classID][specIndex][self.spellBarSlot]["spell"] = nil;
    addonTable["Settings"]["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["SpellBars"]["SpellLists"][classID][specIndex][self.spellBarSlot]["macro"] = nil;
  elseif (type == "macro") then
    PickupMacro(macroName);
    addonTable["Settings"]["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["SpellBars"]["SpellLists"][classID][specIndex][self.spellBarSlot]["type"] = nil;
    addonTable["Settings"]["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["SpellBars"]["SpellLists"][classID][specIndex][self.spellBarSlot]["spell"] = nil;
    addonTable["Settings"]["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["SpellBars"]["SpellLists"][classID][specIndex][self.spellBarSlot]["macro"] = nil;
  end
  self:GetParent():GetParent():UpdateAllButtons();
  addonTable.functions.SaveSettings();
  self:PreventButtonClicksWhileChanging();
end

function FamilyFramesButtonMixin:PlaceAction()
  if (InCombatLockdown()) then
    addonTable.functions.PrintCombatWarning("Cannot change spell bars in combat.", "SpellBarChange");
    return;
  end
  -- some general info we'll need
  local classID, specIndex = addonTable.functions.GetClassAndSpecInfo();
  -- check the cursor for info on what's being dragged
  local cursorType = GetCursorInfo();
  -- if the item is a spell or macro, place it on the button slot and clear the cursor
  if (cursorType == "spell") then
    local spellID = select(4, GetCursorInfo());
    local spellName = C_Spell.GetSpellName(spellID);
    addonTable["Settings"]["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["SpellBars"]["SpellLists"][classID][specIndex][self.spellBarSlot]["type"] = "spell";
    addonTable["Settings"]["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["SpellBars"]["SpellLists"][classID][specIndex][self.spellBarSlot]["spell"] = spellName;
    addonTable["Settings"]["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["SpellBars"]["SpellLists"][classID][specIndex][self.spellBarSlot]["macro"] = nil;
  --elseif (cursorType == "macro") then
  --  local macroIndex = select(2, GetCursorInfo());
  --  local macroName = GetMacroInfo(macroIndex);
  --  addonTable["Settings"]["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["SpellBars"]["SpellLists"][classID][specIndex][self.spellBarSlot]["type"] = "macro";
  --  addonTable["Settings"]["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["SpellBars"]["SpellLists"][classID][specIndex][self.spellBarSlot]["spell"] = nil;
  --  addonTable["Settings"]["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["SpellBars"]["SpellLists"][classID][specIndex][self.spellBarSlot]["macro"] = macroName;
  end
  self:GetParent():GetParent():UpdateAllButtons();
  ClearCursor();
  addonTable.functions.SaveSettings();
end

function FamilyFramesButtonMixin:OnReceiveDrag()
  self:PlaceAction();
end

function FamilyFramesButtonMixin:PreClick()
  local cursorType = GetCursorInfo();
  if (cursorType == "spell" or cursorType == "macro") then
    self:PlaceAction();
    -- try to make it so the click event doesn't fire, but goes back in the postclick
    self:PreventButtonClicksWhileChanging();
  end
end

function FamilyFramesButtonMixin:PostClick()
  -- try to make it so the click event fires again later
  self:AllowButtonClicksAfterChanging();
end

function FamilyFramesButtonMixin:PreventButtonClicksWhileChanging()
  if (InCombatLockdown()) then
    addonTable.functions.PrintCombatWarning("Cannot change spell bars in combat.", "SpellBarChange");
    return;
  end
  self.slotCurrentlyChanging = true;
  self:SetAttribute("type1", nil);
end

function FamilyFramesButtonMixin:AllowButtonClicksAfterChanging()
  if (InCombatLockdown()) then
    addonTable.functions.PrintCombatWarning("Cannot change spell bars in combat.", "SpellBarChange");
    return;
  end
  if (self.slotCurrentlyChanging) then
    -- some general info we'll need
    local classID, specIndex = addonTable.functions.GetClassAndSpecInfo();

    self:SetAttribute("type1", addonTable["Settings"]["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["SpellBars"]["SpellLists"][classID][specIndex][self.spellBarSlot]["type"]);
    self.slotCurrentlyChanging = false;
  end
end

function FamilyFramesButtonMixin:OnEvent(event, ...)
  local idArg = ...;
  local type = self:GetAttribute("type1");
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
    if (self:GetAttribute("type1") == "macro") then
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
  local type = self:GetAttribute("type1");
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
  else
    self.icon:SetTexture(nil);
  end
end