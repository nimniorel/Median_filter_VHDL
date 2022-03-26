library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.my_package.all;

entity control_unit is
   port
      (
	  clk,rst	: in std_logic;
	  start		: in std_logic;
	  push		: out std_logic;
	  done		: out std_logic := '0';
	  Read_addr	: out std_logic_vector(log_two(pic_height)-1 downto 0);
	  Read_en   : out std_logic;
	  Write_addr: out std_logic_vector(log_two(pic_height)-1 downto 0);
	  Write_en	: out std_logic		
       );
end entity control_unit;

architecture arc_control_unit of control_unit is 
type state is (idle,first_read_fisrt_row,second_read_fisrt_row,processing,processing_last_row,finish);
signal c_s, n_s	: state;
signal rom_adr_cnt					: std_logic_vector(log_two(pic_height)-1 downto 0) := (others=>'0');
signal ram_adr_cnt					: std_logic_vector(log_two(pic_height)-1 downto 0) := (others=>'0');
signal full, counter_en_rom				: std_logic := '0';-- counter enable
signal we_sig			: std_logic ;
signal re_sig					: std_logic ;
signal we_delay : std_logic_vector (4 downto 0);

begin

 process(clk,rst)
	begin
	if(rst='1') then 
		c_s	<= idle;	
		ram_adr_cnt		<=(others=>'0');
		rom_adr_cnt		<=(others=>'0');
		full		<='0';
      we_delay<=(others=>'0');
	elsif rising_edge(clk) then
      we_delay<= we_delay(3 downto 0) & we_sig;
		
		c_s	<= n_s;
		ram_adr_cnt		<= ram_adr_cnt + we_delay(2);
		rom_adr_cnt		<= rom_adr_cnt + counter_en_rom;
		if (conv_integer(unsigned(rom_adr_cnt)) = 254) then
			full		<= '1';
		end if;
	end if;	
end process;	

process (c_s, start, full)
	begin
			n_s	   <= c_s;
     		done		<= '0';
			push		<= '0';
			re_sig	<= '0';
			we_sig	<= '0';
			counter_en_rom		<= '1';
	case c_s is
			when idle =>
			counter_en_rom <= '0';
			if (start = '1') then 	
					n_s	<= first_read_fisrt_row;	
			end if;
			
			when first_read_fisrt_row => 
					push		<= '1';
					counter_en_rom		<= '0';
					re_sig		<= '1';
					n_s	<= second_read_fisrt_row;		
					
			when second_read_fisrt_row => 
					push		<= '1';
					counter_en_rom		<= '1'; 
					re_sig		<= '1';
					n_s	<= processing;	
					
			when processing => 
					push		<= '1';
					counter_en_rom		<= '1';
					re_sig		<= '1';
				if (rom_adr_cnt > x"00") then
					we_sig		<= '1';
				end if;	
				if (full = '1') then
					n_s	<= processing_last_row;
					counter_en_rom			<= '0';
				end if;
				
			when processing_last_row =>
					counter_en_rom	<= '0';
					re_sig		<= '1';
					n_s	      <= finish;
					we_sig		<= '1';
					push		   <= '1';
					
			when finish =>
					done		   <= '1';
					push		   <= '0';
					re_sig		<= '0';
					we_sig		<= '0';
		end case;		
end process;

Read_addr	<= rom_adr_cnt;
Write_addr	<= ram_adr_cnt;
Read_en		<= re_sig;
Write_en    <= we_delay(2);

end architecture arc_control_unit;