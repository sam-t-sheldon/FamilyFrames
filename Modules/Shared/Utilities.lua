local addonName, addonTable = ...;

-- Setup
addonTable.functions = {};

function addonTable.functions.PrintInfo(msg)
    print("|cFF00FF00Family Frames Info: |r"..msg);
end

function addonTable.functions.PrintDebug(msg)
    if (addonTable.debug) then
        print("|cFF00FF00Family Frames Debug: |r"..msg);
    end
end

function addonTable.functions.PrintWarning(msg)
    print("|cFFFF4000Family Frames Warning: |r"..msg);
end

function addonTable.functions.PrintCombatWarning(msg, warning, force)
    if (not addonTable["Warnings"]["Combat"][warning] or force) then
        addonTable.functions.PrintWarning(msg);
        addonTable["Warnings"]["Combat"][warning] = true;
    end
end

function addonTable.functions.RestrictInCombat(...)
    local msg, warning, force = ...;
    if (InCombatLockdown()) then
        if (not msg) then
            msg = "This action cannot be done while in combat.";
        end
        if (not warning) then
            warning = "Generic";
        end
        addonTable.functions.PrintCombatWarning(msg, warning, force);
        return true;
    else
        return false;
    end
end