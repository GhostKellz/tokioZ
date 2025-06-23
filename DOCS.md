# Zig Async Runtime Inspired by Tokio: GitHub Copilot Prompt

## 🎯 Goal:

Develop a modern, performant async runtime in **Zig**, inspired by **Tokio** in Rust. This project aims to bring Tokio-style ergonomics, task scheduling, and async IO to the Zig ecosystem.

## 🔍 Overview:

We want to build a comprehensive async runtime for Zig that:

* Uses Zig's built-in `async` primitives and fibers
* Implements a cooperative task scheduler (single-threaded or multi-threaded)
* Integrates with `epoll`/`kqueue`/`poll` for IO readiness
* Provides high-level abstractions like:

  * `spawn(fn)`
  * `sleep(ms)`
  * `join!()`
  * `select!()`
  * `channel<T>()`
* Optionally exposes FFI-compatible bindings for Rust interoperability (e.g., Tokio interop)

## 📦 Core Modules to Implement:

### 1. `runtime.zig`

* Entry point for task executor
* Main reactor loop
* Task registry

### 2. `task.zig`

* Task struct with fiber state
* State transitions (pending, ready, finished)
* Waker support

### 3. `reactor.zig`

* Event loop using `epoll` (Linux), `kqueue` (BSD/macOS), `poll` (fallback)
* Readiness event polling
* Timer queue integration

### 4. `channel.zig`

* Async channel (bounded/unbounded)
* Based on ring buffer or mutex/condvar if needed
* Inspired by `tokio::sync::mpsc`

### 5. `timer.zig`

* Timer wheel or min-heap
* `async sleep(duration)`
* Integration with event loop tick

### 6. `io.zig`

* Non-blocking TCP/UDP socket support
* File descriptor registration
* Integration with poll-based readiness

### 7. `ffi.zig` *(Optional)*

* C ABI wrappers for select async functions
* Intended for use with Rust or other languages

## 💡 Key Features:

* `spawn(async fn)` support for concurrent task execution
* `await`-safe sleep and IO
* Zero-cost cooperative scheduling
* Non-blocking IO using system-native polling
* Minimal heap usage, with static dispatch wherever possible
* Tokio-style API surface adapted for Zig idioms

## 🚀 Future Goals:

* Multi-core task executor
* WASI support for async IO
* HTTP/HTTPS abstraction (like hyper)
* Integration with Zig build system (as a package)
* Benchmarks and real-world application demos (file servers, proxies)

---

This KB defines the architecture, design goals, and starter prompt for building a full-featured Zig async runtime. Ideal for Copilot, GPT-4, or any code-gen LLM.

Let me know when you're ready to scaffold the repo or want to generate the core files automatically.

