for (var i = 0; i < array_length(marble_grid); i++){
    for (var j = 0; j < array_length(marble_grid[i]); j++){
        var _marble = marble_grid[i][j];
        if (is_struct(_marble)){  
            draw_sprite_ext(spr_marbles, _marble.color - 1,
            x_marble + 32 * _marble.x,
            y_marble + 32 * _marble.y, _marble.scale, _marble.scale, 0, c_white, 1);
            _marble.draw();
        }
    }
}