require 'chingu'
include Gosu

class SpaceGame < Chingu::Window
  def initialize(args)
    fullscreen = true
    args.each do |a|
      fullscreen = false if a == "WINDOW"
    end
    super(1440, 900, fullscreen)
  end
  def setup
    switch_game_state(MainState)
  end
end

class MainState < Chingu::GameState
  #attr_accessor :player
  def initialize
    super
    $name = "Player"
    $lives = 3 #3
    $points = 0 #0
    $wasd = true
    $player_looping = true
    $bullet_looping = false #difficult
    $inc_diff = true
    $particles = true
    $stars = true
    $parallax = true
    $shootingstars = true
    $starting_base = true
    #$cursor = true
    $player_speed = 5 #5
    $enemy_speed = 4.5 #4.5
    $bullet_speed = 15 #15
    $star_speed = 20 #20
    $asteroid_speed = 5 #10
    #above are configurable
    $aggression = 20 #20
    $enemy_view = 50 #50
    $enemy_intel = 50 #50
    $difficulty = 0
    $boss = false
    #$is_paused = true
    #$is_dead = false
    $game_over = false
    $window.caption = "Space Gauntlet"
    $starting_x = 70
    $starting_y = $window.height / 2
    $bgscroll = 0
    $shoot_snds = [Gosu::Sound['/sounds/shoot/Laser_Shoot1.wav'], Gosu::Sound['/sounds/shoot/Laser_Shoot2.wav'], Gosu::Sound['/sounds/shoot/Laser_Shoot3.wav'], Gosu::Sound['/sounds/shoot/Laser_Shoot4.wav'], Gosu::Sound['/sounds/shoot/Laser_Shoot5.wav'], Gosu::Sound['/sounds/shoot/Laser_Shoot6.wav']]
    $explosion_snds = [Gosu::Sound['/sounds/explosion/Explosion1.wav'], Gosu::Sound['/sounds/explosion/Explosion2.wav'], Gosu::Sound['/sounds/explosion/Explosion3.wav'], Gosu::Sound['/sounds/explosion/Explosion4.wav'], Gosu::Sound['/sounds/explosion/Explosion5.wav'], Gosu::Sound['/sounds/explosion/Explosion6.wav'], Gosu::Sound['/sounds/explosion/Explosion7.wav'], Gosu::Sound['/sounds/explosion/Explosion8.wav'], Gosu::Sound['/sounds/explosion/Explosion9.wav'], Gosu::Sound['/sounds/explosion/Explosion10.wav'], Gosu::Sound['/sounds/explosion/Explosion11.wav']]
    $powerup_snds = [Gosu::Sound['/sounds/powerup/Pickup_Coin1.wav'], Gosu::Sound['/sounds/powerup/Pickup_Coin2.wav'], Gosu::Sound['/sounds/powerup/Pickup_Coin3.wav'], Gosu::Sound['/sounds/powerup/Pickup_Coin4.wav'], Gosu::Sound['/sounds/powerup/Pickup_Coin5.wav'], Gosu::Sound['/sounds/powerup/Pickup_Coin6.wav']]
    $particle_imgs = [Gosu::Image['/particles/particle1.png'], Gosu::Image['/particles/particle2.png'], Gosu::Image['/particles/particle3.png']]
    @lifecounter = Gosu::Image['/logo/heart.png']
    $star_imgs = [Gosu::Image['/star/star1.png'], Gosu::Image['/star/star2.png'], Gosu::Image['/star/star3.png'], Gosu::Image['/star/star4.png'], Gosu::Image['/star/star5.png'], Gosu::Image['/star/star6.png']]
    $shootingstar_imgs = [Gosu::Image['/star/star5.png'], Gosu::Image['/star/star6.png'], Gosu::Image['/star/star7.png'], Gosu::Image['/star/star8.png']]
    $base = Gosu::Image['/logo/Base1.png']
    @logo = Gosu::Image['/logo/logo.png']
    @shield = Gosu::Image['/spaceship/Shield.png']
    $cursor = Gosu::Image['/logo/Crosshair1.png']
    $powered_up = false
    $invincible = false
    @player = Player.create
    if !$wasd
      @player.input = {holding_left: :move_left, holding_right: :move_right, holding_up: :move_up, holding_down: :move_down, backspace: :end_game, space: :shoot, holding_space: :laser, mouse_left: :shoot, holding_mouse_left: :laser}#, mouse_left: :shoot}
    else
      @player.input = {holding_a: :move_left, holding_d: :move_right, holding_w: :move_up, holding_s: :move_down, backspace: :end_game, space: :shoot, holding_space: :laser, mouse_left: :shoot, holding_mouse_left: :laser}
    end
    Gun.create
    self.input = {l: :toggle_particles, backspace: :exit, esc: :pause}
    $score = Chingu::Text.create("#{$points}", :x => 25, :y => 30, :zorder => 1000, :factor_x => 1.5, :factor_y => 1.5, :font => "Geneva")
    #$particleamt = Chingu::Text.create("GameObjects: #{Player.size + Enemy.size + PlayerBullet.size + EnemyBullet.size + ExtraLife.size + PowerUp.size + Invincibility.size + Gun.size + Particle.size + Star.size + ShootingStar.size}", :x => 25, :y => 50, :zorder => 1000, :factor_x => 1.2, :factor_y => 1.2, :font => "Geneva")
    #$difficultamt = Chingu::Text.create("Difficulty: #{$difficulty}", :x => 25, :y => 70, :zorder => 1000, :factor_x => 1.2, :factor_y => 1.2, :font => "Geneva")
    $fpscount = Chingu::Text.create("FPS: #{fps}", :x => 25, :y => 60, :zorder => 1000, :factor_x => 1.5, :factor_y => 1.5, :font => "Geneva")
    $high_score_list = Chingu::HighScoreList.load(:size => 10)
    #$is_paused = true
    #puts "Enter your name:"
    #$name = gets.chomp
    $music = Gosu::Song["/music/FA.mp3"]
    #$music.volume = 100
    $music.play(looping = true)
  end
  def draw
    super
    #@background.draw(@bgscroll % $window.width, 0, -1000)
    #@background.draw(@bgscroll % $window.width - $window.width, 0, -1000)
    $base.draw($bgscroll, 0, -1000, $window.height/$base.height.to_f, $window.height/$base.height.to_f) if $starting_base && !$game_over
    $lives.times do |count|
      @lifecounter.draw(32*count+5,5,1000)
    end
    #if !$game_over
    @logo.draw($window.width - @logo.width/0.98, $window.height - @logo.height/1.4, 1000)
    #else
    #  @logo.draw($window.width/2 - @logo.width/2, $window.height/2 - @logo.height/2, 1000)
    #end
    #@nose.draw(@player.x + 50, @player.y - @nose.height/2, 0)
    @shield.draw(@player.x - @shield.width/2 - 10, @player.y - @shield.height/2, -100) if $invincible
    #@star[rand(0..3)].draw(rand(0..$window.width), 16, 999) if rand(1..10) == 1
    $cursor.draw($window.mouse_x-8, $window.mouse_y-8, 1000)
    $cursor = Gosu::Image['/logo/Crosshair1.png']
    #$window.draw_line($player_x, $player_y, Gosu::Color::WHITE, $window.mouse_x, $window.mouse_y, Gosu::Color::WHITE)
  end
  def update
    if $game_over
      #if $is_dead
        Particle.all.each do |particle|
          particle.update
        end
      #end
      return
    end
    super# if !$is_paused
    ExtraLife.create if rand(2500) == 0 #2500
    PowerUp.create(0, 0, true) if rand(5000) == 0 #5000
    Invincibility.create(0, 0, true) if rand(5000) == 0 && !$invincible && !$boss #5000
    Enemy.create(1) if rand(30) == 0 #30
    Enemy.create(2) if rand(2000) == 0 #1000
    Enemy.create(3) if rand(5000) == 0 && !$invincible && !$boss #3000
    Star.create(rand(0..1)) if rand(2) == 0 #1
    Star.create(rand(2..3)) if rand(2) == 0 #2
    Star.create(rand(4..5)) if rand(5) == 0 #5
    ShootingStar.create(rand(1)) if rand(300) == 0 #300
    ShootingStar.create(2) if rand(800) == 0 #800
    ShootingStar.create(3) if rand(1200) == 0 #1200
    Asteroid.create if rand(75) == 0 #50
    AsteroidChunk.create(self, true) if rand(100) == 0 #75
    Player.each_collision(Enemy, EnemyBullet, Asteroid, AsteroidChunk) do |player_hit, enemy_hit|
      player_hit.death# if !$is_dead
      enemy_hit.damage
    end
    Enemy.each_collision(PlayerBullet) do |enemy_hit, bullet_hit|
      bullet_hit.destroy
      25.times do
        Particle.create(bullet_hit.x, bullet_hit.y, 10)
      end
      enemy_hit.damage
    end
    PlayerBullet.each_collision(EnemyBullet, Asteroid, AsteroidChunk) do |pbullet_hit, ebullet_hit|
      pbullet_hit.destroy
      ebullet_hit.destroy
      $points += 10
      25.times do
        Particle.create(ebullet_hit.x, ebullet_hit.y, 10)
      end
      $explosion_snds[rand(0..10)].play
    end
    Player.each_collision(ExtraLife) do |player_hit, life_hit|
      life_hit.destroy
      $points += 1000
      $lives += 1
      $powerup_snds[rand(0..5)].play
    end
    Player.each_collision(PowerUp) do |player_hit, power_hit|
      $powerup_snds[rand(0..5)].play
      $points += 1000
      player_hit.powerupDuration += power_hit.duration
      power_hit.destroy
      $powered_up = true
      if $powerup_count == nil
        $powerup_count = Chingu::Text.create("Triple Bullets Power: #{player_hit.powerupDuration/60+1}", :x => 25, :y => $window.height - 40, :zorder => 1000, :factor_x => 2, :factor_y => 2, :font => "Geneva", :color => Gosu::Color::GREEN)
      else
        $powerup_count.text = "Triple Bullets Power: #{player_hit.powerupDuration/60+1}"
      end
      #$current_time = Time.now
    end
    Player.each_collision(Invincibility) do |player_hit, inv_hit|
      $powerup_snds[rand(0..5)].play
      $points += 1000
      player_hit.invincibleDuration += inv_hit.duration
      inv_hit.destroy
      $invincible = true
      if $invincible_count == nil
        $invincible_count = Chingu::Text.create("Shield power: #{player_hit.invincibleDuration/60+1}", :x => 25, :y => $window.height - 75, :zorder => 1000, :factor_x => 2, :factor_y => 2, :font => "Geneva", :color => Gosu::Color::CYAN)
      else
        $invincible_count.text = "Shield Power: #{player_hit.invincibleDuration/60+1}"
      end
    end
    #$window.caption = "#{$name}: #{$points}" if !$game_over && !$is_paused
    $score.text = "#{$points}" if !$game_over# && !$is_paused
    #$particleamt.text = "GameObjects: #{Player.size + Enemy.size + PlayerBullet.size + EnemyBullet.size + ExtraLife.size + PowerUp.size + Invincibility.size + Gun.size + Particle.size + Star.size + ShootingStar.size}"
    #$difficultamt.text = "Difficulty: #{$difficulty}"
    $fpscount.text = "FPS: #{fps}"
    #if $window.mouse_x > $player_x
    #  $cursor_x = $window.mouse_x
    #else
    #  $cursor_x = $player_x
    #end
    #$cursor_y = $window.mouse_y
    $bgscroll -= 1.5 if $bgscroll > -$base.width# && !$is_paused
    $points += 1 if !$game_over
    $difficulty += 1
    $points = 0 if $points < 0
    if $inc_diff
      if $difficulty % 2500 == 1 && $difficulty > 1
        $aggression -= 2
        $enemy_intel -= 4
        $enemy_view += 2
      end
      $aggression = 1 if $aggression < 1
      $enemy_intel = 1 if $enemy_intel < 1
    end
    #$cursor = Gosu::Image['/logo/Crosshair1.png']
    #if $difficulty % 8500 == 1 && $difficulty > 1
    #  $music.play
    #end
    #if Time.now - $current_time > @powerupDuration
    #  $powered_up = false
    #  @powerupDuration = 5
    #end
  end
  def pause
    return if $game_over
    $points = 0 if $points < 0
    #$window.caption = "Your current score is #{$points}. Press ENTER to continue..." if !$game_over
    #$score.text = "Your current score is #{$points}. Press ENTER to continue..." if !$game_over
    #if $is_dead
    #  Particle.all do |particle|
    #  particle.destroy
    #end
    #$is_dead = false if !$game_over
    $window.push_game_state(Pause) #$is_paused = !$is_paused if !$is_paused || !$game_over
  end
  def toggle_particles
    Particle.destroy_all
    ShootingStar.destroy_all
    $particles = !$particles
    $shootingstars = !$shootingstars
  end
  def exit
    if $game_over
      @player.end_game
      super
    end
  end
