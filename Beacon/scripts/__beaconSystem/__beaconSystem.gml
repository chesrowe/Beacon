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