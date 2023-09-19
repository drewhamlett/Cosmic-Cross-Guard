require "app/particles"

class Blocks
  attr_accessor :blocks
  attr_accessor :block_speed

  attr_gtk

  def initialize
    @blocks = []
    @block_speed = 2
  end

  def spawn_rate
    state.spawn_rate
  end

  def size
    @blocks.size
  end

  def tick(args)
    spawn_blocks(args)

    block_index = 0
    while block_index < @blocks.size
      block = @blocks[block_index]
      block.tick(args)

      if block.y > SCREEN_SIZE_Y && !block.hit && !block.destroyed

        Sound.play("GLTCH_SFX_HologramScreen70.ogg", key: :base_hit, gain: 0.5)
        state.health -= 1
        block.destroy!
      end

      if block.y > SCREEN_SIZE_Y + 10 || (block.fade_start_time != -1 && block.a <= 0)
        @blocks.delete_at(block_index)
      else
        block_index += 1
      end
    end
  end

  def draw(args)
    all_blocks = @blocks
    processed_blocks = []
    block_index = 0
    while block_index < @blocks.size
      block = @blocks[block_index]
      if block.fade_start_time != -1
        current_tick = args.state.tick_count
        percentage = args.easing.ease(
          block.fade_start_time,
          current_tick,
          120,
          :quad
        )
        block.a = (1.0 - percentage) * 255
      end
      if state.post_processing
        processed_blocks << {
          x: block.x - block.w / 1,
          y: block.y - block.h / 1,
          w: block.w * 3,
          h: block.h * 3,
          r: block.particle_color[0],
          g: block.particle_color[1],
          b: block.particle_color[2],
          path: "sprites/glow_pixel.png",
          a: block.a - 140,
          angle: block.angle,
          blendmode_enum: (block.hit && block.flash_time > 0) ? 2 : 1
        }
      end
      block_index += 1
    end

    [processed_blocks, all_blocks]
  end

  def handle_collision(args, block, bullet, multiplier)
    args.state.blocks_hit += 1
    block.hit = true
    block.fade_start_time = args.state.tick_count
    ScreenShake.shake(args, t: 5, i: 5)
    Particles.spawn(args, x: block.x + 5, y: block.y + 5, speed: 5, amount: 5, life: Utils.random(15, 30))
    block.dx = bullet[:dx] * multiplier
    block.dy = bullet[:dy] * multiplier
  end

  # @param [Hash] args
  # @param [Enemy] block
  # @param [Player] player
  def handle_player_collision(args, block, player)
    block.damage(1, args) do
      ScreenShake.shake(args, t: 5, i: 5)
      sound = ["hits/hit_4.ogg", "hits/hit_5.ogg"].sample
      Sound.play(sound, gain: 0.1, key: :player_hit)

      block_dx = -player.sprite[:dx] * 0.5

      Particles.spawn_random(
        args,
        x: block.x + 5,
        y: block.y + 5,
        speed: [block_dx.abs, block_dx.abs + 1],
        amount: [2, 5],
        life: [30, 40],
        color: block.particle_color || [103, 205, 252],
        acceleration_x: [-0.1, 0.1],
        acceleration_y: [-0.1, 0.1],
        opacity: [10, 250],
        size: [2, 8]
      )

      block.dx = block_dx
      block.dy = block.speed * 0.5
      HitLabel.spawn(args, x: block.x, y: block.y, dx: block.dx, dy: block.dy)
    end
  end

  def handle_orb_collision(args, block, rotating_orb)
    block.damage(rotating_orb.damage, args) do
      Sound.play("hits/hit_8.ogg", gain: 0.15, key: :orb_hit)
      ScreenShake.shake(args, t: 5, i: 10)
      HitLabel.spawn(
        args,
        x: block.x,
        y: block.y,
        dx: Utils.random(-5, 5),
        dy: Utils.random(-5, 5),
        text: rotating_orb.damage.to_s,
        critical: true
      )

      Particles.spawn_random(
        args,
        x: block.x + 5,
        y: block.y + 5,
        speed: [2, 8],
        amount: [2, 8],
        life: [10, 30],
        color: block.particle_color || [103, 205, 252],
        acceleration_x: [-0.1, 0.1],
        acceleration_y: [-0.1, 0.1],
        opacity: [200, 255],
        size: [2, 8]
      )
      block.dx = -args.state.orb[:dx] * 0.5
      block.dy = -args.state.orb[:dy] * 0.5
    end
  end

  def base_collision
    block_index = 0
    while block_index < @blocks.size
      block = @blocks[block_index]
      unless block.hit || block.y < 650
        base_blocks = args.geometry.find_all_intersect_rect(block, state.base).filter { |b| !b.hit }

        unless base_blocks.empty?
          base = base_blocks.first

          base.hit = true
          block.damage(10, args)

          block.dx = Utils.random(-1, 1)
          block.dy = block.speed * 0.3
          HitLabel.spawn(args, x: block.x, y: block.y, dx: block.dx, dy: block.dy, text: "10", critical: true)

          Particles.spawn_random(
            args,
            x: block.x,
            y: block.y + 10,
            speed: [2, 2],
            amount: [2, 2],
            life: [10, 20],
            color: block.particle_color || [103, 205, 252],
            opacity: [200, 255],
            size: [2, 8]
          )
        end
      end
      block_index += 1
    end
  end

  def side_shot_collision(side_shot:)
    side_shot.bullets.each do |bullet|
      collisions = args.geometry.find_all_intersect_rect(
        bullet,
        @blocks
      )
      collisions.each do |block|
        next unless block.fade_start_time == -1 && block.hit == false
        damage = side_shot.damage(args)

        block.damage(damage, args) do
          side_shot.bullets.delete(bullet)
          block.dx = -bullet.dx * 0.5
          Sound.play("hits/hit_1.ogg", gain: 0.15, key: :player_side_shot_hit)
          HitLabel.spawn(
            args,
            x: block.x,
            y: block.y,
            dx: Utils.random(-5, 5),
            dy: Utils.random(-5, 5),
            text: damage.to_s,
            critical: true
          )
        end
      end
    end
  end

  def collision(args, player:, side_shot:, gun:, rotating_orb:)
    base_collision

    player_blocks = args.geometry.find_all_intersect_rect(
      player.entity,
      @blocks
    )

    player_blocks.each do |block|
      next unless block.fade_start_time == -1 && block.hit == false
      handle_player_collision(args, block, player)
    end

    if state.power_ups.side_shot.active
      side_shot_collision(side_shot: side_shot)
    end

    player.ghost_sprites.each do |ghost_sprite|
      player_ghost_blocks = args.geometry.find_all_intersect_rect(
        ghost_sprite,
        @blocks
      )
      player_ghost_blocks.each do |block|
        next unless block.fade_start_time == -1 && block.hit == false
        block.damage(1, args) do
          block.dy += 1
          Sound.play("hits/hit_1.ogg", gain: 0.15, key: :player_ghost_hit)
        end
      end
    end

    if state.power_ups.rotating_orb.active
      orb_blocks = args.geometry.find_all_intersect_rect(
        args.state.orb,
        @blocks
      )

      orb_blocks.each do |block|
        next unless block.fade_start_time == -1 && block.hit == false
        handle_orb_collision(args, block, rotating_orb)
      end
    end
  end

  def spawn_at(x:, y: -40, speed: 1, clazz: EnemySmall, health: 1)
    @blocks << clazz.new(
      x: x,
      y: y,
      speed: Utils.random(speed, speed),
      health: health
    )
  end

  def every(seconds, &block)
    if (state.tick_count % seconds).zero?
      yield block
    end
  end

  def spawn_x(size = 200)
    Utils.random((1280 / 2) - (size / 2), (1280 / 2) + (size / 2))
  end

  def difficulty_modifier
    current_level = args.state.current_level
    if current_level > 8
      (current_level - 8) * 0.1 # Increase difficulty by 10% for each level above 8
    else
      0
    end
  end

  def scale_health
    base_health = 1
    growth_rate = 0.05  # 10 additional health points per level
    current_level = state.current_level

    health = base_health + (growth_rate * current_level)
    health.floor
  end

  def spawn_blocks(args)
    # size = args.state.spawn_area

    return if args.state.needs_tutorial

    current_level = args.state.current_level

    if current_level == 1
      every 2.seconds do
        size = 300
        spawn_at(x: spawn_x(size), speed: 2.5, clazz: EnemySmall)
      end
    end

    if current_level == 2
      state.next_level_xp = 3
      state.health = 10
      state.base.each do |base|
        base.hit = false
      end
      size = 380
      output = [
        "To do more damage or hit the block twice:",
        "Dash one direction then opposite direction",
        "Blocks will slow down temporarily."
      ]

      output.each_with_index do |text, index|
        outputs.labels << {
          x: SCREEN_SIZE_X / 2 - 350,
          y: SCREEN_SIZE_Y / 1.8 - (index * 25),
          text: text, r: 255, g: 255, b: 255,
          font: FONT, size_enum: 4, alignment_enum: 1
        }
      end
      every 5.seconds do
        spawn_at(x: spawn_x(size), speed: 0.8, clazz: EnemyLarge, health: 2)
      end
    end

    if current_level == 3
      size = 400
      output = [
        "Upgrades will come soon!",
        "Progress towards next level is shown on the right",
        "Don't let the base health reach 0!"
      ]

      output.each_with_index do |text, index|
        outputs.labels << {
          x: SCREEN_SIZE_X / 2 - 350,
          y: SCREEN_SIZE_Y / 1.8 - (index * 25),
          text: text, r: 255, g: 255, b: 255,
          font: FONT, size_enum: 4, alignment_enum: 1
        }
      end
      every 2.seconds do
        spawn_at(x: spawn_x(size), speed: 2, clazz: EnemySmall)
      end
      every 4.seconds do
        spawn_at(x: spawn_x(size), speed: 1, clazz: EnemyLarge, health: 2)
      end
    end

    if current_level == 4
      size = 400
      every 2.seconds do
        spawn_at(x: spawn_x(size), speed: 1, clazz: EnemySmall, health: 2)
      end
    end

    if current_level == 5
      size = 500
      every 1.seconds do
        spawn_at(x: spawn_x(size), speed: 1, clazz: EnemySmall, health: 2)
        spawn_at(x: spawn_x(size), speed: 1, clazz: EnemyLarge, health: 2)
      end
    end

    if current_level == 6
      size = 250
      every 2.seconds do
        spawn_at(x: spawn_x(size), speed: 2, clazz: EnemySmall, health: 2)
      end

      every 3.seconds do
        spawn_at(x: spawn_x(size), speed: 0.8, clazz: EnemyLarge, health: 2)
      end

      every 2.seconds do
        spawn_at(x: spawn_x(size), speed: 0.5, clazz: EnemyMedium, health: 3)
      end
    end

    if current_level == 7
      spawn_in_circle unless args.state.spawned_in_circle_level_7

      args.state.spawned_in_circle_level_7 = true

      every 8.seconds do
        spawn_in_circle(radius: 100, num_enemies: 20)
      end
    end

    if current_level == 8
      size = 350
      spawn_in_circle(radius: 350, num_enemies: 35) unless args.state.spawned_in_circle_level_8

      args.state.spawned_in_circle_level_8 = true

      every 3.seconds do
        spawn_at(x: spawn_x(size), speed: 1, clazz: EnemyMedium, health: 3)
      end
    end

    state.level_start_time ||= 0

    seconds = 15
    if current_level > 8 && current_level <= 500
      if args.state.tick_count - state.level_start_time >= seconds * 60 # 30 seconds * 60 frames per second
        args.state.current_level += 1
        state.level_start_time = args.state.tick_count
      end

      # spawn_rate = (2 * (state.spawn_scale_factor**current_level) * 60.0)

      upper_limit = 60.0
      floor_limit = 10.0
      decay_rate = 0.001 # Tune this to make the rate reduce faster or slower

      rate = upper_limit - (upper_limit - floor_limit) * Math.exp(-decay_rate * current_level)

      spawn_rate = rate.round

      modifier = difficulty_modifier
      size = 300 + (70 * modifier)

      max_speed = 5
      speed = Utils.random(1, max_speed) * (1 * modifier)
      if speed > max_speed
        speed = max_speed
      end

      every 4.seconds do
        spawn_at(
          x: spawn_x(size),
          speed: 1,
          clazz: EnemyCrazy,
          health: 2
        )
      end

      every 2.seconds do
        spawn_at(
          x: [1000, 200].sample,
          speed: 1,
          clazz: EnemyLarge,
          health: 4
        )
      end

      every spawn_rate do
        spawn_at(
          x: spawn_x(size),
          speed: speed,
          clazz: EnemySmall,
          health: scale_health
        )
      end

      every 3.seconds do
        spawn_at(
          x: spawn_x(size),
          speed: 2,
          clazz: EnemyMedium,
          health: 2 * (1 + modifier)
        )
      end

    end

    # if current_level > 12 && current_level < 24
    #   modifier = difficulty_modifier
    #   size = 300 + (100 * modifier)

    #   max_speed = 3
    #   speed = Utils.random(1, max_speed) * (1 * modifier)
    #   if speed > max_speed
    #     speed = max_speed
    #   end

    #   every 1.seconds / 2 do
    #     spawn_at(
    #       x: spawn_x(size),
    #       speed: speed,
    #       clazz: EnemySmall,
    #       health: 2 * (1 + modifier)
    #     )
    #   end
    # end

    # if (args.tick_count % ((60 / spawn_rate) * 5)).zero?
    #   spawn_x = Utils.random((1280 / 2) - (size / 2), (1280 / 2) + (size / 2))
    #   @blocks << EnemyLarge.new(
    #     x: spawn_x,
    #     y: -40,
    #     w: 38,
    #     h: 39,
    #     speed: Utils.random(1, 1)
    #   )

    #   @blocks << EnemyCrazy.new(
    #     x: spawn_x - Utils.random(-200, 200),
    #     y: -40,
    #     w: 24,
    #     h: 24,
    #     speed: Utils.random(2, 2)
    #   )

    #   @blocks << EnemyMedium.new(
    #     x: spawn_x + Utils.random(-200, 200),
    #     y: -40,
    #     w: 42,
    #     h: 42,
    #     speed: Utils.random(2, 3)
    #   )
    # end

    # if (args.tick_count % (60 / 1)).zero?
    #   spawn_x = Utils.random((1280 / 2) - (size / 2), (1280 / 2) + (size / 2))

    #   base_speed = 1

    #   case args.state.current_level
    #   when 1
    #     # if args.state.blocks_hit < 4
    #     #   spawn_at(x: spawn_x, clazz: EnemySmall)
    #     # end

    #     if args.state.blocks_hit < 3 && !args.state.block_circle_spawn
    #       args.state.block_circle_spawn ||= true
    #       num_enemies = 15
    #       radius = 100
    #       num_enemies.times do |i|
    #         angle = 2 * Math::PI * i / num_enemies
    #         x = spawn_x + radius * Math.cos(angle)
    #         y = -400 + radius * Math.sin(angle)

    #         # Create new enemy and add it to @blocks or whatever data structure you use
    #         @blocks << EnemySmall.new(x: x, y: y, speed: 1.5)
    #       end
    #     end
    #   when 2
    #   else
    #     puts "hello"
    #   end

    # if args.state.current_level == 1 && args.state.blocks_hit < 3
    #   @blocks << EnemySmall.new(
    #     x: SCREEN_SIZE_X / 2,
    #     y: -40,
    #     w: 32,
    #     h: 32,
    #     speed: Utils.random(2, 2)
    #   )
    # elsif args.state.blocks_hit < 10
    #   @blocks << EnemySmall.new(
    #     x: SCREEN_SIZE_X / 2 - 100,
    #     y: -20,
    #     w: 32,
    #     h: 32,
    #     speed: Utils.random(1.5, 1.5)
    #   )
    #   @blocks << EnemySmall.new(
    #     x: SCREEN_SIZE_X / 2,
    #     y: -40,
    #     w: 32,
    #     h: 32,
    #     speed: Utils.random(1.5, 1.5)
    #   )
    # elsif @blocks << EnemySmall.new(
    #   x: SCREEN_SIZE_X / 2 - 200,
    #   y: -20,
    #   w: 32,
    #   h: 32,
    #   speed: Utils.random(2, 2)
    # )
    #   @blocks << EnemySmall.new(
    #     x: SCREEN_SIZE_X / 2 + 200,
    #     y: -40,
    #     w: 32,
    #     h: 32,
    #     speed: Utils.random(2, 2)
    #   )
    # end

    # end
  end

  def spawn_in_circle(num_enemies: 15, radius: 200)
    spawn_x = 640 # center of the screen
    spawn_y = -500 # center of the screen
    num_enemies.times do |i|
      angle = 2 * Math::PI * i / num_enemies
      x = spawn_x + radius * Math.cos(angle)
      y = spawn_y + radius * Math.sin(angle)
      spawn_at(x: x, y: y, speed: 1.5, clazz: EnemySmall, health: 1)
    end
  end
end
