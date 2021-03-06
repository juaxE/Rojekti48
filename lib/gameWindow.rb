require 'rubygems'
require 'gosu'

require './lib/levels/level'
require './lib/player/player'
require './lib/robot/robot'
require './lib/explosion/explosion'


WIDTH, HEIGHT = 1366, 768

module ZOrder
  BACKGROUND, STARS, PLAYER, UI = *0..3
end

class GameWindow < Gosu::Window
  def initialize(map_path, handler, width=WIDTH, height=HEIGHT)

    super WIDTH, HEIGHT, fullscreen = true

    self.caption = "MoreGun"

    @background = Gosu::Image.new('./assets/spookyWoods.png', :tileable => true)
    @level = Level.new(map_path, WIDTH)
    spawn1 = @level.getRandomStart
    spawn2 = @level.getRandomStart
    @character = Player.new(@level, spawn1[0], spawn1[1], 1)
    @character2 = Player.new(@level, spawn2[0], spawn2[1], 2)
    @handler = handler

    @level.addPlayer(@character)
    @level.addPlayer(@character2)
    @font = Gosu::Font.new(20)
    @battle_theme = Gosu::Song.new('./assets/audio/battleMusic.mp3')
    @battle_theme.volume = 0.4
    @battle_theme.play(looping = true)
    @end_voice = Gosu::Sample.new('./assets/audio/roundEnd.wav')
  end

  def update
    move_x = 0
    move_x -= 4 if Gosu.button_down? Gosu::KB_LEFT
    move_x += 4 if Gosu.button_down? Gosu::KB_RIGHT
    move_x2 = 0
    move_x2 -= 4 if Gosu.button_down? Gosu::KbA
    move_x2 += 4 if Gosu.button_down? Gosu::KbD
    @character.update(move_x)
    @character.shoot if Gosu.button_down? Gosu::KbL
    @character2.update(move_x2)
    @character2.collect_items(@level.items)
    @character.collect_items(@level.items)
    @character2.shoot if Gosu.button_down? Gosu::KbR
    @level.robots.each { |r| r.update  }
    @level.items.each { |i| i.update}
    @level.explosions.each { |e| e.update}
    @level.randomBot
    @level.updateBullets
    checkDeaths
  end

  def draw
    @background.draw 0, 0, 0
    @level.draw
    @character.draw
    @character2.draw
    @font.draw("Health: #{@character2.health} Score: #{@character2.boxes_collected}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLUE)
    @font.draw("Health: #{@character.health} Score: #{@character.boxes_collected}", 1180, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::RED)
  end

  def button_down(id)
    case id
      when Gosu::KB_UP
        @character.try_to_jump
      when Gosu::KbW
        @character2.try_to_jump
      when Gosu::KB_ESCAPE
        @battle_theme.stop
        close
      else
        super
    end
  end


  def checkWinner
    @level.players.each do |p|
      if p.hp>0
        @handler.winner = p.race.to_s
    end
  end
end

  def checkDeaths
      @level.players.each do |p|
        if p.is_dead?
          if Gosu.milliseconds - p.timeofdeath> 1500
            endGame
            #hide
          end
        end
      end
  end

  def endGame
    @end_voice.play(2,1,false)
    @handler.end_game
    close
  end

  def play_music(filepath)
    @music = Gosu::Song.new(filepath)
    @music.volume = 0.4
    @music.play(looping = true)
  end
end
