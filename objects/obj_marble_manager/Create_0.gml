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

marble_grid_w = 5;
marble_grid_h = 8;
pool_size = marble_grid_w * marble_grid_h * 2;
marble_pool = array_create(pool_size, Marble_Color.NoOne);

marble_w = marble_grid_w * sprite_get_width(spr_head);
marble_h = marble_grid_h * sprite_get_height(spr_head);

x_marble = room_width / 2 - marble_w / 2;
y_marble = room_height / 2 - marble_h;

refill_red_marbles = 0;
refill_green_marbles = 0;
refill_yellow_marbles = 0;
refill_blue_marbles = 0;

explode_settings = {
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

create_marble = function(_color, _x, _y) constructor {
    color = _color;
    x = _x;
    y = _y;
    head = false;
    sprite_size = sprite_get_width(spr_head);
    hover = false;
    scale = 1;
    alpha = 1;
    x_index = _x;
    y_index = _y;
    state = Marble_States.Idle;
    falling_leader = false;
    falling_y = -1;
    timer_explosion_max = 15;
    timer_explosion = timer_explosion_max;
    
    update = function(){
        switch(state){
            case Marble_States.Idle:
                var _x1, _y1, _x2, _y2;
                _x1 = obj_marble_manager.x_marble + x_index * sprite_size - sprite_size / 2;
                _x2 = _x1 + sprite_size;
                _y1 = obj_marble_manager.y_marble + y_index * sprite_size - sprite_size / 2;
                _y2 = _y1 + sprite_size;
                
                if (obj_marble_manager.state == States.Play){
                    if (point_in_rectangle(mouse_x, mouse_y, _x1, _y1, _x2, _y2)){
                        scale = lerp(scale, 1.2, .1);
                        if (y_index > obj_marble_manager.marble_grid_h){
                            if (mouse_check_button_released(mb_left)){
                                obj_marble_manager.remove_marble(x_index, y_index);
                                obj_marble_manager.state = States.Falling_Pieces;
                            }
                        }
                    }else{
                        scale = lerp(scale, 1, .1)
                    }
                }
                
            break;
        
            case Marble_States.Falling:
                y += .1;
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
                                        obj_marble_manager.explode_settings.timer = 2;
                                        obj_marble_manager.explode_settings.y_max = _next_marble.y_index;
                                        obj_marble_manager.explode_settings.x = x_index;
                                        obj_marble_manager.explode_settings.color = _next_marble.color;
                                    }else{
                                        obj_marble_manager.update_row(x_index);
                                        obj_marble_manager.refill_marble_grid(x_index);
                                        obj_marble_manager.state = States.Play;
                                    }
                                }
                            }
                        }else{
                            // caso tenha chegado no fim da grid eu só atualizo as bolinhas
                            obj_marble_manager.update_row(x_index);
                            obj_marble_manager.refill_marble_grid(x_index);
                            obj_marble_manager.state = States.Play;
                        }
                        
                    }
                }
            break;
        
            case Marble_States.Explosion:
                timer_explosion--;
                scale = (timer_explosion / timer_explosion_max);
                if (timer_explosion <= 0){
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
        draw_text(_x1, _y1 + 1, y_index);
        draw_set_color(c_fuchsia);
        draw_text(_x1, _y1, y_index);
        draw_set_color(c_white);
    }
}

row_explosion = function(_x, _y, _color){
    var _y_min, _y_max;
    _y_min = _y;
    _y_max = _y;
    // coloca o y_min
    for (var i = _y; i >= marble_grid_h; i--){
        var _marble = marble_grid[_x][i];
        if (is_struct(_marble)){
            if (_marble.color != _color){
                _y_min = i + 1;
                break;
            }
        }
    } 
    
    var _found = false;
    for (var i = _y; i < marble_grid_h * 2; i++){
        var _marble = marble_grid[_x][i];
        if (is_struct(_marble)){
            if (_marble.color != _color){
                _y_max = i - 1;
                _found = true;
                break;
            }
        }
    } 
    
    if (!_found){
        _y_max = marble_grid_h * 2 - 1;
    }
    
    for (var i = _y_min; i <= _y_max; i++){
        marble_grid[_x, i].state = Marble_States.Explosion;
    }
}

stop_row = function(_x){
    for (var i = 0; i < array_length(marble_grid[_x]); i++){
        var _marble = marble_grid[_x][i];
        if (is_struct(_marble)){
            _marble.state = Marble_States.Idle;
        }
    }
}
remove_marble = function(_x, _y){
    if (is_struct(marble_grid[_x][_y])){
        var _marble = marble_grid[_x][_y].color;
        marble_grid[_x][_y] = Marble_Color.NoOne;
        
        switch (_marble){
        	case Marble_Color.Blue: obj_marble_manager.refill_blue_marbles++; break;
        	case Marble_Color.Green: obj_marble_manager.refill_green_marbles++; break;
        	case Marble_Color.Yellow: obj_marble_manager.refill_yellow_marbles++; break;
        	case Marble_Color.Red : obj_marble_manager.refill_red_marbles++; break;
        }
        
        var _leader_found = false;
        
        for (var i = _y; i >= 0; i--){ // define o lider da queda
            var _current_marble = marble_grid[_x][i];
            if (is_struct(_current_marble)){ 
                _current_marble.state = Marble_States.Falling;
                if (!_leader_found){
                    _leader_found = true;
                    _current_marble.falling_leader = true;
                }
            }
        }
        
        for (var i = _y; i < array_length(marble_grid[_x]); i++){ // define o head
            var _current_marble = marble_grid[_x][i];
            if (is_struct(_current_marble)){ 
                _current_marble.head = true;
                break;
            }
        }
    }
}
refill_marble_grid = function(_x){
    repeat(refill_blue_marbles) array_push(marble_pool, Marble_Color.Blue);
    repeat(refill_green_marbles) array_push(marble_pool, Marble_Color.Green);
    repeat(refill_red_marbles) array_push(marble_pool, Marble_Color.Red);
    repeat(refill_yellow_marbles) array_push(marble_pool, Marble_Color.Yellow);
        
    refill_blue_marbles = 0;
    refill_green_marbles = 0;
    refill_red_marbles = 0;
    refill_yellow_marbles = 0;
    
    array_shuffle_ext(marble_pool);
    
    for (var i = 0; i < array_length(marble_grid[_x]); i++){
        if (!is_struct(marble_grid[_x][i])){
            var _color = array_pop(marble_pool);
            marble_grid[_x][i] = new create_marble(_color, _x, i);
        }
    }
}
update_row = function(_x){
    var _new_row = array_create(marble_grid_h * 2, Marble_Color.NoOne);
    
    for (var i = 0; i < array_length(marble_grid[_x]); i++){
        var _marble = marble_grid[_x][i];
        if (is_struct(_marble)){
            var _y_index_falling = floor(_marble.y mod sprite_get_height(spr_marbles));
            _new_row[_y_index_falling] = new create_marble(_marble.color, _x, _y_index_falling)
        }
    }
    
    marble_grid[_x] = _new_row;
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
