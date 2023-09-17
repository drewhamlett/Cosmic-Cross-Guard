require "app/constants"
require "app/player"
require "app/particles"
require "app/trail_particles"
require "app/slow_mo"
require "app/noise"
require "app/blocks"
require "app/power_ups/rotating_orb"
require "app/power_ups/power_ups"
require "app/power_ups/side_shot"
require "app/screen_shake"
require "app/power_ups/gun"
require "app/power_ups/homing_missile"
require "app/power_ups/laser"
require "app/power_ups/pendulum"
require "app/base"
require "app/hit_label"
require "app/upgrade_bar"
require "app/enemies/enemy_small"
require "app/enemies/enemy_medium"
require "app/enemies/enemy_large"
require "app/enemies/enemy_crazy"
require "app/json"
require "app/sound"
require "app/level"

class Game
  attr_gtk

  SAVE_TIMER = 120

  def initialize(args)
    @player = Player.new(args)
    @blocks = Blocks.new
    @side_shot = SideShot.new
    @gun = Gun.new(args)
    @homing_missile = HomingMissile.new(args)
    @laser = Laser.new(args)
    @rotating_orb = RotatingOrb.new
    @pendulum = Pendulum.new
    @base = Base.new
  end

  def tick(args)
    @player.args = args
    @gun.args = args
    @homing_missile.args = args
    @laser.args = args
    @blocks.args = args
    @rotating_orb.args = args
    @pendulum.args = args
    @base.args = args

    SlowMo.defaults(args)
    PowerUps.defaults(args)

    if args.state.tick_count.zero?
      @rotating_orb.defaults
      @pendulum.defaults

      state.enable_collisions = true
      state.spawn_rate = 0.5
      state.spawn_area = 100
      state.health = 10
      state.screen_angle = 0
      state.start_screen_angle = false
      state.power_level = 1
      state.max_power_level = 100

      # audio[:bg_music] = {
      #   input: "sounds/I've Never Found My Jacket (Song Retro Game).mp3",
      #   looping: true,
      #   gain: 0.5
      # }
    end

    state.current_level ||= 1
    state.current_level_xp ||= 0
    state.next_level_xp ||= 8
    state.growth_rate ||= 1.5
    state.blocks_hit ||= 0

    state.needs_tutorial ||= false
    state.tutorial_timer ||= 60 * 15

    state.save_timer ||= SAVE_TIMER
    state.input_delay ||= 0
    state.upgrade_screen ||= false

    state.debug ||= false

    # state.spawn_rate = (1 * Level.difficulty(args)).round

    outputs[:game].transient!
    outputs[:base].transient!

    if state.tutorial_timer >= 0
      state.tutorial_timer -= 1
    else
      state.needs_tutorial = false
    end

    # Update
    @player.tick

    if state.start_screen_angle
      state.screen_angle += 0.9
    end

    if state.screen_angle >= 179.99
      state.start_screen_angle = false
    end

    if state.blocks_hit >= state.next_level_xp
      SlowMo.slow_mo!(args)
      state.power_up_left_right = PowerUps.left_right(args)
      state.current_level += 1
      state.next_level_xp = (state.growth_rate * state.next_level_xp).round
      state.current_level_xp = 0
      state.blocks_hit = 0
      state.input_delay = 50
      # state.start_screen_angle = true
      # state.spawn_rate += 1
      # state.spawn_area += 100
      Save.save!(args)
      if state.current_level > 3
        state.upgrade_screen = true
      end
    end

    # if state.power_ups.gun.active
    #   @gun.tick(player: @player.sprite, enemies: @blocks.blocks)
    # end

    if state.power_ups.homing_missile.active
      @homing_missile.tick(player: @player.sprite, enemies: @blocks.blocks)
    end

    if state.power_ups.pendulum.active
      @pendulum.tick(player: @player.sprite)
    end

    # if state.power_ups.laser.active
    #   @laser.tick(player: @player.sprite, enemies: @blocks.blocks)
    # end

    if state.power_ups.side_shot.active
      @side_shot.tick(args, player: @player.sprite)
    end

    if state.power_ups.rotating_orb.active
      @rotating_orb.tick(player: @player.entity)
    end

    Particles.tick(args, player: @player.sprite) if args.state.post_processing
    TrailParticles.tick(args, player: @player.sprite) if args.state.post_processing
    @blocks.tick(args)
    ScreenShake.tick(args)
    SlowMo.tick(args)
    @base.tick
    HitLabel.tick(args) if args.state.post_processing
    UpgradeBar.tick(args)

    if state.enable_collisions
      @blocks.collision(
        args,
        player: @player,
        side_shot: @side_shot,
        gun: @gun
      )
    end

    # args.render_target(:game).sprites << @laser.draw(player: @player.sprite) if state.power_ups.laser.active
    # Draw
    outputs.background_color = [0, 0, 0]
    args.render_target(:game).background_color = [58, 58, 75]
    args.render_target(:base).sprites << @base.draw

    args.render_target(:game).sprites << [
      @player.draw_dash_sprites,
      @blocks.draw(args),
      Particles.draw(args),
      TrailParticles.draw(args),
      @player.draw,
      @homing_missile.draw,
      @homing_missile.draw,
      @rotating_orb.draw,
      @side_shot.draw(args),
      @pendulum.draw(player: @player.sprite)
    ]

    args.render_target(:game).labels << HitLabel.draw(args) if args.state.post_processing

    args.render_target(:base).solids << UpgradeBar.draw(args)

    args.render_target(:game).sprites << @blocks.blocks.map do |block|
      next if block.max_health == 1
      next if block.health <= 0
      health_bar_width = (block.health / block.max_health) * block.w

      [
        {
          x: block.x,
          y: block.y - 10,
          w: block.w,
          path: "sprites/block_1_hit.png",
          h: 4,
          font: FONT,
          a: 50,
          r: 255,
          g: 255,
          b: 255
        },
        {
          x: block.x,
          y: block.y - 10,
          w: health_bar_width,
          path: "sprites/block_1_hit.png",
          h: 4,
          font: FONT,
          a: 200,
          r: block.particle_color[0] - 20,
          g: block.particle_color[1] - 20,
          b: block.particle_color[2] - 20
        }
      ]
    end

    if args.state.debug
      args.render_target(:game).borders << {
        **@player.entity,
        r: 255,
        g: 0,
        b: 0
      }
    end

    if state.shake_timer > 0
      shake_x = rand(2 * state.shake_intensity + 1) - state.shake_intensity
      shake_y = rand(2 * state.shake_intensity + 1) - state.shake_intensity
      state.shake_timer -= 1
    else
      shake_x = 0
      shake_y = 0
    end

    outputs.sprites << [
      {
        x: shake_x,
        y: shake_y,
        w: SCREEN_SIZE_X,
        h: SCREEN_SIZE_Y,
        path: :game,
        angle: state.screen_angle
      },
      {
        x: 0,
        y: 0,
        w: SCREEN_SIZE_X,
        h: SCREEN_SIZE_Y,
        path: :base,
        angle: state.screen_angle
      }
    ]

    Noise.draw(args)

    outputs.labels << {x: SCREEN_SIZE_X - 30, y: 0 + 25, text: "#{state.blocks_hit}/#{state.next_level_xp}", r: 170, g: 170, b: 170, font: FONT, size_enum: 1, alignment_enum: 1}
    outputs.labels << {x: 10, y: 720 - 10, text: "level: #{state.current_level}", r: 255, g: 255, b: 255, font: FONT, size_enum: 3}
    outputs.labels << {x: 10, y: 720 - 30, text: "base health: #{state.health} ", r: 255, g: 255, b: 255, font: FONT, size_enum: 3}

    if state.needs_tutorial
      outputs.labels << {x: SCREEN_SIZE_X / 2 - 300, y: SCREEN_SIZE_Y / 1.8 + 150, text: "Movement", r: 255, g: 255, b: 255, font: FONT, size_enum: 6, alignment_enum: 1}
      outputs.labels << {x: SCREEN_SIZE_X / 2 - 300, y: SCREEN_SIZE_Y / 1.8, text: "LEFT / RIGHT", r: 255, g: 255, b: 255, font: FONT, size_enum: 4, alignment_enum: 1}
      outputs.labels << {x: SCREEN_SIZE_X / 2 - 300, y: SCREEN_SIZE_Y / 1.8 - 50, text: "A / D", r: 255, g: 255, b: 255, font: FONT, size_enum: 4, alignment_enum: 1}
      outputs.labels << {x: SCREEN_SIZE_X / 2 - 300, y: SCREEN_SIZE_Y / 1.8 - 100, text: "D-PAD LEFT / D-PAD RIGHT", r: 255, g: 255, b: 255, font: FONT, size_enum: 4, alignment_enum: 1}

      outputs.labels << {x: SCREEN_SIZE_X / 2 - 300, y: SCREEN_SIZE_Y / 1.8 - 150, text: "Space: Pause / Settings / Credits", r: 255, g: 255, b: 255, font: FONT, size_enum: 4, alignment_enum: 1}

      outputs.labels << {x: SCREEN_SIZE_X / 2 + 300, y: SCREEN_SIZE_Y / 1.8 + 150, text: "Dash", r: 255, g: 255, b: 255, font: FONT, size_enum: 6, alignment_enum: 1}

      outputs.labels << {x: SCREEN_SIZE_X / 2 + 300, y: SCREEN_SIZE_Y / 1.8, text: "Double tap LEFT / RIGHT", r: 255, g: 255, b: 255, font: FONT, size_enum: 4, alignment_enum: 1}
      outputs.labels << {x: SCREEN_SIZE_X / 2 + 300, y: SCREEN_SIZE_Y / 1.8 - 50, text: "Double tap A / D", r: 255, g: 255, b: 255, font: FONT, size_enum: 4, alignment_enum: 1}
      outputs.labels << {x: SCREEN_SIZE_X / 2 + 300, y: SCREEN_SIZE_Y / 1.8 - 100, text: "Double tap D-PAD LEFT / D-PAD RIGHT", r: 255, g: 255, b: 255, font: FONT, size_enum: 4, alignment_enum: 1}

      if state.tutorial_timer <= 60 * 5
        outputs.labels << {x: SCREEN_SIZE_X / 2, y: SCREEN_SIZE_Y - 30, text: "Sending you some blocks! Get ready!", r: 255, g: 255, b: 255, font: FONT, size_enum: 7, alignment_enum: 1}
      end

      outputs.labels << {x: SCREEN_SIZE_X / 2, y: 0 + 100, text: "Stop the blocks from getting passed you!", r: 255, g: 255, b: 255, font: FONT, size_enum: 4, alignment_enum: 1}
    end

    if state.debug
      outputs.labels << {x: 10, y: 35, text: "framerate: #{gtk.current_framerate.round}", r: 255, g: 255, b: 255, font: FONT, size_enum: 3}
    end

    args.outputs.debug << args.gtk.framerate_diagnostics_primitives
  end
end
