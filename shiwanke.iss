; �ű��� Inno Setup �ű��� ���ɣ�
; �йش��� Inno Setup �ű��ļ�����ϸ��������İ����ĵ���

#define MyAppName "ʰ��ʹ�ӡ"
#define MyAppVersion "1.0"
#define MyAppPublisher "���������ֵ����������޹�˾"
#define MyAppURL "http://www.shiwanke.net"
#define MyAppExeName "start.bat"
; ���ݲ�ͬ�����߻������޸���Ŀ����Ŀ¼
#define BaseUrl "D:\services\htdocs\printer"

[Setup]
; ע: AppId��ֵΪ������ʶ��Ӧ�ó���
; ��ҪΪ������װ����ʹ����ͬ��AppIdֵ��
; (�����µ�GUID����� ����|��IDE������GUID��)
AppId={{B08D166C-FAA1-49DE-86B9-0BAA95E5D3DD}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DisableProgramGroupPage=yes
OutPutdir={#BaseUrl}\extra
OutputBaseFilename=shiwanke_setup
SetupIconFile={#BaseUrl}\src\printer.ico
Compression=lzma
SolidCompression=yes

[Languages]
Name: "chinesesimp"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkablealone
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkablealone
Name: "startupicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; 

[Files]
Source: "{#BaseUrl}\src\start.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BaseUrl}\src\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#BaseUrl}\src\printer.ico"; DestDir: "{app}"; Flags: ignoreversion
; ע��: ��Ҫ���κι���ϵͳ�ļ���ʹ�á�Flags: ignoreversion��
; VC Redistribute  
Source: "{#BaseUrl}\src\vc_redist.x86.exe"; DestDir: "{app}"; Check: NeedInstallVC8SP1

[Icons]
Name: "{commonprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; IconFilename: "{app}\printer.ico"

[Code]  
var  
  vc8SP1Missing: Boolean;  
  
function NeedInstallVC8SP1(): Boolean;  
begin  
  Result := vc8SP1Missing;  
end;  
  
function InitializeSetup(): Boolean;  
begin  
// �����ͬ�汾���л�����Ӧ��GUID��ͬ  
  if RegValueExists(HKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{710f4c1c-cc18-4c49-8cbf-51240c89a1a2}', 'Version') // Microsoft Visual C++ 2005 Redistributable X86 [XP/Win7 32λ V8.0.61001]  
  or RegValueExists(HKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{ad8a2fa1-06e7-4b0d-927d-6e54b3d31028}', 'Version') // Microsoft Visual C++ 2005 Redistributable X64 [Win7 64λ V8.0.61000]  
  or RegValueExists(HKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{071C9B48-7C32-4621-A0AC-3F809523288F}', 'Version') // Microsoft Visual C++ 2005 SP1 Redistributable X64 [Win7 64λ V8.0.56336]  
    then  
      begin  
        vc8SP1Missing := false;  
      end  
    else  
      begin  
        vc8SP1Missing := true;  
      end;  
  result := true;  
end;  

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
Filename: "{tmp}\vc_redist.x86.exe"; Parameters: /q; WorkingDir: {tmp}; Flags: skipifdoesntexist; StatusMsg: "Install Microsoft Visual C++ 2014 Runtime ..."; Check: NeedInstallVC8SP1  