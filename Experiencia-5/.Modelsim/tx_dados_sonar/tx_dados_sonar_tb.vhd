library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_dados_sonar_tb is
end entity;

architecture tb of tx_dados_sonar_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component tx_dados_sonar
	port ( 
		clock:           in  std_logic; 
		reset:           in  std_logic; 
		transmitir:      in  std_logic; 
		angulo2:         in  std_logic_vector(3 downto 0); 
		angulo1:         in  std_logic_vector(3 downto 0);
		angulo0:         in  std_logic_vector(3 downto 0); 
		distancia2:      in  std_logic_vector(3 downto 0);
		distancia1:      in  std_logic_vector(3 downto 0); 
		distancia0:      in  std_logic_vector(3 downto 0); 
		saida_serial:    out std_logic; 
		pronto:          out std_logic;  
		db_transmitir:   out std_logic; 
		db_saida_serial: out std_logic; 
		db_estado:       out std_logic_vector(3 downto 0) 
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
  signal angulo2_in:     std_logic_vector(3 downto 0); 
  signal angulo1_in:     std_logic_vector(3 downto 0);
  signal angulo0_in:     std_logic_vector(3 downto 0); 
  signal distancia2_in:  std_logic_vector(3 downto 0);  
  signal distancia1_in:  std_logic_vector(3 downto 0); 
  signal distancia0_in:  std_logic_vector(3 downto 0); 
  signal saida_serial_out: std_logic := '1';
  signal pronto_out: std_logic := '0';
  signal db_transmitir_out: std_logic := '0'; 
  signal db_saida_serial_out: std_logic := '0'; 
  signal db_estado_out: std_logic_vector(3 downto 0) := "0000"; 
  
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
  dut: tx_dados_sonar
       port map
       ( 
           clock=>           clock_in,
           reset=>           reset_in,
           transmitir=>      transmitir_in,
           angulo2=> 	     angulo2_in,
		   angulo1=> 	     angulo1_in, 
		   angulo0=> 	     angulo0_in, 
		   distancia2=>  	 distancia2_in,
		   distancia1=>  	 distancia1_in, 
		   distancia0=>  	 distancia0_in,  
           saida_serial=>    saida_serial_out,
           pronto=>          pronto_out,
		   db_transmitir=>   db_transmitir_out,
		   db_saida_serial=> db_saida_serial_out,
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

    ---- dado de entrada da simulacao (caso de teste #1)
	-- 153, 017
    angulo2_in <= "0001";
	angulo1_in <= "0101";
	angulo0_in <= "0011";
	
	distancia2_in <= "0000";
	distancia1_in <= "0001";
	distancia0_in <= "0111";
    wait for 20*clockPeriod;

    ---- acionamento da partida (inicio da transmissao)
    transmitir_in <= '1';
    wait until rising_edge(clock_in);
    wait for 5*clockPeriod; -- pulso partida com 5 periodos de clock
    transmitir_in <= '0';

    ---- espera final da transmissao (pulso pronto em 1)
	wait until pronto_out='1';
	
	---- final do caso de teste 1

    -- intervalo entre casos de teste
    wait for 500*clockPeriod;
	
    ---- inicio da simulacao: caso de teste 2 ----------------
    transmitir_in <= '0';
    reset_in <= '1'; 
    wait for 20*clockPeriod;  
    reset_in <= '0';
    wait until falling_edge(clock_in);
    wait for 50*clockPeriod;

    ---- dado de entrada da simulacao (caso de teste #2)
	-- 240,071
    angulo2_in <= "0010";
	angulo1_in <= "0100";
	angulo0_in <= "0000";
	
	distancia2_in <= "0000";
	distancia1_in <= "0111";
	distancia0_in <= "0001";
	
    wait for 20*clockPeriod;

    ---- acionamento da partida (inicio da transmissao)
    transmitir_in <= '1';
    wait until rising_edge(clock_in);
    wait for 5*clockPeriod; -- pulso partida com 5 periodos de clock
    transmitir_in <= '0';

    ---- espera final da transmissao (pulso pronto em 1)
	wait until pronto_out='1';
	
	wait for 1 ms;
	---- final do caso de teste 2

    ---- final dos casos de teste da simulacao
    assert false report "Fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;


end architecture;