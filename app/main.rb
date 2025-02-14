def init args
  args.state.dragon = {shot_delay:0, v:5, x:620, y:660, w:30, h:60, path:'sprites/square/black.png'}.sprite!
  args.state.knights = []
  args.state.knights_to_spawn = 10
  args.state.knights_countdown = 0
  args.state.princesses = []
  args.state.princess_countdown = rand(300) + 300
  args.state.sheep = []
  args.state.sheep_countdown = rand(200) + 200
  args.state.fireballs = []
  args.state.barriers = []
end

def spawn_knight args
  k = {x:0, y:40, w:60, h:40}
  if not args.state.knights.any_intersect_rect?(k)
    args.state.knights << {remove:false, arrow:false,
                           :direction => :up,
                           v:3, x:0, y:40, w:30, h:40,
                           flip_horizontally: false,
                           path:'sprites/square/red.png'}.sprite!
    return true
  end
  return false
end

def spawn_princess args
  py =  rand(400)
  p = {x:0, y:py, w:20, h:30}
  if not args.state.knights.any_intersect_rect?(p)
    args.state.princesses << {remove:false,
                           v:5, x:0, y:py, w:20, h:30,
                           flip_horizontally: false,
                           path:'sprites/square/violet.png'}.sprite!
  end
end

def spawn_sheep args
  sx = rand(1250)
  s = {x:sx, y:0, w:20, h:30}
  args.state.sheep << {remove:false,
                          v:3, x:sx, y:0, w:20, h:30,
                          flip_horizontally: false,
                          path:'sprites/square/gray.png'}.sprite!
end

def spawn_fireball args
  f = {remove:false,
       x:args.state.dragon.x,
       y:args.state.dragon.y, #- args.state.dragon.h,
       w:20, h:20, v:6,
       path:'sprites/misc/explosion-1.png'}.sprite!

  if args.state.fireballs.size > 2 or args.state.fireballs.any_intersect_rect?(f)
    return
  end
  args.state.fireballs << f
end

def spawn_barrier args, knight
  args.state.barriers << {hp: 3, arrow: false,
                          x:knight.x, y:knight.y, w:30, h:40,
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
    args.state.dragon.y = [720 - args.state.dragon.h, args.state.dragon.y + args.state.dragon.v].min
  elsif args.inputs.keyboard.down
    # Move closer to the cave
    args.state.dragon.y = [600 - args.state.dragon.h, args.state.dragon.y - args.state.dragon.v].max
  end

  if args.inputs.keyboard.space
    #Breathe fire
    if args.state.dragon.shot_delay <= 0
      spawn_fireball args
      args.state.dragon.shot_delay = 15
    end
  end
end

def move_knights args
  args.state.knights.map do |k|
    if k.arrow
      k.y += k.v
      if k.y + k.h >= 700
        k.arrow = false
      end
    else
      k.x += k.v
      if k.x + k.w >= 1280 or k.x <= 0 or args.state.barriers.any_intersect_rect?(k)
        Geometry.each_intersect_rect(args.state.barriers, args.state.knights) do |barrier, knight|
          if barrier.arrow
            knight.arrow = true
            return
          end
        end
        k.v = -k.v
        if k.direction == :up
          k.y += (k.h + 10)
        else
          k.y -= (k.h + 10)
        end
        if k.y <= 0
          k.direction = :up
        elsif k.y >= 630
          k.direction = :down
        end
        k.flip_horizontally = !k.flip_horizontally
      end
    end
  end
end

def move_princesses args
  args.state.princesses.map do |p|
    p.x += p.v
    if p.x > 1280
      p.remove = true
    end
  end
  # Did a princess touch a statue?
  Geometry.each_intersect_rect(args.state.barriers, args.state.princesses) do |barrier, princess|
    barrier.arrow=true
    barrier.path='sprites/square/green.png'
  end
end

def move_sheep args
  args.state.sheep.map do |s|
    s.y += s.v
    if s.y > 640
      s.remove = true
    end
    if not s.remove
        sb = {x:s.x-15, y:s.y-15, w:s.w+30, h:s.h+30}
        if not args.state.barriers.any_intersect_rect?(sb)
          spawn_barrier args, s
        end
    end
  end
end

def move_fireballs args
  args.state.fireballs.map do |f|
    f.y -= f.v
    if f.y <= -f.h
      f.remove=true
    end
  end
end

def handle_hits args
    # Did any Knights get hit?
  Geometry.each_intersect_rect(args.state.fireballs, args.state.knights) do |fireball, knight|
    knight.remove=true
    spawn_barrier args, knight
    fireball.remove=true
  end

  # Did any princesses get hit?
  Geometry.each_intersect_rect(args.state.fireballs, args.state.princesses) do |fireball, princess|
    princess.remove=true
    fireball.remove=true
  end

    # Did any Barriers get hit?
  Geometry.each_intersect_rect(args.state.fireballs, args.state.barriers) do |fireball, barrier|
    barrier.hp -=1
    fireball.remove=true
  end

      # Did any Barriers get hit?
  Geometry.each_intersect_rect(args.state.fireballs, args.state.sheep) do |fireball, sheep|
    sheep.remove=true
    fireball.remove=true
  end

  # Cleanup after any hits
  args.state.fireballs = args.state.fireballs.select{|f| f.remove == false}
  args.state.knights = args.state.knights.select{|k| k.remove == false}
  args.state.princesses = args.state.princesses.select{|p| p.remove == false}
  args.state.sheep = args.state.sheep.select{|s| s.remove == false}


  args.state.barriers = args.state.barriers.select{|b| b.hp > 0}
end

def render args
    # Render
  args.outputs.primitives << {x:0, y:0, w:1280, h:720, r:0, g:96, b:32}.solid!
  args.outputs.primitives << args.state.dragon
  args.outputs.primitives << args.state.knights
  args.outputs.primitives << args.state.princesses
  args.outputs.primitives << args.state.sheep
  args.outputs.primitives << args.state.barriers
  args.outputs.primitives << args.state.fireballs
end

def tick args
  if args.tick_count == 0
    init args
  end

  args.state.dragon.shot_delay -= 1

  args.state.princess_countdown -= 1
  if args.state.princess_countdown <= 0 and rand(1000) < 10
    spawn_princess args
    args.state.princess_countdown = 300 + rand(600)
  end

  if args.state.sheep.size == 0
    args.state.sheep_countdown -= 1
    if args.state.sheep_countdown <= 0
      spawn_sheep args
      args.state.sheep_countdown = rand(500) + 300
    end
  end


  # Spawn Knights when required
  if args.state.knights_to_spawn > 0
    if spawn_knight args
      args.state.knights_to_spawn -= 1
      args.state.knights_countdown = rand(500) + 500
    end
  end

  if args.state.knights_countdown <= 0 and args.state.knights_to_spawn <= 0
    args.state.knights_to_spawn = rand(5) + 5
  end

  handle_input args
  move_knights args
  move_princesses args
  move_sheep args
  move_fireballs args
  handle_hits args

  render args
end