end

class Pause < Chingu::GameState
  def initialize(options = {})
    super
    @white = Gosu::Color.new(255,255,255,255)
    @color = Gosu::Color.new(200,0,0,0)
    @font = Gosu::Font[35]
    @text = "PAUSED - press ESC to return to game."
    @esc_held = $window.button_down?(Gosu::KbEscape)
  end

  def button_up(id)
    pop_game_state(:setup => false) if id == Gosu::KbEscape && !@esc_held   # Return the previous game state, dont call setup()
    @esc_held = false
  end

  def draw
    previous_game_state.draw    # Draw prev game state onto screen (in this case our level)
    $window.draw_quad(  0,0,@color,
                        $window.width,0,@color,
                        $window.width,$window.height,@color,
                        0,$window.height,@color, Chingu::DEBUG_ZORDER)

    @font.draw(@text, ($window.width/2 - @font.text_width(@text)/2), $window.height/2 - @font.height, Chingu::DEBUG_ZORDER + 1)
  end
end

class GameOver < Chingu::GameState
  def initialize
    @color = Gosu::Color.new(200,0,255,0)
    $score.text = "You Lost, #{$name}! Your score was #{$points}."
    Chingu::Text.destroy_if { |text| text.size == 20}
    Chingu::Text.create("GAME OVER", :x => $window.width/8, :y => $window.height/10, :size => 200, :color => Gosu::Color::RED)
    Chingu::Text.create("HIGH SCORES", :x => $window.width/2-300, :y => $window.height/3+10, :size => 100, :color => Gosu::Color::YELLOW)
    #
    # Iterate through all high scores and create the visual represenation of it
    #
    $high_score_list.each_with_index do |high_score, index|
      y = index * 50 + $window.height/2
      if $newscore != index+1
        Chingu::Text.create(high_score[:name], :x => $window.width/2-200, :y => y, :size => 50)
        Chingu::Text.create(high_score[:score], :x => $window.width/2+100, :y => y, :size => 50)
      else
        Chingu::Text.create(high_score[:name], :x => $window.width/2-200, :y => y, :size => 50, :color => Gosu::Color::YELLOW)
        Chingu::Text.create(high_score[:score], :x => $window.width/2+100, :y => y, :size => 50, :color => Gosu::Color::YELLOW)
      end
      #$window.fill_rect([10, 10, 800, 600], Gosu::Color::GREEN, Chingu::DEBUG_ZORDER)
      #fill_gradient(:from => Color.new(255,0,0,0), :to => Color.new(255,60,60,80), :rect => [0,0,$window.width,500])
    end
  end
