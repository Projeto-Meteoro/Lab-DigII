------------------------------------------------------------------
-- Arquivo   : tx_serial_82N_fd.vhd
-- Projeto   : Experiencia 2 - Transmissao Serial Assincrona - atividade 2
------------------------------------------------------------------
-- Descricao : fluxo de dados do circuito da experiencia 2 
--             > implementa configuracao 8N2
--             > nao comporta bit de paridade na transmissão
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
--     12/09/2021  2.0     Bancada B1        versao modificada para a configuracao 82N
------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_serial_8N2_fd is
    port (
        clock, reset:                  in  std_logic;
        zera, conta, carrega, desloca: in  std_logic;
        dados_ascii:                   in  std_logic_vector (7 downto 0);
        saida_serial, fim :            out std_logic
    );
end entity;

architecture tx_serial_8N2_fd_arch of tx_serial_8N2_fd is
     
    component deslocador_n
    generic (
        constant N: integer 
    );
    port (
        clock, reset: in std_logic;
        carrega, desloca, entrada_serial: in std_logic; 
        dados: in std_logic_vector (N-1 downto 0);
        saida: out  std_logic_vector (N-1 downto 0)
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
    
    signal s_dados, s_saida: std_logic_vector (11 downto 0);

begin

    s_dados(0) <= '1';  -- repouso
    s_dados(1) <= '0';  -- start bit
    s_dados(9 downto 2) <= dados_ascii;
    s_dados(11 downto 10) <= "11";  -- stop bits

    U1: deslocador_n generic map (N => 12)  port map (clock, reset, carrega, desloca, '1', s_dados, s_saida);

    U2: contador_m generic map (M => 13, N => 4) port map (clock, zera, conta, open, fim);

    saida_serial <= s_saida(0);
    
end architecture;

