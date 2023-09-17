class UpgradeBar
  LERP_SPEED = 0.05

  X = SCREEN_SIZE_X - 30
  H = SCREEN_SIZE_Y - 50
  Y = 20
  W = 12

  def self.tick(args)
    args.state.current_progress ||= 0.0
    target_progress = args.state.blocks_hit.to_f / args.state.next_level_xp
    args.state.current_progress += (target_progress - args.state.current_progress) * LERP_SPEED
  end

  def self.draw(args)
    filled_h = (args.state.current_progress * H).to_i  # Lerp applied here

    args.outputs.sprites << [
      {
        x: X,
        y: Y,
        w: W,
        h: H,
        r: 0,
        g: 0,
        b: 0,
        a: 10
      },
      {
        x: X,
        y: Y,
        w: W,
        h: filled_h,
        r: 255,
        g: 255,
        b: 255,
        a: 70
      }
    ]
  end

  # Method to set the level (not directly affecting progress bar)
  def self.level(args, level:)
    # Do something with level, perhaps affecting lerp_speed or target_progress
  end
end
