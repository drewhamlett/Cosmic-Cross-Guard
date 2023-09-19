class ::Array
  def faster_find(fallback = nil)
    n = size
    i = 0
    while i < n
      val = self[i]
      return val if yield(val)
      i += 1
    end
    fallback
  end
end

require "app/game"
require "app/save"
require "app/screens/upgrade_screen"
require "app/screens/pause_screen"
require "app/screens/game_over_screen"

# standard:disable Style/Globals, Style/GlobalVars

$gtk.warn_array_primitives!
def tick(args)
  $my_game ||= Game.new(args)
  $my_game.args = args
  $upgrade_screen ||= UpgradeScreen.new(args)
  $pause_screen ||= PauseScreen.new(args)
  $game_over_screen ||= GameOverScreen.new(args)

  args.outputs.background_color = [58, 58, 75]

  if args.state.tick_count.zero?
    Save.load!(args)
  end

  if args.keyboard.key_down.r
    reset
  end

  if args.state.health <= 0 && args.state.tick_count != 0
    args.state.game_over = true
  end

  if !args.inputs.keyboard.has_focus && args.gtk.production && args.state.tick_count != 0
    if !args.state.paused
      args.state.paused = true
    end
    $pause_screen.update
  elsif args.state.paused && args.state.tick_count != 0
    $pause_screen.update
  elsif args.state.upgrade_screen && args.state.tick_count != 0
    $upgrade_screen.tick
  elsif args.state.game_over && args.state.tick_count != 0
    $game_over_screen.update
  else
    $my_game.tick(args)
    $pause_screen.update
  end
end

# DR will call this method (in addition do doing what it already does) if $gtk.reset is called
def reset
  $game = nil
end

$gtk.reset
# standard:enable Style/Globals, Style/GlobalVars
