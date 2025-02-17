class Entity
    attr_sprite
    def initialize vals
        super()
        @x = vals.x || 0
        @y = vals.y || 0
        @w = vals.w || 20
        @h = vals.h || 30
        @path = vals.path || 'sprites/misc/explosion-sheet.png'

        @tile_x = vals.tx || 0
        @tile_y = vals.ty || 0
        @tile_w = vals.tw || 32
        @tile_h = vals.th || 32
        @frames = vals.frames || 7
        @frame_time = vals.frame_time || 5
        @cur_frame = 0
        @cur_frame_time = @frame_time
    end

    def animate
        @cur_frame_time -=1
        if @cur_frame_time <= 0
            @cur_frame = (@cur_frame + 1) % @frames
            @cur_frame_time = @frame_time
            @tile_x = @tile_w * @cur_frame
        end
    end

    def tick
        animate
    end
end

class Game
    def initialize args
        @args = args
        @keys = args.inputs.keyboard
        @player = {}
        @entities = []
        @projectiles = []

    end

    def handle_input
        if @keys.left
            # Fly Left
            @player.x = [0, @player.x - @player.v].max
        elsif @keys.right
            # Fly Right
            @player.x = [1280 - @player.w, @player.x + @player.v].min
        end

        if @keys.up
            # Move away from the cave
            @player.y = [720 - @player.h, @player.y + @player.v].min
        elsif @keys.down
            # Move closer to the cave
            @player.y = [600 - @player.h, @player.y - @player.v].max
        end

        if @keys.space
            #Breathe fire
            if @player.shot_delay <= 0
            #spawn_fireball args
            @player.shot_delay = 15
            end
        end
    end

    def tick
        handle_input

        @entities.map{|e| e.tick}
        @projectiles.map{|e| e.tick}
    end

    def render
        out = []
        out << @player
        out << @entities
        out << @projectiles
        return out
    end
end