end

class Player < Chingu::GameObject
  trait :collision_detection
  trait :bounding_box, :scale => 0.8#, :debug => true
  attr_accessor :powerupDuration, :invincibleDuration
  def initialize
    super
    @image = Gosu::Image['/spaceship/PlayerShip1.png']
    @x = $starting_x
    @y = $starting_y
    $player_x = @x
    $player_y = @y
    @zorder = 0
    $powered_up = false
    @powerupDuration = 0
    @invincibleDuration = 0
    #@md = 100
  end
  def move_left
    @x -= $player_speed-1 if @x >= $starting_x
  end
  def move_right
    @x += $player_speed+1 if @x <= $window.width - 50
    Particle.create(@x-75, @y, 10)
  end
  def move_up
    if $player_looping
      @y -= $player_speed
      if @y < -16
        @y = $window.height + 16
      end
    else
      @y -= $player_speed if @y > 16
    end
  end
  def move_down
    if $player_looping
      @y += $player_speed
      if @y > $window.height + 16
        @y = -16
      end
    else
      @y += $player_speed if @y < $window.height - 16
    end
  end
  def update
    #puts "#{@powerupDuration}"
    @x -= 1 if @x >= $starting_x
    #Particle.create(@x-75, @y, 5) if rand(0..1) == 1
    if $powered_up
      @powerupDuration -= 1
      $powerup_count.text = "Triple Bullets Power: #{@powerupDuration/60+1}"
    end
    if @powerupDuration < 0
      $powered_up = false
      @powerupDuration = 0
      $powerup_count.destroy
      $powerup_count = nil
    #else
    #  $powered_up = true
    end
    if $invincible
      @invincibleDuration -= 1
      $invincible_count.text = "Shield Power: #{@invincibleDuration/60+1}"
    end
    if @invincibleDuration < 0
      $invincible = false
      @invincibleDuration = 0
      $invincible_count.destroy
      $invincible_count = nil
      #else
      #  $powered_up = true
    end
    $player_x = @x
    $player_y = @y
  end
  #def draw
  #  $window.draw_triangle(@x-77, @y-5, Gosu::Color.new(0xFFFF00), @x-75, @y, Gosu::Color.new(0xFFFF00), @x-73, @y-5, Gosu::Color.new(0xFFFF00))
  #  super
  #end
  def shoot
    if !$powered_up && !$game_over && PlayerBullet.size <= 6#32#6
      #PlayerBullet.create(self)
      #if $powered_up
      #  PlayerBullet.create(self, :up)
      #  PlayerBullet.create(self, :down)
      #end
      #if $window.mouse_y > $player_y-@md && $window.mouse_y < $player_y+@md
      #  PlayerBullet.create(self)
      #elsif $window.mouse_y < $player_y-@md
      #  PlayerBullet.create(self, :up)
      #elsif $window.mouse_y > $player_y+@md
      #  PlayerBullet.create(self, :down)
      #end
      #@velocity.x =     $window.mouse_x -$player_x
      #@velocity.y =     $window.mouse_y -$player_y
      PlayerBullet.create(self)#, ($window.mouse_y-$player_y)/($player_y/10))
      $shoot_snds[rand(0..5)].play
    end
  end
  def laser
    if !$game_over && $powered_up && PlayerBullet.size <= 20
      PlayerBullet.create(self)
      $shoot_snds[rand(0..5)].play
    end
  end
  #def save_score
    #if File.exists?("scores.txt")
    #  scores = []
    #  File.open("scores.txt").each_line do |score|
    #    scores.push score.chomp.split(",") if score.strip.length > 0
    #    puts "Score from file #{score}"
    #  end
    #  scores.dup.each_with_index do |score, index|
    #    if $points > score[1].to_i
    #      scores.insert(index, [$name, $points.to_s])
    #      break
    #    end
    #    if index == scores.length - 1
    #      scores.push [$name, $points.to_s]
    #    end
    #  end
    #  puts scores.to_s
    #  #$row1 = Chingu::Text.create("#{scores.to_s}", :x => $window.width/2, :y => $window.height/2, :zorder => 1000, :factor_x => 1.0, :factor_y => 1.0, :font => "Geneva")
    #  File.open("scores.txt", 'w') do |file|
    #    scores.each do |score|
    #      file.write(score.join(',') + "\n")
    #    end
    #  end
    #else
    #  File.open("scores.txt", 'w') do |file|
    #    file.write("#{$name},#{$points}")
    #    #$row1 = Chingu::Text.create("#{$name}: #{$points}", :x => $window.width/2, :y => $window.height/2, :zorder => 1000, :factor_x => 1.0, :factor_y => 1.0, :font => "Geneva")
    #  end
    #end
    ##$scoreboard = Chingu::Text.create("#{scores.to_s}", :x => $window.width/2, :y => $window.height/2, :zorder => 1000, :factor_x => 1.0, :factor_y => 1.0, :font => "Geneva")
    #$window.push_game_state Chingu::GameStates::EnterName.new(:callback => method(:add))
    #$high_score_list.add({name: $name, score:   $points})
  #end
  def death
    if !$invincible
      $explosion_snds[rand(0..10)].play
      @image = Gosu::Image['/spaceship/PlayerShip.png']
      Enemy.destroy_all
      #Miniboss.destroy_all
      #Boss.destroy_all
      Particle.destroy_all
      100.times do
        Particle.create(@x, @y, 25)
      end
      @x = $starting_x
      @y = $starting_y
      $powered_up = false
      $powerup_count.destroy if @powerupDuration > 0
      $powerup_count = nil
      @powerupDuration = 0
      $invincible_count.destroy if @invincibleDuration > 0
      $invincible_count = nil
      @invincibleDuration = 0
      $boss = false
      $lives -= 1
      if $lives <= 0
        destroy
        Gun.destroy_all
        $points = 0 if $points < 0
        #$window.caption = "You Lost, #{$name}! Your score was #{$points}."
        #$points += @powerupDuration/60+1
        #$points += @invincibleDuration/60+1
        $game_over = true
        #$window.pop_game_state
        $window.push_game_state Chingu::GameStates::EnterName.new(:callback => method(:add))
      else
        $points -= 1000
        $bgscroll = 0
        $base.draw($bgscroll, 0, -1000) if $starting_base
      end
      EnemyBullet.destroy_all
      PlayerBullet.destroy_all
      ExtraLife.destroy_all
      PowerUp.destroy_all
      Invincibility.destroy_all
      Star.destroy_all
      ShootingStar.destroy_all
      Asteroid.destroy_all
      AsteroidChunk.destroy_all
      #pause
      #$is_dead = true
    end
  end
  def add(name)
    $name = name
    $newscore = $high_score_list.add({name: $name, score:   $points})
    puts "User entered name #{name}"
    $window.pop_game_state
    $window.push_game_state(GameOver)
  end
  def end_game
    if !$game_over
      $points += $lives*10
      $points += @powerupDuration
      $points += @invincibleDuration
      $invincible = false
      $lives = 0
      death
    end
  end
