function Log {
<# 
 .Synopsis
  Function to log input string to file and display it to screen

 .Description
  Function to log input string to file and display it to screen. Log entries in the log file are time stamped. Function allows for displaying text to screen in different colors.

 .Parameter String
  The string to be displayed to the screen and saved to the log file

 .Parameter Color
  The color in which to display the input string on the screen
  Default is White
  Valid options are
    Black
    Blue
    Cyan
    DarkBlue
    DarkCyan
    DarkGray
    DarkGreen
    DarkMagenta
    DarkRed
    DarkYellow
    Gray
    Green
    Magenta
    Red
    White
    Yellow

 .Parameter LogFile
  Path to the file where the input string should be saved.
  Example: c:\log.txt
  If absent, the input string will be displayed to the screen only and not saved to log file

 .Example
  Log -String "Hello World" -Color Yellow -LogFile c:\log.txt
  This example displays the "Hello World" string to the console in yellow, and adds it as a new line to the file c:\log.txt
  If c:\log.txt does not exist it will be created.
  Log entries in the log file are time stamped. Sample output:
    2014.08.06 06:52:17 AM: Hello World

 .Example
  Log "$((Get-Location).Path)" Cyan
  This example displays current path in Cyan, and does not log the displayed text to log file.

 .Example 
  "Java process ID is $((Get-Process -Name java).id )" | log -color Yellow
  Sample output of this example:
    "Java process ID is 4492" in yellow

 .Example
  "Drive 'd' on VM 'CM01' is on VHDX file '$((Get-SBVHD CM01 d).VHDPath)'" | log -color Green -LogFile D:\Sandbox\Serverlog.txt
  Sample output of this example:
    Drive 'd' on VM 'CM01' is on VHDX file 'D:\VMs\Virtual Hard Disks\CM01_D1.VHDX'
  and the same is logged to file D:\Sandbox\Serverlog.txt as in:
    2014.08.06 07:28:59 AM: Drive 'd' on VM 'CM01' is on VHDX file 'D:\VMs\Virtual Hard Disks\CM01_D1.VHDX'

 .Link
  https://superwidgets.wordpress.com/category/powershell/

 .Notes
  Function by Sam Boutros
  v1.0 - 08/06/2014

#>

    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')] 
    Param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeLine=$true,
                   ValueFromPipeLineByPropertyName=$true,
                   Position=0)]
            [String]$String, 
        [Parameter(Mandatory=$false,
                   Position=1)]
            [ValidateSet("Black","Blue","Cyan","DarkBlue","DarkCyan","DarkGray","DarkGreen","DarkMagenta","DarkRed","DarkYellow","Gray","Green","Magenta","Red","White","Yellow")]
            [String]$Color = "White", 
        [Parameter(Mandatory=$false,
                   Position=2)]
            [String]$LogFile
    )

    write-host $String -foregroundcolor $Color 
    if ($LogFile.Length -gt 2) {
        ((Get-Date -format "yyyy.MM.dd hh:mm:ss tt") + ": " + $String) | out-file -Filepath $Logfile -append
    } else {
        Write-Verbose "Log: Missing -LogFile parameter. Will not save input string to log file.."
    }
}


function ConvertTo-EnhancedHTML {
<#
.SYNOPSIS
Provides an enhanced version of the ConvertTo-HTML command that includes
inserting an embedded CSS style sheet, JQuery, and JQuery Data Tables for
interactivity. Intended to be used with HTML fragments that are produced
by ConvertTo-EnhancedHTMLFragment. This command does not accept pipeline
input.

.PARAMETER jQueryURI
A Uniform Resource Indicator (URI) pointing to the location of the 
jQuery script file. You can download jQuery from www.jquery.com; you should
host the script file on a local intranet Web server and provide a URI
that starts with http:// or https://. Alternately, you can also provide
a file system path to the script file, although this may create security
issues for the Web browser in some configurations.

Tested with v1.8.2.

Defaults to http://ajax.aspnetcdn.com/ajax/jQuery/jquery-1.8.2.min.js, which
will pull the file from Microsoft's ASP.NET Content Delivery Network.

.PARAMETER jQueryDataTableURI
A Uniform Resource Indicator (URI) pointing to the location of the 
jQuery Data Table script file. You can download this from www.datatables.net;
you should host the script file on a local intranet Web server and provide a URI
that starts with http:// or https://. Alternately, you can also provide
a file system path to the script file, although this may create security
issues for the Web browser in some configurations.

Tested with jQuery DataTable v1.9.4

Defaults to http://ajax.aspnetcdn.com/ajax/jquery.dataTables/1.9.3/jquery.dataTables.min.js,
which will pull the file from Microsoft's ASP.NET Content Delivery Network.

.PARAMETER CssStyleSheet
The CSS style sheet content - not a file name. If you have a CSS file,
you can load it into this parameter as follows:

    -CSSStyleSheet (Get-Content MyCSSFile.css)

Alternately, you may link to a Web server-hosted CSS file by using the
-CssUri parameter.

.PARAMETER CssUri
A Uniform Resource Indicator (URI) to a Web server-hosted CSS file.
Must start with either http:// or https://. If you omit this, you
can still provide an embedded style sheet, which makes the resulting
HTML page more standalone. To provide an embedded style sheet, use
the -CSSStyleSheet parameter.

.PARAMETER Title
A plain-text title that will be displayed in the Web browser's window
title bar. Note that not all browsers will display this.

.PARAMETER PreContent
Raw HTML to insert before all HTML fragments. Use this to specify a main
title for the report:

    -PreContent "<H1>My HTML Report</H1>"

.PARAMETER PostContent
Raw HTML to insert after all HTML fragments. Use this to specify a 
report footer:

    -PostContent "Created on $(Get-Date)"

.PARAMETER HTMLFragments
One or more HTML fragments, as produced by ConvertTo-EnhancedHTMLFragment.

    -HTMLFragments $part1,$part2,$part3
.EXAMPLE
The following is a complete example script showing how to use
ConvertTo-EnhancedHTMLFragment and ConvertTo-EnhancedHTML. The
example queries 6 pieces of information from the local computer
and produces a report in C:\. This example uses most of the
avaiable options. It relies on Internet connectivity to retrieve
JavaScript from Microsoft's Content Delivery Network. This 
example uses an embedded stylesheet, which is defined as a here-string
at the top of the script.

$computername = 'localhost'
$path = 'c:\'
$style = @"
<style>
body {
    color:#333333;
    font-family:Calibri,Tahoma;
    font-size: 10pt;
}
h1 {
    text-align:center;
}
h2 {
    border-top:1px solid #666666;
}


th {
    font-weight:bold;
    color:#eeeeee;
    background-color:#333333;
    cursor:pointer;
}
.odd  { background-color:#ffffff; }
.even { background-color:#dddddd; }
.paginate_enabled_next, .paginate_enabled_previous {
    cursor:pointer; 
    border:1px solid #222222; 
    background-color:#dddddd; 
    padding:2px; 
    margin:4px;
    border-radius:2px;
}
.paginate_disabled_previous, .paginate_disabled_next {
    color:#666666; 
    cursor:pointer;
    background-color:#dddddd; 
    padding:2px; 
    margin:4px;
    border-radius:2px;
}
.dataTables_info { margin-bottom:4px; }
.sectionheader { cursor:pointer; }
.sectionheader:hover { color:red; }
.grid { width:100% }
.red {
    color:red;
    font-weight:bold;
} 
</style>
"@

function Get-InfoOS {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True)][string]$ComputerName
    )
    $os = Get-WmiObject -class Win32_OperatingSystem -ComputerName $ComputerName
    $props = @{'OSVersion'=$os.version;
               'SPVersion'=$os.servicepackmajorversion;
               'OSBuild'=$os.buildnumber}
    New-Object -TypeName PSObject -Property $props
}

