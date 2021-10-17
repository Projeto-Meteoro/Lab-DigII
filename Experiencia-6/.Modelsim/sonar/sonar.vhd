library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sonar is 
    port( 
        clock:        in  std_logic; 
        reset:        in  std_logic; 
        ligar:        in  std_logic; 
        echo:         in std_logic; 
        trigger:      out std_logic;  
        pwm:          out std_logic; 
        saida_serial: out std_logic;
		  alerta_proximidade: out std_logic
    ); 
end entity;

architecture estrutural of sonar is

	component sonar_fd
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
	end component;
	
	component sonar_uc
	 port ( 
		clock, reset, ligar, pronto_sensor, pronto_servo: 		 in  std_logic;
		medir, conta, zera, transmitir: out std_logic;
		db_estado:  out std_logic_vector(3 downto 0)
    );
	end component;
	
	signal s_zera, s_conta, s_transmitir, s_medir, s_pronto_sensor, s_pronto_servo: std_logic;
begin

	U1_FD: sonar_fd port map (clock, s_zera, s_conta, s_transmitir, s_medir, echo, trigger, pwm,
									 s_pronto_sensor, s_pronto_servo, saida_serial, alerta_proximidade);
															
						
	U2_uc: sonar_uc port map (clock, reset, ligar, s_pronto_sensor,
										s_pronto_servo, s_medir, s_conta, s_zera, s_transmitir, open);
end architecture;