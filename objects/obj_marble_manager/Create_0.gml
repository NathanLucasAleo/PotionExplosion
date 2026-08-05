randomize();

enum Marble_Color {
    NoOne,
    Red,
    Blue,
    Green,
    Yellow
}

enum Marble_States {
    Idle,
    Explosion,
    Falling
}

enum States {
    Falling_Pieces,
    Play    
}

state = States.Play;

do_combos = false;
marble_min_value = 7;

turn_entity = noone;

marble_grid_w = 5;
marble_grid_h = 8;
pool_size = marble_grid_w * marble_grid_h * 2;
marble_pool = array_create(pool_size, Marble_Color.NoOne);
running_simulation = false;
points = 0;

marble_w = marble_grid_w * sprite_get_width(spr_head);
marble_h = marble_grid_h * sprite_get_height(spr_head);

x_marble = room_width / 2 - marble_w / 2 + 16;
y_marble = room_height / 2 - marble_h * 1.5 + 16;

refill_red_marbles = 0;
refill_green_marbles = 0;
refill_yellow_marbles = 0;
refill_blue_marbles = 0;

explosion_settings = {
    timer : 0,
    color : Marble_Color.NoOne,
    y_max : 0,
    x : 0,
}

colors = [
    Marble_Color.Red,
    Marble_Color.Blue,
    Marble_Color.Green,
    Marble_Color.Yellow,
]

for (var i = 0; i < array_length(marble_pool); i++){
    marble_pool[i] = colors[i % array_length(colors)];
}
array_shuffle_ext(marble_pool);

marble_grid = [
    [],
    [],
    [],
    [],
    [],
]

marble_grid_clone = noone;
turn_player = false;
combo = 0;
best_move = {x: -1, y: -1};

run_possibilities = function(){
	var _possibilities = [];
	var _qty_plays = 5 * 7;
	var _coordinates = ds_map_create();
	var _qty = 0;
	
	var _sort_pieces = function(_x, _show_message = false){
		var _sorting_pieces = true;
		var _y = -1;	
		var _empty_place = -1;

		for (var i = array_length(marble_grid_simulation[_x]) - 1; i >= 0; i--){
			if (marble_grid_simulation[_x][i] == Marble_Color.NoOne && _empty_place == -1){					
				_empty_place = i;
				if (_y < 0){
					_y = i;
				}
			}
					
			if (marble_grid_simulation[_x][i] != Marble_Color.NoOne && _empty_place > -1){
				marble_grid_simulation[_x][_empty_place] = marble_grid_simulation[_x][i];
				marble_grid_simulation[_x][i] = Marble_Color.NoOne;
					
				i = array_length(marble_grid_simulation[_x]) - 1;
				_empty_place = -1;
			}
		}
				
		return _y;
	}
			
	repeat(_qty_plays){
		marble_grid_simulation = []
		for (var i = 0; i < array_length(marble_grid); i++){
			for (var j = 0; j < array_length(marble_grid[i]); j++){
				marble_grid_simulation[i][j] = marble_grid[i][j].color;
			}
		}
		
		points = 0;
		var _x, _y;
		_x = irandom(array_length(marble_grid_simulation) - 1);
		_y = irandom_range(marble_grid_h + 1, array_length(marble_grid_simulation[_x]) - 1);
		while(_coordinates[? $"{_x}|{_y}"] != undefined){
			_x = irandom(array_length(marble_grid_simulation) - 1);
			_y = irandom_range(marble_min_value, array_length(marble_grid_simulation[_x]) - 1);
		}
		_coordinates[? $"{_x}|{_y}"] = true;

		points++;
		marble_grid_simulation[_x][_y] = Marble_Color.NoOne;
		
		var _combos = 0;
		
		var _y_explosion = _sort_pieces(_x);
		var _explosions = true;
		
		while (_explosions){
			if (_y_explosion + 1 > array_length(marble_grid_simulation[_x]) - 1) {
				_explosions = false;
				break;	
			} else {
				_combos++;
				var _marbles_to_explode = [];
				var _og_color = marble_grid_simulation[_x][_y_explosion];
				var _next_color = marble_grid_simulation[_x][_y_explosion + 1];

				if (_og_color == _next_color) {
					_nodes_simulation = [];
					_visited_nodes_simulation = ds_map_create();
					ds_map_clear(_visited_nodes_simulation);
			
					var _create_node = function(_x, _y) {
						_y = clamp(_y, marble_min_value, array_length(marble_grid_simulation[_x]) - 1);

						var _key = $"{_x}|{_y}";
						if (_visited_nodes_simulation[? _key] == undefined) {
							array_push(_nodes_simulation, {
								x: _x,
								y: _y,
							});

							_visited_nodes_simulation[? _key] = true;
						}
					};

					_create_node(_x, _y - 1);
					_create_node(_x, _y + 1);

					while (array_length(_nodes_simulation) > 0) {
						var _marble = marble_grid_simulation[_nodes_simulation[0].x][_nodes_simulation[0].y];
						if (_marble == _og_color) {
							array_push(_marbles_to_explode, {
								x: _nodes_simulation[0].x,
								y: _nodes_simulation[0].y,
							});

							_create_node(_nodes_simulation[0].x, _nodes_simulation[0].y - 1);
							_create_node(_nodes_simulation[0].x, _nodes_simulation[0].y + 1);
						}

						array_delete(_nodes_simulation, 0, 1);
					}

					for (var i = 0; i < array_length(_marbles_to_explode); i++) {
						marble_grid_simulation[_marbles_to_explode[i].x][_marbles_to_explode[i].y] = Marble_Color.NoOne;
						points++;
					}	

					ds_map_destroy(_visited_nodes_simulation);					
					_y_explosion = _sort_pieces(_x);
				} else {
					_explosions = false;
					break;		
				}
			}
		}
		
		var _run_results = {
			x : _x,
			y : _y,
			points : points,
			combos : _combos,
		}
		
		array_push(_possibilities, _run_results);
	}
		
	
	array_sort(_possibilities, function(_run1, _run2){
		return _run2.points - _run1.points;
	});
		
	ds_map_destroy(_coordinates);
	
	return _possibilities;
}

