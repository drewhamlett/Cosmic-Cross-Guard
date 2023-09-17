module ScreenShake
  def self.tick(args)
    args.state.shake_timer ||= 0
    args.state.shake_intensity ||= 0
    args.state.shake_disabled ||= false

    if args.state.tick_count.zero?
      args.state.shake_cool_down = 0
    end

    if args.state.shake_timer > 0
      args.state.shake_cool_down -= 1
    end
  end

  def self.shake(args, t: 10, i: 5)
    return unless args.state.post_processing
    return if args.state.shake_disabled
    return if args.state.shake_timer > 0
    args.state.shake_timer = t
    args.state.shake_intensity = i
    # args.state.screen_angle = [0.1, -0.1, 0.2, -0.2, 0.3, -0.3].sample
  end
end
