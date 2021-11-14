library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity porta_inteligente_uc is
	 port ( 
		clock, reset, ligar, pronto_sensores: 		 in  std_logic;
		menorque30cm, pronto_10s: in std_logic;
		medir_entrada, medir_saida, conta, zera, sel_mux, registra: out std_logic;
		db_estado:  out std_logic_vector(3 downto 0)
    );
end entity;


architecture uc_arch of porta_inteligente_uc is

    type tipo_estado is (inicial, preparacao, mede, espera_medir, verifica_distancia, ativa_mux, abre_porta, espera_10s, fecha_porta);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado
	 signal pronto_sensor : std_logic;

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
    process (ligar, Eatual, pronto_sensores, menorque30cm, pronto_10s) 
    begin

      case Eatual is

        when inicial =>          if ligar='1' then Eprox <= preparacao;
                                 else                Eprox <= inicial;
                                 end if;

        when preparacao =>       Eprox <= mede;
		  
		  when mede =>    			Eprox <= espera_medir;
		  
		  when espera_medir =>     if pronto_sensores='1' then   Eprox <= verifica_distancia;
                                 else               Eprox <= espera_medir;
                                 end if;
											
		  when verifica_distancia => if menorque30cm='1' then Eprox <= ativa_mux;
											  else Eprox <= fecha_porta;
											  end if;

		  when ativa_mux	=>	    Eprox <= abre_porta;
		  
        when abre_porta =>     Eprox <= espera_10s;
		  
		  when espera_10s =>		if pronto_10s='1' then   Eprox <= verifica_distancia;
                              else               Eprox <= espera_10s;
                              end if;
		  
		  when fecha_porta =>   Eprox <= mede;
											
        when others =>           Eprox <= inicial;

      end case;

    end process;

    -- logica de saida (Moore)
	 with Eatual select
        zera <= '1' when preparacao, '0' when others;
		  
    with Eatual select
        medir_entrada <= '1' when mede, '0' when others;
		  
	 with Eatual select
        medir_saida <= '1' when mede, '0' when others;
		  
	with Eatual select
        sel_mux <= '1' when ativa_mux | abre_porta, '0' when others;
		  
   with Eatual select
        conta <= '1' when espera_10s, '0' when others;
         
	with Eatual select
		  registra <= '1' when abre_porta | fecha_porta, '0' when others;
		  
	 -- saida de depuracao (db_estado)
	 with Eatual select
		  db_estado <= "0000" when inicial,
						   "0001" when preparacao,
							"0010" when mede,  
							"0011" when espera_medir,
							"0100" when verifica_distancia, 
							"0101" when ativa_mux,
							"0110" when abre_porta,
							"0111" when espera_10s,
							"1000" when fecha_porta,
							"1010" when others;

end architecture;