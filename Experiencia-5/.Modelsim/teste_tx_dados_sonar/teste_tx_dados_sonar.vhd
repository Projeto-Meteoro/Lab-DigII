-------------------------------------------------------------------
-- Arquivo   : teste_tx_dados_sonar.vhd
-- Projeto   : Experiencia 5 - Sonar 1 - Atividade 2
-------------------------------------------------------------------
-- Descricao : circuito da experiencia 5 - atividade 2
-------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity teste_tx_dados_sonar is 
	port ( 
		clock:           in  std_logic; 
		reset:           in  std_logic; 
		transmitir:      in  std_logic; 
		saida_serial:    out std_logic; 
		pronto:          out std_logic;  
		db_transmitir:   out std_logic; 
		db_estado:       out std_logic_vector(6 downto 0) 
	); 
end entity;

architecture estrutural of teste_tx_dados_sonar is

	component tx_dados_sonar
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
	end component;
	
	component hex7seg
		port ( 
        hexa : in  std_logic_vector(3 downto 0);
        sseg : out std_logic_vector(6 downto 0)
		); 
	end component;
		
	signal s_estado: std_logic_vector(3 downto 0);
	
begin
	
	U1_DS: tx_dados_sonar port map(clock, reset, transmitir, "0001", "0101", "0011", "0000", "0001","0111", 
											 saida_serial, pronto, db_transmitir, open, s_estado);
     
	U2_HS: hex7Seg port map(s_estado, db_estado);
end architecture;