library IEEE;
use IEEE.std_logic_1164.all;

entity reg is
port(
	clock  : in  std_logic; --! entrada de clock
	reset  : in  std_logic; --! clear assincrono
	load   : in  std_logic; --! write enable (carga paralela)
	d      : in  std_logic; --! entrada
	q      : out std_logic  --! saida
);
end reg;

architecture reg_arch of reg is
  signal IQ : std_logic;
begin

  process (clock, reset, IQ)
  begin
    if reset='1' then
      IQ <= '0';
    elsif clock'event and clock='1' then
	  IQ <= D;
    end if;
  end process;
  
  Q <= IQ;
  
end reg_arch;