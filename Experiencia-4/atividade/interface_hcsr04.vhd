library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interface_hcsr04 is 
    port ( 
        clock:     in  std_logic;  
        reset:     in  std_logic; 
        medir:     in  std_logic; 
        echo:      in  std_logic; 
        trigger:   out std_logic; 
        medida:    out std_logic_vector(11 downto 0); -- 3 digitos BCD 
        pronto:    out std_logic; 
        db_estado: out std_logic_vector(3 downto 0)   -- estado da UC 
    ); 
end entity interface_hcsr04;

architecture hcsr04_arch of interface_hcsr04 is

	component interface_hcsr04_uc port ( 
		clock, reset, medir, echo: 					 in  std_logic;
		zera, conta, pronto,limpa, registra, gera: out std_logic;
		db_estado: 											 out std_logic_vector(3 downto 0)
    );
	end component;

	component interface_hcsr04_fd port (
		clock, conta, zera: 		in  std_logic;
		registra, gera, limpa:  in  std_logic;
		trigger, fim :			   out std_logic;
		distancia: 					out std_logic_vector (11 downto 0)
    );
	end component;
	
	signal s_zera, s_conta, s_limpa, s_registra, s_gera: std_logic;
begin

	-- unidade de controle
	U1_UC: interface_hcsr04_uc port map (clock, reset, medir, echo,
                                        s_zera, s_conta, pronto, s_limpa, s_registra, s_gera, db_estado);

	-- fluxo de dados
	U2_FD: interface_hcsr04_fd port map (clock, reset, s_zera, s_registra, s_gera, s_limpa, 
													 trigger, open, medida);
												 
end architecture;