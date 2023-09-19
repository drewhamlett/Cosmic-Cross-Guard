class Save
  VERSION = "v4".freeze
  FILE_NAME = "save_state_#{VERSION}.txt"

  def self.save!(args)
    saved_state = {
      power_ups: args.state.power_ups,
      needs_tutorial: args.state.needs_tutorial
    }

    $gtk.write_file(FILE_NAME, saved_state.inspect)
  end

  def self.load!(args)
    parsed_state = args.gtk.read_file(FILE_NAME)
    puts parsed_state
    p_state = eval(parsed_state)
    puts p_state[:power_ups]

    args.gtk.args.state.power_ups = p_state[:power_ups]
    args.gtk.args.state.needs_tutorial = p_state[:needs_tutorial]

    if !p_state[:needs_tutorial]
      args.gtk.args.state.tutorial_timer = 0
    end
  rescue => error
    args.gtk.args.state.needs_tutorial = true
    puts "Error #{error}"
  end
end
