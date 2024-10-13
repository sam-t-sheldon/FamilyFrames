local addonName, addonTable = ...;

-- spell bar event mixin (for loading, etc)
FamilyFramesSpellBarEventMixin = {};

function FamilyFramesSpellBarEventMixin:OnLoad()
  
end

function FamilyFramesSpellBarEventMixin:OnEvent(event, ...)

end

function FamilyFramesSpellBarEventMixin:UpdateAllButtons()
  for ii, spellBar in pairs(addonTable.spellBars.frames) do
    spellBar:SetButtonAttributes();
  end
end

function FamilyFramesSpellBarEventMixin:CreateSpellBars()
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

-- mixin for the spell bar frame
FamilyFramesSpellBarMixin = {};

function FamilyFramesSpellBarMixin:OnLoad()
  self:Hide();

  self:LoadSettings();

  self:SetButtonAttributes();

	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("INSTANCE_GROUP_SIZE_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
  self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
  self:RegisterEvent("SETTINGS_LOADED");
  self:RegisterEvent("PLAYER_REGEN_ENABLED");

  self:Show();
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
		-- if we're not in combat, manually check the state on the player frame bars just in case
    if (not InCombatLockdown()) then
      if (addonTable.spellBars.frames["FamilyFramesSpellBarCompactParty1"]:IsVisible()) then
        addonTable.spellBars.frames["FamilyFramesSpellBarPlayer"]:Hide();
      else
        addonTable.spellBars.frames["FamilyFramesSpellBarPlayer"]:Show();
      end
    end
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

function FamilyFramesSpellBarMixin:SetButtonAttributes()
  if (InCombatLockdown()) then
    addonTable.functions.PrintCombatWarning("Cannot change spell bars in combat.", "SpellBarChange");
    return;
  end
  local currentSpells = addonTable.functions.GetCurrentSpellBarSpells();
  if (currentSpells) then
    for ii, button in pairs(self.buttons) do
      button:SetAttribute("type*", currentSpells[ii]["type"]);
      button:SetAttribute("spell", currentSpells[ii]["spell"]);
      button:SetAttribute("macro", currentSpells[ii]["macro"]);
      button:SetAttribute("unit", self.targetUnit);
      local spellID = button:GetSpellID();
      
      -- try to set the icon as part of this update
      button:SetIcon();

      -- update the charge count and check for cooldowns when first setting
      button:UpdateCount(currentSpells[ii]["type"], spellID);
      FamilyFrames_UpdateCooldown(button, currentSpells[ii]["type"], spellID);

      -- TODO: need to check whether or not to show the glow, but for now assuming that it's ok to hide as we'll be out of combat
      ActionButton_HideOverlayGlow(button);
    end
  end
end

-- creating a new mixin to ape limited functions of the built-in ActionBarActionButtonMixin

FamilyFramesSpellBarButtonMixin = {};

function FamilyFramesSpellBarButtonMixin:OnLoad()
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

function FamilyFramesSpellBarButtonMixin:OnDragStart()
  -- check modifier key and see if we're allowed to drag
  if (IsModifiedClick("PICKUPACTION")) then
    self:PickupAction();
  end
end

function FamilyFramesSpellBarButtonMixin:OnDragStop()
  self:AllowButtonClicksAfterChanging();
end

function FamilyFramesSpellBarButtonMixin:PickupAction()
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
  _G["FamilyFramesSpellBarEventFrame"]:UpdateAllButtons();
  addonTable.functions.SaveSettings();
  self:PreventButtonClicksWhileChanging();
end

function FamilyFramesSpellBarButtonMixin:PlaceAction()
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
  elseif (cursorType == "macro") then
    local macroIndex = select(2, GetCursorInfo());
    local macroName, _, macroBody = GetMacroInfo(macroIndex);
    -- check the macroBody for @mouseover, and throw a warning
    local macroHasMo = string.find(macroBody, "@mouseover");
    if (not macroHasMo) then
      addonTable.functions.PrintWarning("The macro you have placed doesn't contain @mouseover, and might not cast on the correct target.");
    end
    addonTable["Settings"]["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["SpellBars"]["SpellLists"][classID][specIndex][self.spellBarSlot]["type"] = "macro";
    addonTable["Settings"]["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["SpellBars"]["SpellLists"][classID][specIndex][self.spellBarSlot]["spell"] = nil;
    addonTable["Settings"]["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["SpellBars"]["SpellLists"][classID][specIndex][self.spellBarSlot]["macro"] = macroName;
  end
  _G["FamilyFramesSpellBarEventFrame"]:UpdateAllButtons();
  ClearCursor();
  addonTable.functions.SaveSettings();
end

function FamilyFramesSpellBarButtonMixin:OnReceiveDrag()
  self:PlaceAction();
end

function FamilyFramesSpellBarButtonMixin:PreClick()
  local cursorType = GetCursorInfo();
  if (cursorType == "spell" or cursorType == "macro") then
    self:PlaceAction();
    -- try to make it so the click event doesn't fire, but goes back in the postclick
    self:PreventButtonClicksWhileChanging();
  end
end

function FamilyFramesSpellBarButtonMixin:PostClick()
  -- try to make it so the click event fires again later
  -- need to only do this if self.slotCurrentlyChanging is true (otherwise we get garbage warnings)
  if (self.slotCurrentlyChanging) then
    self:AllowButtonClicksAfterChanging();
  end
end

function FamilyFramesSpellBarButtonMixin:PreventButtonClicksWhileChanging()
  if (InCombatLockdown()) then
    addonTable.functions.PrintCombatWarning("Cannot change spell bars in combat.", "SpellBarChange");
    return;
  end
  self.slotCurrentlyChanging = true;
  self:SetAttribute("type*", nil);
end

function FamilyFramesSpellBarButtonMixin:AllowButtonClicksAfterChanging()
  if (InCombatLockdown()) then
    addonTable.functions.PrintCombatWarning("Cannot change spell bars in combat.", "SpellBarChange");
    return;
  end
  if (self.slotCurrentlyChanging) then
    -- some general info we'll need
    local classID, specIndex = addonTable.functions.GetClassAndSpecInfo();

    self:SetAttribute("type*", addonTable["Settings"]["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["SpellBars"]["SpellLists"][classID][specIndex][self.spellBarSlot]["type"]);
    self.slotCurrentlyChanging = false;
  end
end

function FamilyFramesSpellBarButtonMixin:OnEvent(event, ...)
  local idArg = ...;
  local type = self:GetAttribute("type*");
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
    if (self:GetAttribute("type*") == "macro") then
      self:SetIcon();
      self:UpdateCount();
    end
	elseif (event == "SPELLS_CHANGED") then
		self:SetIcon();
		self:UpdateCount();
  end
end

function FamilyFramesSpellBarButtonMixin:GetSpellID()
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

function FamilyFramesSpellBarButtonMixin:UpdateCount()
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
  else
    text:SetText("");
	end
end

function FamilyFramesSpellBarButtonMixin:GetButtonData()
  local type = self:GetAttribute("type*");
  local spellName = self:GetAttribute("spell");
  local macroName = self:GetAttribute("macro");
  return type, spellName, macroName;
end

function FamilyFramesSpellBarButtonMixin:GetButtonTexture()
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

function FamilyFramesSpellBarButtonMixin:SetIcon()
  local iconID = self:GetButtonTexture();
  local type, _, macroName = self:GetButtonData();
  if (iconID) then
    self.icon:SetTexture(iconID);
  else
    self.icon:SetTexture(nil);
  end
  -- add a warning icon for macros without mouseover, unless that's turned off in the settings
  if (type == "macro") then
    local _, _, macroBody = GetMacroInfo(macroName);
    local macroHasMo = true; -- assuming the macro's fine until told otherwise
    if (macroBody) then
      macroHasMo = string.find(macroBody, "@mouseover");
    end
    if (macroHasMo) then
      self.warningIcon:Hide();
    else
      self.warningIcon:Show();
    end
  else
    self.warningIcon:Hide();
  end
end