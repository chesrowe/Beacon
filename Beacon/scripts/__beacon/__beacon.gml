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
/// @param {number} broadcasts The number of broadcasts to listen for before automatically unsubscribing
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

// `beacon_event_broadcast_region(string event, real x, real y, real radius, [metadata]`: Broadcasts an event at a specific point, and only subscribing instances within the given circular radius are affected.
/// @func beacon_event_broadcast_region(eventName, x, y, radius, [metadata])
/// @desc Broadcasts the given event to all instances subscribed to it within the given radius
/// @param {string} eventName The name of the event to broadcast
/// @param {number} x The x coordinate of the center of the broadcast region
/// @param {number} y The y coordinate of the center of the broadcast region
/// @param {number} radius The radius of the broadcast region
/// @param {any} [metadata] The metadata to pass to the callback functions


/// @func beacon_event_broadcast_region(eventName, x, y, radius, [metadata])
/// @desc Broadcasts the given event to all instances subscribed to it within the given radius
/// @param {string} eventName The name of the event to broadcast
/// @param {number} x The x coordinate of the center of the broadcast region
/// @param {number} y The y coordinate of the center of the broadcast region
/// @param {number} radius The radius of the broadcast region
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
/// @return {boolean} True if the instance is subscribed, otherwise false
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





