# insert-hamburger.ps1
# 실행: powershell -ExecutionPolicy Bypass -File .\insert-hamburger.ps1

$projectRoot = Get-Location

# 1) CSS: target CSS file (create if not exists)
$cssFile = Join-Path $projectRoot "episode-content.css"
$cssSnippet = @"
 /* --- added by automated script: hamburger nav styles --- */
.nav-toggle {
    display: none;
    flex-direction: column;
    cursor: pointer;
    background: none;
    border: none;
    padding: 6px;
}
.nav-toggle span {
    width: 24px;
    height: 3px;
    background: #1f2937;
    margin: 3px 0;
    display:block;
}
/* mobile */
@media (max-width: 768px) {
    .nav-toggle { display:flex; }
    .main-nav { display: none; flex-direction: column; gap:8px; background: #fff; padding:10px; border-radius:6px; }
    .main-nav.active { display:flex; }
}
 /* --- end snippet --- */
"@

if (!(Test-Path $cssFile)) {
    "" | Out-File -FilePath $cssFile -Encoding UTF8
}
# only append if snippet not already present
$cssContent = Get-Content $cssFile -Raw -ErrorAction SilentlyContinue
if ($cssContent -notlike "*added by automated script: hamburger nav styles*") {
    Add-Content -Path $cssFile -Value $cssSnippet -Encoding UTF8
    Write-Host "Appended CSS to $cssFile"
} else {
    Write-Host "CSS snippet already present in $cssFile"
}

# 2) JS snippet to insert before </body> on each episode page if not present and if nav-toggle exists
$jsSnippet = @"
<!-- auto-inserted hamburger JS -->
<script>
(function(){
  var btn = document.querySelector('.nav-toggle');
  var nav = document.querySelector('.main-nav');
  if(!btn || !nav) return;
  if(btn.dataset.hamburgerAdded==='1') return;
  btn.dataset.hamburgerAdded='1';
  btn.addEventListener('click', function(){ nav.classList.toggle('active'); });
})();
</script>
<!-- end auto-inserted hamburger JS -->
"@

# find all index.html in episode folders
Get-ChildItem -Path $projectRoot -Recurse -Include index.html `
    | Where-Object { $_.DirectoryName -match 'episode' } `
    | ForEach-Object {
        $file = $_.FullName
        $txt = Get-Content $file -Raw -ErrorAction SilentlyContinue
        if ($txt -match "<button[^>]*class\s*=\s*['""]?nav-toggle['""]?") {
            if ($txt -notmatch "auto-inserted hamburger JS") {
                # insert just before last </body>
                $new = $txt -replace "</body\s*>", "$jsSnippet`n</body>"
                Set-Content -Path $file -Value $new -Encoding UTF8
                Write-Host "Inserted JS into $file"
            } else {
                Write-Host "JS already present in $file"
            }
        } else {
            Write-Host "No nav-toggle in $file — skipped"
        }
}
