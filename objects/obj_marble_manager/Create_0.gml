enum Marble_Color {
    NoOne,
    Red,
    Blue,
    Green,
    Yellow
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

x_marble = 150;
y_marble = 150;
marble_w = marble_grid_w * sprite_get_width(spr_marbles);
marble_h = marble_grid_h * sprite_get_height(spr_marbles);

refill_red_marbles = 0;
refill_green_marbles = 0;
refill_yellow_marbles = 0;
refill_blue_marbles = 0;

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
    falling = false;
    head = false;
    sprite_size = sprite_get_width(spr_marbles);
    hover = false;
    scale = 1;
    alpha = 1;
    
    update = function(){
        var _x1 = obj_marble_manager.x_marble + sprite_size * x - sprite_size / 2;
        var _x2 = _x1 + sprite_size;
        var _y1 = obj_marble_manager.y_marble + sprite_size * y - sprite_size / 2;
        var _y2 = _y1 + sprite_size;
        
        if (falling){
            y += .1;
            var _marble_grid = obj_marble_manager.marble_grid; 
            var _min = min(floor(y) + 1, array_length(_marble_grid[x]) - 1);
            var _next_marble = _marble_grid[x][_min];
            if (is_struct(_next_marble)){
                if (_next_marble.head){
                    _next_marble.head = false;
                    for (var i = 0; i < array_length(_marble_grid[x]); i++){
                        _marble_grid[x][i].y = floor(_marble_grid[x][i].y);
                        _marble_grid[x][i].falling = false;
                    }
                    
                    obj_marble_manager.state = States.Play;
                    obj_marble_manager.update_marble_grid(x);
                    obj_marble_manager.refill_marble_grid();
                }
            }
            
            if (y + 1 > array_length(_marble_grid[x])){
                for (var i = 0; i < array_length(_marble_grid[x]); i++){
                    _marble_grid[x][i].y = floor(_marble_grid[x][i].y);
                    _marble_grid[x][i].falling = false;
                }
                
                obj_marble_manager.state = States.Play;
                obj_marble_manager.update_marble_grid(x);
                obj_marble_manager.refill_marble_grid();
            }
        }
        
        if (obj_marble_manager.state == States.Play){
            if (point_in_rectangle(mouse_x, mouse_y, _x1, _y1, _x2, _y2)){
                if (mouse_check_button_released(mb_left) && y > obj_marble_manager.marble_grid_h / 2 + 1){
                    obj_marble_manager.state = States.Falling_Pieces;
                    return true;
                }
                
                scale = lerp(scale, 1.2, .1);
            }else{
                scale = lerp(scale, 1, .1);
            }
        }
        
        return false;
    }
    
    draw = function(){ // debug
        var _x1 = obj_marble_manager.x_marble + sprite_size * x - sprite_size / 2;
        var _x2 = _x1 + sprite_size;
        var _y1 = obj_marble_manager.y_marble + sprite_size * y - sprite_size / 2;
        var _y2 = _y1 + sprite_size;
        
        draw_rectangle(_x1, _y1, _x2, _y2, true);
        
        draw_text(_x1, _y1, y);
    }
}

remove_marble = function(_x, _y){
    var _marble = marble_grid[_x][_y].color;
    marble_grid[_x][_y] = Marble_Color.NoOne;
    
    switch (_marble){
    	case Marble_Color.Blue: obj_marble_manager.refill_blue_marbles++; break;
    	case Marble_Color.Green: obj_marble_manager.refill_green_marbles++; break;
    	case Marble_Color.Yellow: obj_marble_manager.refill_yellow_marbles++; break;
    	case Marble_Color.Red : obj_marble_manager.refill_red_marbles++; break;
    }
}

update_marble_grid = function(_x){
    var _new_array = array_create(marble_grid_h, Marble_Color.NoOne);
    for (var i = 0; i < array_length(marble_grid[_x]); i++){
        var _marble = marble_grid[_x][i];
        if (is_struct(marble_grid[_x, i])){
            _new_array[_marble.y] = _marble;
        }
    }
    
    marble_grid[_x] = _new_array;
}

refill_marble_grid = function(){
    repeat(refill_red_marbles){
        array_insert(marble_pool, 0, Marble_Color.Red);    
    }
    
    repeat(refill_yellow_marbles){
        array_insert(marble_pool, 0, Marble_Color.Yellow);    
    }
    
    repeat(refill_green_marbles){
        array_insert(marble_pool, 0, Marble_Color.Green);    
    }
    
    repeat(refill_blue_marbles){
        array_insert(marble_pool, 0, Marble_Color.Blue);    
    }
    
    array_shuffle_ext(marble_pool);
    
    refill_blue_marbles = 0;
    refill_green_marbles = 0;
    refill_yellow_marbles = 0;
    refill_red_marbles = 0;
    
    for (var i = 0; i < array_length(marble_grid); i++){
        for (var j = 0; j < array_length(marble_grid[i]); j++){
            if (!is_struct(marble_grid[i][j])){
                marble_grid[i][j] = new create_marble(array_pop(marble_pool), i, j);
            }
        }
    }
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
