local addonName, addonTable = ...;

-- general event catching (for party numbers changing, instance type, etc)
FamilyFramesPartyFrameBehaviorEventMixin = {};

function FamilyFramesPartyFrameBehaviorEventMixin:OnLoad()
  self:RegisterEvent("SETTINGS_LOADED");
end

function FamilyFramesPartyFrameBehaviorEventMixin:OnEvent(event, ...)
  local arg1 = ...;
  
  if (event == "SETTINGS_LOADED") then
    -- force check the visibility on CompactPartyFrame
    CompactPartyFrame:UpdateVisibility();
  end
end

function FamilyFramesPartyFrameBehaviorEventMixin:Init()
  -- set up showing the raid style frames while solo
  hooksecurefunc(CompactPartyFrame, "UpdateVisibility", FamilyFrames_ShowPartyFramesWhileSolo);
end

function FamilyFrames_ShowPartyFramesWhileSolo()
  if (FamilyFrames_SavedSettings["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["PartyFrameBehavior"]["ShowSolo"]) then
    -- only override if we're not in a group
    local solo = not IsInGroup();
    local usingRaidFrames = EditModeManagerFrame:UseRaidStylePartyFrames();
    if (solo and usingRaidFrames) then
      -- run the UpdateVisibility function (CompactPartyFrame.lua) contents again, but forcing true
      CompactPartyFrame:SetShown(true);
      PartyFrame:UpdatePaddingAndLayout();
      -- TODO: mana bars aren't showing up solo - this is because the player isn't technically classified as healer outside of the group, so we need to figure out a workaround
      -- one idea here might be to hijack the only healer/everyone power bar setting, so if it's set to healer only it gets changed when entering/leaving groups
    end
  end
end

