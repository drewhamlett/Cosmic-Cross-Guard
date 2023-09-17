class Sound
  RATE_LIMIT = 200 # in milliseconds

  @last_played = {}

  def self.play(path, key:, gain: 0.5, pitch: 1.0)
    sound_info = $args.audio[key]
    # if $args.audio[key]
    #   p $args.audio
    #   return if $args.audio[key][:playtime] < $args.audio[key][:length]
    # end

    if sound_info
      $args.audio[key] = nil
    end

    $args.audio[key] = {
      input: "sounds/#{path}",
      gain: gain,
      looping: false,
      pitch: pitch,
      x: 1.0, y: -1.0
    }

    # $gtk.queue_sound "sounds/#{path}"
    # $args.outputs.sounds << "sounds/#{path}"
    # $args.outputs.sounds << {
    #   input: "sounds/#{path}",
    #   looping: false,
    #   gain: gain
    # }
  end
end
