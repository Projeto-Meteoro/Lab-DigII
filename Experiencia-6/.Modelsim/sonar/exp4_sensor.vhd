library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exp4_sensor is 
	port ( 
		clock:      in  std_logic;  
		reset:      in  std_logic; 
		medir:      in  std_logic; 
		echo:       in  std_logic; 
		config_unidade: in std_logic;
		trigger:    out std_logic; 
		hex0:       out std_logic_vector(6 downto 0); -- digitos da medida 
		hex1:       out std_logic_vector(6 downto 0);  
		hex2:       out std_logic_vector(6 downto 0); 
		pronto:     out std_logic; 
		db_echo:    out std_logic; 
		db_estado:  out std_logic_vector(6 downto 0);  -- estado da UC? 
		db_tick:		out std_logic
    ); 
end entity exp4_sensor;
architecture exp4_sensor_arch of exp4_sensor is

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

	component edge_detector 
		port ( 
			clk         : in   std_logic;
			signal_in   : in   std_logic;
			output      : out  std_logic
		);
	end component;
	 
	component hex7seg
		port (
			hexa : in  std_logic_vector(3 downto 0);
			sseg : out std_logic_vector(6 downto 0)
		);
	end component;
	
	signal s_medir_ed, s_trigger: std_logic;
	signal s_estado: std_logic_vector(3 downto 0);
	signal s_medida : std_logic_vector(11 downto 0);

begin
	-- sinais mapeados
	db_echo <= echo;
	trigger <= s_trigger;
	
	U1_IH: interface_hcsr04 port map (clock, reset, s_medir_ed, echo, config_unidade,
												 s_trigger, s_medida, pronto, s_estado, db_tick);
	
	U2_ED: edge_detector port map (clock, medir, s_medir_ed);
	
	U3_HEX: hex7seg port map(s_estado, db_estado);
	
	U4_HEX: hex7seg port map(s_medida(3 downto 0), hex0);
	
	U5_HEX: hex7seg port map(s_medida(7 downto 4), hex1);
	
	U6_HEX: hex7seg port map(s_medida(11 downto 8), hex2);
end architecture;