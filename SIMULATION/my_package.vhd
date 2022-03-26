library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package my_package is
--------------------------------------------------------- 
constant pic_width   : positive := 256;
  constant pic_height  : positive := 256;
  constant color_depth : positive := 5;
constant mif_file_name_format: string := "x.mif";
   type     str_arr is array (0 to 2) of string(mif_file_name_format'range);
   constant mem_arr : str_arr := ("r.mif", "g.mif", "b.mif");
   type buff_row_type is array (natural range <>) of std_logic_vector((pic_width*color_depth+color_depth*2 -1) downto 0);
	--type rows3_type is array (2 downto 0) of buff_row_type;
	subtype rows3_type is buff_row_type(0 to 2);

	type matrix2d is array (0 to 2) of std_logic_vector(0 to 14);
	-------
	-----for the delay test
  type buff_row_type44 is array (natural range <>) of std_logic_vector((pic_width*color_depth-1) downto 0);

  -------
   ------
 type byte is
      (
         b000, b001, b002, b003, b004, b005, b006, b007,
         b008, b009, b010, b011, b012, b013, b014, b015,
         b016, b017, b018, b019, b020, b021, b022, b023,
         b024, b025, b026, b027, b028, b029, b030, b031,
         b032, b033, b034, b035, b036, b037, b038, b039,
         b040, b041, b042, b043, b044, b045, b046, b047,
         b048, b049, b050, b051, b052, b053, b054, b055,
         b056, b057, b058, b059, b060, b061, b062, b063,
         b064, b065, b066, b067, b068, b069, b070, b071,
         b072, b073, b074, b075, b076, b077, b078, b079,
         b080, b081, b082, b083, b084, b085, b086, b087,
         b088, b089, b090, b091, b092, b093, b094, b095,
         b096, b097, b098, b099, b100, b101, b102, b103,
         b104, b105, b106, b107, b108, b109, b110, b111,
         b112, b113, b114, b115, b116, b117, b118, b119,
         b120, b121, b122, b123, b124, b125, b126, b127,
         b128, b129, b130, b131, b132, b133, b134, b135,
         b136, b137, b138, b139, b140, b141, b142, b143,
         b144, b145, b146, b147, b148, b149, b150, b151,
         b152, b153, b154, b155, b156, b157, b158, b159,
         b160, b161, b162, b163, b164, b165, b166, b167,
         b168, b169, b170, b171, b172, b173, b174, b175,
         b176, b177, b178, b179, b180, b181, b182, b183,
         b184, b185, b186, b187, b188, b189, b190, b191,
         b192, b193, b194, b195, b196, b197, b198, b199,
         b200, b201, b202, b203, b204, b205, b206, b207,
         b208, b209, b210, b211, b212, b213, b214, b215,
         b216, b217, b218, b219, b220, b221, b222, b223,
         b224, b225, b226, b227, b228, b229, b230, b231,
         b232, b233, b234, b235, b236, b237, b238, b239,
         b240, b241, b242, b243, b244, b245, b246, b247,
         b248, b249, b250, b251, b252, b253, b254, b255
         );
   
    type bit_file is file of byte;
   
   constant inst_name_format: string := "XRAM";
   type     str_arr1 is array (0 to 2) of string(inst_name_format'range);
   constant inst_arr : str_arr1 := ("RRAM", "GRAM", "BRAM");
--------------------------------------------------------------------------------------------- 
function hamming_code_size (constant data_width : integer) return integer;-- calc how many parity bits needed for data length
 function pow_of_two(constant data: integer) return std_logic;
 function log_two(constant data: integer) return integer;
 function data_size_from_coded_hamming(constant code_width : integer) return integer;
 function g2b( Gray : std_logic_vector ) return std_logic_vector;
 function b2g( Binary : std_logic_vector ) return std_logic_vector;
 function median_row (arg : rows3_type) return std_logic_vector;
 function median_2d (arg : matrix2d) return std_logic_vector;
 function median(d : std_logic_vector(0 to 14)) return std_logic_vector;
 end package my_package;
 package body my_package is
 
		 function hamming_code_size (constant data_width : integer) return integer is
		 begin
		 for k in 0 to 31 loop
        if ((2**k)>=(data_width+k+1)) then
            return k;
        end if;
		  end loop;
		 return 0;
		 end function hamming_code_size;
		 
		 function pow_of_two(constant data: integer) return std_logic is
		 begin
		 for k in 0 to 31 loop
        if (2**k=data) then
            return '1';
        end if;
		  end loop;
			return '0';
		 end function pow_of_two;
		 
		function log_two(constant data: integer) return integer is
		begin
		 for k in 0 to 31 loop
                 if ((2**k)=(data)) then
                      return k;
                 end if;
		 end loop;
		 	
		 end function log_two;
		
	 function data_size_from_coded_hamming(constant code_width : integer) return integer is
		 begin
		 for k in 0 to 31 loop
        if (((2**k)-1)>=(code_width)) then
            return k;
        end if;
		  end loop;
		 return 0;
		 end function data_size_from_coded_hamming;
		 
		 function g2b( Gray : std_logic_vector ) return std_logic_vector is
    alias g : std_logic_vector(Gray'length-1 downto 0) is Gray;
    variable result : std_logic_vector(g'range);
  begin
    result(result'high) := g(g'high);

    for i in g'high-1 downto 0 loop
      result(i) := g(i) xor result(i+1);
    end loop;

  return result;
end function;


function b2g( Binary : std_logic_vector ) return std_logic_vector is
    alias b : std_logic_vector(Binary'length-1 downto 0) is Binary;
    variable result : std_logic_vector(b'range);
  begin
    result := b xor ('0' & b(b'high downto 1));

    return result;
  end function;
  -------
  function median(d : std_logic_vector(0 to 14)) return std_logic_vector is
         variable temp : std_logic_vector(4 downto 0);--pixel
      begin
         if (d(10 to 14) >= d(5 to 9) and d(10 to 14) <= d(0 to 4)) then
            temp:= d(10 to 14);
         elsif (d(10 to 14) >= d(0 to 4) and d(10 to 14) <= d(5 to 9)) then
            temp:= d(10 to 14);
         elsif (d(5 to 9) >= d(0 to 4) and d(5 to 9) <= d(10 to 14)) then
            temp:= d(5 to 9);
         elsif (d(5 to 9) >= d(10 to 14) and d(5 to 9) <= d(0 to 4)) then
            temp:= d(5 to 9);
         elsif (d(0 to 4) >= d(5 to 9) and d(0 to 4) <= d(10 to 14)) then
            temp:= d(0 to 4);
         elsif (d(0 to 4) >= d(10 to 14) and d(0 to 4) <= d(5 to 9)) then
            temp:= d(0 to 4);
         else
            temp:= d(0 to 4);
         end if;
         return temp;
      end function median;
  function median_2d (arg : matrix2d) return std_logic_vector is
      variable buff : std_logic_vector(0 to 14);
   begin
      for i in arg'range loop
         buff(5*i to 4+5*i):=median(arg(i));
      end loop;
      return median(buff);
   end function median_2d;
function median_row (arg : rows3_type) return std_logic_vector is
      variable t : std_logic_vector (0 to (pic_width*color_depth-1));
      variable curr_matrix : matrix2d;
   begin
      for i in 1 to pic_width loop
         for j in curr_matrix'range loop
           curr_matrix(j)(0 to 14):=arg(j)((5*i)+9 downto (5*i)-5);
         end loop;
         t((5*i)-5 to (5*i)-1):=median_2d(curr_matrix);
      end loop;
      return t;    
   end function median_row;
  
  
 end package body my_package;
 