function Get-InfoCompSystem {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True)][string]$ComputerName
    )
    $cs = Get-WmiObject -class Win32_ComputerSystem -ComputerName $ComputerName
    $props = @{'Model'=$cs.model;
               'Manufacturer'=$cs.manufacturer;
               'RAM (GB)'="{0:N2}" -f ($cs.totalphysicalmemory / 1GB);
               'Sockets'=$cs.numberofprocessors;
               'Cores'=$cs.numberoflogicalprocessors}
    New-Object -TypeName PSObject -Property $props
}

function Get-InfoBadService {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True)][string]$ComputerName
    )
    $svcs = Get-WmiObject -class Win32_Service -ComputerName $ComputerName `
           -Filter "StartMode='Auto' AND State<>'Running'"
    foreach ($svc in $svcs) {
        $props = @{'ServiceName'=$svc.name;
                   'LogonAccount'=$svc.startname;
                   'DisplayName'=$svc.displayname}
        New-Object -TypeName PSObject -Property $props
    }
}

function Get-InfoProc {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True)][string]$ComputerName
    )
    $procs = Get-WmiObject -class Win32_Process -ComputerName $ComputerName
    foreach ($proc in $procs) { 
        $props = @{'ProcName'=$proc.name;
                   'Executable'=$proc.ExecutablePath}
        New-Object -TypeName PSObject -Property $props
    }
}

function Get-InfoNIC {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True)][string]$ComputerName
    )
    $nics = Get-WmiObject -class Win32_NetworkAdapter -ComputerName $ComputerName `
           -Filter "PhysicalAdapter=True"
    foreach ($nic in $nics) {      
        $props = @{'NICName'=$nic.servicename;
                   'Speed'=$nic.speed / 1MB -as [int];
                   'Manufacturer'=$nic.manufacturer;
                   'MACAddress'=$nic.macaddress}
        New-Object -TypeName PSObject -Property $props
    }
}

