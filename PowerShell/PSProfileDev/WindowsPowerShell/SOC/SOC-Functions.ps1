



Function Get-SOCUser {
    param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [String]$Name = $(throw "-Name is required.")
    )

    $ADUser = Get-ADUser -Identity $Name -Property *
    $ADGroups = Get-ADPrincipalGroupMembership $ADUser.SamAccountName | select name

    $SOCUser = New-Object -Type PSCustomObject -Property @{
        Identity = $ADUser.SamAccountName
	    DisplayName = $ADUser.DisplayName
	    DistinguishedName = $ADUser.DistinguishedName
	    Title = $ADUser.Title
	    EmployeeType = $ADUser.employeeType
	    Created = $ADUser.Created
	    Modified = $ADUser.Modified
	    Enabled = $ADUser.Enabled
	    LockedOut = $ADUser.LockedOut 
	    AccountLockoutTime = Convert-FileTime($ADUser.AccountLockoutTime)
	    LastLogonDate = Convert-FileTime($ADUser.LastLogon)
	    BadLogonCount = $ADUser.BadLogonCount
	    LastBadPasswordAttempt = Convert-FileTime($ADUser.badPasswordTime)
	    PasswordLastSet = Convert-FileTime($ADUser.PwdLastSet)
        PasswordExpired=$ADUser.PasswordExpired
	    PasswordNotRequired = $ADUser.PasswordNotRequired
	    PasswordNeverExpires = $ADUser.PasswordNeverExpires
	    AccountExpires = Convert-FileTime($ADUser.accountExpires)
	    LogonCount = $ADUser.logonCount
        LogonHours = $ADUser.logonHours
	    HomeDirectory = $ADUser.HomeDirectory
	    EmailAddress = $ADUser.EmailAddress
	    OfficePhone = $ADUser.OfficePhone
	    EmployeeID = $ADUser.EmployeeID
	    Company = $ADUser.Company
	    Department = $ADUser.Department
	    Office = $ADUser.Office
	    Organization = $ADUser.Organization
	    City = $ADUser.City
	    State = $ADUser.State
	    Country = $ADUser.Country
	    PrimaryGroup = $ADUser.PrimaryGroup
	    Groups = $ADGroups 
	    SID = $ADUser.SID
	    SIDHistory = $ADUser.SIDHistory
	    }

    $SOCUser | Add-Member -MemberType AliasProperty -Name SAMAccountName -Value Identity
    $SOCUser.PSObject.TypeNames.Insert(0,'SOC.Computer')

    return $SOCUser
}

Function Get-SOCComputer {
    param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [String]$Name = $(throw "-Name is required.")
    )
    write-host $Name
    
    $ADComputer = Get-ADComputer -Identity $Name -Property *

    $SOCComputer = New-Object -Type PSCustomObject -Property @{
      AccountLockoutTime = $ADComputer.AccountLockoutTime
      BadLogonCount = $ADComputer.BadLogonCount
      badPasswordTime = $ADComputer.badPasswordTime
      badPwdCount = $ADComputer.badPwdCount
      Created = $ADComputer.Created
      Deleted = $ADComputer.Deleted
      Description = $ADComputer.Description
      DisplayName = $ADComputer.DisplayName
      DNSHostName = $ADComputer.DNSHostName
      Enabled = $ADComputer.Enabled
      IPv4Address = $ADComputer.IPv4Address
      IPv6Address = $ADComputer.IPv6Address
      isDeleted = $ADComputer.isDeleted
      KerberosEncryptionType = $ADComputer.KerberosEncryptionType
      LastBadPasswordAttempt = $ADComputer.LastBadPasswordAttempt
      lastLogoff = Convert-FileTime($ADComputer.lastLogoff)
      lastLogon = Convert-FileTime($ADComputer.lastLogon)
      LastLogonDate = $ADComputer.LastLogonDate
      lastLogonTimestamp = $ADComputer.lastLogonTimestamp
      LockedOut = $ADComputer.LockedOut
      logonCount = $ADComputer.logonCount
      ManagedBy = $ADComputer.ManagedBy
      MemberOf = $ADComputer.MemberOf
      Modified = $ADComputer.Modified
      Name = $ADComputer.Name
      OperatingSystem = $ADComputer.OperatingSystem
      OperatingSystemHotfix = $ADComputer.OperatingSystemHotfix
      OperatingSystemServicePack = $ADComputer.OperatingSystemServicePack
      OperatingSystemVersion = $ADComputer.OperatingSystemVersion
      PasswordExpired = $ADComputer.PasswordExpired
      PrimaryGroup = $ADComputer.PrimaryGroup
      SamAccountName = $ADComputer.SamAccountName
      SID = $ADComputer.SID
      SIDHistory = $ADComputer.SIDHistory
      UseDESKeyOnly = $ADComputer.UseDESKeyOnly
      UserPrincipalName = $ADComputer.UserPrincipalName
      }

$SOCComputer.PSObject.TypeNames.Insert(0,'SOC.Computer')
return $SOCComputer      
}