library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity controla_servo_e_interface is 
	port ( 
		clock:      in  std_logic;  
		reset:      in  std_logic; 
		echo:       in  std_logic; 
      conta:   	in  std_logic;
		medir:		in  std_logic;
		modo_manual:	  in  std_logic;
		posicao_manual: in std_logic_vector(2 downto 0);
		trigger:    out std_logic; 
		distancia0: out std_logic_vector(7 downto 0); -- digitos da medida 
		distancia1:       out std_logic_vector(7 downto 0);  
		distancia2:       out std_logic_vector(7 downto 0); 
		angulo0:       out std_logic_vector(7 downto 0); 
		angulo1:       out std_logic_vector(7 downto 0); 
		angulo2:      out std_logic_vector(7 downto 0); 
		pwm:           out std_logic; 
		pronto_sensor:     out std_logic; 
		pronto_servo:     out std_logic;
		db_echo:    out std_logic; 
		db_estado:  out std_logic_vector(3 downto 0);
      db_pwm:        out std_logic;
      posicao:       out std_logic_vector (2 downto 0)
    ); 
end entity controla_servo_e_interface;
architecture estrutural of controla_servo_e_interface is
	
	component interface_hcsr04 
		port ( 
		clock:     in  std_logic;  
		reset:     in  std_logic; 
		medir:     in  std_logic; 
		echo:      in  std_logic; 
		config_unidade: in std_logic;
		trigger:   out std_logic; 
		medida:    out std_logic_vector(11 downto 0); -- 3 digitos BCD 
		pronto:    out std_logic; 
		db_estado: out std_logic_vector(3 downto 0);   -- estado da UC 
		db_tick:	  out std_logic
    ); 
	end component;

	component movimentacao_servomotor 
		port ( 
        clock:         in  std_logic;  
        reset:         in  std_logic; 
        conta:   	 	  in  std_logic; 
		  modo_manual:	  in  std_logic;
		  posicao_manual: in std_logic_vector(2 downto 0);
        pwm:           out std_logic; 
        db_pwm:        out std_logic;
		  pronto:		  out std_logic;
        posicao:       out std_logic_vector (2 downto 0)
		);
	end component;

	component contadorg_m 
		generic (
			constant M: integer := 50 -- modulo do contador
		);
		port (
			clock, zera_as, zera_s, conta: in std_logic;
			Q: out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
			fim, meio: out std_logic 
		);
	end component;
	
	component rom_8x24 
		port ( 
        endereco: in  std_logic_vector(2 downto 0);
        saida   : out std_logic_vector(23 downto 0)
		);
	end component;
	
	signal s_medida : std_logic_vector(11 downto 0);
	signal s_rom: std_logic_vector(23 downto 0);
	signal s_posicao: std_logic_vector(2 downto 0);

begin
	
	U1_IH: interface_hcsr04 port map (clock, reset, medir, echo, '0',
										  trigger, s_medida, pronto_sensor, db_estado);
	
	U2_MS: movimentacao_servomotor port map (clock, reset, conta, modo_manual, posicao_manual,
																  pwm, db_pwm, pronto_servo, s_posicao);
																  
				
	U3_ROM: rom_8x24 port map(s_posicao, s_rom);
	
	-- distancia
	distancia0 <= "0011" & s_medida(3 downto 0);
	distancia1 <= "0011" & s_medida(7 downto 4);
	distancia2 <= "0011" & s_medida(11 downto 8);
	
	-- angulo
	angulo2 <= s_rom(23 downto 16);
	angulo1 <= s_rom(15 downto 8);
	angulo0 <= s_rom(7 downto 0);
	
	-- posicao
	posicao <= s_posicao;
	
	
   -- depuracao	
	db_echo <= echo;
end architecture;