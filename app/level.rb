class Level
  A = 0.5
  B = 1.2
  C = 0.3

  def self.difficulty(args)
    level = args.state.current_level
    power_level = args.state.power_level
    max_power_level = args.state.max_power_level

    base_difficulty = A * (level**B)
    equip_modifier = 1 + C * (power_level.to_f / max_power_level)
    base_difficulty * equip_modifier
  end
end
