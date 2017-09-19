local ConwayGrid = {};

function ConwayGrid:init(w, h, c)	
	self.w = w;
	self.h = h;
	self.cell_sz = c;
	
	self.clamp_left = 1;
	self.clamp_right = self.w;
	
	self.y = screen_h - self.h * self.cell_sz;
	
	self.cursor = vec(1,1);
	
	self.grid = {};
	for y = 1, self.h do
		self.grid[y] = {}
		for x = 1, self.w do
				self.grid[y][x] = false;
		end
	end
end

function ConwayGrid:clear()
	for y = 1, self.h do
		for x = 1, self.w do
				self.grid[y][x] = false;
		end
	end
end

function ConwayGrid:step()
	local nextGrid = {};
	for y = 1, self.h do
		nextGrid[y] = {};
		for x= 1, self.w do
			local n_count = 0;
			
			for dy = -1, 1 do
				for dx = -1, 1 do
					if not (dy == 0 and dx == 0) and self.grid[y + dy] and self.grid[y + dy][x + dx] then
						n_count = n_count + 1;
					end -- if spot exists and is true
				end -- adjacent cols
			end -- adjacent rows
			
			nextGrid[y][x] = (n_count == 3) or (self.grid[y][x] and n_count == 2);
		end -- all cols
	end -- all rows
	
	self.grid = nextGrid;
end

function ConwayGrid:draw()
	for y = 1, self.h do
		for x = 1, self.w do
			lg.setColor(colors.white);
			if self.grid[y][x] then
				lg.setColor(colors.magenta);
			end
			lg.rectangle("fill", (x - 1) * self.cell_sz, 
										self.y + (y - 1) * self.cell_sz, 
										self.cell_sz - 1, 
										self.cell_sz - 1);
		end
	end
end

function ConwayGrid:draw_cursor()
	lg.setColor(colors.green);
	lg.rectangle("line", (self.cursor.x - 1) * self.cell_sz, 
								self.y + (self.cursor.y - 1) * self.cell_sz,
								self.cell_sz - 1,
								self.cell_sz - 1);
end

function ConwayGrid:return_at_cursor()
	return self.grid[self.cursor.y][self.cursor.x]
end

function ConwayGrid:set_cursor_pos(v)
	self.cursor = v:clone();
end

function ConwayGrid:move_cursor(dir)
	self.cursor = self.cursor + dir;
	self.cursor.x = clamp(self.clamp_left, self.cursor.x, self.clamp_right);
	self.cursor.y = clamp(1, self.cursor.y, self.h);
	--print(self.cursor.x .. "\t" .. self.cursor.y);
end

function ConwayGrid:toggle()
	self.grid[self.cursor.y][self.cursor.x] = not self.grid[self.cursor.y][self.cursor.x];
end

function ConwayGrid:check_collision(v)
	return self.grid[v.y][v.x];
end

function ConwayGrid:set_cursor_limits(player_num, turn)
	if player_num == 1 then
		self.clamp_left = 1;
		self.clamp_right = math.min(6 + (turn - 1) * 2,30);
	elseif player_num == 2 then
		self.clamp_left = math.max(1, 25 - (turn - 1) * 2);
		self.clamp_right = self.w;
	end
end

function ConwayGrid:draw_cursor_limits()
	lg.setColor(248,255,18,128);
	for y = 1, self.h do
		for x = self.clamp_left, self.clamp_right do
			lg.rectangle("fill", (x - 1) * self.cell_sz, 
										self.y + (y - 1) * self.cell_sz, 
										self.cell_sz - 1, 
										self.cell_sz - 1);
		end
	end
end

function ConwayGrid:laser_check(t_pos, nt_pos)
	local res = true;
	if t_pos.y ~= nt_pos.y then
		res = false;
	end
	local smaller = math.min(t_pos.x, nt_pos.x);
	local larger = math.max(t_pos.x, nt_pos.x);
	for i = smaller, larger do
		if self.grid[t_pos.y][i] == true then
			res = false;
		end
	end
	
	return res;
end


return ConwayGrid;
