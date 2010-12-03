--------------------------------------------------------------------------------
-- Module Name: VGA - behavioral
--
-- Author: Aaron Storey
-- 
-- Description: This module checks the Video Ram for the state of each 'cell'
-- the monitor is generating and rerieves the pixel data from a character ROM
-- 
-- 
-- Dependencies: VRAM, SHFTREG and CHROM modules.
-- 
-- 
-- Reference Material:
-- VGATEST vhdl authored by :
-- Company: Department of Computer Science, University of Texas at San Antonio
-- Engineer: Chia-Tien Dan Lo (danlo@cs.utsa.edu)
-- 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;


entity vga_core is
  port(
    clk25         : in  std_logic;
    ext_reset     : in  std_logic;
    red_out       : out std_logic;
    green_out     : out std_logic;
    blue_out      : out std_logic;
    hs_out        : out std_logic;
    vs_out        : out std_logic;
    ram_address_b : out unsigned(12 downto 0);
    ram_data_b    : in  unsigned(15 downto 0);
    rom_address   : out unsigned(8 downto 0);
    rom_data      : in  unsigned(7 downto 0);
    strobe        : out std_logic;
    row_data      : out unsigned(7 downto 0);
    pixel         : in  std_logic;
    colour_in     : in  unsigned(1 downto 0);
    );
end vga_core;

architecture behavioral of vga_core is

  
  signal hcounter     : unsigned(9 downto 0);  --1100100000 is 800
  signal vcounter     : unsigned(9 downto 0);  --1000001001 is 521
  signal pixelcount_w : unsigned(2 downto 0);  -- 8 pixels wide for each cell.
  signal row_count    : unsigned(2 downto 0)  := "000";  -- 8 pixels deep for each cell.
  signal next_row     : std_logic_vector(7 downto 0);
  signal cell         : unsigned(12 downto 0) := "0000000000000";
  signal x            : unsigned(9 downto 0);
  signal y            : unsigned(9 downto 0);
  signal x_temp       : unsigned(9 downto 0);
  signal y_temp       : unsigned(9 downto 0);




  signal hs_out_int, vs_out_int : std_logic;

