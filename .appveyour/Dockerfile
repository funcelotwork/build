FROM mcr.microsoft.com/dotnet/core/sdk:3.1.302 AS build
WORKDIR /app

# copy csproj and restore as distinct layers
COPY *.sln .
COPY Build.Abstractions/*.csproj ./Build.Abstractions/
COPY Build/*.csproj ./Build/
COPY Build.Tests/*.csproj ./Build.Tests/
COPY Build.Behave/*.csproj ./Build.Behave/
RUN dotnet restore

# copy everything else and build app
COPY . .
WORKDIR /app/Build
RUN dotnet build --verbosity quiet

WORKDIR /app/Build.Tests
ENTRYPOINT ["dotnet","test","--logger:trx"]
