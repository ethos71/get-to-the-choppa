#!/usr/bin/env python3
"""
Get To The Choppa - WiFi Monitor
A humorous WiFi monitoring tool inspired by classic action movies.
"""

import subprocess
import sys
import time
import random
import platform
from datetime import datetime


class WiFiMonitor:
    """Monitor WiFi connection and provide escape routes when things go wrong."""
    
    ARNOLD_QUOTES = [
        "GET TO THE CHOPPA! 🚁",
        "I'll be back... when the WiFi is fixed.",
        "Come with me if you want to connect.",
        "Hasta la vista, bad connection!",
        "It's not a tumor... it's your router!",
        "Consider this a divorce from your ISP.",
    ]
    
    ESCAPE_ROUTES = [
        "☕ Find a coffee shop with free WiFi",
        "📱 Enable mobile hotspot on your phone",
        "🔌 Switch to ethernet cable (old school!)",
        "🏢 Go to the library",
        "👨‍💻 Visit a coworking space",
        "🏠 Ask your neighbor for their WiFi password",
    ]
    
    def __init__(self):
        self.connection_lost = False
        self.check_count = 0
        
    def check_wifi_connection(self):
        """Check if WiFi is connected by pinging a reliable server."""
        try:
            # Determine ping command based on platform
            if platform.system().lower() == 'windows':
                # Windows: -n count, -w timeout in milliseconds
                ping_cmd = ["ping", "-n", "1", "-w", "2000", "8.8.8.8"]
            else:
                # Unix/Linux/Mac: -c count, -W timeout in seconds
                ping_cmd = ["ping", "-c", "1", "-W", "2", "8.8.8.8"]
            
            result = subprocess.run(
                ping_cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                timeout=3
            )
            return result.returncode == 0
        except (subprocess.TimeoutExpired, FileNotFoundError):
            # If ping command fails or times out, assume no connection
            return False
    
    def get_arnold_quote(self):
        """Get a random Arnold Schwarzenegger-style quote."""
        return random.choice(self.ARNOLD_QUOTES)
    
    def get_escape_route(self):
        """Get a random escape route suggestion."""
        return random.choice(self.ESCAPE_ROUTES)
    
    def display_status(self, connected):
        """Display the current WiFi status."""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.check_count += 1
        
        if connected:
            status = "✅ CONNECTED"
            message = "WiFi is operational. All systems go!"
            if self.connection_lost:
                message += "\n   Connection restored! You're back in action! 💪"
                self.connection_lost = False
        else:
            status = "❌ DISCONNECTED"
            message = f"\n   🚨 {self.get_arnold_quote()}\n"
            message += f"   Escape Route: {self.get_escape_route()}"
            self.connection_lost = True
        
        print(f"[{timestamp}] Check #{self.check_count}: {status}")
        print(f"   {message}")
        print()
    
    def monitor(self, interval=5):
        """
        Continuously monitor WiFi connection.
        
        Args:
            interval: Time in seconds between checks (default: 5)
        """
        print("=" * 60)
        print("GET TO THE CHOPPA - WiFi Monitor Starting...")
        print("=" * 60)
        print(f"Monitoring WiFi connection every {interval} seconds...")
        print("Press Ctrl+C to stop.\n")
        
        try:
            while True:
                connected = self.check_wifi_connection()
                self.display_status(connected)
                time.sleep(interval)
        except KeyboardInterrupt:
            print("\n" + "=" * 60)
            print("Monitor stopped. Stay connected out there! 💻")
            print("=" * 60)
            sys.exit(0)


def main():
    """Main entry point for the WiFi monitor."""
    monitor = WiFiMonitor()
    
    # Check if interval was provided as argument
    interval = 5
    if len(sys.argv) > 1:
        try:
            interval = int(sys.argv[1])
            if interval < 1:
                print("Interval must be at least 1 second.")
                sys.exit(1)
        except ValueError:
            print("Usage: python wifi_monitor.py [interval_in_seconds]")
            print("Example: python wifi_monitor.py 10")
            sys.exit(1)
    
    monitor.monitor(interval)


if __name__ == "__main__":
    main()
