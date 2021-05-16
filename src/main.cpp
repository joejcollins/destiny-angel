#include <Arduino.h>
#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <SPI.h>
#include <Ethernet.h>
#include <aWOT.h>
/*** Configuration ***/
#define DHTPIN 2
#define DHTTYPE DHT22
DHT dht = DHT(DHTPIN, DHTTYPE);
float temperature = 0;
float humidity = 0;
byte mac[] = {
  0xF6, 0x54, 0xA8, 0x28, 0xE5, 0xD0
};
IPAddress ip(10, 0, 21, 212);
EthernetServer server(80);
Application app;
/*** Functions ***/
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
void indexCmd(Request &req, Response &res)
{
  Serial.println("Request for index");
  res.set("Content-Type", "text/html");
  res.println("<html>");
  res.println("<head>");
  res.println("  <meta http-equiv=\"refresh\" content=\"5\">");
  res.println("</head>");
  res.println("<body>");
  res.println("  <H1>Temp: " + String(temperature) + "</p>");
  res.println("</body>");
  res.println("</html>");
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
/*** Setup ***/
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
  app.get("/", &indexCmd);
  app.get("/metrics", &metricsCmd);
}
/*** Loop ***/
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
