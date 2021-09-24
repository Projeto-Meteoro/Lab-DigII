library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tb is
end entity;

architecture tb of uart_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component uart
     port (
        clock, reset, partida: in  std_logic;
        dados_ascii:           in  std_logic_vector (7 downto 0);
		  recebe_dado:   in  std_logic; 
		  tem_dado:      out std_logic; 
		  dado_recebido: out std_logic_vector (7 downto 0); 
		  db_estado:     out std_logic_vector (6 downto 0) 
    );
	end component;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (ModelSim)
  signal clock_in: std_logic := '0';
  signal reset_in: std_logic := '0';
  signal partida_in: std_logic := '0';
  signal dados_ascii_8_in: std_logic_vector (7 downto 0) := "00000000";
  signal recebe_dado_in: std_logic := '0';
  signal saida_serial_out: std_logic := '1';
  signal pronto_out: std_logic := '0';
  signal dado_recebido_out: std_logic_vector(7 downto 0);
  signal db_estado_out: std_logic_vector(6 downto 0);
  signal tem_dado_out : std_logic := '0';
  -- Configurações do clock
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod : time := 20 ns;     -- clock de 50MHz
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;
  
  -- Conecta DUT (Device Under Test)
  dut: uart
       port map
       ( 
           clock=>          clock_in,
           reset=>          reset_in,
           partida=>        partida_in,
           dados_ascii=>    dados_ascii_8_in,
		   recebe_dado => recebe_dado_in,
		   tem_dado => tem_dado_out,
		   dado_recebido => dado_recebido_out,
		   db_estado => db_estado_out
		   
      );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin
  
    assert false report "Inicio da simulacao" severity note;
    keep_simulating <= '1';
    
    ---- inicio da simulacao: reset ----------------
    partida_in <= '0';
    reset_in <= '1'; 
    wait for 20*clockPeriod;  -- pulso com 20 periodos de clock
    reset_in <= '0';
    wait until falling_edge(clock_in);
    wait for 50*clockPeriod;

    ---- dado de entrada da simulacao (caso de teste #1)
    dados_ascii_8_in <= "00110101"; -- x35 = '5'	
    wait for 20*clockPeriod;

    ---- acionamento da partida (inicio da transmissao)
    partida_in <= '1';
    wait until rising_edge(clock_in);
    wait for 5*clockPeriod; -- pulso partida com 5 periodos de clock
    partida_in <= '0';

    ---- espera final da transmissao (pulso pronto em 1)
	wait until tem_dado_out='1';
	
	---- final do caso de teste 1
	recebe_dado_in <= '1';
    -- intervalo entre casos de teste
    wait for 500*clockPeriod;
	
    ---- inicio da simulacao: caso de teste 2 ----------------
    partida_in <= '0';
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
    partida_in <= '1';
    wait until rising_edge(clock_in);
    wait for 5*clockPeriod; -- pulso partida com 5 periodos de clock
    partida_in <= '0';

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