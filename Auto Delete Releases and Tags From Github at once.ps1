# Repository
# Run in Powercell
$repo = "mrgargsir/HEWPExcelADDins"
$cutoff = 670000   # version limit to delete
#$dryRun = $true   # change to $false to actually delete
$dryRun = $false

Write-Host "Fetching releases from $repo ..." -ForegroundColor Green
$releases = gh release list --repo $repo --limit 1000 --json tagName | ConvertFrom-Json

foreach ($release in $releases) {
    $tag = $release.tagName
    if (-not $tag) { continue }

    $num = $tag -replace '\.', ''

    if ([int]$num -lt $cutoff) {
        if ($dryRun) {
            Write-Host "Would delete release & tag: $tag" -ForegroundColor Yellow
        } else {
            Write-Host "Deleting release & tag: $tag" -ForegroundColor Red
            gh release delete $tag --repo $repo -y
            git push https://github.com/$repo.git :refs/tags/$tag
        }
    }
}

Write-Host "Fetching tags from $repo ..." -ForegroundColor Green
$tags = gh api repos/$repo/git/refs/tags | ConvertFrom-Json

foreach ($tagRef in $tags) {
    $tag = $tagRef.ref -replace '^refs/tags/', ''
    $num = $tag -replace '\.', ''

    if ([int]$num -lt $cutoff) {
        if ($dryRun) {
            Write-Host "Would delete tag: $tag" -ForegroundColor Cyan
        } else {
            Write-Host "Deleting tag: $tag" -ForegroundColor Magenta
            $refPath = "repos/$repo/git/refs/tags/$tag"
            gh api --method DELETE $refPath
        }
    }
}
