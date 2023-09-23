param (
    [int]$n = 5,                # Default number of iterations
    [int]$parallelThreads = 2  # Default number of parallel threads
)

# Set the URL and JSON data
$apiUrl = 'https://2nhri1btq7.execute-api.us-east-1.amazonaws.com/prod/queueEmail'
$jsonData = '{
  "message": "YESSSSSSS",
  "to": "rainiersvn1@gmail.com",
  "subject": "Now on to V2!"
}'

# Function to execute the CURL command
function Execute-CurlCommand {
    param (
        [string]$apiUrl,
        [string]$jsonData
    )
    
    Invoke-RestMethod -Uri $apiUrl -Method POST -Headers @{
        'Content-Type' = 'application/json'
    } -Body $jsonData
}

# Create a collection to store the jobs
$jobs = @()

# Loop through the iterations and execute the CURL command with parallel threads
for ($i = 1; $i -le $n; $i++) {
    $job = Start-Job -ScriptBlock {
        param (
            $apiUrl,
            $jsonData
        )
        Execute-CurlCommand -apiUrl $apiUrl -jsonData $jsonData
    } -ArgumentList $apiUrl, $jsonData
    
    $jobs += $job

    # Limit the number of parallel threads based on the $parallelThreads parameter
    if ($jobs.Count -ge $parallelThreads) {
        $finishedJob = $jobs | Wait-Job -Any
        $jobs.Remove($finishedJob)
        $finishedJob | Receive-Job
    }
}

# Wait for any remaining jobs to complete
$jobs | Wait-Job | Receive-Job

# Clean up the jobs
$jobs | Remove-Job
