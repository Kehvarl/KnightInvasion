
class Game
    def initialize args
        @args = args
        @score = 0
        @max_score = 0
        @player = Player.new({shot_delay:0, v:10, x:620, y:660, w:30, h:60, tw:80, th:80, path:'sprites/square/black.png'})
        @entities = []
        @projectiles = []
        @knights_to_spawn = 10
    end

    def spawn_knights
        # Spawn Knights when required
        if @knights_to_spawn > 0
            k = {x:0, y:40, w:60, h:40}
            if not @entities.any_intersect_rect?(k)
                @entities << MovingEntity.new({remove:false, arrow:false,
                                            :direction => :up, score:10,
                                            reverse_on_collision:true, vx:5,
                                            tw:80, th:80, x:0, y:40, w:30, h:40,
                                            flip_horizontally: false,
                                            path:'sprites/square/red.png'})
                @knights_to_spawn -= 1
            end
        end
    end

    def tick
        @player.tick(@args.inputs.keyboard)

        spawn_knights

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

