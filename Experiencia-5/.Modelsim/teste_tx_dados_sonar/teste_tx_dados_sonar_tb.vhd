library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity teste_tx_dados_sonar_tb is
end entity;

architecture tb of teste_tx_dados_sonar_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component teste_tx_dados_sonar
	port ( 
		clock:           in  std_logic; 
		reset:           in  std_logic; 
		transmitir:      in  std_logic; 
		saida_serial:    out std_logic; 
		pronto:          out std_logic;  
		db_transmitir:   out std_logic; 
		db_estado:       out std_logic_vector(6 downto 0) 
	); 
  end component;
  
  -- componente auxiliar
  
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
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (ModelSim)
  signal clock_in: std_logic := '0';
  signal reset_in: std_logic := '0';
  signal transmitir_in: std_logic := '0';
  signal saida_serial_out: std_logic := '1';
  signal pronto_out: std_logic := '0';
  signal db_transmitir_out: std_logic := '0'; 
  signal db_estado_out: std_logic_vector(6 downto 0) := "0000000"; 
  
  -- auxiliar
  signal dado_ascii_out : std_logic_vector(7 downto 0) := "00000000";

  -- Configurações do clock
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod : time := 20 ns;     -- clock de 50MHz
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;
  
  -- Conecta DUT (Device Under Test)
  dut: teste_tx_dados_sonar
       port map
       ( 
           clock=>           clock_in,
           reset=>           reset_in,
           transmitir=>      transmitir_in,
           saida_serial=>    saida_serial_out,
           pronto=>          pronto_out,
		   db_transmitir=>   db_transmitir_out,
		   db_estado=>       db_estado_out
      );
	  
  -- Conecta component auxiliar
  aux: rx_serial_8N2
       port map
       ( 
		   clock=>           clock_in,
           reset=>           reset_in,
		   dado_serial=> saida_serial_out,
		   recebe_dado=> '1',
		   pronto_rx=> open,
		   tem_dado=> open,
		   dado_recebido=> dado_ascii_out,
	       db_estado=> open
      );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin
  
    assert false report "Inicio da simulacao" severity note;
    keep_simulating <= '1';
    
    ---- inicio da simulacao: reset ----------------
    transmitir_in <= '0';
    reset_in <= '1'; 
    wait for 20*clockPeriod;  -- pulso com 20 periodos de clock
    reset_in <= '0';
    wait until falling_edge(clock_in);
    wait for 50*clockPeriod;


    ---- acionamento da partida (inicio da transmissao)
    transmitir_in <= '1';
    wait until rising_edge(clock_in);
    wait for 5*clockPeriod; -- pulso partida com 5 periodos de clock
    transmitir_in <= '0';

    ---- espera final da transmissao (pulso pronto em 1)
	wait until pronto_out='1';
	
	---- final do caso de teste 


    ---- final dos casos de teste da simulacao
    assert false report "Fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;


end architecture;