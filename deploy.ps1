New-AzResourceGroup -Name keithbl -Location australiaeast -Force

New-AzResourceGroupDeployment -ResourceGroupName keithbl -TemplateFile .\main.bicep -Verbose