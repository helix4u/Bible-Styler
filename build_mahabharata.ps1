Param(
  [string]$ZipPath = "mahatxt.zip",
  [string]$OutPath = "mahabharata_kmg.json"
)

if (!(Test-Path $ZipPath)) {
  Write-Host "Missing $ZipPath. Download from https://sacred-texts.com/hin/maha/mahatxt.zip and place it in this folder." -ForegroundColor Yellow
  exit 1
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

function Get-ParvaName($rel) {
  switch ($rel) {
    'm01' { 'Adi Parva' }
    'm02' { 'Sabha Parva' }
    'm03' { 'Vana Parva' }
    'm04' { 'Virata Parva' }
    'm05' { 'Udyoga Parva' }
    'm06' { 'Bhishma Parva' }
    'm07' { 'Drona Parva' }
    'm08' { 'Karna Parva' }
    'm09' { 'Shalya Parva' }
    'm10' { 'Sauptika Parva' }
    'm11' { 'Stri Parva' }
    'm12' { 'Santi Parva' }
    'm13' { 'Anusasana Parva' }
    'm14' { 'Aswamedha Parva' }
    'm15' { 'Asramavasika Parva' }
    'm16' { 'Mausala Parva' }
    'm17' { 'Mahaprasthanika Parva' }
    'm18' { 'Svargarohanika Parva' }
    Default { $rel }
  }
}

function Strip-Html($s) {
  if (-not $s) { return '' }
  $t = [Regex]::Replace($s, '(?is)<script.*?</script>', '')
  $t = [Regex]::Replace($t, '(?is)<style.*?</style>', '')
  $t = [Regex]::Replace($t, '<[^>]+>', ' ')
  return ($t -replace '\s+', ' ').Trim()
}

$entries = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path $ZipPath)).Entries
$records = New-Object System.Collections.Generic.List[object]

# We expect filenames like m01/m01001.htm (HTML) or .txt; skip index files
$sectionRe = [Regex]'m(?<parva>\d{2})0*(?<sec>\d{1,3})\.(htm|html|txt)$'

foreach ($e in $entries) {
  $name = $e.FullName.Replace('\\','/').ToLowerInvariant()
  if ($name -notmatch $sectionRe) { continue }
  if ($name -like '*/index.*') { continue }
  $parvaCode = $Matches['parva']
  $secNo = [int]$Matches['sec']
  $parvaRel = 'm' + $parvaCode
  $parvaName = Get-ParvaName $parvaRel

  $sr = New-Object System.IO.StreamReader($e.Open())
  $raw = $sr.ReadToEnd(); $sr.Dispose()
  $text = Strip-Html $raw
  if (-not $text) { continue }

  # Heuristic: drop navigation tails
  $text = ($text -replace '\s+Previous:.*$', '').Trim()

  # Split into paragraphs on blank lines or sentence blocks
  $paras = @()
  $paras = ($text -split "(\r?\n){2,}") | ForEach-Object { $_.Trim() } | Where-Object { $_ }
  if (-not $paras -or $paras.Count -lt 2) {
    # fallback: split on ". " boundaries every ~400-800 chars
    $tmp = New-Object System.Collections.Generic.List[string]
    $buf = ''
    foreach ($seg in ($text -split '(?<=\.)\s+')) {
      if (($buf + ' ' + $seg).Length -gt 800) { if ($buf) { $tmp.Add($buf.Trim()) } $buf = $seg }
      else { $buf = ($buf ? ($buf + ' ' + $seg) : $seg) }
    }
    if ($buf.Trim()) { $tmp.Add($buf.Trim()) }
    $paras = $tmp
  }

  $v = 0
  foreach ($p in $paras) {
    $v++
    $records.Add([pscustomobject]@{
      volume_title = 'Hinduism'
      book_title   = "Mahabharata — $parvaName"
      chapter_number = $secNo
      verse_number = $v
      scripture_text = ($p -replace '\s+', ' ').Trim()
      verse_title = "Mahabharata — $parvaName Section $secNo ¶$v"
    })
  }
}

if (-not $records.Count) {
  Write-Host "No records parsed. Ensure the ZIP is the one from sacred-texts." -ForegroundColor Yellow
  exit 2
}

$json = $records | ConvertTo-Json -Depth 4 -Compress
Set-Content -Path $OutPath -Encoding UTF8 -NoNewline -Value $json
Write-Host "Wrote $($records.Count) records to $OutPath" -ForegroundColor Green

