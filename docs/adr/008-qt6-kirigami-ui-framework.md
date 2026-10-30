# ADR-008: Qt6/Kirigami for UI Framework

## Status
Accepted

## Context
Meridian OS currently implements its Linux-track UI using **Qt6 (6.8 LTS)** with **QML** and **Kirigami** (KDE's convergent UI components). The Conexus specification defines a cross-platform design system ("Conexus Design System") with tokens, components, and motion specs targeting web (React/Inertia), Android (Compose), and iOS (SwiftUI).

Key tensions:
- Qt6/Kirigami is mature, convergent (mobile/desktop), and already runs on all target Linux devices
- Conexus design system is defined in Figma with web-first implementation (shadcn/ui + Tailwind)
- W10M custom controls (`meridian-w10m/src/controls/`) implement 50+ Windows 10 Mobile–specific components
- Rewriting the entire Linux UI in a new toolkit (Flutter, React Native, Compose Multiplatform) would take 12–18 months
- C++/Qt expertise exists in the team; Rust/Qt bindings (`cxx-qt`, `qt-rs`) are maturing but not production-ready

## Decision
**Keep Qt6/Kirigami as the UI framework for Linux-track devices.** Build the Conexus Design System as a **Qt/QML component library** (`conexus-ui-qt`) that wraps Kirigami and provides Conexus tokens, components, and motion.

- Existing `meridian-w10m` codebase stays on Qt6/Kirigami + custom W10M controls
- New Conexus-branded Linux apps use `conexus-ui-qt` (QML modules: `Conexus.Components`, `Conexus.Tokens`, `Conexus.Motion`)
- W10M controls extracted to a separate library (`w10m-controls`) for preservation and migration (see ADR-010)
- No Flutter, React Native, or Compose Multiplatform on Linux track
- FFI boundary at D-Bus for Rust system services (see ADR-011)

## Consequences

### Positive
- **Time to market**: Linux UI ships now; Conexus design system built incrementally as Qt components
- **Hardware enablement**: Qt6 already has working GPU acceleration (ETNAVIV, Lima, Panfrost, freedreno) on all target SoCs
- **Convergent by default**: Kirigami handles phone/tablet/desktop breakpoints; matches Conexus responsive specs
- **Team velocity**: Existing C++/Qt knowledge applies directly; no context switch
- **Upstream contribution**: Fixes/improvements flow back to Kirigami/Qt, benefiting wider KDE ecosystem

### Negative
- **Design system divergence**: Qt implementation of Conexus tokens/components must be kept in sync with Figma/web/Android/iOS specs
- **C++/Qt expertise required**: Hiring pool smaller than React/Flutter; onboarding investment
- **No code sharing with mobile apps**: Conexus mobile apps (Android/iOS) use Compose/SwiftUI; Linux uses Qt — separate implementations
- **W10M brand confusion risk**: Must clearly separate "Meridian W10M" (legacy skin) from "Conexus" (new design language)

## Links
- [Kirigami documentation](https://api.kde.org/frameworks/kirigami/html/)
- [Qt 6.8 LTS release notes](https://www.qt.io/blog/qt-6.8-released)
- [ADR-010: W10M Controls as Extractable Library](adr-010-w10m-controls-library.md)
- [ADR-011: Rust for New System Services](adr-011-rust-system-services.md)
- [Conexus Design System Figma](https://www.figma.com/...conexus-design-system)