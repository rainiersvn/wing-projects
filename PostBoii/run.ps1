[CmdletBinding()]
param (
    [ValidateSet("compile", "apply", "compile-apply", "run")][string]$WingOperation = "compile-apply",
    [string]$Flag
)
process {
    if ($WingOperation -eq "compile") {
        Write-Host "Compiling all wing modules..."
        & wing compile main.w
        & wing compile -t tf-aws --plugins=plugin.terraform.js main.w
    }
    elseif ($WingOperation -eq "apply") {
        $workDir = "target\main.tfaws"
        Set-Location $workDir
        Write-Host "Terraforming the wings..." 
        # & terraform init
        & terraform apply
        & cd ../../
    }
    elseif ($WingOperation -eq "run") {
        $workDir = "target\main.tfaws"
        Set-Location $workDir
        Write-Host "Terraforming the wings..." 
        & terraform init
        & terraform apply
        & cd ../../
    }
    elseif ($WingOperation -eq "compile-apply") {
        Write-Host "Compiling wing modules..." 
        wing compile -t tf-aws --plugins=plugin.terraform.js main.w
        $workDir = "target\main.tfaws"
        Set-Location $workDir
        Write-Host "Terraforming the wings..." 
        & terraform init
        & terraform apply
        & cd ../../
    }
}
