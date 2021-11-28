library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity porta_inteligente_tb is
end entity;

architecture tb of porta_inteligente_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component porta_inteligente
	port ( 
		clock, reset, echo_entrada, ligar: 			in  std_logic;
        proximidade_saida, pronto_saida:			in  std_logic; 
		modo, dado_serial:							in  std_logic;
		trigger_entrada, medir_saida:  				out std_logic;
        pwm:          								out std_logic; 
		alerta_proximidade: 						out std_logic;
		db_pwm:										out std_logic;
		saida_serial:                         		out std_logic;
		hex0:										out std_logic_vector(6 downto 0);
		hex1:										out std_logic_vector(6 downto 0);
		hex2:										out std_logic_vector(6 downto 0);
		db_estado:									out std_logic_vector(6 downto 0)
	); 
  end component;

   -- componente auxiliar
  
  component uart_8N2
    port  
    ( 
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
  signal clock_in				: std_logic := '0';
  signal reset_in				: std_logic := '0';
  signal echo_entrada_in		: std_logic := '0';
  signal ligar_in				: std_logic := '0';
  signal proximidade_saida_in	: std_logic := '0';
  signal pronto_saida_in		: std_logic := '0';
  signal modo_in				: std_logic := '0';
  signal dado_serial_in			: std_logic := '0';
  signal trigger_entrada_out	: std_logic := '0';
  signal medir_saida_out		: std_logic := '0';
  signal pwm_out				: std_logic := '0'; 
  signal alerta_proximidade_out : std_logic := '0';
  signal saida_serial_out 		: std_logic := '0';

  -- auxiliar
  signal dados_recebido_out : std_logic_vector(7 downto 0) := "00000000";
  signal dados_ascii_in 	: std_logic_vector(7 downto 0) := "00000000";
  signal transmite_dado_in	: std_logic := '0';
  
    -- Array de casos de teste
  type caso_teste_type is record
      id    : natural; 
      tempo : integer;
	  proximidade : std_logic;    
	  modo 		  : std_logic; 
	  dado_ascii  : std_logic_vector(7 downto 0);
  end record;
  
  type casos_teste_array is array (natural range <>) of caso_teste_type;
  constant casos_teste : casos_teste_array :=
      (
        (1, 5883, '0', '1', "00000000"),   -- 5883us  (100cm) // modo = automatico 	  // transmissao = null 
        (2, 520, '1',  '1', "00000000"),    -- 520us  (8.3cm)  // modo = automatico	  // transmissao = null 
		(3, 1000, '1', '0', "01101110"),   -- 1000us  (17cm)  // modo = nao automatico // transmissao = n 
		(4, 894, '1',  '0', "01110011"),    -- 894us  (15cm)   // modo = nao automatico // transmissao = s
		(5, 16649,'0', '0', "00000000"),   -- 16649us (283cm) // modo = nao automatico // transmissao = s
		(6, 3779, '1', '0', "01010011")   -- 641us   (10.9cm)
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
		  modo 					=> modo_in,
		  dado_serial			=> dado_serial_in,
		  trigger_entrada		=> trigger_entrada_out, 
		  medir_saida			=> medir_saida_out,  		
		  pwm					=> pwm_out,  						
		  alerta_proximidade	=> alerta_proximidade_out, 					
		  saida_serial			=> saida_serial_out 					
      );
	  
  -- Conecta component auxiliar
  aux: uart_8N2
       port map
       ( 
		   clock=>           clock_in,
           reset=>           reset_in,
		   -- rx
		   dado_serial=> saida_serial_out,
		   recebe_dado=> '1',
		   pronto_rx=> open,
		   tem_dado=> open,
		   dado_recebido_rx=> dados_recebido_out,
		   -- tx
		   transmite_dado => transmite_dado_in,
		   dados_ascii => dados_ascii_in,
		   saida_serial => dado_serial_in
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
    for i in casos_teste'range loop
        -- 1) determina largura do pulso echo
        assert false report "Caso de teste " & integer'image(casos_teste(i).id) & ": " &
            integer'image(casos_teste(i).tempo) & "us" severity note;
        larguraPulso<= casos_teste(i).tempo * 1 us; -- caso de teste "i"
		
		pronto_saida_in <= '0';
		ligar_in <= '0';
		modo_in <= casos_teste(i).modo;
		
        -- 2) envia pulso medir
        wait until falling_edge(clock_in);
        ligar_in <= '1';
     
        wait until medir_saida_out = '1';
     
        -- 4) gera pulso de echo (largura = larguraPulso)
        echo_entrada_in <= '1';
        wait for larguraPulso;
        echo_entrada_in <= '0';
		
		proximidade_saida_in <= casos_teste(i).proximidade;
		pronto_saida_in <= '1';
		
		-- Autorizacao
		wait for 10 ms;
		
		dados_ascii_in <= casos_teste(i).dado_ascii;
		
		transmite_dado_in <= '1';
		wait for clockPeriod;
		transmite_dado_in <= '0';
		
        assert false report "Fim do caso " & integer'image(casos_teste(i).id) severity note;
     
        -- 6) espera entre casos de tese
        wait for 50 ms;

    end loop;

    ---- final dos casos de teste da simulacao
    assert false report "Fim das simulacoes" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente (não retirar esta linha)
  end process;


end architecture;