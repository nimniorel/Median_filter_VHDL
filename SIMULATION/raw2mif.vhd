library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use ieee.std_logic_textio.all;
library work;
use work.img_proc_pack.all;
-------------------------------------------------------------------------------
entity raw2mif is
   generic
      (pic_width      : integer := pic_width;
       pic_height     : integer := pic_height;
       file_path      : string  := "C:\quartusProj\AVHDLprojet\";
       mif_file_path  : string  := "C:\quartusProj\AVHDLprojet\";
       pic_file_name  : string  := "lena_005noise_256x256.raw";
       rmif_file_name : string  := "r.mif";
       gmif_file_name : string  := "g.mif";
       bmif_file_name : string  := "b.mif";
       color_depth    : integer := color_depth
       );
end entity raw2mif;
-------------------------------------------------------------------------------
architecture arc_raw2mif of raw2mif is
begin
   process is
      type     bit_file is file of byte;
      file pic_source              : bit_file open read_mode is file_path & pic_file_name;
      file mif_r, mif_g, mif_b     : text;
      variable curr_color           : byte;
      variable line_r, line_g, line_b : line;
      variable r, g, b : std_logic_vector(7 downto 0);
      variable status_r, status_g, status_b      : file_open_status;
   begin
      file_open(status_r, mif_r, mif_file_path & rmif_file_name, write_mode);
      assert (status_r = open_ok)
         report "file creating failure" & time'image(now)
         severity failure;
      assert (status_r /= open_ok)
         report "file rmif is opened"
         severity note;
      file_open(status_g, mif_g, mif_file_path & gmif_file_name, write_mode);
      assert (status_g = open_ok)
         report "file creating failure" & time'image(now)
         severity failure;
      assert (status_g /= open_ok)
         report "file gmif is opened"
         severity note;
      file_open(status_b, mif_b, mif_file_path & bmif_file_name, write_mode);
      assert (status_r = open_ok)
         report "file creating failure" & time'image(now)
         severity failure;
      assert (status_b /= open_ok)
         report "file bmif is opened"
         severity note;

      write(line_r, string'("WIDTH=") & integer'image(color_depth*pic_width) & string'(";"));
      writeline(mif_r, line_r);
      write(line_r, string'("DEPTH=") & integer'image(pic_height) & string'(";"));
      writeline(mif_r, line_r);
      write(line_r, string'("ADDRESS_RADIX = BIN;"));
      writeline(mif_r, line_r);
      write(line_r, string'("DATA_RADIX = BIN;"));
      writeline(mif_r, line_r);
      write(line_r, string'("CONTENT"));
      writeline(mif_r, line_r);
      write(line_r, string'("BEGIN"));
      writeline(mif_r, line_r);

      write(line_g, string'("WIDTH=") & integer'image(color_depth*pic_width) & string'(";"));
      writeline(mif_g, line_g);
      write(line_g, string'("DEPTH=") & integer'image(pic_height) & string'(";"));
      writeline(mif_g, line_g);
      write(line_g, string'("ADDRESS_RADIX = BIN;"));
      writeline(mif_g, line_g);
      write(line_g, string'("DATA_RADIX = BIN;"));
      writeline(mif_g, line_g);
      write(line_g, string'("CONTENT"));
      writeline(mif_g, line_g);
      write(line_g, string'("BEGIN"));
      writeline(mif_g, line_g);

      write(line_b, string'("WIDTH=") & integer'image(color_depth*pic_width) & string'(";"));
      writeline(mif_b, line_b);
      write(line_b, string'("DEPTH=") & integer'image(pic_height) & string'(";"));
      writeline(mif_b, line_b);
      write(line_b, string'("ADDRESS_RADIX = BIN;"));
      writeline(mif_b, line_b);
      write(line_b, string'("DATA_RADIX = BIN;"));
      writeline(mif_b, line_b);
      write(line_b, string'("CONTENT"));
      writeline(mif_b, line_b);
      write(line_b, string'("BEGIN"));
      writeline(mif_b, line_b); 
      
      l1 : for i in 0 to (pic_height-1) loop
          write(line_r, conv_std_logic_vector(i,8));
          write(line_r, string'(" : "));
          write(line_g, conv_std_logic_vector(i,8));
          write(line_g, string'(" : "));
          write(line_b, conv_std_logic_vector(i,8));
          write(line_b, string'(" : "));
         l2 : for j in 0 to (pic_width-1) loop
            l3 : for k in 0 to 2 loop
               exit l1 when endfile(pic_source);
               read(pic_source, curr_color);
               case k is
                  when 0 => r := conv_std_logic_vector(byte'pos(curr_color), r'length);
                  when 1 => g := conv_std_logic_vector(byte'pos(curr_color), g'length);
                  when 2 => b := conv_std_logic_vector(byte'pos(curr_color), b'length);
               end case;
            end loop l3;
            write(line_r, r(r'left downto ((r'left-color_depth)+1)));
            write(line_g, g(g'left downto ((g'left-color_depth)+1)));
            write(line_b, b(b'left downto ((b'left-color_depth)+1)));       
         end loop l2;
         write(line_r, string'(";"));
         writeline(mif_r, line_r);
         write(line_g, string'(";"));
         writeline(mif_g, line_g);
         write(line_b, string'(";"));
         writeline(mif_b, line_b);
      end loop l1;
      write(line_r, string'("END;"));
      writeline(mif_r, line_r);
      write(line_g, string'("END;"));
      writeline(mif_g, line_g);
      write(line_b, string'("END;"));
      writeline(mif_b, line_b);
      file_close(mif_r);
      file_close(mif_g);
      file_close(mif_b);
      assert (false)
         report "Destination files at " & mif_file_path & " are created"
         severity note;
      file_close(pic_source);
      assert (false)
         report "Original file " & file_path & pic_file_name & " is closed"
         severity note;
      wait;
   end process;
end architecture arc_raw2mif;
