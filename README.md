## obs-script1
learn LUA script from https://www.lua.org/pil/1.html </br>
make a LUA script for OBS Studio </br>

# user input
some checkboxes in OBS Script property panel </br>
- DLC, MOD, disaster, Mic, chat TTS, BGM
- BGM URL

# script output
to source in OBS scene
- source_type: Text (GDI+) </br>
- source_name: Title </br>

read checkboxes and make a string </br>
> { ALL / NO } DLC, { Using / NO } MOD, Disaster { ON / OFF } </br>
> MIC { ON / OFF }, Chat TTS { ON / OFF }, BGM { ON / OFF } , url info (if only BGM is ON) </br>

set string to Text source </br>

# References
https://obsproject.com/docs/scripting.html#script-sources-lua-only  </br>
https://dev.to/hectorleiva/start-to-write-plugins-for-obs-with-lua-1172?fbclid=IwAR2_oLcHhzYgUxPo137RoiCkzxo8J7KymLrPzJYXCe2jZNclc7zDiIfzKA0  </br>
https://github.com/hectorleiva/obs_current_date  </br>

string concat methods
https://www.rubyguides.com/2019/07/ruby-string-concatenation/
