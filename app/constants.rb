SCREEN_SIZE_X = 1280
SCREEN_SIZE_Y = 720

FONT = "fonts/TinyUnicode.ttf".freeze

# center = 1.5
center = 1.5

RECT = {
  x: 0,
  y: 0,
  h: SCREEN_SIZE_Y,
  w: SCREEN_SIZE_X,
  # r: 30,
  # g: 30,
  # b: 30,
  r: 58, g: 58, b: 75

}

module Utils
  # @param [Integer] min
  # @param [Integer] max
  def self.random(min, max)
    rand(max - min + 1) + min
  end
end
