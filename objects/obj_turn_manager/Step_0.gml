for (var i = 0; i < array_length(party); i++){
	var _member = party[i];
	method(_member, _member.update)();
}

for (var i = 0; i < array_length(enemy_party); i++){
	var _member = enemy_party[i];
	method(_member, _member.update)();
}
	
	