function Get-InfoDisk {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True)][string]$ComputerName
    )
    $drives = Get-WmiObject -class Win32_LogicalDisk -ComputerName $ComputerName `
           -Filter "DriveType=3"
    foreach ($drive in $drives) {      
        $props = @{'Drive'=$drive.DeviceID;
                   'Size'=$drive.size / 1GB -as [int];
                   'Free'="{0:N2}" -f ($drive.freespace / 1GB);
                   'FreePct'=$drive.freespace / $drive.size * 100 -as [int]}
        New-Object -TypeName PSObject -Property $props 
    }
}

foreach ($computer in $computername) {
    try {
        $everything_ok = $true
        Write-Verbose "Checking connectivity to $computer"
        Get-WmiObject -class Win32_BIOS -ComputerName $Computer -EA Stop | Out-Null
    } catch {
        Write-Warning "$computer failed"
        $everything_ok = $false
    }

    if ($everything_ok) {
        $filepath = Join-Path -Path $Path -ChildPath "$computer.html"

        $params = @{'As'='List';
                    'PreContent'='<h2>OS</h2>'}
        $html_os = Get-InfoOS -ComputerName $computer |
                   ConvertTo-EnhancedHTMLFragment @params 

        $params = @{'As'='List';
                    'PreContent'='<h2>Computer System</h2>'}
        $html_cs = Get-InfoCompSystem -ComputerName $computer |
                   ConvertTo-EnhancedHTMLFragment @params 

        $params = @{'As'='Table';
                    'PreContent'='<h2>&diams; Local Disks</h2>';
                    'EvenRowCssClass'='even';
                    'OddRowCssClass'='odd';
                    'MakeTableDynamic'=$true;
                    'TableCssClass'='grid';
                    'Properties'='Drive',
                                 @{n='Size(GB)';e={$_.Size}},
                                 @{n='Free(GB)';e={$_.Free};css={if ($_.FreePct -lt 80) { 'red' }}},
                                 @{n='Free(%)';e={$_.FreePct};css={if ($_.FreeePct -lt 80) { 'red' }}}}
        $html_dr = Get-InfoDisk -ComputerName $computer |
                   ConvertTo-EnhancedHTMLFragment @params

        $params = @{'As'='Table';
                    'PreContent'='<h2>&diams; Processes</h2>';
                    'MakeTableDynamic'=$true;
                    'TableCssClass'='grid'}
        $html_pr = Get-InfoProc -ComputerName $computer |
                   ConvertTo-EnhancedHTMLFragment @params 

        $params = @{'As'='Table';
                    'PreContent'='<h2>&diams; Services to Check</h2>';
                    'EvenRowCssClass'='even';
                    'OddRowCssClass'='odd';
                    'MakeHiddenSection'=$true;
                    'TableCssClass'='grid'}
        $html_sv = Get-InfoBadService -ComputerName $computer |
                   ConvertTo-EnhancedHTMLFragment @params 

        $params = @{'As'='Table';
                    'PreContent'='<h2>&diams; NICs</h2>';
                    'EvenRowCssClass'='even';
                    'OddRowCssClass'='odd';
                    'MakeHiddenSection'=$true;
                    'TableCssClass'='grid'}
        $html_na = Get-InfoNIC -ComputerName $Computer |
                   ConvertTo-EnhancedHTMLFragment @params

        $params = @{'CssStyleSheet'=$style;
                    'Title'="System Report for $computer";
                    'PreContent'="<h1>System Report for $computer</h1>";
                    'HTMLFragments'=@($html_os,$html_cs,$html_dr,$html_pr,$html_sv,$html_na)}
        ConvertTo-EnhancedHTML @params |
        Out-File -FilePath $filepath
    }
}

 .Notes
  Function by Don Jones
  Generated on: 9/10/2013
  For more information see Powershell.org
  included in SBTools module with permission by Don Jones
  
#>
    [CmdletBinding()]
    param(
        [string]$jQueryURI = 'http://ajax.aspnetcdn.com/ajax/jQuery/jquery-1.8.2.min.js',
        [string]$jQueryDataTableURI = 'http://ajax.aspnetcdn.com/ajax/jquery.dataTables/1.9.3/jquery.dataTables.min.js',
        [Parameter(ParameterSetName='CSSContent')][string[]]$CssStyleSheet,
        [Parameter(ParameterSetName='CSSURI')][string[]]$CssUri,
        [string]$Title = 'Report',
        [string]$PreContent,
        [string]$PostContent,
        [Parameter(Mandatory=$True)][string[]]$HTMLFragments
    )


    <#
        Add CSS style sheet. If provided in -CssUri, add a <link> element.
        If provided in -CssStyleSheet, embed in the <head> section.
        Note that BOTH may be supplied - this is legitimate in HTML.
    #>
    Write-Verbose "Making CSS style sheet"
    $stylesheet = ""
    if ($PSBoundParameters.ContainsKey('CssUri')) {
        $stylesheet = "<link rel=`"stylesheet`" href=`"$CssUri`" type=`"text/css`" />"
    }
    if ($PSBoundParameters.ContainsKey('CssStyleSheet')) {
        $stylesheet = "<style>$CssStyleSheet</style>" | Out-String
    }


    <#
        Create the HTML tags for the page title, and for
        our main javascripts.
    #>
    Write-Verbose "Creating <TITLE> and <SCRIPT> tags"
    $titletag = ""
    if ($PSBoundParameters.ContainsKey('title')) {
        $titletag = "<title>$title</title>"
    }
    $script += "<script type=`"text/javascript`" src=`"$jQueryURI`"></script>`n<script type=`"text/javascript`" src=`"$jQueryDataTableURI`"></script>"


    <#
        Render supplied HTML fragments as one giant string
    #>
    Write-Verbose "Combining HTML fragments"
    $body = $HTMLFragments | Out-String


    <#
        If supplied, add pre- and post-content strings
    #>
    Write-Verbose "Adding Pre and Post content"
    if ($PSBoundParameters.ContainsKey('precontent')) {
        $body = "$PreContent`n$body"
    }
    if ($PSBoundParameters.ContainsKey('postcontent')) {
        $body = "$body`n$PostContent"
    }


    <#
        Add a final script that calls the datatable code
        We dynamic-ize all tables with the .enhancedhtml-dynamic-table
        class, which is added by ConvertTo-EnhancedHTMLFragment.
    #>
    Write-Verbose "Adding interactivity calls"
    $datatable = ""
    $datatable = "<script type=`"text/javascript`">"
    $datatable += '$(document).ready(function () {'
    $datatable += "`$('.enhancedhtml-dynamic-table').dataTable();"
    $datatable += '} );'
    $datatable += "</script>"


    <#
        Datatables expect a <thead> section containing the
        table header row; ConvertTo-HTML doesn't produce that
        so we have to fix it.
    #>
    Write-Verbose "Fixing table HTML"
    $body = $body -replace '<tr><th>','<thead><tr><th>'
    $body = $body -replace '</th></tr>','</th></tr></thead>'


    <#
        Produce the final HTML. We've more or less hand-made
        the <head> amd <body> sections, but we let ConvertTo-HTML
        produce the other bits of the page.
    #>
    Write-Verbose "Producing final HTML"
    ConvertTo-HTML -Head "$stylesheet`n$titletag`n$script`n$datatable" -Body $body  
    Write-Debug "Finished producing final HTML"


}


