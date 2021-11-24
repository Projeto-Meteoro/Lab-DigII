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
        echo_entrada:  			in  std_logic; 
		  proximidade_saida: 	in  std_logic;
		  pronto_saida:         in  std_logic;
		  registra:             in  std_logic;
		  zera:						in  std_logic;
		  registra_entrada:     in  std_logic;
		  registra_saida:       in  std_logic;
		  transmitir:           in  std_logic;
		  zera_reg:				in  std_logic;
        trigger_entrada:  		out std_logic;  
        pwm:          			out std_logic; 
		  pronto_sensores:		out std_logic;
		  proximidade_entrada:	out std_logic;
		  saida_serial:         out std_logic;
		  esta_aberta:          out std_logic;
		  pronto_tx:        		out std_logic;
		  pronto_200ms:         out std_logic;
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
		saida_serial:    out std_logic; 
		pronto:          out std_logic;  
		db_transmitir:   out std_logic; 
		db_saida_serial: out std_logic; 
		db_estado:       out std_logic_vector(3 downto 0) 
	); 
end component;


	signal posicao, saida_registrador: std_logic_vector(2 downto 0);
	signal c5, c4, c3, c2, c1, c0: std_logic_vector(7 downto 0);
	signal pronto_entrada: std_logic;
	signal medida_entrada: std_logic_vector(11 downto 0);
	signal sel_palavra: std_logic_vector(1 downto 0);
	signal prox_entrada : std_logic_vector(0 downto 0);
	signal prox_saida: std_logic_vector(0 downto 0);
	signal entrou_pessoa, saiu_pessoa: std_logic_vector(0 downto 0);
	
begin 
	
	prox_saida(0) <= proximidade_saida;
	
	with sel_mux select
		posicao <= "000" when '1', "110" when others;
		
		
	ENTROUSAIU: memoria_palavras port map(sel_palavra, c5, c4, c3, c2, c1, c0);
	
	TX: tx_dados_porta port map (clock, zera, transmitir, c5, c4, c3, c2, c1, c0, saida_serial, pronto_tx, open, open, open);
		
	RN: registrador_n generic map (N => 3) port map(clock, reset, registra, posicao, saida_registrador);
	
	RE: registrador_n generic map (N => 1) port map(clock, zera_reg, registra_entrada, "1", entrou_pessoa);
	
	RS: registrador_n generic map (N => 1) port map(clock, zera_reg, registra_saida, "1", saiu_pessoa);

	CS3: controle_servo_3 port map(clock, reset, saida_registrador, pwm);

	
	HCS_E: interface_hcsr04 port map (clock, reset, medir_entrada, echo_entrada, '0', trigger_entrada, 
												 medida_entrada, pronto_entrada);
												 
	ESP200MS: contadorg_m generic map (M => 10000000) port map (clock, zera, '0',  conta, open, pronto_200ms);	
												 
	prox_entrada(0) <= '0' when medida_entrada(11 downto 8) /= "0000" else
								  '1' when medida_entrada(7 downto 4) = "0010" else
								  '1' when medida_entrada(7 downto 4) = "0001" else
								  '1' when medida_entrada(7 downto 4) = "0000" else '0';
								  
	sel_palavra <= saiu_pessoa & entrou_pessoa;
	
	pronto_sensores <= pronto_entrada and pronto_saida;
	
	esta_aberta <= entrou_pessoa(0) or saiu_pessoa(0);
	
	proximidade_entrada <= prox_entrada(0);
	-- depuracao
   db_entrada <= medida_entrada;
end architecture;