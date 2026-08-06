for (var i = 0; i < array_length(pop_ups); i++){
	var _channel = animcurve_channel_evaluate(curve, pop_ups[i].timer / pop_ups[i].max_timer);
	var _scale = _channel * .3 + pop_ups[i].scale;
	var _alpha = _channel;
	
    scribble($"[alpha, {_alpha}][scale, {_scale}]{pop_ups[i].text}").draw(pop_ups[i].x, pop_ups[i].y);
	
    if (--pop_ups[i].timer <= 0){
        array_delete(pop_ups, i, 1);
        i -= 1;
    }
}
