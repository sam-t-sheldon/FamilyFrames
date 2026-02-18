local addonName, addonTable = ...;

-- Base action button mixin
FFActionButtonMixin = {};

function FFActionButtonMixin:OnLoad()
    -- register events
    self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
    self:RegisterEvent("LOSS_OF_CONTROL_ADDED");

    -- register drag-and-drop
	self:RegisterForDrag("LeftButton", "RightButton");

    -- temp - set whether or not the cooldown numbers show
    ActionButton_UpdateCooldownNumberHidden(self);
end

function FFActionButtonMixin:OnEvent(event, ...)
    local idArg = ...;
    local type = self:GetAttribute("type");
    local spellID = self:GetSpellID();
    if (event == "ACTIONBAR_UPDATE_COOLDOWN" or event == "LOSS_OF_CONTROL_ADDED") then
        self:UpdateCooldown();
    end
end

function FFActionButtonMixin:GetSpellID()
    return C_Spell.GetSpellIDForSpellIdentifier(self:GetAttribute("spell"));
end

function FFActionButtonMixin:SetAction(type, identifier)
    -- restrict in combat lockdown
    if (addonTable.functions.RestrictInCombat()) then
        return;
    end

    self:SetAttribute("type", type);
    if (type == "spell") then
        local spellName = C_Spell.GetSpellName(identifier);
        local iconID = C_Spell.GetSpellTexture(identifier);
        self:SetAttribute("spell", spellName);
        self:SetIcon(iconID);
    elseif (type == "macro") then
        local macroName, macroIconID = GetMacroInfo(identifier);
        self:SetAttribute("macro", macroName);
        self:SetIcon(macroIconID);
    -- TODO: items
    end
end

function FFActionButtonMixin:SetUnit(target, useParent)
    -- restrict in combat lockdown
    if (addonTable.functions.RestrictInCombat()) then
        return;
    end

    -- TODO: target settings
end

function FFActionButtonMixin:SetIcon(iconID)
    -- restrict in combat lockdown
    if (addonTable.functions.RestrictInCombat()) then
        return;
    end

    if (iconID) then
        self.icon:SetTexture(iconID);
    else
        self.icon:SetTexture(nil);
    end
end

-- based on the Blizzard function ActionButton_UpdateCooldown, updated to refer to the current non-action-bar button
function FFActionButtonMixin:UpdateCooldown()
    local defaultCooldownInfo = { startTime = 0; duration = 0; isEnabled = false; modRate = 0 };
    local defaultChargeInfo = { currentCharges = 0; maxCharges = 0; cooldownStartTime = 0; cooldownDuration = 0; chargeModRate = 0 };
    local defaultLossOfControlInfo = { startTime = 0; duration = 0; modRate = 0 };

    local chargeInfo;
    local cooldownInfo;
    local lossOfControlInfo  = {};
    local actionType = self:GetAttribute("type");
    local actionID = nil;
    if (actionType == "spell") then
        actionID = self:GetSpellID();
    end
    local auraData = nil;
    local passiveCooldownSpellID = nil;
    local onEquipPassiveSpellID = nil;

    if ((actionType and actionType == "spell") and actionID) then
        passiveCooldownSpellID = C_UnitAuras.GetCooldownAuraBySpellID(actionID);
    end

    if(passiveCooldownSpellID and passiveCooldownSpellID ~= 0) then
		auraData = C_UnitAuras.GetPlayerAuraBySpellID(passiveCooldownSpellID);
	end

    if(auraData) then
		local currentTime = GetTime();
		local timeUntilExpire = auraData.expirationTime - currentTime;
		local howMuchTimeHasPassed = auraData.duration - timeUntilExpire;

		lossOfControlInfo.startTime =  currentTime - howMuchTimeHasPassed;
		lossOfControlInfo.duration = auraData.expirationTime - currentTime;
		lossOfControlInfo.modRate = auraData.timeMod;
		cooldownInfo = {};
		cooldownInfo.startTime = currentTime - howMuchTimeHasPassed;
		cooldownInfo.duration =  auraData.duration
		cooldownInfo.modRate = auraData.timeMod;
		cooldownInfo.isEnabled = 1;
		chargeInfo = defaultChargeInfo; -- auraData does not contain charge counts
    elseif ((actionType and actionType == "spell") and actionID) then
        cooldownInfo = C_Spell.GetSpellCooldown(actionID) or defaultCooldownInfo;
        chargeInfo = C_Spell.GetSpellCharges(actionID) or defaultChargeInfo;

        local locStart, locDuration = C_Spell.GetSpellLossOfControlCooldown(actionID);
        lossOfControlInfo.startTime = locStart;
		lossOfControlInfo.duration = locDuration;
		lossOfControlInfo.modRate = cooldownInfo.modRate;
    end

    ActionButton_ApplyCooldown(self.cooldown, cooldownInfo, self.chargeCooldown, chargeInfo, self.lossOfControlCooldown, lossOfControlInfo);
end

function FFActionButtonMixin:OnDragStart()
    -- check modifier key and drag only if allowed
    if (not Settings.GetValue("lockActionBars") or IsModifiedClick("PICKUPACTION")) then
        self:PickupAction();
    end
end

function FFActionButtonMixin:OnDragStop()

end

function FFActionButtonMixin:OnReceiveDrag()
    self:PlaceAction();
end

function FFActionButtonMixin:PreClick()

end

function FFActionButtonMixin:PostClick()

end

function FFActionButtonMixin:PickupAction()
    -- restrict in combat lockdown
    if (addonTable.functions.RestrictInCombat()) then
        return;
    end

    -- TODO: pick up button contents to cursor

    -- TODO: dispatch event
end

function FFActionButtonMixin:PlaceAction()
    -- restrict in combat lockdown
    if (addonTable.functions.RestrictInCombat()) then
        return;
    end

    -- TODO: place cursor contents to button if able

    -- TODO: dispatch event
end