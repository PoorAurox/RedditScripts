function Get-Month
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
        ParameterSetName='LongMonthNames')]
        [string]
        $Month,
        [Parameter(Mandatory = $true,
        ParameterSetName = 'ShortMonthNames')]
        [string]
        $AbbreviatedMonth,
        [Parameter(Mandatory = $true,
        ParameterSetName = 'DigitMonth')]
        [int]
        $NumMonth,
        [Parameter(Mandatory = $true)]
        [int]
        $Year
    )
    $culture = Get-Culture
    $curMonth = switch($PSCmdlet.ParameterSetName)
    {
        'LongMonthNames' {$culture.DateTimeFormat.MonthNames.IndexOf($Month) + 1}
        'ShortMonthNames' {$culture.DateTimeFormat.AbbreviatedMonthNames.IndexOf($AbbreviatedMonth) + 1}
        'DigitMonth' {$NumMonth}
    }
    $firstDayOfWeek = $culture.DateTimeFormat.DayNames.IndexOf($culture.DateTimeFormat.FirstDayOfWeek.ToString())
    #DateTimeFormat.DayNames isn't guaranteed to start on the first day of the week for the local culture. There's probably a better way but I am hacking it for now.
    $weekOrder = $firstDayOfWeek..($firstDayOfWeek + $culture.DateTimeFormat.DayNames.Count - 1) |  Foreach-Object {$_ % $culture.DateTimeFormat.DayNames.Count}
    #DateTime is always in the current culture. I need to figure out another way to test besides just set-culture.
    #This brings up an issue with en-gb having the first week of the year start on the first four day week. Using [System.Globalization.CalendarWeekRule]::FirstDay avoids this
    #Just another reason America is the best.
    $weeks = 1..($culture.Calendar.GetDaysInMonth($year, $curMonth)) | ForEach-Object { [DateTime]::New($year,$curMonth,$_, $culture.Calendar) } | Group-Object {$culture.Calendar.GetWeekOfYear($_, [System.Globalization.CalendarWeekRule]::FirstDay, $culture.DateTimeFormat.FirstDayOfWeek)}
    $weeks | Foreach-Object -Process {
        $week = "" | Select-Object $culture.DateTimeFormat.DayNames[$weekOrder]
        foreach($dayOfWeek in $culture.DateTimeFormat.DayNames)
        {
            $week.$dayOfWeek = $_.Group | Where-Object {$_.DayofWeek -eq $dayOfWeek} | Select-Object -ExpandProperty Day
        }
        $week
    }
}

Get-Month -Month February -Year 2023 | ft * -AutoSize