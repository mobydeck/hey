<p align="center">
  <img src="http://i.imgur.com/szzD9q0.png" alt="hey">
</p>

# hey - HTTP Load Generator

`hey` is a modern, lightweight HTTP load testing tool designed to help you benchmark and stress test your web
applications, APIs, and HTTP servers.

## Overview

`hey` sends a specified number of HTTP requests to a target URL with configurable concurrency levels, providing detailed
performance metrics and statistics. It's ideal for:

- API performance testing
- Load testing web applications
- Stress testing HTTP servers
- Benchmarking response times
- Identifying performance bottlenecks

## Installation

Download latest package from [Releases](https://github.com/mobydeck/hey/releases)

## Quick Start

```bash
hey https://example.com/
```

## Features

- Configurable request count and concurrency
- Support for HTTP/2
- Custom HTTP methods and headers
- Request body from string or file
- Rate limiting
- Request timeouts
- Basic authentication
- HTTP proxy support
- CSV output format for further analysis
- Customizable connection options

## Usage

```
hey [options...] <url>
```

### Options

| Flag | Description |
|------|-------------|
| `-n` | Number of requests to run (default: 200) |
| `-c` | Concurrent workers (default: 50) |
| `-q` | Rate limit in QPS per worker (default: no limit) |
| `-z` | Duration to send requests (e.g., `-z 10s`, `-z 3m`) |
| `-o` | Output format (`csv` or default summary) |
| `-m` | HTTP method (GET, POST, PUT, DELETE, HEAD, OPTIONS) |
| `-H` | Custom HTTP header (repeatable) |
| `-t` | Request timeout in seconds (default: 20, 0 for infinite) |
| `-A` | HTTP Accept header |
| `-d` | HTTP request body |
| `-D` | HTTP request body from file |
| `-T` | Content-type (default: "text/html") |
| `-a` | Basic authentication (username:password) |
| `-x` | HTTP proxy address (host:port) |
| `-s` | SOCKS5 proxy address (host:port) |
| `-h2` | Enable HTTP/2 |
| `-host` | HTTP Host header |
| `-disable-compression` | Disable compression |
| `-disable-keepalive` | Disable keep-alive |
| `-disable-redirects` | Disable following HTTP redirects |
| `-cpus` | Number of CPU cores to use |

### Examples

Basic use:
```bash
hey -n 1000 -c 100 https://example.com/
```

POST request with body:
```bash
hey -m POST -d '{"key":"value"}' -T "application/json" https://api.example.com/resource
```

Using HTTP/2 with custom headers:
```bash
hey -h2 -H "Authorization: Bearer token" https://api.example.com/
```

## History

`hey` came from [rakyll/hey](https://github.com/rakyll/hey) and was originally inspired by this
tool [tarekziade/boom](https://github.com/tarekziade/boom).
