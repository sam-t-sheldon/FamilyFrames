local addonName, addonTable = ...;

-- Custom event dispatcher based on the Blizzard_Dispatcher functionality, and loosely on how JS events work

addonTable.eventDispatcher = {
    Events = {};
    NextEventId = 1;
};

function addonTable.eventDispatcher:Initialize()
    
end

function addonTable.eventDispatcher:FindEventEntryKeyByFrame(eventName, frame)
    local registeredList = self.Events[eventName];
    if (registeredList == nil) then
        return nil;
    end
    for k, v in pairs(registeredList) do
        if (type(v) == "table") then
            if (v.ID == frame:GetDebugName()) then
                return k;
            end
        end
    end
    return nil;
end

function addonTable.eventDispatcher:_CreateEventEntry(frame, conditions)
    return {
        ID = frame:GetDebugName(); -- TODO: better handling for anonymous frames with no parent (though that's unlikely in my code)
        Callback = frame:GetScript("OnEvent");
        Conditions = conditions;
    };
end

-- Taking the outline of Dispatcher:RegisterEvent
function addonTable.eventDispatcher:Register(eventName, forFrame, conditions)
    -- Unregister existing versions of this event from this owner
    self:Unregister(eventName, forFrame);

    -- Create an empty table if this event hasn't been registered yet
    if (self.Events[eventName] == nil) then
        self.Events[eventName] = {};
    end

    -- Add an entry to the event table for this registration
    local id = self.NextEventId;
    self.Events[eventName][id] = self:_CreateEventEntry(forFrame, conditions);
    self.NextEventId = self.NextEventId + 1;

    return id;
end

function addonTable.eventDispatcher:Unregister(eventName, forFrame)

end

function addonTable.eventDispatcher:Dispatch(eventName, fromFrame, ...)

end

-- mixin that other mixins can branch off of to use the custom event system
FFEventMixin = {};

function FFEventMixin:RegisterFFEvent(eventName, ...)
    addonTable.functions.PrintDebug("Registered for event: "..eventName);
    addonTable.eventDispatcher:Register(eventName, self, ...);
end

function FFEventMixin:UnregisterFFEvent(eventName, ...)
    addonTable.functions.PrintDebug("Unregistered for event: "..eventName);
    addonTable.eventDispatcher:Unregister(eventName, self);
end

function FFEventMixin:DispatchFFEvent(eventName, ...)
    addonTable.functions.PrintDebug("Dispatched event: "..eventName);
    addonTable.eventDispatcher.Dispatch(eventName, self, ...);
end