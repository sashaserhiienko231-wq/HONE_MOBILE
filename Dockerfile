# Multi-stage Dockerfile for Hone Mobile
FROM ubuntu:22.04 AS base

# Set environment variables
ENV FLUTTER_VERSION=3.16.0
ENV JAVA_VERSION=17
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_SDK_VERSION=8512546
ENV ANDROID_BUILD_TOOLS_VERSION=33.0.2
ENV ANDROID_PLATFORM_VERSION=34

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    wget \
    openjdk-${JAVA_VERSION}-jdk \
    python3 \
    python3-pip \
    build-essential \
    lib32stdc++6 \
    lib32z1 \
    lib32ncurses6 \
    libbz2-1.0 \
    lib32gcc1 \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libxtst6 \
    libxi6 \
    libxcursor1 \
    libnss3 \
    libgtk-3-0 \
    libgconf-2-4 \
    libxrandr2 \
    libasound2 \
    libpangocairo-1.0-0 \
    libatk1.0-0 \
    libcairo-gobject2 \
    libgdk-pixbuf2.0-0 \
    libgtk-3-0 \
    libxss1 \
    libxtst6 \
    libxrandr2 \
    libasound2 \
    libpangocairo-1.0-0 \
    libatk1.0-0 \
    libcairo-gobject2 \
    libgdk-pixbuf2.0-0 \
    libxext6 \
    libxrender1 \
    libxi6 \
    libxtst6 \
    libxrandr2 \
    libasound2 \
    libpangocairo-1.0-0 \
    libatk1.0-0 \
    libcairo-gobject2 \
    libgdk-pixbuf2.0-0 \
    libxss1 \
    libnss3 \
    libgtk-3-0 \
    libgconf-2-4 \
    && rm -rf /var/lib/apt/lists/*

# Set Java environment
ENV JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# Install Android SDK
RUN mkdir -p $ANDROID_SDK_ROOT && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip -O commandlinetools.zip && \
    unzip -q commandlinetools.zip -d $ANDROID_SDK_ROOT/cmdline-tools && \
    rm commandlinetools.zip

# Set Android SDK environment variables
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/build-tools/$ANDROID_BUILD_TOOLS_VERSION/bin

# Install Android SDK components
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-$ANDROID_PLATFORM_VERSION" "build-tools;$ANDROID_BUILD_TOOLS_VERSION"

# Install Flutter
RUN wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz -O flutter.tar.xz && \
    tar xf flutter.tar.xz -C /opt/ && \
    rm flutter.tar.xz

# Set Flutter environment
ENV PATH=/opt/flutter/bin:$PATH
RUN flutter doctor

# Create app directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml ./
COPY pubspec.lock ./

# Get Flutter dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build stage
FROM base AS builder

# Build the app
RUN flutter build apk --release --shrink --dart-define=FLUTTER_WEB_CANVASKIT_ENABLED=true

# Production stage
FROM ubuntu:22.04 AS production

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Create app user
RUN useradd -m -s /bin/bash hone

# Copy APK from builder stage
COPY --from=builder /app/build/app/outputs/flutter-apk/app-release.apk /app/hone-mobile.apk

# Set permissions
RUN chown -R hone:hone /app

# Switch to non-root user
USER hone

# Expose port for potential web server
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Set working directory
WORKDIR /app

# Default command
CMD ["echo", "Hone Mobile APK is available at /app/hone-mobile.apk"]

# Development stage
FROM base AS development

# Install development tools
RUN pip install pytest pytest-asyncio

# Copy test files
COPY test/ ./test/

# Run tests
RUN flutter test --coverage

# Install development dependencies
RUN pip install black flake8 mypy

# Code quality checks
RUN black --check lib/
RUN flake8 lib/
RUN mypy lib/

# Development command
CMD ["flutter", "run", "--hot"]

# Testing stage
FROM base AS testing

# Copy test files
COPY test/ ./test/

# Run all tests
RUN flutter test --coverage

# Run integration tests
RUN flutter test integration_test/

# Performance tests
RUN flutter test --name="performance"

# Security tests
RUN flutter test --name="security"

# Documentation stage
FROM base AS documentation

# Install documentation tools
RUN pip install mkdocs mkdocs-material

# Copy documentation
COPY docs/ ./docs/

# Generate documentation
RUN mkdocs build

# Serve documentation
EXPOSE 8000
CMD ["mkdocs", "serve", "--dev-addr=0.0.0.0:8000"]

# Multi-arch build stage
FROM --platform=linux/amd64,linux/arm64 base AS multiarch

# Build for multiple architectures
RUN flutter build apk --release --shrink --dart-define=FLUTTER_WEB_CANVASKIT_ENABLED=true

# CI/CD stage
FROM base AS ci-cd

# Install CI/CD tools
RUN pip install pre-commit black flake8 mypy pytest

# Copy pre-commit configuration
COPY .pre-commit-config.yaml ./

# Install pre-commit hooks
RUN pre-commit install

# Run pre-commit checks
RUN pre-commit run --all-files

# Security scanning
RUN pip install bandit safety
RUN bandit -r lib/
RUN safety check

# Performance benchmarking
RUN pip install pytest-benchmark
RUN pytest --benchmark-only

# Monitoring stage
FROM base AS monitoring

# Install monitoring tools
RUN pip install prometheus-client grafana-api

# Copy monitoring configuration
COPY monitoring/ ./monitoring/

# Start monitoring
EXPOSE 9090
CMD ["python", "monitoring/metrics.py"]
