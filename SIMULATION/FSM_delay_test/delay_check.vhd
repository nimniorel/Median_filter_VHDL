library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.my_package.all;

entity delay_check is
	port(-- Read_en		:	in	std_logic;
		  --Read_addr		:	in	std_logic_vector(log_two(pic_height)-1 downto 0);
		  --push			:	in	std_logic;
			s_Write_en:out std_logic;
			s_processed_row	:out	std_logic_vector ((pic_width*color_depth-1) downto 0);
			s_Write_addr	:	out	std_logic_vector(log_two(pic_height)-1 downto 0);
			s_buff:out buff_row_type44 (0 to 2);	
		  clk, rst		:	in	std_logic;
		  start        :  in std_logic;
		  done         :out std_logic
		 );
end entity delay_check;

architecture data_flow of delay_check is
signal   buff				:  buff_row_type44 (0 to 2);				
signal	current_row	   :	std_logic_vector ((pic_width*color_depth-1) downto 0);
signal	processed_row	:	std_logic_vector ((pic_width*color_depth-1) downto 0);
signal	s_push	      :	std_logic_vector(3 downto 0);
signal 	push				 :std_logic;
signal  Read_addr: std_logic_vector(log_two(pic_height)-1 downto 0);
signal Write_en		:		std_logic;
signal Read_en:std_logic;
signal Write_addr	:		std_logic_vector(log_two(pic_height)-1 downto 0);
begin
----rom
	gen_rom: entity work.ROM
		generic map(mif_name	=>"test.mif",
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
		generic map (inst_name => "CHECKRAM",
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
control_unit_component:entity work.control_unit
	   port map (
		clk			=>	clk,
		rst			=>	rst,
		push		   =>	push,		
		start		   =>	start,		
		done		   =>	done,		
		Read_addr	=>	Read_addr,	
		Read_en		=>	Read_en,		
		Write_addr	=>	Write_addr,
		Write_en		=>	Write_en			
		);
------buffer
process (clk,rst) is
variable t : std_logic_vector(1279 downto 0);
begin
	if(rst='1') then	
		buff<=(others=>(others=>'1'));
    elsif rising_edge(clk) then
	 t:= current_row ;
		s_push <= s_push(2 downto 0)&push;
		if(s_push(2)='1') then	
			buff<= buff(1 to 2) & t ;
		end if;
	end if;
end process;
-----filter
processed_row<=buff(1);
s_Write_en<=Write_en;
s_processed_row<=processed_row;
s_Write_addr<=Write_addr;
s_buff<=buff;
end architecture data_flow;
