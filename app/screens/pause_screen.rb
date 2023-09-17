class PauseScreen
  FADE_DURATION = 10
  attr_gtk

  def initialize(args)
    @args = args
  end

  def update
    position = 300

    if state.tick_count.zero?
      state.post_processing = true
      state.post_processing_checkbox = {
        x: position,
        y: 650,
        w: 38,
        h: 32
      }
    end

    state.paused ||= false
    state.pause_fade_in ||= 0

    if state.paused
      args.gtk.set_system_cursor("hand")
    else
      args.gtk.set_system_cursor("arrow")
    end

    if inputs.keyboard.key_down.escape || inputs.keyboard.key_down.space
      state.paused = !state.paused
      state.pause_fade_in = 0
    end

    if inputs.mouse.click
      if inputs.mouse.intersect_rect?(state.post_processing_checkbox)
        state.post_processing = !state.post_processing
      end
    end

    if inputs.keyboard.space
      # state.enable_collisions = !state.enable_collisions
      # $gtk.serialize_state("game_state.txt", state)
    end

    if state.paused
      state.pause_fade_in += 1

      fade_percentage = state.pause_fade_in / FADE_DURATION.to_f
      fade_percentage = 1.0 if fade_percentage > 1.0
      alpha = (255 * fade_percentage).to_i

      outputs.background_color = [15, 15, 15]

      outputs.solids << {
        **state.post_processing_checkbox,
        r: 255,
        g: 255,
        b: 255,
        a: alpha
      }

      outputs.labels << {
        size_enum: 2,
        x: position + 18,
        y: 682,
        text: state.post_processing ? "ON" : "OFF",
        alignment_enum: 1,
        r: 0,
        g: 0,
        b: 0,
        a: alpha,
        font: FONT
      }

      outputs.labels << {
        size_enum: 2,
        x: state.post_processing_checkbox.x + state.post_processing_checkbox.w + 8,
        y: 681,
        text: "Visual Post Processing",
        alignment_enum: 0,
        r: 255,
        g: 255,
        b: 255,
        a: alpha,
        font: FONT
      }

      outputs.labels << {
        size_enum: 10,
        x: 640,
        y: SCREEN_SIZE_Y / 1.9,
        text: "Game Paused (Press spacebar to resume)",
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255,
        a: alpha,
        font: FONT
      }

      offset = 5

      outputs.labels << {
        size_enum: 6,
        x: 640,
        y: (SCREEN_SIZE_Y / offset + 50),
        text: "Credits",
        alignment_enum: 1,
        r: 200,
        g: 200,
        b: 200,
        a: alpha,
        font: FONT
      }

      outputs.labels << {
        size_enum: 5,
        x: 640,
        y: SCREEN_SIZE_Y / offset,
        text: "Development / Sprites / Music @drewhamlett",
        alignment_enum: 1,
        r: 200,
        g: 200,
        b: 200,
        a: alpha,
        font: FONT
      }

      outputs.labels << {
        size_enum: 5,
        x: 640,
        y: (SCREEN_SIZE_Y / offset) - 30,
        text: "Sound effects from Splice (Glitchmachines, Sample Magic)",
        alignment_enum: 1,
        r: 200,
        g: 200,
        b: 200,
        a: alpha,
        font: FONT
      }

      outputs.labels << {
        size_enum: 5,
        x: 640,
        y: (SCREEN_SIZE_Y / offset) - 60,
        text: "Font: nimblebeastscollective",
        alignment_enum: 1,
        r: 200,
        g: 200,
        b: 200,
        a: alpha,
        font: FONT
      }

      outputs.labels << {
        size_enum: 5,
        x: 640,
        y: (SCREEN_SIZE_Y / offset) - 90,
        text: "Engine: DragonRuby",
        alignment_enum: 1,
        r: 200,
        g: 200,
        b: 200,
        a: alpha,
        font: FONT
      }
    end
  end
end
