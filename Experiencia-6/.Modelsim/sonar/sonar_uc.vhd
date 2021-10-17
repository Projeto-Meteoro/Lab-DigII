library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sonar_uc is
	 port ( 
		clock, reset, ligar, pronto_sensor, pronto_servo: 		 in  std_logic;
		medir, conta, zera, transmitir: out std_logic;
		db_estado:  out std_logic_vector(3 downto 0)
    );
end entity;


architecture uc_arch of sonar_uc is

    type tipo_estado is (inicial, preparacao, mede, transmite, muda_posicao);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

begin

    -- memoria de estado
    process (reset, clock, ligar)
    begin
        if reset = '1' then
            Eatual <= inicial;
		  elsif ligar = '0' then
		      Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

  -- logica de proximo estado
    process (ligar, Eatual, pronto_sensor, pronto_servo) 
    begin

      case Eatual is

        when inicial =>          if ligar='1' then Eprox <= preparacao;
                                 else                Eprox <= inicial;
                                 end if;

        when preparacao =>       Eprox <= mede;
		  
		  when mede =>    			if pronto_sensor='1' then   Eprox <= transmite;
                                 else               Eprox <= mede;
                                 end if;
											
		  when transmite =>			Eprox <= muda_posicao;

        when muda_posicao =>     if pronto_servo='1' then   Eprox <= mede;
                                 else               Eprox <= muda_posicao;
                                 end if;
		  
											
        when others =>           Eprox <= inicial;

      end case;

    end process;

    -- logica de saida (Moore)
	 with Eatual select
        zera <= '1' when preparacao, '0' when others;
		  
    with Eatual select
        medir <= '1' when mede, '0' when others;
		  
    with Eatual select
        transmitir <= '1' when transmite, '0' when others;

    with Eatual select
        conta <= '1' when muda_posicao, '0' when others;
         
	 -- saida de depuracao (db_estado)
	 with Eatual select
		  db_estado <= "0000" when inicial,
						   "0001" when preparacao,
							"0010" when mede,  
							"0011" when transmite,
							"0100" when muda_posicao, 
							"1010" when others;

end architecture;