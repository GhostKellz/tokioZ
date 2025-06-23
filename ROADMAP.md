# TokioZ Development Roadmap

## 🎯 Current Status (v0.1.0-alpha)

### ✅ **COMPLETED**
- **Project Structure**: Proper Zig package layout with build.zig
- **Core Architecture**: Runtime, task queue, reactor, timer wheel, channels, I/O abstractions
- **Cross-Platform Support**: Linux (epoll), macOS/BSD (kqueue), fallback (poll)
- **Type System**: Complete type definitions for all major components
- **Basic Functionality**: Simple runtime demonstration working
- **Documentation**: README, DOCS, and examples
- **Testing Framework**: Unit tests for core modules

### ⚠️ **IN PROGRESS**
- **Async Integration**: Currently using placeholder implementations due to Zig 0.15 async limitations
- **Event Loop**: Core reactor loop exists but needs async frame integration
- **Task Scheduling**: Task queue structure exists but needs async execution

### ❌ **TODO**

## 🗓️ Development Phases

### **Phase 1: Core Async Runtime (High Priority)**
**Target**: Working async task execution and basic I/O

#### 1.1 Async Frame Management
- [ ] Implement proper async frame handling for Zig 0.15
- [ ] Create frame pool for memory management
- [ ] Integrate with task queue for async execution
- [ ] Fix `suspend`/`resume` points in runtime

#### 1.2 Event Loop Integration
- [ ] Connect reactor polling with task scheduling
- [ ] Implement proper waker system
- [ ] Add timeout handling to main loop
- [ ] Optimize polling intervals

#### 1.3 Basic I/O Operations
- [ ] Complete TcpStream async read/write
- [ ] Complete TcpListener async accept
- [ ] Complete UdpSocket async send/recv
- [ ] Test with real network operations

**Deliverable**: Working echo server and basic async I/O

---

### **Phase 2: Enhanced Features (Medium Priority)**
**Target**: Full channel system and timer integration

#### 2.1 Channel System Completion
- [ ] Fix async send/receive operations
- [ ] Implement select-like functionality
- [ ] Add channel broadcasting
- [ ] Performance optimization

#### 2.2 Timer Integration
- [ ] Connect timer wheel with reactor
- [ ] Implement async sleep function
- [ ] Add interval timers
- [ ] High-precision timing support

#### 2.3 Task Management
- [ ] Task cancellation
- [ ] Task priorities
- [ ] Join handles with results
- [ ] Error propagation

**Deliverable**: Full channel communication and timer system

---

### **Phase 3: Advanced Features (Lower Priority)**
**Target**: Production-ready features

#### 3.1 Multi-threading Support
- [ ] Work-stealing task scheduler
- [ ] Thread-safe channel implementation
- [ ] Cross-thread task migration
- [ ] CPU affinity support

#### 3.2 I/O Uring Support (Linux)
- [ ] io_uring backend for reactor
- [ ] Zero-copy I/O operations
- [ ] Advanced file operations
- [ ] Memory-mapped files

#### 3.3 Advanced Networking
- [ ] TLS/SSL support (via zig-tls)
- [ ] HTTP/1.1 implementation
- [ ] WebSocket support
- [ ] DNS resolution

**Deliverable**: Production-ready async runtime

---

### **Phase 4: Ecosystem & Integration**
**Target**: Real-world usage and ecosystem

#### 4.1 Package Management
- [ ] Publish to Zig package manager
- [ ] Semantic versioning
- [ ] API stability
- [ ] Documentation site

#### 4.2 Real-world Applications
- [ ] HTTP server framework
- [ ] Database drivers
- [ ] Message queue implementations
- [ ] Microservice templates

#### 4.3 Performance & Benchmarks
- [ ] Comprehensive benchmarks vs Tokio
- [ ] Memory usage optimization
- [ ] Latency measurements
- [ ] Throughput testing

**Deliverable**: Ecosystem-ready package

---

## 🚧 Known Issues & Limitations

### **Current Blockers**
1. **Zig 0.15 Async**: Self-hosted compiler doesn't fully support async frames yet
2. **Suspend Points**: Need proper integration with reactor for async I/O
3. **Memory Management**: Frame allocation and cleanup needs work

### **Architecture Decisions**
1. **Single vs Multi-threaded**: Currently designed for single-threaded, will expand
2. **Memory Model**: Zero-copy where possible, controlled allocations
3. **API Design**: Tokio-inspired but Zig-idiomatic

### **Platform Support**
- ✅ **Linux**: epoll backend implemented
- ✅ **macOS/BSD**: kqueue backend implemented  
- ✅ **Others**: poll fallback implemented
- ⏳ **Windows**: IOCP support planned
- ⏳ **WASI**: WebAssembly support planned

---

## 🎯 Next Steps (Immediate)

### **Week 1-2: Async Foundation**
1. Research Zig 0.15 async frame APIs
2. Implement basic async/await functionality
3. Create minimal working echo server
4. Fix suspend/resume in reactor

### **Week 3-4: I/O Integration**
1. Complete TCP async operations
2. Test with real network clients
3. Implement proper error handling
4. Add comprehensive I/O tests

### **Month 2: Channel & Timer Systems**
1. Complete async channel operations
2. Integrate timer wheel with reactor
3. Implement select functionality
4. Performance testing and optimization

---

## 🧪 Testing Strategy

### **Unit Tests** (Current)
- ✅ Core type creation and basic operations
- ✅ Memory management (no leaks)
- ✅ API surface area validation

### **Integration Tests** (Next)
- [ ] Real async task execution
- [ ] Network I/O operations
- [ ] Channel communication
- [ ] Timer accuracy

### **Performance Tests** (Future)
- [ ] Throughput benchmarks
- [ ] Latency measurements
- [ ] Memory usage profiling
- [ ] Comparison with Tokio

---

## 📚 References & Inspiration

- **Rust Tokio**: Architecture and API design patterns
- **Zig Standard Library**: Async primitives and I/O abstractions
- **Node.js libuv**: Event loop design principles
- **Go Runtime**: Goroutine scheduling concepts

---

## 🤝 Contributing

TokioZ is designed to be the foundation for high-performance async applications in Zig. Key areas for contribution:

1. **Async Runtime**: Core task scheduling and execution
2. **I/O Systems**: Network and file operations
3. **Performance**: Optimization and benchmarking
4. **Documentation**: Examples and tutorials
5. **Testing**: Comprehensive test coverage

---

*This roadmap is living document and will be updated as the project evolves.*
