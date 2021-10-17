library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sonar_tb is
end entity;

architecture tb of sonar_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component sonar
	port ( 
        clock:        in  std_logic; 
        reset:        in  std_logic; 
        ligar:        in  std_logic; 
        echo:         in std_logic; 
        trigger:      out std_logic;  
        pwm:          out std_logic; 
        saida_serial: out std_logic;
	    alerta_proximidade: out std_logic
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
  signal clock_in: std_logic := '0';
  signal reset_in: std_logic := '0';
  signal ligar_in: std_logic := '0';
  signal echo_in: std_logic := '1';
  signal trigger_out: std_logic := '0';
  signal pwm_out: std_logic := '0'; 
  signal saida_serial_out: std_logic := '0'; 
  signal alerta_proximidade_out: std_logic := '0';
  
  -- auxiliar
  signal dado_ascii_out : std_logic_vector(7 downto 0) := "00000000";

    -- Array de casos de teste
  type caso_teste_type is record
      id    : natural; 
      tempo : integer;     
  end record;

  type casos_teste_array is array (natural range <>) of caso_teste_type;
  constant casos_teste : casos_teste_array :=
      (
        (1, 5882),   -- 5882us (100cm)
        (2, 4353),   -- 4353us (74cm)
		(3, 2941),	 -- 2941   (50cm)
		(4, 589),	 -- 589	   (10cm)
		(5, 642)	 -- 642    (10.9cm)
        -- inserir aqui outros casos de teste (inserir "," na linha anterior)
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
  dut: sonar
       port map
       ( 
           clock=>          	clock_in,
           reset=>          	reset_in,
           ligar=>	        	ligar_in,
		   echo=>			 	echo_in,
		   trigger=>		 	trigger_out,
		   pwm=> 			 	pwm_out,
		   saida_serial=>	 	saida_serial_out,
		   alerta_proximidade=> alerta_proximidade_out
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
    echo_in  <= '0';

    ---- inicio: reset ----------------
    wait for 2*clockPeriod;
    reset_in <= '1'; 
    wait for 2 us;
    reset_in <= '0';
    wait until falling_edge(clock_in);

    ---- espera de 100us
    wait for 100 us;

    ---- loop pelos casos de teste
    for i in casos_teste'range loop
        -- 1) determina largura do pulso echo
        assert false report "Caso de teste " & integer'image(casos_teste(i).id) & ": " &
            integer'image(casos_teste(i).tempo) & "us" severity note;
        larguraPulso <= casos_teste(i).tempo * 1 us; -- caso de teste "i"

        -- 2) envia pulso medir
        wait until falling_edge(clock_in);
        ligar_in <= '1';
     
        wait for 400 us;
     
        -- 4) gera pulso de echo (largura = larguraPulso)
        echo_in <= '1';
        wait for larguraPulso;
        echo_in <= '0';
     
        -- 5) espera final da medida
      	wait for 200 ms; 
        assert false report "Fim do caso " & integer'image(casos_teste(i).id) severity note;
     
        -- 6) espera entre casos de tese
        wait for 100 us;

    end loop;

    ---- final dos casos de teste da simulacao
    assert false report "Fim das simulacoes" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente (não retirar esta linha)
  end process;


end architecture;