$groups = get-content -path c:\groups.txt
$computers = get-content -path c:\computers.txt

foreach($computer in $computers)
{
	$computer
	$comp = get-adcomputer -identity $computer | %{$_.distinguishedname}
	foreach($group in $groups)
	{
		$gr = get-adgroup -identity $group -properties * | %{$_.distinguishedname}
		add-adgroupmember -identity $gr -member $comp
	}
}


