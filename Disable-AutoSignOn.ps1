$registryPath = "HKLM:\SOFTWARE\WOW6432Node\Ellie Mae\SmartClient"

$Name = "AutoSignOn"

$value = "0"

Set-ItemProperty -Path $registryPath -Name $name -Value $value `

    -PropertyType String -Force | Out-Null