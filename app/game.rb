class Entity
    attr_sprite
    def initialize vals
        super()
        @remove = false

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
    end
end

class MovingEntity < Entity
    def initialize args
        super vals
        @min_x = vals.min_x || 0
        @max_x = vals.max_x || 1280
        @miy_y = vals.min_y || 0
        @max_y = vals.max_y || 720
        @vx = vals.vx || 0
        @vy = vals.vy || 0

        @has_favor = false
        @direction = :up
        @reverse_on_collision = false
    end

    def move

        if @type == :gryphon and (@y >= 640 or @y <= 0)
            @vy = -@vy
        end

        if @favor
            @y += [@vx, @vy].max
            if @y + @h >= 700
                @favor = false
            end
        else
            @x += @vx
            @y += @vy

            if @x + @w >= 1280 or @x <= 0 # Touched edge of screen
                if  @reverse_on_collision
                    reverse_and_shift_row
                else
                    @remove = true
                end
            end
        end
    end


    def reverse_and_shift_row
        @vx = -@vx
        @vy = -@vy
        if @direction == :up
            @y += (@h + 10)
        else
            @y -= (@h + 10)
        end
        if @y <= 0
            @direction = :up
        elsif @y >= 630
            @direction = :down
        end
        @flip_horizontally =  !@flip_horizontally
    end

    def tick
        super
        move
    end
end

class Game
    def initialize args
        @args = args
        @keys = args.inputs.keyboard
        @score = 0
        @max_score = 0
        @player = {shot_delay:0, v:5, x:620, y:660, w:30, h:60, path:'sprites/square/black.png'}.sprite!
        @entities = []
        @projectiles = []

    end

    def check_overlap x, y, w, h
        @entities.any_intersect_rect?({x:x, y:y, w:w, h:h})
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
        @entites = @entities.select{|e| e.remove == false}
    end

    def render
        out = []
        out << @player
        out << @entities
        out << @projectiles
        return out
    end
end

