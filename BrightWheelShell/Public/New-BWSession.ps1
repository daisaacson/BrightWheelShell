function New-BWSession {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(
            
        )]
        [string]$uri = "https://schools.mybrightwheel.com",

        [Parameter(
            Mandatory = $true
        )]
        [PSCredential]$credential = (Get-Credential -Message "Enter your Brightwheel email and password for $uri"),

        [Parameter(
            ValueFromPipeline = $true
        )]
        [switch]$PassThru,

        [Parameter(
            ValueFromRemainingArguments = $true
        )]
        $SplattedParameters
    )

    begin {
        # Initialization code
        Write-Verbose "$($MyInvocation.MyCommand) : begin {}"
        $api1 = "/api/v1/sessions/start"
        $api2 = "/api/v1/sessions"
        $method = "POST"
        $headers = @{
            "Content-Type" = "application/json"
            "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36"
            "Referer" = "https://schools.mybrightwheel.com/sign-in"
        }
        $BWSession = $null
    }

    process {
        Write-Verbose "$($MyInvocation.MyCommand) : process {}"
            if ($PSCmdlet.ShouldProcess("$uri")) {
                Try {
                    # Login
                    $uri = $uri + $api1
                    $body = @{
                        "user" = @{
                            "email" = $credential.UserName;
                            "password" = $credential.GetNetworkCredential().password
                        }
                    } | ConvertTo-Json -Compress
                    $response1 = Invoke-RestMethod -Uri $uri -Method $method -Body $body -ContentType "application/json" -SessionVariable BWSession -Proxy http://localhost:8888
                    Write-Debug $response1

                    # 2FA
                    $uri = $uri -replace $api1, $api2
                    $2fa = Read-Host -Prompt "Enter 2Factor code"
                    $body = @{
                        "2fa_code" = $2fa;
                        "user" = @{
                            "email" = $credential.UserName;
                            "password" = $credential.GetNetworkCredential().password
                        }
                    } | ConvertTo-Json -Compress
                    $response2 = Invoke-RestMethod -Uri $uri -Method $method -Body $body -ContentType "application/json" -WebSession $BWSession -Proxy http://localhost:8888
                    Write-Debug $response2
                } Catch {
                    Write-Error "Failed to process ${item}: $_"
                }
            }
        }
    
    end {
        Write-Verbose "$($MyInvocation.MyCommand) : end {}"
        if ($PassThru) {
            Write-Output $BWSession
            <# Action to perform if the condition is true #>
        } else {
            $Script:BWSession = $BWSession
        }
        # Cleanup code
    }
}