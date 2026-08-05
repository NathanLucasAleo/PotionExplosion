for (var i = 0; i < array_length(party); i++){ // desenha minha party
	var _member = party[i];
	draw_sprite_ext(
		_member.sprite, _member.index_sprite, _member.x + _member.x_add * (i + 1), _member.y,
		_member.scale, _member.scale, 0, c_white, 1
	);
	
	draw_text(_member.x, _member.y, _member.turn);
}

for (var i = 0; i < array_length(enemy_party); i++){ // desenha party inimiga
	var _member = enemy_party[i];
	draw_sprite_ext(
		_member.sprite, _member.index_sprite, _member.x + _member.x_add * (i + 1), _member.y,
		_member.scale * - 1, _member.scale, 0, c_white, 1
	);
	
	draw_text(_member.x - 16, _member.y + 16, _member.state) 
	
	draw_text(_member.x, _member.y, _member.turn);
}
	