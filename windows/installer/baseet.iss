#ifndef AppVersion
  #define AppVersion "1.0.0"
#endif
[Setup]
AppId={{BB9A71F3-1FD1-4B7E-8F02-4FD125FB4600}
AppName=Baseet
AppVersion={#AppVersion}
AppPublisher=Baseet
DefaultDirName={localappdata}\Programs\Baseet
DefaultGroupName=Baseet
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir=..\..\build\installer
OutputBaseFilename=Baseet-Setup-{#AppVersion}-windows-x64
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\baseet.exe
CloseApplications=yes
SetupIconFile=..\runner\resources\app_icon.ico

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; Flags: unchecked

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Baseet"; Filename: "{app}\baseet.exe"
Name: "{autodesktop}\Baseet"; Filename: "{app}\baseet.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\baseet.exe"; Description: "Open Baseet"; Flags: nowait postinstall skipifsilent

; Business records live in the user's application-support directory. Uninstall
; deliberately leaves that directory intact so upgrades do not remove records.
