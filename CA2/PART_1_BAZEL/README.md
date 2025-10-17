# CA2 Part 1 - Bazel Build Tool (Windows)

This project demonstrates build automation using Bazel as an alternative to Gradle.

## Project Structure

- `src/main/java/basic_demo/` - Java source files
- `WORKSPACE` - Bazel workspace configuration
- `BUILD.bazel` - Build targets and rules
- `.bazelversion` - Bazel version specification

## Requirements

- Bazelisk (automatically manages Bazel versions)
- Java 17 or higher
- Windows 10/11

## Building
```powershell
bazelisk build //:chat_lib
```

## Running

Start server:
```powershell
bazelisk run //:chat_server -- 59001
```

Start client:
```powershell
bazelisk run //:chat_client
```