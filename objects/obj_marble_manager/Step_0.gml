turn_entity = obj_combat_manager.turns[obj_combat_manager.turn];
turn_player = !obj_combat_manager.turns[obj_combat_manager.turn].enemy;

for (var i = 0; i < array_length(marble_grid); i++){
    for (var j = 0; j < array_length(marble_grid[i]); j++){
        var _marble = marble_grid[i][j]
        if (is_struct(_marble)){ 
            method(_marble, _marble.update)();
        }
    }
}

if (explosion_settings.timer > 0){
    if (--explosion_settings.timer <= 0){
		obj_marble_manager.refill_marble_grid(explosion_settings.x);
        row_explosion(explosion_settings.x, explosion_settings.y_max, explosion_settings.color)
    }
}

if (keyboard_check_released(vk_left)){
	run_possibilities();
}

if (keyboard_check_released(vk_space)){
    room_restart();
}