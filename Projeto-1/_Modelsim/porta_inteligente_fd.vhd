library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity porta_inteligente_fd is
	port (
        clock:        			in  std_logic; 
        reset:        			in  std_logic; 
        conta:        			in  std_logic; 
		  sel_mux:					in  std_logic;
		  medir_entrada:			in  std_logic;
		  medir_saida:				in  std_logic;
        echo_entrada:  			in  std_logic; 
		  echo_saida:  			in  std_logic;
		  registra:             in  std_logic;
		  zera:						in  std_logic;
        trigger_entrada:  		out std_logic;  
		  trigger_saida:  		out std_logic;
        pwm:          			out std_logic; 
		  pronto_sensores:		out std_logic;
		  menorque30cm:			out std_logic;
		  pronto_10s:				out std_logic;
		  db_saida:					out std_logic_vector(11 downto 0)
   );
end entity;


architecture fd_arch of porta_inteligente_fd is

component interface_hcsr04
	port ( 
		clock:     in  std_logic;  
		reset:     in  std_logic; 
		medir:     in  std_logic; 
		echo:      in  std_logic; 
		config_unidade: in std_logic;
		trigger:   out std_logic; 
		medida:    out std_logic_vector(11 downto 0); -- 3 digitos BCD 
		pronto:    out std_logic; 
		db_estado: out std_logic_vector(3 downto 0);   -- estado da UC 
		db_tick:	  out std_logic
    ); 
end component;

component controle_servo_3
    port( 
        clock:      in  std_logic; 
        reset:      in  std_logic; 
        posicao:    in  std_logic_vector(2 downto 0); 
        pwm:        out std_logic; 
        db_reset:   out std_logic;  
        db_pwm:     out std_logic; 
        db_posicao: out std_logic_vector(2 downto 0) 
    ); 
end component;


component contadorg_m
    generic (
        constant M: integer := 50 -- modulo do contador
    );
   port (
        clock, zera_as, zera_s, conta: in std_logic;
        Q: out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
        fim, meio: out std_logic 
   );
end component;

component registrador_n
    generic (
       constant N: integer := 8 
    );
    port (
       clock:  in  std_logic;
       clear:  in  std_logic;
       enable: in  std_logic;
       D:      in  std_logic_vector (N-1 downto 0);
       Q:      out std_logic_vector (N-1 downto 0) 
    );
end component;


	signal posicao, saida_registrador: std_logic_vector(2 downto 0);
	signal pronto_entrada, pronto_saida: std_logic;
	signal medida_entrada, medida_saida: std_logic_vector(11 downto 0);
	signal proximidade_entrada, proximidade_saida: std_logic;
	 
begin 
	-- MODIFICADO PARA 200 MS 
	ESP10S: contadorg_m generic map (M => 10000000) port map (clock, zera, '0',  conta, open, pronto_10s);	
	
	with sel_mux select
		posicao <= "000" when '1', "110" when others;
		
		
	RN: registrador_n generic map (N => 3) port map(clock, reset, registra, posicao, saida_registrador);
	
	CS3: controle_servo_3 port map(clock, reset, saida_registrador, pwm);

	
	HCS_E: interface_hcsr04 port map (clock, reset, medir_entrada, echo_entrada, '0', trigger_entrada, 
												 medida_entrada, pronto_entrada);
	
	HCS_S: interface_hcsr04 port map (clock, reset, medir_saida, echo_saida, '0', trigger_saida, 
												 medida_saida, pronto_saida);

												 
	proximidade_entrada <= '0' when medida_entrada(11 downto 8) /= "0000" else
								  '1' when medida_entrada(7 downto 4) = "0010" else
								  '1' when medida_entrada(7 downto 4) = "0001" else
								  '1' when medida_entrada(7 downto 4) = "0000" else '0';
								  
	proximidade_saida <= '0' when medida_saida(11 downto 8) /= "0000" else
								  '1' when medida_saida(7 downto 4) = "0010" else
								  '1' when medida_saida(7 downto 4) = "0001" else
								  '1' when medida_saida(7 downto 4) = "0000" else '0';
								  
	menorque30cm <= proximidade_saida or proximidade_entrada;
	
	pronto_sensores <= pronto_saida and pronto_entrada;
	-- depuracao
   db_saida <= medida_saida;
end architecture;