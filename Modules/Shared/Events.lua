local addonName, addonTable = ...;

-- Custom event dispatcher based on the Blizzard_Dispatcher functionality, and loosely on how JS events work

addonTable.eventDispatcher = {
    
};

function addonTable.eventDispatcher:Initialize()
    
end

function addonTable.eventDispatcher:Register(eventName, forFrame, ...)

end

function addonTable.eventDispatcher:UnRegister(eventName, forFrame, ...)

end

function addonTable.eventDispatcher:Dispatch(eventName, fromFrame, ...)

end

-- mixin that other mixins can branch off of to use the custom event system
FFEventMixin = {};

function FFEventMixin:RegisterFFEvent(eventName, ...)
    addonTable.functions.PrintDebug("Registered for event: "..eventName);
    addonTable.eventDispatcher:Register(eventName, self, ...);
end

function FFEventMixin:UnRegisterFFEvent(eventName, ...)
    addonTable.functions.PrintDebug("Unregistered for event: "..eventName);
    addonTable.eventDispatcher:UnRegister(eventName, self, ...);
end

function FFEventMixin:DispatchFFEvent(eventName, ...)
    addonTable.functions.PrintDebug("Dispatched event: "..eventName);
    addonTable.eventDispatcher.Dispatch(eventName, self, ...);
end