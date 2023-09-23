[CmdletBinding()]
param (
    [ValidateSet("compile", "apply", "compile-apply", "run", "destroy")][string]$WingOperation = "compile-apply",
    [string]$Flag
)
process {
    if ($WingOperation -eq "compile") {
        Write-Host "Compiling all wing modules..."
        & wing compile mm.main.w
        & wing compile -t tf-aws --plugins=plugin.terraform.js mm.main.w
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
        wing compile -t tf-aws --plugins=plugin.terraform.js mm.main.w
        $workDir = "target\mm.main.tfaws"
        Set-Location $workDir
        Write-Host "Terraforming the wings..." 
        & terraform init
        & terraform apply
        & cd ../../
    }
    elseif ($WingOperation -eq "destroy") {
        Write-Host "Compiling wing modules..." 
        wing compile -t tf-aws --plugins=plugin.terraform.js mm.main.w
        $workDir = "target\mm.main.tfaws"
        Set-Location $workDir
        Write-Host "Ripping off the wings........" 
        & terraform init
        & terraform destroy
        & cd ../../
    }
}
