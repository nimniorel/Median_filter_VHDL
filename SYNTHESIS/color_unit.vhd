library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.my_package.all;

entity color_unit is
	generic( mif_name		   :	string:="x.mif";
				instant_name	:	string:="RRAM"
			);
	port( Read_en		:	in	std_logic;
		  Read_addr		:	in	std_logic_vector(log_two(pic_height)-1 downto 0);
		  push			:	in	std_logic;
		  Write_en		:	in	std_logic;
		  Write_addr	:	in	std_logic_vector(log_two(pic_height)-1 downto 0);
		  clk, rst		:	in	std_logic
		 );
end entity color_unit;

architecture data_flow of color_unit is
signal   buff				:  buff_row_type (0 to 2);				
signal	current_row	   :	std_logic_vector ((pic_width*color_depth-1) downto 0);
signal	processed_row	:	std_logic_vector ((pic_width*color_depth-1) downto 0);
signal	s_push	      :	std_logic_vector(3 downto 0);
begin
----rom
	gen_rom: entity work.ROM
		generic map(mif_name	=>mif_name,
						pic_width=>pic_width,
						pic_height=>pic_height,
						color_depth=>color_depth
	               )
		port map(
			clock	=>	clk,
			rden =>Read_en,
			address	=>	Read_addr,
			q		=>	current_row
				);

----ram
	gen_ram: entity work.RAM
		generic map (inst_name => instant_name,
						pic_width=>pic_width,
						pic_height=>pic_height,
						color_depth=>color_depth)
		port map(
			clock	=>	clk,
			address	=>	Write_addr,
			data	=>	processed_row,
			wren	=>	Write_en,
			q		=> OPEN 	
				);
------buffer
process (clk,rst) is
variable t : std_logic_vector(buff(buff'left)'range);
begin
	if(rst='1') then	
		buff<=(others=>(others=>'0'));
    elsif rising_edge(clk) then
	 t:=(current_row(1279 downto 1275) & current_row & current_row(4 downto 0));
		s_push <= s_push(2 downto 0)&push;
		if(s_push(2)='1') then	
			buff<= buff(1 to 2) & t ;
		end if;
	end if;
end process;
-----filter
processed_row<=median_row(buff);
end architecture data_flow;
