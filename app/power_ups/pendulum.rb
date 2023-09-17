# class Pendulum
#   attr_gtk

#   # INTERTIA = 1.0
#   DAMPING = 0.01
#   GRAVITY = 0.1
#   LENGTH = 500.0
#   FRICTION = 0.0005

#   def initialize
#     @angle = 180  # Start at a 45-degree angle
#     @angular_velocity = 0.0
#     @angular_acceleration = 0.0
#     @prev_player_dx = 0
#     @prev_player_dy = 0
#   end

#   def tick(player:)
#     # Calculate inertia (I = m * L^2, assuming mass m = 1 for simplicity)
#     inertia = LENGTH

#     # Calculate torque due to gravity
#     torque_due_to_gravity = GRAVITY * Math.sin(@angle)

#     # Calculate player's influence based on their change in position
#     estimated_accel_x = (player.dx - @prev_player_dx)
#     estimated_accel_y = (player.dy - @prev_player_dy)

#     # Calculate torque due to player's movement
#     torque_due_to_player = 0.5 * (estimated_accel_x + estimated_accel_y)

#     # Calculate the net torque (add damping to oppose motion)
#     net_torque = torque_due_to_gravity + torque_due_to_player - DAMPING * @angular_velocity

#     # Update angular acceleration
#     @angular_acceleration = net_torque / inertia

#     # Update angular velocity (consider damping and friction)
#     @angular_velocity += @angular_acceleration - DAMPING * @angular_velocity
#     @angular_velocity *= (1 - FRICTION)

#     # Update angle and wrap around for full rotation
#     @angle += @angular_velocity
#     @angle %= 2 * Math::PI

#     # Update the previous player dx and dy for the next frame
#     @prev_player_dx = player.dx
#     @prev_player_dy = player.dy

#     # Calculate x and y position of the pendulum's end
#     @x = player.x + LENGTH * Math.sin(@angle)
#     @y = player.y + LENGTH * Math.cos(@angle)  # 0,0 is at bottom-left
#   end

#   def tick2(player:)
#     # Calculate torque due to gravity
#     torque_due_to_gravity = GRAVITY / LENGTH * Math.sin(@angle)

#     # Update angular velocity and angle
#     @angular_velocity += torque_due_to_gravity
#     @angle += @angular_velocity

#     # Calculate x and y position of the pendulum's end
#     @x = player.x + LENGTH * Math.sin(@angle)
#     @y = player.y + LENGTH * Math.cos(@angle)  # 0,0 is at bottom-left
#   end

#   def draw(player:)
#     args.render_target(:game).lines << [player.x + player.w / 2, player.y + player.h / 2, @x, @y, 255, 255, 255, 20]

#     # args.render_target(:game).sprites << [@x - 5, @y - 5, 12, 12, 0, 0, 255]
#     args.render_target(:game).sprites << [
#       {
#         x: @x - 5,
#         y: @y - 5,
#         h: 12,
#         w: 12,
#         r: 255,
#         g: 255,
#         b: 255
#       },
#       {
#         x: @x - 12,
#         y: @y - 12,
#         w: 24,
#         h: 24,
#         path: "sprites/glow.png",
#         a: 200
#       }
#     ]
#   end

#   def defaults
#   end

#   # def draw(player:)
#   #   # args.render_target(:game).lines << [player.x, player.y, @x, @y, 255, 0, 0]
#   #   args.render_target(:game).solids << [@x - 5, @y - 5, 10, 10, 0, 0, 255]
#   # end
# end

class Pendulum
  SIZE = 10

  attr_gtk

  def defaults
    state.pendulum ||= {
      x: 0,
      y: 0,
      w: SIZE,
      h: SIZE,
      dx: 0.0,
      dy: 0.0,
      prev_x: 0,
      prev_y: 0,
      speed: 0.1,
      length: 100,

      radius: 250.0,
      r: 180,
      g: 180,
      b: 180,
      a: 255,
      angular_velocity: 0.0,
      angle: 0.0

    }
  end

  def tick2(player:)
    # Constants
    mass = 10
    gravity = 0.1
    friction = 0.99
    time_step = 0.1

    player_force = -player.sprite[:dx] * 0.05 + player.sprite[:dy] * 0.05

    # Step 1: Calculate Torque (Force applied times distance from pivot)
    torque = state.pendulum[:length] * player_force

    # Add torque due to gravity
    torque_due_to_gravity = -mass * gravity * state.pendulum[:length] * Math.sin(state.pendulum[:angle] * Math::PI / 180)

    torque += torque_due_to_gravity

    # Step 2: Update Angular Velocity
    state.pendulum[:angular_velocity] += (torque / mass) * time_step

    # Step 3: Apply friction to angular velocity
    state.pendulum[:angular_velocity] *= friction

    # Step 4: Update Angle
    state.pendulum[:angle] += state.pendulum[:angular_velocity] * time_step

    # Step 5: Bound angle between 0 and 360
    state.pendulum[:angle] %= 360

    # Step 6: Update x and y position based on new angle
    pivot_x = player.x + player.w / 2
    pivot_y = player.y + player.h / 2
    state.pendulum[:x] = pivot_x + state.pendulum[:length] * Math.sin(state.pendulum[:angle] * Math::PI / 180)
    state.pendulum[:y] = pivot_y - state.pendulum[:length] * Math.cos(state.pendulum[:angle] * Math::PI / 180)
  end

  def tick(player:)
    max_angle_deflection = 360.0
    offset = 360.0
    speed_of_pendulum = 0.5

    angle = max_angle_deflection * Math.sin(args.state.tick_count * speed_of_pendulum * 0.05)

    pendulum_x = SCREEN_SIZE_X / 2 + state.pendulum[:radius] * Math.cos(angle * Math::PI / offset)
    pendulum_y = SCREEN_SIZE_Y / 3 + state.pendulum[:radius] * Math.sin(angle * Math::PI / offset)

    d_angle_dt = max_angle_deflection * speed_of_pendulum * 0.05 * Math.cos(args.state.tick_count * speed_of_pendulum * 0.05)

    dx = -state.pendulum[:radius] * Math.sin(angle * Math::PI / offset) * d_angle_dt
    dy = state.pendulum[:radius] * Math.cos(angle * Math::PI / offset) * d_angle_dt

    state.pendulum[:x] = pendulum_x
    state.pendulum[:y] = pendulum_y
    # state.pendulum[:angle] = angle - 300
    state.pendulum[:dx] = dx * 0.01
    state.pendulum[:dy] = dy * 0.01
  end

  def draw(player:)
    scale_factor = 3

    [
      state.pendulum,
      {
        x: state.pendulum.x - (state.pendulum.w * scale_factor) / scale_factor,
        y: state.pendulum.y - (state.pendulum.h * scale_factor) / scale_factor,
        w: state.pendulum.w * scale_factor,
        h: state.pendulum.h * scale_factor,
        path: "sprites/glow.png",
        a: 100,
        angle: state.pendulum.angle
      }
    ]
  end
end
