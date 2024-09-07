local addonName, addonTable = ...;

function addonTable.functions.LoadSavedSettings()
  if (FamilyFrames_SavedSettings) then
    if (FamilyFrames_SavedSettings["Version"] == addonTable["Version"]) then
      -- if the versions match, just load up the settings as they are
      addonTable["Settings"] = FamilyFrames_SavedSettings;
    else
      -- the settings are for an old version, so we'll need to update them incrementally
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
end

function addonTable.functions.CreateSettingsPanel()
  local profile = "General"; -- TODO: this should vary
  local category = Settings.RegisterVerticalLayoutCategory("Family Frames");

  do
    local name = "Button Scale (%)";
	  local variable = "FamilyFrames_ButtonScaleSetting";
    local defaultValue = 100;
    local minValue = 10;
    local maxValue = 200;
    local step = 1;

    local function GetValue()
      return addonTable["Settings"]["Profiles"][profile]["Modules"]["SpellBars"]["BarScale"] * 100 or defaultValue;
    end

    local function SetValue(value)
      addonTable["Settings"]["Profiles"][profile]["Modules"]["SpellBars"]["BarScale"] = value / 100;
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