# HibbAzurePS
Einfaches Powershell cmdlet zum erstellen von Azurenutzern, die Standardwerte sind auf die BS32 gesetzt.
## Vorraussetzungen
Sie müssen Administrator-Rechte in Ihrem AzureAd Tennant haben, Sie werden nach entsprechenden Logindaten gefragt.

### Installieren des Microsoft AzureAd-Moduls
Öffnen Sie Powershell als Administrator und geben Sie

install-module AzureAd

ein.
## Herrunterladen und Ausführen

Laden Sie die Datei Create-NewBs32AzurePupil.ps1 in ein Verzeichnis Ihrer wahl herrunter. Wechseln Sie in Powershell in dieses Verzeichnis

PS> cd <IhrVerzeichnis>

und geben:

./Create-NewBs32AzurePupil.ps1

ein. Nun steht der Befehl create-BsHibbUser zur Verfügung.

## Hilfe und Verwendung

get-help create-BsHibbUser -Examples

