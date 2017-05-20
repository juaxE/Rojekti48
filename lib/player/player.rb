require 'rubygems'
require 'gosu'

require './lib/gun/gun'

SCALE = 0.5

class Player
  attr_reader :x, :y

  def initialize(level, x, y)
    @hp = 100
    @gun = Gun.new(x,y)
    @firespeed = 2
    @x, @y = x, y
    @dir = :left
    @vy = 0 # Vertical velocity
    @level = level
    # Load all animation frames
    @standing, @walk1, @walk2, @jump, @shoot, @die = *Gosu::Image.load_tiles("./assets/player2.png", 70, 56)
    # This always points to the frame that is currently drawn.
    # This is set in update, and used in draw.
    @cur_image = @standing
  end

  def collect_boxes(boxes)
      boxes.reject! do |box|
        if Gosu.distance(@x, @y, box.x, box.y) < 20
          @firespeed + box.firespeed_increase
          true
        else
          false
      end
    end
  end

  def take_damage (amount)
    @hp - amount
  end

  def draw
    # Flip vertically when facing to the left.
    if @dir == :left
      offs_x = -25*(SCALE)
      factor = SCALE
    else
      offs_x = 25*(SCALE)
      factor = -1*SCALE
    end
    @cur_image.draw(@x + offs_x, @y - (65*SCALE), 0, factor, SCALE)
  end

  # Could the object be placed at x + offs_x/y + offs_y without being stuck?
  def would_fit(offs_x, offs_y)
    # Check at the center/top and center/bottom for map collisions
    not @level.solid?(@x + offs_x, @y + offs_y) and
        not @level.solid?(@x + offs_x, @y + offs_y - (70*SCALE))
  end

  def update(move_x)
    # Select image depending on action
    if (move_x == 0)
      @cur_image = @standing
    else
      @cur_image = (Gosu.milliseconds / 175 % 2 == 0) ? @walk1 : @walk2
    end
    if (@vy < 0)
      @cur_image = @jump
    end

    # Directional walking, horizontal movement
    if move_x > 0
      @dir = :right
      move_x.times { if would_fit(1, 0) then @x += 1 end }
    end
    if move_x < 0
      @dir = :left
      (-move_x).times { if would_fit(-1, 0) then @x -= 1 end }
    end

    # Acceleration/gravity
    # By adding 1 each frame, and (ideally) adding vy to y, the player's
    # jumping curve will be the parabole we want it to be.
    @vy += 1
    # Vertical movement
    if @vy > 0
      @vy.times { if would_fit(0, 1) then @y += 1 else @vy = 0 end }
    end
    if @vy < 0
      (-@vy).times { if would_fit(0, -1) then @y -= 1 else @vy = 0 end }
    end
  end

  def try_to_jump
    if @level.solid?(@x, @y + 1)
      @vy = -20
    end
  end

  def shoot
    @level.addBullet(@x, @y, @dir)
  end
end
