#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:5.0.400-alpine3.13 AS build
WORKDIR /src
COPY ["src/Dotnet.Docker.Hardening.API/Dotnet.Docker.Hardening.API.csproj", "src/Dotnet.Docker.Hardening.API/"]
RUN dotnet restore "src/Dotnet.Docker.Hardening.API/Dotnet.Docker.Hardening.API.csproj"
COPY . .
WORKDIR "/src/src/Dotnet.Docker.Hardening.API"
RUN dotnet build "Dotnet.Docker.Hardening.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Dotnet.Docker.Hardening.API.csproj" -c Release -o /app/publish -r alpine-x64

FROM mcr.microsoft.com/dotnet/runtime-deps:5.0.9-alpine3.13 AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["./Dotnet.Docker.Hardening.API.dll"]