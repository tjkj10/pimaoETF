# PowerShell script to fix encoding issues in HTML files

# Find all HTML files recursively
$htmlFiles = Get-ChildItem -Path . -Filter "*.html" -Recurse -File

Write-Host "Found $($htmlFiles.Count) HTML files"

$fixedCount = 0
foreach ($file in $htmlFiles) {
    try {
        # Read file content as UTF-8
        $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
        
        # Store original content
        $originalContent = $content
        
        # Replace all variations of garbled back button text
        $content = $content -replace '鈫\?棣栭〉', '← 首页'
        $content = $content -replace '鈫\?杩斿洖棣栭〉', '← 返回首页'
        
        # If content changed, write back to file
        if ($content -ne $originalContent) {
            [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
            Write-Host "Fixed: $($file.FullName)"
            $fixedCount++
        }
    } catch {
        Write-Host "Error fixing $($file.FullName): $_"
    }
}

Write-Host "Fix complete! Fixed $fixedCount files."
