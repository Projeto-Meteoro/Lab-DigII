library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity movimentacao_servomotor is 
    port  
    ( 
        clock:         in  std_logic;  
        reset:         in  std_logic; 
        conta:   	 	  in  std_logic; 
        pwm:           out std_logic; 
        db_pwm:        out std_logic;
		  pronto:		  out std_logic;
        posicao:       out std_logic_vector (2 downto 0)
    ); 
end entity; 

architecture estrutural of movimentacao_servomotor is
     
    component controle_servo_3 port ( 
        clock:      in  std_logic; 
        reset:      in  std_logic; 
        posicao:    in  std_logic_vector(2 downto 0); 
        pwm:        out std_logic; 
        db_reset:   out std_logic;  
        db_pwm:     out std_logic; 
        db_posicao: out std_logic_vector(2 downto 0) 
    );
    end component;

    component contadorg_updown_m
		generic (
				  constant M: integer := 50 -- modulo do contador
			 );
			port (
				  clock:   in  std_logic;
				  zera_as: in  std_logic;
				  zera_s:  in  std_logic;
				  conta:   in  std_logic;
				  Q:       out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
				  inicio:  out std_logic;
				  fim:     out std_logic;
				  meio:    out std_logic 
			);
    end component;
    
    component contadorg_m 
    generic (
        constant M: integer
    );
    port (
        clock, zera_as, zera_s, conta: in std_logic;
        Q: out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
        fim, meio: out std_logic
    );
    end component;
	 
	 signal s_tick, s_pwm : std_logic;
	 signal s_posicao: std_logic_vector(2 downto 0);

begin

    U1_CS3: controle_servo_3 port map (clock, reset, s_posicao, s_pwm);

    U2_SEG: contadorg_updown_m generic map (M => 8) port map (clock, reset, '0', s_tick, s_posicao);

    -- gerador de tick
    -- fator de divisao (10000000=2s/(20*10^-9) MODIFICADO PARA 200 MS
    U3_TICK: contadorg_m  generic map (M => 10000000) port map (clock, reset, '0',  conta, open, s_tick);
	 
	 -- Sinais de saida
	 pwm <= s_pwm;
	 posicao <= s_posicao;
	 pronto <= s_tick;
	 db_pwm <= s_pwm;
end architecture;