end

class Enemy < Chingu::GameObject
  trait :collision_detection
  trait :bounding_box, :scale => 0.8#, :debug => true
  def initialize(type)
    super()
    @type = type
    case @type
      when 1
        @image = Gosu::Image['/spaceship/Enemy1.png']
        @zorder = -10
        @count = 1
        @health = 1
      when 2
        @image = Gosu::Image['/spaceship/MiniBoss1.png']
        @zorder = -20
        @count = 3
        @health = 5
      when 3
        @image = Gosu::Image['/spaceship/Boss1.png']
        @zorder = -30
        @count = 5
        @health = 10
        $boss = true
    end
    @angle = 180
    @x = $window.width + @image.width
    @y = rand(0..$window.height)
  end
  def update
    case @type
      when 1
        @x -= $enemy_speed
        #EnemyBullet.create(self) if rand(0..$aggression) == 1 || @y < $player_y+25 && @y > $player_y-25 && rand(0..50) == 1
        #destroy if @x <= -@image.width
        #Particle.create(@x+50, @y, 5) if rand(0..1) == 1
      when 2
        @x -= $enemy_speed - 0.3
        #Particle.create(@x+75, @y, 8) if rand(0..1) == 1
        #if rand(0..400) == 1
        #  EnemyBullet.create(self, :up)
        #  EnemyBullet.create(self, :down)
        #  if @y < $player_y+25 && @y > $player_y-25 && rand(0..50) == 1
        #    EnemyBullet.create(self)
        #  end
        #end
      when 3
        @x -= $enemy_speed - 0.6
        #Particle.create(@x+100, @y, 8) if rand(0..1) == 1
        #if rand(0..300) == 1 || @y < $player_y+25 && @y > $player_y-25 && rand(0..50) == 1
        #  EnemyBullet.create(self)
        #  EnemyBullet.create(self, :up)
        #  EnemyBullet.create(self, :down)
        #end
    end
    Particle.create(@x + @image.width/2 - 8, @y, 8) if rand(0..1) == 1
    if rand(0..$aggression*20) == 1 || @y < $player_y+$enemy_view && @y > $player_y-$enemy_view && rand(0..$enemy_intel) == 1
      EnemyBullet.create(self) if @type != 2 || @y < $player_y+$enemy_view && @y > $player_y-$enemy_view
      if @type != 1
        #EnemyBullet.create(self, :up)
        #EnemyBullet.create(self, :down)
        EnemyBullet.create(self, true)
        EnemyBullet.create(self, true)
      end
    end
    if $window.mouse_x > @x-@image.width && $window.mouse_x < @x+@image.width/2 && $window.mouse_y > @y-@image.height/2 && $window.mouse_y < @y+@image.height/2
      $cursor = Gosu::Image['/logo/Crosshair2.png']
    end
    if @x <= -@image.width
      @x = $window.width + @image.width
      @y = rand(0..$window.height)
      @count -= 1
    end
    if @count <= 0
      destroy
    end
  end
  def damage
    @health -= 1
    $points += 100
    $explosion_snds[rand(0..10)].play
    if @health < 1
      destroy
      100.times do
        Particle.create(@x, @y, 25)
      end
      case @type
        when 2
          $points += 5000
          50.times do
            Particle.create(@x-50, @y, 25)
          end
          50.times do
            Particle.create(@x+50, @y, 25)
          end
        when 3
          $boss = false
          $points += 10000
          50.times do
            Particle.create(@x-75, @y, 25)
          end
          50.times do
            Particle.create(@x+75, @y, 25)
          end
          Invincibility.create(@x, @y, false) if rand(0..1)==0
      end
      PowerUp.create(@x, @y, false) if rand(0..2)==0 && !$powered_up && @type != 1
    end
  end
