# OpenUXKit

OpenUXKit is an open source implementation of Apple's UXKit PrivateFramework

The project is for the following purposes:
- Build similar to UIKit interface on non-Apple platform (e.g. GNUStep)
- Bringing missing components to the macOS platform (e.g. NavigationController)

And the API design is to stay the same as the original UXKit API.

Currently, this project is in early development.

## Examples

Open `OpenUXKit.xcworkspace` and pick a scheme:

- **OpenUXKit-Example-Swift** — the supported showcase. A single window hosts a
  `UXNavigationController` whose home screen pushes one demo per public API
  family: `UXView` / `UXLabel` / `UXImageView` / `UXControl`, the
  `UXBarButtonItem` system items, `UXNavigationItem`, the four
  `UXToolbar` tracks, navigation stack manipulation, modal presentation,
  custom `UXViewControllerAnimatedTransitioning` animators, the
  `UXCollectionView` + flow-layout stack, `UXCollectionViewController`,
  `UXTabBarItemSegment`, `UXLayoutSupport` guides, and the `UXBase` helpers.
  `UXKitAppearance` is intentionally absent — see the note below.
- **OpenUXKit-Example-ObjC** — *deprecated*. Kept only for historical reference;
  it links against Apple's private `UXKit.framework`. See
  `Examples/OpenUXKit-Example-ObjC/DEPRECATED.md`.

### Deprecated API

`UXKitAppearance` (and its `UXTintAdjustmentMode` enum) was modelled on the
macOS 11.0 vintage of the private `UXKit.framework`. Apple has since removed
the protocol from the framework, so OpenUXKit now ships the declarations
annotated with `API_DEPRECATED` for source compatibility only. Style controls
through `NSAppearance`, asset catalog colors, or per-class tint APIs (e.g.
`UXImageView.tintColor`) instead.

## TODO

- [x] `UXView`
- [x] `UXViewController`
- [x] `UXBar`
- [x] `UXToolbar`
- [x] `UXBarItem`
- [x] `UXBarButtonItem`
- [x] `UXNavigationBar`
- [x] `UXNavigationController`
- [x] `UXNavigationItem`
- [x] `UXLabel`
- [x] `UXImageView`
- [ ] `UXSourceController`
- [ ] `UXTabBarController`
- [ ] `UXCollectionView`
- [ ] `UXWindowController`
- [ ] ......
