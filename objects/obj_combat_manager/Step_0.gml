for (var i = 0; i < array_length(party); i++){ // roda o step da minha party
	var _member = party[i];
	method(_member, _member.update)();
}

for (var i = 0; i < array_length(enemy_party); i++){ // roda o step da party inimiga
	var _member = enemy_party[i];
	method(_member, _member.update)();
}
	
	