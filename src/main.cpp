#include <Arduino.h>
// Include the libraries:
#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <SPI.h>
#include <Ethernet.h>
#include <aWOT.h>

// Set DHT pin:
#define DHTPIN 2
// Set DHT type
#define DHTTYPE DHT22   // DHT 22  (AM2302)
// Initialize DHT sensor for normal 16mhz Arduino:
DHT dht = DHT(DHTPIN, DHTTYPE);
// globals to store readings
float temperature = 0;
float humidity = 0;

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
Application app;

void metricsCmd(Request &req, Response &res)
{
  Serial.println("Request for metrics");
  res.set("Content-Type", "text/plain");
  res.print("# HELP temperature is the last temperature reading in degrees celsius\n");
  res.print("# TYPE temp gauge\n");
  res.print("temperature " + String(temperature) + "\n");
  res.print("# HELP humidity is the last relative humidity reading as a percentage\n");
  res.print("# TYPE humidity gauge\n");
  res.print("humidity " + String(humidity) + "\n");
}

void setup() 
{
  // Open serial communications and wait for the port to open.
  Serial.begin(9600);
  Serial.println("Set up webserver");
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
  // Mount the handlers
  app.get("/", &metricsCmd);
  app.get("/metrics", &metricsCmd);
  // Start the sensor
  Serial.println("Set up sensor");
  dht.begin();
}

void readSensor()
{
  // Read the humidity in %:
  humidity = dht.readHumidity();
  // Read the temperature as Celsius:
  temperature = dht.readTemperature();
  // Check if any reads failed and exit early (to try again):
  if (isnan(humidity) || isnan(temperature)) 
  {
    Serial.println("Failed to read from sensor");
    return;
  }
}

void serialPrintReadings()
{
  Serial.print("Humidity: ");
  Serial.print(humidity);
  Serial.print(" % | ");
  Serial.print("Temperature: ");
  Serial.print(temperature);
  Serial.println(" C");
}

void loop() 
{
  // Wait a couple of seconds between measurements.
  delay(2000);
  // Reading temperature or humidity takes about 250 milliseconds
  // Sensor readings may also be up to 2 seconds 'old'
  readSensor();
  serialPrintReadings();
  EthernetClient client = server.available();
  if (client.connected()) {
    app.process(&client);
    client.stop();
  }
}