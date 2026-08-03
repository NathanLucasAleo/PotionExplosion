var _max_channels = 1024
var _flags_core = FMOD_INIT.NORMAL;
var _flags_studio = FMOD_STUDIO_INIT.LIVEUPDATE;



// If we enable debug callbacks in the macro above set them ON /
if (USE_DEBUG_CALLBACKS)
{
    fmod_debug_initialize(FMOD_DEBUG_FLAGS.LEVEL_LOG, FMOD_DEBUG_MODE.CALLBACK);
}

// If we want to use FMOD_STUDIO /
if (USE_FMOD_STUDIO)
{
    fmod_studio_system_create();
    show_debug_message("fmod_studio_system_create: " + string(fmod_last_result()));

    fmod_studio_system_init(_max_channels, _flags_studio, _flags_core);
    show_debug_message("fmod_studio_system_init: " + string(fmod_last_result()));

    fmod_main_system = fmod_studio_system_get_core_system();
}
// If we want to use FMOD Core only
else
{
    fmod_main_system = fmod_system_create()
    show_debug_message("fmod_system_create: " + string(fmod_last_result()))

    fmod_system_init(_max_channels, _flags_core)
    show_debug_message("fmod_system_init: " + string(fmod_last_result()))
}