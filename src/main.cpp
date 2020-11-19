#include <Arduino.h>
// Include the libraries:
#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <SPI.h>
#include <Ethernet.h>

// Set DHT pin:
#define DHTPIN 2

// Set DHT type, uncomment whatever type you're using!
//#define DHTTYPE DHT11   // DHT 11 
#define DHTTYPE DHT22   // DHT 22  (AM2302)
//#define DHTTYPE DHT21   // DHT 21 (AM2301)
// Initialize DHT sensor for normal 16mhz Arduino:
DHT dht = DHT(DHTPIN, DHTTYPE);

// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
byte mac[] = {
  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED
};
IPAddress ip(10, 0, 21, 211);
// Initialize the Ethernet server library
// with the IP address and port you want to use
// (port 80 is default for HTTP):
EthernetServer server(80);

/**
 * 
 */
void setup() 
{
  // Open serial communications and wait for the port to open.
  Serial.begin(9600);
  while (!Serial) 
  {
    ; // Wait for serial port to connect (only needed for native USB ports).
  }
  Serial.println("Webserver set up");

  // Start the Ethernet connection and the server:
  Ethernet.begin(mac, ip);
  // Check that the Ethernet hardware is present
  if (Ethernet.hardwareStatus() == EthernetNoHardware) 
  {
    Serial.println("Ethernet shield was not found.");
    while (true) 
    {
      delay(1); // Do nothing since there is no point in proceeding.
    }
  }
  if (Ethernet.linkStatus() == LinkOFF) {
    Serial.println("Ethernet cable is not connected.");
  }

  // Start the sensor
  Serial.println("Sensor set up");
  dht.begin();
}


/**
 * 
 */
void loop() 
{
  // Wait a few seconds between measurements.
  delay(3000);
  // Reading temperature or humidity takes about 250 milliseconds
  // Sensor readings may also be up to 2 seconds 'old'
  // Read the humidity in %:
  float humidity = dht.readHumidity();
  // Read the temperature as Celsius:
  float temperature = dht.readTemperature();
  // Check if any reads failed and exit early (to try again):
  if (isnan(humidity) || isnan(temperature)) 
  {
    Serial.println("Failed to read from sensor");
    return;
  }

  Serial.print("Humidity: ");
  Serial.print(humidity);
  Serial.print(" % | ");
  Serial.print("Temperature: ");
  Serial.print(temperature);
  Serial.println(" C");

  EthernetClient client = server.available();
  if (client) 
  {
    Serial.println("new client");
    // an http request ends with a blank line
    boolean currentLineIsBlank = true;
    while (client.connected()) 
    {
      if (client.available()) 
      {
        char c = client.read();
        Serial.write(c);
        // if you've gotten to the end of the line (received a newline
        // character) and the line is blank, the http request has ended,
        // so you can send a reply
        if (c == '\n' && currentLineIsBlank)
        {
          client.println("HTTP/1.1 200 OK");
          client.println("Connection: close");
          client.println();

          const String temp = "temperature " + String(temperature)+"\n";
          const String hum = "humidity " + String(humidity)+"\n";

          client.println("# HELP temperature is the last temperature reading in degrees celsius");
          client.print("# TYPE temp gauge\n");
          client.print(temp);
          client.println("# HELP humidity is the last relative humidity reading as a percentage");
          client.print("# TYPE humidity gauge\n");
          client.print(hum);
          break;
        }
        if (c == '\n')
        {
          // you're starting a new line
          currentLineIsBlank = true;
        }
        else if (c != '\r')
        {
          // you've gotten a character on the current line
          currentLineIsBlank = false;
        }
      }
    }
    // give the web browser time to receive the data
    delay(1);
    // close the connection:
    client.stop();
    Serial.println("client disconnected");
  }
}