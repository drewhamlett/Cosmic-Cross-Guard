module SlowMo
  SLOW_MO_MULTI = 0.6

  def self.defaults(args)
    args.state.slow_mo ||= false
    args.state.slow_mo_x ||= 1.0
    args.state.slow_mo_timer ||= 0
  end

  def self.multi(args)
    args.state.slow_mo_x
  end

  def self.slow_mo!(args)
    return if args.state.slow_mo_timer > 0

    if args.state.slow_mo
      args.state.slow_mo = false
      args.state.slow_mo_x = 1.0
    else
      args.state.slow_mo = true
      args.state.slow_mo_x = SLOW_MO_MULTI
      args.state.slow_mo_timer = 60
    end
  end

  def self.tick(args)
    if args.state.slow_mo_timer > 0
      args.state.slow_mo_timer -= 1
    else
      args.state.slow_mo = false
      args.state.slow_mo_x = 1.0
    end
  end
end
