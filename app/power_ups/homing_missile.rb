# frozen_string_literal: true

class HomingMissile
  # MISSILE_SPEED = 2
  # FIRE_INTERVAL = 60 * 3
  # FIRE_INTERVAL = 30
  MIN_LOCK_DISTANCE = 200
  DAMAGE_SCALE_FACTOR = 1.5
  attr_accessor :missiles, :last_fired

  attr_gtk

  def initialize(args)
    @args = args
    @missiles = []
    @last_fired = 0
    @level = 1
  end

  def damage
    (1 * DAMAGE_SCALE_FACTOR**state.power_ups.homing_missile.level).round
  end

  def fire_interval
    case state.power_ups.homing_missile.level
    when 1
      60 * 3
    when 2
      60 * 2
    when 3
      30
    when 4
      20
    else
      10
    end
  end

  def speed
    case state.power_ups.homing_missile.level
    when 1
      2
    when 2
      2.5
    when 3
      3
    when 4
      4
    else
      5
    end
  end

  def tick(player:, enemies:)
    if state.tick_count >= @last_fired + fire_interval
      current_targets = @missiles.map { |missile| missile[:target] } || []
      target = enemies.faster_find do |enemy|
        @args.geometry.distance(player, enemy) >= MIN_LOCK_DISTANCE &&
          enemy.y > 20 && !current_targets.include?(enemy) && !enemy.hit
      end

      if target
        missile = {
          x: player[:x],
          y: player[:y],
          w: 10,
          h: 10,
          target: target,
          launch_time: args.state.tick_count,
          dx: 0,
          dy: 0,
          fade_start_time: -1,
          a: 200,
          hit: false,
          hit_direction: [-3, 3, -4, 4].sample
        }
        @missiles << missile
        @last_fired = state.tick_count
      end
    end

    @missiles.reject! { |missile| missile.y > SCREEN_SIZE_Y || missile.y < 0 }
    @missiles.reject! { |missile| missile.x < 0 || missile.x > SCREEN_SIZE_X }
    @missiles.reject! { |missile| missile.fade_start_time != -1 && missile.a <= 0 }

    @missiles.each do |missile|
      angle = @args.geometry.angle_to(missile, missile[:target])
      missile[:x] += speed * Math.cos(angle.to_radians)
      missile[:y] += speed * Math.sin(angle.to_radians)
      base_dx = speed * Math.cos(angle.to_radians)
      base_dy = speed * Math.sin(angle.to_radians)

      missile.dx = base_dx * state.slow_mo_x
      missile.dy = base_dy * state.slow_mo_x

      time_since_launch = args.state.tick_count - missile[:launch_time]
      sine_wave_x = 3 * Math.sin(time_since_launch * 0.1)
      sine_wave_y = 3 * Math.sin(time_since_launch * 0.15)

      if missile.hit
        missile[:x] += missile.hit_direction
        missile[:y] += speed + 1.5
      else
        missile[:x] += base_dx + sine_wave_x
        missile[:y] += base_dy + sine_wave_y
      end

      if missile.intersect_rect?(missile[:target]) && !missile.hit
        missile.target.damage(damage, args)
        missile.fade_start_time = args.state.tick_count

        Sound.play("hits/hit_10.ogg", gain: [0.05, 0.07].sample, key: :homing_missile_hit, pitch: [0.9, 1.1].sample)

        HitLabel.spawn(
          args,
          x: missile[:target].x,
          y: missile[:target].y,
          dx: missile[:target].dx,
          dy: missile[:target].dy,
          text: damage.to_s
        )

        Particles.spawn_random(
          args,
          x: missile[:target].x,
          y: missile[:target].y,
          speed: [2, 3],
          amount: [1, 3],
          size: [3, 6],
          color: missile.target.particle_color || [103, 205, 252]
        )
        missile[:target].dx = -missile.dx * 0.1
        missile[:target].dy = -missile.dy * 0.1
        missile[:target].x = missile[:target].x + 4
        missile[:target].y = missile[:target].y - 4
        missile.hit = true
      end
    end
  end

  def draw
    return unless state.power_ups.homing_missile.active
    @missiles.map do |missile|
      if missile.fade_start_time != -1
        current_tick = args.state.tick_count
        percentage = args.easing.ease(
          missile.fade_start_time,
          current_tick,
          60,
          :quad
        )
        missile.a = (1.0 - percentage) * 255
      end

      [
        {
          x: missile.x,
          y: missile.y,
          w: missile.w,
          h: missile.h,
          path: "sprites/missile.png",
          a: missile.a
        },
        {
          x: missile[:x] - 8,
          y: missile[:y] - 8,
          w: 28,
          h: 28,
          path: "sprites/glow_sprite.png",
          a: missile.a + 50
        }
      ]
    end
  end
end
