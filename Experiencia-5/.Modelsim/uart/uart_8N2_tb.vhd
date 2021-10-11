library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_8N2_tb is
end entity;

architecture tb of uart_8N2_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component uart_8N2
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
	end component;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (ModelSim)
  signal clock_in: std_logic := '0';
  signal reset_in: std_logic := '0';
  signal transmite_dado_in: std_logic := '0';
  signal dados_ascii_8_in: std_logic_vector (7 downto 0) := "00000000";
  signal dado_serial_in: std_logic := '0';
  signal recebe_dado_in: std_logic := '0';
  signal saida_serial_out: std_logic := '1';
  signal pronto_tx_out: std_logic := '0';
  signal dado_recebido_out: std_logic_vector(7 downto 0);
  signal tem_dado_out: std_logic := '0';
  signal pronto_rx_out: std_logic := '0'; 
  signal db_transmite_dado_out: std_logic := '0';
  signal db_saida_serial_out: std_logic := '0';
  signal db_estado_tx_out: std_logic_vector(3 downto 0) := "0000";
  signal db_recebe_dado_out: std_logic := '0';
  signal db_dado_serial_out: std_logic := '0';
  signal db_estado_rx_out: std_logic_vector(3 downto 0) := "0000";
  -- Configurações do clock
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod : time := 20 ns;     -- clock de 50MHz
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;
  
  -- Conecta DUT (Device Under Test)
  dut: uart_8N2
       port map
       ( 
           clock=>          	   clock_in,
           reset=>          	   reset_in,
           transmite_dado=>        transmite_dado_in,
           dados_ascii=>    	   dados_ascii_8_in,
		   dado_serial => 		   dado_serial_in,
		   recebe_dado => 		   recebe_dado_in,
		   saida_serial => 	 	   saida_serial_out,
		   pronto_tx => 			   pronto_tx_out,
		   dado_recebido_rx => 	   dado_recebido_out,
		   tem_dado => 			   tem_dado_out,
		   pronto_rx=> 			   pronto_rx_out,
		   db_transmite_dado =>    db_transmite_dado_out,
		   db_saida_serial=> 	   db_dado_serial_out,
		   db_estado_tx=> 		   db_estado_tx_out,
		   db_recebe_dado=> 	   db_recebe_dado_out,
		   db_dado_serial=> 	   db_dado_serial_out,
		   db_estado_rx => 		   db_estado_rx_out
		   
      );

  -- Loopback
  dado_serial_in <= saida_serial_out;
  
  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin
  
    assert false report "Inicio da simulacao" severity note;
    keep_simulating <= '1';
    
    ---- inicio da simulacao: reset ----------------
    transmite_dado_in <= '0';
    reset_in <= '1'; 
    wait for 20*clockPeriod;  -- pulso com 20 periodos de clock
    reset_in <= '0';
    wait until falling_edge(clock_in);
    wait for 50*clockPeriod;

    ---- dado de entrada da simulacao (caso de teste #1)
    dados_ascii_8_in <= "00110101"; -- x35 = '5'	
    wait for 20*clockPeriod;

    ---- acionamento da partida (inicio da transmissao)
    transmite_dado_in <= '1';
    wait until rising_edge(clock_in);
    wait for 5*clockPeriod; -- pulso partida com 5 periodos de clock
    transmite_dado_in <= '0';

    ---- espera final da transmissao (pulso pronto em 1)
	wait until tem_dado_out='1';
	
	---- final do caso de teste 1
	recebe_dado_in <= '1';
    -- intervalo entre casos de teste
    wait for 500*clockPeriod;
	
    ---- inicio da simulacao: caso de teste 2 ----------------
    transmite_dado_in <= '0';
    reset_in <= '1'; 
	recebe_dado_in <= '0';
    wait for 20*clockPeriod;  
    reset_in <= '0';
    wait until falling_edge(clock_in);
    wait for 50*clockPeriod;

    ---- dado de entrada da simulacao (caso de teste #2)
    dados_ascii_8_in <= "01111010"; -- x7A = 'z'	
    wait for 20*clockPeriod;

    ---- acionamento da partida (inicio da transmissao)
    transmite_dado_in <= '1';
    wait until rising_edge(clock_in);
    wait for 5*clockPeriod; -- pulso partida com 5 periodos de clock
    transmite_dado_in <= '0';

    ---- espera final da transmissao (pulso pronto em 1)
	wait until tem_dado_out='1';
	recebe_dado_in <= '1';
	wait for  0.3 ms;
	---- final do caso de teste 2

    ---- final dos casos de teste da simulacao
    assert false report "Fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;


end architecture;