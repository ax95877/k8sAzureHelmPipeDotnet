# Multi-stage Dockerfile for .NET 10 Web API
# Stage 1: Build & Publish
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy project file and restore dependencies (layer cache optimization)
COPY ["k8s.csproj", "./"]
RUN dotnet restore "k8s.csproj"

# Copy remaining source files and publish
COPY . .
RUN dotnet publish "k8s.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

# Expose default ASP.NET Core port (8080 in .NET 8+)
EXPOSE 8080
ENV ASPNETCORE_HTTP_PORTS=8080

# Copy published artifacts from build stage
COPY --from=build /app/publish .

# Run as non-root user for security best practices
USER app

ENTRYPOINT ["dotnet", "k8s.dll"]
