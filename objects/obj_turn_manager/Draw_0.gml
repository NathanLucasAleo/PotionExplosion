for (var i = 0; i < array_length(party); i++){
	var _member = party[i];
	draw_sprite_ext(
		_member.sprite, _member.index_sprite, _member.x + _member.x_add * (i + 1), _member.y,
		_member.scale, _member.scale, 0, c_white, 1
	);
	
	draw_text(_member.x, _member.y, _member.turn);
}

for (var i = 0; i < array_length(enemy_party); i++){
	var _member = enemy_party[i];
	draw_sprite_ext(
		_member.sprite, _member.index_sprite, _member.x + _member.x_add * (i + 1), _member.y,
		_member.scale, _member.scale, 0, c_white, 1
	);
	
	draw_text(_member.x, _member.y, _member.turn);
}
	