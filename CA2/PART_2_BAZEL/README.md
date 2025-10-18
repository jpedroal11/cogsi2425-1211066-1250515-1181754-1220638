# CA2 Part 2 - Bazel Build Tool

## Overview

This project converts a Spring Boot application (Payroll Service) from Gradle to Bazel.

Source: https://github.com/spring-guides/tut-rest

## Project Structure

```
CA2/PART_2_BAZEL/tut-rest/
├── BUILD.bazel              # Build configuration
├── WORKSPACE                # Dependencies
├── deploy_dev.sh            # Deployment script
├── install_dist.sh          # Distribution script
├── run_app.sh               # Run script
├── verify_deployment.sh     # Verification script
└── src/
    ├── main/java/          # Source code
    └── integration-test/   # Integration tests
```

## Requirements Implemented

### First Week
- Convert Spring Boot project to Bazel
- Configure dependencies (Spring Boot, H2, JPA, HATEOAS)

### Second Week

**Task 1: deployToDev**
- Copy JAR to build/deployment/dev/
- Copy dependencies to dev/lib/
- Process configuration files with token replacement (version, timestamp)

**Task 2: installDist + runFromDist**
- Create installable distribution with scripts
- Linux/Mac script: payroll_app
- Windows script: payroll_app.bat
- Auto-detect OS and run

**Task 3: javadocZip**
- Generate Javadoc
- Package into ZIP file

**Task 4: Integration Tests**
- Separate source set: src/integration-test/
- 3 tests implemented

## Build Commands

```bash
cd CA2/PART_2_BAZEL/tut-rest

# Build application
bazel build //:payroll_app

# Deploy to dev
bazel build //:deployToDev

# Create distribution
bazel build //:installDist

# Run application
bazel run //:runFromDist

# Generate Javadoc
bazel build //:javadocZip

# Run integration tests
bazel test //:integration_tests
```

## Output Artifacts

**deployToDev:**
```
bazel-bin/build/deployment/dev/
├── payroll_app.jar
├── lib/payroll_lib.jar
├── application.properties
└── DEPLOYMENT_INFO.txt
```

**installDist:**
```
bazel-bin/dist/
├── bin/
│   ├── payroll_app
│   └── payroll_app.bat
└── lib/
    ├── payroll_app.jar
    └── payroll_lib.jar
```

**javadocZip:**
```
bazel-bin/payroll-javadoc.zip
```

## Dependencies

Configured in WORKSPACE:
- Spring Boot 3.2.0
- Spring HATEOAS 2.1.0
- H2 Database 2.2.224
- JUnit Jupiter 5.10.1

## Gradle vs Bazel Comparison

| Aspect | Gradle | Bazel |
|--------|--------|-------|
| Build file | build.gradle | BUILD.bazel |
| Dependencies | dependencies {} | maven_install() |
| Tasks | task name | genrule |
| Run | ./gradlew run | bazel run |
| Clean | ./gradlew clean | Automatic |

## Notes

- Bazel builds are isolated (no need for clean)
- Token replacement: @project.version@ and @build.timestamp@
- Integration tests use JUnit 4 for Bazel compatibility
