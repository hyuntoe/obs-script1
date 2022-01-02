obs           = obslua
source_name   = ""

titletext     = ""

-- A function named script_properties defines the properties that the user
-- can change for the entire script module itself
function script_properties()
	local props = obs.obs_properties_create()
	
	local p = obs.obs_properties_add_list(props, "source", "Text Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local sources = obs.obs_enum_sources()

	if sources ~= nil then
		for _, source in ipairs(sources) do
			source_id = obs.obs_source_get_unversioned_id(source)
			if source_id == "text_gdiplus" or source_id == "text_ft2_source" then
				local name = obs.obs_source_get_name(source)
				obs.obs_property_list_add_string(p, name, name)
			end
		end
	end

	obs.source_list_release(sources)

    obs.obs_properties_add_bool(props, "DLC", "Using DLC")
    obs.obs_properties_add_bool(props, "MOD", "Using MOD")
    obs.obs_properties_add_bool(props, "Dis", "Disater ON")
    obs.obs_properties_add_bool(props, "MIC", "Using Mic")
    obs.obs_properties_add_bool(props, "Chat TTS", "Using Chat TTS")
    obs.obs_properties_add_bool(props, "BGM", "playing BGM")
    obs.obs_properties_add_text(props, "BGM Src", "BGM source", obs.OBS_TEXT_DEFAULT)

	return props
end

-- A function named script_defaults will be called to set the default settings
function script_defaults(settings)
	obs.obs_data_set_default_bool(settings, "DLC", true)
	obs.obs_data_set_default_bool(settings, "MOD", true)
  obs.obs_data_set_default_bool(settings, "Dis", false)
  obs.obs_data_set_default_bool(settings, "MIC", false)
	obs.obs_data_set_default_bool(settings, "Chat TTS", true)
	obs.obs_data_set_default_bool(settings, "BGM", true)
	obs.obs_data_set_default_string(settings, "BGM Src", "")
end

-- A function named script_update will be called when settings are changed
function script_update(settings)
    source_name   = obs.obs_data_get_string(settings, "source")
    set_title_text(settings)
end

-- a function named script_load will be called on startup
-- NOTE: These particular script callbacks do not necessarily have to
-- be disconnected, as callbacks will automatically destroy themselves
-- if the script is unloaded.  So there's no real need to manually
-- disconnect callbacks that are intended to last until the script is
-- unloaded.
function script_load(settings)
	local sh = obs.obs_get_signal_handler()
	obs.signal_handler_connect(sh, "source_activate", source_activated)
end

function source_activated(cd)
    activate_plugin(cd)
end

-- Called when this source is activated
function activate_plugin(cd)
    local source = obs.calldata_source(cd, "source")
    if source ~= nil then
        local name = obs.obs_source_get_name(source)
        if (name == source_name) then
            activate()
        end
    end
end

function activate()
    set_title_text(settings)
end

-- my Function to set title text
function set_title_text(settings)
    if obs.obs_data_get_bool(settings, "DLC") then
        dlctext = "ALL "
    else
        dlctext = "NO "
    end
    
    if obs.obs_data_get_bool(settings, "MOD") then
        modtext = ""
    else
        modtext = "NO "
    end

    if obs.obs_data_get_bool(settings, "Dis") then
        distext = "ON"
    else
        distext = "OFF"
    end
    
    if obs.obs_data_get_bool(settings, "MIC") then
        mictext = "ON"
    else
        mictext = "OFF"
    end
    
    if obs.obs_data_get_bool(settings, "Chat TTS") then
        ttstext = "ON"
    else
        ttstext = "OFF"
    end
    
    if obs.obs_data_get_bool(settings, "BGM") then
        bgmtext = "ON"
        bgmsrc = obs.obs_data_get_string(settings, "BGM Src")
        if bgmsrc == "" then
            bgmtext = bgmtext.."."
        else
            bgmtext = bgmtext..", "..bgmsrc
        end
    else
        bgmtext = "OFF"
    end
    titletext = dlctext.."DLC, "..modtext.."MOD, Disater "..distext..",\nMIC "..mictext..", Chat TTS "..ttstext..", BGM "..bgmtext

    local source = obs.obs_get_source_by_name(source_name)
    if source ~= nil then
        local settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", titletext)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)
    end
end    

-- A function named script_description returns the description shown to the user
function script_description()
	return "Sets a text source to write down setting selected.\n\nMade by HT"
end