FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine AS publish
#RUN dotnet publish "Dotnet.Docker.Hardening.API.csproj" -c Release -o /app/publish -r alpine-x64
WORKDIR /src
RUN mkdir Dotnet.Docker.Hardening.API/
COPY ./src/Dotnet.Docker.Hardening.API/Dotnet.Docker.Hardening.API.csproj ./Dotnet.Docker.Hardening.API/
# specify target runtime for destroy
RUN dotnet restore "./Dotnet.Docker.Hardening.API/Dotnet.Docker.Hardening.API.csproj" --runtime alpine-x64

COPY /src/Dotnet.Docker.Hardening.API/ ./Dotnet.Docker.Hardening.API/

RUN dotnet publish "./Dotnet.Docker.Hardening.API/Dotnet.Docker.Hardening.API.csproj" -c Release -o /app/publish \
  --no-restore \  
  --runtime alpine-x64 \
  --self-contained true \
  /p:PublishTrimmed=true \
  /p:PublishSingleFile=true

FROM mcr.microsoft.com/dotnet/runtime-deps:6.0.2-alpine3.14 AS final

# create a new user and change directory ownership
#RUN addgroup --group dotnetgroup --gid 2000 && adduser --disabled-password \
RUN adduser -u 1000 --disabled-password \
  --home /app \
  --gecos '' dotnetuser && chown -R dotnetuser /app

# upgrade musl to remove potential vulnerability
# RUN apk upgrade musl

# impersonate into the new user
USER dotnetuser
WORKDIR /app

# use port 5000 because
EXPOSE 5000
# ENV ASPNETCORE_URLS=http://*:5000
COPY --from=publish /app/publish .

ENV COMPlus_EnableDiagnostics=0

# instruct Kestrel to expose API on port 5000
ENTRYPOINT ["./Dotnet.Docker.Hardening.API", "--urls", "http://*:5000"]