class UpgradeScreen
  attr_gtk

  SPACE = 300

  def initialize(args)
    @args = args
  end

  def tick
    state.input_delay -= 1
    if (inputs.keyboard.left || inputs.controller_one.left || inputs.finger_left) && state.input_delay <= 0
      PowerUps.upgrade!(args, power_up: state.power_up_left_right.first[:type])
      done!
    end

    if (inputs.keyboard.right || inputs.controller_one.right || inputs.finger_left) && state.input_delay <= 0
      PowerUps.upgrade!(args, power_up: state.power_up_left_right.second[:type])
      done!
    end

    outputs.background_color = [0, 0, 0]
    outputs.labels << {
      size_enum: 15,
      x: SCREEN_SIZE_X / 2,
      y: SCREEN_SIZE_Y - 150,
      text: "CHECKPOINT!",
      alignment_enum: 1,
      r: 255,
      g: 255,
      b: 255,
      font: FONT
    }

    outputs.labels << {
      x: 0 + SPACE,
      y: 390,
      text: "Press Left",
      r: 255,
      g: 255,
      b: 255,
      font: FONT,
      a: 200,
      alignment_enum: 1,
      size_enum: 9
    }

    outputs.labels << {
      x: 0 + SPACE,
      y: 330,
      # text: "Rotating Orb: Orb that is powerful (Level 1)",
      text: state.power_up_left_right.first[:text],
      r: 255,
      g: 255,
      b: 255,

      alignment_enum: 1,
      size_enum: 3,
      font: FONT
    }

    outputs.labels << {
      x: SCREEN_SIZE_X - SPACE,
      y: 390,
      text: "Press Right",
      r: 255,
      g: 255,
      b: 255,
      a: 200,
      font: FONT,
      alignment_enum: 1,
      size_enum: 9
    }

    outputs.labels << {
      x: SCREEN_SIZE_X - SPACE,
      y: 330,
      text: state.power_up_left_right.second[:text],
      r: 255,
      g: 255,
      b: 255,
      alignment_enum: 1,
      size_enum: 3,
      font: FONT
    }
  end

  def done!
    state.upgrade_screen = false
  end
end
