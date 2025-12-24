Param(
    [Alias('sz')]   [string]$szukaj
)

if ($PSBoundParameters.Count -lt 1) {
    "
    Trzeba podać jakieś opcje!:

    radio-browser.ps1 [OPCJE]

    Opcje:
        -szukaj [-sz] `"czego szukasz`"

    Przykład:
        radio-browser.ps1 -sz `"polskie`"

    "

    exit
}

# lista serwerów
$resp = Invoke-RestMethod -Method Get -AllowInsecureRedirect -Uri "http://all.api.radio-browser.info/json/servers"
$rndServer = $resp.name | Sort-Object -Unique | Get-Random

if ($szukaj) {
    Write-Output "Using $rndServer"
    # zapytanie
    $api = $rndServer
    $resp = Invoke-RestMethod -Method Get -Uri "$api/json/stations/search?name=$szukaj&hidebroken=true"
    $resp | Format-Table -Property name, countrycode, @{Label = "codec"; Expression = { $_.codec + " " + $_.bitrate } }, url_resolved
}
