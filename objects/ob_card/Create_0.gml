depth=200;
//
if instance_exists(ob_control) { var reference_id=ob_control; }
else if instance_exists(ob_deckbuild) { var reference_id=ob_deckbuild; }
else if instance_exists(ob_event) { var reference_id=ob_event; }
//————————————————————————————————————————————————————————————————————————————————————————————————————
if reference_id=ob_deckbuild or (reference_id=ob_event and ob_event.show_deck=true) { card_face=true; }
else { card_face=false; }
card_played=false;
card_trash=false;
card_enemy=false;
//
card_cat=reference_id.create_card_cat;
for (var i=0; i<=deck_setup_max; i++;) {
	if card_cat=0 and reference_id=ob_deckbuild { card_indeck[i]=reference_id.create_card_indeck[i]; }
	else { card_indeck[i]=false; }
}
if card_cat=0 and reference_id=ob_deckbuild { card_serial=reference_id.create_card_serial; }
else { card_serial=-1; }
//
num_in_maindeck=-1;
num_in_berrydeck=-1;
num_in_all=-1;
//
potential_x=x;
potential_y=y;
//
for (var i=0; i<=3; i++;) {
	consumed_berry[i]=0;
}
//
already_attacked=false;
effect_damaged=0;
//
card_delete_timer=0;
card_delete_timer_max=45;
//
if card_cat=0 and variable_instance_exists(reference_id,"create_card_nickname") { card_nickname=reference_id.create_card_nickname; }
else { card_nickname=""; }
card_rename=false;
//
card_shiny=false;
sell_value=0;
//
auto_turn_add=false;
if card_cat=0 and reference_id=ob_control { enemy_randomizer=reference_id.create_enemy_randomizer; }
else { enemy_randomizer=false; }
if card_cat=0 and reference_id=ob_control { enemy_costcount=reference_id.create_enemy_costcount; }
else { enemy_costcount=false; }
//————————————————————————————————————————————————————————————————————————————————————————————————————
if card_cat=0 {
	var random_group_chance=irandom(9999);
	//
	do {
		card_id=reference_id.create_card_id;
		if card_id=-1 { var random_card=true; } else { var random_card=false; }
		//
		var choose_id_enigma=false, choose_id_stage_2=false, choose_id_stage_3=false, choose_id_normal=false;
		var allow_id_enigma=false, allow_id_pseudo=false, allow_id_fossil=false, allow_id_starter=false, allow_id_baby=false;
		//————————————————————————————————————————————————————————————————————————————————————————————————————
		if random_card=true and enemy_randomizer=false {
			if random_group_chance<1 { //0.01% secret card
				card_id=irandom_range(1,secret_cards_total)+2000;
				card_innate=1;
			}
			else if random_group_chance<201 { //2% environment card
				card_id=irandom_range(1,environment_cards_total)+2500;
				card_innate=1;
			}
			else {
				card_id=irandom_range(1,normal_poke_id_max);
				card_innate=1;
				//
				if random_group_chance<226 { choose_id_enigma=true; } //0.25% enigma
				else if random_group_chance<476 { choose_id_stage_2=true; } //2.5% stage 2
				else if random_group_chance<526 { choose_id_stage_3=true; } //0.5% stage 3
				else { choose_id_normal=true; } //94.74% stage 1 or baby
				//
				var random_id_chance=irandom(99); if random_id_chance<50 { allow_id_pseudo=true; } //50% pseudo allowed
				var random_id_chance=irandom(99); if random_id_chance<75 { allow_id_fossil=true; } //75% fossil allowed
				var random_id_chance=irandom(99); if random_id_chance<25 { allow_id_starter=true; } //25% starter allowed
				var random_id_chance=irandom(99); if random_id_chance<30 { allow_id_baby=true; } //30% baby allowed
			}
			//
			card_level=irandom_range(ob_main.card_level_spawn_min,ob_main.card_level_spawn_limit);
			card_glyph_a=-1;
			card_glyph_b=-1;
			card_glyph_c=-1;
			card_form_value=irandom(999);
			//
			var random_id_chance=irandom(999); if random_id_chance<5 and card_id<=normal_poke_id_max { card_shiny=true; } //0.5% shiny, same as in ob_event
			else { card_shiny=false; }
		}
		//————————————————————————————————————————————————————————————————————————————————————————————————————
		else if random_card=true and enemy_randomizer=true {
			if random_group_chance<500 { //5% environment card
				card_id=irandom_range(1,environment_cards_total)+2500;
				card_innate=1;
			}
			else {
				card_id=irandom_range(1,normal_poke_id_max);
				//
				if reference_id.create_card_innate=-1 {
					var card_enemy_innate_value=irandom(999);
					if ob_main.playing_champion=true {
						if card_enemy_innate_value<200 { card_innate=innate_max; } //20%
						else if card_enemy_innate_value<420 { card_innate=3; } //22%
						else if card_enemy_innate_value<670 { card_innate=2; } //25%
						else { card_innate=1; } //33%
					}
					else if ob_main.playing_gym=true or ob_main.playing_elite=true {
						if card_enemy_innate_value<(20+ob_main.area_zone*10) { card_innate=innate_max; } //2% - 10%
						else if card_enemy_innate_value<(50+ob_main.area_zone*25) { card_innate=3; } //3% - 15%
						else if card_enemy_innate_value<(100+ob_main.area_zone*45) { card_innate=2; } //5% - 21%
						else { card_innate=1; } //90% - 54%
					}
					else {
						if card_enemy_innate_value<(10+ob_main.area_zone*5) { card_innate=innate_max; } //1% - 5%
						else if card_enemy_innate_value<(30+ob_main.area_zone*15) { card_innate=3; } //2% - 10%
						else if card_enemy_innate_value<(80+ob_main.area_zone*25) { card_innate=2; } //5% - 13%
						else { card_innate=1; } //92% - 72%
					}
				}
				else { card_innate=reference_id.create_card_innate; }
				//
				var random_id_chance=irandom(99); if random_id_chance<5 { allow_id_enigma=true; } //5% enigma allowed
				var random_id_chance=irandom(99); if random_id_chance<90 { allow_id_pseudo=true; } //90% pseudo allowed
				var random_id_chance=irandom(99); if random_id_chance<90 { allow_id_fossil=true; } //90% fossil allowed
				var random_id_chance=irandom(99); if random_id_chance<80 { allow_id_starter=true; } //80% starter allowed
				var random_id_chance=irandom(99); if random_id_chance<15 { allow_id_baby=true; } //15% baby allowed
			}
			//
			if reference_id.create_card_level=-1 {
				do {
					var accepted_level=true;
					card_level=irandom_range(ob_main.card_level_enemy_min,ob_main.card_level_enemy_limit);
					//
					if card_level=ob_main.card_level_enemy_limit and ob_main.zone_first_lap=true and
					ob_main.playing_gym=false and ob_main.playing_elite=false and ob_main.playing_champion=false {
						accepted_level=choose(true,false,false); //2/3 chance to re-roll
					}
				} until (accepted_level=true);
			}
			else { card_level=reference_id.create_card_level; }
			card_glyph_a=reference_id.create_card_glyph_a;
			card_glyph_b=reference_id.create_card_glyph_b;
			card_glyph_c=reference_id.create_card_glyph_c;
			if reference_id.create_card_form_value=-1 { card_form_value=irandom(999); }
			else { card_form_value=reference_id.create_card_form_value; }
		}
		//————————————————————————————————————————————————————————————————————————————————————————————————————
		else {
			card_level=reference_id.create_card_level;
			card_glyph_a=reference_id.create_card_glyph_a;
			card_glyph_b=reference_id.create_card_glyph_b;
			card_glyph_c=reference_id.create_card_glyph_c;
			card_innate=reference_id.create_card_innate;
			card_form_value=reference_id.create_card_form_value;
			card_shiny=reference_id.create_card_shiny;
		}
		//————————————————————————————————————————————————————————————————————————————————————————————————————
		// SAVE COMPATIBILITY (v1.8.0.0)
		if card_shiny=-1 { card_shiny=false; }
		//————————————————————————————————————————————————————————————————————————————————————————————————————
		sc_pokelist();
		//————————————————————————————————————————————————————————————————————————————————————————————————————
		// SAVE COMPATIBILITY (v1.3.0.1) + (v1.5.0.0) + (v2.0.0.0)
		if random_card=false {
			if (card_id=109 or card_id=110) and card_glyph_a>=glyph_common_amount { card_glyph_a=ref_glyph_mist; } //koffing, weezing
			else if card_id=132 and card_glyph_a!=ref_glyph_imposter { card_glyph_a=ref_glyph_imposter; } //ditto
			else if card_id=231 and card_glyph_a!=ref_glyph_mindful { card_glyph_a=ref_glyph_mindful; } //phanpy
			else if card_id=235 and card_glyph_a!=ref_glyph_palette { card_glyph_a=ref_glyph_palette; } //smeargle
		}
		//————————————————————————————————————————————————————————————————————————————————————————————————————
		if random_card=true or card_glyph_a=-2 or card_glyph_b=-2 or card_glyph_c=-2 {
			if card_glyph_a=-2 { card_glyph_a=-1; } //in case they were -2, which is used for semi-random enemy cards
			if card_glyph_b=-2 { card_glyph_b=-1; }
			if card_glyph_c=-2 { card_glyph_c=-1; }
			//
			if card_id=109 or card_id=110 {
				//koffing, weezing (currently, sc_glyph_check and ob_main.mist_exists only check for slot A, for optimization)
				card_glyph_a=choose(-1,ref_glyph_mist); }
			else if card_id=132 {
				//ditto
				card_glyph_a=ref_glyph_imposter; }
			else if card_id=235 or card_id=352 {
				//smeargle, kecleon
				card_glyph_a=ref_glyph_palette; }
			else if card_id=287 or card_id=288 or card_id=289 or card_id=486 {
				//slakoth, vigoroth, slaking, regigigas
				card_glyph_a=ref_glyph_setback; }
			else if card_id=298 or card_id=183 or card_id=184 or card_id=175 or card_id=176 or card_id=468 or card_id=222 or card_id=223 or card_id=225 or card_id=137 or card_id=233 or
			card_id=474 or card_id=632 {
				//azurill, marill, azumarill, togepi, togetic, togekiss, corsola, remoraid (not octillery), delibird, porygon, porygon2, porygon-z, durant
				card_glyph_a=choose(-1,ref_glyph_might); }
			else if card_id=307 or card_id=308 or card_id=554 or card_id=633 or card_id=634 or card_id=649 {
				//meditite, medicham, darumaka (not darmanitan), deino/zweilous (not hydreigon), genesect
				card_glyph_a=ref_glyph_might; }
			else if card_id=292 {
				//shedinja
				card_glyph_a=ref_glyph_aegis; }
			else if card_id=311 {
				//plusle
				card_glyph_a=ref_glyph_magnetism_p; } //currently, only checks slot A, for optimization
			else if card_id=312 {
				//minun
				card_glyph_a=ref_glyph_magnetism_m; } //currently, only checks slot A, for optimization
			else if card_id=179 or card_id=180 or card_id=181 {
				//mareep, flaaffy, ampharos
				card_glyph_a=choose(-1,-1,-1,ref_glyph_magnetism_p); } //currently, only checks slot A, for optimization
			else if card_id=309 or card_id=310 {
				//electrike, manectric
				card_glyph_a=choose(-1,-1,-1,ref_glyph_magnetism_m); } //currently, only checks slot A, for optimization
			else if card_id=599 or card_id=600 or card_id=601 {
				//klink, klang, klinklang
				card_glyph_a=choose(ref_glyph_magnetism_p,ref_glyph_magnetism_m); } //currently, only checks slot A, for optimization
			else if card_id=420 or card_id=421 {
				//cherubi, cherrim
				card_glyph_a=ref_glyph_sunlight; }
			else if card_id=052 or card_id=190 or card_id=216 or card_id=263 or card_id=264 or card_id=417 or card_id=424 or card_id=446 or card_id=506 {
				//meowth, aipom, teddiursa, zigzagoon, linoone, pachirisu, ambipom, munchlax, lillipup (not herdier/stoutland)
				card_glyph_a=choose(-1,ref_glyph_mindful); }
			else if card_id=231 {
				//phanpy (not donphan)
				card_glyph_a=ref_glyph_mindful; }
			else if card_id=645 {
				//landorus
				card_glyph_a=ref_glyph_intimidate; }
			else if card_id=023 or card_id=024 or card_id=058 or card_id=059 or card_id=128 or card_id=130 or card_id=209 or card_id=210 or card_id=234 or card_id=237 or card_id=262 or
			card_id=284 or card_id=303 or card_id=373 or card_id=397 or card_id=398 or card_id=403 or card_id=404 or card_id=405 or card_id=507 or card_id=508 or card_id=551 or card_id=552 or
			card_id=553 {
				//ekans, arbok, growlithe, arcanine, tauros, gyarados (not magikarp), snubbull, granbull, stantler, hitmontop (not tyrogue), mightyena (not poochyena), masquerain (not surskit),
				//mawile, salamence (not bagon/shelgon), staravia/staraptor (not starly), shinx, luxio, luxray, herdier/stoutland (not lillipup), sandile, krokorok, krookodile
				card_glyph_a=choose(-1,ref_glyph_intimidate); }
			else if card_id=566 or card_id=567 {
				//archen, archeops
				card_glyph_a=ref_glyph_distress; }
			//
			if card_glyph_a=-1 and
			(card_id=056 or card_id=057 or card_id=116 or card_id=117 or card_id=230 or card_id=198 or card_id=430 or card_id=223 or card_id=224 or card_id=359 or card_id=451 or card_id=452 or
			card_id=519 or card_id=520 or card_id=521) {
				//mankey, primeape, horsea, seadra, kingdra, murkrow, honchkrow, remoraid, octillery, absol, skorupi, drapion, pidove, tranquill, unfezant
				card_glyph_a=choose(-1,ref_glyph_confidence); }
			if card_glyph_a=-1 and
			(card_id=015 or card_id=021 or card_id=022 or card_id=167 or card_id=168 or card_id=175 or card_id=176 or card_id=468 or card_id=323 or card_id=551 or card_id=552 or card_id=553) {
				//beedrill, spearow, fearow, spinarak, ariados, togepi, togetic, togekiss, camerupt, sandile, krokorok, krookodile
				//not tauros just because it'd be useless
				card_glyph_a=choose(-1,-1,-1,ref_glyph_confidence); }
			if card_glyph_a=-1 and
			(card_id=211 or card_id=559 or card_id=560) {
				//qwilfish, scraggy, scrafty
				card_glyph_a=choose(-1,-1,-1,ref_glyph_intimidate); }
			if card_glyph_a=-1 and
			(card_id=102 or card_id=103 or card_id=215 or card_id=461 or card_id=273 or card_id=274 or card_id=275 or card_id=357) {
				//exeggcute, exeggutor, sneasel, weavile, seedot, nuzleaf, shiftry, tropius
				card_glyph_a=choose(-1,-1,-1,ref_glyph_forage); }
			//
			if card_environment=false and (card_glyph_a=-1 or card_glyph_b=-1) {
				if enemy_randomizer=false { var guru_chance=irandom(99); } //1%
				else { var guru_chance=irandom(74); } //1.33%
				if guru_chance=0 {
					if card_glyph_a=-1 { card_glyph_a=ref_glyph_guru; }
					else if card_glyph_b=-1 { card_glyph_b=ref_glyph_guru; }
				}
			}
			//
			if enemy_randomizer=false {
				var card_glyph_chance=irandom(999), card_glyph_total=0;
				if card_glyph_chance<5 { card_glyph_total=2; } //0.5%
				else if card_glyph_chance<25 { card_glyph_total=1; } //2%
				//
				if card_glyph_total>=1 and card_glyph_a=-1 {
					card_glyph_a=sc_glyph_random(card_environment);
				}
				if card_glyph_total>=2 and card_glyph_b=-1 {
					do {
						card_glyph_b=sc_glyph_random(card_environment);
					} until (card_glyph_b!=card_glyph_a);
				}
			}
			else {
				var card_glyph_chance=irandom(9999), card_glyph_total=0;
				if card_environment=true {
					if ob_main.stats_league_won=0 and (ob_main.playing_gym=true or ob_main.playing_elite=true or ob_main.playing_champion=true) {
						var card_glyph_chance_limit=3000+875*ob_main.area_zone; } //30%, 38.75%, 47.5%, 56.25%, 65%, 73.75%, 82.5%, 91.25%, (100%)
					else if ob_main.stats_league_won>0 and (ob_main.playing_gym=true or ob_main.playing_elite=true or ob_main.playing_champion=true) {
						var card_glyph_chance_limit=10000; } //100%
					else {
						var card_glyph_chance_limit=2500+625*ob_main.area_zone; } //25%, 31.25%, 37.5%, 43.75%, 50%, 56.25%, 62.5%, 68.75%, (75%)
				}
				else if card_glyph_a=ref_glyph_guru or card_glyph_b=ref_glyph_guru {
					var card_glyph_chance_limit=10000; } //100%
				else if ob_main.stats_league_won=0 and (ob_main.playing_gym=true or ob_main.playing_elite=true or ob_main.playing_champion=true) {
					var card_glyph_chance_limit=1500+225*ob_main.area_zone; } //15%, 17.25%, 19.5%, 21.75%, 24%, 26.25%, 28.5%, 30.75%, (33%)
				else if ob_main.stats_league_won>0 and (ob_main.playing_gym=true or ob_main.playing_elite=true or ob_main.playing_champion=true) {
					var card_glyph_chance_limit=3300; } //33%
				else { var card_glyph_chance_limit=980+190*ob_main.area_zone; } //9.8%, 11.7%, 13.6%, 15.5%, 17.4%, 19.3%, 21.2%, 23.1%, (25%)
				//
				if card_glyph_chance<card_glyph_chance_limit {
					card_glyph_chance=irandom(99);
					if card_glyph_b=ref_glyph_guru {
						card_glyph_total=3; }
					else if ob_main.playing_champion=true {
						if card_glyph_chance<50 { card_glyph_total=3; } //50%
						else if card_glyph_chance<80 { card_glyph_total=2; } //30%
						else if card_glyph_chance<100 and card_glyph_a=ref_glyph_guru { card_glyph_total=2; } //20%
						else if card_glyph_chance<100 and card_glyph_a!=ref_glyph_guru { card_glyph_total=1; } //20%
					}
					else if ob_main.playing_gym=true or ob_main.playing_elite=true {
						if card_glyph_chance<40 { card_glyph_total=3; } //40%
						else if card_glyph_chance<75 { card_glyph_total=2; } //35%
						else if card_glyph_chance<100 and card_glyph_a=ref_glyph_guru { card_glyph_total=2; } //25%
						else if card_glyph_chance<100 and card_glyph_a!=ref_glyph_guru { card_glyph_total=1; } //25%
					}
					else {
						if card_glyph_chance<20 { card_glyph_total=3; } //20%
						else if card_glyph_chance<50 { card_glyph_total=2; } //30%
						else if card_glyph_chance<100 and card_glyph_a=ref_glyph_guru { card_glyph_total=2; } //50%
						else if card_glyph_chance<100 and card_glyph_a!=ref_glyph_guru { card_glyph_total=1; } //50%
					}
					//
					if card_glyph_total>=1 and card_glyph_a=-1 {
						card_glyph_a=sc_glyph_random(card_environment);
					}
					if card_glyph_total>=2 and card_glyph_b=-1 {
						do {
							card_glyph_b=sc_glyph_random(card_environment);
						} until (card_glyph_b!=card_glyph_a);
					}
					if card_glyph_total=3 and card_glyph_c=-1 {
						do {
							card_glyph_c=sc_glyph_random(card_environment);
						} until (card_glyph_c!=card_glyph_a and card_glyph_c!=card_glyph_b);
					}
				}
			}
		}
		//————————————————————————————————————————————————————————————————————————————————————————————————————
		var card_rarity=round(sqrt(card_base_hp+card_base_atk+card_base_def)*10-100);
		//
		if random_card=true {
			var card_rarity_chance=0, card_rarity_soft_min=0, card_rarity_soft_max=-1;
			//
			if enemy_randomizer=false {
				var card_rarity_chance_max=150;
				card_rarity_chance=irandom(card_rarity_chance_max-1)+1;
			}
			else {
				if card_environment=true {
					var card_rarity_chance_max=150;
					card_rarity_chance=irandom(card_rarity_chance_max-1)+1;
				}
				else if ob_main.playing_champion=true {
					var card_rarity_chance_max=270; //about +80% to increase chance for stronger pokemon
					card_rarity_soft_min=87; //about 350 base stat total (349.69)
					card_rarity_chance=irandom(card_rarity_chance_max-1)+1;
				}
				else if ob_main.playing_gym=true or ob_main.playing_elite=true {
					var card_rarity_chance_max=225; //about +50% to increase chance for stronger pokemon
					card_rarity_soft_min=42+ob_main.area_zone*4; //42-74, about 200-300 base stat total (201.64-302.76)
					if ob_main.area_zone=0 and ob_main.stats_league_won=0 { card_rarity_soft_max=81; } //about 330 base stat total (327.61)
					card_rarity_chance=irandom(card_rarity_chance_max-1)+1;
				}
				else {
					var card_rarity_chance_max=190; //about +25% to increase chance for stronger pokemon
					var card_rarity_irandom_max=60+ob_main.latest_zone*45; //60 (above lowest normal-type and dragon-type), 105, 150, 179
					if card_rarity_irandom_max>card_rarity_chance_max-1 { card_rarity_irandom_max=card_rarity_chance_max-1; }
					card_rarity_chance=irandom(card_rarity_irandom_max)+1;
				}
			}
			//
			var card_rarity_check=false;
			if card_rarity_chance>card_rarity or card_rarity_chance=card_rarity_chance_max {
				card_rarity_check=true;
				//
				if enemy_randomizer=false {
					if card_enigma=false and choose_id_enigma=true { card_rarity_check=false; }
					else if card_stage!=2 and choose_id_stage_2=true { card_rarity_check=false; }
					else if card_stage!=3 and choose_id_stage_3=true { card_rarity_check=false; }
					else if (card_stage>1 or card_enigma=true) and choose_id_normal=true { card_rarity_check=false; }
				}
				else {
					if card_enigma=true and (allow_id_enigma=false or (ob_main.playing_elite=false and ob_main.playing_champion=false)) { card_rarity_check=false; }
				}
				//
				if card_pseudo=true and allow_id_pseudo=false { card_rarity_check=false; }
				if card_fossil=true and allow_id_fossil=false { card_rarity_check=false; }
				if card_starter=true and allow_id_starter=false { card_rarity_check=false; }
				if card_stage=0 and allow_id_baby=false { card_rarity_check=false; }
				//
				var card_rarity_soft_check=0;
				//
				if card_rarity_check=true {
					if card_rarity<card_rarity_soft_min {
						card_rarity_soft_check=irandom(19);
						if card_rarity_soft_check=0 { card_rarity_check=true; } //5%
						else { card_rarity_check=false; }
					}
				}
				//
				if card_rarity_check=true {
					if card_rarity_soft_max>-1 and card_rarity>card_rarity_soft_max {
						card_rarity_soft_check=irandom(19);
						if card_rarity_soft_check=0 { card_rarity_check=true; } //5%
						else { card_rarity_check=false; }
					}
				}
				//
				if card_rarity_check=true {
					card_rarity_chance=irandom(34)+1; //level 10: 30 (max) + 5 (higher chances in general)
					if card_rarity_chance>=round(sqrt(card_level-1)*10) { card_rarity_check=true; }
					else { card_rarity_check=false; }
				}
				//
				if card_rarity_check=true and enemy_randomizer=true and card_environment=false {
					card_rarity_check=false;
					//
					for (var i=0; i<=17; i++;) {
						var type_condition_chance=irandom(99);
						if type_condition_chance<ob_control.enemy_type_chance[i] and (card_type_a=i or card_type_b=i) {
							card_rarity_check=true;
						}
					}
				}
			}
		}
	} until (random_card=false or (card_rarity_check=true and card_name!=""));
	//————————————————————————————————————————————————————————————————————————————————————————————————————
	sc_card_level_stats_all(true,true);
	//
	any_common_glyph=false;
	any_natural_glyph=false;
	any_paired_glyph=false;
	if (card_glyph_a<glyph_common_amount and card_glyph_a>=0) or (card_glyph_b<glyph_common_amount and card_glyph_b>=0) or (card_glyph_c<glyph_common_amount and card_glyph_c>=0) { any_common_glyph=true; }
	if card_glyph_a>=glyph_common_amount or card_glyph_b>=glyph_common_amount or card_glyph_c>=glyph_common_amount { any_natural_glyph=true; }
	if card_glyph_a=ref_glyph_magnetism_p or card_glyph_b=ref_glyph_magnetism_p or card_glyph_c=ref_glyph_magnetism_p or
	card_glyph_a=ref_glyph_magnetism_m or card_glyph_b=ref_glyph_magnetism_m or card_glyph_c=ref_glyph_magnetism_m { any_paired_glyph=true; }
	//
	if reference_id=ob_control and (card_glyph_a=ref_glyph_mist /*or card_glyph_b=ref_glyph_mist or card_glyph_c=ref_glyph_mist*/) { ob_main.mist_exists=true; }
}
//————————————————————————————————————————————————————————————————————————————————————————————————————
else if card_cat=1 {
	card_id=reference_id.create_card_id;
	if card_id=-1 { var random_card=true; } else { var random_card=false; }
	//
	if random_card=true {
		var card_berry_chance=irandom(99);
		if card_berry_chance<85 { card_id=choose(3000,3001,3002); }
		else { card_id=3003; } //15%
	}
	//
	switch (card_id) {
		case 3000:
			card_name="Oran Berry"; break;
		case 3001:
			card_name="Leppa Berry"; break;
		case 3002:
			card_name="Lum Berry"; break;
		case 3003:
			card_name="Enigma Berry"; break;
	}
}