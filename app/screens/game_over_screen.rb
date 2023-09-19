class GameOverScreen
  FADE_DURATION = 10
  attr_gtk

  def initialize(args)
    @args = args
  end

  def update
    state.game_over ||= false
    state.game_over_fade_in ||= 0

    if inputs.keyboard.key_down.space
      state.health = 10
      state.current_level = 10
      state.base.each { |base| base[:hit] = false }

      state.game_over = !state.game_over
      state.game_over_fade_in = 0
    end

    if state.game_over
      state.game_over_fade_in += 1

      fade_percentage = state.game_over_fade_in / FADE_DURATION.to_f
      fade_percentage = 1.0 if fade_percentage > 1.0
      alpha = (255 * fade_percentage).to_i

      outputs.background_color = [15, 15, 15]

      outputs.labels << {
        size_enum: 10,
        x: 640,
        y: SCREEN_SIZE_Y / 1.9,
        text: "Game Over (Press spacebar to restart)",
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255,
        a: alpha,
        font: FONT
      }
    end
  end
end
