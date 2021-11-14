library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sonar_fd is 
    port( 
        clock:        			in  std_logic; 
        reset:        			in  std_logic; 
        conta:        			in  std_logic; 
		  transmitir:   			in  std_logic;
		  medir:			 			in  std_logic;
        echo:         			in  std_logic; 
		  dado_serial:				in  std_logic;
		  recebe_dado:				in  std_logic;
		  modo_manual:				in  std_logic;
        trigger:      			out std_logic;  
        pwm:          			out std_logic; 
		  pronto_sensor:			out std_logic;
		  pronto_servo: 			out std_logic;
        saida_serial: 			out std_logic;
		  alerta_proximidade: 	out std_logic;
		  recebe_m:					out std_logic;
		  tem_dado:					out std_logic;
		  -- Depuracao
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
			dado_serial:	  in  std_logic;
			recebe_dado:	  in  std_logic;
			saida_serial:    out std_logic; 
			tem_dado:		out std_logic;
			pronto:          out std_logic;  
			db_transmitir:   out std_logic; 
			db_saida_serial: out std_logic; 
			db_estado_sonar: out std_logic_vector(3 downto 0);
			db_estado_tx:	  out std_logic_vector(3 downto 0);
			db_estado_rx:    out std_logic_vector(3 downto 0);
			dado_recebido:		out std_logic_vector(7 downto 0)
			
		); 
	end component;
	
	component controla_servo_e_interface
		port ( 
			clock:      in  std_logic;  
			reset:      in  std_logic; 
			echo:       in  std_logic; 
			conta:   	in  std_logic; 
			medir:		in  std_logic;
			modo_manual:	  in  std_logic;
			posicao_manual: in std_logic_vector(2 downto 0);
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
			posicao:       out std_logic_vector (2 downto 0);
			db_estado:  out std_logic_vector(3 downto 0);
			db_echo:    out std_logic; 
			db_pwm:        out std_logic
    ); 
	end component; 
  
  signal s_angulo2, s_angulo1, s_angulo0: std_logic_vector(7 downto 0);
  signal s_distancia1, s_distancia0, s_distancia2: std_logic_vector(7 downto 0);
  signal s_posicao, posicao_manual: std_logic_vector(2 downto 0);
  signal s_dado_recebido: std_logic_vector(7 downto 0);
  signal s_tem_dado: std_logic;
  
begin

	U1_TX: tx_dados_sonar port map (clock, reset, transmitir, s_angulo2, s_angulo1, s_angulo0,
											  s_distancia2, s_distancia1, s_distancia0, dado_serial, recebe_dado, saida_serial,
											  s_tem_dado, open, open, open,
											  estado_tx_sonar, estado_tx, estado_rx,s_dado_recebido);
											  
	U2_SI: controla_servo_e_interface port map(clock, reset, echo, conta, medir, modo_manual, posicao_manual,trigger,
															s_distancia0, s_distancia1, s_distancia2, s_angulo0,
															s_angulo1, s_angulo2, pwm, pronto_sensor, pronto_servo,
															s_posicao, estado_hcsr04);
															
	alerta_proximidade <= '1' when (s_distancia1 = "00110001" or s_distancia1 = "00110000") and s_distancia2 = "00110000" else '0';
	
	-- Depuracao
	distancia2 <= s_distancia2(3 downto 0); 
	distancia1 <= s_distancia1(3 downto 0);
	distancia0 <= s_distancia0(3 downto 0);
	angulo2 <= s_angulo2(3 downto 0);
	angulo1 <= s_angulo1(3 downto 0);
	angulo0 <= s_angulo0(3 downto 0);
	posicao <= '0' & s_posicao;
	-- recepcao
	recebe_m <= '1' when s_dado_recebido = "01001101" and s_tem_dado = '1' else  '0';
	posicao_manual <= s_dado_recebido(2 downto 0);
	tem_dado <= s_tem_dado;
end architecture;