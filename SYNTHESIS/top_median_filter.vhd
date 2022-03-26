library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.my_package.all;

entity top_median_filter is
port ( 
    clk		: in    std_logic; 
    rst		: in    std_logic; 
	 start	: in	std_logic;
	 done	   : out	std_logic
	);
attribute altera_chip_pin_lc : string;
attribute altera_chip_pin_lc of clk  : signal is "Y2";
attribute altera_chip_pin_lc of rst  : signal is "AB28";
attribute altera_chip_pin_lc of start: signal is "AC28";
attribute altera_chip_pin_lc of done : signal is "E21";
end entity top_median_filter;

architecture arc_top of top_median_filter is
	
signal re_sig			: std_logic;	
signal read_addr_sig	: std_logic_vector(log_two(pic_height)-1 downto 0);	
signal push_sig		: std_logic;	
signal we_sig			: std_logic;	
signal write_addr_sig: std_logic_vector(log_two(pic_height)-1 downto 0);	

begin

	g1: for i in 0 to 2 generate
		color_units_generation:entity work.color_unit
		generic map ( mif_name		=>	mem_arr(i),
					  instant_name	=> inst_arr(i)
					)
		port map (clk			=>	clk,
					rst			=>	rst,
					Read_en		=>	re_sig,
					Read_addr	=>	read_addr_sig,
					push	   	=>	push_sig,
					Write_en		=>	we_sig,
					Write_addr	=>	write_addr_sig
				  );
		end generate g1;
		
	control_unit_component:entity work.control_unit
	   port map (
		clk			=>	clk,
		rst			=>	rst,
		push		   =>	push_sig,		
		start		   =>	start,		
		done		   =>	done,		
		Read_addr	=>	read_addr_sig,	
		Read_en		=>	re_sig,		
		Write_addr	=>	write_addr_sig,
		Write_en		=>	we_sig			
		);
		
end architecture arc_top;