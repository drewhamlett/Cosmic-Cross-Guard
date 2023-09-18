require "app/constants"

class SideShot
  BULLET_SPEED = 8
  # FIRE_INTERVAL = 150  # 5 seconds * 60 frames per second
  FIRE_INTERVAL = 120

  attr_accessor :bullets

  def initialize
    @last_fired = 0
    @bullets = []
  end

  def tick(args, player:)
    if args.state.tick_count - @last_fired >= FIRE_INTERVAL
      bullet1 = {x: player[:x], y: player[:y] + 5, dx: BULLET_SPEED, dy: 0, w: 20, h: 5}
      bullet2 = {x: player[:x], y: player[:y] + 5, dx: -BULLET_SPEED, dy: 0, w: 20, h: 5}
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
