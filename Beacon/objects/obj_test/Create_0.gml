beacon_event_subscribe("testEvent", function(event, data){
    show_message(event + " " + data);
});