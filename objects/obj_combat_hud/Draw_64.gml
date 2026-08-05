var _guiw = display_get_gui_width();
var _guih = display_get_gui_height();



var _x, _y, _w;
_y = _guih * .05;
_x = _guiw * .025;
draw_sprite_ext(spr_health_bar_player, 1, _x, _y, 1, 1, 0, c_white, 1);
_w = obj_combat_manager.hp_party / obj_combat_manager.hp_party_max * sprite_get_width(spr_health_bar_player);
draw_sprite_part(spr_health_bar_player, 0, 0, 0, _w, sprite_get_height(spr_health_bar_player), _x, _y);

_x = _guiw * (1 - .025) - sprite_get_width(spr_health_bar_enemy);
draw_sprite_ext(spr_health_bar_enemy, 1, _x, _y, 1, 1, 0, c_white, 1);
_w = obj_combat_manager.hp_enemy_party / obj_combat_manager.hp_enemy_party_max * sprite_get_width(spr_health_bar_enemy);
draw_sprite_part(spr_health_bar_enemy, 0, 0, 0, _w, sprite_get_height(spr_health_bar_enemy), _x, _y);