[CmdletBinding()]
param (
    [ValidateSet("init", "plan", "apply", "rm-lock", "rm-state", "tidy", "destroy")][string]$TerraformOperation,
    [string]$Flag
)
process {
    Write-Host "Compiling wing modules..." 
    wing compile -t tf-aws --plugins=plugin.terraform.js main.w
    $workDir = "target\main.tfaws"
    Set-Location $workDir
    Write-Host "Working..." 
    & terraform init
    if ($TerraformOperation -eq "init") {
        Write-Host "Initing..."
        & terraform $TerraformOperation -upgrade
    }
    elseif ($TerraformOperation -eq "plan") {
        Write-Host "Planning..."
        & terraform $TerraformOperation
    }
    elseif ($TerraformOperation -eq "apply") {
        Write-Host "Applying..." -ForegroundColor DarkGreen
        & terraform $TerraformOperation
    }
    elseif ($TerraformOperation -eq "destroy") {
        Write-Host "Destroying..." -ForegroundColor DarkRed
        & terraform $TerraformOperation
    }
    elseif ($TerraformOperation -eq "rm-lock") {
        Write-Host "Removing troublesome state lock flag"
        & terraform force-unlock $Flag
    }
    elseif ($TerraformOperation -eq "rm-state") {
        Write-Host "Removing troublesome state"
        & terraform state rm $TerraformOperation
    }
    elseif ($TerraformOperation -eq "tidy") {
        Write-Host "Formatting and validating your terraform"
        & terraform fmt 
        & terraform validate
    }
    cd ../../
}
