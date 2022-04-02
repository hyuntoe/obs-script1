-- initialize
obs           = obslua
source_name   = "Title"
titletext     = ""
origin_text   = ""
origin_text_array = {}

-- A function named script_properties defines the properties that the user
-- can change for the entire script module itself
function script_properties()    
	local props = obs.obs_properties_create()

    -- local p = obs.obs_properties_add_list(props, "source", "Text Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	-- local sources = obs.obs_enum_sources()

	-- if sources ~= nil then
	-- 	for _, source in ipairs(sources) do
	-- 		source_id = obs.obs_source_get_unversioned_id(source)
	-- 		if source_id == "text_gdiplus" or source_id == "text_ft2_source" then
	-- 			local name = obs.obs_source_get_name(source)
	-- 			obs.obs_property_list_add_string(p, name, name)
	-- 		end
	-- 	end
	-- end

	-- obs.source_list_release(sources)

    obs.obs_properties_add_bool(props, "DLC", "Using DLC")
    obs.obs_properties_add_bool(props, "MOD", "Using MOD")
    obs.obs_properties_add_bool(props, "DIS", "Disaster ON")
    obs.obs_properties_add_bool(props, "MIC", "Using Mic")
    obs.obs_properties_add_bool(props, "TTS", "Using Chat TTS")
    obs.obs_properties_add_bool(props, "BGM", "playing BGM")
    obs.obs_properties_add_text(props, "URL", "", obs.OBS_TEXT_DEFAULT)

    -- for test of function activate()
    -- get_text(source_name)
    -- get_position(origin_text)
    -- get_string(origin_text)

    -- obs.obs_properties_add_bool(props, "test", origin_text)
    -- local temp_text = "DLC:"..origin_text_array["DLC_t"]
    -- temp_text=temp_text.."/MOD:"..origin_text_array["MOD_t"]
    -- temp_text=temp_text.."/Disater:"..origin_text_array["DIS_t"].."\n"
    -- temp_text=temp_text.."/MIC:"..origin_text_array["MIC_t"]
    -- temp_text=temp_text.."/Chat TTS:"..origin_text_array["TTS_t"]
    -- temp_text=temp_text.."/BGM:"..origin_text_array["BGM_t"].."\n"
    -- temp_text=temp_text.."/URL:/"..origin_text_array["URL_t"].."/"

    -- obs.obs_properties_add_bool(props, "1111", temp_text)
    -- test end
    return props
end

-- function get content text from selected text source
function get_text(source_name)
    local source = obs.obs_get_source_by_name (source_name)
    local settings = obs.obs_source_get_settings(source)
    origin_text = obs.obs_data_get_string (settings, "text")

    obs.obs_source_release(source)
    obs.obs_data_release(settings)
end

-- function get positon from content text
-- ALL DLC, Using MOD, Disaster ON,\nMIC OFF, Chat TTS ON, BGM ON, URLs
-- ---------1---------2---------3-- -------4---------5---------6-------
-- ---------0---------0---------0-- -------0---------0---------0-------
-- ----0----------1----2----------- -3--------4----4-------5-------6--6
-- ----5----------6----1----------- -4--------3----8-------6-------4--7
-- /n is just 1 character
function get_position(origin_text)
    origin_text_array["DLC"] = string.find(origin_text,"DLC") -- 5 OK
    origin_text_array["MOD"] = string.find(origin_text,"MOD") -- 16 OK
    origin_text_array["DIS"] = string.find(origin_text,"Disaster") --21 OK
    origin_text_array["MIC"] = string.find(origin_text,"MIC") --34 OK
    origin_text_array["TTS"] = string.find(origin_text,"TTS") --48 OK
    origin_text_array["BGM"] = string.find(origin_text,"BGM") --56 OK
    -- origin_text_array["URL"] = string.len(origin_text)-string.find(string.reverse(origin_text),",") 
    origin_text_array["URL"] = string.find(origin_text,",",origin_text_array["BGM"]) 
    if origin_text_array["URL"] ~= nil then
        if origin_text_array["URL"] > origin_text_array["BGM"] then
            origin_text_array["URL"] = origin_text_array["URL"] +2
        else
            origin_text_array["URL"] = nil
        end
    end

end

function get_string(origin_text)
    origin_text_array["DLC_t"],origin_text_array["MOD_t"],origin_text_array["DIS_t"],origin_text_array["MIC_t"],origin_text_array["BGM_t"],origin_text_array["URL_t"] = ""
    if origin_text_array["DLC"] and origin_text_array["MOD"] and origin_text_array["DIS"] and origin_text_array["MIC"] and origin_text_array["TTS"] and origin_text_array["BGM"] then
        origin_text_array["DLC_t"] = string.sub( origin_text, 1, origin_text_array["DLC"]-2 )
        origin_text_array["MOD_t"] = string.sub( origin_text, origin_text_array["DLC"]+5, origin_text_array["MOD"]-2 )
        origin_text_array["DIS_t"] = string.sub( origin_text, origin_text_array["DIS"]+9, origin_text_array["MIC"]-3 )
        origin_text_array["MIC_t"] = string.sub( origin_text, origin_text_array["MIC"]+4, origin_text_array["TTS"]-8 )
        origin_text_array["TTS_t"] = string.sub( origin_text, origin_text_array["TTS"]+4, origin_text_array["BGM"]-3 )
        if origin_text_array["URL"] ~= nil then
            origin_text_array["BGM_t"] = string.sub( origin_text, origin_text_array["BGM"]+4, origin_text_array["URL"]-3 )
            origin_text_array["URL_t"] = string.sub( origin_text, origin_text_array["URL"], string.len(origin_text) )
        else
            origin_text_array["BGM_t"] = string.sub( origin_text, origin_text_array["BGM"]+4, string.len(origin_text) )
            origin_text_array["URL_t"] = ""
        end
    end
end

-- A function named script_defaults will be called to set the default settings
function script_defaults(settings)
    get_text(source_name)
    get_position(origin_text)
    get_string(origin_text)
    
    if origin_text_array["DLC_t"] == "ALL" then
        obs.obs_data_set_default_bool(settings, "DLC", true)
    elseif origin_text_array["DLC_t"] == "NO" then
        obs.obs_data_set_default_bool(settings, "DLC", false)
    end

	if origin_text_array["MOD_t"] == "Using" then
        obs.obs_data_set_default_bool(settings, "MOD", true)
    elseif origin_text_array["MOD_t"] == "NO" then
        obs.obs_data_set_default_bool(settings, "MOD", false)
    end
    
    if origin_text_array["DIS_t"] == "ON" then
        obs.obs_data_set_default_bool(settings, "DIS", true)
    elseif origin_text_array["DIS_t"] == "OFF" then
        obs.obs_data_set_default_bool(settings, "DIS", false)
    end
    
    if origin_text_array["MIC_t"] == "ON" then
        obs.obs_data_set_default_bool(settings, "MIC", true)
    elseif origin_text_array["MIC_t"] == "OFF" then
        obs.obs_data_set_default_bool(settings, "MIC", false)
    end

    if origin_text_array["TTS_t"] == "ON" then
        obs.obs_data_set_default_bool(settings, "TTS", true)
    elseif origin_text_array["TTS_t"] == "OFF" then
        obs.obs_data_set_default_bool(settings, "TTS", false)
    end

    if origin_text_array["BGM_t"] == "ON" then
        obs.obs_data_set_default_bool(settings, "BGM", true)
    elseif origin_text_array["BGM_t"] == "OFF" then
        obs.obs_data_set_default_bool(settings, "BGM", false)
    end
	
    if origin_text_array["URL_t"] ~= nil then
        obs.obs_data_set_default_string(settings, "URL", origin_text_array["URL_t"])
    else
        obs.obs_data_set_default_string(settings, "URL", "")
    end
	
end

-- A function named script_update will be called when settings are changed
function script_update(settings)
    -- source_name   = obs.obs_data_get_string(settings, "source")
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
    -- set_title_text(settings)
    get_text(source_name)
    get_position(origin_text)
    get_string(origin_text)
    set_string(settings)

end

function set_string(settings)
    local dlctext = origin_text_array["DLC_t"].." "
    local modtext = origin_text_array["MOD_t"].." "
    local distext = origin_text_array["DIS_t"]
    local mictext = origin_text_array["MIC_t"]
    local ttstext = origin_text_array["TTS_t"]
    local bgmtext = origin_text_array["BGM_t"]
    local bgmsrc = origin_text_array["URL_t"]

    if bgmtext == "ON" then
        bgmsrc = origin_text_array["URL_t"]
        if bgmsrc ~= nil then
            bgmtext = bgmtext..", "..bgmsrc
        end
    else
        bgmtext = "OFF"
    end
    local titletext = dlctext.."DLC, "..modtext.."MOD, Disaster "..distext..",\nMIC "..mictext..", Chat TTS "..ttstext..", BGM "..bgmtext

    local source = obs.obs_get_source_by_name(source_name)
    if source ~= nil then
        local settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", titletext)

        obs.obs_source_update(source, settings)

        obs.obs_data_release(settings)
        obs.obs_source_release(source)
    end
end

-- my Function to set title text
function set_title_text(settings)
    local dlctext, modtext, distext, mictext, ttstext, bgmtext, bgmsrc

    if obs.obs_data_get_bool(settings, "DLC") then
        dlctext = "ALL "
    else
        dlctext = "NO "
    end
    
    if obs.obs_data_get_bool(settings, "MOD") then
        modtext = "Using "
    else
        modtext = "NO "
    end

    if obs.obs_data_get_bool(settings, "DIS") then
        distext = "ON"
    else
        distext = "OFF"
    end
    
    if obs.obs_data_get_bool(settings, "MIC") then
        mictext = "ON"
    else
        mictext = "OFF"
    end
    
    if obs.obs_data_get_bool(settings, "TTS") then
        ttstext = "ON"
    else
        ttstext = "OFF"
    end
    
    if obs.obs_data_get_bool(settings, "BGM") then
        bgmtext = "ON"
        bgmsrc = obs.obs_data_get_string(settings, "URL")
        if bgmsrc ~= "" then
            bgmtext = bgmtext..", "..bgmsrc
        end
    else
        bgmtext = "OFF"
    end
    titletext = dlctext.."DLC, "..modtext.."MOD, Disaster "..distext..",\nMIC "..mictext..", Chat TTS "..ttstext..", BGM "..bgmtext

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