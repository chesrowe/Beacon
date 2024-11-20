/// @title Event Functions
/// @category API Reference

/// @func beacon_event_subscribe(eventName, callback)
/// @desc Subscribes the calling instance to the given event with the given callback
/// @param {string} eventName The name of the event to subscribe the instance to
/// @param {function} callback The callback function to execute for this instance when the event is broadcasted
function beacon_event_subscribe(_eventName, _callback){
    var _i = 0;
    var _eventFound = false;

    repeat(ds_grid_width(global.__beaconEvents)){
        var _currentEvent = global.__beaconEvents[# _i, 0];

        // Existing event found
        if (_currentEvent == _eventName){
            var _a = 1; // Start from 1 since 0 is the event name
            
            repeat(ds_grid_height(global.__beaconEvents)){
                if (global.__beaconEvents[# _i, _a] == 0){
                    global.__beaconEvents[# _i, _a] = [id, _callback];
                    _eventFound = true;
                    break;
                }
                _a++;
            }
        }

        // No existing event found, create a new one
        if (!_eventFound && _currentEvent == ""){
            global.__beaconEvents[# _i, 0] = _eventName;
            global.__beaconEvents[# _i, 1] = [id, _callback];
            break;
        }

        if (_eventFound){	
			break;
		}
        
		_i++;
    }
}

/// @func beacon_event_subscribe_temp(eventName, callback, broadcasts)
/// @desc Subscribes the calling instance to the given event with the given callback for a limited number of broadcasts
/// @param {string} eventName The name of the event to subscribe the instance to
/// @param {function} callback The callback function to execute for this instance when the event is broadcasted
/// @param {real} broadcasts The number of broadcasts to listen for before automatically unsubscribing
function beacon_event_subscribe_temp(_eventName, _callback, _broadcasts){
    var _i = 0;
	var _eventFound = false;
    
    // Either find an existing event or create a new one
    repeat(ds_grid_width(global.__beaconEvents)){
        var _currentEvent = global.__beaconEvents[# _i, 0];
        
        // Existing event found
        if (_currentEvent == _eventName){
            var _a = 1; // Start from 1 since 0 is the event name
            
            repeat(ds_grid_height(global.__beaconEvents) - 1){
                if (global.__beaconEvents[# _i, _a] == 0){
                    global.__beaconEvents[# _i, _a] = [id, _callback, _broadcasts];
					_eventFound = true;
                    break;
                }
                _a++;
            }
        }

        // No existing event found, create a new one
        if (_currentEvent == ""){
            global.__beaconEvents[# _i, 0] = _eventName;
            global.__beaconEvents[# _i, 1] = [id, _callback, _broadcasts];
            break;
        }
        
		if (_eventFound){	
			break;
		}
		
        _i++;
    }
}

/// @func beacon_event_unsubscribe(eventName)
/// @desc Unsubscribes the calling instance from the given event
/// @param {string} eventName The name of the event to unsubscribe the instance from
function beacon_event_unsubscribe(_eventName){
	var _i = 0;
	
	repeat(ds_grid_width(global.__beaconEvents)){
		if (global.__beaconEvents[# _i, 0] == _eventName){
			var _a = 0;
			
			repeat(ds_grid_height(global.__beaconEvents)){
				if (global.__beaconEvents[# _i, _a][0] == id){
					global.__beaconEvents[# _i, _a] = 0;
					break;
				}
				
				_a++;
			}
		}
		
		_i++;
	}
}

/// @func beacon_event_broadcast(eventName, [metadata])
/// @desc Broadcasts the given event to all instances subscribed to it and handles temporary subscriptions
/// @param {string} eventName The name of the event to broadcast
/// @param {any} [metadata] The metadata to pass to the callback functions
function beacon_event_broadcast(_eventName, _metadata){
    var _i = 0;

    repeat(ds_grid_width(global.__beaconEvents)){
        if (global.__beaconEvents[# _i, 0] == _eventName){
            var _a = 1; // Start from 1 since 0 is the event name
            
            repeat(ds_grid_height(global.__beaconEvents) - 1){
                var _currentSubscriberArray = global.__beaconEvents[# _i, _a];
                
                if (is_array(_currentSubscriberArray) && _currentSubscriberArray != 0){
                    var _instance = _currentSubscriberArray[0];
                    var _callback = _currentSubscriberArray[1];
                    
                    _callback(_eventName, _metadata);
                    
                    // Handle temporary subscriptions
                    if (array_length(_currentSubscriberArray) == 3){
                        _currentSubscriberArray[2]--;
                        if (_currentSubscriberArray[2] <= 0){
                            global.__beaconEvents[# _i, _a] = 0;
							__beacon_event_compact(_i);
							_a = 0;
                        }
                    }
                }
                _a++;
            }
        }
        _i++;
    }
}

/// @func beacon_event_broadcast_region(eventName, x, y, radius, [metadata])
/// @desc Broadcasts the given event to all instances subscribed to it within the given radius
/// @param {string} eventName The name of the event to broadcast
/// @param {real} x The x coordinate of the center of the broadcast region
/// @param {real} y The y coordinate of the center of the broadcast region
/// @param {real} radius The radius of the broadcast region
/// @param {any} [metadata] The metadata to pass to the callback functions
function beacon_event_broadcast_region(_eventName, _x, _y, _radius, _metadata){
    var _i = 0;

    repeat(ds_grid_width(global.__beaconEvents)){
        if (global.__beaconEvents[# _i, 0] == _eventName){
            var _a = 1; // Start from 1 since 0 is the event name
            
            repeat(ds_grid_height(global.__beaconEvents)){
                // Ensure _a does not exceed the grid height
                if (_a >= ds_grid_height(global.__beaconEvents)) break;
                
                var _currentSubscriberArray = global.__beaconEvents[# _i, _a];
                
                if (is_array(_currentSubscriberArray) && _currentSubscriberArray != 0){
                    var _instance = _currentSubscriberArray[0];
                    var _callback = _currentSubscriberArray[1];
                    
                    if (point_distance(_x, _y, _instance.x, _instance.y) <= _radius){
                        _callback(_eventName, _metadata);
                    }
                }
                _a++;
            }
        }
       
	   // Ensure _i does not exceed the grid width
        if (_i >= ds_grid_width(global.__beaconEvents)) break;
        _i++;
    }
}

/// @func beacon_event_is_subscribed(eventName)
/// @desc Checks if the calling instance is subscribed to the given event
/// @param {string} eventName The name of the event to check subscription for
/// @return {bool} True if the instance is subscribed, otherwise false
function beacon_event_is_subscribed(_eventName){
    var _i = 0;

    repeat(ds_grid_width(global.__beaconEvents)){
        if (global.__beaconEvents[# _i, 0] == _eventName){
            var _a = 1; // Start from 1 since 0 is the event name
            
            repeat(ds_grid_height(global.__beaconEvents) - 1){
                if (is_array(global.__beaconEvents[# _i, _a]) && global.__beaconEvents[# _i, _a][0] == id){
                    return true;
                }
                _a++;
            }
        }
        _i++;
    }
    return false;
}

/// @func beacon_event_clear(eventName)
/// @desc Clears all subscribers from the given event
/// @param {string} eventName The name of the event to clear
function beacon_event_clear(_eventName){
    var _i = 0;

    repeat(ds_grid_width(global.__beaconEvents)){
        if (global.__beaconEvents[# _i, 0] == _eventName){
            var _a = 1; // Start from 1 since 0 is the event name
            
            repeat(ds_grid_height(global.__beaconEvents) - 1){
                global.__beaconEvents[# _i, _a] = 0;
                _a++;
            }
            break;
        }
        _i++;
    }
}

/// @func beacon_event_list_subscribers(eventName)
/// @desc Lists all subscribers to the given event
/// @param {string} eventName The name of the event to list subscribers for
/// @return {array} An array of instance IDs subscribed to the event
function beacon_event_list_subscribers(_eventName){
    var _subscribers = [];
    var _i = 0;

    repeat(ds_grid_width(global.__beaconEvents)){
        if (global.__beaconEvents[# _i, 0] == _eventName){
            var _a = 1; // Start from 1 since 0 is the event name
            
            repeat(ds_grid_height(global.__beaconEvents) - 1){
                var _currentSubscriberArray = global.__beaconEvents[# _i, _a];
                
                if (is_array(_currentSubscriberArray) && _currentSubscriberArray != 0){
                    array_push(_subscribers, _currentSubscriberArray[0]);
                }
                _a++;
            }
            break;
        }
        _i++;
    }
    
	return _subscribers;
}

/// @func beacon_event_broadcast_random_by_prefix(eventPrefix, [metadata])
/// @desc Broadcasts an event to a random instance subscribed to events that start with the given prefix
/// @desc Broadcasts an event to a random instance subscribed to events that start with the given prefix
/// @param {string} eventPrefix The prefix for events to broadcast
/// @param {any} [metadata] The metadata to pass to the callback functions
function beacon_event_broadcast_random_by_prefix(_eventPrefix, _metadata){
    var _matchingEvents = [];
    var _i = 0;

    // Collect all matching events
	var _gridWidth = ds_grid_width(global.__beaconEvents);
	
    repeat (_gridWidth) {
        var _eventName = global.__beaconEvents[# _i, 0];
        
        // Check if the current event starts with the given prefix
        if (string_copy(_eventName, 1, string_length(_eventPrefix)) == _eventPrefix) {
            array_push(_matchingEvents, _eventName);
        }
        
        _i++;
    }

    // Broadcast to a random matching event, if any matches were found
    if (array_length(_matchingEvents) > 0) {
        var _randomIndex = irandom(array_length(_matchingEvents) - 1);
        var _selectedEvent = _matchingEvents[_randomIndex];
        beacon_event_broadcast(_selectedEvent, _metadata);
    }
}

/// @func beacon_event_broadcast_all_by_prefix(eventPrefix, [metadata])
/// @desc Broadcasts an event to all instances subscribed to events that start with the given prefix
/// @param {string} eventPrefix The prefix for events to broadcast
/// @param {any} [metadata] The metadata to pass to the callback functions
function beacon_event_broadcast_all_by_prefix(_eventPrefix, _metadata){
    var _i = 0;

    // Collect all matching events and broadcast
    var _gridWidth = ds_grid_width(global.__beaconEvents);
    
    repeat (_gridWidth) {
        var _eventName = global.__beaconEvents[# _i, 0];
        
        // Check if the current event starts with the given prefix
        if (string_copy(_eventName, 1, string_length(_eventPrefix)) == _eventPrefix) {
            beacon_event_broadcast(_eventName, _metadata);
        }
        
        _i++;
    }
}

/// @func beacon_event_debug_list_all_subscriptions([eventPrefix])
/// @desc Lists all events and their corresponding subscribers for debugging purposes, optionally filtered by a prefix
/// @param {string} [eventPrefix] The prefix to filter events by (optional)
function beacon_event_debug_list_all_subscriptions(_eventPrefix = ""){
    var _i = 0;
    var _totalEvents = 0;
    var _totalSubscribers = 0;
    var _eventsWithoutSubscribers = 0;

    var _gridWidth = ds_grid_width(global.__beaconEvents);
    var _gridHeight = ds_grid_height(global.__beaconEvents);

    repeat (_gridWidth) {
        var _eventName = global.__beaconEvents[# _i, 0];
        
        if (_eventName != "" && _eventName != undefined) {
            if (_eventPrefix == "" || string_copy(_eventName, 1, string_length(_eventPrefix)) == _eventPrefix) {
                var _subscribers = [];
                
                for (var _a = 1; _a < _gridHeight; _a++) {
                    var _subscriber = global.__beaconEvents[# _i, _a];
                    if (is_array(_subscriber) && array_length(_subscriber) > 0) {
                        var _instanceId = _subscriber[0];
                        if (instance_exists(_instanceId)) {
                            var _objectName = object_get_name(_instanceId.object_index);
                            array_push(_subscribers, string(_instanceId) + "(" + _objectName + ")");
                        } else {
                            array_push(_subscribers, string(_instanceId) + "(DESTROYED)");
                        }
                    }
                }

                if (array_length(_subscribers) > 0) {
                    _totalSubscribers += array_length(_subscribers);
                    show_debug_message("Event: " + _eventName + " has subscribers: " + string(array_length(_subscribers)) + " [ " + string(_subscribers) + " ]");
                } else {
                    _eventsWithoutSubscribers++;
                    show_debug_message("Event: " + _eventName + " has no subscribers.");
                }
                _totalEvents++;
            }
        } else {
            // Stop iterating if we reach an empty or undefined event
            break;
        }
        
        _i++;
    }

    // Summary output
    show_debug_message("Total Events: " + string(_totalEvents));
    show_debug_message("Total Subscribers: " + string(_totalSubscribers));
    show_debug_message("Events Without Subscribers: " + string(_eventsWithoutSubscribers));
}

/// @func beacon_event_unsubscribe_by_prefix(eventPrefix)
/// @desc Unsubscribes the calling instance from all events that start with the given prefix
/// @param {string} eventPrefix The prefix for events to unsubscribe from
function beacon_event_unsubscribe_by_prefix(_eventPrefix){
    var _i = 0;
    var _gridWidth = ds_grid_width(global.__beaconEvents);
    var _gridHeight = ds_grid_height(global.__beaconEvents);

    repeat (_gridWidth) {
        var _eventName = global.__beaconEvents[# _i, 0];
        
        // Check if the current event starts with the given prefix
        if (_eventName != "" && _eventName != undefined && string_copy(_eventName, 1, string_length(_eventPrefix)) == _eventPrefix) {
            for (var _a = 1; _a < _gridHeight; _a++) {
                var _subscriber = global.__beaconEvents[# _i, _a];
                if (is_array(_subscriber) && array_length(_subscriber) > 0 && _subscriber[0] == id) {
                    global.__beaconEvents[# _i, _a] = 0;
                    break; // Break early once the instance is unsubscribed
                }
            }
        }
        
        _i++;
    }
}