begin

  cellupdate : process (clk25, x, y)
  begin

    x_temp <= "000" & x(9 downto 3);
    y_temp <= "000" & y(9 downto 3);
    cell   <= to_unsigned(((to_integer(x_temp)) + (to_integer(y_temp) * 80)), cell'length);
    if (to_integer(hcounter) < 144) and (to_integer(vcounter) < 39) then
      cell <= (others => '0');
    end if;


  end process;

  p2 : process (clk25)

  begin
    -- hcounter counts from 0 to 799
    -- vcounter counts from 0 to 520
    -- x coordinate: 0 - 639 (x = hcounter - 144, i.e., hcounter -Tpw-Tbp)
    -- y coordinate: 0 - 479 (y = vcounter - 31, i.e., vcounter-Tpw-Tbp)

    if clk25'event and clk25 = '1' then
      -- To draw a pixel in (x0, y0), simply test if the ray trace to it
      -- and set its color to any value between 1 to 7. The following example simply sets
      -- the whole display area to a single-color wash, which is changed every one
      -- second.

      x <= to_unsigned((to_integer(hcounter) - 144), x'length);
      y <= to_unsigned((to_integer(vcounter) - 39), y'length);

      if (to_integer(hcounter) >= 144)    -- 144
        and (to_integer(hcounter) < 784)  -- 784
        and (to_integer(vcounter) >= 39)  -- 39
        and (to_integer(vcounter) < 519)  -- 519
      then
        if (colour_in = "00") then
          red_out   <= '0';
          green_out <= '0';
          blue_out  <= pixel;
        elsif (colour_in = "01") then
          red_out   <= pixel;
          green_out <= '0';
          blue_out  <= '0';
        elsif (colour_in = "10") then
          red_out   <= '0';
          green_out <= pixel;
          blue_out  <= '0';
        elsif (colour_in = "11") then
          red_out   <= pixel;
          green_out <= pixel;
          blue_out  <= '0';
        end if;
      else
        red_out   <= '0';
        green_out <= '0';
        blue_out  <= '0';
      end if;
      -- Here is the timing for horizontal synchronization.
      -- (Refer to p. 24, Xilinx, Spartan-3 Starter Kit Board User Guide)
      -- Pulse width: Tpw = 96 cycles @ 25 MHz
      -- Back porch: Tbp = 48 cycles
      -- Display time: Tdisp = 640 cycles
      -- Front porch: Tfp = 16 cycles
      -- Sync pulse time (total cycles) Ts = 800 cycles

      if (to_integer(hcounter) > 0)
        and (to_integer(hcounter) < 93)  -- 96+1
      then
        hs_out_int <= '0';
      else
        hs_out_int <= '1';
      end if;
      -- Here is the timing for vertical synchronization.
      -- (Refer to p. 24, Xilinx, Spartan-3 Starter Kit Board User Guide)
      -- Pulse width: Tpw = 1600 cycles (2 lines) @ 25 MHz
      -- Back porch: Tbp = 23200 cycles (29 lines)
      -- Display time: Tdisp = 38400 cycles (480 lines)
      -- Front porch: Tfp = 8000 cycles (10 lines)
      -- Sync pulse time (total cycles) Ts = 416800 cycles (521 lines)
      if (to_integer(vcounter) > 0)
        and (to_integer(vcounter) < 3)   -- 2+1
      then
        vs_out_int <= '0';
      else
        vs_out_int <= '1';
      end if;
      -- horizontal counts from 0 to 799 , checks if it has counted to 800
      hcounter <= hcounter+1;
      if (to_integer(hcounter) = 800) then
        vcounter  <= vcounter+1;
        hcounter  <= (others => '0');
        row_count <= row_count + 1;
        if (to_integer(row_count) = 8) then
          row_count <= (others => '0');
        end if;
      end if;
      if (to_integer(vcounter) = 521) then
        vcounter  <= (others => '0');
        row_count <= (others => '0');
      end if;



    end if;

  end process;

  p_strobe : process(clk25, pixelcount_w, rom_data, ram_data_b)
  begin
    if clk25'event and clk25 = '1' then

      if (to_integer(hcounter) = 140) and (to_integer(vcounter) < 39) then
        strobe        <= '0';
        ram_address_b <= to_unsigned((to_integer(cell)), ram_address_b'length);
      elsif (to_integer(hcounter) = 141) and (to_integer(vcounter) < 39) then
        strobe      <= '0';
        rom_address <= to_unsigned(to_integer(ram_data_b(8 downto 0)) + to_integer(row_count), rom_address'length);
      elsif (to_integer(hcounter) = 142) and (to_integer(vcounter) < 39) then
        strobe   <= '0';
        row_data <= rom_data;
      elsif (to_integer(hcounter) = 143) and (to_integer(vcounter) < 39) then
        strobe <= '1';
      end if;

      if pixelcount_w = "111" then
        strobe <= '1';
      elsif pixelcount_w < "100" then
        strobe        <= '0';
        ram_address_b <= to_unsigned((to_integer(cell)), ram_address_b'length);
      elsif pixelcount_w = "100" then
        strobe      <= '0';
        rom_address <= to_unsigned(to_integer(ram_data_b(8 downto 0)) + to_integer(row_count), rom_address'length);
      elsif pixelcount_w = "101" then
        strobe   <= '0';
        row_data <= rom_data;
      end if;
    end if;
  end process;

  vs_out <= vs_out_int;
  hs_out <= hs_out_int;




  p_pixelcount : process (clk25, ext_reset)
  begin
    if ext_reset = '1' then
      pixelcount_w <= (others => '0');

    elsif clk25'event and clk25 = '1' then
      if hs_out_int = '0' or vs_out_int = '0' then
        pixelcount_w <= (others => '0');
      else
        pixelcount_w <= pixelcount_w + 1;
      end if;
    end if;

  end process;



end behavioral;

