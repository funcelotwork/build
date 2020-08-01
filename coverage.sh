#!/usr/bin/env bash
set -e

if [[ ! -f "./packages/tools/dotnet-sonarscanner.exe" ]]
then
  dotnet tool install --global dotnet-sonarscanner
fi
if [[ ! -f "./packages/tools/csmacnz.Coveralls.exe" ]]
then
  dotnet tool install --tool-path packages/tools coveralls.net
fi

export CurrentDir="$(echo $(pwd))"
echo CurrentDir=$CurrentDir
export DotNet_Version="$(cat ${CurrentDir}/.config/DotNetCliVersion.txt)"
echo DotNet_Version=$DotNet_Version
export OpenCover_Version="4.7.922"
echo OpenCover_Version=$OpenCover_Version

# Moving from version 2.5.1 to 2.6.0 requires /p:Include=[build.*]* /p:Exclude="[xunit*]*,[build.abstractions.*]*"
export CoverletMsbuild_Version="2.6.0"
echo CoverletMsbuild_Version=$CoverletMsbuild_Version

export Tools_Path="$(echo ${CurrentDir}/packages/tools)"
echo Tools_Path=$Tools_Path
export DotNet_Path="$(echo ${CurrentDir}/packages/dotnet/${DotNet_Version})"
echo DotNet_Path=$DotNet_Path
export NuGet_Path="$(echo ${CurrentDir}/packages/nuget)"
echo NuGet_Path=$NuGet_Path
export OpenCover_Path="$(echo ${CurrentDir}/packages/.packages/OpenCover/${OpenCover_Version}/tools)"
echo OpenCover_Path=$OpenCover_Path

export PATH="$DotNet_Path:$NuGet_Path:$Tools_Path:$OpenCover_Path:$PATH"

dotnet add ./Build.Tests package --package-directory packages/.packages OpenCover --version $OpenCover_Version
dotnet add ./Build.Tests package --package-directory packages/.packages coverlet.msbuild --version $CoverletMsbuild_Version

dotnet restore --packages packages/.packages

dotnet-sonarscanner begin /o:"hack2root-github" /d:sonar.login="$SONARCLOUDTOKEN" /k:"build-core" /d:sonar.host.url="https://sonarcloud.io" /n:"build" /v:"1.0" /d:sonar.cs.opencover.reportsPaths="Build.Tests/coverage.opencover.xml" /d:sonar.coverage.inclusions="**/*.cs" /d:sonar.coverage.exclusions="**/Interface*.cs,**/*Test*.cs,**/*Exception*.cs,**/*Attribute*.cs,**/Middleware/*.cs,/Pages/*.cs,**/Program.cs,**/Startup.cs,**/sample/*,**/aspnetcore/*,**/wwwroot/*,**/xunit/*,**/*.js,**/coverage.opencover.xml" /d:sonar.sourceEncoding="UTF-8" /d:sonar.language=cs
dotnet build --configuration Release
dotnet test --configuration Release --no-build Build.Tests /p:CollectCoverage=true /p:CoverletOutputFormat=opencover /p:Include="[Build]*" /p:Exclude="[Build]*AttributeProvider*" -v:n
dotnet-sonarscanner end /d:sonar.login="$SONARCLOUDTOKEN"
