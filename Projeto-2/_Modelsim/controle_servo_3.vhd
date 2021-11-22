-- controle_servo.vhd - descrição rtl
--
-- gera saída com modulacao pwm para controlar o servo motor
--
-- parametros: CONTAGEM_MAXIMA e largura_pwm
--             (clock a 50MHz ou 20ns)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo_3 is 
    port( 
        clock:      in  std_logic; 
        reset:      in  std_logic; 
        posicao:    in  std_logic_vector(2 downto 0); 
        pwm:        out std_logic; 
        db_reset:   out std_logic;  
        db_pwm:     out std_logic; 
        db_posicao: out std_logic_vector(2 downto 0) 
    ); 
end entity;

architecture rtl of controle_servo_3 is

  constant CONTAGEM_MAXIMA : integer := 1000000;-- valor para frequencia da saida de 50Hz 
                                               -- ou periodo de 20ms
  signal contagem     : integer range 0 to CONTAGEM_MAXIMA-1;
  signal largura_pwm  : integer range 0 to CONTAGEM_MAXIMA-1;
  signal s_largura    : integer range 0 to CONTAGEM_MAXIMA-1;
  
begin

  process(clock,reset, posicao)
  begin
    -- inicia contagem e largura
    if(reset='1') then
      contagem    <= 0;
      pwm         <= '0';
		db_pwm      <= '0';
      largura_pwm <= s_largura;
    elsif(rising_edge(clock)) then
        -- saida
        if(contagem < largura_pwm) then
          pwm    <= '1';
			 db_pwm <= '1';
        else
          pwm    <= '0';
			 db_pwm <= '0';
        end if;
        -- atualiza contagem e largura
        if(contagem=CONTAGEM_MAXIMA-1) then
          contagem   <= 0;
          largura_pwm <= s_largura;
        else
          contagem   <= contagem + 1;
        end if;
    end if;
  end process;

  process(posicao)
  begin
    case posicao  is
      when "000" =>    s_largura <=   50000;  -- pulso de  1     ms
		when "001" =>    s_largura <=   57150;  -- pulso de  1,143 ms
		when "010" =>    s_largura <=   64300;  -- pulso de  1,286 ms
		when "011" =>    s_largura <=   71450;  -- pulso de  1,429 ms
		when "100" =>    s_largura <=   78550;  -- pulso de  1,571 ms
		when "101" =>    s_largura <=   85700;  -- pulso de  1,714 ms
      when "110" =>    s_largura <=   92850;  -- pulso de  1,857 ms
		when "111" =>    s_largura <=  100000;  -- pulso de  2     ms
      when others =>  s_largura <=       0;  -- nulo   saida 0
    end case;
  end process;

 -- Depuracao
  db_reset 	 <= reset;
  db_posicao <= posicao;
end architecture;