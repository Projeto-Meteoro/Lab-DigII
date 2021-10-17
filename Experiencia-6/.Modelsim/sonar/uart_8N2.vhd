library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity uart_8N2 is 
	port ( 
		clock             : in  std_logic; 
		reset             : in  std_logic; 
		transmite_dado    : in  std_logic; 
		dados_ascii       : in  std_logic_vector(7 downto 0); 
		dado_serial       : in  std_logic; 
		recebe_dado       : in  std_logic; 
		saida_serial      : out std_logic; 
		pronto_tx         : out std_logic; 
		dado_recebido_rx  : out std_logic_vector(7 downto 0); 
		tem_dado          : out std_logic; 
		pronto_rx         : out std_logic;  
		db_transmite_dado : out std_logic;  
		db_saida_serial   : out std_logic; 
		db_estado_tx      : out std_logic_vector(3 downto 0); 
		db_recebe_dado    : out std_logic; 
		db_dado_serial    : out std_logic; 
		db_estado_rx      : out std_logic_vector(3 downto 0) 
    ); 
end entity;

architecture uart8n2_arch of uart_8N2 is
	component rx_serial_8N2
		 port  
		 ( 
			  clock:           in  std_logic;  
			  reset:           in  std_logic; 
			  dado_serial:     in  std_logic; 
			  recebe_dado:     in  std_logic;
			  dado_recebido:   out std_logic_vector (7 downto 0);  
			  tem_dado:        out std_logic; 
			  pronto_rx:       out std_logic; 
			  db_recebe_dado:  out std_logic; 
			  db_dado_serial:  out std_logic;
			  db_estado:       out std_logic_vector (3 downto 0)  -- estado da UC 
		 ); 
	end component; 
	
	component tx_serial_8N2
		 port (
			  clock, reset, partida: 	 in  std_logic;
			  dados_ascii:           	 in  std_logic_vector (7 downto 0);
			  saida_serial, pronto_tx : out std_logic;
		     db_partida:      			 out std_logic;  
           db_saida_serial: 			 out std_logic; 
           db_estado:       			 out std_logic_vector(3 downto 0)
		 );
	end component;
    
    component edge_detector_up is port ( 
             clk         : in   std_logic;
             signal_in   : in   std_logic;
             output      : out  std_logic
    );
    end component;
	 
    signal s_zera, s_conta, s_carrega, s_desloca, s_tick, s_fim: std_logic;
	 signal s_transmite_dado: std_logic;

begin

    -- recepcao
	 U2_RX: rx_serial_8N2 port map (clock, reset, dado_serial, recebe_dado, dado_recebido_rx, tem_dado, pronto_rx,
											  db_recebe_dado, db_dado_serial, db_estado_rx);
    -- transmissao
    U1_TX: tx_serial_8N2 port map (clock, reset, s_transmite_dado, dados_ascii, saida_serial, pronto_tx,
											  db_transmite_dado, db_saida_serial, db_estado_tx);
	 
	 -- Edge detector 
	 U2_ED: edge_detector_up port map (clock, transmite_dado, s_transmite_dado);
     
end architecture;