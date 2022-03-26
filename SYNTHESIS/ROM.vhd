
LIBRARY ieee;
USE ieee.std_logic_1164.all;
library work;
use work.my_package.all;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY ROM IS
generic (
	          pic_width   : positive:=pic_width;
              pic_height  : positive:=pic_height;
              color_depth : positive:=color_depth;
				  mif_name    : string
	        );
	PORT
	(
		address		: in std_logic_vector (log_two(pic_height)-1 downto 0);
		clock		: IN STD_LOGIC  := '1';
		rden		: IN STD_LOGIC  := '1';
		q		    : out std_logic_vector (pic_width*color_depth-1 downto 0)
	);
END ROM;


ARCHITECTURE SYN OF rom IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (pic_width*color_depth-1 downto 0);

BEGIN
	q    <= sub_wire0(pic_width*color_depth-1 downto 0);

	altsyncram_component : altsyncram
	GENERIC MAP (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => mif_name,
		intended_device_family => "Cyclone IV E",
		lpm_hint => "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=NONE",
		lpm_type => "altsyncram",
		numwords_a => pic_height,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "CLOCK0",
		widthad_a => log_two(pic_height),
		width_a => pic_width*color_depth,
		width_byteena_a =>  (pic_width*color_depth)/8
	)
	PORT MAP (
		address_a => address,
		clock0 => clock,
		rden_a => rden,
		q_a => sub_wire0
	);



END SYN;

