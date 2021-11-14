------------------------------------------------------------------
-- Arquivo   : tx_dados_sonar_uc.vhd
-- Projeto   : Experiencia 5 - Sonar 1 - Atividade 1
------------------------------------------------------------------
-- Descricao : circuito da experiencia 5
--             > unidade de controle para o circuito
--             > de transmissao serial assincrona
--             > Implementa o controle para a saida serial
------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tx_dados_sonar_uc is 
	port ( 
		clock:           in  std_logic; 
		reset:           in  std_logic; 
		transmitir:      in  std_logic; 
		fim:				  in  std_logic;
		pronto_tx:		  in  std_logic;
		conta:			  out std_logic;
		partida:			  out std_logic;
		pronto:          out std_logic;  
		zera:				  out std_logic;
		db_estado:       out std_logic_vector(3 downto 0)
	); 
end entity;

architecture dados_sonar_uc_arch of tx_dados_sonar_uc is

    type tipo_estado is (inicial, preparacao, transmite, espera, verifica_fim, conta_contador, final);
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
    process (transmitir, pronto_tx, fim, Eatual) 
    begin

      case Eatual is

        when inicial =>          if transmitir='1'   then Eprox <= preparacao;
                                 else                Eprox <= inicial;
                                 end if;

        when preparacao =>       Eprox <= transmite;

        when transmite =>        Eprox <= espera;
		
		when espera =>	 if pronto_tx='1' then Eprox <= verifica_fim;
                                 else            Eprox <= espera;
                                 end if;
											
		  when verifica_fim =>		if fim='1'		then Eprox <= final;
											else				Eprox <= conta_contador;
											end if;
											
		  when conta_contador =>   Eprox <= transmite;
 
        when final =>            if transmitir='1' then Eprox <= preparacao;
											else					Eprox <= final;
											end if;

        when others =>           Eprox <= inicial;

      end case;

    end process;

    -- logica de saida (Moore)
    with Eatual select
        zera <= '1' when preparacao, '0' when others;

    with Eatual select
        partida <= '1' when transmite, '0' when others;

    with Eatual select
        conta <= '1' when conta_contador, '0' when others;
		  
    with Eatual select
        pronto <= '1' when final, '0' when others;
		  
	 -- saida de depuracao (db_estado)
	 with Eatual select
		  db_estado <= "0000" when inicial,
						   "0001" when preparacao,     
							"0010" when transmite,
							"0011" when espera,
							"0100" when conta_contador,
							"0101" when final,
							"1010" when others;
end architecture;