function ConvertTo-EnhancedHTMLFragment {
<#
.SYNOPSIS
Creates an HTML fragment (much like ConvertTo-HTML with the -Fragment switch
that includes CSS class names for table rows, CSS class and ID names for the
table, and wraps the table in a <DIV> tag that has a CSS class and ID name.

.PARAMETER InputObject
The object to be converted to HTML. You cannot select properties using this
command; precede this command with Select-Object if you need a subset of
the objects' properties.

.PARAMETER EvenRowCssClass
The CSS class name applied to even-numbered <TR> tags. Optional, but if you
use it you must also include -OddRowCssClass.

.PARAMETER OddRowCssClass
The CSS class name applied to odd-numbered <TR> tags. Optional, but if you 
use it you must also include -EvenRowCssClass.

.PARAMETER TableCssID
Optional. The CSS ID name applied to the <TABLE> tag.

.PARAMETER DivCssID
Optional. The CSS ID name applied to the <DIV> tag which is wrapped around the table.

.PARAMETER TableCssClass
Optional. The CSS class name to apply to the <TABLE> tag.

.PARAMETER DivCssClass
Optional. The CSS class name to apply to the wrapping <DIV> tag.

.PARAMETER As
Must be 'List' or 'Table.' Defaults to Table. Actually produces an HTML
table either way; with Table the output is a grid-like display. With
List the output is a two-column table with properties in the left column
and values in the right column.

.PARAMETER Properties
A comma-separated list of properties to include in the HTML fragment.
This can be * (which is the default) to include all properties of the
piped-in object(s). In addition to property names, you can also use a
hashtable similar to that used with Select-Object. For example:

 Get-Process | ConvertTo-EnhancedHTMLFragment -As Table `
               -Properties Name,ID,@{n='VM';
                                     e={$_.VM};
                                     css={if ($_.VM -gt 100) { 'red' }
                                          else { 'green' }}}

This will create table cell rows with the calculated CSS class names.
E.g., for a process with a VM greater than 100, you'd get:

  <TD class="red">475858</TD>
  
You can use this feature to specify a CSS class for each table cell
based upon the contents of that cell. Valid keys in the hashtable are:

  n, name, l, or label: The table column header
  e or expression: The table cell contents
  css or csslcass: The CSS class name to apply to the <TD> tag 
  
Another example:

  @{n='Free(MB)';
    e={$_.FreeSpace / 1MB -as [int]};
    css={ if ($_.FreeSpace -lt 100) { 'red' } else { 'blue' }}
    
This example creates a column titled "Free(MB)". It will contain
the input object's FreeSpace property, divided by 1MB and cast
as a whole number (integer). If the value is less than 100, the
table cell will be given the CSS class "red." If not, the table
cell will be given the CSS class "blue." The supplied cascading
style sheet must define ".red" and ".blue" for those to have any
effect.  

.PARAMETER PreContent
Raw HTML content to be placed before the wrapping <DIV> tag. 
For example:

    -PreContent "<h2>Section A</h2>"

.PARAMETER PostContent
Raw HTML content to be placed after the wrapping <DIV> tag.
For example:

    -PostContent "<hr />"

.PARAMETER MakeHiddenSection
Used in conjunction with -PreContent. Adding this switch, which
needs no value, turns your -PreContent into  clickable report
section header. The section will be hidden by default, and clicking
the header will toggle its visibility.

When using this parameter, consider adding a symbol to your -PreContent
that helps indicate this is an expandable section. For example:

    -PreContent '<h2>&diams; My Section</h2>'

If you use -MakeHiddenSection, you MUST provide -PreContent also, or
the hidden section will not have a section header and will not be
visible.

.PARAMETER MakeTableDynamic
When using "-As Table", makes the table dynamic. Will be ignored
if you use "-As List". Dynamic tables are sortable, searchable, and
are paginated.

You should not use even/odd styling with tables that are made
dynamic. Dynamic tables automatically have their own even/odd
styling. You can apply CSS classes named ".odd" and ".even" in 
your CSS to style the even/odd in a dynamic table.

.EXAMPLE
 $fragment = Get-WmiObject -Class Win32_LogicalDisk |
             Select-Object -Property PSComputerName,DeviceID,FreeSpace,Size |
             ConvertTo-HTMLFragment -EvenRowClass 'even' `
                                    -OddRowClass 'odd' `
                                    -PreContent '<h2>Disk Report</h2>' `
                                    -MakeHiddenSection `
                                    -MakeTableDynamic

 You will usually save fragments to a variable, so that multiple fragments
 (each in its own variable) can be passed to ConvertTo-EnhancedHTML.
.NOTES
Consider adding the following to your CSS when using dynamic tables:

    .paginate_enabled_next, .paginate_enabled_previous {
        cursor:pointer; 
        border:1px solid #222222; 
        background-color:#dddddd; 
        padding:2px; 
        margin:4px;
        border-radius:2px;
    }
    .paginate_disabled_previous, .paginate_disabled_next {
        color:#666666; 
        cursor:pointer;
        background-color:#dddddd; 
        padding:2px; 
        margin:4px;
        border-radius:2px;
    }
    .dataTables_info { margin-bottom:4px; }

This applies appropriate coloring to the next/previous buttons,
and applies a small amount of space after the dynamic table.

If you choose to make sections hidden (meaning they can be shown
and hidden by clicking on the section header), consider adding
the following to your CSS:

    .sectionheader { cursor:pointer; }
    .sectionheader:hover { color:red; }

This will apply a hover-over color, and change the cursor icon,
to help visually indicate that the section can be toggled.

 .Notes
  Function by Don Jones
  Generated on: 9/10/2013
  For more information see Powershell.org
  included in SBTools module with permission by Don Jones

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [object[]]$InputObject,
        [string]$EvenRowCssClass,
        [string]$OddRowCssClass,
        [string]$TableCssID,
        [string]$DivCssID,
        [string]$DivCssClass,
        [string]$TableCssClass,
        [ValidateSet('List','Table')]
        [string]$As = 'Table',
        [object[]]$Properties = '*',
        [string]$PreContent,
        [switch]$MakeHiddenSection,
        [switch]$MakeTableDynamic,
        [string]$PostContent
    )
    BEGIN {
        <#
            Accumulate output in a variable so that we don't
            produce an array of strings to the pipeline, but
            instead produce a single string.
        #>
        $out = ''
        <#
            Add the section header (pre-content). If asked to
            make this section of the report hidden, set the
            appropriate code on the section header to toggle
            the underlying table. Note that we generate a GUID
            to use as an additional ID on the <div>, so that
            we can uniquely refer to it without relying on the
            user supplying us with a unique ID.
        #>
        Write-Verbose "Precontent"
        if ($PSBoundParameters.ContainsKey('PreContent')) {
            if ($PSBoundParameters.ContainsKey('MakeHiddenSection')) {
               [string]$tempid = [System.Guid]::NewGuid()
               $out += "<span class=`"sectionheader`" onclick=`"`$('#$tempid').toggle(500);`">$PreContent</span>`n"
            } else {
                $out += $PreContent
                $tempid = ''
            }
        }
        <#
            The table will be wrapped in a <div> tag for styling
            purposes. Note that THIS, not the table per se, is what
            we hide for -MakeHiddenSection. So we will hide the section
            if asked to do so.
        #>
        Write-Verbose "DIV"
        if ($PSBoundParameters.ContainsKey('DivCSSClass')) {
            $temp = " class=`"$DivCSSClass`""
        } else {
            $temp = ""
        }
        if ($PSBoundParameters.ContainsKey('MakeHiddenSection')) {
            $temp += " id=`"$tempid`" style=`"display:none;`""
        } else {
            $tempid = ''
        }
        if ($PSBoundParameters.ContainsKey('DivCSSID')) {
            $temp += " id=`"$DivCSSID`""
        }
        $out += "<div $temp>"
        <#
            Create the table header. If asked to make the table dynamic,
            we add the CSS style that ConvertTo-EnhancedHTML will look for
            to dynamic-ize tables.
        #>
        Write-Verbose "TABLE"
        $_TableCssClass = ''
        if ($PSBoundParameters.ContainsKey('MakeTableDynamic') -and $As -eq 'Table') {
            $_TableCssClass += 'enhancedhtml-dynamic-table '
        }
        if ($PSBoundParameters.ContainsKey('TableCssClass')) {
            $_TableCssClass += $TableCssClass
        }
        if ($_TableCssClass -ne '') {
            $css = "class=`"$_TableCSSClass`""
        } else {
            $css = ""
        }
        if ($PSBoundParameters.ContainsKey('TableCSSID')) {
            $css += "id=`"$TableCSSID`""
        } else {
            if ($tempid -ne '') {
                $css += "id=`"$tempid`""
            }
        }
        $out += "<table $css>"
        <#
            We're now setting up to run through our input objects
            and create the table rows
        #>
        $fragment = ''
        $wrote_first_line = $false
        $even_row = $false

        if ($properties -eq '*') {
            $all_properties = $true
        } else {
            $all_properties = $false
        }

    }
    PROCESS {

        foreach ($object in $inputobject) {
            Write-Verbose "Processing object"
            $datarow = ''
            $headerrow = ''

            <#
                Apply even/odd row class. Note that this will mess up the output
                if the table is made dynamic. That's noted in the help.
            #>
            if ($PSBoundParameters.ContainsKey('EvenRowCSSClass') -and $PSBoundParameters.ContainsKey('OddRowCssClass')) {
                if ($even_row) {
                    $row_css = $OddRowCSSClass
                    $even_row = $false
                    Write-Verbose "Even row"
                } else {
                    $row_css = $EvenRowCSSClass
                    $even_row = $true
                    Write-Verbose "Odd row"
                }
            } else {
                $row_css = ''
                Write-Verbose "No row CSS class"
            }


            <#
                If asked to include all object properties, get them.
            #>
            if ($all_properties) {
                $properties = $object | Get-Member -MemberType Properties | Select -ExpandProperty Name
            }


            <#
                We either have a list of all properties, or a hashtable of
                properties to play with. Process the list.
            #>
            foreach ($prop in $properties) {
                Write-Verbose "Processing property"
                $name = $null
                $value = $null
                $cell_css = ''


                <#
                    $prop is a simple string if we are doing "all properties,"
                    otherwise it is a hashtable. If it's a string, then we
                    can easily get the name (it's the string) and the value.
                #>
                if ($prop -is [string]) {
                    Write-Verbose "Property $prop"
                    $name = $Prop
                    $value = $object.($prop)
                } elseif ($prop -is [hashtable]) {
                    Write-Verbose "Property hashtable"
                    <#
                        For key "css" or "cssclass," execute the supplied script block.
                        It's expected to output a class name; we embed that in the "class"
                        attribute later.
                    #>
                    if ($prop.ContainsKey('cssclass')) { $cell_css = $Object | ForEach $prop['cssclass'] }
                    if ($prop.ContainsKey('css')) { $cell_css = $Object | ForEach $prop['css'] }


                    <#
                        Get the current property name.
                    #>
                    if ($prop.ContainsKey('n')) { $name = $prop['n'] }
                    if ($prop.ContainsKey('name')) { $name = $prop['name'] }
                    if ($prop.ContainsKey('label')) { $name = $prop['label'] }
                    if ($prop.ContainsKey('l')) { $name = $prop['l'] }


                    <#
                        Execute the "expression" or "e" key to get the value of the property.
                    #>
                    if ($prop.ContainsKey('e')) { $value = $Object | ForEach $prop['e'] }
                    if ($prop.ContainsKey('expression')) { $value = $tObject | ForEach $prop['expression'] }


                    <#
                        Make sure we have a name and a value at this point.
                    #>
                    if ($name -eq $null -or $value -eq $null) {
                        Write-Error "Hashtable missing Name and/or Expression key"
                    }
                } else {
                    <#
                        We got a property list that wasn't strings and
                        wasn't hashtables. Bad input.
                    #>
                    Write-Warning "Unhandled property $prop"
                }


                <#
                    When constructing a table, we have to remember the
                    property names so that we can build the table header.
                    In a list, it's easier - we output the property name
                    and the value at the same time, since they both live
                    on the same row of the output.
                #>
                if ($As -eq 'table') {
                    Write-Verbose "Adding $name to header and $value to row"
                    $headerrow += "<th>$name</th>"
                    $datarow += "<td$(if ($cell_css -ne '') { ' class="'+$cell_css+'"' })>$value</td>"
                } else {
                    $wrote_first_line = $true
                    $headerrow = ""
                    $datarow = "<td$(if ($cell_css -ne '') { ' class="'+$cell_css+'"' })>$name :</td><td$(if ($cell_css -ne '') { ' class="'+$cell_css+'"' })>$value</td>"
                    $out += "<tr$(if ($row_css -ne '') { ' class="'+$row_css+'"' })>$datarow</tr>"
                }
            }


            <#
                Write the table header, if we're doing a table.
            #>
            if (-not $wrote_first_line -and $as -eq 'Table') {
                Write-Verbose "Writing header row"
                $out += "<tr>$headerrow</tr><tbody>"
                $wrote_first_line = $true
            }


            <#
                In table mode, write the data row.
            #>
            if ($as -eq 'table') {
                Write-Verbose "Writing data row"
                $out += "<tr$(if ($row_css -ne '') { ' class="'+$row_css+'"' })>$datarow</tr>"
            }
        }
    }
    END {
        <#
            Finally, post-content code, the end of the table,
            the end of the <div>, and write the final string.
        #>
        Write-Verbose "PostContent"
        if ($PSBoundParameters.ContainsKey('PostContent')) {
            $out += "`n$PostContent"
        }
        Write-Verbose "Done"
        $out += "</tbody></table></div>"
        Write-Output $out
    }
}


