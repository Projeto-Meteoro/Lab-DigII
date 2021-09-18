
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_serial_8N2_fd is
    port (
        clock, reset:                  in  std_logic;
        zera, conta, carrega, desloca: in  std_logic;
        dados_ascii:                   in  std_logic_vector (7 downto 0);
        saida_serial, fim :            out std_logic
    );
end entity;

architecture rx_serial_8N2_fd_arch of rx_serial_8N2_fd is
     
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

    component contadorg_m 
    generic (
        constant M: integer; 
    );
    port (
        clock, zera_as, zera_s, conta: in std_logic;
        Q: out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
        fim, meio: out std_logic
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