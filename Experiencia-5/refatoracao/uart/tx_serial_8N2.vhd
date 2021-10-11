-------------------------------------------------------------------
-- Arquivo   : tx_serial_82N.vhd
-- Projeto   : Experiencia 2 - Transmissao Serial Assincrona - Atividade 2
-------------------------------------------------------------------
-- Descricao : circuito da experiencia 2 - atividade 2
--             > implementa configuracao 82N e taxa de 9600 bauds
--             > 
--             > componente edge_detector (U4) trata pulsos largos
--             > de PARTIDA (veja linha 83)
-------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial 
--     12/09/2021  2.0     Bancada B1        versao modificada para a configuracao 82N
-------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tx_serial_8N2 is
    port (
        clock, reset, partida:   in  std_logic;
        dados_ascii:             in  std_logic_vector (7 downto 0);
        saida_serial, pronto_tx: out std_logic;
		  db_partida:      out std_logic;  
        db_saida_serial: out std_logic; 
        db_estado:       out std_logic_vector(3 downto 0)
    );
end entity;

architecture tx_serial_8N2_arch of tx_serial_8N2 is
     
    component tx_serial_tick_uc port ( 
            clock, reset, partida, tick, fim:      in  std_logic;
            zera, conta, carrega, desloca, pronto: out std_logic;
				db_estado:       out std_logic_vector(3 downto 0)
    );
    end component;

    component tx_serial_8N2_fd port (
        clock, reset: in std_logic;
        zera, conta, carrega, desloca: in std_logic;
        dados_ascii: in std_logic_vector (7 downto 0);
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
    
    component edge_detector_up is port ( 
             clk         : in   std_logic;
             signal_in   : in   std_logic;
             output      : out  std_logic
    );
    end component;
    
    signal s_reset: std_logic;
    signal s_zera, s_conta, s_carrega, s_desloca, s_tick, s_fim: std_logic;
	 signal s_serial: std_logic;

begin

    -- sinais reset e partida mapeados na GPIO (ativos em alto)
    s_reset   <= reset;

    -- unidade de controle
    U1_UC: tx_serial_tick_uc port map (clock, s_reset, partida, s_tick, s_fim,
                                       s_zera, s_conta, s_carrega, s_desloca, pronto_tx, db_estado);

    -- fluxo de dados
    U2_FD: tx_serial_8N2_fd port map (clock, s_reset, s_zera, s_conta, s_carrega, s_desloca, 
                                      dados_ascii, s_serial, s_fim);

    -- gerador de tick
    -- fator de divisao 50MHz para 9600 bauds (5208=50M/9600), 13 bits
    U3_TICK: contador_m generic map (M => 5208, N => 13) port map (clock, s_zera, '1', open, s_tick);
 
	 
	 saida_serial <= s_serial;
     
	 -- Depuracao
	 db_partida <= partida;
	 db_saida_serial <= s_serial;
end architecture;