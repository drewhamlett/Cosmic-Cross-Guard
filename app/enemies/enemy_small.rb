require "app/enemies/enemy"

class EnemySmall < Enemy
  def initialize(x:, y:, speed:, health: 1)
    super(x: x, y: y, w: 32, h: 32, speed: speed, flash_time: 5, health: health)
    @path = "sprites/block_1.png"
  end

  def particle_color
    [103, 205, 252]
  end
end
