<#
.Synopsis
   
   Erstellt im Microsoft AzureAD einer HIBB-Schule (Standartwerte: hier der BS32) einen neuen Schüler gemäß der vorgaben des HIBB und CanCom. Es wird das offizielle AzureAD Modul benötigt. Führen sie also vor der Nutzung von Create-BS32User install-Module AzureAd aus.Quelle ist eine .csv die Vorname,Nachname, Klasse enthält.
   Umlaute und Sonderzeichen werden ersetzt, sollen also drin bleiben. Üblich ist der aufruf diese Cmdlet mit einer CSV. Siehe Beispiel

.DESCRIPTION
   **Vorraussetzung 1:**

   Starten Sie Powershell mit Adminstratoren-Rechten und installieren Sie das Powershell-Modul AzureAD
   PS> Install-Module AzureAd  
   **Vorraussetzung 2:**
   Für die Nutzung diese Programmes muss der Nutzer Administratoren-Rechte im jeweiligen AzureAd Tennant haben.
   
   Vor der Nutzung dieses PFür das anlegen eines Users wird ein Nutzertyp, Name, Vorname und Klasse benötigt.
   Dieses cmdlet nimmt ein oder mehrere Nutzerobjekte

.EXAMPLE
        install-module AzureAd
   
        # Einen Schüler erstellen der BS32 erstellen
        $einSchueler = [PSCustomObject]@{
                                        Vorname     = 'Kevin'
                                        Nachname = 'PowerShell'
                                        Klasse    = 'TG2202'
                                        }
        $einSchueler | create-BsHibbUser

.EXAMPLE
        Viele Schüler anlegen, (Szenario: Schuljahres beginn) und Logging einschalten

        import-csv ./userDaten.csv | Create-BsHibbUser -Logging
.EXAMPLE
        einen Lehrer an Schule BSXX anlegen
        $einLuL = [PSCustomObject]@{
                                        Vorname     = 'Maria'
                                        Nachname = 'Musterlehrerin'
                                        }
        $einLuL | create-BsHibbUser -userType "Lehrer" -domain "@bsxx.onmicrosoft.com" -Logging -write-Verbose
#>
function Create-BsHibbUser
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Die Nutzerobjekte
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [PSCustomObject[]]$nuser,
        # optional Nutzertyp der erstellt werden soll. Standartwert: "Schüler" (möglich: "Lehrer" und "Verwaltung")
        [ValidateSet("Schüler","Lehrer","Verwaltung")]
        [String]$userType = "Schüler",
        # optional Azure-Schuldomain default: '@bs32hh.onmicrosoft.com' 
        [String]$domain = '@bs32hh.onmicrosoft.com',
        # optional Einschalten des Loggings 
        [switch]$logging=$false,
        #optional alternativer Logpath Standartwert ist das aktuelle ist das aktuelle Verzeichnis
    )
    Begin
    {
        $send = 0
        $error = 0
        $credObject = Get-Credential
        Connect-AzureAD -Credential $credObject
        
        if($logging)
        {
            Write-Verbose "Logging eingeschaltet"
            $timestamp = Get-Date -UFormat "%d%m%Y"
            $rnd = Get-Random
            $logpath = ".\azureAD" + $timestamp + $rnd
            $logpath += ".txt" 
            New-Item -Path . -Name $logpath -ErrorAction SilentlyContinue -ErrorVariable myerr
             
             if($myerr){
            write-Verbose $myerr
            }
        }
    }
    Process
    {      
        $vorn = $nuser.Vorname
        $nachn = $nuser.Nachname
        $dpn = $vorn + ' ' + $nachn
        #umlaute, leerzeichen und sonderzeichen entfernen
        $resV = Replace-Umlaute($vorn)
        $vorn = $resV.Name
        
        $resN = Replace-Umlaute($nachn)
        $nachn = $resN.Name
        
        $upn = $vorn + '.' + $nachn + $domain

        $cl = $nuser.Klasse
        
        $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
        $PasswordProfile.Password = "BS32_2022"
#error handling
        New-AzureADUser -UserPrincipalName $upn -DisplayName $dpn -Department $userType -JobTitle $cl -AccountEnabled $true -PasswordProfile $PasswordProfile -MailNickName "BS-32-SchülerIn" -ErrorAction SilentlyContinue -ErrorVariable azureError
        if (! $azureError){
            "$upn, $dpn, - erstellt" | Add-Content $logpath
            $send += 1

        }else{
            $azureError.message | Add-Content $logpath
            $upn | Add-Content $logpath

            $error += 1
        }    
    }
    End
    {
        Write-Output "Es wurden $send erstellt, es traten $error Fehler auf"
    }
}
# Helperfunction Credits to
# source https://www.datenteiler.de/powershell-umlaute-ersetzen/
function Replace-Umlaute ([string]$s) {
    $UmlautObject = New-Object PSObject | Add-Member -MemberType NoteProperty -Name Name -Value $s -PassThru
 
    # Achtung Groß- und Kleinschreiung wird unterschieden 
 
    $characterMap = New-Object system.collections.hashtable
    $characterMap.ä = "ae"
    $characterMap.ö = "oe"
    $characterMap.ü = "ue"
    $characterMap.ß = "ss"
    $characterMap.Ä = "Ae"
    $characterMap.Ü = "Ue"
    $characterMap.Ö = "Oe"
    $characterMap.' ' = "-"
    $characterMap.é = "e"
    $characterMap.è = "e"
    $characterMap.à = "a"
    $characterMap.á = "a"
    $characterMap.Ş = "S"
 
    foreach ($property  in 'Name') { 
        foreach ($key in $characterMap.Keys) {
            $UmlautObject.$property = $UmlautObject.$property -creplace $key,$characterMap[$key] 
        }
    }
 
    $UmlautObject
}# ENDE - Replace-Umlaute 
