#region System(don't mess with these)

global.__tomeFileArray = [];
global.__tomeAdditionalSidebarItemsArray = [];
global.__tomeHomepage = "";
global.__tomeLatestDocVersion = "Current-Version";
global.__tomeNavbarItemsArray = [];

#endregion

/*
	Add all the files you wish to be parsed here!
	                                              */
												  
tome_add_script(__beaconEvents);

tome_set_site_description("My site is cool");
tome_set_site_name("mySiteName");
tome_set_site_latest_version("In-Development");
tome_set_site_theme_color("#11DD11");