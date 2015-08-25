function Format-ScriptFormatCommandNames {
    [CmdletBinding()]
    param(
        [parameter(Position=0, ValueFromPipeline=$true, HelpMessage='Lines of code to look for and fix spelling on.')]
        [string[]]$Code
    )
    begin {
        $Codeblock = @()
        $CurrentLevel = 0
        $ParseError = $null
        $Tokens = $null
        $Indent = (' ' * $Depth)
    }
    process {
        $Codeblock += $Code
    }
    end {
        $ScriptText = $Codeblock | Out-String

        $AST = [System.Management.Automation.Language.Parser]::ParseInput($ScriptText, [ref]$Tokens, [ref]$ParseError) 
 
        if($ParseError) { 
            $ParseError | Write-Error
            throw "The parser will not work properly with errors in the script, please modify based on the above errors and retry."
        }

        $commands = $ast.FindAll({$args[0] -is [System.Management.Automation.Language.CommandAst]}, $true)

        for($t = $commands.Count - 1; $t -ge 0; $t--) {
            $command = $commands[$t]
            
		    $commandInfo = Get-Command -Name $command.GetCommandName() -ErrorAction SilentlyContinue

            if (($commandInfo -ne $null) -and ($commandInfo.Name -cne $command.GetCommandName()))
            {
                $commandElement = $command.CommandElements[0]
                $RemoveStart = ($commandElement.Extent).StartOffset
                $RemoveEnd = ($commandElement.Extent).EndOffset - $RemoveStart
                $ScriptText = $ScriptText.Remove($RemoveStart,$RemoveEnd).Insert($RemoveStart,$commandInfo.Name)
            }
        }
        $ScriptText
    }
}