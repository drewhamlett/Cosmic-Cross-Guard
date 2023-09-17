# frozen_string_literal: true

require "app/constants"

class Gun
  BULLET_SPEED = 20
  FIRE_INTERVAL = 60

  attr_gtk

  attr_accessor :bullets

  def initialize(args)
    @args = args
    @last_fired = 0
    @bullets = []
  end

  def collision(args, blocks:)
    blocks.each do |block|
      @bullets.each do |bullet|
        if bullet.intersect_rect?(block)
          blocks.delete(block)
        end
      end
    end
  end

  def tick(player:, enemies:)
    current_time = state.tick_count
    if current_time - @last_fired >= FIRE_INTERVAL
      @last_fired = current_time

      furthest_enemy = find_furthest_enemy(player, enemies)
      if furthest_enemy
        fire_bullet_towards(player, furthest_enemy)
      end
    end

    # Update bullet positions
    @bullets.each do |bullet|
      bullet[:x] += bullet[:dx] * BULLET_SPEED
      bullet[:y] += bullet[:dy] * BULLET_SPEED
    end

    # Remove bullets out of bounds
    @bullets.reject! { |bullet| bullet[:x] > RECT[:x] + RECT[:w] || bullet[:x] < RECT[:x] }
  end

  def find_furthest_enemy(player, enemies)
    furthest_enemy = nil
    max_distance = 0

    enemies.each do |enemy|
      distance = @args.geometry.distance(player, enemy)
      if distance > max_distance
        max_distance = distance
        furthest_enemy = enemy
      end
    end

    furthest_enemy
  end

  def fire_bullet_towards(player, enemy)
    time_to_reach = args.geometry.distance(player, enemy) / BULLET_SPEED

    future_enemy_x = enemy.x + enemy.dx * time_to_reach
    future_enemy_y = enemy.y + enemy.dy * time_to_reach
    future_enemy = {x: future_enemy_x, y: future_enemy_y}

    angle = args.geometry.angle_to(player, future_enemy)
    dx = Math.cos(angle.to_radians)
    dy = Math.sin(angle.to_radians)

    bullet = {
      x: player[:x],
      y: player[:y],
      dx: dx,
      dy: dy,
      w: 8,
      h: 8
    }

    @bullets << bullet
  end

  def draw
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
