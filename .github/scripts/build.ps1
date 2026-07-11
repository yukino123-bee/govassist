$source = "govassist_backend"
$flatDest = "dist"
$flutterWeb = "build/web"

Write-Host "Starting Release Pipeline..." -ForegroundColor Cyan

Write-Host "Preparing deployment directory ($flatDest)..."
if (Test-Path $flatDest) { Remove-Item -Path $flatDest -Recurse -Force }
New-Item -ItemType Directory -Path $flatDest | Out-Null

if (Test-Path $flutterWeb) {
    Write-Host "Copying Flutter Web Build..." -ForegroundColor Cyan
    Copy-Item -Path "$flutterWeb/*" -Destination $flatDest -Recurse -Force
}

Write-Host "Copying backend files directly..." -ForegroundColor Cyan
# Copy the entire backend contents recursively, preserving the native folder structure
Copy-Item -Path "$source/*" -Destination $flatDest -Recurse -Force

# Ensure upload directories exist
New-Item -ItemType Directory -Path "$flatDest/uploads/profiles" -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "$flatDest/uploads/ids" -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "$flatDest/uploads/templates" -Force -ErrorAction SilentlyContinue
" " | Set-Content "$flatDest/uploads/index.html"
" " | Set-Content "$flatDest/uploads/profiles/index.html"
" " | Set-Content "$flatDest/uploads/ids/index.html"
" " | Set-Content "$flatDest/uploads/templates/index.html"

# Create .htaccess to preserve Authorization header on Awardspace
$htaccessContent = @"
RewriteEngine On
RewriteCond %{HTTP:Authorization} ^(.*)
RewriteRule .* - [e=HTTP_AUTHORIZATION:%1]
SetEnvIf Authorization "(.*)" HTTP_AUTHORIZATION=`$1
"@
$htaccessContent | Set-Content "$flatDest/.htaccess"

Write-Host "Pipeline complete! The dist directory is ready for FTP upload." -ForegroundColor Green
