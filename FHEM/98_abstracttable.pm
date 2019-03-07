###############################################################################
#
# A module to render an abstract table based on enumerated readings
#
# written 2019 by Matthias Kleine <info at haus-automatisierung.com>
#
###############################################################################

package main;

use strict;
use warnings;

#####################################
sub abstracttable_Initialize($)
{
    my ($hash) = @_;
    
    $hash->{DefFn} = "abstracttable_Define";
    $hash->{AttrList} = "table-startindex table-colgroup table-header table-rowtemplate table-footer";

    #$hash->{FW_summaryFn} = "abstracttable_FwFn";
    $hash->{FW_detailFn}  = "abstracttable_FwFn";

    $hash->{FW_addDetailToSummary} = 1;
    $hash->{FW_deviceOverview} = 1;

    $hash->{FW_atPageEnd} = 0;
}

#####################################
sub abstracttable_Define($$)
{
    my ($hash, $def) = @_;

    my @args = split("[ \t]+", $def);

    return "Invalid number of arguments: define <name> abstracttable <device>" if (int(@args) < 1);

    my ($name, $type, $device) = @args;

    if (defined($defs{$device})) {
        $hash->{DEVICE} = $device;
        $hash->{MODULE_VERSION} = "0.1";

        return undef;
    }
    else {
        return "device missing";
    }
}

sub abstracttable_FwFn($$$$)
{
    my ($FW_wname, $d, $room, $pageHash) = @_;
    my $hash = $defs{$d};
    my $device = $hash->{DEVICE};

    my $ret = "";

    return $ret if (IsDisabled($d));

    my $tableStartIndex = AttrVal($d, "table-startindex", 0);
    my $tableColgroup = AttrVal($d, "table-colgroup", "");
    my $tableHeader = AttrVal($d, "table-header", "");
    my $tableRowTemplate = AttrVal($d, "table-rowtemplate", "");
    my $tableFooter = AttrVal($d, "table-footer", "");

    my $rows = 0;

    if ($tableRowTemplate) {
        $ret .= '<table class="block wide abstract-table">';

        if ($tableHeader) {
            $ret .= '<thead>';
            $ret .= '<tr>';
            $ret .= '<th>' . join('</th><th>', split(/,/, $tableHeader)) . '</th>';
            $ret .= '</tr>';
            $ret .= '</thead>';
        }

        $ret .= '<tbody>';

        my @tableColumns = split(/,/, $tableRowTemplate);
        my $lastRowWithValue = 1;
        my $currentIndex = $tableStartIndex;

        while ($lastRowWithValue) {
            $lastRowWithValue = 0;

            my @currentRow = ();

            foreach my $column (@tableColumns) {
                my $val = ReadingsVal($device, sprintf($column, $currentIndex), undef);

                if (defined($val)) {
                    $lastRowWithValue = 1;
                }

                push(@currentRow, $val);
            }

            if ($lastRowWithValue) {
                $ret .= '<tr class="' . ($currentIndex % 2 == 0 ? 'even' : 'odd') . '">';
                $ret .= '<td>' . join('</td><td>', @currentRow) . '</td>';
                $ret .= '</tr>';

                Log3($d, 5, "Found values: " . join(', ', @currentRow));
                $rows++;
            }

            $currentIndex++;
        }

        $ret .= '</tbody>';

        if ($tableFooter) {
            $ret .= '<tfoot>';
            $ret .= '<tr>';
            $ret .= '<td>' . join('</td><td>', split(/,/, $tableFooter)) . '</td>';
            $ret .= '</tr>';
            $ret .= '</tfoot>';
        }

        $ret .= '</table>';
    }

    readingsSingleUpdate($hash, "state", $rows, 1);

    return $ret;
}

1;

=pod
=item helper
=item summary generate a table for FHEMWEB frontend
=item summary_DE Tabellen-Generator für das FHEMWEB Frontend
=begin html

