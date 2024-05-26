//if (irandom(1)){
//	beacon_event_subscribe("testEvent", function(_event, _data){
//		show_message(_event + " " + _data);	
//	});
//}

beacon_event_subscribe_temp("testEvent", function(event, data){
    show_message(event + " " + data);
}, 2);