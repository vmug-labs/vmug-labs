<#
Sets all vApp properties for a VM to be user configurable as Terraform v11.5
and the Terraform vSphere provider v1.3 and earlier do not support deploying
VMs with one or more vApp property where the UserConfigurable field is set to
'False'.

William Lam's nested ESXi VM templates have a 'debug' vApp properties that must
be enabled before Terraform can successfully clone VMs from it.  This script
will do so.

https://github.com/terraform-providers/terraform-provider-vsphere/issues/394
#>
param (
    [Parameter(
        Mandatory = $true,
        Position = 0,
        ValueFromPipeline = $true
    )]
    [ValidateCount( 1, 100)]
    [ValidateNotNullOrEmpty()]
    [String[]] $Name
)

$vms = Get-VM -Name $Name -ErrorAction 'Stop'

foreach ( $vm in $vms ) {
    $virtualMachineConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
    $virtualMachineConfigSpec.changeVersion = $vm.ExtensionData.Config.ChangeVersion
    $virtualMachineConfigSpec.vAppConfig = New-Object VMware.Vim.VmConfigSpec

    foreach ( $property in $vm.ExtensionData.Config.VAppConfig.Property ) {
        $vAppPropertySpec = New-Object -TypeName 'VMware.Vim.VAppPropertySpec'
        $vAppPropertySpec.Operation = 'edit'
        $vAppPropertySpec.Info = $property
        $VAppPropertySpec.Info.UserConfigurable = $true

        $virtualMachineConfigSpec.vAppConfig.Property += $VAppPropertySpec
    }

    $vm.ExtensionData.ReconfigVM_Task( $virtualMachineConfigSpec )

    # Get all the IDs and values
    $vm.ExtensionData.Config.VAppConfig.Property |
        Select-Object -Property 'ID', 'Value'
}
