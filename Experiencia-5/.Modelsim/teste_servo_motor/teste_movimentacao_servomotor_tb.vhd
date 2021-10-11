-- controle_servo_tb
--
library ieee;
use ieee.std_logic_1164.all;

entity teste_movimentacao_servomotor_tb is
end entity;

architecture tb of teste_movimentacao_servomotor_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component teste_movimentacao_servomotor is
    port (
        clock:         in  std_logic;  
        reset:         in  std_logic; 
        ligar:   	 	  in  std_logic; 
        db_ligar:      out std_logic; 
        pwm:           out std_logic; 
        db_pwm:        out std_logic; 
        posicao:       out std_logic_vector (2 downto 0)
    );
  end component;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (GHDL ou ModelSim)
  signal clock_in: std_logic := '0';
  signal reset_in: std_logic := '0';
  signal ligar_in: std_logic := '0';
  signal db_ligar_out: std_logic := '0';
  signal posicao_out: std_logic_vector (2 downto 0) := "000";
  signal pwm_out: std_logic := '0';
  signal db_pwm_out: std_logic := '0';

  -- Configurações do clock
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod: time := 20 ns;
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;

 
  -- Conecta DUT (Device Under Test)
  dut: teste_movimentacao_servomotor port map( 
         clock=>   clock_in,
         reset=>   reset_in,
         ligar=>  ligar_in,
		 db_ligar=> db_ligar_out,
         pwm=>     pwm_out,
		 db_pwm=> db_pwm_out,
		 posicao=> posicao_out
      );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin
  
    assert false report "Inicio da simulacao" & LF & "... Simulacao ate 8000 ms. Aguarde o final da simulacao..." severity note;
    keep_simulating <= '1';
    
    ---- inicio: reset ----------------
    reset_in <= '1'; 
    wait for 2*clockPeriod;
    reset_in <= '0';
    wait for 2*clockPeriod;

    ---- casos de teste
	ligar_in<= '1'; 
    wait for 2*clockPeriod;
    wait for 8000 ms;
	
	ligar_in<= '0'; 
    wait for 2*clockPeriod;
	
    ---- final dos casos de teste  da simulacao
    assert false report "Fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;


end architecture;