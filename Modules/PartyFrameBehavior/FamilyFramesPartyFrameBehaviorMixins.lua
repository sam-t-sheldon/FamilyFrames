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
    -- manually update buff sizes in case that changed
    CompactPartyFrame:RefreshMembers();
  end
end

function FamilyFramesPartyFrameBehaviorEventMixin:Init()
  -- set up showing the raid style frames while solo
  hooksecurefunc(CompactPartyFrame, "UpdateVisibility", FamilyFrames_ShowPartyFramesWhileSolo);
  -- hook to move buffs to the left of the frame (TODO: specific anchor should be a setting) (see CompactUnitFrame.lua)
  hooksecurefunc("DefaultCompactUnitFrameSetup", FamilyFrames_MoveBuffs);
  hooksecurefunc("DefaultCompactUnitFrameSetup", FamilyFrames_MoveDebuffs);
  --hooksecurefunc("DefaultCompactUnitFrameSetup", FamilyFrames_MoveDispelDebuffs); -- may not need this at the moment
  -- TODO: do we need private aura anchor tweaks as well?
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

function addonTable.functions.GetOuterBuffSize(frame)
  local showOuterBuffs = FamilyFrames_SavedSettings["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["PartyFrameBehavior"]["ShowBuffsOutside"];
  local showOuterDebuffs = FamilyFrames_SavedSettings["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["PartyFrameBehavior"]["ShowDebuffsOutside"];
  if (showOuterBuffs and showOuterDebuffs) then
    return frame:GetHeight() / 2 - 2;
  else -- if neither are shown, none of this matters anyway
    return frame:GetHeight() - 2;
  end
end

function FamilyFrames_MoveBuffs(frame)
  if (FamilyFrames_SavedSettings["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["PartyFrameBehavior"]["ShowBuffsOutside"]) then
    -- TODO: custom max buffs number
    -- TODO: adjust buff size based on if debuffs are also shown on left
    local buffSize = addonTable.functions.GetOuterBuffSize(frame);
    local buffPos, buffRelativePoint, buffOffset = "TOPRIGHT", "TOPLEFT", CUF_AURA_BOTTOM_OFFSET * -1;
    frame.buffFrames[1]:ClearAllPoints();
    frame.buffFrames[1]:SetPoint(buffPos, frame, "TOPLEFT", -2, buffOffset);
    for i=1, #frame.buffFrames do
      if ( i > 1 ) then
        frame.buffFrames[i]:ClearAllPoints();
        frame.buffFrames[i]:SetPoint(buffPos, frame.buffFrames[i - 1], buffRelativePoint, 0, 0);
      end
      frame.buffFrames[i]:SetSize(buffSize, buffSize);
    end
  end
end

function FamilyFrames_MoveDebuffs(frame)
  if (FamilyFrames_SavedSettings["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["PartyFrameBehavior"]["ShowDebuffsOutside"]) then
    -- TODO: custom max debuffs number
    -- TODO: adjust debuff size based on if buffs are also shown on left
    local debuffSize = addonTable.functions.GetOuterBuffSize(frame);
    local debuffPos, debuffRelativePoint, debuffOffset = "BOTTOMRIGHT", "BOTTOMLEFT", CUF_AURA_BOTTOM_OFFSET;
    frame.debuffFrames[1]:ClearAllPoints();
    frame.debuffFrames[1]:SetPoint(debuffPos, frame, "BOTTOMLEFT", -2, debuffOffset);
    for i=1, #frame.debuffFrames do
      if ( i > 1 ) then
        frame.debuffFrames[i]:ClearAllPoints();
        frame.debuffFrames[i]:SetPoint(debuffPos, frame.debuffFrames[i - 1], debuffRelativePoint, 0, 0);
      end
      frame.debuffFrames[i].baseSize = debuffSize;
      frame.debuffFrames[i].maxHeight = debuffSize;
      --frame.debuffFrames[i]:SetSize(debuffSize, debuffSize);
    end
    -- TODO: not sure if this is where I should handle the private aura anchors, but it seems to be messing with apparent debuff sizing
    if frame.PrivateAuraAnchors then
      for _, privateAuraAnchor in ipairs(frame.PrivateAuraAnchors) do
        privateAuraAnchor:SetSize(debuffSize, debuffSize);
      end
    end
  end
end

function FamilyFrames_MoveDispelDebuffs(frame)
  if (true) then -- TODO: setting for this
    
  end
end