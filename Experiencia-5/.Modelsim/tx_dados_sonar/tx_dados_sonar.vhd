-------------------------------------------------------------------
-- Arquivo   : tx_dados_sonar.vhd
-- Projeto   : Experiencia 5 - Sonar 1 - Atividade 1
-------------------------------------------------------------------
-- Descricao : circuito da experiencia 5 - atividade 1
--             > Transmissão de dados seriais do sonar 
--             > Transmite ângulo e de distância
--             > Formato : a2a1a0,d2d1d0 
--             > Usa codificação ASCII
-------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_dados_sonar is 
	port ( 
		clock:           in  std_logic; 
		reset:           in  std_logic; 
		transmitir:      in  std_logic; 
		angulo2:         in  std_logic_vector(3 downto 0); -- digitos BCD 
		angulo1:         in  std_logic_vector(3 downto 0); -- de angulo 
		angulo0:         in  std_logic_vector(3 downto 0); 
		distancia2:      in  std_logic_vector(3 downto 0); -- e de distancia  
		distancia1:      in  std_logic_vector(3 downto 0); 
		distancia0:      in  std_logic_vector(3 downto 0); 
		saida_serial:    out std_logic; 
		pronto:          out std_logic;  
		db_transmitir:   out std_logic; 
		db_saida_serial: out std_logic; 
		db_estado:       out std_logic_vector(3 downto 0) 
	); 
end entity;

architecture dados_sonar_arch of tx_dados_sonar is

	component tx_dados_sonar_uc
		port ( 
			clock:           in  std_logic; 
			reset:           in  std_logic; 
			transmitir:      in  std_logic; 
			fim:				  in  std_logic;
			pronto_tx:		  in  std_logic;
			conta:			  out std_logic;
			partida:			  out std_logic;
			pronto:          out std_logic;  
			zera:				  out std_logic;
			db_estado:       out std_logic_vector(3 downto 0)
		); 
	end component;
	
	component tx_dados_sonar_fd
		port ( 
			clock:            in  std_logic; 
			reset:            in  std_logic; 
			conta:      	   in  std_logic; 
			partida:			   in  std_logic;
			zera:				   in  std_logic;
			angulo2:          in  std_logic_vector(3 downto 0); -- digitos BCD 
			angulo1:          in  std_logic_vector(3 downto 0); -- de angulo 
			angulo0:          in  std_logic_vector(3 downto 0); 
			distancia2:       in  std_logic_vector(3 downto 0); -- e de distancia  
			distancia1:       in  std_logic_vector(3 downto 0); 
			distancia0:       in  std_logic_vector(3 downto 0); 
			fim:					out std_logic;
			pronto_tx:			out std_logic;
			saida_serial:     out std_logic; 
			db_saida_serial: out std_logic
		); 
	end component;
		
	component edge_detector_up
		 port ( clk         : in   std_logic;
				  signal_in   : in   std_logic;
				  output      : out  std_logic
		 );
	end component;
	
	signal s_conta, s_zera, s_fim, s_pronto_tx, s_partida, s_transmitir: std_logic; 
	
begin
	U1_UC: tx_dados_sonar_uc port map(clock, reset, s_transmitir, s_fim, s_pronto_tx,
												 s_conta, s_partida, pronto, s_zera, db_estado);
	
	
	U2_FD: tx_dados_sonar_fd port map(clock, reset, s_conta, s_partida, s_zera, angulo2, angulo1, angulo0,
												 distancia2, distancia1, distancia0, s_fim, s_pronto_tx, saida_serial, db_saida_serial);
	
	-- Edge detector 
	U3_ED: edge_detector_up port map (clock, transmitir, s_transmitir);
	
	-- depuracao
	db_transmitir <= transmitir;
     
end architecture;