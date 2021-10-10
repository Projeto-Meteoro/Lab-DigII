------------------------------------------------------------------
-- Arquivo   : tx_dados_sonar_fd.vhd
-- Projeto   : Experiencia 5 - Sonar 1 - Atividade 1
------------------------------------------------------------------
-- Descricao : fluxo de dados do circuito da experiencia 5 
--             > implementa saida ASCII 
------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_dados_sonar_fd is 
	port ( 
		clock:            in  std_logic; 
		reset:            in  std_logic; 
		conta:      	   in  std_logic; 
		partida:			   in  std_logic;
		zera:				   in  std_logic;
		angulo2:          in  std_logic_vector(3 downto 0);
		angulo1:          in  std_logic_vector(3 downto 0);
		angulo0:          in  std_logic_vector(3 downto 0); 
		distancia2:       in  std_logic_vector(3 downto 0); 
		distancia1:       in  std_logic_vector(3 downto 0); 
		distancia0:       in  std_logic_vector(3 downto 0); 
		fim:					out std_logic;
		pronto_tx:			out std_logic;
		saida_serial:     out std_logic; 
		db_saida_serial:  out std_logic
	); 
end entity;

architecture dados_sonar_fd_arch of tx_dados_sonar_fd is

	component mux_8x1_n
		generic (
			constant BITS: integer := 4
		);
		port ( 
			D0 :     in  std_logic_vector (BITS-1 downto 0);
			D1 :     in  std_logic_vector (BITS-1 downto 0);
			D2 :     in  std_logic_vector (BITS-1 downto 0);
			D3 :     in  std_logic_vector (BITS-1 downto 0);
			D4 :     in  std_logic_vector (BITS-1 downto 0);
			D5 :     in  std_logic_vector (BITS-1 downto 0);
			D6 :     in  std_logic_vector (BITS-1 downto 0);
			D7 :     in  std_logic_vector (BITS-1 downto 0);
			SEL:     in  std_logic_vector (2 downto 0);
			MUX_OUT: out std_logic_vector (BITS-1 downto 0)
		 );
	end component;
	

	component contador_m
		generic (
			constant M: integer; 
			constant N: integer 
		);
		port (
			clock, zera, conta: in std_logic;
			Q: out std_logic_vector (N-1 downto 0);
			fim: out std_logic
		);
	end component;
	 
	 
	component tx_serial_8N2
		port (
			clock, reset, partida:   in  std_logic;
			dados_ascii:             in  std_logic_vector (7 downto 0);
			saida_serial, pronto_tx: out std_logic;
			db_partida:      out std_logic;  
			db_saida_serial: out std_logic; 
			db_estado:       out std_logic_vector(3 downto 0)
		);
	end component;
    
	signal angulo0_ascii, angulo1_ascii, angulo2_ascii: std_logic_vector(7 downto 0);
	signal distancia0_ascii, distancia1_ascii, distancia2_ascii: std_logic_vector(7 downto 0);
	signal s_mux: std_logic_vector(7 downto 0);
	signal virgula : std_logic_vector(7 downto 0) := "00101100";
	signal ponto 	: std_logic_vector(7 downto 0) := "00101110";
	signal s_contador : std_logic_vector(2 downto 0);
	signal pronto  : std_logic;
	signal s_pronto_tx : std_logic;
begin
	-- Angulos em Ascii
	angulo0_ascii <= "0011" & angulo0;
	angulo1_ascii <= "0011" & angulo1;
	angulo2_ascii <= "0011" & angulo2;
	
	-- Distancias em ascii
	distancia0_ascii <= "0011" & distancia0;
	distancia1_ascii <= "0011" & distancia1;
	distancia2_ascii <= "0011" & distancia2;
	
	-- Componentes
	U1: mux_8x1_n generic map (BITS => 8) port map(angulo2_ascii, angulo1_ascii, angulo0_ascii, virgula,
																  distancia2_ascii, distancia1_ascii, distancia0_ascii, ponto,
																  s_contador, s_mux);
																  
	U2: contador_m generic map(M => 8, N => 3) port map(clock, zera, conta, s_contador, pronto);
	
	U3: tx_serial_8N2 port map (clock, reset, partida, s_mux, saida_serial, s_pronto_tx, db_saida_serial, open);
	
	pronto_tx <= s_pronto_tx;
	fim <= pronto and s_pronto_tx;
end architecture;