// Set up ds grid to store beacon events
global.__beaconEvents = ds_grid_create(1000, 1000);

var _i = 0;

repeat(ds_grid_width(global.__beaconEvents)){
	global.__beaconEvents[# _i, 0] = "";
	_i++;	
}

// Create a time source to initialize Beacon's controller object
global.__beaconInitTimeSource = time_source_create(time_source_global, 1, time_source_units_frames, __beacon_init, [], 1);

function __beacon_init(){
	instance_create_depth(0, 0, 0, __beaconController);	
}

time_source_start(global.__beaconInitTimeSource);

/// @desc Sorts the event row in the grid to ensure all `0`s are at the end
/// @param {real} eventIndex The index of the event row to sort
function __beacon_event_compact(_eventIndex){
    var _subscribers = [];
    var _a = 1; // Start from 1 since 0 is the event name

    // Collect all non-zero entries
    repeat(ds_grid_height(global.__beaconEvents) - 1){
        var _currentEntry = global.__beaconEvents[# _eventIndex, _a];
        
        if (_currentEntry != 0){
            array_push(_subscribers, _currentEntry);
        }
        _a++;
    }

    // Place non-zero entries back and fill the rest with zeros
    _a = 1;
    for (var _i = 0; _i < array_length(_subscribers); _i++){
        global.__beaconEvents[# _eventIndex, _a] = _subscribers[_i];
        _a++;
    }
    
    // Fill the remaining cells with zeros
    repeat(ds_grid_height(global.__beaconEvents) - _a){
        global.__beaconEvents[# _eventIndex, _a] = 0;
        _a++;
    }
}

