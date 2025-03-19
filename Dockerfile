FROM mingc/android-build-box:latest

RUN apt-get update 
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3
RUN apt-get clean

# download Flutter SDK from Flutter Github repo
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set flutter environment path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor

# Install Android SDK dependencies
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    && apt-get clean



RUN eval "$(jenv init -)"

# Create and set the working directory
WORKDIR /app

# Copy the Flutter project into the container
COPY . .

# Check Flutter
RUN flutter doctor

# Get Flutter dependencies
RUN flutter pub get

# Build the Flutter project for Android
CMD ["flutter", "build", "aab", "--release"]
