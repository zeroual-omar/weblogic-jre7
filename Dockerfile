# APACHE LICENSE, VERSION 2.0

FROM oraclelinux:7-slim

MAINTAINER omar zeroual <omar.zeroual@sgs.com>

RUN set -eux; \
	yum install -y \
		gzip \
		tar \
	; \
	rm -rf /var/cache/yum
	

# Default to UTF-8 file.encoding
ENV LANG en_US.UTF-8


# Download the JDK from
#
#  https://www.oracle.com/technetwork/java/javase/downloads/server-jre7-downloads-2133154.html
#	
# and place it on the same directory as the Dockerfile
#

ENV JAVA_VERSION=1.7.0_80 \
	JAVA_PKG=server-jre-7u80-linux-x64.tar.gz \
	JAVA_MD5=366a145fb3a185264b51555546ce2f87 \
	JAVA_HOME=/usr/java/jdk-7
	
ENV	PATH $JAVA_HOME/bin:$PATH

##
COPY $JAVA_PKG /tmp/jdk.tgz
RUN set -eux; \
	\
	echo "$JAVA_MD5 */tmp/jdk.tgz" | md5sum -c -; \
	mkdir -p "$JAVA_HOME"; \
	tar --extract --file /tmp/jdk.tgz --directory "$JAVA_HOME" --strip-components 1; \
	rm /tmp/jdk.tgz; \
	\
	ln -sfT "$JAVA_HOME" /usr/java/default; \
	ln -sfT "$JAVA_HOME" /usr/java/latest; \
	for bin in "$JAVA_HOME/bin/"*; do \
		base="$(basename "$bin")"; \
		[ ! -e "/usr/bin/$base" ]; \
		alternatives --install "/usr/bin/$base" "$base" "$bin" 20000; \
	done; \
# -Xshare:dump will create a CDS archive to improve startup in subsequent runs	
	java -Xshare:dump; \
	java -version; \
	javac -version
	
