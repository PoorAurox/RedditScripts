    #$culture = Get-Culture
    $culture = [cultureinfo]::GetCultureInfo('en-gb')
    $year = 2021
    foreach($month in $culture.DateTimeFormat.MonthNames | Select-Object -SkipLast 1)
    {
        $cardinalMonth = $culture.DateTimeFormat.MonthNames.indexof($month) + 1
        $firstDayOfWeek = $culture.DateTimeFormat.DayNames.IndexOf($culture.DateTimeFormat.FirstDayOfWeek.ToString())
        #DateTimeFormat.DayNames isn't guaranteed to start on the first day of the week for the local culture. There's probably a better way but I am hacking it for now.
        $weekOrder = $firstDayOfWeek..($firstDayOfWeek + $culture.DateTimeFormat.DayNames.Count - 1) |  Foreach-Object {$_ % $culture.DateTimeFormat.DayNames.Count}
        #DateTime is always in the current culture. I need to figure out another way to test besides just set-culture.
        #This brings up an issue with en-gb having the first week of the year start on the first four day week. It could cause issues with the first and last weeks of the year.
        #Just another reason America is the best.
        $weeks = 1..($culture.Calendar.GetDaysInMonth($year, $cardinalMonth)) | ForEach-Object { [DateTime]::New($year,$cardinalMonth,$_, $culture.Calendar) } | Group-Object {$culture.Calendar.GetWeekOfYear($_, $culture.DateTimeFormat.CalendarWeekRule, $culture.DateTimeFormat.FirstDayOfWeek)}
        $weeks | Foreach-Object -Process {
            $week = "" | Select-Object $culture.DateTimeFormat.DayNames[$weekOrder]
            foreach($dayOfWeek in $culture.DateTimeFormat.DayNames)
            {
                $week.$dayOfWeek = $_.Group | Where-Object {$_.DayofWeek -eq $dayOfWeek} | Select-Object -ExpandProperty Day
            }
            $week
        } | Export-Csv "$year$month.csv" -NoTypeInformation
    } 