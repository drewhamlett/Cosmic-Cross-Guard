class PowerUps
  MAX_LEVEL = 30

  def self.defaults(args)
    state = args.state
    state.power_up_left_right ||= []
    state.power_ups ||= {
      # pendulum: {
      #   level: 1,
      #   active: false,
      #   text: "Base Orb: Protect base with an orb"
      # },
      # ghost: {
      #   level: 1,
      #   active: false,
      #   text: "Ghost Dash"
      # },
      # repair_base: {
      #   level: 1,
      #   active: false,
      #   text: "Repair Base"
      # },
      side_shot: {
        level: 1,
        active: false,
        text: "Side Shot"
      },
      rotating_orb: {
        level: 1,
        active: false,
        text: "Rotating Orb"
      },
      # gun: {
      #   type: :gun,
      #   level: 1,
      #   active: false,
      #   text: "Gun: Shoots bullets"
      # },
      homing_missile: {
        level: 1,
        active: false,
        text: "Homing Missile"
      },
      laser: {
        level: 1,
        active: false,
        text: "Laser"
      }
    }
  end

  # @param power_up [String]
  def self.upgrade!(args, power_up:)
    power_ups = args.state.power_ups
    power_ups[power_up][:active] = true
    power_ups[power_up].level += 1 if power_ups[power_up].level < MAX_LEVEL
  end

  # @return [Array<String>]
  def self.list(args)
    args.state.power_ups.keys
  end

  def self.left_right(args)
    first = list(args).sample
    second = list(args).filter { |l| l != first }.sample

    [first, second].map do |power_up|
      {
        **args.state.power_ups[power_up],
        type: power_up
      }
    end
  end
end
