global.__beaconEvents = ds_grid_create(1000, 2);

var _i = 0;

repeat(ds_grid_width(global.__beaconEvents)){
	global.__beaconEvents[# _i, 0] = "";
	_i++;	
}