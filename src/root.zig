//! TokioZ - Asynchronous Runtime for Zig
//! Inspired by Rust's Tokio, adapted for Zig's async model

const std = @import("std");

// Export core modules
pub const runtime = @import("runtime.zig");
pub const task = @import("task.zig");
pub const reactor = @import("reactor.zig");
pub const timer = @import("timer.zig");
pub const channel = @import("channel.zig");
pub const io = @import("io.zig");
pub const examples = @import("examples.zig");
pub const simple = @import("simple.zig");
pub const scheduler = @import("scheduler.zig");
pub const event_loop = @import("event_loop.zig");
pub const zquic_integration = @import("zquic_integration.zig");
pub const async_runtime = @import("async_runtime.zig");

// Re-export commonly used types and functions
pub const Runtime = runtime.Runtime;
pub const TaskQueue = task.TaskQueue;
pub const JoinHandle = task.JoinHandle;
pub const Waker = task.Waker;
pub const Reactor = reactor.Reactor;
pub const TimerWheel = timer.TimerWheel;
pub const TimerHandle = timer.TimerHandle;
pub const AsyncScheduler = scheduler.AsyncScheduler;
pub const EventLoop = event_loop.EventLoop;
pub const TaskPriority = scheduler.TaskPriority;
pub const AsyncRuntime = async_runtime.AsyncRuntime;
pub const TaskHandle = async_runtime.TaskHandle;
pub const Sleep = async_runtime.Sleep;

// Convenience functions
pub const run = runtime.run;
pub const runHighPerf = runtime.runHighPerf;
pub const runIoFocused = runtime.runIoFocused; // Perfect for zquic!
pub const spawn = runtime.spawn;
pub const spawnUrgent = runtime.spawnUrgent;
pub const spawnAsync = runtime.spawnAsync; // New async spawn with TaskHandle
pub const sleep = runtime.sleep;
pub const asyncSleep = runtime.asyncSleep; // True async sleep
pub const blockOn = runtime.blockOn; // Block on async function
pub const registerIo = runtime.registerIo;
pub const getStats = runtime.getStats;

// Global async runtime functions
pub const globalSpawn = async_runtime.spawn;
pub const globalSleep = async_runtime.sleep;
pub const yieldNow = async_runtime.yield_now;

// Channel creation functions
pub const bounded = channel.bounded;
pub const unbounded = channel.unbounded;
pub const oneshot = channel.OneShot;

// High-level API for easy usage
pub fn init(allocator: std.mem.Allocator) !*Runtime {
    return Runtime.init(allocator, .{});
}

pub fn defaultRuntime(comptime main_task: anytype) !void {
    try run(main_task);
}

// Legacy function for compatibility
pub fn advancedPrint() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("TokioZ async runtime initialized!\n", .{});
    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush();
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try std.testing.expect(add(3, 7) == 10);
}

test "tokioz runtime creation" {
    const testing = std.testing;
    const allocator = testing.allocator;
    
    const rt = try init(allocator);
    defer rt.deinit();
    
    try testing.expect(!rt.running.load(.acquire));
}

test "tokioz exports" {
    // Test that our exports are accessible
    const testing = std.testing;
    
    // Test runtime types
    const RuntimeType = @TypeOf(Runtime);
    _ = RuntimeType;
    
    // Test functions exist
    const run_func = run;
    _ = run_func;
    
    const spawn_func = spawn;
    _ = spawn_func;
    
    try testing.expect(true);
}
