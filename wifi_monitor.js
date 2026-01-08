#!/usr/bin/env node
/**
 * Get To The Choppa - WiFi Monitor
 * A humorous WiFi monitoring tool inspired by classic action movies.
 */

const { exec } = require('child_process');
const { promisify } = require('util');

const execAsync = promisify(exec);

class WiFiMonitor {
  constructor() {
    this.connectionLost = false;
    this.checkCount = 0;
    
    this.ARNOLD_QUOTES = [
      "GET TO THE CHOPPA! 🚁",
      "I'll be back... when the WiFi is fixed.",
      "Come with me if you want to connect.",
      "Hasta la vista, bad connection!",
      "It's not a tumor... it's your router!",
      "Consider this a divorce from your ISP.",
    ];
    
    this.ESCAPE_ROUTES = [
      "☕ Find a coffee shop with free WiFi",
      "📱 Enable mobile hotspot on your phone",
      "🔌 Switch to ethernet cable (old school!)",
      "🏢 Go to the library",
      "👨‍💻 Visit a coworking space",
      "🏠 Ask your neighbor for their WiFi password",
    ];
  }
  
  /**
   * Check if WiFi is connected by pinging a reliable server.
   * @returns {Promise<boolean>} True if connected, false otherwise
   */
  async checkWiFiConnection() {
    try {
      // Determine ping command based on platform
      const pingCmd = process.platform === 'win32' 
        ? 'ping -n 1 -w 2000 8.8.8.8'
        : 'ping -c 1 -W 2 8.8.8.8';
      
      await execAsync(pingCmd);
      return true;
    } catch (error) {
      return false;
    }
  }
  
  /**
   * Get a random Arnold Schwarzenegger-style quote.
   * @returns {string} A random quote
   */
  getArnoldQuote() {
    return this.ARNOLD_QUOTES[Math.floor(Math.random() * this.ARNOLD_QUOTES.length)];
  }
  
  /**
   * Get a random escape route suggestion.
   * @returns {string} A random escape route
   */
  getEscapeRoute() {
    return this.ESCAPE_ROUTES[Math.floor(Math.random() * this.ESCAPE_ROUTES.length)];
  }
  
  /**
   * Display the current WiFi status.
   * @param {boolean} connected - Whether WiFi is connected
   */
  displayStatus(connected) {
    const timestamp = new Date().toISOString().replace('T', ' ').substring(0, 19);
    this.checkCount++;
    
    let status, message;
    
    if (connected) {
      status = "✅ CONNECTED";
      message = "WiFi is operational. All systems go!";
      if (this.connectionLost) {
        message += "\n   Connection restored! You're back in action! 💪";
        this.connectionLost = false;
      }
    } else {
      status = "❌ DISCONNECTED";
      message = `\n   🚨 ${this.getArnoldQuote()}\n`;
      message += `   Escape Route: ${this.getEscapeRoute()}`;
      this.connectionLost = true;
    }
    
    console.log(`[${timestamp}] Check #${this.checkCount}: ${status}`);
    console.log(`   ${message}`);
    console.log();
  }
  
  /**
   * Continuously monitor WiFi connection.
   * @param {number} interval - Time in seconds between checks (default: 5)
   */
  async monitor(interval = 5) {
    console.log("=".repeat(60));
    console.log("GET TO THE CHOPPA - WiFi Monitor Starting...");
    console.log("=".repeat(60));
    console.log(`Monitoring WiFi connection every ${interval} seconds...`);
    console.log("Press Ctrl+C to stop.\n");
    
    // Do the first check immediately
    const connected = await this.checkWiFiConnection();
    this.displayStatus(connected);
    
    // Then check at regular intervals
    const intervalId = setInterval(async () => {
      const connected = await this.checkWiFiConnection();
      this.displayStatus(connected);
    }, interval * 1000);
    
    // Handle graceful shutdown
    process.on('SIGINT', () => {
      clearInterval(intervalId);
      console.log("\n" + "=".repeat(60));
      console.log("Monitor stopped. Stay connected out there! 💻");
      console.log("=".repeat(60));
      process.exit(0);
    });
  }
}

/**
 * Main entry point for the WiFi monitor.
 */
function main() {
  const monitor = new WiFiMonitor();
  
  // Check if interval was provided as argument
  let interval = 5;
  if (process.argv.length > 2) {
    interval = parseInt(process.argv[2], 10);
    if (isNaN(interval) || interval < 1) {
      console.error("Usage: node wifi_monitor.js [interval_in_seconds]");
      console.error("Example: node wifi_monitor.js 10");
      process.exit(1);
    }
  }
  
  monitor.monitor(interval);
}

// Run if called directly
if (require.main === module) {
  main();
}

module.exports = WiFiMonitor;
