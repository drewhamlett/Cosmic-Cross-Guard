require "app/constants"

class SideShot
  # FIRE_INTERVAL = 150  # 5 seconds * 60 frames per second
  DEFAULT_FIRE_INTERVAL = 120.0

  DAMAGE_SCALE_FACTOR = 1.25
  DECAY_RATE = 0.7
  LOWER_LIMIT = 15.0

  attr_accessor :bullets

  def initialize
    @last_fired = 0
    @bullets = []
  end

  def damage(args)
    (1 * DAMAGE_SCALE_FACTOR**args.state.power_ups.side_shot.level).round
  end

  def bullet_speed(args)
    initial_speed = 8.0
    growth_rate = 0.1  # Increase this to increase speed faster
    upper_limit = 16.0
    level = args.state.power_ups.side_shot.level
    speed = (initial_speed * Math.exp(growth_rate * level)).round
    [speed, upper_limit].min
  end

  def fire_interval(args)
    level = args.state.power_ups.side_shot.level
    interval = (DEFAULT_FIRE_INTERVAL * Math.exp(-DECAY_RATE * level)).round
    [interval, LOWER_LIMIT].max
  end

  def tick(args, player:)
    if args.state.tick_count - @last_fired >= fire_interval(args)
      bullet1 = {x: player[:x], y: player[:y] + 5, dx: bullet_speed(args), dy: 0, w: 20, h: 5}
      bullet2 = {x: player[:x], y: player[:y] + 5, dx: -bullet_speed(args), dy: 0, w: 20, h: 5}
      @bullets.push(bullet1, bullet2)
      @last_fired = args.state.tick_count
    end

    @bullets.each do |bullet|
      bullet[:x] += bullet[:dx]
      bullet[:y] += bullet[:dy]
    end

    @bullets.reject! { |bullet| bullet[:x] > RECT[:x] + RECT[:w] || bullet[:x] < RECT[:x] }
  end

  def draw(args)
    @bullets.map do |bullet|
      {
        x: bullet[:x],
        y: bullet[:y],
        w: bullet.w,
        h: bullet.h,
        r: 255,
        g: 255,
        b: 255
      }
    end
  end
end
