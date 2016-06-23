Get-TokenKindLocations
{
    <#
    .SYNOPSIS
        Supplemental function used to get exact location of different kinds of AST tokens in a script.
    .DESCRIPTION
        Supplemental function used to get exact location of different kinds of AST tokens in a script.
    .PARAMETER Code
        Multiline or piped lines of code to process.
    .EXAMPLE
       PS > $testfile = 'C:\temp\test.ps1'
       PS > $test = Get-Content $testfile -raw
       PS > $test | Get-TokenKindLocations -Kind "HereStringLiteral" | clip
       
       Description
       -----------
       Takes C:\temp\test.ps1 as input, formats as the function defines and places the result in the clipboard 
       to be pasted elsewhere for review.

    .NOTES
       Author: Zachary Loeber
       Site: http://www.the-little-things.net/
       Requires: Powershell 3.0

       Version History
       1.0.0 - Initial release
    #>
    [CmdletBinding()]
    param (
    [parameter(Position=0, ValueFromPipeline=$true, HelpMessage='Lines of code to process.')]
    [String[]]$Code,
    [parameter(Position=1, HelpMessage='Type of AST kind to retrieve.')]
    [String[]]$Kind
    )
    
    Begin
    {
        $Codeblock = @()
        $ParseError = $null
        $Tokens = $null
        if ($kind.count -gt 0)
        {
            $KindMatch = '^(' + (($Kind | %{[Regex]::Escape($_)}) -join '|') + ')$'
        }
        else
        {
            $KindMatch = '.*'
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."
    }
    Process
    {
        $Codeblock += $Code
    }
    End
    {
        $ScriptText = $Codeblock | Out-String
        Write-Verbose "$($FunctionName): Attempting to parse AST."
        $AST = [System.Management.Automation.Language.Parser]::ParseInput($ScriptText, [System.Management.Automation.PSReference]$Tokens, [System.Management.Automation.PSReference]$ParseError)
        
        if($ParseError)
        {
            $ParseError | Write-Error
            throw "$($FunctionName): Will not work properly with errors in the script, please modify based on the above errors and retry."
        }
        $TokenKinds = @($Tokens | Where {$_.Kind -match $KindMatch})
        Foreach ($Token in $TokenKinds)
        {
            New-Object psobject -Property @{
                'Start' = $Token.Extent.StartOffset
                'End' = $Token.Extent.EndOffset
            }
        }
        Write-Verbose "$($FunctionName): End."
    }
}
