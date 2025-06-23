//! TokioZ Runtime - Main async task executor and reactor loop
//! Inspired by Tokio's runtime architecture adapted for Zig

const std = @import("std");
const builtin = @import("builtin");
const task = @import("task.zig");
const reactor = @import("reactor.zig");
const timer = @import("timer.zig");

/// Main runtime configuration
pub const Config = struct {
    max_tasks: u32 = 1024,
    enable_io: bool = true,
    enable_timers: bool = true,
    thread_pool_size: ?u32 = null, // null = single-threaded
};

/// Runtime error types
pub const RuntimeError = error{
    AlreadyRunning,
    RuntimeShutdown,
    TaskSpawnFailed,
    OutOfMemory,
    SystemResourceExhausted,
};

/// Global runtime instance
var global_runtime: ?*Runtime = null;

/// Main TokioZ Runtime struct
pub const Runtime = struct {
    allocator: std.mem.Allocator,
    config: Config,
    task_queue: task.TaskQueue,
    reactor: reactor.Reactor,
    timer_wheel: timer.TimerWheel,
    running: std.atomic.Value(bool),
    shutdown_signal: std.atomic.Value(bool),

    const Self = @This();

    /// Initialize a new runtime
    pub fn init(allocator: std.mem.Allocator, config: Config) !*Self {
        const runtime = try allocator.create(Self);
        errdefer allocator.destroy(runtime);

        runtime.* = Self{
            .allocator = allocator,
            .config = config,
            .task_queue = try task.TaskQueue.init(allocator, config.max_tasks),
            .reactor = try reactor.Reactor.init(allocator),
            .timer_wheel = try timer.TimerWheel.init(allocator),
            .running = std.atomic.Value(bool).init(false),
            .shutdown_signal = std.atomic.Value(bool).init(false),
        };

        return runtime;
    }

    /// Deinitialize the runtime
    pub fn deinit(self: *Self) void {
        self.shutdown();
        self.task_queue.deinit();
        self.reactor.deinit();
        self.timer_wheel.deinit();
        self.allocator.destroy(self);
    }

    /// Set this runtime as the global runtime
    pub fn setGlobal(self: *Self) void {
        global_runtime = self;
    }

    /// Get the global runtime instance
    pub fn global() ?*Self {
        return global_runtime;
    }

    /// Main runtime loop - this is where the magic happens
    pub fn run(self: *Self, main_task: anytype) !void {
        if (self.running.swap(true, .acq_rel)) {
            return RuntimeError.AlreadyRunning;
        }
        defer self.running.store(false, .release);

        // Set as global runtime
        self.setGlobal();
        defer global_runtime = null;

        // Spawn the main task
        _ = try self.spawn(main_task);

        // Main event loop
        while (!self.shutdown_signal.load(.acquire)) {
            // Process ready tasks
            const processed_tasks = try self.task_queue.processReady();
            
            // Process timer events
            const timer_events = self.timer_wheel.processExpired();
            
            // Process I/O events (with timeout)
            const timeout_ms: i32 = if (processed_tasks > 0 or timer_events > 0) 0 else 10;
            const io_events = try self.reactor.poll(timeout_ms);

            // If no work was done, yield to prevent busy loop
            if (processed_tasks == 0 and timer_events == 0 and io_events == 0) {
                std.Thread.yield() catch {};
            }

            // Check if we have any pending work
            if (self.task_queue.isEmpty() and self.timer_wheel.isEmpty()) {
                break; // No more work to do
            }
        }
    }

    /// Spawn a new async task
    pub fn spawn(self: *Self, comptime func: anytype) !task.JoinHandle {
        return self.task_queue.spawn(func);
    }

    /// Spawn a task with custom allocator
    pub fn spawnWithAllocator(self: *Self, allocator: std.mem.Allocator, comptime func: anytype) !task.JoinHandle {
        return self.task_queue.spawnWithAllocator(allocator, func);
    }

    /// Schedule a task to run after a delay
    pub fn scheduleTimeout(self: *Self, delay_ms: u64, comptime func: anytype) !timer.TimerHandle {
        return self.timer_wheel.scheduleTimeout(delay_ms, func);
    }

    /// Request runtime shutdown
    pub fn shutdown(self: *Self) void {
        self.shutdown_signal.store(true, .release);
    }

    /// Block current task for specified duration
    pub fn sleep(self: *Self, duration_ms: u64) void {
        // This will integrate with the timer wheel
        // For now, we'll implement a simple version
        suspend {
            const handle = self.scheduleTimeout(duration_ms, struct {
                fn wake(frame: anyframe) void {
                    resume frame;
                }
            }.wake) catch return;
            _ = handle;
        }
    }
};

/// Convenience function to create and run a runtime
pub fn run(comptime main_task: anytype) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    
    const runtime = try Runtime.init(gpa.allocator(), .{});
    defer runtime.deinit();
    
    try runtime.run(main_task);
}

/// Spawn a task on the global runtime
pub fn spawn(comptime func: anytype) !task.JoinHandle {
    const runtime = Runtime.global() orelse return RuntimeError.RuntimeShutdown;
    return runtime.spawn(func);
}

/// Sleep for the specified duration (milliseconds)
pub fn sleep(duration_ms: u64) void {
    const runtime = Runtime.global() orelse return;
    runtime.sleep(duration_ms);
}

// Tests
test "runtime creation and basic operations" {
    const testing = std.testing;
    const allocator = testing.allocator;
    
    const runtime = try Runtime.init(allocator, .{});
    defer runtime.deinit();
    
    try testing.expect(!runtime.running.load(.acquire));
    try testing.expect(!runtime.shutdown_signal.load(.acquire));
}

test "global runtime" {
    const testing = std.testing;
    const allocator = testing.allocator;
    
    const runtime = try Runtime.init(allocator, .{});
    defer runtime.deinit();
    
    runtime.setGlobal();
    try testing.expect(Runtime.global() == runtime);
}
