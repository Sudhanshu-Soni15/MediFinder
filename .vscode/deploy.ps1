$TOMCAT = "C:\Program Files\Apache Software Foundation\Tomcat 9.0"
$WEBAPP = "$TOMCAT\webapps\MediFinder"
$CLASSES = "$WEBAPP\WEB-INF\classes"
$LIB = "$WEBAPP\WEB-INF\lib"
$SERVLET_API = "$TOMCAT\lib\servlet-api.jar"

# ✅ ADD THESE TWO LINES
$env:CATALINA_HOME = $TOMCAT
$env:JAVA_HOME = "C:\Program Files\Java\jdk-26"

Write-Host "========================================"  -ForegroundColor Cyan
Write-Host "  MediFinder Build and Deploy"            -ForegroundColor Cyan
Write-Host "========================================"  -ForegroundColor Cyan

# Replace [1/4] Stopping Tomcat...
Write-Host "[1/4] Stopping Tomcat..." -ForegroundColor Yellow
& "$TOMCAT\bin\catalina.bat" stop 2>$null
Start-Sleep -Seconds 4

Write-Host "[2/4] Clearing Tomcat cache..." -ForegroundColor Yellow
$workDir = "$TOMCAT\work\Catalina\localhost\MediFinder"
if (Test-Path $workDir) {
    Remove-Item -Recurse -Force $workDir
    Write-Host "      Cache cleared." -ForegroundColor Green
} else {
    Write-Host "      No cache, skipping." -ForegroundColor Gray
}

Write-Host "[3/4] Compiling Java sources..." -ForegroundColor Yellow
$javaFiles = Get-ChildItem -Recurse $CLASSES -Filter "*.java" | Select-Object -ExpandProperty FullName

if ($javaFiles.Count -eq 0) {
    Write-Host "No .java files found!" -ForegroundColor Red
    exit 1
}

$allArgs = "-cp", ".;$LIB\*;$SERVLET_API", "-d", $CLASSES
$allArgs = $allArgs + $javaFiles

$output = & javac @allArgs 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "BUILD FAILED:" -ForegroundColor Red
    Write-Host $output  -ForegroundColor Red
    Write-Host "Tomcat NOT restarted." -ForegroundColor Red
    exit 1
}
Write-Host "      Compiled OK." -ForegroundColor Green

# Replace [4/4] Starting Tomcat...
Write-Host "[4/4] Starting Tomcat..." -ForegroundColor Yellow
Start-Process "$TOMCAT\bin\catalina.bat" -ArgumentList "start" -WindowStyle Hidden
Start-Sleep -Seconds 4

Write-Host "========================================"  -ForegroundColor Green
Write-Host "  DONE: http://localhost:8080/MediFinder" -ForegroundColor Green
Write-Host "========================================"  -ForegroundColor Green