end

#class PlayerBullet < Chingu::GameObject
#  traits :collision_detection, :bounding_circle
#  def initialize(shooter, direction = :straight)
#    super(image: Gosu::Image['/bullet/PlayerBullet.png'])
#    @x = shooter.x
#    @y = shooter.y
#    #@x_velocity = $bullet_speed
#    #@y_velocity = $bullet_speed
#    @direction = direction
#    #if @direction == :straight
#    #  if @x < $window.mouse_x
#    #    @x_velocity = $bullet_speed
#    #  else
#    #    @x_velocity = -$bullet_speed
#    #  end
#    #  if @y < $window.mouse_y
#    #    @y_velocity = $bullet_speed
#    #  else
#    #    @y_velocity = -$bullet_speed
#    #  end
#    #end
#  end
#  def update
#    @x += rand($bullet_speed-2..$bullet_speed+2)
#    @y += rand(-5..5)
#    #@x += @x_velocity
#    #@y += @y_velocity
#    if @direction == :up
#      @y -= $bullet_speed - 4
#    end
#    if @direction == :down
#      @y += $bullet_speed - 4
#    end
#    if $bullet_looping
#      if @y > $window.height + 5
#        @y = -5
#      end
#      if @y < -5
#        @y = $window.height + 5
#      end
#    end
#    destroy if @x >= $window.width + 16 || @y < -16 || @y > $window.height + 16
#  end
#end

