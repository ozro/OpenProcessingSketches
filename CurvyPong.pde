var paddle_w = 10;
var paddle_h = 40;
var paddle_x = 50;
var ball_r = 5;

var ball_vx_max = 300;

var rally_boost = 10;
var friction = 1;
var spin_factor = 0.5;
var spin_boost = 5;
var spin_decay = 1;

var w = 800;
var h = 500;
var fps = 60;

var paddle_speed = 15;

class Game {
		constructor(x, y, w, h, diff){
			//Player 1 parameters
			this.x1 = x + paddle_x;
			this.y1 = y + h / 2;
			this.v1 = 0;
			//Player 2 parameters
			this.x2 = x + w - paddle_x;
			this.y2 = y + h / 2;
			this.v2 = 0;
			//Ball parameters
			this.bx = x + w / 2;
			this.by = y + h / 2;
			this.bvx = 0;
			this.bvy = 0;
			this.spin = 0;
			//Game parameters
			this.score1 = 0;
			this.score2 = 0;
			this.rally = 0;
			this.diff = diff;
			//Render parameters
			this.x = x;
			this.y = y;
			this.w = w;
			this.h = h;
		}
    
    reset() {
        this.score1 = 0;
        this.score2 = 0;
    }
    
    start() {
        this.bx = this.x + this.w / 2;
        this.by = this.y + this.h / 2;
        this.bvx = ball_vx_max * (1 - 2 * Math.round(random(0, 1))) * this.diff;
        this.bvy = this.bvx * (random() * 2 - 1);
        this.rally = 0;
        this.spin = 0;
    }
    
    update(v1, v2, dt) {
        //Update ball
        this.bx += this.bvx * dt;
        this.by += this.bvy * dt;
        if (this.bvx > 0) {
            this.bvy -= this.spin * spin_factor;
        } else {
            this.bvy += this.spin * spin_factor;
        }
        this.spin *= spin_decay;

        //Update paddle velocities
        this.v1 = v1;
        this.v2 = v2;

        //Update paddle positions
        this.y1 += this.v1;
        this.y2 += this.v2;
        if (this.y1 - paddle_h / 2 < this.y) {
            this.y1 = this.y + paddle_h / 2;
            this.v1 = 0;
        } else if (this.y1 + paddle_h / 2 > this.y + this.h) {
            this.y1 = this.y + this.h - paddle_h / 2;
            this.v1 = 0;
        }
        if (this.y2 - paddle_h / 2 < this.y) {
            this.y2 = this.y + paddle_h / 2;
            this.v2 = 0;
        } else if (this.y2 + paddle_h / 2 > this.y + this.h) {
            this.y2 = this.y + this.h - paddle_h / 2;
            this.v2 = 0;
        }

        //Top and bottom collision
        if (((this.by - ball_r < this.y) && (this.bvy < 0)) ||
                ((this.by + ball_r > this.h + this.y) && (this.bvy > 0))) {
            this.bvy *= -1;
            this.bvy += this.spin;
            if (this.bvx > 0) {
                this.bvx += Math.abs(this.spin) * spin_boost;
            } else {
                this.bvx -= Math.abs(this.spin) * spin_boost;
            }
            this.spin *= 0.5;
        }

        // Left collision
        if ((this.bx - ball_r < this.x + paddle_x + paddle_w / 2) &&
                  (this.bx > this.x + paddle_x)) {
            if ((this.by + ball_r >= this.y1 - paddle_h / 2) &&
                    (this.by - ball_r <= this.y1 + paddle_h / 2) && (this.bvx < 0)) {
                this.bvx *= -1;
                this.bvx += rally_boost;
								this.spin *= 0.5;
                this.spin += this.v1 * this.diff;
                this.bvy += this.v1 * friction;
                this.rally += 1;
            }
        }

        // Right collision
        else if (this.bx + ball_r > this.x + this.w - paddle_x - paddle_w / 2 &&
             this.bx < this.x + this.w - paddle_x) {
            if(this.by+ball_r >= this.y2-paddle_h/2 &&
               this.by-ball_r <= this.y2+paddle_h/2 && this.bvx > 0) {
                this.bvx *= -1;
                this.bvx -= rally_boost;
								this.spin *= 0.5;
                this.spin -= this.v2 * this.diff;
                this.bvy += this.v2 * friction;
                this.rally += 1;
            }
        }
        
        // Check scoring
        if(this.bx < this.x) {
            this.score2 += 1
            this.start();
            if(this.score2 > 9) {
                this.reset();
            }
        }
        else if(this.bx > this.x + this.w){
            this.score1 += 1;
            this.start();
            if(this.score1 > 9){
                this.reset();
            }
				}
				
				rect(this.bx-ball_r, this.by-ball_r, ball_r*2, ball_r*2);
				rect(this.x1-paddle_w/2,this.y1-paddle_h/2, paddle_w, paddle_h);
				rect(this.x2-paddle_w/2,this.y2-paddle_h/2, paddle_w, paddle_h);
    }
}

var game;

function setup() {
    createCanvas(w, h);
    frameRate(fps);
    game = new Game(0, 0, w, h, 1);
    fill(255);
		stroke(255);
		game.start();
		background([0,0,0,1])
}

var c;
var vel1 = 0;
var vel2 = 0;
var p1u = false;
var p1d = false;
var p2u = false;
var p2d = false;
var z = 0;
function draw() {
    if(game.spin > 0){
        c = [Math.min(Math.abs(game.spin)/50*255,255), 0, 0, 50];
    }
    else {
        c = [0, 0, Math.min(Math.abs(game.spin)/50*255,255), 50];
    }

    background(c);
		var desired1 = 0;
    var desired2 = 0;
    if(p1u){
        desired1 = -paddle_speed;
    }
    else if(p1d){
        desired1 = paddle_speed;
    }
    if(p2u){
        desired2 = -paddle_speed;
    }
    else if(p2d){
        desired2 = paddle_speed;
    }
    vel1 += (desired1 - vel1)/2;
    vel2 += (desired2 - vel2)/2;
		vel2 += (game.by - game.y2)/5;

    game.update(vel1, vel2, 1/fps);
}

function keyPressed() {
    if (keyCode == 87) {
        p1u = true;
    } else if (keyCode == 83) {
        p1d = true;
    }
    if (keyCode == 73) {
        p2u = true;
    } else if (keyCode == 75) {
        p2d = true;
    }
}

function keyReleased() {
    if (keyCode === 87) {
        p1u = false;
    } else if (keyCode === 83) {
        p1d = false;
    }
    if (keyCode == 73) {
        p2u = false;
    } else if (keyCode == 75) {
        p2d = false;
    }
}
