class Enemy
  attr_sprite

  attr_accessor :x, :y, :w, :h, :dx, :dy, :health, :color, :hit, :speed, :fade_start_time, :flash_time, :a, :last_collision_tick

  attr_reader :destroyed, :max_health

  def initialize(x:, y:, w:, h:, speed:, flash_time: 10, health: 1)
    @x = x
    @y = y
    @w = w
    @h = h
    @dx = 0
    @dy = 0
    @hit = false
    @health = health
    @max_health = health
    @speed = speed
    @fade_start_time = -1
    @flash_time = flash_time
    @initial_flash_time = flash_time
    @angle = Utils.random(0, 350)
    @a = 230
    @tile_x = 0 + (0 * 38)
    @tile_y = 0
    @tile_w = 40
    @tile_h = 40
    @flash = false
    @angle_speed = Utils.random(1, 4)
    @destroyed = false
    @last_collision_tick = 0
  end

  def hit?
    @hit
  end

  def destroy!
    @destroyed = true
  end

  def blendmode_enum
    (@flash && @flash_time > 0) ? 2 : 1
  end

  def hit_sprite
    "sprites/warp.png"
  end

  def fade_away_sprite
    @path
  end

  def path
    if @hit && !@flash
      fade_away_sprite
    elsif @flash && @flash_time > 0
      hit_sprite
    else
      @path
    end
  end

  # def path
  #   if @hit && @flash_time > 0
  #     "sprites/block_1_hit.png"
  #   else
  #     @hit ? @random_hit : @path
  #   end
  # end

  def angle
    if @hit && @flash_time > 0
      (@angle > 359) ? @angle + 10 : @angle - 10
    else
      @angle
    end
  end

  def damage(amount, args, &block)
    current_tick = args.state.tick_count
    cooldown_ticks = 15

    @last_collision_tick ||= 0  # Initialize if not already set

    # puts "Current tick: #{current_tick}, Last collision tick: #{@last_collision_tick}, Difference: #{current_tick - @last_collision_tick}"

    return if current_tick - @last_collision_tick < cooldown_ticks

    yield block if block

    @health -= amount
    @flash = true
    @last_collision_tick = current_tick

    if @health <= 0
      @hit = true
      @fade_start_time = args.state.tick_count
      args.state.blocks_hit += 1

      if args.state.current_level >= 10
        args.state.blocks_hit += 1
      elsif args.state.current_level >= 15
        args.state.blocks_hit += 5
      end
    end
  end

  def tick(args)
    @angle += (@angle_speed * args.state.slow_mo_x)
    if @flash && @flash_time > 0
      @flash_time -= 1
    else
      @flash = false
      @flash_time = @initial_flash_time
    end

    if @hit
      @x -= @dx * 2
      @y -= @dy * 2
      @angle += 5
      # block.flash_time -= 1 if block.flash_time > 0
    else
      @y += @speed * args.state.slow_mo_x
    end
  end

  def draw
  end

  def to_s
    "#{self.class.name} - x: #{@x}, y: #{@y}, w: #{@w}, h: #{@h}, dx: #{@dx}, dy: #{@dy}"
  end
end
