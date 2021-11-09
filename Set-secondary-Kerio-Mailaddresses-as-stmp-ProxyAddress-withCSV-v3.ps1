# Festlegen der Maildomain für die einzustellenden Proxy-Addresses nach dem Schema "maildomain.com"
$SMTPDomain = Read-Host "Bitte die zu verwendende Maildomain eintragen (Bsp.: maildomain.com)"

# Hier muss der Pfad zur CSV-Datei angegeben werden.
$CSVPATH = Read-Host "Bitte geb den absoluten Pfad zur CSV-Datei an"

$USERS = Import-Csv -Delimiter ";" -Path "$CSVPATH"
$USERS | Foreach {
    Write-Host $_.SamAccountName
    ForEach ($ext in ($_.MailAddress -split ",")) {
        Write-Host "smtp:"$ext"@"$SMTPDomain
    }
}

# Der Benutzer muss den Wert "Y" eingeben um den Vorgang zu bestätigen!
# Wenn der Wert leer gelassen wird oder von "Y" abweicht wird das Skript abgebrochen!
$WAHL = Read-Host -Prompt "Gebe (Y) ein wenn die oben gelisteten Einträge in das Attribut (proxyAddresses) geschriben werden sollen!"

# Es wird vorrausgesetzt, dass der Benutzer zuvor in der Abfrage den Wert "Y" eingegeben hat!
    if ($WAHL -eq "Y") {

# Ausführen des Set-Befehls
# Dieser Befehl setzt alle zuvor gelisteten, sekundären E-Mail-Adressen in das AD-Attribut "ProxyAddresses"
        $USERS | Foreach {
            ForEach ($ext in ($_.MailAddress -split ",")) {
                Set-ADUser -Identity $_.SamAccountName -Add @{
                    Proxyaddresses="smtp:"+$ext+"@"+$SMTPDomain
                }
            }           
        }

# Ausgabe ob das Skript nach der Bestätigung ausgeführt wurde oder nicht
        Write-Host "Alle Einträge wurden wie beschrieben erfolglreich in das Attribut (proxyAddresses) geschrieben!"
        Read-Host
    } else {
        Write-Host "Es wurden keine Einstellungen angepasst!"
        Read-Host
        exit
}