<a name="abstracttable"></a>
<h3>abstracttable</h3>
<ul>
  <a name="abstracttabledefine"></a>
  <b>Define</b>
  <ul>
    <code>define &lt;name&gt; abstracttable [device]</code>
    <br><br>
    This module can be used to render device readings which contain counters (e.g. CALVIEW, PROPLANTA, Wunderlist, Todoist, CALLMONITOR, allergy, DBPlan, ...)
    <br><br>
    Examples:
    <ul>
      <code>
        define tabelle_birthdays abstracttable GeburstagsKalenderView<br>
        attr tabelle_birthdays table-header Date,Days,Age,Who<br>
        attr tabelle_birthdays table-rowtemplate t_%03d_bdate,t_%03d_daysleftLong,t_%03d_age,t_%03d_summary<br>
        attr tabelle_birthdays table-startindex 1<br>
      </code>
      <br>
      <code>
        define table_wunderlist abstracttable Wunderlist<br>
        attr table_wunderlist table-header ID,Title<br>
        attr table_wunderlist table-rowtemplate Task_%03d_ID,Task_%03d<br>
      </code>
      <br>
      <code>
        define table_calllist abstracttable Anrufhistorie<br>
        attr table_calllist table-header connection,duration,number<br>
        attr table_calllist table-rowtemplate %d-connection,%d-duration,%d-number<br>
        attr table_calllist table-startindex 1<br>
      </code>
      <br>
      <code>
        define table_allergy abstracttable OUT_Allergie
        attr table_allergy table-header Wochentag,Maximum,Erle,Hasel,Roggen
        attr table_allergy table-rowtemplate fc%d_day_of_week,fc%d_maximum,fc%d_Erle,fc%d_Hasel,fc%d_Roggen
        attr table_allergy table-startindex 1
      </code>
      <br>
      <code>
        define table_bahnhof abstracttable OUT_BahnBahnhof
        attr table_bahnhof table-header Linie,Umsteigen,Typ,Abfahrt,Dauer,Verspätung,Ankunft,Ziel,Preis
        attr table_bahnhof table-rowtemplate travel_vehicle_nr_%d,plan_travel_change_%d,plan_connection_%d,plan_departure_%d,plan_travel_duration_%d,plan_arrival_delay_%d,plan_arrival_%d,travel_destination_%d,travel_price_%d
        attr table_bahnhof table-startindex 1
      </code>
    </ul>
    <br>

    Notes:
    <ul>
      <li>The interation will stop if no column returns a value in the current row</li>
    </ul>
  </ul>

  <a name="weblinkset"></a>
  <b>Set</b> <ul>N/A</ul><br>

  <a name="weblinkget"></a>
  <b>Get</b> <ul>N/A</ul><br>

  <a name="weblinkattr"></a>
  <b>Attributes</b>
  <ul>
    <a name="table-header"></a>
    <li>
      table-header<br>
      Comma separated list of header row
    </li>

    <a name="table-colgroup"></a>
    <li>
      table-colgroup<br>
      Comma separated list of column widths in percent
    </li>

    <a name="table-footer"></a>
    <li>
      table-footer<br>
      Comma separated list of footer row
    </li>

    <a name="table-startindex"></a>
    <li>
      table-startindex<br>
      Number where to search for the first reading (default: 0)
    </li>

    <a name="table-rowtemplate"></a>
    <li>
      table-rowtemplate<br>
      Comma seperated list of columns with placeholder for index.<br>
      Each column value will be passed to sprintf to fill current index<br>
      <br>
      Examples:<br>
      <code>row_%d</code> will be converted to <code>row_0</code> (where 0 is the current index)<br/>
      <code>row_%03d</code> will be converted to <code>row_000</code> (where 0 is the current index)<br/>
      <code>row_%d_suffix</code> will be converted to <code>row_0_suffix</code> (where 0 is the current index)<br/>
    </li>

    <li><a href="#disable">disable</a></li>
    <li><a href="#disabledForIntervals">disabledForIntervals</a></li>
  </ul>

  <br>
</ul>

=end html
=cut
