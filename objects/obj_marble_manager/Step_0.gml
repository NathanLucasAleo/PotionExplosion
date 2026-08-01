for (var i = 0; i < array_length(marble_grid); i++){
    for (var j = 0; j < array_length(marble_grid[i]); j++){
        var _marble = marble_grid[i][j]
        if (is_struct(_marble)){
            if (method(_marble, _marble.update)()){
                // fazer as bolinhas da coluna selecionada cairem
                for (var _y = j - 1; _y >= 0; _y--){
                    if (is_struct(marble_grid[i][_y])){
                        var _marble_current = marble_grid[i][_y];
                        _marble_current.falling = true;
                    }
                }
                
                // marca a bolinha da frente para ser o limite de queda das anteriores
                var _min = min(j + 1, array_length(marble_grid[i]) - 1);
                if (is_struct(marble_grid[i][_min])){
                    marble_grid[i][_min].head = true;
                }
                
                remove_marble(i, j);
            }
        }
    }
}

if (keyboard_check_released(vk_space)){
    room_restart();
}