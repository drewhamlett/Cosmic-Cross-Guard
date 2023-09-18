class RotatingOrb
  SIZE = 10

  attr_gtk

  SCALE_FACTOR = 3
  DAMAGE_SCALE_FACTOR = 1.5

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

  def radius
    case state.power_ups.rotating_orb.level
    when 1
      50
    when 2
      70
    when 3
      80
    when 4
      80
    else
      80
    end
  end

  def speed
    case state.power_ups.rotating_orb.level
    when 1
      10
    when 2
      10
    when 3
      11
    when 4
      12
    else
      12
    end
  end

  def damage
    (1 * DAMAGE_SCALE_FACTOR**state.power_ups.rotating_orb.level).round
  end

  def tick(player:)
    prev_angle = state.orb[:angle]

    # Update angle
    state.orb[:angle] += speed

    # Handle full rotations
    if state.orb[:angle] >= 360
      state.orb[:angle] %= 360
      state.orb[:full_rotations] += 1
    end

    # Calculate new x and y based on the updated angle
    orb_x = player.x + 6 + radius * Math.cos(state.orb.angle * Math::PI / 180)
    orb_y = player.y + 6 + radius * Math.sin(state.orb.angle * Math::PI / 180)

    state.orb[:x] = orb_x - SIZE / 2
    state.orb[:y] = orb_y - SIZE / 2

    # Calculate dx and dy based on the new and old x and y
    state.orb[:dx] = state.orb[:x] - (player.x + radius * Math.cos(prev_angle * Math::PI / 180))
    state.orb[:dy] = state.orb[:y] - (player.y + radius * Math.sin(prev_angle * Math::PI / 180))
  end

  def draw
    [
      state.orb,
      {
        x: state.orb.x - (state.orb.w * SCALE_FACTOR) / SCALE_FACTOR,
        y: state.orb.y - (state.orb.h * SCALE_FACTOR) / SCALE_FACTOR,
        w: state.orb.w * SCALE_FACTOR,
        h: state.orb.h * SCALE_FACTOR,
        path: "sprites/glow.png",
        a: 200
      }
    ]
  end
end
