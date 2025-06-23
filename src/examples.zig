//! Example implementations and usage patterns for TokioZ

const std = @import("std");
const tokioz = @import("root.zig");

/// Simple echo server example
pub fn echoServer(port: u16) !void {
    const address = std.net.Address.parseIp4("127.0.0.1", port) catch unreachable;
    
    const listener = try tokioz.io.TcpListener.bind(address);
    defer listener.close();
    
    std.debug.print("Echo server listening on port {}\n", .{port});
    
    while (true) {
        const stream = try listener.accept();
        
        // Spawn a task to handle the connection
        _ = try tokioz.spawn(async handleEchoClient(stream));
    }
}

/// Handle a single echo client
fn handleEchoClient(stream: tokioz.io.TcpStream) !void {
    defer stream.close();
    
    var buffer: [1024]u8 = undefined;
    
    while (true) {
        const bytes_read = stream.read(&buffer) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        
        if (bytes_read == 0) break;
        
        try stream.writeAll(buffer[0..bytes_read]);
    }
}

/// HTTP-like server example
pub fn httpServer(port: u16) !void {
    const address = std.net.Address.parseIp4("127.0.0.1", port) catch unreachable;
    
    const listener = try tokioz.io.TcpListener.bind(address);
    defer listener.close();
    
    std.debug.print("HTTP server listening on port {}\n", .{port});
    
    while (true) {
        const stream = try listener.accept();
        
        // Spawn a task to handle the HTTP request
        _ = try tokioz.spawn(async handleHttpRequest(stream));
    }
}

/// Handle a single HTTP request
fn handleHttpRequest(stream: tokioz.io.TcpStream) !void {
    defer stream.close();
    
    var buffer: [4096]u8 = undefined;
    const bytes_read = try stream.read(&buffer);
    
    // Simple HTTP response
    const response = 
        \\HTTP/1.1 200 OK
        \\Content-Type: text/plain
        \\Content-Length: 25
        \\Connection: close
        \\
        \\Hello from TokioZ server!
    ;
    
    try stream.writeAll(response);
    
    // Log the request
    std.debug.print("Handled request: {s}\n", .{buffer[0..@min(bytes_read, 100)]});
}

/// Timer-based task example
pub fn timerExample() !void {
    std.debug.print("Starting timer example...\n", .{});
    
    // Schedule some timers
    const timer1 = try tokioz.timer.scheduleTimeout(1000, printMessage1);
    const timer2 = try tokioz.timer.scheduleTimeout(2000, printMessage2);
    const timer3 = try tokioz.timer.scheduleTimeout(3000, printMessage3);
    
    // Wait a bit
    tokioz.sleep(4000);
    
    // Cancel unused timers
    timer1.cancel();
    timer2.cancel();
    timer3.cancel();
    
    std.debug.print("Timer example completed.\n", .{});
}

fn printMessage1() void {
    std.debug.print("Timer 1 expired!\n", .{});
}

fn printMessage2() void {
    std.debug.print("Timer 2 expired!\n", .{});
}

fn printMessage3() void {
    std.debug.print("Timer 3 expired!\n", .{});
}

/// Channel communication example
pub fn channelExample() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    std.debug.print("Starting channel example...\n", .{});
    
    // Create a bounded channel
    const ch = try tokioz.bounded(i32, allocator, 10);
    defer {
        ch.channel.deinit();
        allocator.destroy(ch.channel);
    }
    
    // Spawn producer task
    _ = try tokioz.spawn(async producer(ch.sender));
    
    // Spawn consumer task
    _ = try tokioz.spawn(async consumer(ch.receiver));
    
    // Let them run for a bit
    tokioz.sleep(5000);
    
    std.debug.print("Channel example completed.\n", .{});
}

fn producer(sender: tokioz.channel.Sender(i32)) !void {
    for (0..10) |i| {
        try sender.send(@intCast(i));
        std.debug.print("Sent: {}\n", .{i});
        tokioz.sleep(500);
    }
    sender.close();
}

fn consumer(receiver: tokioz.channel.Receiver(i32)) !void {
    while (true) {
        const value = receiver.recv() catch |err| switch (err) {
            tokioz.channel.ChannelError.ChannelClosed => break,
            else => return err,
        };
        std.debug.print("Received: {}\n", .{value});
    }
}

/// Concurrent task example
pub fn concurrentExample() !void {
    std.debug.print("Starting concurrent example...\n", .{});
    
    // Spawn multiple concurrent tasks
    const task1 = try tokioz.spawn(async countTask("Task-1", 5));
    const task2 = try tokioz.spawn(async countTask("Task-2", 3));
    const task3 = try tokioz.spawn(async countTask("Task-3", 7));
    
    // Wait for tasks to complete
    try task1.join();
    try task2.join();
    try task3.join();
    
    std.debug.print("Concurrent example completed.\n", .{});
}

fn countTask(name: []const u8, count: u32) !void {
    for (0..count) |i| {
        std.debug.print("{s}: {}\n", .{ name, i });
        tokioz.sleep(1000);
    }
}

/// UDP client/server example
pub fn udpExample() !void {
    std.debug.print("Starting UDP example...\n", .{});
    
    // Start UDP server
    _ = try tokioz.spawn(async udpServer());
    
    // Give server time to start
    tokioz.sleep(100);
    
    // Start UDP client
    _ = try tokioz.spawn(async udpClient());
    
    // Let them run
    tokioz.sleep(3000);
    
    std.debug.print("UDP example completed.\n", .{});
}

fn udpServer() !void {
    const address = std.net.Address.parseIp4("127.0.0.1", 8080) catch unreachable;
    const socket = try tokioz.io.UdpSocket.bind(address);
    defer socket.close();
    
    std.debug.print("UDP server listening on port 8080\n", .{});
    
    var buffer: [1024]u8 = undefined;
    
    while (true) {
        const result = try socket.recvFrom(&buffer);
        std.debug.print("UDP server received: {s} from {}\n", .{ buffer[0..result.bytes], result.address });
        
        // Echo back
        _ = try socket.sendTo(buffer[0..result.bytes], result.address);
    }
}

fn udpClient() !void {
    const local_addr = std.net.Address.parseIp4("127.0.0.1", 0) catch unreachable;
    const server_addr = std.net.Address.parseIp4("127.0.0.1", 8080) catch unreachable;
    
    const socket = try tokioz.io.UdpSocket.bind(local_addr);
    defer socket.close();
    
    const messages = [_][]const u8{ "Hello", "World", "from", "TokioZ!" };
    
    for (messages) |msg| {
        _ = try socket.sendTo(msg, server_addr);
        std.debug.print("UDP client sent: {s}\n", .{msg});
        
        var buffer: [1024]u8 = undefined;
        const result = try socket.recvFrom(&buffer);
        std.debug.print("UDP client received: {s}\n", .{buffer[0..result.bytes]});
        
        tokioz.sleep(500);
    }
}
