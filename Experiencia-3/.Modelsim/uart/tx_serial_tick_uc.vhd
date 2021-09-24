------------------------------------------------------------------
-- Arquivo   : tx_serial_tick_uc.vhd
-- Projeto   : Experiencia 2 - Transmissao Serial Assincrona
------------------------------------------------------------------
-- Descricao : circuito da experiencia 2 
--             > unidade de controle para o circuito
--             > de transmissao serial assincrona
--             > 
--             > usa a tecnica de superamostragem com o uso
--             > de sinal de tick para transmissao de dados
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;

entity tx_serial_tick_uc is 
    port ( clock, reset, partida, tick, fim:      in  std_logic;
           zera, conta, carrega, desloca, pronto: out std_logic
    );
end entity;

architecture tx_serial_tick_uc_arch of tx_serial_tick_uc is

    type tipo_estado is (inicial, preparacao, espera, transmissao, final);
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
    process (partida, tick, fim, Eatual) 
    begin

      case Eatual is

        when inicial =>          if partida='1' then Eprox <= preparacao;
                                 else                Eprox <= inicial;
                                 end if;

        when preparacao =>       Eprox <= espera;

        when espera =>           if tick='1' then   Eprox <= transmissao;
                                 elsif fim='0' then Eprox <= espera;
                                 else               Eprox <= final;
                                 end if;

        when transmissao =>      if fim='0' then Eprox <= espera;
                                 else            Eprox <= final;
                                 end if;
 
        when final =>            Eprox <= inicial;

        when others =>           Eprox <= inicial;

      end case;

    end process;

    -- logica de saida (Moore)
    with Eatual select
        carrega <= '1' when preparacao, '0' when others;

    with Eatual select
        zera <= '1' when preparacao, '0' when others;

    with Eatual select
        desloca <= '1' when transmissao, '0' when others;

    with Eatual select
        conta <= '1' when transmissao, '0' when others;

    with Eatual select
        pronto <= '1' when final, '0' when others;

end tx_serial_tick_uc_arch;
