Get-BreakableTokens
{
    [CmdletBinding()]
    param (
    [parameter(Position=0, ValueFromPipeline=$true, Mandatory=$true, HelpMessage='Tokens to process.')]
    [System.Management.Automation.Language.Token[]]$Tokens
    )
    
    Begin
    {
        $Kinds = @('Pipe')
        # Flags found here: https://msdn.microsoft.com/en-us/library/system.management.automation.language.tokenflags(v=vs.85).aspx
        $TokenFlags = @('BinaryPrecedenceAdd','BinaryPrecedenceMultiply','BinaryPrecedenceLogical')
        $Kinds_regex = '^(' + (($Kinds | %{[Regex]::Escape($_)}) -join '|') + ')$'
        $TokenFlags_regex = '(' + (($TokenFlags | %{[Regex]::Escape($_)}) -join '|') + ')'
        $Results = @()
        $AllTokens = @()
    }
    Process
    {
        $AllTokens += $Tokens
    }
    End
    {
        Foreach ($Token in $AllTokens)
        {
            if (($Token.Kind -match $Kinds_regex) -or ($Token.TokenFlags -match $TokenFlags_regex))
            {
                $Results += $Token
            }
        }
        $Results
    }
}
