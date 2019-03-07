# AbstractTable FHEM Module

This module can render device with numbered readings as a table. (e.g. CALVIEW, PROPLANTA, Wunderlist, Todoist, CALLMONITOR, allergy, DBPlan, ...)

But: This module is still under development. Please report any issues.

## Installation

```
update add https://raw.githubusercontent.com/klein0r/fhem-abstracttable/master/controls_abstracttable.txt
update check abstracttable
update all abstracttable
```

## Usage

Device is the source of the readings

```
define <name> abstracttable [device]
```

You have to specify at least ```table-rowtemplate```. This attribute must contain a comma seperated list of readings. You have to add the placeholder for the number in each reading.

Examples:

- ```t_%d_age,t_%d_summary``` will try to get the reading ```t_0_age``` for the first column and ```t_0_summary``` for the second column.
- ```t_%03d_age,t_%02d_summary``` will try to get the reading ```t_000_age``` for the first column and ```t_00_summary``` for the second column.

You can use all conversions supported by [sprintf](https://perldoc.perl.org/functions/sprintf.html).

The iteration will stop when no column for the current row has returned a value.

## Examples

### CALVIEW-Device

```
define tabelle_birthdays abstracttable GeburstagsKalenderView
attr tabelle_birthdays table-header Date,Days,Age,Who
attr tabelle_birthdays table-rowtemplate t_%03d_bdate,t_%03d_daysleftLong,t_%03d_age,t_%03d_summary
attr tabelle_birthdays table-startindex 1
```

### Wunderlist

```
define table_wunderlist abstracttable Wunderlist
attr table_wunderlist table-header ID,Title
attr table_wunderlist table-rowtemplate Task_%03d_ID,Task_%03d
```

### FB_CALLLIST

```
define table_calllist abstracttable Anrufhistorie
attr table_calllist table-header connection,duration,number
attr table_calllist table-rowtemplate %d-connection,%d-duration,%d-number
attr table_calllist table-startindex 1
```

### allergy

```
define table_allergy abstracttable OUT_Allergie
attr table_allergy table-header Wochentag,Maximum,Erle,Hasel,Roggen
attr table_allergy table-rowtemplate fc%d_day_of_week,fc%d_maximum,fc%d_Erle,fc%d_Hasel,fc%d_Roggen
attr table_allergy table-startindex 1
```

### DBPlan

```
define table_bahnhof abstracttable OUT_BahnBahnhof
attr table_bahnhof table-header Linie,Umsteigen,Typ,Abfahrt,Dauer,Verspätung,Ankunft,Ziel,Preis
attr table_bahnhof table-rowtemplate travel_vehicle_nr_%d,plan_travel_change_%d,plan_connection_%d,plan_departure_%d,plan_travel_duration_%d,plan_arrival_delay_%d,plan_arrival_%d,travel_destination_%d,travel_price_%d
attr table_bahnhof table-startindex 1
```

### Screenshot

![FHEM Style](https://raw.githubusercontent.com/klein0r/fhem-abstracttable/master/preview.png)

## License

MIT License

Copyright (c) 2019 Matthias Kleine

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
