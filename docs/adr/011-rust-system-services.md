# ADR-011: Rust for New System Services (ADR-005 Alignment)

## Status
Accepted

## Context
Conexus ADR-005 establishes **Rust as the preferred language for new userspace system services** (daemons, agents, CLI tools) across the platform. Meridian OS currently has:

- **C++/Qt applications**: Shell (`meridian-w10m`), Home (`meridian-home`), Store, Messages, Dialer, Terminal, File Manager
- **C system services**: `pm-manager` (power), `killswitch-handler`, `hwinit` scripts (shell)
- **No Rust code** in the codebase yet

The Conexus platform is introducing new system services:
- `conexus-telephony` (modem manager, call/SMS handling)
- `conexus-network` (NetworkManager wrapper, VPN, tethering)
- `conexus-location` (GPS, geoclue integration)
- `conexus-sync` (contacts/calendar sync via CalDAV/CardDAV)
- `conexus-push` (unified push gateway for mobile apps)
- `conexus-ota` (update client for OSTree/A/B)

## Decision
**Write all new Conexus system services in Rust.** Existing C++/Qt applications remain C++; FFI boundary at **D-Bus**.

### Rust Adoption Rules
1. **New daemons/agents/CI tools → Rust** (Cargo workspace at `system/rust/`)
2. **Existing C++ apps → stay C++** (no rewrite; too risky, no user value)
3. **Existing C daemons → rewrite only when modified** (opportunistic)
4. **FFI at D-Bus**: Rust services expose `org.conexus.*` D-Bus APIs; Qt apps call via `QDBusInterface`
5. **Shared types**: `conexus-dbus-gen` generates Rust (`zbus`) and C++ (`QtDBus`) bindings from XML
6. **No `cxx-qt`/`qt-rs` in production yet**: Monitor maturity; revisit in 2026 Q4

### Cargo Workspace Structure
```
system/rust/
├── Cargo.toml (workspace)
├── conexus-dbus-gen/          # codegen from XML → Rust/C++
├── conexus-telephony/         # modem, calls, SMS
├── conexus-network/           # NetworkManager D-Bus wrapper
├── conexus-location/          # geoclue, GPS
├── conexus-sync/              # CalDAV/CardDAV
├── conexus-push/              # unified push
├── conexus-ota/               # OSTree/A/B update client
└── conexus-common/            # shared: config, logging, error types
```

### Toolchain
- `rust-toolchain.toml` pins stable channel (currently 1.82+)
- `cargo-deny` for license/security auditing in CI
- `cargo-audit` + `cargo-outdated` in nightly pipeline
- MSRV (Minimum Supported Rust Version): 1.78 (Debian 12 backport)

## Consequences

### Positive
- **ADR-005 compliance**: Aligns with Conexus platform direction
- **Memory safety**: Critical system services (telephony, network, OTA) eliminate CVE classes
- **Concurrency**: `tokio`/`async-std` for modem/network I/O; no callback hell
- **Ecosystem**: `zbus`, `dbus`, `nix`, `libc` crates mature for Linux system programming
- **Hiring**: Rust talent pool growing; Conexus-wide skill investment

### Negative
- **Two language stacks**: C++ (Qt apps) + Rust (system services) = context switching
- **D-Bus latency**: IPC overhead vs in-process C++ calls (~1–2 ms per call; acceptable for system APIs)
- **Build complexity**: Cargo + CMake + meson (for some deps); CI matrix expands
- **Learning curve**: Team needs Rust onboarding (3–4 weeks for C++ devs)
- **No GUI in Rust**: Qt remains C++; `slint`/`iced` not ready for production mobile UI

## Links
- [Conexus ADR-005: Rust for Userspace](https://github.com/conexus-systems/.../adr-005-rust-userspace.md)
- [zbus D-Bus crate](https://dbus.zbus.io/)
- [Rust Linux system programming](https://rust-lang.github.io/rust-system-programming/)
- [system/rust/Cargo.toml](../system/rust/Cargo.toml) (to be created)
- [conexus-dbus-gen design](../system/rust/conexus-dbus-gen/README.md) (to be created)