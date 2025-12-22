Param(
    [Alias('sz')]   [string]$szukaj,
    [Alias('st')]   [string]$stacja
)

function printc($tekst, $kolor = "White") {
    # black, blue, cyan, darkblue, darkcyan, darkgray, darkgreen, darkmagenta, darkred, darkyellow, gray, green, magenta, red, white, yellow
    $fg = $host.ui.RawUI.ForegroundColor
    $host.ui.RawUI.ForegroundColor = $kolor
    Write-Output $tekst
    $host.ui.RawUI.ForegroundColor = $fg
}

if ($PSBoundParameters.Count -lt 1) {
    "
    Trzeba podać jakieś opcje!:

    szukacz.ps1 [OPCJE]

    Opcje:
        -szukaj [-sz] `"czego szukasz`"
        -stacja [-st] `"ID stacji`"

    Przykład:
        szukacz.ps1 -sz `"polskie`"

    Czyli: najsampierw szukasz stacji -szukaj costamcostam
    po znalezieniu stacji dowiadujesz się o szczegółach
    za pomocą -stacja IDstacji z poprzedniego szukania


    "

    exit
}

if ($szukaj) {
    $resp = Invoke-RestMethod -Uri "http://opml.radiotime.com/Search.ashx?query=$szukaj&types=station"

    foreach ($item in $resp.opml.body.outline[0..15]) {
        if ($item.type -eq "audio") {
            printc -tekst $item.text -kolor "Yellow"
            printc -tekst " - Info: $($item.subtext)"
            printc -tekst " - Format: $($item.formats)/$($item.bitrate)"
            printc -tekst " - ID: $($item.guide_id)" -kolor "Green"
        }
    }
}

if ($stacja) {

    $resp = Invoke-RestMethod -Uri "https://opml.radiotime.com/describe.ashx?id=$stacja"

    $descr = $resp.opml.body.outline.station

    printc -tekst "Informacje o $($descr.name)" -kolor "yellow"
    printc "Slogan: $($descr.slogan)"
    printc "Rodzaj: $($descr.genre_name) / $($descr.content_classification)"
    printc "Lokalizacja: $($descr.location) / $($descr.language)"

    $resp = Invoke-WebRequest -Uri "https://opml.radiotime.com/tune.ashx?id=$stacja" | Select-Object -ExpandProperty Content
    printc -tekst $([System.Text.Encoding]::UTF8.GetString($resp)) -kolor "cyan"
}
