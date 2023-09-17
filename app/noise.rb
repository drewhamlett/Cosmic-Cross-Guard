module Noise
  NOISE_AMOUNT = 20
  NOISE_PATHS = (0..NOISE_AMOUNT).to_a.map do |i|
    "sprites/noise/noise_frame_#{i}-fs8.png"
  end.freeze

  def self.draw(args)
    tick_count = args.state.tick_count
    current_frame = tick_count.idiv(1).mod(NOISE_AMOUNT)

    image = current_frame + 1

    if args.state.tick_count.zero?
      args.outputs.static_sprites << {
        x: 0,
        y: 0,
        w: 1366,
        h: 768,
        path: "sprites/v.png",
        a: 255
      }
    end

    if args.state.post_processing
      args.outputs.sprites << {
        x: 0,
        y: 0,
        w: 1366,
        h: 768,
        path: NOISE_PATHS[image],
        a: 10
      }
    end
  end
end
