library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sonar is 
    port( 
        clock:        in  std_logic; 
        reset:        in  std_logic; 
        ligar:        in  std_logic; 
        echo:         in  std_logic; 
		  sel_mux:		 in  std_logic_vector(1 downto 0);
		  dado_serial:  in  std_logic;
        trigger:      out std_logic;  
        pwm:          out std_logic; 
		  recebe_serial: out std_logic;
        saida_serial: out std_logic;
		  alerta_proximidade: out std_logic;
		  tick:			 out std_logic;
		  hex0:			 out std_logic_vector(6 downto 0);
		  hex1:			 out std_logic_vector(6 downto 0);
		  hex2:			 out std_logic_vector(6 downto 0);
		  hex3:			 out std_logic_vector(6 downto 0);
		  hex4:			 out std_logic_vector(6 downto 0);
		  hex5:			 out std_logic_vector(6 downto 0)
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
		  dado_serial:				in  std_logic;
		  recebe_dado:				in  std_logic;
		  modo_manual:				in  std_logic;
        trigger:      out std_logic;  
        pwm:          out std_logic; 
		  pronto_sensor: out std_logic;
		  pronto_servo: out std_logic;
        saida_serial: out std_logic;
		  alerta_proximidade: out std_logic;
		  recebe_m:					out std_logic;
		  tem_dado:					out std_logic;
		  distancia2:				out std_logic_vector(3 downto 0);	
		  distancia1:				out std_logic_vector(3 downto 0);
		  distancia0:				out std_logic_vector(3 downto 0);
		  angulo2:					out std_logic_vector(3 downto 0);
		  angulo1:					out std_logic_vector(3 downto 0);
		  angulo0:					out std_logic_vector(3 downto 0);
		  posicao:					out std_logic_vector(3 downto 0);
		  estado_hcsr04:			out std_logic_vector(3 downto 0);
		  estado_tx:				out std_logic_vector(3 downto 0);
		  estado_rx:				out std_logic_vector(3 downto 0);
		  estado_tx_sonar:		out std_logic_vector(3 downto 0)
		 ); 
	end component;
	
	component sonar_uc
	 port ( 
		clock, reset, ligar, pronto_sensor, pronto_servo, recebe_m, tem_dado: 		 in  std_logic;
	   medir, conta, zera, transmitir, recebe_dado: out std_logic;
		ps_manual: out std_logic;
		db_estado:  out std_logic_vector(3 downto 0)
    );
	end component;
	
	component hex7seg 
		 port (
			  hexa : in  std_logic_vector(3 downto 0);
			  sseg : out std_logic_vector(6 downto 0)
		 );
	end component;
	
	component mux_4x1_n
		 generic (
			  constant BITS: integer := 4
		 );
		 port ( 
			  D0 :     in  std_logic_vector (BITS-1 downto 0);
			  D1 :     in  std_logic_vector (BITS-1 downto 0);
			  D2 :     in  std_logic_vector (BITS-1 downto 0);
			  D3 :     in  std_logic_vector (BITS-1 downto 0);
			  SEL:     in  std_logic_vector (1 downto 0);
			  MUX_OUT: out std_logic_vector (BITS-1 downto 0)
		 );
	end component;
	
	signal s_zera, s_conta, s_transmitir, s_medir, s_pronto_sensor, s_pronto_servo: std_logic;
	signal s_d0, s_d1, s_d2, s_d3 : std_logic_vector(3 downto 0);
	signal distancia2, distancia1, distancia0: std_logic_vector(3 downto 0);
	signal angulo2, angulo1, angulo0: std_logic_vector(3 downto 0);
	signal posicao, estado_hcsr04, estado_tx_sonar, estado_tx, estado_rx: std_logic_vector(3 downto 0);
	signal estado_sonar: std_logic_vector(3 downto 0);
	signal mux0, mux1, mux2, mux3, mux4, mux5 : std_logic_vector(3 downto 0);
	signal s_recebe_m, s_ps_manual, s_recebe_dado, s_tem_dado: std_logic;
begin

	U1_FD: sonar_fd port map (clock, s_zera, s_conta, s_transmitir, s_medir, 
									 echo, dado_serial, s_recebe_dado, s_ps_manual, trigger, pwm,
									 s_pronto_sensor, s_pronto_servo, saida_serial, alerta_proximidade, s_recebe_m,
									 s_tem_dado, distancia2, distancia1, distancia0, angulo2, angulo1, angulo0,
									 posicao, estado_hcsr04, estado_tx, estado_rx, estado_tx_sonar);
															
						
	U2_uc: sonar_uc port map (clock, reset, ligar, s_pronto_sensor,s_pronto_servo, s_recebe_m,s_tem_dado, s_medir,
									 s_conta, s_zera, s_transmitir,s_recebe_dado,s_ps_manual, estado_sonar);
	-- MUX
	U3_MUX0: mux_4x1_n port map(distancia0, "0000", "0000", angulo0, sel_mux, mux0);
	
	U4_MUX1: mux_4x1_n port map(distancia1, "0000", "0000", angulo1, sel_mux, mux1);
	
	U5_MUX2: mux_4x1_n port map(distancia2, estado_rx, "0000", angulo2, sel_mux, mux2);
	
	U6_MUX3: mux_4x1_n port map("0000", "0000", "0000", "0000", sel_mux, mux3);
	
	U7_MUX4: mux_4x1_n port map(estado_hcsr04, "0000", "0000", "00" & sel_mux, sel_mux, mux4);
	
	U8_MUX5: mux_4x1_n port map(posicao, estado_tx, estado_tx_sonar, estado_sonar, sel_mux, mux5);
	
	-- HEX
	U9_HEX0: hex7seg port map(mux0, hex0);
	
	U10_HEX1: hex7seg port map(mux1, hex1);
	
	U11_HEX2: hex7seg port map(mux2, hex2);
	
	U12_HEX3: hex7seg port map(mux3, hex3);
	
	U13_HEX4: hex7seg port map(mux4, hex4);
	
	U14_HEX5: hex7seg port map(mux5, hex5);
	
	tick <= s_pronto_servo;
end architecture;