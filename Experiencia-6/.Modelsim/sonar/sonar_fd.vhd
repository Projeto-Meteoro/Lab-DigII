library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sonar_fd is 
    port( 
        clock:        in  std_logic; 
        reset:        in  std_logic; 
        conta:        in  std_logic; 
		  transmitir:   in  std_logic;
		  medir:			 in  std_logic;
        echo:         in  std_logic; 
        trigger:      out std_logic;  
        pwm:          out std_logic; 
		  pronto_sensor: out std_logic;
		  pronto_servo: out std_logic;
        saida_serial: out std_logic;
		  alerta_proximidade: out std_logic
    ); 
end entity;

architecture estrutural of sonar_fd is
	component tx_dados_sonar 
		port ( 
			clock:           in  std_logic; 
			reset:           in  std_logic; 
			transmitir:      in  std_logic; 
			angulo2:         in  std_logic_vector(7 downto 0); -- digitos ASCII 
			angulo1:         in  std_logic_vector(7 downto 0); -- de angulo 
			angulo0:         in  std_logic_vector(7 downto 0); 
			distancia2:      in  std_logic_vector(7 downto 0); -- e de distancia  
			distancia1:      in  std_logic_vector(7 downto 0); 
			distancia0:      in  std_logic_vector(7 downto 0); 
			saida_serial:    out std_logic; 
			pronto:          out std_logic;  
			db_transmitir:   out std_logic; 
			db_saida_serial: out std_logic; 
			db_estado:       out std_logic_vector(3 downto 0) 
		); 
	end component;
	
	component controla_servo_e_interface
		port ( 
			clock:      in  std_logic;  
			reset:      in  std_logic; 
			echo:       in  std_logic; 
			conta:   	in  std_logic; 
			medir:		in  std_logic;
			trigger:    out std_logic; 
			distancia0: out std_logic_vector(7 downto 0); -- digitos da medida 
			distancia1:       out std_logic_vector(7 downto 0);  
			distancia2:       out std_logic_vector(7 downto 0); 
			angulo0:       out std_logic_vector(7 downto 0); 
			angulo1:       out std_logic_vector(7 downto 0); 
			angulo2:      out std_logic_vector(7 downto 0); 
			pwm:           out std_logic; 
			pronto_sensor:     out std_logic; 
			pronto_servo:		 out std_logic;
			db_echo:    out std_logic; 
			db_estado:  out std_logic_vector(6 downto 0);  -- estado da UC? 
			db_pwm:        out std_logic;
			posicao:       out std_logic_vector (2 downto 0)
    ); 
	end component; 
  
  signal s_angulo2, s_angulo1, s_angulo0: std_logic_vector(7 downto 0);
  signal s_distancia1, s_distancia0, s_distancia2: std_logic_vector(7 downto 0);
begin

	U1_TX: tx_dados_sonar port map (clock, reset, transmitir, s_angulo2, s_angulo1, s_angulo0,
											  s_distancia2, s_distancia1, s_distancia0, saida_serial);
											  
	U2_SI: controla_servo_e_interface port map(clock, reset, echo, conta, medir, trigger,
															s_distancia0, s_distancia1, s_distancia2, s_angulo0,
															s_angulo1, s_angulo2, pwm, pronto_sensor, pronto_servo);
															
	alerta_proximidade <= '1' when (s_distancia1 = "00110001" or s_distancia1 = "00110000") and s_distancia2= "00110000" else '0';
end architecture;