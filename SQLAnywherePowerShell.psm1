function Split-DBUnloadSQLFileIntoSections {
    param (
        $Path
    )

    $DBUnloadSQL = Get-Content -Path $Path
    $SectionStartIndexNumbers = $DBUnloadSQL | foreach {
        if ($_ -match "--   Create ") {
            $DBUnloadSQL.IndexOf($_)
        }
    }
    
    $LastIndex = $SectionStartIndexNumbers.Count-1

    $Sections =  @("") * $SectionStartIndexNumbers.Count
    foreach ($Index in 0..$LastIndex) {
        $StartOfSection = $SectionStartIndexNumbers[$Index]+2
        $EndOfSection = if ($Index -eq $LastIndex) {
            $DBUnloadSQL.Length
        } else {
            $SectionStartIndexNumbers[$Index+1]-2
        }
        #$StartOfSection
        #$EndOfSection
        #$DBUnloadSQL[$StartOfSection..$EndOfSection] | measure
        $Sections[$Index] = $DBUnloadSQL[$StartOfSection..$EndOfSection]
    }
}

function Get-DatabaseNames {
    param (
        $ConnectionString
    )
    $Query = "select db_name( number ) from sa_db_list();"
    Invoke-SQLAnywhereSQL -ConnectionString $ConnectionString -SQLCommand $Query -ConvertFromDataRow
}

function Get-SQLAnywhereConnection {
    param (
        $ConnectionString
    )
    $Query = @"
SELECT *, 
    DB_NAME( DBNumber ) as DBName, 
    CONNECTION_PROPERTY( 'LastStatement', Number ) as LastStatement
FROM sa_conn_info( );
"@
    Invoke-SQLAnywhereSQL -ConnectionString $ConnectionString -SQLCommand $Query -ConvertFromDataRow
}

function Remove-SQLAnywhereConnection {
    param (
        [Parameter(Mandatory)]$ConnectionString,
        [Parameter(Mandatory)]$ID
    )
    $Query = @"
    DROP CONNECTION $ID;
"@
    Invoke-SQLAnywhereSQL -ConnectionString $ConnectionString -SQLCommand $Query -ConvertFromDataRow
}

function Get-SQLAnywhereConnectionUniqueIPs {
    param (
        $ConnectionString
    )
    Get-SQLAnywhereConnection -ConnectionString $ConnectionString |
    Sort-Object -Unique
}