function Get-PII {
<# 
 .SYNOPSIS
  Function to report on files containing Personally Identifiable Information (PII)

 .DESCRIPTION
  Function produces an HTML report of files of certain extensions in certain folders,
  that contain PII such as social security numbers and credit card card numbers.

 .PARAMETER FileType
  File extensions of the files to search in. Wildcards are allowed.
  Examples: "txt" or "txt","doc?","xls"

 .PARAMETER TargetFolder
  Folder(s) to search in. Wildcards are allowed.
  Examples: "c:\support" or "d:\sandbox","\\server11\share\sales*"

 .PARAMETER FileProperties
  These will make up the columns in the tabular HTML report. If not provided, the default is:
  "Name","DirectoryName","CreationTime","LastAccessTime","LastWriteTime"
  Acceptable values are:
  "Name","DirectoryName","Extension","Length","CreationTime","LastAccessTime","LastWriteTime","Attributes"

 .PARAMETER LogFile
  File name where log information is saved.
  Default is "Get-PII_20140822_081426AM.txt" (Date/time script was run)
  Examples: ".\log.txt" or "c:\scripts\pii.log"

 .PARAMETER HTMLFile
  HTML file name where report information is saved.
  Default is "Get-PII_20140822_081426AM.htm" (Date/time script was run)
  Examples: ".\Report.htm" or "c:\scripts\pii.html"

 .EXAMPLE
  Get-PII -FileType "txt" -TargetFolder "D:\Sandbox"
  This example produces a report on files with "txt" extension in the folder
  "d:\sandbox" that contain PII

 .EXAMPLE
  Get-PII "txt","csv","doc?" "D:\Sandbox","\\Myserver\Install\Script?"
  This example produces a report on files with the extensions "txt","csv","doc?"
  in the folders "D:\Sandbox","\\Myserver\Install\Script?" that contain PII

 .EXAMPLE
  $FileExtensions = "txt","csv","xls?","ppt*"
  $SearchFolders = "D:\Sandbox","\\Server2\Share\User*"
  Get-PII $FileExtensions $SearchFolders

 .EXAMPLE
  Get-PII -FileType "txt" -TargetFolder "D:\Sandbox" -FileProperties "Name","DirectoryName","Attributes"
  This example displays the listed file properties int he HTML report

 .LINK
  https://superwidgets.wordpress.com/category/powershell/

 .NOTES
  Script to report on files containing Personally Identifiable Information
  By Sam Boutros
  v1.0 - 20 August 2014
  v1.1 - 26 August 2016, output filelist as PS object which can be exported to CSV
#>

    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')] 
    Param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeLine=$true,
                   ValueFromPipeLineByPropertyName=$true,
                   Position=0)]
            [ValidateLength(1,5)]
            [String[]]$FileType, 
        [Parameter(Mandatory=$false,
                   ValueFromPipeLineByPropertyName=$true,
                   Position=1)]
            [ValidateScript({ Test-Path $_ })]
            [String[]]$TargetFolder = (Get-Location).Path, 
        [Parameter(Mandatory=$false,
                   Position=2)]
            [ValidateSet("Name","DirectoryName","Extension","Length","CreationTime","LastAccessTime","LastWriteTime","Attributes")]
            [String[]]$FileProperties = ("Name","DirectoryName","CreationTime","LastAccessTime","LastWriteTime"), 
