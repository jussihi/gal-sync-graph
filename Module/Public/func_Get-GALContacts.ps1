Import-Module Microsoft.Graph.Users

function Get-GALContacts {
    [CmdletBinding()]
    param (
        [bool]$ContactsWithoutPhoneNumber,
        [bool]$ContactsWithoutEmail
    )
    try {
        Write-VerboseEvent "Getting GAL contacts"
        $allContacts = Get-MgUser -All
        if (-not $ContactsWithoutPhoneNumber) {
            $allContacts = $allContacts | Where-Object { $_.businessPhones -or $_.mobilePhone }
        }
        if (-not $ContactsWithoutEmail) {
            $allContacts = $allContacts | Where-Object { $_.mail }
        }
        $returnObject = @()
        $allContacts | ForEach-Object {
            $returnObject += [pscustomobject]@{
                businessPhones = $_.businessPhones
                displayname    = $_.displayName
                givenName      = $_.givenName
                surname        = $_.surname
                jobTitle       = $_.jobTitle                
                department     = $_.department
                homePhones     = $_.homePhones
                emailAddresses = @([pscustomobject]@{
                        name    = $_.displayName
                        address = $_.mail 
                    })
            }
        }
        Write-VerboseEvent "$($returnObject.count) contacts found"
        return $returnObject
    }
    catch {
        throw (Format-ErrorCode $_).ErrorMessage
    }
}