# SoftwareConfig downloads and installs required software
Configuration SoftwareConfig {
  Chocolatey SublimeText3Install {
    Ensure = 'Present'
    Package = 'sublimetext3'
    Version = '3.0.0.3103'
  }
  Chocolatey SublimeText3PackageControlInstall {
    Ensure = 'Present'
    Package = 'sublimetext3.packagecontrol'
    Version = '2.0.0.20140915'
  }
  #Chocolatey VisualStudioCommunity2013Install {
  #  Ensure = 'Present'
  #  Package = 'visualstudiocommunity2013'
  #  Version = '12.0.21005.1'
  #}
  Chocolatey VisualStudio2015CommunityInstall {
    Ensure = 'Present'
    Package = 'visualstudio2015community'
    Version = '14.0.24720.01'
  }
  Chocolatey WindowsSdkInstall {
    Ensure = 'Present'
    Package = 'windows-sdk-8.1'
    Version = '8.100.26654.0'
  }
  Import-DscResource -ModuleName PSDesiredStateConfiguration
  Package RustInstall {
    Name = 'Rust beta 1.7 (MSVC 64-bit)'
    Path = 'https://static.rust-lang.org/dist/rust-beta-x86_64-pc-windows-msvc.msi'
    ProductId = '2B9726D5-BA12-44AF-B083-178CE2E08DD1'
    Ensure = 'Present'
    LogPath = ('{0}\log\{1}.rust-beta-x86_64-pc-windows-msvc.msi.log' -f $env:SystemDrive, [DateTime]::Now.ToString("yyyyMMddHHmmss"))
  }
  Package MozillaBuildInstall {
    Name = 'MozillaBuild'
    Path = 'http://ftp.mozilla.org/pub/mozilla/libraries/win32/MozillaBuildSetup-2.1.0.exe'
    ProductId = ''
    Arguments = '/S'
    Ensure = 'Present'
    LogPath = ('{0}\log\{1}.MozillaBuildSetup-2.1.0.exe.log' -f $env:SystemDrive, [DateTime]::Now.ToString("yyyyMMddHHmmss"))
  }
}
