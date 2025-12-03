# ----------------------------
# 1. Build Stage
# ----------------------------
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy only the project file first (for caching)
COPY CryptoAPI/CryptoAPI.csproj ./CryptoAPI/

WORKDIR /src/CryptoAPI

# Restore dependencies
RUN dotnet restore CryptoAPI.csproj

# Copy the rest of the source code
COPY CryptoAPI/. .

# Build the project
RUN dotnet build CryptoAPI.csproj -c Release --no-restore

# Publish the app
RUN dotnet publish CryptoAPI.csproj -c Release -o /app/publish --no-build

# ----------------------------
# 2. Runtime Stage
# ----------------------------
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Copy published files from build stage
COPY --from=build /app/publish .

# Expose port (change if your app uses a different port)
EXPOSE 80

# Entry point
ENTRYPOINT ["dotnet", "CryptoAPI.dll"]