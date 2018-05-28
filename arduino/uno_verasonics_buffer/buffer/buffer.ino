#define gpioVERIN 2
#define gpioBTNIN 4
#define gpioRPSTARTOUT 13
#define gpioRPSTOPOUT 12

static bool interrupted;
static bool acquire;


void setup()
{

  pinMode(gpioVERIN, INPUT_PULLUP);
  pinMode(gpioBTNIN, INPUT);
  pinMode(gpioRPSTARTOUT, OUTPUT);
  pinMode(gpioRPSTOPOUT, OUTPUT);

  acquire = false;
  interrupted = false;

  attachInterrupt(digitalPinToInterrupt(gpioVERIN), procInterrupt, FALLING);
}

void loop()
{
  if (interrupted || digitalRead(gpioBTNIN)){
    if (acquire){
      digitalWrite(gpioRPSTARTOUT,HIGH);
      delay(1000);
      digitalWrite(gpioRPSTARTOUT,LOW);
    }else{
      digitalWrite(gpioRPSTOPOUT,HIGH);
      delay(1000);
      digitalWrite(gpioRPSTOPOUT,LOW);
    }
    acquire = !acquire;
    interrupted = false;
  }
}

void procInterrupt()
{
  interrupted = true;
}

