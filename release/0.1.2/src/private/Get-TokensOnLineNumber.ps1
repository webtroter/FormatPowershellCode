Get-TokensOnLineNumber
{
    [CmdletBinding()]
    param (
    [parameter(Position=0, ValueFromPipeline=$true, Mandatory=$true, HelpMessage='Tokens to process.')]
    [System.Management.Automation.Language.Token[]]$Tokens,
    [parameter(Position=1, Mandatory=$true, HelpMessage='Line Number')]
    [System.Int32]$LineNumber
    )
    
    Begin
    {
        $AllTokens = @()
    }
    Process
    {
        $AllTokens += $Tokens
    }
    End
    {
        $AllTokens |
        Where {($_.Extent.StartLineNumber -eq $_.Extent.EndLineNumber) -and
            ($_.Extent.StartLineNumber -eq $LineNumber)}
    }
}
