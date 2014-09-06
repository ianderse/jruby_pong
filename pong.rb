$:.push File.expand_path('../lib', __FILE__)

require 'java'
require 'lwjgl.jar'
require 'slick.jar'

java_import org.newdawn.slick.BasicGame
java_import org.newdawn.slick.GameContainer
java_import org.newdawn.slick.Graphics
java_import org.newdawn.slick.Image
java_import org.newdawn.slick.Input
java_import org.newdawn.slick.SlickException
java_import org.newdawn.slick.AppGameContainer

class PongGame < BasicGame
  def render(container, graphics)
  	@bg.draw(0,0)
  	@ball.image.draw(@ball.x, @ball.y)
  	@p1_paddle.image.draw(@p1_paddle.x, @p1_paddle.y)
  	@p2_paddle.image.draw(@p2_paddle.x, @p2_paddle.y)
    graphics.draw_string('RubyPong (ESC to exit)', 8, container.height - 30)
    graphics.draw_string("P1 Score: #{@p1_score}   P2 Score: #{@p2_score}", 8, container.height - 50)
  end

  def init(container)
  	@speed = 1
  	@p1_score = 0
  	@p2_score = 0
  	@bg = Image.new('data/bg.png')
  	@ball = Ball.new(200, 200, 45)
	  @p1_paddle = Paddle.new(200, 400)
	  @p2_paddle = Paddle.new(200, 50)
  end

  def update(container, delta)
    player_movement(container, delta)
    ball_movement(container, delta)
  end

  def player_movement(container, delta)
  	input = container.get_input
    container.exit if input.is_key_down(Input::KEY_ESCAPE)

  	if input.is_key_down(Input::KEY_LEFT) && @p1_paddle.x > 0
    	@p1_paddle.x -= 0.3 * delta
  	elsif input.is_key_down(Input::KEY_RIGHT) && @p1_paddle.x < container.width - @p1_paddle.image.width
	    @p1_paddle.x += 0.3 * delta
	  end

	  if input.is_key_down(Input::KEY_A) && @p2_paddle.x > 0
    	@p2_paddle.x -= 0.3 * delta
    elsif input.is_key_down(Input::KEY_D) && @p2_paddle.x < container.width - @p2_paddle.image.width
	    @p2_paddle.x += 0.3 * delta
	  end
  end

  def ball_movement(container, delta)
  	@ball.x += 0.3 * delta * Math.cos(@ball.angle * Math::PI / 180) * @speed
		@ball.y -= 0.3 * delta * Math.sin(@ball.angle * Math::PI / 180) * @speed

		hit_paddle(container, delta)
		off_screen(container, delta)
  end

  def off_screen(container, delta)
  	if (@ball.x > container.width - @ball.image.width) || (@ball.y < 0) || (@ball.x < 0)
		  @ball.angle = (@ball.angle + 90) % 360
		end

  	if @ball.y > container.height
			@p2_score += 1
			reset_game
		elsif @ball.y < 0
			@p1_score += 1
			reset_game
		end
  end

  def hit_paddle(container, delta)
  	if @ball.x >= @p1_paddle.x && @ball.x <= (@p1_paddle.x + @p1_paddle.image.width) && @ball.y.round >= (400 - @ball.image.height)
			@ball.angle = (@ball.angle + 90) % 360
			#@speed += 0.05
		elsif @ball.x >= @p2_paddle.x && @ball.x <= (@p2_paddle.x + @p2_paddle.image.width) && @ball.y.round <= (100 - @ball.image.height)
			@ball.angle = (@ball.angle + 90) % 360
			#@speed += 0.05
		end
  end

  def reset_game
  	@p1_paddle.x = 200
	  @ball.x = 200
	  @ball.y = 200
	  @ball.angle = 45
	  @speed = 1
  end

end

class Ball
	attr_reader :image
	attr_accessor :x, :y, :angle

	def initialize(x, y, angle)
		@image = Image.new('data/ball.png')
		@x = x
	  @y = y
	  @angle = angle
	end
end

class Paddle
	attr_reader :image
	attr_accessor :x, :y

	def initialize(x, y)
		@image = Image.new('data/paddle.png')
		@x = x
		@y = y
	end
end

app = AppGameContainer.new(PongGame.new('RubyPong'))
app.set_display_mode(640, 480, false)
app.start
