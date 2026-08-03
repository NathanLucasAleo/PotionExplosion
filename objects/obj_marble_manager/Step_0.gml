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
        row_explosion(explosion_settings.x, explosion_settings.y_max, explosion_settings.color)
    }
}

if (keyboard_check_released(vk_left)){
    game_restart();
}

if (keyboard_check_released(vk_space)){
    room_restart();
}