class PlayerBullet < Chingu::GameObject
  traits :collision_detection, :bounding_circle
  def initialize(shooter)#, velocity)
    super(image: Gosu::Image['/bullet/PlayerBullet.png'])
    @x = shooter.x
    @y = shooter.y
    @zorder = 1
    @x_velocity = ($window.mouse_x-$player_x)#/($player_x/16)#velocity# - 300
    #@x_velocity = $bullet_speed
    @y_velocity = ($window.mouse_y-$player_y)#/($player_y/16)
    #@magx = (@x_velocity.to_f) * (@x_velocity.to_f)#**
    #@magy = (@y_velocity.to_f) * (@y_velocity.to_f)#**
    @mag = Math::sqrt(@x_velocity**2 + @y_velocity**2)
    #@direction = direction
    #if @direction == :straight
    #  if @x < $window.mouse_x
    #    @x_velocity = $bullet_speed
    #  else
    #    @x_velocity = -$bullet_speed
    #  end
    #  if @y < $window.mouse_y
    #    @y_velocity = $bullet_speed
    #  else
    #    @y_velocity = -$bullet_speed
    #  end
    #end
  end
  def update
    #@magx = (@x_velocity.to_f) * (@x_velocity.to_f)#**
    #@magy = (@y_velocity.to_f) * (@y_velocity.to_f)#**
    @mag = Math::sqrt(@x_velocity**2 + @y_velocity**2)
    @x_velocity /= @mag
    @y_velocity /= @mag
    @x += @x_velocity*$bullet_speed# + $bullet_speed#rand($bullet_speed-2..$bullet_speed+2)
    @y += @y_velocity*$bullet_speed
    if @x_velocity < 0
      @x += @image.width/2
      @x_velocity = 0#@x_velocity.abs
    end
    #@x += @x_velocity * 20
    #@y += @y_velocity * 20
    if @direction == :up
      @y -= $bullet_speed - 4
    end
    if @direction == :down
      @y += $bullet_speed - 4
    end
    if $bullet_looping
      if @y > $window.height + 5
        @y = -5
      end
      if @y < -5
        @y = $window.height + 5
      end
    end
    destroy if @x >= $window.width + 16 || @y < -16 || @y > $window.height + 16
  end
end

#class EnemyBullet < Chingu::GameObject
#  traits :collision_detection, :bounding_circle
#  def initialize(shooter, direction = :straight)
#    super(image: Gosu::Image['/bullet/EnemyBullet.png'])
#    @x = shooter.x
#    @y = shooter.y
#    @zorder = -35
#    @direction = direction
#  end
#  def update
#    @x -= rand($bullet_speed-2..$bullet_speed+2)
#    @y += rand(-3..3)
#    if @direction == :up
#      @y -= $bullet_speed - 4
#    end
#    if @direction == :down
#      @y += $bullet_speed - 4
#    end
#    if $bullet_looping
#      if @y > $window.height + 5
#        @y = -5
#      end
#      if @y < -5
#        @y = $window.height + 5
#      end
#    end
#    destroy if @x <= -16 || @y < -16 || @y > $window.height + 16
#  end
#  def damage
#    destroy
#  end
#end

