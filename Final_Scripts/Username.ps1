function addressUsername {
    $forbiddenUsernames = @(
        'admin'
        'andy'
        'honey'
        'john'
        'john doe'
        'malnetvm'
        'maltest'
        'malware'
        'roo'
        'sandbox'
        'snort'
        'tequilaboomboom'
        'test'
        'virus'
        'virusclone'
        'wilbert'
        'nepenthes'
        'currentuser'
        'username'
        'user'
        'vmware'
        'virtualbox')
    
    $currentUsername = [Environment]::UserName
    $usernameInList = $false
    foreach ($username in $forbiddenUsernames) {
        if ($currentUsername.ToLower() -eq $username.ToLower()) {
            $usernameInList = $true
            break
        }
    }
    if ($usernameInList) {
        try {
            $NewName = "Bob" # Remember to Change
            Rename-LocalUser -Name $currentUsername -NewName $NewName
        }
        catch {
            Write-Output "Unable to change username: $_"
        }
    }
}