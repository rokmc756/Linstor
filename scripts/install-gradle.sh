
wget https://services.gradle.org/distributions/gradle-7.5.1-bin.zip
mkdir /opt/gradle
unzip -d /opt/gradle gradle-7.5.1-bin.zip
export PATH=$PATH:/opt/gradle/gradle-7.5.1/bin
vi ~/.bashrc

# Gradle Support Matix for Java Versions
# https://docs.gradle.org/current/userguide/compatibility.html

# Disabling the Daemon
# https://docs.gradle.org/5.6.4/userguide/gradle_daemon.html

