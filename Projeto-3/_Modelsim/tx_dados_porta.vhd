-------------------------------------------------------------------
-- Arquivo   : tx_dados_porta.vhd
-- Projeto   : Semana 3 - Porta Inteligente
-------------------------------------------------------------------
-- Descricao : circuito da Semana 3 - Projeto
--             > Transmissão de dados seriais da porta 
--             > Transmite se saiu ou entrou
--             > Formato : " SAIU " ou "ENTROU" 
--             > Usa codificação ASCII
-------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_dados_porta is 
	port ( 
		clock:           in  std_logic; 
		reset:           in  std_logic; 
		transmitir:      in  std_logic; 
		caractere5:      in  std_logic_vector(7 downto 0); -- digitos ASCII 
		caractere4:      in  std_logic_vector(7 downto 0);
		caractere3:      in  std_logic_vector(7 downto 0);
		caractere2:      in  std_logic_vector(7 downto 0);
		caractere1:      in  std_logic_vector(7 downto 0);
		caractere0:      in  std_logic_vector(7 downto 0);  
		recebe_dado:	  in  std_logic; 
		dado_serial:	  in	std_logic;
		saida_serial:    out std_logic; 
		pronto:          out std_logic;
		tem_dado:		  out std_logic;
		dado_recebido:	  out std_logic_vector(7 downto 0);
		db_transmitir:   out std_logic; 
		db_saida_serial: out std_logic; 
		db_estado:       out std_logic_vector(3 downto 0) 
	); 
end entity;

architecture dados_porta_arch of tx_dados_porta is

	component tx_dados_porta_uc
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
	
	component tx_dados_porta_fd
		port ( 
			clock:            in  std_logic; 
			reset:            in  std_logic; 
			conta:      	   in  std_logic; 
			partida:			   in  std_logic;
			zera:				   in  std_logic;
			caractere5:       in  std_logic_vector(7 downto 0); -- digitos ASCII 
			caractere4:       in  std_logic_vector(7 downto 0);
			caractere3:       in  std_logic_vector(7 downto 0);
			caractere2:       in  std_logic_vector(7 downto 0);
			caractere1:       in  std_logic_vector(7 downto 0);
			caractere0:       in  std_logic_vector(7 downto 0);
			recebe_dado:	  	in  std_logic; 
			dado_serial:		in	 std_logic;
			fim:				 	out std_logic;
			pronto_tx:			out std_logic;
			saida_serial:     out std_logic; 
			tem_dado:		   out std_logic;
			dado_recebido:	   out std_logic_vector(7 downto 0);
			db_saida_serial:  out std_logic
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
	U1_UC: tx_dados_porta_uc port map(clock, reset, s_transmitir, s_fim, s_pronto_tx,
												 s_conta, s_partida, pronto, s_zera, db_estado);
	
	
	U2_FD: tx_dados_porta_fd port map(clock, reset, s_conta, s_partida, s_zera, caractere5, caractere4, caractere3,
												 caractere2, caractere1, caractere0, recebe_dado, dado_serial, s_fim,
												 s_pronto_tx, saida_serial, tem_dado, dado_recebido, db_saida_serial);
	
	-- Edge detector 
	U3_ED: edge_detector_up port map (clock, transmitir, s_transmitir);
	
	-- depuracao
	db_transmitir <= transmitir;
     
end architecture;