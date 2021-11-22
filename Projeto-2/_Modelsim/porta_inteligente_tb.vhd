library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity porta_inteligente_tb is
end entity;

architecture tb of porta_inteligente_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component porta_inteligente
	port ( 
	  clock, reset, echo_entrada, ligar: 		in  std_logic;
      proximidade_saida, pronto_saida:			in  std_logic; 
      trigger_entrada, medir_saida:  			out std_logic;
      pwm:          									out std_logic; 
	  alerta_proximidade: 							out std_logic;
	  db_pwm:											out std_logic;
	  saida_serial:                          out std_logic;
	  hex0:												out std_logic_vector(6 downto 0);
	  hex1:												out std_logic_vector(6 downto 0);
	  hex2:												out std_logic_vector(6 downto 0);
	  db_estado:										out std_logic_vector(6 downto 0)
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
        db_estado:     out std_logic_vector (3 downto 0)  -- estado da UC 
    ); 
  end component; 
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (ModelSim)
  signal clock_in				: std_logic := '0';
  signal reset_in				: std_logic := '0';
  signal echo_entrada_in		: std_logic := '0';
  signal ligar_in				: std_logic := '0';
  signal proximidade_saida_in	: std_logic := '0';
  signal pronto_saida_in		: std_logic := '0';
  signal trigger_entrada_out	: std_logic := '0';
  signal medir_saida_out		: std_logic := '0';
  signal pwm_out				: std_logic := '0'; 
  signal alerta_proximidade_out : std_logic := '0';
  signal saida_serial_out 		: std_logic := '0';

  -- auxiliar
  signal dado_ascii_out : std_logic_vector(7 downto 0) := "00000000";
  
    -- Array de casos de teste
  type caso_teste_type is record
      id    : natural; 
      tempo : integer;     
  end record;

  type simular_sensor_type is record
      id    : natural; 
      proximidade : std_logic;     
  end record;
  
  type casos_teste_array is array (natural range <>) of caso_teste_type;
  constant casos_teste_entrada : casos_teste_array :=
      (
        (1, 5882),   -- 5882us (100cm)
        (2, 1177),   -- 1177us (20cm)
		(3, 3059),   -- 3059us (52cm)
		(4, 641)     -- 641us  (10.9cm)
      );

  type simular_sensor_array is array (natural range <>) of simular_sensor_type;
  constant casos_teste_saida : simular_sensor_array :=
      (
		(1, '0'),	 -- 4353us (74cm)
		(2, '1'),	 -- 294us  (05cm)
		(3, '1'),   -- 1706us (29cm)
		(4, '0')    -- 2647us (45cm)
      );
	  
  signal larguraPulso: time := 1 ns;
  
  -- Configurações do clock
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod : time := 20 ns;     -- clock de 50MHz
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;
  
  -- Conecta DUT (Device Under Test)
  dut: porta_inteligente
       port map
       ( 
          clock					=> clock_in, 
		  reset					=> reset_in, 
		  echo_entrada			=> echo_entrada_in, 
		  ligar					=> ligar_in,
		  proximidade_saida		=> proximidade_saida_in, 
		  pronto_saida			=> pronto_saida_in,	
		  trigger_entrada		=> trigger_entrada_out, 
		  medir_saida			=> medir_saida_out,  		
		  pwm					=> pwm_out,  						
		  alerta_proximidade	=> alerta_proximidade_out, 					
		  saida_serial			=> saida_serial_out 					
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
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;
  
  stimulus: process is
  begin
  
    assert false report "Inicio das simulacoes" severity note;
    keep_simulating <= '1';
    
    ---- valores iniciais ----------------
    ligar_in <= '0';
    echo_entrada_in  <= '0';
    ---- inicio: reset ----------------
    wait for 2*clockPeriod;
    reset_in <= '1'; 
    wait for 2 us;
    reset_in <= '0';
    wait until falling_edge(clock_in);

    ---- espera de 100us
    wait for 100 us;

    ---- loop pelos casos de teste entrada
    for i in casos_teste_entrada'range loop
        -- 1) determina largura do pulso echo
        assert false report "Caso de teste " & integer'image(casos_teste_entrada(i).id) & ": " &
            integer'image(casos_teste_entrada(i).tempo) & "us" severity note;
        larguraPulso<= casos_teste_entrada(i).tempo * 1 us; -- caso de teste "i"
		
		pronto_saida_in <= '0';
		
        -- 2) envia pulso medir
        wait until falling_edge(clock_in);
        ligar_in <= '1';
     
        wait until medir_saida_out = '1';
     
        -- 4) gera pulso de echo (largura = larguraPulso)
        echo_entrada_in <= '1';
        wait for larguraPulso;
        echo_entrada_in <= '0';
		
		proximidade_saida_in <= casos_teste_saida(i).proximidade;
		pronto_saida_in <= '1';
		
        assert false report "Fim do caso " & integer'image(casos_teste_entrada(i).id) severity note;
     
        -- 6) espera entre casos de tese
        wait for 100 us;

    end loop;
	

    ---- final dos casos de teste da simulacao
    assert false report "Fim das simulacoes" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente (não retirar esta linha)
  end process;


end architecture;