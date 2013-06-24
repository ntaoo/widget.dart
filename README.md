# Dart Widgets
## A set of reusable Web Components for Dart applications

[![Build Status](https://drone.io/github.com/dart-lang/widget.dart/status.png)](https://drone.io/github.com/dart-lang/widget.dart/latest)

# Web UI

**Dart Widgets** leverages the [Web UI](https://github.com/dart-lang/web-ui) Dart project, sponsored by the [Google Dart](http://www.dartlang.org/) team.

* **Web UI** is in heavy development, as is **Dart**.
* Read up on the **WEB UI** project before trying to use the code in this project.
* Pay attention to the current version of **WEB UI** being used by looking at `pubspec.yaml`.

# Conventions

* All components live in `lib/components`
    * At the moment, all components live in their own inferred library.
    * While the convention states libraries should be directly in `lib`, it would get noisy to have every component in the `lib` dir.
    * Tracked by [widget.dart bug 4](https://github.com/kevmoo/widget.dart/issues/4)
    * Blocked by [web-ui bug 291](https://github.com/dart-lang/web-ui/issues/291)
* Naming
    * For a custom component with element name `x-foo-bar`
    * The class name corresponds to the web-ui library convention: `FooBar`
    * File names correspond to Dart convention: `foo_bar.[dart|html]`

# Versioning

Our goal is to follow [Semantic Versioning](http://semver.org/).

_Note: we have not released v1 (yet)._

# Authors
 * [Kevin Moore](https://github.com/kevmoo) ([@kevmoo](http://twitter.com/kevmoo))
 * _You? File bugs. Fork and Fix bugs._
