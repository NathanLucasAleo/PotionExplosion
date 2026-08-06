function create_screen_shake(_f){
	if (!instance_exists(obj_screen_shake)){
		instance_create_layer(0, 0, "Controller", obj_screen_shake, {
			f : _f	
		})	
	}else{
		obj_screen_shake.f = _f;	
	}
}

function create_popup(_x, _y, _text){
    var _gui_x, _gui_y;
    
	if (!instance_exists(obj_pop_ups)){
		if (!layer_exists("pop_ups")){
			layer_create(-1, "pop_ups");
		}
		
		instance_create_layer(0, 0, "pop_ups", obj_pop_ups);
	}
	
    var _guiw = display_get_gui_width(); // you can probably store these in global vars...
    var _guih = display_get_gui_height();
    var _rw = room_width;
    var _rh = room_height;
    var _gui_x = (_x / _rw) * _guiw;
    var _gui_y = (_y / _rh) * _guih;
    
    array_push(obj_pop_ups.pop_ups, {
        x : _gui_x,
        y : _gui_y,
        text : _text,
		scale : 1,
        timer : 60,
		max_timer : 60
    })
}

function create_damage_indicator(_player, _dmg, _color, _explosions){
	var _x, _y;
	var _margin = .2;
	_y = room_height / 2 + 48;
	if (!_player){
		_x = room_width * _margin;
	}else{
		_x = room_width * (1 - _margin);	
	}
	
	var _popup_color;
	
	switch(_color){
		case c_red: _popup_color = "[c_red]" break;
		case c_green: _popup_color = "[c_green]" break;
		case c_blue: _popup_color = "[c_blue]" break;
		case c_yellow: _popup_color = "[c_yellow]" break;
	}
	
	create_popup(_x, room_height / 2, $"[fa_middle][fa_center]{_popup_color}[fnt_pixel_small_out]{_explosions} {(_explosions > 0) ? "Explosões" : "Explosão"}!\n-{_dmg * 10}[c_white][spr_heart_pop_up]");
	instance_create_layer(_x, _y, "Damage_Indicator", obj_damage_indicator, {
		image_blend : _color,	
	})
}