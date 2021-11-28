library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity porta_inteligente_uc is
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
end entity;


architecture uc_arch of porta_inteligente_uc is

    type tipo_estado is (inicial, registra_modo, preparacao, mede, espera_medir, verifica_distancia, 
								 transmite, espera_transmitir, ativa_dado, espera_autorizacao, verifica_autorizacao,
								 ativa_mux, abre_porta, espera_5s, espera_200ms,fecha_porta);
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
    process (ligar, Eatual, pronto_sensores, pronto_rx, pronto_tx, pronto_200ms,
				 pronto_5s, autoriza, menorque30cm) 
	 begin	 
      case Eatual is                                  		

        when inicial =>          if ligar='1' then Eprox <= registra_modo;
                                 else                Eprox <= inicial;
                                 end if;
											
		  when registra_modo =>	   Eprox <= preparacao;

        when preparacao =>       Eprox <= mede;
		  
		  when mede =>    			Eprox <= espera_medir;
		  
		  when espera_medir =>     if pronto_sensores='1' then   Eprox <= verifica_distancia;
                                 else               Eprox <= espera_medir;
                                 end if;
											
		  when verifica_distancia => if (menorque30cm = '0' and automatico='0') then Eprox <= fecha_porta;
											  elsif (menorque30cm = '0' and automatico='1') then Eprox <= fecha_porta;
											  elsif (menorque30cm = '1' and automatico='1') then Eprox <= ativa_mux;
											  else Eprox <= transmite;
											  end if;
											  
		  when transmite => 			 Eprox <= espera_transmitir;
		  
		  when espera_transmitir => if pronto_tx='1' then   Eprox <= ativa_dado;
											 else               		 Eprox <= Espera_transmitir;
											 end if;
											 
		  when ativa_dado => 		 Eprox <= espera_autorizacao;
		  
		  when espera_autorizacao  =>  if pronto_rx='1' then   Eprox <= verifica_autorizacao;
												 else               		 Eprox <= espera_autorizacao;
												 end if;
												 
												 
		  when verifica_autorizacao  =>  if autoriza='1' then   Eprox <= ativa_mux;
												   else               	  Eprox <= fecha_porta;
												   end if;

		  when ativa_mux	=>	    Eprox <= abre_porta;
		  
        when abre_porta =>     Eprox <= espera_5s;
											
		  when fecha_porta =>   Eprox <= espera_200ms;
		  
		  when espera_200ms =>  if pronto_200ms='1' then   Eprox <= preparacao;
										else               Eprox <= espera_200ms;
										end if;
									
		  when espera_5s =>  	if pronto_5s='1' then   Eprox <= preparacao;
										else               Eprox <= espera_5s;
										end if;
										
        when others =>           Eprox <= inicial;

      end case;

    end process;

    -- logica de saida (Moore)
	 with Eatual select
        reg_modo <= '1' when registra_modo, '0' when others;
		  
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
        conta_5s <= '1' when espera_5s, '0' when others;
         
	with Eatual select
		  registra <= '1' when abre_porta | fecha_porta, '0' when others;
		  
	with Eatual select
		  transmitir <= '1' when transmite, '0' when others;
		  
	with Eatual select
		  recebe_dado <= '1' when ativa_dado, '0' when others;
		  
	-- saida de depuracao (db_estado)
	with Eatual select
		  db_estado <= "0000" when inicial,
							"0001" when registra_modo,
						   "0010" when preparacao,
							"0011" when mede,  
							"0100" when espera_medir,
							"0101" when verifica_distancia, 
							"0110" when ativa_mux,
							"0111" when abre_porta,
							"1000" when espera_200ms,
							"1001" when fecha_porta,
							"1010" when ativa_dado,
							"1011" when espera_autorizacao,
							"1100" when verifica_autorizacao,
							"1101" when espera_5s,
							"1110" when espera_transmitir,
							"1111" when others;

end architecture;