lg = love.graphics;
lk = love.keyboard;
la = love.audio;
colors = require("colors");
vec = require("vector");
screen_w = 600;
screen_h = 600;
phase = 3;

local move_sound = la.newSource("move.wav", "static");
local place_sound = la.newSource("place.wav", "static");
local remove_sound = la.newSource("remove.wav", "static");

local Grid = require("ConwayGrid");

local players = {};

local step_timer = 0;
local threshold = 0.1;
local num_steps = 0;

local true_pos = vec(0, 0);
local spd = 2.5;

local font = lg.newFont("editundo.ttf", 30);

local directions = {left = vec(-1,0), right = vec(1, 0), up = vec(0, -1), down = vec(0, 1)};

local turn_player = 1;
local not_turn_player = 2;
local turn_count = 0;

local instructions = true;

function love.load()
	lg.setBackgroundColor(colors.gray);
	lg.setFont(font);
	Grid:init(30, 25, 20);
	players[1] = {life = 20, strife = 5, pos = vec(3, 12)};
	players[2] = {life = 20, strife = 5, pos = vec(Grid.w - 2, 12)};
	love.keyboard.setKeyRepeat(true);
	lg.setPointSize(5);
	
	
end

function restart()
	players[1] = {life = 20, strife = 5, pos = vec(3, 12)};
	players[2] = {life = 20, strife = 5, pos = vec(Grid.w - 2, 12)};
	Grid:clear();
	turn_count = 0;
	turn_player = 1;
	enter_phase_one();
end


function love.update(dt)
	if phase == 2 then
		step_timer = step_timer + dt;
		if step_timer > threshold then
			step_timer = 0;
			num_steps = num_steps + 1;
			Grid:step();
			if Grid:check_collision(players[turn_player].pos) then
				players[turn_player].life = players[turn_player].life - 1;
			end
			
			if Grid:check_collision(players[not_turn_player].pos) then
				players[not_turn_player].life = players[not_turn_player].life - 1;
			end
		end
		
		if num_steps > 39 then
			if turn_player == 1 then 
				turn_player = 2;
				not_turn_player = 1;
			elseif turn_player == 2 then 
				turn_player = 1; 
				not_turn_player = 2;
			end 
			players[1].life = math.max(0, players[1].life);
			players[2].life = math.max(0, players[2].life);
			if players[1].life * players[2].life == 0 then
				phase = 3;
			else
				enter_phase_one();
			end
		end
		
		if lk.isDown("up") then
			true_pos = true_pos + directions.up * spd;
		end
		if lk.isDown("down") then
			true_pos = true_pos + directions.down * spd;
		end
		if lk.isDown("left") then
			true_pos = true_pos + directions.left * spd;
		end
		if lk.isDown("right") then
			true_pos = true_pos + directions.right * spd;
		end
		
		true_pos.x = clamp(0, true_pos.x, screen_w - 0.5);
		true_pos.y = clamp(Grid.y, true_pos.y, screen_h - 0.5);
		if phase == 2 then
			players[not_turn_player].pos.x = math.floor(true_pos.x / Grid.cell_sz) + 1;
			players[not_turn_player].pos.y = math.floor((true_pos.y - Grid.y) / Grid.cell_sz) + 1;
		end
	end
end

function love.draw()
	
	Grid:draw();
	
	draw_players();
	if phase == 1 then
		Grid:draw_cursor();
		Grid:draw_cursor_limits();
	end
	draw_ui();
	
	if instructions then
		draw_instructions();
	end
end

