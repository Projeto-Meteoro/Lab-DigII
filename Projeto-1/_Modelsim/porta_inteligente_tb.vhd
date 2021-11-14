library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity porta_inteligente_tb is
end entity;

architecture tb of porta_inteligente_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component porta_inteligente
	port ( 
		clock, reset, echo_entrada, ligar: 					 in  std_logic;
      echo_saida:         in  std_logic; 
      trigger_saida:      out std_logic; 
		trigger_entrada:    out std_logic;
      pwm:          out std_logic; 
		alerta_proximidade: out std_logic;
		hex0:			out std_logic_vector(6 downto 0);
		hex1:			out std_logic_vector(6 downto 0);
		hex2:			out std_logic_vector(6 downto 0);
		db_estado:	out std_logic_vector(6 downto 0)
	); 
  end component;

  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (ModelSim)
  signal clock_in: std_logic := '0';
  signal reset_in: std_logic := '0';
  signal ligar_in: std_logic := '0';
  signal echo_entrada_in: std_logic := '0';
  signal echo_saida_in: std_logic := '0';
  signal trigger_entrada_out: std_logic := '0';
  signal trigger_saida_out: std_logic := '0';
  signal pwm_out: std_logic := '0'; 
  signal alerta_proximidade_out: std_logic := '0';
  


    -- Array de casos de teste
  type caso_teste_type is record
      id    : natural; 
      tempo : integer;     
  end record;

  type casos_teste_array is array (natural range <>) of caso_teste_type;
  constant casos_teste_entrada : casos_teste_array :=
      (
        (1, 5882),   -- 5882us (100cm)
        (2, 1177),   -- 1177us (20cm)
		(3, 3059),   -- 3059us (52cm)
		(4, 641)     -- 641us  (10.9cm)
      );

  constant casos_teste_saida : casos_teste_array :=
      (
		(1, 4353),	 -- 4353us (74cm)
		(2, 295),	 -- 294us  (05cm)
		(3, 1706),   -- 1706us (29cm)
		(4, 2647)    -- 2647us (45cm)
      );
	  
  signal larguraPulso_entrada, larguraPulso_saida: time := 1 ns;
  
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
           clock=>          	clock_in,
           reset=>          	reset_in,
           ligar=>	        	ligar_in,
		   echo_entrada=>		echo_entrada_in,
		   echo_saida=>			echo_saida_in,
		   trigger_entrada=>	trigger_entrada_out,
		   trigger_saida=>		trigger_saida_out,
		   pwm=> 			 	pwm_out,
		   alerta_proximidade=> alerta_proximidade_out
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
	echo_saida_in  <= '0';
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
        larguraPulso_entrada <= casos_teste_entrada(i).tempo * 1 us; -- caso de teste "i"
		larguraPulso_saida <= casos_teste_saida(i).tempo * 1 us; -- caso de teste "i"
		
        -- 2) envia pulso medir
        wait until falling_edge(clock_in);
        ligar_in <= '1';
     
        wait for 400 us;
     
        -- 4) gera pulso de echo (largura = larguraPulso)
        echo_entrada_in <= '1';
        wait for larguraPulso_entrada;
        echo_entrada_in <= '0';
		
		echo_saida_in <= '1';
        wait for larguraPulso_saida;
        echo_saida_in <= '0';
     
        -- 5) espera final da medida
      	wait for 200 ms; 
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