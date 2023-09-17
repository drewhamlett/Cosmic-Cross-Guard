require "app/enemies/enemy"

class EnemyMedium < Enemy
  def initialize(x:, y:, speed:, health: 20)
    super(x: x, y: y, w: 42, h: 42, speed: speed, flash_time: 5, health: health)
    @path = "sprites/enemy_medium.png"
  end

  def particle_color
    [198, 240, 34]
  end
end