class EnemyBullet < Chingu::GameObject
  traits :collision_detection, :bounding_circle
  def initialize(shooter, power=false)
    super(image: Gosu::Image['/bullet/EnemyBullet.png'])
    @x = shooter.x
    @y = shooter.y
    @zorder = -35
    @power = power
    if @power
      @x_velocity = (@x-$player_x)
      @y_velocity = (@y-$player_y)
      @mag = Math::sqrt(@x_velocity**2 + @y_velocity**2)
    end
  end
  def update
    if @power
      @mag = Math::sqrt(@x_velocity**2 + @y_velocity**2)
      @x_velocity /= @mag
      @y_velocity /= @mag
      @x -= @x_velocity*$bullet_speed# + $bullet_speed#rand($bullet_speed-2..$bullet_speed+2)
      @y -= @y_velocity*$bullet_speed
      if @x_velocity < 0
        #@x -= @image.width/2
        @x_velocity = 0#@x_velocity.abs
      end
    else
      @x -= rand($bullet_speed-2..$bullet_speed+2)
      @y += rand(-3..3)
    end
    if $window.mouse_x > @x-@image.width && $window.mouse_x < @x+@image.width/2 && $window.mouse_y > @y-@image.height/2 && $window.mouse_y < @y+@image.height/2
      $cursor = Gosu::Image['/logo/Crosshair2.png']
    end
    if @direction == :up
      @y -= $bullet_speed - 4
    end
    if @direction == :down
      @y += $bullet_speed - 4
    end
    if $bullet_looping
      if @y > $window.height + 5
        @y = -5
      end
      if @y < -5
        @y = $window.height + 5
      end
    end
    destroy if @x <= -16 || @y < -16 || @y > $window.height + 16
  end
  def damage
    destroy
  end
end

class ExtraLife < Chingu::GameObject
  traits :collision_detection, :bounding_box
  def initialize
    super
    @image = Gosu::Image['/powerup/heart_add.png']
    @x = $window.width + 24
    @y = rand(0..$window.height)
    @zorder = -50
  end
  def update
    @x -= 3
  end
end

class PowerUp < Chingu::GameObject
  trait :collision_detection
  trait :bounding_circle, :scale => 0.8#, :debug => true
  attr_accessor :natural, :duration
  def initialize(x, y, natural)
    super()
    @image = Gosu::Image['/powerup/triplicator.png']
    @natural = natural
    #@duration = 0
    if natural
      @x = $window.width + 24
      @y = rand(0..$window.height)
      @duration = 300 #5 secs
    else
      @x = x
      @y = y
      @duration = 300 #10 secs
    end
    @zorder = -50
  end
  def update
    @x -= 3
  end
end

class Invincibility < Chingu::GameObject
  trait :collision_detection
  trait :bounding_box, :scale => 0.8#, :debug => true
  attr_accessor :natural, :duration
  def initialize(x, y, natural)
    super()
    @image = Gosu::Image['/powerup/Shield.png']
    @natural = natural
    if natural
      @x = $window.width + 24
      @y = rand(0..$window.height)
      @duration = 300 #5 secs
    else
      @x = x
      @y = y
      @duration = 300 #10 secs
    end
    @zorder = -50
  end
  def update
    @x -= 3
  end
end

class Gun < Chingu::GameObject
  def initialize
    super
    @image = Gosu::Image['/spaceship/Gun.png']
    @x = $player_x
    @y = $player_y
    @angle = Math::atan2($window.mouse_y - @y, $window.mouse_x - @x)*180/Math::PI
    @zorder = 2
  end
  def update
    @x = $player_x
    @y = $player_y
    @angle = Math::atan2($window.mouse_y - @y, $window.mouse_x - @x)*180/Math::PI
    if @angle < -90
      @angle = -90
    elsif @angle > 90
      @angle = 90
    end
  end
end

class Particle < Chingu::GameObject
  def initialize(x, y, speed)
    if $particles && Particle.size <= 100
      super()
      @image = $particle_imgs[rand(0..2)]
      @x = x
      @y = y
      @zorder = -15
      @particleSpeed = speed
      #$particleamt.text = "#{Particle.size}"
    end
  end
  def update
    super
    @angle += 90
    # @image = $particle_imgs[rand(0..2)]
    @x += rand(-@particleSpeed..@particleSpeed)
    @y += rand(-@particleSpeed..@particleSpeed)
    destroy if @x <= -@image.width
    destroy if @x >= $window.width + @image.width
    destroy if @y <= -@image.height
    destroy if @y >= $window.height + @image.height
    if rand(1..10) == 1
      destroy
    end
  end
end

class Star < Chingu::GameObject
  def initialize(type)
    if $stars
    super()
      @type = type
      @image = $star_imgs[@type]
      @x = $window.width + @image.width
      @y = rand(0..$window.width)
      @zorder = -800 + @type
    end
  end
  def update
    if $parallax
      case @type
        when 0
          @x -= 1.5
        when 1
          @x -= 2
        when 2
          @x -= 2.5
        when 3
          @x -= 2.5
        when 4
          @x -= 3
        when 5
          @x -= 3
      end
    else
      @x -= 3
    end
    destroy if @x < -@image.width
  end
end

class ShootingStar < Chingu::GameObject
  def initialize(type)
    if $shootingstars
      super()
      @image = $shootingstar_imgs[type]
      @spawnSide = rand(1..4) #1:top|2:bottom|3:right|4:left
      @xdir = 0
      @ydir = 0
      @offset = rand(-5..5)
      case @spawnSide
        when 1
          @x = rand(0..$window.width)
          @y = -@image.height
          @xdir = rand(-$star_speed..$star_speed)
          @ydir = @xdir.abs + @offset
        when 2
          @x = rand(0..$window.width)
          @y = $window.height + @image.height
          @xdir = rand(-$star_speed..$star_speed)
          @ydir = -@xdir.abs + @offset
        when 3
          @x = $window.width + @image.width
          @y = rand(0..$window.width)
          @ydir = rand(-$star_speed..$star_speed)
          @xdir = -@ydir.abs + @offset
        when 4
          @x = -@image.width
          @y = rand(0..$window.height)
          @ydir = rand(-$star_speed..$star_speed)
          @xdir = @ydir.abs + @offset
      end
      @zorder = -900
    end
  end
  def update
    @x += @xdir
    @y += @ydir
    if @xdir > -5 && @xdir < 0
      @xdir = -5
    elsif @xdir < 5 && @xdir > 0
      @xdir = 5
    end
    if @ydir > -5 && @ydir < 0
      @ydir = -5
    elsif @ydir < 5 && @ydir > 0
      @ydir = 5
    end
    destroy if @x < -@image.width
    destroy if @x > $window.width + @image.width
    destroy if @y < -@image.height
    destroy if @y > $window.height + @image.height
  end
