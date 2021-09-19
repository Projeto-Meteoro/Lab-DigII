-------------------------------------------------------------------
-- Arquivo   : tx_serial_7E2.vhd
-- Projeto   : Experiencia 2 - Transmissao Serial Assincrona
-------------------------------------------------------------------
-- Descricao : circuito da experiencia 2 
--             > implementa configuracao 7E2 e taxa de 115200 bauds
--             > 
--             > componente edge_detector (U4) trata pulsos largos
--             > de PARTIDA (veja linha 83)
-------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
-------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tx_serial_7E2 is
    port (
        clock, reset, partida: in  std_logic;
        dados_ascii:           in  std_logic_vector (6 downto 0);
        saida_serial, pronto : out std_logic
    );
end entity;

architecture tx_serial_7E2_arch of tx_serial_7E2 is
     
    component tx_serial_tick_uc port ( 
            clock, reset, partida, tick, fim:      in  std_logic;
            zera, conta, carrega, desloca, pronto: out std_logic 
    );
    end component;

    component tx_serial_7E2_fd port (
        clock, reset: in std_logic;
        zera, conta, carrega, desloca: in std_logic;
        dados_ascii: in std_logic_vector (6 downto 0);
        saida_serial, fim : out std_logic
    );
    end component;
    
    component contador_m
    generic (
        constant M: integer; 
        constant N: integer 
    );
    port (
        clock, zera, conta: in std_logic;
        Q: out std_logic_vector (N-1 downto 0);
        fim: out std_logic
    );
    end component;
    
    component edge_detector is port ( 
             clk         : in   std_logic;
             signal_in   : in   std_logic;
             output      : out  std_logic
    );
    end component;
    
    signal s_reset, s_partida, s_partida_ed: std_logic;
    signal s_zera, s_conta, s_carrega, s_desloca, s_tick, s_fim: std_logic;

begin

    -- sinais reset e partida mapeados na GPIO (ativos em alto)
    s_reset   <= reset;
    s_partida <= partida;

    -- unidade de controle
    U1_UC: tx_serial_tick_uc port map (clock, s_reset, s_partida_ed, s_tick, s_fim,
                                       s_zera, s_conta, s_carrega, s_desloca, pronto);

    -- fluxo de dados
    U2_FD: tx_serial_7E2_fd port map (clock, s_reset, s_zera, s_conta, s_carrega, s_desloca, 
                                      dados_ascii, saida_serial, s_fim);

    -- gerador de tick
    -- fator de divisao 50MHz para 115.200 bauds (434=50M/115200), 9 bits
    U3_TICK: contador_m generic map (M => 434, N => 9) port map (clock, s_zera, '1', open, s_tick);
 
    -- detetor de borda para tratar pulsos largos
    U4_ED: edge_detector port map (clock, s_partida, s_partida_ed);
    
end architecture;

