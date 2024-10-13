local addonName, addonTable = ...;

function addonTable.functions.LoadSavedSettings()
  if (FamilyFrames_SavedSettings) then
    if (FamilyFrames_SavedSettings["Version"] == addonTable["Version"]) then
      -- if the versions match, just load up the settings as they are
      addonTable["Settings"] = FamilyFrames_SavedSettings;
    else
      -- the settings are for an old version, so we'll need to update them incrementally
      addonTable.functions.UpgradeSettings(FamilyFrames_SavedSettings["Version"], addonTable["Version"]);
      addonTable["Settings"] = FamilyFrames_SavedSettings;
    end
  else
    -- load the default settings
    addonTable.functions.LoadDefaultSettings();
  end
end

function addonTable.functions.SaveSettings()
  FamilyFrames_SavedSettings = addonTable["Settings"];
end

function addonTable.functions.GetDefaultSettings()
  local defaults = {
    ["Version"] = addonTable["Version"],
    ["Profiles"] = {
      ["General"] = {
        ["Modules"] = {
          ["SpellBars"] = {
            ["Enabled"] = true,
            ["FrameAnchorPoint"] = "TOPRIGHT",
            ["BarAnchorPoint"] = "TOPLEFT",
            ["BarScale"] = 1,
            ["SpellLists"] = {}
          }
        }
      }
    }
  };

  -- generate the empty SpellLists
  for classID = 1, GetNumClasses(), 1 do
    defaults["Profiles"]["General"]["Modules"]["SpellBars"]["SpellLists"][classID] = {};
    for specIndex = 1, GetNumSpecializationsForClassID(classID), 1 do
      defaults["Profiles"]["General"]["Modules"]["SpellBars"]["SpellLists"][classID][specIndex] = {};
      for ii = 1, 15, 1 do
        defaults["Profiles"]["General"]["Modules"]["SpellBars"]["SpellLists"][classID][specIndex][ii] = {
          ["type"] = nil,
          ["spell"] = nil,
          ["macro"] = nil
        };
      end
    end
  end
  return defaults;
end

function addonTable.functions.LoadDefaultSettings()
  addonTable["Settings"] = addonTable.functions.GetDefaultSettings();
  addonTable["Settings"]["CurrentProfile"] = "General";
  addonTable.functions.PrintInfo("Default settings loaded.");
end

function addonTable.functions.CreateSettingsPanel()
  local category = Settings.RegisterVerticalLayoutCategory("Family Frames");

  do
    local name = "Button Scale (%)";
	  local variable = "FamilyFrames_ButtonScaleSetting";
    local defaultValue = 100;
    local minValue = 10;
    local maxValue = 200;
    local step = 1;

    local function GetValue()
      return addonTable["Settings"]["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["SpellBars"]["BarScale"] * 100 or defaultValue;
    end

    local function SetValue(value)
      addonTable["Settings"]["Profiles"][addonTable["Settings"]["CurrentProfile"]]["Modules"]["SpellBars"]["BarScale"] = value / 100;
      C_EventUtils.NotifySettingsLoaded();
    end

    local setting = Settings.RegisterProxySetting(category, variable, type(defaultValue), name, defaultValue, GetValue, SetValue);
    
    local tooltip = "Scale of the spell bar buttons (this is in addition to your general UI scaling)";
    local options = Settings.CreateSliderOptions(minValue, maxValue, step);
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
    Settings.CreateSlider(category, setting, options, tooltip);
  end

  Settings.RegisterAddOnCategory(category);
end

function addonTable.functions.UpgradeSettings(savedVersion, currentVersion)
  if (savedVersion == "0.1.0") then
    -- upgrade to 0.1.1
    FamilyFrames_SavedSettings["CurrentProfile"] = "General";
    FamilyFrames_SavedSettings["Version"] = "0.1.1";
  end
  if (savedVersion == "0.1.1") then
    FamilyFrames_SavedSettings["Version"] = "0.1.2";
  end
  if (savedVersion == "0.1.2") then
    FamilyFrames_SavedSettings["Version"] = "0.1.3";
  end
  addonTable.functions.PrintInfo("Settings updated for version "..currentVersion);
end