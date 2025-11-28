const rl = @import("raylib");

const Rectangle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,

    pub fn intersects(self: Rectangle, other: Rectangle) bool {
        return self.x < other.x + other.width and
            self.x + self.width > other.x and
            self.y < other.y + other.height and
            self.y + self.height > other.y;
    }
};

const Bullet = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    active: bool,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .speed = 10.0,
            .active = false,
        };
    }

    pub fn update(self: *@This()) void {
        if (self.active) {
            self.position_y -= self.speed;
            if (self.position_y < 0) {
                self.active = false;
            }
        }
    }

    pub fn draw(self: @This()) void {
        if (self.active) {
            rl.drawRectangle(
                @intFromFloat(self.position_x),
                @intFromFloat(self.position_y),
                @intFromFloat(self.width),
                @intFromFloat(self.height),
                rl.Color.red,
            );
        }
    }
};

const Player = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .speed = 5.0,
        };
    }

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }

    pub fn draw(self: @This()) void {
        rl.drawRectangle(
            @intFromFloat(self.position_x),
            @intFromFloat(self.position_y),
            @intFromFloat(self.width),
            @intFromFloat(self.height),
            rl.Color.blue,
        );
    }

    pub fn update(self: *@This()) void {
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            self.position_x += self.speed;
        }

        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            self.position_x -= self.speed;
        }

        if (self.position_x < 0) {
            self.position_x = 0;
        }

        if (self.position_x + self.width > @as(f32, @floatFromInt(rl.getScreenWidth()))) {
            self.position_x = @as(f32, @floatFromInt(rl.getScreenWidth())) - self.width;
        }
    }
};

const Invader = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    alive: bool,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .speed = 5.0,
            .alive = true,
        };
    }

    pub fn draw(self: @This()) void {
        rl.drawRectangle(
            @intFromFloat(self.position_x),
            @intFromFloat(self.position_y),
            @intFromFloat(self.width),
            @intFromFloat(self.height),
            rl.Color.green,
        );
    }
};

const GameConfig = struct {
    screenWidth: i32,
    screenHeight: i32,
    playerWidth: f32,
    playerHeight: f32,
    playerStartY: f32,
    bulletWidth: f32,
    bulletHeight: f32,
    shieldStartX: f32,
    shieldY: f32,
    shieldWidth: f32,
    shieldHeight: f32,
    shieldSpacing: f32,
    invaderStartX: f32,
    invaderStartY: f32,
    invaderWidth: f32,
    invaderHeight: f32,
    invaderSpacingX: f32,
    invaderSpacingY: f32,
};

pub fn main() void {
    const screenWidth = 800;
    const screenHeight = 600;
    const maxBullets = 10;
    const bulletWidth = 4.0;
    const bulletHeight = 10.0;
    const invaderRows = 5;
    const invaderCols = 11;
    const invaderWidth = 40.0;
    const invaderHeight = 30.0;
    const invaderStartX = 100.0;
    const invaderStartY = 50.0;
    const invaderSpacingX = 60.0;
    const invaderSpacingY = 40.0;

    rl.initWindow(screenWidth, screenHeight, "Zig Invaders");
    defer rl.closeWindow();

    const playerWidth = 50.0;
    const playerHeight = 30.0;

    var player = Player.init(
        @as(f32, @floatFromInt(screenWidth)) / 2 - playerWidth / 2,
        @as(f32, @floatFromInt(screenHeight)) - 60.0,
        playerWidth,
        playerHeight,
    );

    var bullets: [maxBullets]Bullet = undefined;
    for (&bullets) |*bullet| {
        bullet.* = Bullet.init(0, 0, bulletWidth, bulletHeight);
    }

    var invaders: [invaderRows][invaderCols]Invader = undefined;
    for (&invaders, 0..) |*row, i| {
        for(row, 0..) |*invader, j| {
            const x = invaderStartX + @as(f32, @floatFromInt(j)) * invaderSpacingX;
            const y = invaderStartY + @as(f32, @floatFromInt(i)) * invaderSpacingY;
            invader.* = Invader.init(x, y, invaderWidth, invaderHeight);
        }
    }

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);
        player.update();
        if (rl.isKeyPressed(rl.KeyboardKey.space)) {
            for (&bullets) |*bullet| {
                if (!bullet.active) {
                    bullet.position_x = player.position_x + player.width/2 - bullet.width/2;
                    bullet.position_y = player.position_y;
                    bullet.active = true;
                    break;
                }
            }
        }

        for (&bullets) |*bullet| {
            bullet.update();
        }

        player.draw();

        for (&bullets) |*bullet| {
            bullet.draw();
        }

        for (&invaders) |*row| {
            for (row) |*invader| {
                invader.draw();
            }
        }

        rl.drawText("Zig Invaders", 250, 250, 40, rl.Color.green);
    }
}
