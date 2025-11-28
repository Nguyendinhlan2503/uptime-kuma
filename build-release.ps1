# Build script for Uptime Kuma v1.0.0
$ErrorActionPreference = "Stop"

$VERSION = "v1.0.0"
$TAR_FILE = "uptime-kuma-$VERSION.tar"
$DOCKER_IMAGE = "uptime-kuma:$VERSION"
$DOCKER_PORT = 4428

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Building Uptime Kuma $VERSION" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Step 1: Build frontend
Write-Host "`n[1/4] Building frontend..." -ForegroundColor Yellow
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "Frontend build failed!" -ForegroundColor Red
    exit 1
}

# Step 2: Create tar file
Write-Host "`n[2/4] Creating tar file: $TAR_FILE..." -ForegroundColor Yellow
# Exclude unnecessary files
$exclude = @(
    "node_modules",
    ".git",
    "data",
    "tmp",
    "*.log",
    ".env",
    ".env.local",
    "dist-stats.html"
)

# Create tar file (PowerShell 7+)
if (Get-Command tar -ErrorAction SilentlyContinue) {
    $excludeArgs = $exclude | ForEach-Object { "--exclude=$_" }
    tar -czf $TAR_FILE --exclude="node_modules" --exclude=".git" --exclude="data" --exclude="tmp" --exclude="*.log" .
    Write-Host "Tar file created: $TAR_FILE" -ForegroundColor Green
} else {
    Write-Host "Warning: tar command not found. Skipping tar file creation." -ForegroundColor Yellow
    Write-Host "You can create it manually with: tar -czf $TAR_FILE --exclude='node_modules' --exclude='.git' --exclude='data' ." -ForegroundColor Yellow
}

# Step 3: Build Docker image
Write-Host "`n[3/4] Building Docker image: $DOCKER_IMAGE..." -ForegroundColor Yellow
docker build -f docker/dockerfile -t $DOCKER_IMAGE --target release .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "Docker image built: $DOCKER_IMAGE" -ForegroundColor Green

# Step 4: Run Docker container
Write-Host "`n[4/4] Running Docker container on port $DOCKER_PORT..." -ForegroundColor Yellow
# Stop existing container if running
docker stop uptime-kuma-$VERSION 2>$null
docker rm uptime-kuma-$VERSION 2>$null

docker run -d `
    --name uptime-kuma-$VERSION `
    -p ${DOCKER_PORT}:3001 `
    -v uptime-kuma-data:/app/data `
    --restart unless-stopped `
    $DOCKER_IMAGE

if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker container failed to start!" -ForegroundColor Red
    exit 1
}

Write-Host "`n=========================================" -ForegroundColor Green
Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Tar file: $TAR_FILE" -ForegroundColor Cyan
Write-Host "Docker image: $DOCKER_IMAGE" -ForegroundColor Cyan
Write-Host "Container: uptime-kuma-$VERSION" -ForegroundColor Cyan
Write-Host "Access at: http://localhost:$DOCKER_PORT/uptime" -ForegroundColor Cyan
Write-Host "`nTo view logs: docker logs -f uptime-kuma-$VERSION" -ForegroundColor Yellow

