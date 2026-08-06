for (var i = 0; i < array_length(party); i++){ // desenha minha party
	var _member = party[i];
	draw_sprite_ext(
		_member.sprite, _member.index_sprite, _member.x + _member.x_add * (i + 1), _member.y,
		_member.scale, _member.scale, 0, c_white, 1
	);
	
	var _x_icons = _member.x + _member.x_add * (i + 1) - 32;
	var _y_icons = _member.y - 32;
	scribble($"[fa_center][fa_middle][fnt_pixel_ultra_small_out][spr_icons_members, 1]{_member.turn}\n[spr_icons_members, 0]{_member.atk}").draw(_x_icons, _y_icons);
}

for (var i = 0; i < array_length(enemy_party); i++){ // desenha party inimiga
	var _member = enemy_party[i];
	draw_sprite_ext(
		_member.sprite, _member.index_sprite, _member.x + _member.x_add * (i + 1), _member.y,
		_member.scale * - 1, _member.scale, 0, c_white, 1
	);
	
	var _x_icons = _member.x + _member.x_add * (i + 1) + 32;
	var _y_icons = _member.y - 32;
	scribble($"[fa_center][fa_middle][fnt_pixel_ultra_small_out]{_member.turn}[spr_icons_members, 1]\n{_member.atk}[spr_icons_members, 0]").draw(_x_icons, _y_icons);
	
}
	