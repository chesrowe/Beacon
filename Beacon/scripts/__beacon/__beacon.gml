/// @title Event Functions
/// @category API Reference

/// @func beacon_event_subscribe(eventName, callback)
/// @desc Subscribes the calling instance to the given event with the given callback
/// @param {string} eventName The name of the event to subscribe the instance to
/// @param {function} callback The callback function to execute for this instance when the event is broadcasted
function beacon_event_subscribe(_eventName, _callback){
	var _i = 0;
	
	// Either find an existing event or create a new one
	repeat(ds_grid_width(global.__beaconEvents)){
		var _currentEvent = global.__beaconEvents[# _i, 0];
		
		// Existing event found
		if (_currentEvent == _eventName){
			var _a = 0;
			
			repeat(ds_grid_height(global.__beaconEvents)){
				if (global.__beaconEvents[# _i, _a] == 0){
					global.__beaconEvents[# _i, _a] = [id, _callback];
					break;
				}
				
				_a++;
			}
		// No existing event found, create a new one
		}else if (_currentEvent == ""){
			global.__beaconEvents[# _i, 0] = _eventName;
			global.__beaconEvents[# _i, 1] = [id, _callback];
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
/// @desc Broadcasts the given event to all instances subscribed to it
/// @param {string} eventName The name of the event to broadcast
/// @param {any} [metadata] The metadata to pass to the callback functions
function beacon_event_broadcast(_eventName, _metadata){
	var _i = 0;
	
	repeat(ds_grid_width(global.__beaconEvents)){
		if (global.__beaconEvents[# _i, 0] == _eventName){
			var _a = 1;
			
			repeat(ds_grid_height(global.__beaconEvents)){
				var _currentSubscriberArray = global.__beaconEvents[# _i, _a];
				
				if (global.__beaconEvents[# _i, _a] != 0){
					var _instance = _currentSubscriberArray[0];
					var _callback = _currentSubscriberArray[1];
					
					_callback(_eventName, _metadata);
					break;
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
function beacon_event_broadcast_region(_eventName, _x, _y, _radius, _metadata){
	var _i = 0;
	
	repeat(ds_grid_width(global.__beaconEvents)){
		if (global.__beaconEvents[# _i, 0] == _eventName){
			var _a = 1;
			
			repeat(ds_grid_height(global.__beaconEvents)){
				var _currentSubscriberArray = global.__beaconEvents[# _i, _a];
				
				if (global.__beaconEvents[# _i, _a] != 0){
					var _instance = _currentSubscriberArray[0];
					var _callback = _currentSubscriberArray[1];
					
					if (point_distance(_x, _y, _instance.x, _instance.y) <= _radius){
						_callback(_eventName, _metadata);
					}
				}
				
				_a++;
			}
		}
		
		_i++;
	}
}


