FROM unclecode/crawl4ai:latest

USER root

# Install Xvfb and dependencies for headless browser
RUN apt-get update && \
    apt-get install -y xvfb xauth && \
    rm -rf /var/lib/apt/lists/*

# Create .crawl4ai directory for appuser (uid 999)
RUN mkdir -p /home/appuser/.crawl4ai && \
    chown -R appuser:appuser /home/appuser/.crawl4ai && \
    chmod 755 /home/appuser/.crawl4ai

# Set display and home environment variables
ENV DISPLAY=:99
ENV HOME=/home/appuser

# Create startup script
RUN echo '#!/bin/bash\n\
set -e\n\
echo "Cleaning X server locks..."\n\
rm -f /tmp/.X99-lock /tmp/.X11-unix/X99\n\
echo "Starting Xvfb..."\n\
Xvfb :99 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset > /tmp/xvfb.log 2>&1 &\n\
XVFB_PID=$!\n\
sleep 3\n\
echo "Xvfb started on display :99 (PID: $XVFB_PID)"\n\
echo "Ensuring appuser .crawl4ai permissions..."\n\
mkdir -p /home/appuser/.crawl4ai\n\
chown -R appuser:appuser /home/appuser/.crawl4ai\n\
chmod 755 /home/appuser/.crawl4ai\n\
echo "Starting Crawl4AI via supervisord..."\n\
exec supervisord -c supervisord.conf' > /start.sh && \
    chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
