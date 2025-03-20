fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### setupMac

```sh
[bundle exec] fastlane setupMac
```

☁️  Installs Base Dependencies For Our Devs.

### lintFormatValidate

```sh
[bundle exec] fastlane lintFormatValidate
```

☁️  Validates The Current Project Using SwiftLint And Swift Format

### lintFormatCorrect

```sh
[bundle exec] fastlane lintFormatCorrect
```

☁️  Lints And Formats The Current Project

### test

```sh
[bundle exec] fastlane test
```

☁️ Runs Unit Tests

### releasePackage

```sh
[bundle exec] fastlane releasePackage
```

☁️ Creates A New Package Version

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