function draw_ui()
	for i = 0, 19 do
		lg.setColor(colors.black);
		if i <= players[1].life - 1 then
			lg.setColor(colors.cyan);
		end
		
		lg.rectangle("fill", i * 12.5, 0, 12.5 - 2, 50 - 2);
	end
	
	for i = 0, 19 do
		lg.setColor(colors.black);
		if i <= players[2].life - 1 then
			lg.setColor(colors.cyan);
		end	
		lg.rectangle("fill", screen_w - i * 12.5 , 0, 12.5 - 2, 50 -2);
	end
	
	for i = 0, 19 do
		lg.setColor(colors.black);
		if i <= players[1].strife - 1 then
			lg.setColor(colors.magenta);
		end	
		lg.rectangle("fill", i * 12.5, 50, 12.5 - 2, 50 - 2);
	end
	for i = 0, 19 do
		lg.setColor(colors.black);
		if i <= players[2].strife - 1 then
			lg.setColor(colors.magenta);
		end	
		lg.rectangle("fill", screen_w - i * 12.5, 50, 12.5 - 2, 50 - 2);
	end
	
	lg.setColor(colors.white);
	lg.print("P1 Life", 10, 13);
	lg.print("P1 Strife", 10, 55);
	lg.print("P2 Life", screen_w - font:getWidth("P2 Life") - 10, 13);
	lg.print("P2 Strife", screen_w - font:getWidth("P2 Strife") - 10, 55);
	
	lg.setColor(colors.black);
	lg.print("Gen: "..num_steps, screen_w / 2 - 40 , 0);
	lg.print("Trn: "..turn_count, screen_w / 2 - 40 , 25);
	lg.print("Phs: "..phase, screen_w / 2 - 40 , 50);
	
	lg.setColor(colors.black)
	if turn_player == 1 then
		lg.setColor(colors.green);
	end
	lg.polygon("fill", 298, 80, 298, 98, 280, 89);
	
	lg.setColor(colors.black)
	if turn_player == 2 then
		lg.setColor(colors.green);
	end
	lg.polygon("fill", 302, 80, 302, 98, 320, 89);
	
	if phase == 3 then
		lg.setColor(0,0,0,200);
		lg.rectangle("fill", 0, 0, 600, 600);
		lg.setColor(colors.white);
		lg.print("Press any key to play again", screen_w / 2 - font:getWidth("Press any key to play again") / 2,
						screen_h / 2);
	end
end

function draw_players()
	lg.setColor(255,0,0,128);
	lg.rectangle("line", (players[1].pos.x - 1) * Grid.cell_sz, 
								Grid.y + (players[1].pos.y - 1) * Grid.cell_sz,
								Grid.cell_sz - 1,
								Grid.cell_sz - 1);
								
	lg.setColor(0,0,255,128);
	lg.rectangle("line", (players[2].pos.x - 1) * Grid.cell_sz, 
								Grid.y + (players[2].pos.y - 1) * Grid.cell_sz,
								Grid.cell_sz - 1,
								Grid.cell_sz - 1);
	lg.setColor(colors.red);
	--lg.points(true_pos.x, true_pos.y);
end

function love.keypressed(k)
	if k == "escape" then
		love.event.push("quit");
	elseif phase == 1 then
		if k == "left" or k == "right" or k == "up" or k == "down" then
			Grid:move_cursor(directions[k]);
			move_sound:play();
		elseif k == "z" then
			if (not Grid:return_at_cursor() and players[turn_player].strife > 0 
						and players[1].pos ~= Grid.cursor and players[2].pos ~= Grid.cursor) then
				Grid:toggle();
				players[turn_player].strife = players[turn_player].strife - 1;
				place_sound:play();
			elseif Grid:return_at_cursor() and players[turn_player].strife < 20 then
				Grid:toggle();
				players[turn_player].strife = players[turn_player].strife + 1;
				remove_sound:play();
			end
		elseif k == "space" then
			enter_phase_two();
		end
	elseif phase == 2 and k == "z" and players[not_turn_player].strife >= 3 then
		players[not_turn_player].strife = players[not_turn_player].strife - 3;
		local res = Grid:laser_check(players[turn_player].pos, players[not_turn_player].pos);
		if res then
			players[turn_player].life = players[turn_player].life - 3;
		end
	elseif phase == 3 then
		instructions = false;
		restart();
	end
end


function enter_phase_one()
	phase = 1;
	turn_count = turn_count + 1;
	players[turn_player].strife = players[turn_player].strife + 5;
	players[turn_player].strife = math.min(players[turn_player].strife, 20);
	Grid:set_cursor_limits(turn_player, turn_count);
	Grid:set_cursor_pos(players[turn_player].pos);
end

function enter_phase_two()
	phase = 2;
	num_steps = 0;
	step_timer = 0;
	true_pos.x, true_pos.y = (players[not_turn_player].pos.x * Grid.cell_sz) - 1, 
										(Grid.y + players[not_turn_player].pos.y * Grid.cell_sz) -1;
end

function draw_instructions()
	lg.setColor(colors.white);
	lg.rectangle("fill", 100, 120, 400, 480);
	lg.setColor(colors.black);
	local lines_tbl = {"-Instructions-", "Turn player places blocks", "then the other avoids them",
								"for 40 Conway generations.", "Conway organisms", "damage players.",
								"-Controls-", "=Turn player=","Arrow keys and z to place", "space to proceed",
								"=Other player=", "Arrow keys and z to laser", "blocks and lasers", "cost strife"};
	
	for i,v in ipairs(lines_tbl) do
		lg.print(v, screen_w / 2 - font:getWidth(v) / 2, 120 + i * 30)
	end
end
function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end