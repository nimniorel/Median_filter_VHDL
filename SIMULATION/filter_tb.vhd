library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.my_package.all;

entity filter_tb is
port( done	:	out std_logic);
end entity filter_tb;

architecture arc_filter_tb of filter_tb is
signal clk	:	std_logic := '0';
signal rst	:	std_logic := '1';
signal start	: 	 std_logic := '0'; 
begin
	filter: entity work.top_median_filter
		port map(
			clk		=>	clk,
			rst 	=>	rst,
			done	=>	done,
			start	=>	start
				);
	clk <= not clk after 5 ns;
	rst <= '0' after 1 ns;
	start <= '1' after 4 ns;
end architecture arc_filter_tb;	
