# ADR-010: W10M Controls as Extractable Library

## Status
Accepted

## Context
The `meridian-w10m` codebase contains **50+ custom QML/C++ controls** implementing the Windows 10 Mobile design language (Metro/Modern UI):

- Shell: `W10MShell`, `W10MNavigation`, `W10MCompositor`
- Controls: `W10MPivot`, `W10MCommandBar`, `W10MAppBar`, `W10MTile`, `W10MToggle`, `W10MCheckbox`, `W10MButton`, `W10MTextField`, `W10MMenu`, `W10MDialog`, `W10MCommandBar`, `W10MLiveTile`
- Animations: `W10MAnimationManager` (page transitions, peel, tilt, swipe)
- Models: `W10MTileModel`, `W10MAppModel`, `W10MSettingsModel`
- Input: `W10MInputManager` (touch, keyboard, gamepad)

The Conexus specification requires a **new, unified design system** ("Conexus Design System") with its own tokens, components, and motion language — distinct from Windows 10 Mobile. Continuing to build Conexus UI inside `meridian-w10m` conflates the two brands and creates technical debt.

## Decision
**Extract W10M controls to a standalone library (`w10m-controls`)** and build the Conexus Design System as a fresh Qt/QML library (`conexus-ui-qt`).

### Extraction (`w10m-controls`)
- New CMake project: `ui/w10m-controls/`
- Public API: `import W10M.Controls 1.0` (QML modules + C++ plugins)
- Preserves all 50+ controls, animations, models, input manager
- Versioned independently; Meridian W10M shell depends on it
- Documented as "legacy/reference implementation" — not for new Conexus apps

### New Conexus Library (`conexus-ui-qt`)
- New CMake project: `ui/conexus-ui-qt/`
- Implements Conexus tokens (colors, spacing, typography, motion) as QML `Conexus.Tokens`
- Components: `Conexus.Button`, `Conexus.Card`, `Conexus.Navigation`, `Conexus.Sheet`, etc. (per Figma spec)
- Motion: `Conexus.Transition`, `Conexus.Easing` matching Conexus motion specs
- No W10M visual language; clean break

### Migration Path
- Existing `meridian-w10m` shell links `w10m-controls` — zero behavior change
- New Conexus-branded apps (Settings, Store, Messages) use `conexus-ui-qt`
- Gradual migration: one screen at a time; `w10m-controls` deprecated over 12 months
- Automated codemod for common patterns (e.g., `W10MButton` → `Conexus.Button`)

## Consequences

### Positive
- **Brand clarity**: W10M preserved as historical reference; Conexus design system unambiguous
- **Technical debt isolation**: W10M quirks (Zune-era animations, pivot headers) don't leak into Conexus components
- **Independent versioning**: `w10m-controls` can stay on Qt 6.8 LTS; `conexus-ui-qt` tracks Qt 6.next
- **Open source friendly**: `w10m-controls` can be published as "Windows 10 Mobile UI kit for Qt" — community value
- **Testing**: Each library has own CI; visual regression tests per design language

### Negative
- **Duplication effort**: Two Qt component libraries to maintain (~20% overlap in primitives)
- **Migration cost**: ~30 screens in `meridian-w10m` need porting to `conexus-ui-qt`
- **Team split**: Developers must context-switch between W10M and Conexus component APIs

## Links
- [meridian-w10m source](../ui/meridian-w10m/)
- [W10M controls extraction plan](../ui/w10m-controls/README.md) (to be created)
- [Conexus Design System Figma](https://www.figma.com/...conexus-design-system)
- [ADR-008: Qt6/Kirigami for UI Framework](adr-008-qt6-kirigami-ui-framework.md)