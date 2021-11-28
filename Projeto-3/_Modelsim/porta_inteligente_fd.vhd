library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity porta_inteligente_fd is
	port (
        clock:        			in  std_logic; 
        reset:        			in  std_logic; 
		  modo:						in	 std_logic;
		  dado_serial:				in  std_logic;
        conta:        			in  std_logic; 
		  sel_mux:					in  std_logic;
		  medir_entrada:			in  std_logic;
        echo_entrada:  			in  std_logic; 
		  proximidade_saida: 	in  std_logic;
		  pronto_saida:         in  std_logic;
		  registra:             in  std_logic;
		  zera:						in  std_logic;
		  registra_modo:     	in  std_logic;
		  transmitir:           in  std_logic;
		  recebe_dado:				in  std_logic;
		  conta_5s:					in	 std_logic;
        trigger_entrada:  		out std_logic;  
        pwm:          			out std_logic; 
		  pronto_sensores:		out std_logic;
		  menorque30cm:			out std_logic;
		  saida_serial:         out std_logic;
		  pronto_tx:        		out std_logic;
		  pronto_rx:				out std_logic;
		  pronto_200ms:         out std_logic;
		  pronto_5s:				out std_logic;
		  autoriza:					out std_logic;
		  automatico:				out std_logic;
		  db_pwm:					out std_logic;
		  db_entrada:			   out std_logic_vector(11 downto 0)
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

component memoria_palavras is
    port ( 
       SEL:       in  std_logic_vector (1 downto 0);
       C5 :       out std_logic_vector (7 downto 0);
		 C4 :       out std_logic_vector (7 downto 0);
       C3 :       out std_logic_vector (7 downto 0);
		 C2 :       out std_logic_vector (7 downto 0);
       C1 :       out std_logic_vector (7 downto 0);
		 C0 :       out std_logic_vector (7 downto 0)
    );
end component;

component tx_dados_porta is 
	port ( 
		clock:           in  std_logic; 
		reset:           in  std_logic; 
		transmitir:      in  std_logic; 
		caractere5:      in  std_logic_vector(7 downto 0); -- digitos ASCII 
		caractere4:      in  std_logic_vector(7 downto 0);
		caractere3:      in  std_logic_vector(7 downto 0);
		caractere2:      in  std_logic_vector(7 downto 0);
		caractere1:      in  std_logic_vector(7 downto 0);
		caractere0:      in  std_logic_vector(7 downto 0);
		recebe_dado:	  in  std_logic; 
		dado_serial:	  in	std_logic;		
		saida_serial:    out std_logic; 
		pronto:          out std_logic;
		tem_dado:		  out std_logic;
		dado_recebido:	  out std_logic_vector(7 downto 0);		
		db_transmitir:   out std_logic; 
		db_saida_serial: out std_logic; 
		db_estado:       out std_logic_vector(3 downto 0) 
	); 
end component;

component reg
port(
	clock  : in  std_logic; 
	reset  : in  std_logic; 
	load   : in  std_logic; 
	d      : in  std_logic; 
	q      : out std_logic  
);
end component;

	signal posicao, saida_registrador: std_logic_vector(2 downto 0);
	signal c5, c4, c3, c2, c1, c0: std_logic_vector(7 downto 0);
	signal pronto_entrada, proximidade_entrada: std_logic;
	signal medida_entrada: std_logic_vector(11 downto 0);
	signal sel_palavra: std_logic_vector(1 downto 0);
	signal dado_recebido: std_logic_vector(7 downto 0);
begin 
	
	with sel_mux select
		posicao <= "000" when '1', "110" when others;
		
	ENTROUSAIU: memoria_palavras port map(sel_palavra, c5, c4, c3, c2, c1, c0);
	
	TX: tx_dados_porta port map (clock, zera, transmitir, c5, c4, c3, c2, c1, c0, recebe_dado, dado_serial, saida_serial, 
										  pronto_tx, pronto_rx, dado_recebido, open, open, open);
		
	RN: registrador_n generic map (N => 3) port map(clock, reset, registra, posicao, saida_registrador);
	
	RM: reg port map(clock, reset, registra_modo, modo, automatico);

	CS3: controle_servo_3 port map(clock, reset, saida_registrador, pwm);

	
	HCS_E: interface_hcsr04 port map (clock, zera, medir_entrada, echo_entrada, '0', trigger_entrada, 
												 medida_entrada, pronto_entrada);
												 
	ESP200MS: contadorg_m generic map (M => 2500000) port map (clock, zera, '0',  conta, open, pronto_200ms);
	
	ESP5S: contadorg_m generic map (M => 2500000) port map (clock, zera, '0',  conta_5s, open, pronto_5s);	
												 
	proximidade_entrada <= '0' when medida_entrada(11 downto 8) /= "0000" else
								  '1' when medida_entrada(7 downto 4) = "0001" else
								  '1' when medida_entrada(7 downto 4) = "0000" else '0';
								  
	sel_palavra <= proximidade_saida & proximidade_entrada; -- entrou pessoa & saiu pessoa
	
	menorque30cm <= proximidade_saida or proximidade_entrada;
	
	pronto_sensores <= pronto_entrada and pronto_saida;
	
	autoriza <= '1' when dado_recebido = "01010011" else
	            '1' when dado_recebido = "01110011" else '0';
					
	-- depuracao
   db_entrada <= medida_entrada;
	db_pwm <= '1' when saida_registrador = "000" else '0';
end architecture;