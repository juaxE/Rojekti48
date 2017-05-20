SPEED = 10

class Bullet
  attr_reader :x, :y

  def initialize(x, y, direction, level)
    @image = Gosu::Image.new('./assets/bullet.png')
    @x, @y = x, y
    @direction = direction
    @level = level
  end

  def draw
    if @direction == :left
      offs_x = 0
      factor = 2
    else
      offs_x = -5
      factor = -2
    end
    @image.draw(@x + offs_x, @y, 0, factor, 2)
  end

  def update
    if @direction == :right
      @x = @x + SPEED

    else
      @x = @x - SPEED
    end

  end

  def would_fit
    not @level.solid?(@x, @y)
  end
end
