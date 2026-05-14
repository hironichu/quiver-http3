# quiver-http3

HTTP/3, QPACK, and server-side WebTransport implementation for Quiver. This package builds on `quiver-quic` and provides the HTTP/3 connection, client, server, stream, settings, frame, Extended CONNECT, and WebTransport session machinery.

## Products

| Product | Purpose |
| --- | --- |
| `QPACK` | QPACK encoder, decoder, integer/string codecs, Huffman codec, and static table support. |
| `HTTP3` | HTTP/3 client/server APIs, connection management, frame codecs, request/response types, priority handling, Extended CONNECT, and WebTransport implementation. |

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
	.package(url: "https://github.com/hironichu/quiver-http3.git", branch: "main")
]
```

Then depend on the products you need:

```swift
.target(
	name: "MyTarget",
	dependencies: [
		.product(name: "HTTP3", package: "quiver-http3"),
		.product(name: "QPACK", package: "quiver-http3"),
	]
)
```

## Local Development

Keep this package next to `quiver-quic` for local development:

```text
quiver-packages/
├── quiver-quic/
└── quiver-http3/
```

For Swift CI style local dependency testing, set `SWIFTCI_USE_LOCAL_DEPS=1` and place local `swift-nio` and `swift-nio-ssl` checkouts one directory above `quiver-packages`.

Set `QUIVER_PACKAGES_PATH=/path/to/quiver-packages` if your local Quiver package checkouts live somewhere else.

## WebTransport

The WebTransport server/session implementation lives in this package because it is tightly coupled to HTTP/3 Extended CONNECT routing, stream registration, and session dispatch. The separate `quiver-webtransport` package is a facade for consumers that want a WebTransport-named package boundary.

## Development Commands

```bash
swift build
swift test
```

## Relationship To Quiver

The root `quiver` package conditionally re-exports `HTTP3` and `QPACK` through package traits. Use this package directly when you want HTTP/3 or QPACK without the full aggregate package.