next_turn = function(){
	with(obj_combat_manager){
		turn++;
		if (turn > array_length(turns) - 1){
			turn = 0;
		}
		
		if (!turns[turn].enemy){
			with(obj_marble_manager){
				var _run = run_possibilities();
				best_move.x = _run[0].x;
				best_move.y = _run[0].y;
				alarm[0] = 60 * 8;
			}
		}else{
			with(obj_marble_manager){
				best_move.x = -1;
				best_move.y = -1;
			}
		}
	}
}

create_marble = function(_color, _x, _y) constructor {
    color = _color;
    x = _x;
    y = _y;
    head = false;
    sprite_size = sprite_get_width(spr_head);
    hover = false;
    scale = 1;
    alpha = 1;
	alpha_final = 1;
	simulation_mode = false;
    x_index = _x;
    y_index = _y;
    state = Marble_States.Idle;
    falling_leader = false;
    falling_y = -1;
    timer_explosion_max = 15;
    timer_explosion = timer_explosion_max;
	leader = false;
	
	reveal_myself = function(){

	}	
    
    update = function(){		
		alpha = lerp(alpha, 1, .1);
        switch(state){
            case Marble_States.Idle:
                var _x1, _y1, _x2, _y2;
                _x1 = obj_marble_manager.x_marble + x_index * sprite_size - sprite_size / 2;
                _x2 = _x1 + sprite_size;
                _y1 = obj_marble_manager.y_marble + y_index * sprite_size - sprite_size / 2;
                _y2 = _y1 + sprite_size;
				reveal_myself();
				
                if (obj_marble_manager.state == States.Play){
					if (obj_combat_manager.turns[obj_combat_manager.turn].enemy == false){
						if (point_in_rectangle(mouse_x, mouse_y, _x1 + 4, _y1 + 4, _x2 - 4, _y2 - 4)){
	                        scale = lerp(scale, 1.2, .1);
	                        if (y_index >= obj_marble_manager.marble_min_value){
	                            if (mouse_check_button_released(mb_left)){
	                                state = Marble_States.Explosion;
	                                obj_marble_manager.state = States.Falling_Pieces;
									obj_combat_manager.deal_damage(obj_combat_manager.turns[obj_combat_manager.turn].atk , 0)
	                            }
	                        }
	                    }else{
							scale = lerp(scale, 1, .1)
							if (obj_marble_manager.turn_player){
								if (obj_marble_manager.alarm[0] <= -1){
									if (x_index == obj_marble_manager.best_move.x && y_index == obj_marble_manager.best_move.y){
										scale = 1 + abs(dcos(current_time / 10)) * .2; 	
									}
								}
							}
	                    }
					}
                }
                
            break;
        
            case Marble_States.Falling:
				reveal_myself();
				if (array_length(obj_marble_manager.combo_guys) <= 0){
					y += .1;
					obj_marble_manager.do_combos = false;
				}else{
					obj_marble_manager.do_combos = true;
				}
				
	            if (falling_leader){
	                var _y_index_falling = floor(y mod sprite_size);
	                if (falling_y != _y_index_falling){
	                    falling_y = _y_index_falling;
	                    // parei, e vou ver se a proxima posição da grid ainda é valida
	                    var _marble_grid = obj_marble_manager.marble_grid;
	                    if (falling_y + 1 < array_length(_marble_grid[x_index])){
	                        // caso tenha colidido com o head
	                        var _next_marble = _marble_grid[x_index][falling_y + 1];
	                        if (is_struct(_next_marble)){
	                            if (_next_marble.head){ 
	                                // tenta executar uma explosao
	                                // caso consiga explodir, ele repete todo o processo
	                                // caso nao consiga explodir, passa o turno
	                                if (_next_marble.color == color){
	                                    obj_marble_manager.update_row(x_index);
	                                    obj_marble_manager.explosion_settings.timer = 5;
	                                    obj_marble_manager.explosion_settings.y_max = _next_marble.y_index;
	                                    obj_marble_manager.explosion_settings.x = x_index;
	                                    obj_marble_manager.explosion_settings.color = _next_marble.color;
	                                }else{
	                                    obj_marble_manager.update_row(x_index);
	                                    obj_marble_manager.refill_marble_grid(x_index);
	                                    obj_marble_manager.state = States.Play;
										obj_marble_manager.next_turn();
										obj_marble_manager.combo = 0;
	                                }
	                            }
	                        }
	                    }else{
	                        // caso tenha chegado no fim da grid eu só atualizo as bolinhas
	                        obj_marble_manager.update_row(x_index);
	                        obj_marble_manager.refill_marble_grid(x_index);
	                        obj_marble_manager.state = States.Play;
							obj_marble_manager.next_turn();
	                    }
	                }
				}
            break;
        
            case Marble_States.Explosion:
				if (!simulation_mode){
					reveal_myself();
	                timer_explosion--;
	                scale = (timer_explosion / timer_explosion_max);
	                if (timer_explosion <= 0){
	                    obj_marble_manager.remove_marble(x_index, y_index);
	                }
				}else{
					obj_marble_manager.remove_marble(x_index, y_index);	
				}
            break;
        }
    }
    
    draw = function(){ // debug
        var _x1 = obj_marble_manager.x_marble + sprite_size * x - sprite_size / 2;
        var _x2 = _x1 + sprite_size;
        var _y1 = obj_marble_manager.y_marble + sprite_size * y - sprite_size / 2;
        var _y2 = _y1 + sprite_size;

        draw_set_color(c_black);
        draw_text(_x1 + 16, _y1 + 1, y_index);
        draw_set_color(c_fuchsia);
        draw_text(_x1 + 16, _y1, y_index);
        draw_set_color(c_white);
    }
}

