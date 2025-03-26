local addonName, addonTable = ...;

-- Action buttons require a parent bar of some kind, which has the following functions:
--  SetupButton(button) - responsible for populating the button properties as needed

FamilyFramesActionButtonMixin = {};

-- button load tasks (event registration, etc.)
-- any parent-specific tasks will run in the parent (such as setting specific attributes and placement)
function FamilyFramesActionButtonMixin:OnLoad()
  -- make sure we get the parent to work with as needed
  local parent = self:GetParent();
end

function FamilyFramesActionButtonMixin:OnEvent()

end

-- clears all casting attributes from the button
function FamilyFramesActionButtonMixin:ClearAction()
  self:SetAttribute("type*", nil);
  self:SetAttribute("spell", nil);
  self:SetAttribute("macro", nil);
  self:SetAttribute("item", nil);
end

-- loads a spell on this button
function FamilyFramesActionButtonMixin:SetSpell(spellID)
  self:ClearAction();
  local spellName = C_Spell.GetSpellName(spellID);

  -- populate the necessary attributes
  self:SetAttribute("type*", "spell");
  self:SetAttribute("spell", spellName);

  -- set the icon
  local iconID = C_Spell.GetSpellTexture(spellID);
  self.icon:SetTexture(iconID);
end

-- loads a macro on this button
function FamilyFramesActionButtonMixin:SetMacro(macroID)
  self:ClearAction();
  local macroName, iconID = GetMacroInfo(macroID);

  -- populate the necessary attributes
  self:SetAttribute("type*", "macro");
  self:SetAttribute("macro", macroName);

  -- set the icon
  self.icon:SetTexture(iconID);
end

-- loads an item on this button
function FamilyFramesActionButtonMixin:SetItem(itemID)
  self:ClearAction();
  local itemName = C_Item.GetItemNameByID(itemID);

  -- populate the necessary attributes
  self:SetAttribute("type*", "item");
  self:SetAttribute("item", itemName);

  -- set the icon
  local iconID = C_Item.GetItemIconByID(itemID);
  self.icon:SetTexture(iconID);
end