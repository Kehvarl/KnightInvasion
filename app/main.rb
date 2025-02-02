def init args
  args.state.dragon = {v:5, x:620, y:0, w:40, h:80, path:'sprites/square/black.png'}
end

def tick args
  if args.tick_count == 0
    init args
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
  end

  # Render
  args.outputs.primitives << {x:0, y:0, w:1280, h:720, r:0, g:96, b:32}.solid!
  args.outputs.primitives << args.state.dragon
end
