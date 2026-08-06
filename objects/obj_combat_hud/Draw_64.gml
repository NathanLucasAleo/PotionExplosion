var _guiw = display_get_gui_width();
var _guih = display_get_gui_height();

// life bars
var _x, _y, _w, _scale;
_y = _guih * .05;
_x = _guiw * .025;
_scale = 2;
draw_sprite_ext(spr_health_bar_player, 1, _x, _y, _scale, _scale, 0, c_white, 1);
_w = obj_combat_manager.hp_party / obj_combat_manager.hp_party_max;
draw_sprite_ext(spr_health_bar_player, 0, _x, _y, _scale *_w, _scale, 0, c_white, 1);
draw_sprite_ext(spr_heart, 0, _x - sprite_get_width(spr_heart) / 2, _y - 4, _scale, _scale, 0, c_white, 1);

_x = _guiw * (1 - .025)
draw_sprite_ext(spr_health_bar_enemy, 1, _x, _y, _scale, _scale, 0, c_white, 1);
_w = obj_combat_manager.hp_enemy_party / obj_combat_manager.hp_enemy_party_max;
draw_sprite_ext(spr_health_bar_enemy, 0, _x, _y, _scale * _w, _scale, 0, c_white, 1);
draw_sprite_ext(spr_heart, 0, _x - sprite_get_width(spr_heart), _y - 4, _scale, _scale, 0, c_white, 1);