require "app/enemies/enemy"

class EnemyLarge < Enemy
  def initialize(x:, y:, speed:, health: 3)
    super(x: x, y: y, w: 38, h: 39, speed: speed, flash_time: 6, health: health)
    @path = "sprites/enemy_large.png"

    @random_hit = [
      "sprites/hit.png",
      "sprites/wavey-Sheet.png"
    ].sample
  end

  def particle_color
    [
      255,
      255,
      0
    ]
  end

  def hit_sprite
    "sprites/block_hit.png"
  end

  def fade_away_sprite
    @random_hit
  end

  # def hit_sprite
  #   @random_hit
  # end

  # def blendmode_enum
  #   (@hit && @flash_time > 0) ? 2 : 1
  # end

  # def path
  #   if @hit && @flash_time > 0
  #     "sprites/block_1_hit.png"
  #   else
  #     @hit ? @random_hit : @path
  #   end
  # end
end
