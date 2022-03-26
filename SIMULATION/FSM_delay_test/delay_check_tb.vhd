library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.my_package.all;

entity delay_check_tb is
port( done	:	out std_logic);
end entity delay_check_tb;

architecture arc_delay_check_tb of delay_check_tb is
signal clk	:	std_logic := '0';
signal rst	:	std_logic := '1';
signal start	: 	 std_logic := '0'; 
signal s_Write_en :std_logic;
signal s_processed_row:std_logic_vector(1279 downto 0);
signal s_Write_addr:std_logic_vector(7 downto 0);
signal   s_buff				:  buff_row_type44 (0 to 2);				

begin
	filter: entity work.delay_check
		port map(
			clk		=>	clk,
			rst 	=>	rst,
			done	=>	done,
			start	=>	start,
			s_Write_en=>s_Write_en,
			s_processed_row=>s_processed_row,
			s_Write_addr=>s_Write_addr,
			s_buff=>s_buff
				);
	clk <= not clk after 5 ns;
	rst <= '0' after 2 ns;
	start <= '1' after 4 ns;
end architecture arc_delay_check_tb;	
