def init args
  args.state.dragon = {v:5, x:620, y:0, w:40, h:80, path:'sprites/square/black.png'}.sprite!
  args.state.knights = []
  args.state.fireballs = []
end

def spawn_knight args
  k = {v:2, x:0, y:680, w:90, h:40}
  if not args.state.knights.any_intersect_rect?(k)
    args.state.knights << {damaged:false,
                           v:2, x:0, y:680, w:60, h:40,
                           flip_horizontally: false,
                           path:'sprites/square/red.png'}.sprite!
  end
end

def spawn_fireball args
  f = {deleted:false,
       x:args.state.dragon.x,
       y:args.state.dragon.y + args.state.dragon.h,
       w:40, h:40, v:2,
       path:'sprites/misc/explosion-1.png'}.sprite!

  if args.state.fireballs.size > 2 or args.state.fireballs.any_intersect_rect?(f)
    return
  end
  args.state.fireballs << f

end

def tick args
  if args.tick_count == 0
    init args
  end

  if args.state.knights.size < 10
    spawn_knight args
  end

  if args.inputs.keyboard.left
    # Fly Left
    args.state.dragon.x = [0, args.state.dragon.x - args.state.dragon.v].max
  elsif args.inputs.keyboard.right
    # Fly Right
    args.state.dragon.x = [1240, args.state.dragon.x + args.state.dragon.v].min
  end

  if args.inputs.keyboard.up
    # Move away from the cave
    args.state.dragon.y = [120, args.state.dragon.y + args.state.dragon.v].min
  elsif args.inputs.keyboard.down
    # Move closer to the cave
    args.state.dragon.y = [0, args.state.dragon.y - args.state.dragon.v].max
  end

  if args.inputs.keyboard.space
    #Breathe fire
    spawn_fireball args
  end

  args.state.knights.map do |k|
    k.x += k.v
    if k.x + k.w >= 1280 or k.x <= 0
      k.v = -k.v
      k.y -= (k.h + 10)
      k.flip_horizontally = !k.flip_horizontally
    end
  end

  args.state.fireballs.map do |f|
    f.y += f.v
    if f.y > 720
      f.deleted=true
    end
    hits = args.state.knights.select{|k| k.intersect_rect?(f)}
    hits.each do |h|
      h.damaged=true
      f.deleted=true
    end
  end
  args.state.fireballs = args.state.fireballs.select{|f| f.deleted == false}
  args.state.knights = args.state.knights.select{|k| k.damaged == false}
  # Render
  args.outputs.primitives << {x:0, y:0, w:1280, h:720, r:0, g:96, b:32}.solid!
  args.outputs.primitives << args.state.dragon
  args.outputs.primitives << args.state.knights
  args.outputs.primitives << args.state.fireballs
end
