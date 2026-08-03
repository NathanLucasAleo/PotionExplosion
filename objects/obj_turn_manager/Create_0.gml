enum Entities_States {
	Idle,
	Cast,
	Damage,
}

hp_party = 0;
hp_max_party = 0;
hp_enemy_party = 0;
hp_max_party = 0;

roll_initiative = function(_type){
	switch(_type){
		case Party_Members.Warrior: return irandom(20) + 3; break;
		case Party_Members.Archer: return irandom(20) + 5; break;
		case Party_Members.Druid: return irandom(20); break;
		case Party_Members.Rogue: return irandom(20) + 8; break;
	}
}

#region Party
create_party_member = function(_type, _hp) constructor {
	type = _type;
	hp = _hp;
	initiative = obj_turn_manager.roll_initiative(type);
	state = Entities_States.Idle;
	timer_state = 0;
	turn = 0;
	
	scale = 1;
	
	sprite_idle = asset_get_index($"spr_party_member_{type}_idle");
	sprite_dmg  = asset_get_index($"spr_party_member_{type}_dmg");
	sprite_cast = asset_get_index($"spr_party_member_{type}_cast");
	
	x = room_width * .15;
	y = 0;
	x_add = 0;
	
	sprite = sprite_idle;
	index_sprite = 0;
	
	update = function(){
		if (obj_turn_manager.turn == turn){
			x_add = lerp(x_add, 32, .1);
		}else{
			x_add = lerp(x_add, 0, .1);	
		}
		
		switch(state){
			case Entities_States.Idle: 
				sprite = sprite_idle;
			break;
			
			case Entities_States.Damage:
				sprite = sprite_dmg;
			break;
			
			case Entities_States.Cast:
				sprite = sprite_cast;
			break;
		}
		
		index_sprite += sprite_get_speed(sprite) / game_get_speed(gamespeed_fps);
	}
}

party = [
	new create_party_member(Party_Members.Warrior, 10),
	new create_party_member(Party_Members.Archer, 10),
	new create_party_member(Party_Members.Druid, 10),
	new create_party_member(Party_Members.Rogue, 10),
];

array_sort(party, function(_member1, _member2){
	return 	_member2.initiative - _member1.initiative;
});

// sort party y and x
for (var i = 0; i < array_length(party); i++){
	var _member_y = room_height / 2 + (i - array_length(party) / 2) * 48;
	party[i].y = _member_y;
	party[i].x -= 16 * i;
}
#endregion

#region Enemy Party
create_enemy_party_member = function(_type, _hp) constructor {
	type = _type;
	hp = _hp;
	initiative = obj_turn_manager.roll_initiative(type);
	state = Entities_States.Idle;
	timer_state = 0;
	turn = 0;
	
	scale = 1;
	
	sprite_idle = asset_get_index($"spr_party_member_{type}_idle");
	sprite_dmg  = asset_get_index($"spr_party_member_{type}_dmg");
	sprite_cast = asset_get_index($"spr_party_member_{type}_cast");
	
	x = room_width * .85;
	y = 0;
	x_add = 0;
	
	sprite = sprite_idle;
	index_sprite = 0;
	
	update = function(){
		if (obj_turn_manager.turn == turn){
			x_add = lerp(x_add, -32, .1);
		}else{
			x_add = lerp(x_add, 0, .1);	
		}
		
		switch(state){
			case Entities_States.Idle: 
				sprite = sprite_idle;
			break;
			
			case Entities_States.Damage:
				sprite = sprite_dmg;
			break;
			
			case Entities_States.Cast:
				sprite = sprite_cast;
			break;
		}
		
		index_sprite += sprite_get_speed(sprite) / game_get_speed(gamespeed_fps);
	}
}

enemy_party = [
	new create_enemy_party_member(Party_Members.Warrior, 10),
	new create_enemy_party_member(Party_Members.Archer, 10),
	new create_enemy_party_member(Party_Members.Druid, 10),
	new create_enemy_party_member(Party_Members.Rogue, 10),
];

array_sort(enemy_party, function(_member1, _member2){
	return 	_member2.initiative - _member1.initiative;
});

// sort enemy party y and x
for (var i = 0; i < array_length(enemy_party); i++){
	var _member_y = room_height / 2 + (i - array_length(enemy_party) / 2) * 48;
	enemy_party[i].y = _member_y;
	enemy_party[i].x += 16 * i;
}

#endregion

// arrumar os turnos
turns = [];
var _all_entities = array_union(party, enemy_party);
var _turns = 0;
while(array_length(_all_entities) > 0){
	var _index_to_remove = 0;
	var _initiative = -1;
	for (var i = 0; i < array_length(_all_entities); i++){
		if (_all_entities[i].initiative > _initiative){
			_index_to_remove = i;
			_initiative = _all_entities[i].initiative;
		}
	}
	
	_all_entities[_index_to_remove].turn = _turns;
	array_push(turns, _all_entities[_index_to_remove]);
	array_delete(_all_entities, _index_to_remove, 1);
	_turns++;
}
turn  = 0;
