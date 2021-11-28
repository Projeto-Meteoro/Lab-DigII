library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity porta_inteligente is
	 port ( 
		clock, reset, echo_entrada, ligar: 		in  std_logic;
      proximidade_saida, pronto_saida:			in  std_logic; 
		modo, dado_serial:							in  std_logic;
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
end entity;


architecture pi_arch of porta_inteligente is

component porta_inteligente_uc
	 port ( 
		clock:        			in  std_logic;
		reset:        			in  std_logic;
		ligar:        			in  std_logic;
		menorque30cm:			in	 std_logic;
		pronto_sensores: 		in  std_logic;
		pronto_tx:				in  std_logic;
		pronto_rx:				in	 std_logic;
		pronto_200ms:			in  std_logic;
		pronto_5s:				in  std_logic;
		autoriza:				in  std_logic;
		automatico:				in  std_logic;
		medir_entrada:       out std_logic; 
		medir_saida:         out std_logic; 
		conta:               out std_logic;
		conta_5s:            out std_logic;
		zera:                out std_logic; 
		sel_mux:             out std_logic;
		registra:            out std_logic;
		reg_modo:	    		out std_logic; 
		transmitir:				out std_logic;
		recebe_dado:			out std_logic;
		db_estado:           out std_logic_vector(3 downto 0)
    );
end component;

component porta_inteligente_fd
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
end component;

component hex7seg
    port (
        hexa : in  std_logic_vector(3 downto 0);
        sseg : out std_logic_vector(6 downto 0)
    );
end component;

	signal pronto_sensores, medir_entrada, conta, zera, sel_mux, registra: std_logic;
	signal menorque30cm, autoriza, automatico, transmitir: std_logic;
	signal pronto_rx, pronto_tx, pronto_200ms: std_logic;		
	signal pronto_5s, conta_5s, registra_modo, recebe_dado: std_logic;
	signal s_estado: std_logic_vector(3 downto 0);
	signal db_entrada: std_logic_vector(11 downto 0);
	
begin
	U1_UC: porta_inteligente_uc port map(clock, reset, ligar, menorque30cm, pronto_sensores, pronto_tx, pronto_rx,
													 pronto_200ms, pronto_5s, autoriza, automatico, medir_entrada, medir_saida, conta, 
													 conta_5s, zera, sel_mux, registra, registra_modo, transmitir, recebe_dado, s_estado);
													 
	U2_FD: porta_inteligente_fd port map(clock, reset, modo, dado_serial, conta, sel_mux, medir_entrada, echo_entrada,
													 proximidade_saida, pronto_saida, registra, zera, registra_modo, transmitir,
													 recebe_dado, conta_5s, trigger_entrada, pwm, pronto_sensores, menorque30cm, 
				   								 saida_serial, pronto_tx, pronto_rx, pronto_200ms, pronto_5s, autoriza,
													 automatico, db_pwm, db_entrada);
	
	-- Depuracao
	
	U3_HEX0: hex7seg port map(db_entrada(3 downto 0), hex0);
	
	U4_HEX1: hex7seg port map(db_entrada(7 downto 4), hex1);

	U5_HEX2: hex7seg port map(db_entrada(11 downto 8), hex2);
	
	U6_HEX5: hex7seg port map(s_estado, db_estado);
	
	alerta_proximidade <= menorque30cm;
	
end architecture;