#            [ValidateSet("Name","DirectoryName","Extension","Length","CreationTime","LastAccessTime","LastWriteTime","Attributes","File")]
#            [String[]]$FileProperties = ("Name","DirectoryName","CreationTime","LastAccessTime","LastWriteTime","File"), 
        [Parameter(Mandatory=$false,
                   Position=3)]
            [String]$LogFile = ".\logs\Get-PII_" + (Get-Date -format yyyyMMdd_hhmmsstt) + ".txt",
        [Parameter(Mandatory=$false,
                   Position=4)]
            [String]$HTMLFile = ".\logs\Get-PII_" + (Get-Date -format yyyyMMdd_hhmmsstt) + ".htm"
    )

    $Patterns = @()
    $Pattern0 = 'Credit Card - Visa','(4\d{3}[-| ]\d{4}[-| ]\d{4}[-| ]\d{4})|(4\d{15})','Start with a 4 and have 16 digits, may be split as xxxx-xxxx-xxxx-xxxx by dashes or spaces'
    $Pattern1 = 'Credit Card - MasterCard','(5[1-5]\d{14})|(5[1-5]\d{2}[-| ]\d{4}[-| ]\d{4}[-| ]\d{4})','Starts with 51-55 and have 16 digits, may be split as xxxx-xxxx-xxxx-xxxx by dashes or spaces'
    $Pattern2 = 'Credit Card - Amex','(3[47]\d{13})|(3[47]\d{2}[-| ]\d{6}[-| ]\d{5})','Starts with 34 or 37 and have 15 digits, may be split as xxxx-xxxxxx-xxxxx by dashes or spaces'
    $Pattern3 = 'Credit Card - DinersClub','(3(?:0[0-5]|[68]\d)\d{11})|(3(?:0[0-5]|[68]\d)\d[-| ]\d{6}[-| ]\d{4})','Starts with 300-305, or 36-38 and have 14 digits, may be split as xxxx-xxxxxx-xxxx by dashes or spaces'
    $Pattern4 = 'Credit Card - Discover','(6(?:011|5\d{2})\d{12})|(6(?:011|5\d{2})[-| ]\d{4}[-| ]\d{4}[-| ]\d{4})','Start with 6011 or 65 and have 16 digits, may be split as xxxx-xxxx-xxxx-xxxx by dashes or spaces'
    $Pattern5 = 'Credit Card - JCB','((?:2131|1800|35\d{3})\d{11})|((?:2131|1800|35\d{2})[-| ]\d{4}[-| ]\d{4}[-| ]\d{3}[\d| ])','Start with 2131 or 1800 and have 15 digits) or (Start with 35 and have 16 digits'
    $Pattern6 = 'Social Security Number','(\d{3}[-| ]\d{2}[-| ]\d{4})|(\d{9})','9 digits, may be split as xxx-xx-xxxx by dashes or spaces'
    $Patterns = $Pattern0,$Pattern1,$Pattern2,$Pattern3,$Pattern4,$Pattern5,$Pattern6 # 2D aray
    #    
    $Style = @"
    <style>
    body {
        color:#333333;
        font-family:Calibri,Tahoma;
        font-size: 10pt;
    }
    h1 {
        text-align:center;
    }
    h2 {
        border-top:1px solid #666666;
    }
    th {
        font-weight:bold;
        color:#eeeeee;
        background-color:#333333;
        cursor:pointer;
    }
    .odd  { background-color:#ffffff; }
    .even { background-color:#dddddd; }
    .paginate_enabled_next, .paginate_enabled_previous {
        cursor:pointer; 
        border:1px solid #222222; 
        background-color:#dddddd; 
        padding:2px; 
        margin:4px;
        border-radius:2px;
    }
    .paginate_disabled_previous, .paginate_disabled_next {
        color:#666666; 
        cursor:pointer;
        background-color:#dddddd; 
        padding:2px; 
        margin:4px;
        border-radius:2px;
    }
    .dataTables_info { margin-bottom:4px; }
    .sectionheader { cursor:pointer; }
    .sectionheader:hover { color:red; }
    .grid { width:100% }
    .red {
        color:red;
        font-weight:bold;
    } 
    </style>
"@
    #
    if (-not ("Name" -in $FileProperties)) { $FileProperties += "Name" }
    if (-not ("DirectoryName" -in $FileProperties)) { $FileProperties += "DirectoryName" }
    $Properties = $FileProperties
    For ($i=0; $i -lt $Patterns.Count; $i++) { $Properties += "Pattern$($i)" }
    $Tables = @()
    $TargetFolderString = $null
    foreach ($Folder in $TargetFolder) {
        $TargetFolderString += $Folder + ", "
        $FileTypeString = $null
        foreach ($Type in $FileType) {
            log "Searching for files with $Type extension on folder $Folder and its subfolders" Green $Logfile
            $FileTypeString += $Type + ", "
            $Files = Get-ChildItem -Path $Folder -Include *.$Type -Force -Recurse -ErrorAction SilentlyContinue
            $FileList = @()
            ForEach ($File in $Files) {
                Write-Verbose "Checking file $($File.FullName)"
                $Props = @{}
                foreach ($Prop in $FileProperties) { $Props.Add($Prop, $($File.$Prop)) } 
                For ($i=0; $i -lt $Patterns.Count; $i++) { $Props.Add("Pattern$($i)", 0) }
                $objFile = New-Object -TypeName PSObject -Property $Props
#                $objFile.File = "<a href='$($objFile.DirectoryName)\$($objFile.Name)' target= '_blank'>$($objFile.Name)</a>"
                try { 
                    $FileContent = Get-Content -Path "$($objFile.DirectoryName)\$($objFile.Name)" -ErrorAction Stop
                    for ($j=0; $j -lt $FileContent.Count; $j++) { # each line in a file
                        For ($i=0; $i -lt $Patterns.Count; $i++) { 
                            if ($FileContent[$j] -match $Patterns[$i][1]) { 
                                $objFile.$("Pattern$i") += 1 
                                Write-Verbose "Found '$($Patterns[$i][0])' match in line '$($FileContent[$j])' in file '$($objFile.DirectoryName)\$($objFile.Name)'"
                            } 
                        }
                        Write-Debug "Finished checking line '$($FileContent[$j])' in file '$($objFile.DirectoryName)\$($objFile.Name)'"
                    }
                    $PatternMatch = $false
                    For ($k=0; $k -lt $Patterns.Count; $k++) {
                        if ($objFile.$("Pattern$k") -gt 0 ) { $PatternMatch = $true }
                    }
                    if ($PatternMatch) { $FileList += $objFile }
#                    if ($PatternMatch) { $FileList += ($objFile | Select-Object -Property * -ExcludeProperty Name) }
                } catch {
                    log "Unable to read file $($objFile.DirectoryName)\$($objFile.Name)" Yellow $LogFile
                }
            } 
            if ($FileList) { # Skip empty tables
                $Params = @{'As'='Table';
                        'PreContent'='<h2><font color=blue>''' + $FileList.Count + ''' </font>file(s) with <font color=blue>''' + $Type + '''</font> extension under folder <font color=blue>''' + $Folder + ''' </font>contain PII:</h2>';
                        'EvenRowCssClass'='even';
                        'OddRowCssClass'='odd';
                        'MakeTableDynamic'=$true;
                        'TableCssClass'='grid';
                        'Properties'= $Properties }
#                        'Properties'= ($Properties | Where-Object { $_ -ne "Name" }) }
                $Table = $FileList | ConvertTo-EnhancedHTMLFragment @params
                $Tables += $Table
                Write-Debug "Added HTML Fragment"
            }
        } 
    } 
    Write-Debug "Done all folders"
    $PreContent =  "<h1> Report of files containing PII </h1>"
    $PreContent += "<br> <u>Search crieteria:</u>"
    $PreContent += "<br> &nbsp;&nbsp;&nbsp;&nbsp;Files with extension(s): <font color=blue>$($FileTypeString.Substring(0,$FileTypeString.Length-2))</font>"
    $PreContent += "<br> &nbsp;&nbsp;&nbsp;&nbsp;In folder(s) - including their sub-folders: <font color=blue>$($TargetFolderString.Substring(0,$TargetFolderString.Length-2))</font>"
    $PreContent += "<br> <u>Patterns searched for:</u>"
    For ($i=0; $i -lt $Patterns.Count; $i++) { $PreContent += "<br> &nbsp;&nbsp;&nbsp;&nbsp;Pattern$($i): $($Patterns[$i][0]) ($($Patterns[$i][2]))" }
    $PreContent += "<br> <u>Notes:</u>"
    $PreContent += "<br> &nbsp;&nbsp;&nbsp;&nbsp;1. Social Security number pattern macthes may include false positives"
    $PreContent += "<br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;For example a 4234567890123456 number will match as a Visa card number <i><b>AND</b></i> a Social Security number"
    $PreContent += "<br> &nbsp;&nbsp;&nbsp;&nbsp;2. Files with full name (including path) longer than 260 characters are not checked"
    $PreContent += "<br> &nbsp;&nbsp;&nbsp;&nbsp;3. Files that cannot be accessed due to NTFS permissions are not checked"
    $PreContent += "<br> &nbsp;&nbsp;&nbsp;&nbsp;4. A pattern match is reported once per line per file (even if it occurs multiple times on the same line)"
    if ($Tables) {
        $Params = @{'CssStyleSheet'=$Style;
                'Title'="Report of files containing PII";
                'PreContent'=$PreContent;
                'HTMLFragments'=$Tables;
                'jQueryDataTableUri'='http://ajax.aspnetcdn.com/ajax/jquery.dataTables/1.9.3/jquery.dataTables.min.js';
                'jQueryUri'='http://ajax.aspnetcdn.com/ajax/jQuery/jquery-1.8.2.min.js'} 
        ConvertTo-EnhancedHTML @params | Out-File -FilePath $HTMLFile
        log "Done. Report saved to file $HTMLFile" Green $Logfile
        Start-Process $HTMLFile
    } else {
        log "No files found with PII in files with extension(s): '$($FileTypeString.Substring(0,$FileTypeString.Length-2))' in folder(s) '$($TargetFolderString.Substring(0,$TargetFolderString.Length-2))'" green $LogFile
    }
    Write-Debug "Done"
    $FileList 
}