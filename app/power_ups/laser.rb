# frozen_string_literal: true

class Laser
  MIN_LOCK_DISTANCE = 300
  NUM_SEGMENTS = 20
  JITTER_AMOUNT = 15
  LASER_WIDTH = 16

  DAMAGE_SCALE_FACTOR = 1.1

  attr_accessor :last_fired
  attr_gtk

  def initialize(args)
    @args = args
    @last_fired = 0
    @target = nil
    @lerp_factor = 0.0
    @attached = false
    @fire_duration = 0
    state.laser ||= state.new_entity_strict :laser do |l|
      l.speed = 20.0
      l.last_fired = 0
      l.target = nil
    end
  end

  def fire_interval
    case state.power_ups.laser.level
    when 1
      60 * 2.5
    when 2
      60 * 2
    when 3
      60
    when 4
      30
    else
      20
    end
  end

  def damage
    (1 * DAMAGE_SCALE_FACTOR**state.power_ups.laser.level).round
  end

  def tick(player:, enemies:)
    if state.tick_count >= @last_fired + fire_interval
      @target = enemies.faster_find do |enemy|
        next if enemy.hit
        geometry.distance(player, enemy) >= MIN_LOCK_DISTANCE &&
          enemy.y > 50
      end

      if @target
        @last_fired = state.tick_count
        @lerp_factor = 0.0
        @attached = false
      end
    end

    if @lerp_factor < 1.0 && @target && !@attached
      @lerp_factor += 1.0 / state.laser.speed
      @lerp_factor = [@lerp_factor, 1.0].min
      @attached = true if @lerp_factor >= 1.0
    end

    if @attached
      if @target
        block = @target

        block.damage(damage, args) do
          ScreenShake.shake(args, t: 5, i: 5)

          block_dx = 10 * 0.5

          Sound.play("ESM_GW_bass_one_shot_hit_layer_sweetener_metal_crunchy_shuffle_7_laser_zap.ogg", key: :laser_hit, gain: 0.1)

          Particles.spawn_random(
            args,
            x: block.x + 5,
            y: block.y + 5,
            speed: [block_dx.abs, block_dx.abs + 1],
            amount: [1, 2],
            life: [10, 30],
            color: block.particle_color || [103, 205, 252],
            acceleration_x: [-0.1, 0.1],
            acceleration_y: [-0.1, 0.1],
            opacity: [10, 250],
            size: [2, 8]
          )

          block.dx = 0
          block.dy = 0
          HitLabel.spawn(args, x: block.x, y: block.y, dx: block.dx, dy: block.dy, text: damage.to_s)
          Particles.spawn_random(args, amount: [1, 2], x: @target.x, y: @target.y, size: [5, 10])
          block.dx = Utils.random(-25, 25) * 0.05
          block.dy = 2 * 0.05
        end

        if state.power_ups.laser.level < 5
          @last_fired = state.tick_count
          @target = nil
        else
          @last_fired = -1
        end
      end

    end
  end

  def draw(player:)
    return if @target.nil?

    target = @target
    x1, y1 = player[:x], player[:y]
    x2, y2 = target.x + 10, target.y + 5
    dx = (x2 - x1) / NUM_SEGMENTS.to_f
    dy = (y2 - y1) / NUM_SEGMENTS.to_f
    prev_x, prev_y = x1, y1

    # Particles.spawn(
    #   @args,
    #   amount: 1,
    #   x: x2 - Utils.random(-5, 5),
    #   y: y2 - Utils.random(-5, 5),
    #   speed: 1,
    #   life: 5
    # )

    time_since_lock = state.tick_count - @last_fired

    NUM_SEGMENTS.map do |i|
      if !@attached
        segment_end_x = x1 + dx * (i + 1) * @lerp_factor
        segment_end_y = y1 + dy * (i + 1) * @lerp_factor
      else
        segment_end_x = x1 + dx * (i + 1)
        segment_end_y = y1 + dy * (i + 1)
      end

      sine_wave_x = JITTER_AMOUNT * Math.sin(time_since_lock * 0.5 + i * 0.5)
      sine_wave_y = JITTER_AMOUNT * Math.sin(time_since_lock * 0.15 + i * 0.5)

      segment_end_x += sine_wave_x
      segment_end_y += sine_wave_y

      laser_segment = {
        x: prev_x,
        y: prev_y,
        w: Utils.random(2, LASER_WIDTH),
        h: Utils.random(2, LASER_WIDTH),
        path: "sprites/laser_segment_#{[1, 2, 3, 4, 5].sample}.png",
        # path: "sprites/laser_segment.png",
        a: Utils.random(200, 255),
        angle: Utils.random(0, 360)
      }

      prev_x, prev_y = segment_end_x, segment_end_y
      laser_segment
    end
  end
end

# class Laser
#   NUM_SEGMENTS = 50
#   JITTER_AMOUNT = 10

#   attr_gtk

#   def initialize(args)
#     @args = args
#   end

#   def tick
#   end

#   def draw(player:, target:)
#     x1, y1 = player[:x], player[:y]
#     x2, y2 = target[:x], target[:y]
#     dx = (x2 - x1) / NUM_SEGMENTS.to_f
#     dy = (y2 - y1) / NUM_SEGMENTS.to_f
#     prev_x, prev_y = x1, y1

#     NUM_SEGMENTS.times do |i|
#       segment_end_x = x1 + dx * (i + 1)
#       segment_end_y = y1 + dy * (i + 1)

#       jitter_x = (-JITTER_AMOUNT..JITTER_AMOUNT).to_a.sample
#       jitter_y = (-JITTER_AMOUNT..JITTER_AMOUNT).to_a.sample

#       p jitter_x

#       segment_end_x += jitter_x
#       segment_end_y += jitter_y

#       @args.outputs.lines << [prev_x, prev_y, segment_end_x, segment_end_y, 255, 255, 255, 255]

#       prev_x, prev_y = segment_end_x, segment_end_y
#     end
#   end
# end
