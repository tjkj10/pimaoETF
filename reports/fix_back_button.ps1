# UTF-8 encoding fix script
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$newCSS = @'
/* 返回按钮 - 透明悬浮 */
.back-button {
    position: fixed;
    top: 15px;
    left: 15px;
    background: rgba(255, 255, 255, 0.9);
    color: #667eea;
    padding: 8px 14px;
    border-radius: 20px;
    text-decoration: none;
    font-weight: 500;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    transition: all 0.3s ease;
    z-index: 1000;
    display: inline-flex;
    align-items: center;
    gap: 4px;
    font-size: 13px;
    backdrop-filter: blur(10px);
    border: 1px solid rgba(102, 126, 234, 0.2);
}

.back-button:hover {
    background: rgba(255, 255, 255, 1);
    box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
    transform: translateY(-2px);
    text-decoration: none;
}

@media (max-width: 768px) {
    .back-button {
        top: 10px;
        left: 10px;
        padding: 6px 12px;
        font-size: 12px;
    }
}
'@

$backButtonHtml = '<a href="../../index.html" class="back-button">← 首页</a>'

Get-ChildItem -Path "C:\Users\tjkj1\Documents\pimao_tools\etf\pimaoETF\reports" -Filter "*.html" -Recurse | ForEach-Object {
    $file = $_
    Write-Host "Processing: $($file.Name)"
    
    try {
        # Read with UTF-8 BOM
        $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.UTF8Encoding]::new($false))
        
        # Remove old back-button CSS (any variation)
        $content = $content -replace '(?s)/\*.*?(?:back|返回|Back).*?button.*?\*/[\s\S]*?(?=\s*/\*|</style>)', ''
        
        # Find the position of </style>
        $styleEndPos = $content.IndexOf('</style>')
        if ($styleEndPos -gt 0) {
            # Insert new CSS before </style>
            $content = $content.Substring(0, $styleEndPos) + "`n" + $newCSS + "`n" + $content.Substring($styleEndPos)
        }
        
        # Replace back button HTML
        $content = $content -replace '<a\s+href="[^"]*"[^>]*class="[^"]*back-button[^"]*"[^>]*>[^<]*</a>', $backButtonHtml
        
        # Add back-button if not present and <body> exists
        if ($content -notmatch 'class="back-button"' -and $content -match '<body>') {
            $content = $content -replace '<body>', "<body>`n    $backButtonHtml"
        }
        
        # Write with UTF-8 encoding (no BOM)
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
        
        Write-Host "  - Fixed: $($file.Name)" -ForegroundColor Green
    }
    catch {
        Write-Host "  - Error: $($file.Name) - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nAll files processed!" -ForegroundColor Cyan