row_explosion = function(_x, _y, _color){
	var _marbles_to_explode = [];
	
	_nodes = [];
	_visited_nodes = ds_map_create();
	ds_map_clear(_visited_nodes);
	var _create_node = function(_x, _y){
		_y = clamp(_y, marble_min_value, array_length(marble_grid[_x]) - 1);
		
		var _key = $"{_x}|{_y}";
		if (_visited_nodes[? _key] == undefined){
			array_push(_nodes, {
				x : _x,
				y : _y,
			});
			
			_visited_nodes[? _key] = true;
		}
	}	

	_create_node(_x, _y - 1);
	_create_node(_x, _y + 1);
	
	while(array_length(_nodes) > 0){
		var _marble = marble_grid[_nodes[0].x][_nodes[0].y];
		if (is_struct(_marble)){
			if (_marble.color == _color){
				array_push(_marbles_to_explode, {
					x : _nodes[0].x,
					y : _nodes[0].y,
				})
			
				_create_node(_nodes[0].x, _nodes[0].y - 1);
				_create_node(_nodes[0].x, _nodes[0].y + 1);
			}
		}
		
		array_delete(_nodes, 0, 1);
	}
	
    for (var i = 0; i < array_length(_marbles_to_explode); i++){
		var _marble = marble_grid[_marbles_to_explode[i].x][_marbles_to_explode[i].y];
		if (is_struct(_marble)){
			_marble.state = Marble_States.Explosion;
		}
    }
	
	ds_map_destroy(_visited_nodes);
	set_combo(_color, array_length(_marbles_to_explode));
}

