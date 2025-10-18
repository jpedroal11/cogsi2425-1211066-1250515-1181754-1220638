@echo off
REM Server startup script for Bazel-based chat application (Windows CMD)

set PORT=%1
if "%PORT%"=="" set PORT=59001

echo Starting Chat Server on port %PORT%...
bazel run //:chat_server -- %PORT%