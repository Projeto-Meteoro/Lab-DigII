library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interface_hcsr04_uc is
	 port ( 
		clock, reset, medir, echo: 					 in  std_logic;
		zera, conta, pronto,limpa, registra, gera: out std_logic;
		db_estado: 											 out std_logic_vector(3 downto 0)
    );
end entity;


architecture uc_arch of interface_hcsr04_uc is

    type tipo_estado is (inicial, preparacao, gera_trigger, espera_echo, medicao, armazena, final);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

begin

    -- memoria de estado
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

  -- logica de proximo estado
    process (medir, echo, Eatual) 
    begin

      case Eatual is

        when inicial =>          if medir='1' then Eprox <= preparacao;
                                 else                Eprox <= inicial;
                                 end if;

        when preparacao =>       Eprox <= gera_trigger;
		  
		  when gera_trigger =>     Eprox <= espera_echo;

        when espera_echo =>      if echo='1' then   Eprox <= medicao;
                                 else               Eprox <= espera_echo;
                                 end if;

        when medicao =>            if echo='1' then   Eprox <= medicao;
                                 else               Eprox <= armazena;
                                 end if;
 
        when armazena =>         Eprox <= final;
		  
		  when final    =>			Eprox <= inicial;
		  
											
        when others =>           Eprox <= inicial;

      end case;

    end process;

    -- logica de saida (Moore)
	 with Eatual select
        limpa <= '1' when preparacao, '0' when others;
		  
    with Eatual select
        zera <= '1' when preparacao, '0' when others;

    with Eatual select
        gera <= '1' when gera_trigger, '0' when others;

    with Eatual select
        conta <= '1' when medicao, '0' when others;

    with Eatual select
        registra <= '1' when armazena, '0' when others;
		  
    with Eatual select
        pronto <= '1' when final, '0' when others;
         
	 -- saida de depuracao (db_estado)
	 with Eatual select
		  db_estado <= "0000" when inicial,
						   "0001" when preparacao,
							"0010" when gera_trigger,      
							"0011" when espera_echo,     
							"0100" when medicao,      
							"0101" when armazena,
							"0110" when final,
							"1010" when others;

end architecture;