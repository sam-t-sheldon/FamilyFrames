local addonName, addonTable = ...;

-- set up the addonTable structures

-- section for combat warning flag to prevent the combat warning from showing up twice
if (not addonTable["Warnings"]) then
    addonTable["Warnings"] = {};
    addonTable["Warnings"]["Combat"] = {};
end


--local testButton = CreateFrame("Frame", "FFTestActionButton", UIParent, "SecureActionButtonTemplate");
local btn = CreateFrame("Button", "myButton", UIParent, "FFActionButtonTemplate")
--btn:SetAttribute("type", "spell")
--btn:SetAttribute("spell", "Smite")
btn:SetAction("spell", "Power Word: Shield");
--btn:SetAttribute("useOnKeyDown", false)
--btn:RegisterForClicks("AnyUp", "AnyDown")
btn:SetPoint("CENTER", UIParent)