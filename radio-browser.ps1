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
# $resp = Invoke-RestMethod -Method Get -AllowInsecureRedirect -Uri "http://all.api.radio-browser.info/json/servers"
# Write-Output $resp | Sort-Object -Unique -Property name

if ($szukaj) {
    
    # zapytanie
    $api = "https://nl1.api.radio-browser.info"

    $resp = Invoke-RestMethod -Method Get -Uri "$api/json/stations/search?name=$szukaj&hidebroken=true"

    $resp | Format-Table -Property name, countrycode, @{Label = "codec"; Expression = { $_.codec + " " + $_.bitrate } }, url_resolved
	}
