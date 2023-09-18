require "app/enemies/enemy"

class EnemyCrazy < Enemy
  def initialize(x:, y:, speed:, health: 1)
    super(x: x, y: y, w: 24, h: 24, speed: speed, flash_time: 5, health: health)
    @path = "sprites/enemy_crazy.png"
    @sine_angle = 0
  end

  def particle_color
    [252, 106, 34]
  end

  def tick(args)
    @sine_angle += 0.05
    sine_value = Math.sin(@sine_angle)

    super(args)
    @x += sine_value * 5 unless hit?
  end
end
