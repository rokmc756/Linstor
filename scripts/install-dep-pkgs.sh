dnf config-manager --set-enabled crb

dnf install -y java-11-* asciidoctor selinux-policy-devel \
kernel-abi-stablelists kernel-devel kernel-rpm-macros


po4a-translate


update-alternatives --config java

There are 13 programs which provide 'java'.

  Selection    Command
-----------------------------------------------
   1           /usr/lib/jvm/jre-17-openjdk/bin/java
 + 2           /usr/lib/jvm/jre-1.8.0-openjdk/bin/java
   3           /usr/lib/jvm/jre-11-openjdk/bin/java
~~ snip

Enter to keep the current selection[+], or type selection number: 3
