module HitLabel
  OPACITY = 255

  def self.tick(args)
    args.state.hit_labels ||= []
    args.state.hit_labels.reject! { |particle| particle[:life] <= 0 }

    args.state.hit_labels.each do |particle|
      particle[:x] += particle[:dx]
      particle[:y] += particle[:dy]
      particle[:life] -= 1
      particle[:opacity] -= particle[:fade_rate]
      particle[:size] = rand * 7 # Random size between 0 and 10
      particle[:angle] = rand * 360 # Random rotation between 0 and 360 degrees
    end
  end

  def self.spawn(args, x:, y:, dx:, dy:, text: "1", critical: false)
    life = Utils.random(50, 70)
    color = [255, 255, 255]

    color = [252, 106, 0] if critical
    args.state.hit_labels << {
      text: text,
      x: x,
      y: y,
      dx: Utils.random(-1, 1), # Random velocity between -1 and 1
      dy: Utils.random(1.5, 2), # Random velocity between -1 and 1
      life: life,
      size: Utils.random(5, 10),
      opacity: Utils.random(OPACITY - 20, OPACITY),
      fade_rate: (Utils.random(OPACITY - 20, OPACITY) / life.to_f).ceil,
      r: color[0],
      g: color[1],
      b: color[2]
    }
  end

  def self.draw(args)
    args.state.hit_labels.map do |label|
      {
        x: label.x,
        y: label.y,
        text: label.text || "1",
        r: label.r,
        g: label.g,
        b: label.b,
        a: label.opacity,
        font: FONT
      }
    end
  end
end
