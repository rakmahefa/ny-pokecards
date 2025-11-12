//ob_splash
//————————————————————————————————————————————————————————————————————————————————————————————————————
if ob_main.fade_black<=0 {
	if mouse_check_button_pressed(mb_any) or keyboard_check_pressed(vk_enter) or keyboard_check_pressed(vk_space) or keyboard_check_pressed(vk_escape) {
		sc_playsound(sn_click,50,false,false);
		ob_main.event_transition=ref_mainmenu;
	}
	else if keyboard_check_pressed(vk_anykey) {
		if keyboard_check_pressed(ord("3")) and secret_code=10 {
			secret_code=11;
			ob_main.secret_code=true;
			sc_playsound(sn_rare_2,50,false,false);
		}
		else if keyboard_check_pressed(ord("9")) and secret_code=9 { secret_code=10; secret_code_time=secret_code_time_max; }
		else if keyboard_check_pressed(ord("2")) and secret_code=8 { secret_code=9; secret_code_time=secret_code_time_max; }
		else if keyboard_check_pressed(ord("1")) and secret_code=7 { secret_code=8; secret_code_time=secret_code_time_max; }
		else if keyboard_check_pressed(ord("O")) and secret_code=6 { secret_code=7; secret_code_time=secret_code_time_max; }
		else if keyboard_check_pressed(ord("R")) and secret_code=5 { secret_code=6; secret_code_time=secret_code_time_max; }
		else if keyboard_check_pressed(ord("O")) and secret_code=4 { secret_code=5; secret_code_time=secret_code_time_max; }
		else if keyboard_check_pressed(ord("P")) and secret_code=3 { secret_code=4; secret_code_time=secret_code_time_max; }
		else if keyboard_check_pressed(ord("P")) and secret_code=2 { secret_code=3; secret_code_time=secret_code_time_max; }
		else if keyboard_check_pressed(ord("A")) and secret_code=1 { secret_code=2; secret_code_time=secret_code_time_max; }
		else if keyboard_check_pressed(ord("S")) and secret_code<11 { secret_code=1; secret_code_time=secret_code_time_max; }
		else if keyboard_check_pressed(vk_anykey) and secret_code<11 { secret_code=0; secret_code_time=0; }
	}
	//
	if secret_code_time>0 { secret_code_time--; }
	else if secret_code<11 { secret_code=0; }
}
//————————————————————————————————————————————————————————————————————————————————————————————————————
if sc_music_sync()=true {
	text_potential_y=-70;
	text_color=make_colour_rgb(irandom_range(170,255),irandom_range(170,255),irandom_range(170,255));
	with (ob_card_splash) {
		if beat_direction=0 {
			potential_y-=70;
			beat_direction=1;
		}
		else {
			potential_y+=70;
			beat_direction=0;
		}
	}
}
else {
	text_potential_y=0;
	with (ob_card_splash) {
		potential_y=initial_y;
	}
}
//
if text_potential_y!=text_rel_y {
	if text_potential_y>text_rel_y {
		var step_y=ceil((text_potential_y-text_rel_y)/5);
		text_rel_y+=step_y;
	}
	else if text_potential_y<text_rel_y {
		var step_y=ceil((text_rel_y-text_potential_y)/5);
		text_rel_y-=step_y;
	}
}