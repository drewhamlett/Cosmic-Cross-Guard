module TrailParticles
  OPACITY = 30

  def self.tick(args, player:)
    args.state.trail_particles ||= []
    args.state.trail_particles.reject! { |particle| particle[:life] <= 0 }

    args.state.trail_particles << {
      x: player[:x] + 5,
      y: player[:y] + 5,
      dx: Utils.random(-2, 2), # Random velocity between -1 and 1
      dy: Utils.random(-2, 2), # Random velocity between -1 and 1
      life: Utils.random(1, 20),
      size: Utils.random(2, 8),
      opacity: Utils.random(OPACITY, OPACITY + 100)
    }

    # args.state.trail_particles << {
    #   x: player[:x] + 4,
    #   y: player[:y] + 5,
    #   dx: Utils.random(-0.5, 1), # Random velocity between -1 and 1
    #   dy: Utils.random(1, 2), # Random velocity between -1 and 1
    #   life: Utils.random(10, 30), # Particle life in frames,
    #   size: Utils.random(2, 10),
    #   opacity: Utils.random(50, 200)
    # }

    args.state.trail_particles.each do |particle|
      particle[:x] += particle[:dx]
      particle[:y] += particle[:dy]
      particle[:life] -= 1.2
      particle[:opacity] = particle[:opacity] # Random opacity between .5 and 1
      particle[:size] = particle[:size] # Random size between 0 and 10
      particle[:angle] = Utils.random(1, 350) # Random rotation between 0 and 360 degrees
    end
  end

  def self.draw(args)
    args.state.trail_particles.map do |particle|
      {
        x: particle[:x],
        y: particle[:y],
        w: particle[:size],
        h: particle[:size],
        angle: particle[:angle],
        a: particle[:opacity],
        r: 255,
        g: 255,
        b: 255
      }
    end
  end
end
