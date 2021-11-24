obs           = obslua
source_name   = "titletext"
-- my variables
dlcflag       = 0
modflag       = 0
micflag       = 0
ttsflag       = 0
bgmsrc        = ""
bgmflag       = 0
titletext     = ""
obsmicflag    = 0

--total_seconds = 0
--
--cur_seconds   = 0
--last_text     = ""
--stop_text     = ""
activated     = false

hotkey_id     = obs.OBS_INVALID_HOTKEY_ID


-- 변수는 만들었고,
-- 출력될 obs source를 text(GDI+)로 해서 text 값을 내보내기
-- 스크립트 동작 및 프로퍼티 세팅 관련
-- obs의 input source 중 마이크를 골라서 mic 변수에 연동
-- https://obsproject.com/docs/scripting.html#script-sources-lua-only 에서 찾아볼 것
-- https://dev.to/hectorleiva/start-to-write-plugins-for-obs-with-lua-1172?fbclid=IwAR2_oLcHhzYgUxPo137RoiCkzxo8J7KymLrPzJYXCe2jZNclc7zDiIfzKA0
-- https://github.com/hectorleiva/obs_current_date
--
--
----------------------------------------------------------

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

    -- 여기에다 내가 원하는 걸 만드는 건가.
    obs.obs_properties_add_int_slider(props, "DLC", "Using DLC", 0, 1, 1)
    obs.obs_properties_add_int_slider(props, "MOD", "Using MOD from Steam Workshop", 0, 1, 1)
    obs.obs_properties_add_int_slider(props, "MIC", "Using Mic", 0, 1, 1)
    obs.obs_properties_add_int_slider(props, "Chat TTS", "Using Chat TTS", 0, 1, 1)
    obs.obs_properties_add_int_slider(props, "BGM", "playing BGM", 0, 1, 1)
    obs.obs_properties_add_text(props, "BGM Src", "BGM source", obs.OBS_TEXT_DEFAULT)

	return props
end

-- A function named script_defaults will be called to set the default settings
function script_defaults(settings)
	obs.obs_data_set_default_int(settings, "DLC", 1)
	obs.obs_data_set_default_int(settings, "MOD", 1)
	obs.obs_data_set_default_int(settings, "MIC", 0)
	obs.obs_data_set_default_int(settings, "Chat TTS", 1)
	obs.obs_data_set_default_int(settings, "BGM", 1)
	obs.obs_data_set_default_string(settings, "BGM Src", "")
end

-- A function named script_update will be called when settings are changed
function script_update(settings)
    dlcflag       = obs.obs_data_get_int(settings, "DLC")
    modflag       = obs.obs_data_get_int(settings, "MOD")
    micflag       = obs.obs_data_get_int(settings, "MIC")
    ttsflag       = obs.obs_data_get_int(settings, "Chat TTS")
    bgmflag       = obs.obs_data_get_int(settings, "BGM")
    bgmsrc        = obs.obs_data_get_string(settings, "BGM Src")
    source_name   = obs.obs_data_get_string(settings, "source")
    
    set_title_text()
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
	-- obs.signal_handler_connect(sh, "source_deactivate", source_deactivated)
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
    set_title_text()
end

-- my Function to set title text
function set_title_text()
    titletext = "Cities Skyline : "
    if dlcflag then 
        titletext = titletext .. "All"
    else
        titletext = titletext .. "NO"
    end
    
    titletext = titletext .. " DLC, "
    
    if modflag then
        titletext = titletext .. "MOD"
    else
        titletext = titletext .. ""
    end

    titletext = titletext .. ", MIC "
    
    if micflag then
        titletext = titletext .. "ON"
    else
        titletext = titletext .. "OFF"
    end
    
    titletext = titletext .. ", Chat TTS "
    
    if ttsflag then
        titletext = titletext .. "ON"
    else
        titletext = titletext .. "OFF"
    end
    
    titletext = titletext .. ", BGM "
    
    if bgmflag then
        titletext = titletext .. "ON"
        if string.len(bgmsrc) > 1 then
            titletext = titletext .. ", " .. bgmsrc
        end
    else
        titletext = titletext .. "OFF"
    end
    
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

-- A function named script_save will be called when the script is saved
--
-- NOTE: This function is usually used for saving extra data (such as in this
-- case, a hotkey's save data).  Settings set via the properties are saved
-- automatically.
function script_save(settings)
end