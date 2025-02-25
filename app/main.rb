require 'app/game.rb'

def init args
    args.state.game = Game.new args
end

def tick args
    if args.tick_count == 0
        init args
    end

    args.state.game.tick

    args.outputs.primitives << args.state.game.render
end
