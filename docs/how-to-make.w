\documentclass[a4paper, 12pt]{article}
\usepackage{fullpage} % for 1.5 cm margins
\renewcommand{\familydefault}{\sfdefault} % so it doesn't look like LaTeX
\usepackage{helvet}
\usepackage{graphicx}
\graphicspath{ {imgs/} }
\usepackage{float} % so the figures stay with the text

\usepackage{abstract}
\renewcommand{\abstractname}{Overview}
\raggedright

\usepackage{parskip}

\usepackage{hyperref}
\hypersetup{
    colorlinks=true,
    linkcolor=blue,
    filecolor=magenta,      
    urlcolor=cyan,
}

\usepackage{listings}
\usepackage{color}
\lstset{language=C++,
        basicstyle=\ttfamily,
        keywordstyle=\color{blue}\ttfamily,
        stringstyle=\color{red}\ttfamily,
        commentstyle=\color{green}\ttfamily,
        morecomment=[l][\color{magenta}]{\#}
}

\title{Promethean Temperature Sensor}
\author{Joe Collins}

\begin{document}
\maketitle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\tableofcontents

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{The Problem}

A temperature sensor that can be monitoring using Prometheus (\url{https://prometheus.io/}).

Prometheus is our main system for monitoring system status,
so it makes sense to have temperature sensors that can also be monitored using Prometheus.
There doesn't appear to be anything available off the shelf.
There are temperature monitors but some effort would be required to get 
them to integrate with our Prometheus monitoring system.
So we might as well build a bespoke temperature sensor
that can be polled directly by Prometheus.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Components}

Shopping list and details, with prices.

\begin{figure}[H]
  \centering
  \includegraphics[width=0.8\textwidth]{components.jpg}
  \caption{Components}
\end{figure}


\begin{tabular}{ll}
  \textbf{Component} & \textbf{Cost} \\ 
  \hline
  Arduino Uno Rev3, ATmega328P, CH340G Compatible Board & \pounds 5.79 \\
  UK 9V AC/DC Power Supply Adapter Plug for Arduino Uno & \pounds 7.95 \\
  Ethernet Shield LAN W5100 for Arduino Uno & \pounds 7.75 \\
  DHT22 AM2302 Digital Temperature and Humidity Sensor & \pounds 6.90 \\
  0.25 Watt Metal Film Resistor 10K Ohm & \pounds 0.99 \\
  Uno Ethernet Shield Case & \pounds 10.36 \\
  \hline
  Total cost in November 2020 & \textbf{\pounds 39.74}  \\
\end{tabular}

\subsection{Sensor}

AM2302 capacitive humidity sensing digital temperature and humidity module is one that contains the
compound has been calibrated digital signal output of the temperature and humidity sensors. 



\subsection{Sensor}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Wiring}

Pull up resistor.



\begin{figure}[H]
  \centering
  \includegraphics[width=0.8\textwidth]{wiring-dht22.jpg}
  \caption{Wiring diagram with pull up resistor}
\end{figure}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Programming}

Install 

\begin{itemize}
  \item VSCode \\
  \url{https://code.visualstudio.com/}
  \item Platformio \\
  \url{https://marketplace.visualstudio.com/items?itemName=platformio.platformio-ide}
\end{itemize}



Platform io

Include serial for output to monitor

@o ../src/shit.cpp @{
#include <Arduino.h>
@< libraries @>
@< configuration @>
@< functions @>

void setup() 
{
  // Open serial communications and wait for the port to open.
  Serial.begin(9600);
  while (!Serial) 
  {
    ; // Wait for serial port to connect (only needed for native USB ports).
  }
  @< setup @>
}

void loop() 
{
  @< loop @>
}
@}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Sensor}

Why Adafruit library?

Why DHT library?

Serial Peripheral Interface (SPI) is a synchronous serial data protocol
used by microcontrollers for communicating with peripheral devices quickly over short distances.

@d libraries @{
// Sensor libraries:
#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <SPI.h>
@}

Pin and DHT type
DHT11 cheaper and less precise probably would be just as good for our situation
DHT21 (AM2301)

Register the pin used see wiring.

@d configuration @{
// Sensor config
#define DHTPIN 2
#define DHTTYPE DHT22   // DHT 22  (AM2302)
DHT dht = DHT(DHTPIN, DHTTYPE); // Initialize DHT sensor for normal 16mhz Arduino:
// globals to store readings
float temperature = 0;
float humidity = 0;
@}

The sensor needs to begin, why?

@d setup @{
  Serial.println("Set up sensor");
  dht.begin();
@}

Set the values in the globals,
could have passed stuff around.

@d functions @{
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
@}

Not necessary in use but handy for development.

@d functions @{
void serialPrintReadings()
{
  Serial.print("Humidity: ");
  Serial.print(humidity);
  Serial.print(" % | ");
  Serial.print("Temperature: ");
  Serial.print(temperature);
  Serial.println(" C");
}
@}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Ethernet Client}

aWOT is in version 3

\verb|lasselukkari/aWOT@0.0.0-alpha+sha.bf07e6371c|


@d libraries @{
// Ethernet shield
#include <Ethernet.h>
#include <aWOT.h>
@}


@d configuration @{
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
@}

No need to over do the rate besides it takes abot about 250 milliseconds to poll the sensor.
Prometheus normally scrapes every minute.

@d loop @{
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
@}

Prometheus style metrics for scraping.

@d functions @{
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
@}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Upload}

Drivers on PC.

read back doesn't always work.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Testing}

\begin{verbatim}
  --- Quit: Ctrl+C | Menu: Ctrl+T | Help: Ctrl+T followed by Ctrl+H ---
  Webserver set up
  Sensor set up
  Humidity: 55.90 % | Temperature: 22.10 C
  Humidity: 56.30 % | Temperature: 22.20 C
\end{verbatim}


Rather than link up to a router

\begin{itemize}
  \item Assign a manual IP address to the laptop's ethernet connection say 10.0.21.1.
  \item Subnet mask 255.255.255.0.
  \item Assign a manual IP address to the Arduino's ethernet, say 10.0.21.211.
  \item Subnet mask 255.255.255.0.
  \item Leave the default Gateway empty.
  \item Use an ethernet patch cable to link the two (since 100BaseT onwards it doesn't have to be a special cross over cable).
  \item You should then be able to get your Arduino site up on \url{http://192.168.0.2} from the laptop.
\end{itemize}
  
This is the endpoint at \url{http://10.0.21.211/metrics}.
  
\begin{verbatim}
  > curl 10.0.21.211
  # HELP temperature is the last temperature reading in degrees celsius
  # TYPE temp gauge
  temperature 23.30
  # HELP humidity is the last relative humidity reading as a percentage
  # TYPE humidity gauge
  humidity 47.60
\end{verbatim}

\verb|docker-compose up|

\begin{figure}[H]
  \centering
  \includegraphics[width=0.8\textwidth]{graph.jpg}
  \caption{Temperature graph}
\end{figure}
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Packaging}

\begin{figure}[H]
  \centering
  \includegraphics[width=0.8\textwidth]{sensor-mount.jpg}
  \caption{Components for mounting the sensor}
\end{figure}

2.5 mm holes and 4 mm holes.

\begin{figure}[H]
  \centering
  \includegraphics[width=0.8\textwidth]{packaging.jpg}
  \caption{Mounted sensor and wiring}
\end{figure}

\end{document}