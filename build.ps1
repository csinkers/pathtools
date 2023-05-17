if (Test-Path "out") { Remove-Item -Recurse out }
mkdir out >$null
if (!(Test-Path local)) { mkdir local >$null }

$options = @(
    "common",
    "common_win",
    "gnutools",
    "colemak",
    "colemak_win",
    "dev",
    "dev_win",
    "local"
)

foreach ($dirName in $options) {
    echo "`nProcessing $dirName"
    $prefix = (Get-Item $dirName).FullName

    Get-ChildItem -Recurse $dirName |
    Foreach-Object {
        if (!($_ -is [System.IO.FileInfo])) { return }

        $relativePath = $_.FullName -replace [regex]::Escape($prefix + "\")
        $newPath = "out\$relativePath"

        Try {

            if (Test-Path $newPath) {
                echo " > $newPath"
                if ($_.Extension | Where-Object { ".exe", ".dll" -contains $_ }) {
                    throw [InvalidOperationException] "Tried to append to existing file $newPath while processing $dirName"
                }

                $content = Get-Content -Path $_.FullName
                Add-Content -Path $newPath $content
            }
            else {
                echo " + $newPath"
                New-Item -ItemType File -Path $newPath -Force >$null
                Copy-Item -LiteralPath $_.FullName $newPath -Force
            }
        }
        Catch
        {
            echo $_.Exception.Message
        }
    }
}

