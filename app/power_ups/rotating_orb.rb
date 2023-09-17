class RotatingOrb
  SIZE = 10

  attr_gtk

  def defaults
    state.orb ||= {
      x: 0,
      y: 0,
      w: SIZE,
      h: SIZE,
      dx: 0.0,
      dy: 0.0,
      prev_x: 0, # Add this
      prev_y: 0, # Add this
      speed: 10,
      # radius: 70,
      radius: 50,
      angle: 0.0,
      r: 255,
      g: 255,
      b: 255,
      a: 200,
      full_rotations: 0
    }
  end

  def tick(player:)
    # Store previous angle for comparison
    prev_angle = state.orb[:angle]

    # Update angle
    state.orb[:angle] += state.orb[:speed]

    # Handle full rotations
    if state.orb[:angle] >= 360
      state.orb[:angle] %= 360
      state.orb[:full_rotations] += 1
    end

    # Calculate new x and y based on the updated angle
    orb_x = player.x + 6 + state.orb.radius * Math.cos(state.orb.angle * Math::PI / 180)
    orb_y = player.y + 6 + state.orb.radius * Math.sin(state.orb.angle * Math::PI / 180)

    state.orb[:x] = orb_x - SIZE / 2
    state.orb[:y] = orb_y - SIZE / 2

    # Calculate dx and dy based on the new and old x and y
    state.orb[:dx] = state.orb[:x] - (player.x + state.orb.radius * Math.cos(prev_angle * Math::PI / 180))
    state.orb[:dy] = state.orb[:y] - (player.y + state.orb.radius * Math.sin(prev_angle * Math::PI / 180))
  end

  def draw
    scale_factor = 3

    [
      state.orb,
      {
        x: state.orb.x - (state.orb.w * scale_factor) / scale_factor,
        y: state.orb.y - (state.orb.h * scale_factor) / scale_factor,
        w: state.orb.w * scale_factor,
        h: state.orb.h * scale_factor,
        path: "sprites/glow.png",
        a: 200
      }
    ]
  end
end
