class Player
  ACCELERATION = 2.8
  FRICTION = 0.81
  MAX_SPEED = 10.0
  TILT_LERP_FACTOR = 0.1
  MAX_TILT_ANGLE = 30.0
  DASH_SPEED = 4.0
  DOUBLE_TAP_THRESHOLD = 15
  SIZE = 24
  SPRITE_SIZE = 20

  attr_gtk

  attr_accessor :ghost_sprites

  def initialize(args)
    @args = args
    @player = {
      x: SCREEN_SIZE_X / 2,
      y: SCREEN_SIZE_Y - 100,
      h: SIZE,
      w: SIZE,
      dx: 0,
      dy: 0,
      r: 255,
      g: 255,
      b: 255,
      path: "sprites/player.png",
      angle: 1,
      dash_speed: 1
      # source_x:  16,
      # source_y:  16,
      # source_w: -16,
      # source_h: -16,
    }

    state.double_tap ||= {
      direction: :left,
      dash_timer: 0,
      dashing: false,
      last_key_pressed: nil,
      current_time: 0,
      key_count: 0
    }

    @last_tap_time_left = 0
    @last_tap_time_right = 0
    @dash_timer = 0
    @dashing = false
    @dash_sprites = []
    @ghost_sprites = []
  end

  def entity
    {
      w: SIZE,
      h: SIZE,
      x: @player[:x] - 2,
      y: @player[:y] - 2
    }
  end

  def sprite
    @player
  end

  def tick
    input!

    @ghost_sprites.each do |sprite|
      if sprite.fade_time >= 0
        sprite.a -= 0.5
      end

      if sprite.a <= 0
        @ghost_sprites.delete(sprite)
      end
    end

    @dash_sprites.each do |sprite|
      if sprite.fade_time >= 0
        sprite.a -= 0.3
      end

      if sprite.a <= 0
        @dash_sprites.delete(sprite)
      end
    end
  end

  def start_dash(direction)
    @dash_direction = direction
    @dashing = true
    @dash_timer = 10

    if state.power_ups.ghost.active
      @ghost_sprites << {
        x: @player.x,
        y: @player.y,
        w: @player.w,
        h: @player.h,
        path: @player.path,
        a: 150,
        blendmode_enum: 1,
        angle: Utils.random(-10, 10),
        fade_time: 60
      }
    end
  end

  def draw
    [
      {
        x: @player.x - SPRITE_SIZE / 2,
        y: @player.y - SPRITE_SIZE / 2,
        w: SPRITE_SIZE * 2,
        h: SPRITE_SIZE * 2,
        path: "sprites/glow.png",
        a: 150
      },
      {
        **@player,
        h: SPRITE_SIZE,
        w: SPRITE_SIZE
      }
    ]
  end

  def draw_dash_sprites
    @dash_sprites + @ghost_sprites
  end

  def dash_check(direction)
    current_time = state.tick_count
    if direction == :left
      if current_time - @last_tap_time_left <= DOUBLE_TAP_THRESHOLD
        SlowMo.slow_mo!(args)
        Sound.play("left.ogg", gain: 0.15, key: :left)
        start_dash(direction)
      end
      @last_tap_time_left = current_time
    elsif direction == :right
      if current_time - @last_tap_time_right <= DOUBLE_TAP_THRESHOLD
        SlowMo.slow_mo!(args)
        Sound.play("right.ogg", gain: 0.15, key: :right)
        start_dash(direction)
      end
      @last_tap_time_right = current_time
    end
  end

  def input!
    # Boundary checks
    @player[:x] = [@player[:x], RECT[:x]].max
    @player[:x] = [@player[:x], RECT[:x] + RECT[:w] - @player[:w]].min
    @player[:y] = [@player[:y], RECT[:y]].max
    @player[:y] = [@player[:y], RECT[:y] + RECT[:h] - @player[:h]].min

    target_tilt_angle =
      if @player[:dx] > 0
        -MAX_TILT_ANGLE
      elsif @player[:dx] < 0
        MAX_TILT_ANGLE
      else
        5.0
      end

    if @dashing
      @player[:dash_speed] = DASH_SPEED
      @dash_timer -= 1
      @dashing = false if @dash_timer <= 0

      3.times do |i|
        @dash_sprites << {
          x: @player.x + i * -20,
          y: @player.y + Utils.random(-10, 10),
          w: @player.w,
          h: @player.h,
          path: @player.path,
          a: @dash_timer * 4,
          blendmode_enum: 2,
          angle: Utils.random(-90, 90),
          fade_time: 120
        }
      end

      10.times do |i|
        @dash_sprites << {
          x: @player.x + (i * 2),
          y: @player.y + 8,
          w: 32,
          h: 3,
          path: @player.path,
          a: @dash_timer * 5,
          blendmode_enum: 1,
          angle: Utils.random(-4, 4),
          fade_time: 120
        }
      end
    else
      @player[:dash_speed] = 1
    end

    if inputs.keyboard.key_down.left || inputs.controller_one.key_down.left || inputs.keyboard.key_down.a
      dash_check(:left)
    end

    if inputs.keyboard.key_down.right || inputs.controller_one.key_down.right || inputs.keyboard.key_down.d
      dash_check(:right)
    end

    if inputs.keyboard.left || inputs.controller_one.left || inputs.finger_left
      @player[:dx] -= ACCELERATION
    elsif inputs.keyboard.right || inputs.controller_one.right || inputs.finger_right
      @player[:dx] += ACCELERATION
    else
      @player[:dx] *= FRICTION
      target_tilt_angle = 1.0
    end

    @player[:angle] += (target_tilt_angle - @player[:angle]) * TILT_LERP_FACTOR

    @player[:dx] = MAX_SPEED if @player[:dx] > MAX_SPEED
    @player[:dx] = -MAX_SPEED if @player[:dx] < -MAX_SPEED
    @player[:x] += (@player[:dx] * @player[:dash_speed])
  end
end

# def dash_check(direction)
#   current_time = state.tick_count
#   if direction == :left
#     state.double_tap.last_key_pressed = :left
#     state.double_tap.current_time = current_time
#     state.double_tap.dash_timer = DOUBLE_TAP_THRESHOLD
#     state.double_tap.key_count += 1
#   end
# end

#   state.double_tap.dash_timer -= 1
# if state.double_tap.last_key_pressed

#   if state.double_tap.dash_timer > 0 && state.double_tap.key_count > 1
#     state.double_tap.dashing = true
#     puts 'dashing'
#   else
#     state.double_tap.dashing = false
#   end
#   if state.double_tap.dash_timer <= 0
#     state.double_tap.dashing = false
#     state.double_tap.dash_timer = 0
#     state.double_tap.current_time = 0
#     state.double_tap.key_count = 0
#   end
# else
# end
