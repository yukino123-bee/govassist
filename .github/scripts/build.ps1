$source = "govassist_backend"
$flatDest = "dist"

Write-Host "Starting Release Pipeline..." -ForegroundColor Cyan

# 1. FLATTEN BACKEND FOR AWARDSPACE
Write-Host "Flattening backend to $flatDest..."
if (Test-Path $flatDest) { Remove-Item -Path $flatDest -Recurse -Force }
New-Item -ItemType Directory -Path $flatDest | Out-Null

Copy-Item -Path "$source/api/*.php" -Destination $flatDest -Force
Copy-Item -Path "$source/admin/*.html" -Destination $flatDest -Force
Copy-Item -Path "$source/api/admin/*.php" -Destination $flatDest -Force -ErrorAction SilentlyContinue
Copy-Item -Path "$source/admin/css/*.*" -Destination $flatDest -Force -ErrorAction SilentlyContinue
Copy-Item -Path "$source/admin/js/*.*" -Destination $flatDest -Force -ErrorAction SilentlyContinue
Copy-Item -Path "$source/admin/images/*.*" -Destination $flatDest -Force -ErrorAction SilentlyContinue

# Update Paths in Flat Files
$phpFiles = Get-ChildItem -Path $flatDest -Filter "*.php"
foreach ($file in $phpFiles) {
    $content = Get-Content $file.FullName
    
    # Inject Production DB Credentials for Awardspace
    if ($file.Name -eq 'db.php') {
        $content = $content -replace "'localhost'", "'fdb1032.awardspace.net'" `
                            -replace "'govassist_db'", "'4715301_govassist'" `
                            -replace "'root'", "'4715301_govassist'" `
                            -replace "''", "'manok123#'"
    }
    
    # Fix paths for files that were previously in subfolders
    $content = $content -replace "'\.\./cors\.php'", "'cors.php'" `
                        -replace "'\.\./db\.php'", "'db.php'" `
                        -replace "'\.\./auth_middleware\.php'", "'auth_middleware.php'" `
                        -replace "'\.\./jwt\.php'", "'jwt.php'"
    $content | Set-Content $file.FullName
}

if (Test-Path "$source/admin/css/style.css") {
    $styleContent = Get-Content "$source/admin/css/style.css" -Raw
    $styleTag = "<style>`n$styleContent`n</style>"

    $htmlFiles = Get-ChildItem -Path $flatDest -Filter "*.html"
    foreach ($file in $htmlFiles) {
        (Get-Content $file.FullName -Raw) -replace '(?i)<link[^>]*href="[^"]*style\.css[^"]*"[^>]*>', $styleTag `
                                          -replace 'href="css/', 'href="' `
                                          -replace 'src="js/', 'src="' `
                                          -replace 'src="images/', 'src="' `
                                          -replace "\.\./api/admin/", "" `
                                          -replace "\.\./api/", "" | Set-Content $file.FullName
    }
}

$jsFiles = Get-ChildItem -Path $flatDest -Filter "*.js"
foreach ($file in $jsFiles) {
    (Get-Content $file.FullName) -replace "\.\./api/admin/", "" `
                                 -replace "\.\./api/", "" `
                                 -replace 'src="\.\./', 'src="' `
                                 -replace 'src="images/', 'src="' | Set-Content $file.FullName
}
Write-Host "Flattening complete!" -ForegroundColor Green
