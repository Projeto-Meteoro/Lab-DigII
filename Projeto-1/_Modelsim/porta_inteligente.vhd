library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity porta_inteligente is
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
end entity;


architecture pi_arch of porta_inteligente is

component porta_inteligente_uc
	 port ( 
		clock, reset, ligar, pronto_sensores: 		 in  std_logic;
		menorque30cm, pronto_10s: in std_logic;
		medir_entrada, medir_saida, conta, zera, sel_mux, registra: out std_logic;
		db_estado:  out std_logic_vector(3 downto 0)
    );
end component;

component porta_inteligente_fd
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
end component;

component hex7seg
    port (
        hexa : in  std_logic_vector(3 downto 0);
        sseg : out std_logic_vector(6 downto 0)
    );
end component;

	signal pronto_sensores, menorque30cm, medir_entrada, medir_saida, conta, zera, sel_mux, registra: std_logic;
	signal pronto_10s : std_logic;
	signal s_estado: std_logic_vector(3 downto 0);
	signal db_saida: std_logic_vector(11 downto 0);
	
begin
	U1_UC: porta_inteligente_uc port map(clock, reset, ligar, pronto_sensores, menorque30cm, pronto_10s, medir_entrada,
													 medir_saida, conta, zera, sel_mux, registra, s_estado);
													 
	U2_FD: porta_inteligente_fd port map(clock, reset, conta, sel_mux, medir_entrada, medir_saida, echo_entrada,
													 echo_saida, registra, zera, trigger_entrada, trigger_saida, pwm,
													 pronto_sensores, menorque30cm, pronto_10s, db_saida);

	
	-- Depuracao
	
	U3_HEX0: hex7seg port map(db_saida(3 downto 0), hex0);
	
	U4_HEX1: hex7seg port map(db_saida(7 downto 4), hex1);

	U5_HEX2: hex7seg port map(db_saida(11 downto 8), hex2);
	
	U6_HEX5: hex7seg port map(s_estado, db_estado);
	
	alerta_proximidade <= menorque30cm;
	
end architecture;