pattern_time = require 'pattern_time' -- use the pattern_time lib in this script

g = grid.connect()

function init()
  grid_pattern = pattern_time.new() -- establish a pattern recorder
  grid_pattern.process = parse_grid_pattern -- assign the function to be executed when the pattern plays back

  grid_value = {0,0,0}
  pattern_message = "press K3 to start recording"
  erase_message = "(no pattern recorded)"
  overdub_message = ""


  screen_dirty = true
  screen_timer = clock.run(
    function()
      while true do
        clock.sleep(1/15)
        if screen_dirty then
          redraw()
          screen_dirty = false
        end
      end
    end
  )
end

function record_grid_value()
  grid_pattern:watch(
    {
      ["x"] = grid_value[1]
      ["y"] = grid_value[2]
      ["z"] = grid_value[3]
    }
  )
end

function parse_grid_pattern(data)
  grid_value = data.value
  screen_dirty = true
end

function key(n,z)
  if n == 3 and z == 1 then
    if grid_pattern.rec == 1 then -- if we're recording...
      grid_pattern:rec_stop() -- stop recording
      grid_pattern:start() -- start playing
      pattern_message = "playing, press K3 to stop"
      erase_message = "press K2 to erase"
      overdub_message = "hold K1 to overdub"
    elseif grid_pattern.count == 0 then -- otherwise, if there are no events recorded..
      grid_pattern:rec_start() -- start recording
      record_grid_value()
      pattern_message = "recording, press K3 to stop"
      erase_message = "press K2 to erase"
      overdub_message = ""
    elseif grid_pattern.play == 1 then -- if we're playing...
      grid_pattern:stop() -- stop playing
      pattern_message = "stopped, press K3 to play"
      erase_message = "press K2 to erase"
      overdub_message = ""
    else -- if by this point, we're not playing...
      grid_pattern:start() -- start playing
      pattern_message = "playing, press K3 to stop"
      erase_message = "press K2 to erase"
      overdub_message = "hold K1 to overdub"
    end
  elseif n == 2 and z == 1 then
    grid_pattern:rec_stop() -- stops recording
    grid_pattern:stop() -- stops playback
    grid_pattern:clear() -- clears the pattern
    erase_message = "(no pattern recorded)"
    pattern_message = "press K3 to start recording"
    overdub_message = ""
  elseif n == 1 then
    grid_pattern:set_overdub(z) -- toggles overdub
    overdub_message = z == 1 and "overdubbing" or "hold K1 to overdub"
  end
  screen_dirty = true
end

function g.key(x,y,z)
  g:all(0)
  record_grid_value()
  if z == 1 then
    g:led(x,y,12)
  end
  g:refresh()
end

function redraw()
  screen.clear()
  screen.level(15)
  screen.move(0,10)
  screen.text("encoder 3 value: "..enc_value)
  screen.move(0,40)
  screen.text(pattern_message)
  screen.move(0,50)
  screen.text(erase_message)
  screen.move(0,60)
  screen.text(overdub_message)
  screen.update()
end
