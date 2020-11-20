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

\title{Promethean Temperature Sensor}
\author{Joe J Collins}

\begin{document}
\maketitle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\tableofcontents


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{The Problem}

Monitoring with Prometheus
no off the shelf monitoring.
Temperature is important.

No hassle with Wifi.

\begin{description}
  \item[Start up time]
  \item[Maintenance]
  \item[Cost]
  \item[Availability]
  \item[Support information] 
\end{description}

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

@d configuration @{
  #define DHTPIN 2
  // Set DHT type, uncomment whatever type you're using!
  //#define DHTTYPE DHT11   // DHT 11 
  #define DHTTYPE DHT22   // DHT 22  (AM2302)
  //#define DHTTYPE DHT21   // DHT 21 (AM2301)
  // Initialize DHT sensor for normal 16mhz Arduino:
  DHT dht = DHT(DHTPIN, DHTTYPE);
@}


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
  \item VSCode
  \item Platformio \url{https://marketplace.visualstudio.com/items?itemName=platformio.platformio-ide}
\end{itemize}

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


Platform io

@o ../src/shit.cpp @{
#include <Arduino.h>
@< libraries @>
@< configuration @>
void setup() 
{
  @< setup @>
}
void loop() 
{
  @< loop @>
}
@}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Libraries}

Notes

@d libraries @{
// Include the libraries:
#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <SPI.h>
#include <Ethernet.h>
@}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Upload}

Drivers on PC.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Testing}

\begin{verbatim}
  --- Quit: Ctrl+C | Menu: Ctrl+T | Help: Ctrl+T followed by Ctrl+H ---
  Webserver set up
  Sensor set up
  Humidity: 55.90 % | Temperature: 22.10 C
  Humidity: 56.30 % | Temperature: 22.20 C
  \end{verbatim}
  
  This is the endpoint at \url{http://10.0.21.211/}.
  
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