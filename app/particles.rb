module Particles
  GRAVITY = -0.01

  def self.tick(args, player:)
    args.state.particles ||= []
    args.state.particles.reject! { |particle| particle[:life] <= 0 }

    args.state.particles.each do |particle|
      # particle[:dx] += particle[:acceleration_x]
      # particle[:dy] += particle[:acceleration_y]

      particle[:x] += particle[:dx] * 0.5
      particle[:y] += particle[:dy] * 0.5
      particle[:life] -= 0.4
      # particle[:opacity] = particle[:a]
      particle[:size] = particle[:size] # Random size between 0 and 10
      particle[:angle] = rand * 360 # Random rotation between 0 and 360 degrees
      particle[:r] = particle[:r]
      particle[:g] = particle[:g]
      particle[:b] = particle[:b]

      particle[:opacity] = (particle[:life] / particle[:initial_life].to_f) * particle[:a]  # Calculate opacity based on remaining life

      # particle[:size] += particle[:grow_factor]
    end
  end

  def self.spawn_random(
    args,
    amount: [30, 30],
    x: nil,
    y: nil,
    speed: [5, 5],
    life: [30, 30],
    size: [-2, 2],
    color: nil,
    acceleration_x: [0, 0],
    acceleration_y: [0, 0],
    grow_factor: [0, 0],
    opacity: [30, 255]
  )

    color = [255, 255, 255] if color.nil?
    life_min = life.first
    life_max = life.second

    unless args.state.post_processing
      life_min = 5
      life_max = (life_max > 20) ? 20 : life_max
      amount = [5, 5]
    end

    Utils.random(amount.first, amount.second).times do |i|
      life = Utils.random(life_min, life_max)

      args.state.particles << {
        x: x,
        y: y,
        dx: [-Utils.random(speed.first, speed.second), Utils.random(speed.first, speed.second)].sample,
        dy: [-Utils.random(speed.first, speed.second), Utils.random(speed.first, speed.second)].sample,
        life: life,
        size: Utils.random(size.first, size.second),
        r: color[0],
        g: color[1],
        b: color[2],
        a: Utils.random(opacity.first, opacity.second),
        grow_factor: Utils.random(grow_factor.first, grow_factor.second),
        acceleration_x: Utils.random(acceleration_x.first, acceleration_x.second),
        acceleration_y: Utils.random(acceleration_y.first, acceleration_y.second),
        initial_life: life
      }
    end
  end

  def self.spawn(args, amount: nil, x: nil, y: nil, speed: 5, life: 30, size: nil, color: nil, acceleration_x: 0, acceleration_y: 0, grow_factor: 0)
    size = rand * 7 if size.nil?

    color = [255, 255, 255] if color.nil?

    amount.times do |i|
      args.state.particles << {
        x: x,
        y: y,
        dx: Utils.random(-speed, speed), # Random velocity between -1 and 1
        dy: Utils.random(-speed, speed), # Random velocity between -1 and 1
        life: Utils.random(life / 2, life * 2), # Particle life in frames
        size: Utils.random(size - 2, size + 2),
        r: color[0],
        g: color[1],
        b: color[2],
        a: Utils.random(10, 255),
        acceleration_x: acceleration_x,
        acceleration_y: acceleration_y,
        grow_factor: Utils.random(grow_factor - 0.5, grow_factor + 0.5),
        initial_life: life
      }
    end
  end

  def self.draw(args)
    args.state.particles.map do |particle|
      {
        x: particle[:x],
        y: particle[:y],
        w: particle[:size],
        h: particle[:size],
        angle: particle[:angle],
        a: particle[:opacity],
        r: particle[:r],
        g: particle[:g],
        b: particle[:b]
      }
    end
  end
end
