module PauseScreen
  def self.tick(args)
    args.state.paused ||= false

    if args.inputs.keyboard.key_down.escape
      puts "Toggling pause"
      args.state.paused = !args.state.paused
    end
  end

  def self.paused?(args)
    args.state.paused
  end

  def self.draw(args)
  end
end
