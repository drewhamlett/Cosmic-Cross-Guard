class Base
  attr_gtk

  HEIGHT = 16
  TILE_AMOUNT = (SCREEN_SIZE_X / HEIGHT).round

  def initialize
    @tiles = TILE_AMOUNT.times.map do |i|
      {
        x: 0 + (HEIGHT * i),
        y: SCREEN_SIZE_Y - HEIGHT,
        h: HEIGHT,
        w: HEIGHT,
        hit: false,
        health: 1
      }
    end
  end

  def tick
    state.base ||= @tiles
  end

  def draw
    state.base.map do |base|
      {
        **base,
        a: base.hit ? 0 : 230,
        path: "sprites/base_block.png"
      }
    end
  end
end
