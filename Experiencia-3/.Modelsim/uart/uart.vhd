library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity uart is
    port (
        clock, reset, partida: in  std_logic;
        dados_ascii:           in  std_logic_vector (7 downto 0);
		  recebe_dado:   in  std_logic; 
		  tem_dado:      out std_logic; 
		  dado_recebido: out std_logic_vector (7 downto 0); 
		  db_estado:     out std_logic_vector (6 downto 0) 
    );
end entity;

architecture uart_arch of uart is
	component rx_serial_8N2
		 port  
		 ( 
			  clock:         in  std_logic;  
			  reset:         in  std_logic; 
			  dado_serial:   in  std_logic; 
			  recebe_dado:   in  std_logic; 
			  pronto_rx:     out std_logic; 
			  tem_dado:      out std_logic; 
			  dado_recebido: out std_logic_vector (7 downto 0); 
			  db_estado:     out std_logic_vector (6 downto 0)  -- estado da UC 
		 ); 
	end component; 
	
	component tx_serial_8N2
		 port (
			  clock, reset, partida: in  std_logic;
			  dados_ascii:           in  std_logic_vector (7 downto 0);
			  saida_serial, pronto : out std_logic
		 );
	end component;
    
    signal s_reset, s_partida, s_partida_ed: std_logic;
    signal s_zera, s_conta, s_carrega, s_desloca, s_tick, s_fim: std_logic;
	 signal s_serial: std_logic;

begin

    -- sinais reset e partida mapeados na GPIO (ativos em alto)
    s_reset   <= reset;
    s_partida <= partida;

    -- transmissao
    U1_TX: tx_serial_8N2 port map (clock, reset, partida, dados_ascii, s_serial, open);

    -- recepcao
	 U2_RX: rx_serial_8N2 port map (clock, reset, s_serial, recebe_dado, open, tem_dado,
											  dado_recebido, db_estado);
     
end architecture;