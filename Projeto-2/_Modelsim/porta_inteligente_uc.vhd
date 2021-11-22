library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity porta_inteligente_uc is
	 port ( 
		clock:        			in  std_logic;
		reset:        			in  std_logic;
		ligar:        			in  std_logic;
		pronto_sensores: 		in  std_logic;
		proximidade_saida:   in  std_logic;
		proximidade_entrada: in  std_logic;
		esta_aberta:			in  std_logic;
		pronto_tx:				in  std_logic;
		pronto_200ms:			in  std_logic;
		medir_entrada:       out std_logic; 
		medir_saida:         out std_logic; 
		conta:               out std_logic;
		zera:                out std_logic; 
		sel_mux:             out std_logic;
		registra:            out std_logic;
		reg_entrada:    		out std_logic; 
		reg_saida:      		out std_logic;
		transmitir:				out std_logic;
		zera_reg:			 out std_logic;
		db_estado:           out std_logic_vector(3 downto 0)
    );
end entity;


architecture uc_arch of porta_inteligente_uc is

    type tipo_estado is (inicial, preparacao, mede, espera_medir, verifica_distancia, 
								 registra_entrada, registra_entradaEsaida, registra_saida, ativa_mux, abre_porta, espera_200ms, 
								 verifica_porta, transmite, espera_transmitir, zera_registradores, fecha_porta);
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
    process (ligar, Eatual, pronto_sensores, proximidade_saida, 
				 proximidade_entrada, esta_aberta, pronto_tx, pronto_200ms) 
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
											
		  when verifica_distancia => if (proximidade_entrada = '0' and proximidade_saida='0') then Eprox <= verifica_porta;
											  elsif (proximidade_entrada = '0' and proximidade_saida='1') then Eprox <= registra_entrada;
											  elsif (proximidade_entrada = '1' and proximidade_saida='1') then Eprox <= registra_entradaEsaida;
											  else Eprox <= registra_saida;
											  end if;
											  
		  when registra_entrada			=> Eprox <= ativa_mux;
		  
		  when registra_saida			=> Eprox <= ativa_mux;
		  
		  when registra_entradaEsaida => Eprox <= ativa_mux;

		  when ativa_mux	=>	    Eprox <= abre_porta;
		  
        when abre_porta =>     Eprox <= espera_200ms;
		  		  
		  when verifica_porta => if esta_aberta='1' then   Eprox <= transmite;
										 else               Eprox <= fecha_porta;
										 end if;
										 
		  when transmite => Eprox <= espera_transmitir;
		  
		  when Espera_transmitir => if pronto_tx='1' then   Eprox <= zera_registradores;
											 else               		 Eprox <= Espera_transmitir;
											 end if;
													
		  when zera_registradores => Eprox <= fecha_porta;
		  
		  when fecha_porta =>   Eprox <= espera_200ms;
		  
		  when espera_200ms =>  if pronto_200ms='1' then   Eprox <= preparacao;
										else               Eprox <= espera_200ms;
										end if;
											
        when others =>           Eprox <= inicial;

      end case;

    end process;

    -- logica de saida (Moore)
	 with Eatual select
        zera <= '1' when preparacao, '0' when others;
		  
    with Eatual select
        medir_entrada <= '1' when mede, '0' when others;
		  
	 with Eatual select
        medir_saida <= '1' when mede | espera_medir, '0' when others;
		  
	with Eatual select
        sel_mux <= '1' when ativa_mux | abre_porta, '0' when others;
		  
   with Eatual select
        conta <= '1' when espera_200ms, '0' when others;
         
	with Eatual select
		  registra <= '1' when abre_porta | fecha_porta, '0' when others;
		  
	with Eatual select
		  reg_entrada <= '1' when registra_entrada | registra_entradaEsaida, '0' when others;
		  
	with Eatual select
		  reg_saida  <= '1' when registra_saida | registra_entradaEsaida, '0' when others;
		  
	with Eatual select
		  transmitir <= '1' when transmite, '0' when others;
	
	with Eatual select
		  zera_reg <= '1' when zera_registradores, '0' when others;
		  
	-- saida de depuracao (db_estado)
	with Eatual select
		  db_estado <= "0000" when inicial,
						   "0001" when preparacao,
							"0010" when mede,  
							"0011" when espera_medir,
							"0100" when verifica_distancia, 
							"0101" when ativa_mux,
							"0110" when abre_porta,
							"0111" when espera_200ms,
							"1000" when fecha_porta,
							"1001" when registra_entrada,
							"1010" when registra_saida,
							"1011" when registra_entradaEsaida,
							"1100" when verifica_porta,
							"1101" when transmite,
							"1110" when espera_transmitir,
							"1111" when others;

end architecture;