remove_marble = function(_x, _y){
	var _marble_grid = obj_marble_manager.marble_grid;
    if (is_struct(_marble_grid[_x][_y])){
        var _marble = _marble_grid[_x][_y].color;
        _marble_grid[_x][_y] = Marble_Color.NoOne;
				
        switch (_marble){
        	case Marble_Color.Blue: obj_marble_manager.refill_blue_marbles++; break;
        	case Marble_Color.Green: obj_marble_manager.refill_green_marbles++; break;
        	case Marble_Color.Yellow: obj_marble_manager.refill_yellow_marbles++; break;
        	case Marble_Color.Red : obj_marble_manager.refill_red_marbles++; break;
        }
		
		combo++;
	    
        var _leader_found = false;
        
        for (var i = _y; i >= 0; i--){ // define o lider da queda
            var _current_marble = _marble_grid[_x][i];
            if (is_struct(_current_marble)){ 
                _current_marble.state = Marble_States.Falling;
                if (!_leader_found){
                    _leader_found = true;
                    _current_marble.falling_leader = true;
                }
            }
        }
        
        for (var i = _y; i < array_length(_marble_grid[_x]); i++){ // define o head
            var _current_marble = _marble_grid[_x][i];
            if (is_struct(_current_marble)){ 
                _current_marble.head = true;
                break;
            }
        }
    }
}

combo_guys = [];

set_combo = function(_color, _combo){
	combo_guys = [];
	var _player_turn = !obj_combat_manager.turns[obj_combat_manager.turn].enemy;
	var _array = (_player_turn) ? obj_combat_manager.party : obj_combat_manager.enemy_party;
	
	for (var i = 0; i < array_length(_array); i++){
		if (_array[i].color == _color){
			_array[i].combo = true;	
			array_push(combo_guys, {
				character : _array[i],
				timer : 30,
				combo : _combo
			});
		}
	}
}

stop_row = function(_x){
	var _marble_grid = obj_marble_manager.marble_grid;
    for (var i = 0; i < array_length(_marble_grid[_x]); i++){
        var _marble = _marble_grid[_x][i];
        if (is_struct(_marble)){
            _marble.state = Marble_States.Idle;
        }
    }
}
refill_marble_grid = function(_x){
    var _marble_grid = obj_marble_manager.marble_grid;
	repeat(refill_blue_marbles) array_push(marble_pool, Marble_Color.Blue);
    repeat(refill_green_marbles) array_push(marble_pool, Marble_Color.Green);
    repeat(refill_red_marbles) array_push(marble_pool, Marble_Color.Red);
    repeat(refill_yellow_marbles) array_push(marble_pool, Marble_Color.Yellow);
        
    refill_blue_marbles = 0;
    refill_green_marbles = 0;
    refill_red_marbles = 0;
    refill_yellow_marbles = 0;
    
    array_shuffle_ext(marble_pool);
    
    for (var i = 0; i < array_length(_marble_grid[_x]); i++){
        if (!is_struct(_marble_grid[_x][i])){
            var _color = array_pop(marble_pool);
            _marble_grid[_x][i] = new create_marble(choose(
				Marble_Color.Blue, Marble_Color.Green, Marble_Color.Red, Marble_Color.Yellow
			), _x, i);
        }
    }
}
update_row = function(_x){
    var _new_row = array_create(marble_grid_h * 2, Marble_Color.NoOne);
    var _marble_grid = obj_marble_manager.marble_grid;
	
    for (var i = 0; i < array_length(_marble_grid[_x]); i++){
        var _marble = _marble_grid[_x][i];
        if (is_struct(_marble)){
            var _y_index_falling = floor(_marble.y mod sprite_get_height(spr_marbles));
            _new_row[_y_index_falling] = new create_marble(_marble.color, _x, _y_index_falling);
			if (running_simulation){
				_new_row[_y_index_falling].simulation_mode = true;
			}
        }
    }
   
	for (var i = 0; i < array_length(_new_row); i++){
		if (is_struct(_new_row[i])){
			_new_row[i].leader = true;
			break;
		}
	}

    _marble_grid[_x] = _new_row;
}

fill_marble_grid = function(){
    for (var _i = 0; _i < array_length(marble_grid); _i++){
        var _y = 0;
        while(array_length(marble_grid[_i]) < marble_grid_h * 2){
            var _color = array_pop(marble_pool);
            array_push(marble_grid[_i], new create_marble(_color, _i, _y));
            _y += 1;
        }
    }
}

fill_marble_grid();
