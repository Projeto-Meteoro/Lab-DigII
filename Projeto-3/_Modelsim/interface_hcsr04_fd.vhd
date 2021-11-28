library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interface_hcsr04_fd is
	port (
		clock, conta, zera: 		in  std_logic;
		registra, gera, limpa:  in  std_logic;
		trigger, fim:           out std_logic;
		distancia: 					out std_logic_vector (11 downto 0)
   );
end entity;


architecture fd_arch of interface_hcsr04_fd is

	component gerador_pulso 
		generic (
			largura: integer:= 25
		);
		port(
			clock:  in  std_logic;
			reset:  in  std_logic;
			gera:   in  std_logic;
			para:   in  std_logic;
			pulso:  out std_logic;
			pronto: out std_logic
		);
	end component;

	component contador_bcd_4digitos
		port ( 
			clock, zera, conta:     in  std_logic;
			dig3, dig2, dig1, dig0: out std_logic_vector(3 downto 0);
			fim:                    out std_logic
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
	
	signal s_contagem: std_logic_vector(11 downto 0);
	 
begin 
	contagem: contador_bcd_4digitos port map (clock, zera, conta, open, s_contagem(11 downto 8), 
														   s_contagem(7 downto 4), s_contagem(3 downto 0));
															
	registrador: registrador_n generic map (N=> 12) port map (clock, limpa, registra, s_contagem, distancia);
	
	-- fator de divisao 10us para 20ns (500=10us/20ns)
	gera_pulso: gerador_pulso generic map (largura => 500) port map (clock, zera, gera, '0', trigger, fim);

end architecture;