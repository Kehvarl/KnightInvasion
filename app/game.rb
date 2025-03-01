
class Game
    def initialize args
        @args = args
        @score = 0
        @max_score = 0
        @player = Player.new({shot_delay:0, v:10, x:620, y:660, w:30, h:60, tw:80, th:80, path:'sprites/square/black.png'})
        @entities = []
        @projectiles = []
        @knights_to_spawn = 10
        @princess_countdown = 300 + rand(300)
        @gryphon_countdown = 400 + rand(250)
        @sheep_countdown = 200 + rand(250)

    end

    def spawn_knights
        # Spawn Knights when required
        if @knights_to_spawn > 0
            k = {x:0, y:40, w:60, h:40}
            if not @entities.any_intersect_rect?(k)
                @entities << MovingEntity.new({:type => :knight, remove:false, arrow:false,
                                               :direction => :up, score:10,
                                               reverse_on_collision:true, vx:5,
                                               tw:80, th:80, x:0, y:40, w:30, h:40,
                                               flip_horizontally: false,
                                               path:'sprites/square/red.png'})
                @knights_to_spawn -= 1
            end
        end
    end

    def spawn_princess
        @princess_countdown -= 1
        if @princess_countdown <= 0 and rand(1000) < 10
            py =  rand(400)
            p = {x:0, y:py, w:20, h:30}
            if not @entities.any_intersect_rect?(p)
                @entities << MovingEntity.new({:type => :princess, remove:false, score:20, vx:6,
                                               tw:80, th:80, x:0, y:py, w:20, h:30,
                                               flip_horizontally: false,
                                               path:'sprites/square/violet.png'})
                @princess_countdown = 300 + rand(600)
            end
        end
    end

    def spawn_sheep
        if @entities.select{|e| e.type==:sheep}.size == 0
            @sheep_countdown -= 1
            if @sheep_countdown <= 0
                  sx = rand(1250)
                  s = {x:sx, y:0, w:20, h:30}
                  @entities << MovingEntity.new({:type => :sheep, remove:false, score:30, vx:0, vy:3,
                                                 tw:80, th:80, x:sx, y:0, w:20, h:30,
                                                 flip_horizontally: false,
                                                 path:'sprites/square/gray.png'})
                @sheep_countdown = rand(500) + 300
            end
        end
    end

    def spawn_gryphon
        @gryphon_countdown -= 1

        gy = 180 + rand(360)
        g = {x:0, y:gy, w:20, h:30}
        if @gryphon_countdown <= 0
            if not @entities.any_intersect_rect?(g)
                @entities << MovingEntity.new({:type => :gryphon, remove:false, score:30,
                                            :direction => :up,
                                            tw:80, th:80, vx:3, vy:3, x:0, y:gy, w:20, h:30,
                                            flip_horizontally: false,
                                            path:'sprites/square/yellow.png'})
                @gryphon_countdown = 400 + rand(250)
            end
        end
    end

    def tick
        @player.tick(@args.inputs.keyboard)

        spawn_knights
        spawn_princess
        spawn_gryphon
        spawn_sheep

        @entities.map{|e| e.tick}
        @projectiles.map{|e| e.tick}
        @entities = @entities.select{|e| e.remove == false}
    end

    def render
        out = []
        out << @player
        out << @entities
        out << @projectiles
        return out
    end
end

