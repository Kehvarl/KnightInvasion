def init args
  args.state.dragon = {v:5, x:620, y:0, w:40, h:80, path:'sprites/square/black.png'}.sprite!
  args.state.knights = []
  args.state.fireballs = []
  args.state.barriers = []
end

def spawn_knight args
  k = {v:2, x:0, y:680, w:90, h:40}
  if not args.state.knights.any_intersect_rect?(k)
    args.state.knights << {remove:false,
                           v:2, x:0, y:680, w:60, h:40,
                           flip_horizontally: false,
                           path:'sprites/square/red.png'}.sprite!
  end
end

def spawn_fireball args
  f = {remove:false,
       x:args.state.dragon.x,
       y:args.state.dragon.y + args.state.dragon.h,
       w:40, h:40, v:2,
       path:'sprites/misc/explosion-1.png'}.sprite!

  if args.state.fireballs.size > 2 or args.state.fireballs.any_intersect_rect?(f)
    return
  end
  args.state.fireballs << f
end

def spawn_barrier args, knight
  args.state.barriers << {hp: 3,
                          x:knight.x, y:knight.y, w:40, h:40,
                          path:'sprites/square/blue.png'}.sprite!
end

def handle_input args
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
end

def move_knights args
  args.state.knights.map do |k|
    k.x += k.v
    if k.x + k.w >= 1280 or k.x <= 0 or args.state.barriers.any_intersect_rect?(k)
      k.v = -k.v
      k.y -= (k.h + 10)
      k.flip_horizontally = !k.flip_horizontally
    end
  end
end

def move_fireballs args
  args.state.fireballs.map do |f|
    f.y += f.v
    if f.y > 720
      f.remove=true
    end
  end
end

def tick args
  if args.tick_count == 0
    init args
  end

  # Continuously spawn new knights
  if args.state.knights.size < 10
    spawn_knight args
  end

  handle_input args
  move_knights args
  move_fireballs args

  # Did any Knights get hit?
  Geometry.each_intersect_rect(args.state.fireballs, args.state.knights) do |fireball, knight|
    knight.remove=true
    spawn_barrier args, knight
    fireball.remove=true
  end

    # Did any Knights get hit?
  Geometry.each_intersect_rect(args.state.fireballs, args.state.barriers) do |fireball, barrier|
    barrier.hp -=1
    fireball.remove=true
  end

  # Cleanup after any hits
  args.state.fireballs = args.state.fireballs.select{|f| f.remove == false}
  args.state.knights = args.state.knights.select{|k| k.remove == false}
  args.state.barriers = args.state.barriers.select{|b| b.hp > 0}


  # Render
  args.outputs.primitives << {x:0, y:0, w:1280, h:720, r:0, g:96, b:32}.solid!
  args.outputs.primitives << args.state.dragon
  args.outputs.primitives << args.state.knights
  args.outputs.primitives << args.state.barriers
  args.outputs.primitives << args.state.fireballs
end