end

class Asteroid < Chingu::GameObject
  traits :collision_detection, :bounding_circle
  def initialize#(type)
    super#()
    @image = Gosu::Image['/star/Asteroid1.png']
    @spawnSide = rand(1..3) #1:top|2:bottom|3:right|4:left
    #@xdir = 0
    #@ydir = 0
    #@offset = rand(-5..5)
    @rot = rand(0..1)
    @rot = -1 if @rot == 0
    case @spawnSide
      when 1
        @x = rand(0..$window.width)
        @y = -@image.height
        #@xdir = rand(-$asteroid_speed..$asteroid_speed)
        #@ydir = @xdir.abs + @offset
      when 2
        @x = rand(0..$window.width)
        @y = $window.height + @image.height
        #@xdir = rand(-$asteroid_speed..$asteroid_speed)
        #@ydir = -@xdir.abs + @offset
      when 3
        @x = $window.width + @image.width
        @y = rand(0..$window.width)
        #@ydir = rand(-$asteroid_speed..$asteroid_speed)
        #@xdir = -@ydir.abs + @offset
      #when 4
        #@x = -@image.width
        #@y = rand(0..$window.height)
        #@ydir = rand(-$asteroid_speed..$asteroid_speed)
        #@xdir = @ydir.abs + @offset
    end
    @x_velocity = rand(-$asteroid_speed..$asteroid_speed)
    @y_velocity = rand(-$asteroid_speed..$asteroid_speed)
    @zorder = 0
  end
  def update
    @x += @x_velocity
    @y += @y_velocity
    if $window.mouse_x > @x-@image.width/2 && $window.mouse_x < @x+@image.width/2 && $window.mouse_y > @y-@image.height/2 && $window.mouse_y < @y+@image.height/2
      $cursor = Gosu::Image['/logo/Crosshair2.png']
    end
    @angle += @rot
    #if @xdir > -5 && @xdir < 0
    #  @xdir = -5
    #elsif @xdir < 5 && @xdir > 0
    #  @xdir = 5
    #end
    #if @ydir > -5 && @ydir < 0
    #  @ydir = -5
    #elsif @ydir < 5 && @ydir > 0
    #  @ydir = 5
    #end
    destroy if @x < -@image.width
    destroy if @x > $window.width + @image.width
    destroy if @y < -@image.height
    destroy if @y > $window.height + @image.height
  end
  def damage
    destroy
  end
  def destroy
    rand(1..3).times do
      AsteroidChunk.create(self, false)
    end
    super
  end
end

class AsteroidChunk < Chingu::GameObject
  traits :collision_detection, :bounding_circle
  def initialize(parent, natural)
    super()
    @image = Gosu::Image['/star/Asteroid2.png']
    @natural = natural
    if @natural
      @spawnSide = rand(1..3) #1:top|2:bottom|3:right|4:left
      #@xdir = 0
      #@ydir = 0
      #@offset = rand(-5..5)
      case @spawnSide
        when 1
          @x = rand(0..$window.width)
          @y = -@image.height
          #@xdir = rand(-$asteroid_speed..$asteroid_speed)
          #@ydir = @xdir.abs + @offset
        when 2
          @x = rand(0..$window.width)
          @y = $window.height + @image.height
          #@xdir = rand(-$asteroid_speed..$asteroid_speed)
          #@ydir = -@xdir.abs + @offset
        when 3
          @x = $window.width + @image.width
          @y = rand(0..$window.width)
          #@ydir = rand(-$asteroid_speed..$asteroid_speed)
          #@xdir = -@ydir.abs + @offset
        #when 4
        #@x = -@image.width
        #@y = rand(0..$window.height)
        #@ydir = rand(-$asteroid_speed..$asteroid_speed)
        #@xdir = @ydir.abs + @offset
      end
    else
      @x = parent.x
      @y = parent.y
    end
    @x_velocity = rand(-$asteroid_speed..$asteroid_speed)
    @y_velocity = rand(-$asteroid_speed..$asteroid_speed)
    @rot = rand(0..1)
    @rot = -1 if @rot == 0
    @zorder = 0
  end
  def update
    @x += @x_velocity
    @y += @y_velocity
    if $window.mouse_x > @x-@image.width/2 && $window.mouse_x < @x+@image.width/2 && $window.mouse_y > @y-@image.height/2 && $window.mouse_y < @y+@image.height/2
      $cursor = Gosu::Image['/logo/Crosshair2.png']
    end
    @angle += @rot
    destroy if @x < -@image.width
    destroy if @x > $window.width + @image.width
    destroy if @y < -@image.height
    destroy if @y > $window.height + @image.height
  end
  def damage
    destroy
  end
end

SpaceGame.new(ARGV).show