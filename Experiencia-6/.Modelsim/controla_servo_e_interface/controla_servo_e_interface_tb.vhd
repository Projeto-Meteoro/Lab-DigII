library ieee;
use ieee.std_logic_1164.all;

entity controla_servo_e_interface_tb is
end entity;

architecture tb of controla_servo_e_interface_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component controla_servo_e_interface
    port (
		clock:						in  std_logic;  
		reset:						in  std_logic; 
		echo:							in  std_logic; 
      conta:   					in  std_logic;
		medir:						in  std_logic;
		trigger:   				 	out std_logic; 
		distancia0: 				out std_logic_vector(7 downto 0); -- digitos da medida 
		distancia1:       		out std_logic_vector(7 downto 0);  
		distancia2:       		out std_logic_vector(7 downto 0); 
		angulo0:       			out std_logic_vector(7 downto 0); 
		angulo1:       			out std_logic_vector(7 downto 0); 
		angulo2:      				out std_logic_vector(7 downto 0); 
		pwm:           			out std_logic; 
		pronto_sensor:     		out std_logic; 
		pronto_servo:     		out std_logic;
		db_echo:    				out std_logic; 
		db_estado_sonar:	 		out std_logic_vector(3 downto 0);
		db_pwm:        			out std_logic;
		posicao:       			out std_logic_vector (2 downto 0)
    );
  end component;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (GHDL ou ModelSim)
  signal clock_in:      		std_logic := '0';
  signal reset_in:     		 	std_logic := '0';
  signal echo_in:      		 	std_logic := '0';
  signal conta_in:      		std_logic := '0';
  signal medir_in:     		 	std_logic := '0';
  signal trigger_out:   		std_logic := '0';
  signal distancia0_in: 		std_logic_vector (7 downto 0) := x"00";
  signal distancia1_in: 		std_logic_vector (7 downto 0) := x"00";
  signal distancia2_in: 		std_logic_vector (7 downto 0) := x"00";
  signal angulo0_in:    		std_logic_vector (7 downto 0) := x"00";
  signal angulo1_in:    		std_logic_vector (7 downto 0) := x"00";
  signal angulo2_in:    		std_logic_vector (7 downto 0) := x"00";
  signal pwm_out:   			std_logic := '0';
  signal pronto_sensor_out:		std_logic := '0';
  signal pronto_servo_out:		std_logic := '0';
  signal db_echo_out:			std_logic := '0';
  signal db_estado_sonar_out:	std_logic_vector(3 downto 0) := x"0";
  signal db_pwm_out:			std_logic := '0';
  signal posicao_out:			std_logic_vector(2 downto 0) := "000";

  -- Configurações do clock
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod:   time := 20 ns;    -- clock de 50MHz
  
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

begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;
  
  -- Conecta DUT (Device Under Test)
  dut: controla_servo_e_interface
       port map( 
				clock       	=>clock_in,   		
				reset       	=>reset_in,  		 	
				echo			=>echo_in,   		 	
				conta       	=>conta_in,   		
				medir       	=>medir_in,  		 	
				trigger			=>trigger_out,		   		
				distancia0		=>distancia0_in,	 	
				distancia1		=>distancia1_in,	       
				distancia2		=>distancia2_in,	       
				angulo0			=>angulo0_in, 		       	
				angulo1			=>angulo1_in, 		       	
				angulo2			=>angulo2_in, 		      	
				pwm				=>pwm_out,			           	
				pronto_sensor	=>pronto_sensor_out,	    
				pronto_servo	=>pronto_servo_out,	    
				db_echo			=>db_echo_out,		   	
				db_estado_sonar	=>db_estado_sonar_out,
				db_pwm			=>db_pwm_out,		       	
				posicao			=>posicao_out			      	
      );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin
  
    assert false report "Inicio das simulacoes" severity note;
    keep_simulating <= '1';
    
    ---- valores iniciais ----------------
    medir_in <= '0';
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
        medir_in <= '1';
        wait for 5*clockPeriod;
        medir_in <= '0';
     
        -- 3) espera por 400us (tempo entre trigger e echo)
        wait for 400 us;
     
        -- 4) gera pulso de echo (largura = larguraPulso)
        echo_in <= '1';
        wait for larguraPulso;
        echo_in <= '0';
     
        -- 5) espera final da medida
      	wait until pronto_sensor_out = '1';
        assert false report "Fim do caso " & integer'image(casos_teste(i).id) severity note;
     
        conta_in <= '1';
        wait for 200 ms;
        conta_in <= '0';
		
        wait for 100 us;

    end loop;

    ---- final dos casos de teste da simulacao
    assert false report "Fim das simulacoes" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente (não retirar esta linha)
  end process;

end architecture;
