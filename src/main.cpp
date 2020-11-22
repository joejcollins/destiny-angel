#include <Arduino.h>
#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <SPI.h>
#include <Ethernet.h>
#include <aWOT.h>
#define DHTPIN 2
#define DHTTYPE DHT22
DHT dht = DHT(DHTPIN, DHTTYPE);
float temperature = 0;
float humidity = 0;
byte mac[] = {
  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED
};
IPAddress ip(10, 0, 21, 211);
EthernetServer server(80);
Application app;
void readSensor()
{
  humidity = dht.readHumidity();
  temperature = dht.readTemperature();
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
  Serial.begin(9600);
  while (!Serial){;}
  Serial.println("Set up sensor");
  dht.begin();
  Ethernet.begin(mac, ip);
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
  app.get("/", &metricsCmd);
  app.get("/metrics", &metricsCmd);
}
void loop()
{
    delay(2000);
    readSensor();
    serialPrintReadings();
    EthernetClient client = server.available();
    if (client.connected()) {
      app.process(&client);
      client.stop();
    }
}
