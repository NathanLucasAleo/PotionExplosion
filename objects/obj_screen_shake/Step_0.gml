f *= .9;
view_set_xport(0, random_range(-f, f));
view_set_yport(0, random_range(-f, f));

if (f <= 1){
	instance_destroy();	
}