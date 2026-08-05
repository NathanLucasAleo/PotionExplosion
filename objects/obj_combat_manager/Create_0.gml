enum Entities_States {
	Idle,
	Cast,
	Damage,
}

magic_points = {
	red : 0,
	blue : 0,
	yellow : 0,
	green : 0
}

hp_party = 0;
hp_max_party = 0;
hp_enemy_party = 0;
hp_max_party = 0;

d20 = function(){
	return irandom_range(1, 20);	
}

roll_initiative = function(_type){
	switch(_type){
		case Party_Members.Warrior: return d20() + 3; break;
		case Party_Members.Archer: return d20() + 5; break;
		case Party_Members.Druid: return d20(); break;
		case Party_Members.Rogue: return d20() + 8; break;
	}
}

#region Party
create_party_member = function(_type, _hp, _color, _atk) constructor {
	type = _type;
	hp = _hp;
	enemy = false;
	initiative = obj_combat_manager.roll_initiative(type);
	state = Entities_States.Idle;
	timer_state = 0;
	turn = 0;
	color = _color;
	combo = false;
	atk = _atk;
	
	scale = 1;
	
	sprite_idle = asset_get_index($"spr_party_member_{type}_idle");
	sprite_dmg  = asset_get_index($"spr_party_member_{type}_dmg");
	sprite_cast = asset_get_index($"spr_party_member_{type}_cast");
	
	x = room_width * .15;
	y = 0;
	x_add = 0;
	
	timer_dmg = 20;
	sprite = sprite_idle;
	index_sprite = 0;
	
	update = function(){
		if (obj_combat_manager.turn == turn || combo){
			x_add = lerp(x_add, 32, .1);
		}else{
			x_add = lerp(x_add, 0, .1);	
		}
		
		switch(state){
			case Entities_States.Idle: 
				sprite = sprite_idle;
				
				if (obj_combat_manager.turn == turn){
					state = Entities_States.Cast;	
				}
				
				if (combo){
					state = Entities_States.Cast;	
				}
			break;
			
			case Entities_States.Damage:
				sprite = sprite_dmg;
				
				if (--timer_dmg <= 0){
					timer_dmg = 20;
					state = Entities_States.Idle;
				}
				
			break;
			
			case Entities_States.Cast:
				sprite = sprite_cast;
				
				if (obj_combat_manager.turn != turn){
					if (!combo){
						state = Entities_States.Idle;
					}
				}
			break;
		}
		
		index_sprite += sprite_get_speed(sprite) / game_get_speed(gamespeed_fps);
	}
}

party = [
	new create_party_member(Party_Members.Warrior, 40, Marble_Color.Red, 5),
	new create_party_member(Party_Members.Archer, 20, Marble_Color.Yellow, 7),
	new create_party_member(Party_Members.Druid, 20, Marble_Color.Green, 2),
	new create_party_member(Party_Members.Rogue, 30, Marble_Color.Blue, 4),
];

array_sort(party, function(_member1, _member2){
	return 	_member2.initiative - _member1.initiative;
});

// sort party y and x
for (var i = 0; i < array_length(party); i++){
	var _member_y = room_height / 2 + 48 + (i - array_length(party) / 2) * 48;
	party[i].y = _member_y;
	party[i].x -= 16 * i;
	hp_party += party[i].hp;
}

hp_party_max = hp_party;
#endregion

#region Enemy Party
create_enemy_party_member = function(_type, _hp, _color, _atk) constructor {
	type = _type;
	enemy = true;
	hp = _hp;
	initiative = obj_combat_manager.roll_initiative(type);
	state = Entities_States.Idle;
	timer_state = 0;
	turn = 0;
	color = _color;
	combo = false;
	atk = _atk;
	
	scale = 1;
	
	sprite_idle = asset_get_index($"spr_party_member_{type}_idle");
	sprite_dmg  = asset_get_index($"spr_party_member_{type}_dmg");
	sprite_cast = asset_get_index($"spr_party_member_{type}_cast");	
	timer_play = 60;
	
	x = room_width * .85;
	y = 0;
	x_add = 0;
	play = false;
	
	sprite = sprite_idle;
	index_sprite = 0;
	timer_dmg = 20;
	
	update = function(){
		if (state == Entities_States.Cast || combo){
			x_add = lerp(x_add, -32, .1);
		}else{
			x_add = lerp(x_add, 0, .1);	
		}
		
		switch(state){
			case Entities_States.Idle: 
				sprite = sprite_idle;
				play = false;
				
				if (obj_combat_manager.turn == turn){
					if (--timer_play <= 0){
						state = Entities_States.Cast;
						timer_play = 60;
					}
				}
				
				if (combo){
					state = Entities_States.Cast;	
				}
			break;
			
			case Entities_States.Damage:
				sprite = sprite_dmg;
				
				if (--timer_dmg <= 0){
					timer_dmg = 20;
					state = Entities_States.Idle;
				}
				
			break;
			
			case Entities_States.Cast:
				sprite = sprite_cast;
				if (obj_combat_manager.turn != turn){
					if (!combo){
						state = Entities_States.Idle;
					}
				}else{
					if (obj_marble_manager.state == States.Play){
						if (!play){
							var _play = obj_marble_manager.run_possibilities();
							obj_marble_manager.marble_grid[_play[0].x][_play[0].y].state = Marble_States.Explosion;
							play = true;
						}
					}
				}
			break;
		}
		
		index_sprite += sprite_get_speed(sprite) / game_get_speed(gamespeed_fps);
	}
}

enemy_party = [
	new create_enemy_party_member(Party_Members.Warrior, 20, Marble_Color.Red, 3),
	new create_enemy_party_member(Party_Members.Archer, 15, Marble_Color.Yellow, 5),
	new create_enemy_party_member(Party_Members.Druid, 15, Marble_Color.Green, 1),
	new create_enemy_party_member(Party_Members.Rogue, 15, Marble_Color.Blue, 2),
];

array_sort(enemy_party, function(_member1, _member2){
	return 	_member2.initiative - _member1.initiative;
});

// sort enemy party y and x
for (var i = 0; i < array_length(enemy_party); i++){
	var _member_y = room_height / 2 + 48 + (i - array_length(enemy_party) / 2) * 48;
	enemy_party[i].y = _member_y;
	enemy_party[i].x += 16 * i;
	hp_enemy_party += enemy_party[i].hp;
}

hp_enemy_party_max = hp_enemy_party;

#endregion

// metodos
deal_damage = function(_dmg, _combo){
	var _turn_player = !turns[turn].enemy;
	if (_turn_player){
		hp_enemy_party -= _dmg * (1 + _combo / 10);
	}else{
		hp_party -= _dmg * (1 + _combo / 10);	
	}
	
	var _party = (_turn_player) ? enemy_party : party;
	for (var i = 0; i < array_length(_party); i++){
		_party[i].state = Entities_States.Damage;
	}
	
	if (hp_enemy_party <= 0){
		show_message("Venceu!");
		game_restart();
	}	
	
	if (hp_party <= 0){
		show_message("Game Over");
		game_restart();
	}
}

// arrumar os turnos
turns = [];
var _all_entities = array_union(party, enemy_party);
var _turns = 0;
while(array_length(_all_entities) > 0){ // organiza os turnos de cada personagem com base na iniciativa
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

if (!turns[turn].enemy){
	with(obj_marble_manager){
		var _run = run_possibilities();
		best_move.x = _run[0].x;
		best_move.y = _run[0].y;
		alarm[0] = 60 * 8;	
	}
}
