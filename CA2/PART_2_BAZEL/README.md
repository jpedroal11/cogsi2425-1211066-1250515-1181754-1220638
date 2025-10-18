# CA2 Part 2 - Bazel

## Overview

This assignment converts a Spring Boot application from Maven to Bazel as an alternative build tool to Gradle.

**Source:** https://github.com/spring-guides/tut-rest

The application is a simple payroll service that manages company employees. It stores employee objects in an H2 in-memory database, accesses them through JPA, and wraps that with a Spring MVC layer for internet access.

## Initial Setup

### Original Application (Maven)

Run the original Maven application:
```bash
cd tut-rest/links
../mvnw spring-boot:run
```

Access: http://localhost:8080/employees

### Conversion to Bazel

The project was converted from Maven to Bazel by:
1. Creating `BUILD.bazel` with build configuration
2. Creating `WORKSPACE` with Maven dependencies
3. Adding `.bazelversion` to specify Bazel version
4. Replacing Maven lifecycle with Bazel targets

Run with Bazel:
```bash
cd CA2/PART_2_BAZEL/tut-rest
bazel run //:payroll_app
```

## Bazel Project Structure

```
CA2/PART_2_BAZEL/tut-rest/
├── BUILD.bazel              
├── WORKSPACE                
├── .bazelversion
├── deploy_dev.sh            
├── install_dist.sh          
├── run_app.sh               
└── src/
    ├── main/java/          
    └── integration-test/   
```

## Custom Tasks Implemented

### Task 1: deployToDev

Custom task that deploys the application:
- Copies main JAR to `build/deployment/dev/`
- Copies runtime dependencies to `dev/lib/`  
- Processes configuration files with token replacement

```bash
bazel build //:deployToDev
```

Result:
```
bazel-bin/build/deployment/dev/
├── payroll_app.jar
├── lib/payroll_lib.jar
├── application.properties      # @project.version@ replaced
└── DEPLOYMENT_INFO.txt         # @build.timestamp@ replaced
```

### Task 2: installDist + runFromDist

Creates distribution with OS-specific scripts:

```bash
bazel build //:installDist
```

Result:
```
bazel-bin/dist/
├── bin/
│   ├── payroll_app             # Linux/Mac
│   └── payroll_app.bat         # Windows
└── lib/
    ├── payroll_app.jar
    └── payroll_lib.jar
```

Run application:
```bash
bazel run //:runFromDist        # Auto-detects OS
```

### Task 3: javadocZip

Generates Javadoc and packages it:

```bash
bazel build //:javadocZip
```

Result: `bazel-bin/payroll-javadoc.zip`

### Task 4: Integration Tests

Separate source set for integration tests:

```bash
bazel test //:integration_tests
```

Location: `src/integration-test/java/`

Tests implemented: 3

## Build Commands

```bash
cd CA2/PART_2_BAZEL/tut-rest

# Build application
bazel build //:payroll_app

# Run application
bazel run //:payroll_app

# Custom tasks
bazel build //:deployToDev
bazel build //:installDist  
bazel build //:javadocZip
bazel test //:integration_tests
```

## Dependencies

Configured in WORKSPACE:
- Spring Boot 3.2.0
- Spring HATEOAS 2.1.0
- H2 Database 2.2.224
- JUnit 4

## Maven vs Gradle vs Bazel

| Command | Maven | Gradle | Bazel |
|---------|-------|--------|-------|
| Build | `mvn package` | `./gradlew build` | `bazel build //:target` |
| Run | `mvn spring-boot:run` | `./gradlew bootRun` | `bazel run //:target` |
| Test | `mvn test` | `./gradlew test` | `bazel test //:target` |
| Clean | `mvn clean` | `./gradlew clean` | Not needed |

## Notes

- Bazel builds are hermetic and isolated
- No separate clean task needed
- Token replacement: `@project.version@` and `@build.timestamp@`
- Scripts auto-detect operating system (Windows/Linux/Mac)
