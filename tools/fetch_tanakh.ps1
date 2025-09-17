$ErrorActionPreference = 'Stop'

# Fetch Tanakh (JPS 1917 English) via Sefaria API and emit our standard schema.
# Output: tanakh_standard_works.json (UTF-8, no BOM)

$torah   = @('Genesis','Exodus','Leviticus','Numbers','Deuteronomy')
$neviim  = @('Joshua','Judges','I Samuel','II Samuel','I Kings','II Kings','Isaiah','Jeremiah','Ezekiel','Hosea','Joel','Amos','Obadiah','Jonah','Micah','Nahum','Habakkuk','Zephaniah','Haggai','Zechariah','Malachi')
$ketuvim = @('Psalms','Proverbs','Job','Song of Songs','Ruth','Lamentations','Ecclesiastes','Esther','Daniel','Ezra','Nehemiah','I Chronicles','II Chronicles')

function Get-ChapterCount($book) {
  $idx = (Invoke-WebRequest -UseBasicParsing "https://www.sefaria.org/api/index/$([uri]::EscapeDataString($book))" -TimeoutSec 20).Content | ConvertFrom-Json
  return [int]$idx.schema.lengths[0]
}

function Get-ChapterVerses($book, $chapter) {
  $u = "https://www.sefaria.org/api/texts/$([uri]::EscapeDataString($book)).$chapter?lang=en&version=JPS%201917"
  $attempts = 0
  for ($try=1; $try -le 8; $try++) {
    try {
      $resp = (Invoke-WebRequest -UseBasicParsing $u -TimeoutSec 30).Content | ConvertFrom-Json
      if ($null -ne $resp.text -and $resp.text.Count -gt 0) { return ,$resp.text }
      Start-Sleep -Milliseconds 400
    } catch {
      Start-Sleep -Milliseconds ([Math]::Min(5000, 250 * $try))
    }
  }
  throw "Failed to fetch $book $chapter after retries"
}

function Clean-Text($s) {
  if (-not $s) { return '' }
  $t = [string]$s
  $t = [System.Text.RegularExpressions.Regex]::Replace($t, '<[^>]+>', '')
  $t = $t -replace '\r|\n', ' '
  $t.Trim()
}

function Add-Section($books, $volume, [System.Collections.Generic.List[object]]$rows) {
  foreach ($b in $books) {
    Write-Host ("Processing {0} ({1})" -f $b, $volume) -ForegroundColor Cyan
    $chapters = Get-ChapterCount $b
    for ($c=1; $c -le $chapters; $c++) {
      $verses = Get-ChapterVerses $b $c
      for ($i=0; $i -lt $verses.Count; $i++) {
        $vno = $i + 1
        $text = Clean-Text $verses[$i]
        $rows.Add([pscustomobject]@{
          volume_title   = $volume
          book_title     = $b
          chapter_number = $c
          verse_number   = $vno
          scripture_text = $text
          verse_title    = "$b $c`:$vno"
        })
      }
      # light throttle to be kind to the API
      Start-Sleep -Milliseconds 120
    }
  }
}

$rows = New-Object System.Collections.Generic.List[object]

Add-Section -books $torah   -volume 'Torah'   -rows $rows
Add-Section -books $neviim  -volume "Nevi'im" -rows $rows
Add-Section -books $ketuvim -volume 'Ketuvim' -rows $rows

$dest = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'tanakh_standard_works.json'
($rows | ConvertTo-Json -Depth 5 -Compress) | Set-Content -Path $dest -Encoding UTF8
Write-Host ("Wrote {0} with {1} verses across {2} books." -f $dest, $rows.Count, ($torah.Count + $neviim.Count + $ketuvim.Count)) -ForegroundColor Green

