-----------------Laboratorio Digital-------------------------------------
-- Arquivo   : memoria_palavras.vhd
-- Projeto   : Semana 3 - Porta Inteligente
-------------------------------------------------------------------------
-- Descricao : Memoria para as palavras ENTROU/SAIU
--
-- adaptado a partir do codigo my_4t1_mux.vhd do livro "Free Range VHDL" 
-------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     26/09/2021  1.0     Edson Midorikawa  criacao
-------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memoria_palavras is
    port ( 
       SEL:       in  std_logic_vector (1 downto 0);
       C5 :       out std_logic_vector (7 downto 0);
		 C4 :       out std_logic_vector (7 downto 0);
       C3 :       out std_logic_vector (7 downto 0);
		 C2 :       out std_logic_vector (7 downto 0);
       C1 :       out std_logic_vector (7 downto 0);
		 C0 :       out std_logic_vector (7 downto 0)
    );
end entity;

architecture behav of memoria_palavras is

	type memoria_4x8 is array (integer range 0 to 3) of std_logic_vector(7 downto 0);
		constant caractere5: memoria_4x8 := (
			"00100000", -- Espaço em branco
			"01000101", -- E
			"00100000", -- Espaço em branco
			"00100000"  -- Espaço em branco
		);
		
		constant caractere4: memoria_4x8 := (
			"01001110", -- N
			"01001110", -- N
			"01010011", -- S
			"01000001"  -- A
		);
		
		constant caractere3: memoria_4x8 := (
			"01000001", -- A
			"01010100", -- T
			"01000001", -- A
			"01001101"  -- M
		);
		
		constant caractere2: memoria_4x8 := (
			"01000100", -- D
			"01010010", -- R
			"01001001", -- I
			"01000010"  -- B
		);
		
		constant caractere1: memoria_4x8 := (
			"01000001", -- A
			"01001111", -- O
			"01010010", -- R
			"01001111"  -- O
		);
		
		constant Caractere0: memoria_4x8 := (
			"00100000", -- Espaço em branco
			"01010010", -- R
			"00100000", -- Espaço em branco
			"01010011"  -- S
		);
	
begin
    C5 <= caractere5(to_integer(unsigned(SEL)));
			 
    C4 <= caractere4(to_integer(unsigned(SEL)));
			 
    C3 <= caractere3(to_integer(unsigned(SEL)));
			 
    C2 <= caractere2(to_integer(unsigned(SEL)));
		
    C1 <= caractere1(to_integer(unsigned(SEL)));
			 
    C0 <= caractere0(to_integer(unsigned(SEL)));
	 
end behav;
