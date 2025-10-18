# Server startup script for Bazel-based chat application (PowerShell)
param(
    [int]$Port = 59001
)

Write-Host "Starting Chat Server on port $Port..." -ForegroundColor Green
bazel run //:chat_server -- $Port