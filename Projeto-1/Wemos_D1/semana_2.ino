#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <Servo.h>
#include <Ultrasonic.h>

String user = "grupo2-bancadaB1";
String passwd = "L@Bdygy2B1";

const char* ssid = "*";
const char* password = "*";
const char* mqtt_server = "3.141.193.238";

WiFiClient espClient;
PubSubClient client(espClient);
unsigned long lastMsg = 0;
#define MSG_BUFFER_SIZE  (50)
char msg[MSG_BUFFER_SIZE];

int value = 0; //sinal de heartbeat

uint32_t prev_millis;
uint32_t ms_cnt = 0;

const char* zero_cstr = "0";
const char* one_cstr = "1";

Servo myservo;  // create servo object to control a servo

int valor;

int microseconds = 0; 


#define trigPin 12
#define echoPin 13


Ultrasonic ultrasonic(trigPin, echoPin);

void setup_wifi() {

  delay(10);

  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  randomSeed(micros());

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println();

  // Led buit-in mapeado no topico "user/ledhome"
  if (strcmp(topic,(user+"/ledhome").c_str())==0) {
    if ((char)payload[0] == '1') {
      digitalWrite(BUILTIN_LED, HIGH); 
    } else {
      digitalWrite(BUILTIN_LED, LOW); 
    }
  }

  // Servo motor 
  if (strcmp(topic,(user+"/S0").c_str())==0) {
    if ((char)payload[0] == '1') {
      while((char)payload[0] == '1'){
        microseconds++;
        delay(1);
      }
      myservo.writeMicroseconds(microseconds);
      microseconds = 0;
    } 
  }

  // Sensor de distância
  if (strcmp(topic,(user+"/S1").c_str())==0) {
    if ((char)payload[0] == '1') {
      digitalWrite(trigPin, HIGH); 
    } else {
      digitalWrite(trigPin, LOW); 
    }
  }
}

void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    
    Serial.print("Attempting MQTT connection...");
    
    // Create a random client ID
    String clientId = user;
    clientId += String(random(0xffff), HEX);
    
    // Attempt to connect
    if (client.connect(clientId.c_str(), user.c_str(), passwd.c_str())) {
      
      Serial.println("connected");
      // Once connected, publish an announcement...
      client.publish((user+"/homehello").c_str(), "hello world #%ld", value);
      client.subscribe((user+"/ledhome").c_str());
      client.subscribe((user+"/S0").c_str()); // topic for pwm
       
      // publish echo value
      if (digitalRead(echoPin) == HIGH){
        client.publish((user+"/E5").c_str(), "1");
      }
      else{
        client.publish((user+"/E5").c_str(),"0");
      }
      
      client.subscribe((user+"/S1").c_str()); // topic for trigger 
    } else {
      
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      
      // Wait 5 seconds before retrying
      delay(5000);
      
    }
  }
}

void setup() {
  pinMode(BUILTIN_LED, OUTPUT);

   myservo.attach(D3);  // attaches the servo on pin D1 to the servo object
  
  Serial.begin(115200);
  
  setup_wifi();
  
  client.setServer(mqtt_server, 80);
  client.setCallback(callback);
}

void loop() {

  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  if(prev_millis!=millis()){
    prev_millis=millis();
    if(ms_cnt%100==0){
      client.subscribe((user+"/ledhome").c_str());
    }
    ms_cnt++;
  }

  unsigned long now = millis();
  if (now - lastMsg > 2000) {
    lastMsg = now;
    ++value;
    snprintf (msg, MSG_BUFFER_SIZE, "hello world #%ld", value);
    client.publish((user+"/homehello").c_str(), "hello world #%ld", value);
  }

  // publish echo value
  if (digitalRead(echoPin) == HIGH){
    client.publish((user+"/E5").c_str(), "1");
  }
  else{
    client.publish((user+"/E5").c_str(),"0");
  }
}
