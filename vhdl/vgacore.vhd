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
-------------------------------------------------------------------------------
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
    ram_data_b    : in  unsigned(11 downto 0);
    rom_address   : out unsigned(8 downto 0);
    rom_data      : in  unsigned(7 downto 0);
    strobe        : out std_logic;      -- activate serializer
    row_data      : out unsigned(7 downto 0);  -- data to send to serializer
    pixel         : in  std_logic       -- bit data coming back from serializer
    );
end vga_core;

architecture behavioral of vga_core is

  
  signal   hcounter             : unsigned(9 downto 0)  := (others => '0');
  signal   vcounter             : unsigned(9 downto 0)  := (others => '0');
  signal   pixelcount_w         : unsigned(2 downto 0)  := (others => '0');
  signal   row_count            : unsigned(2 downto 0)  := (others => '0');
  signal   cell                 : unsigned(12 downto 0) := (others => '0');
  signal   x                    : unsigned(9 downto 0)  := (others => '0');
  signal   y                    : unsigned(8 downto 0)  := (others => '0');
  signal   x_temp               : unsigned(6 downto 0)  := (others => '0');
  signal   y_temp               : unsigned(5 downto 0)  := (others => '0');
  signal   hs_out_signal        : std_logic             := '0';
  signal   vs_out_signal        : std_logic             := '0';
  signal   ram_address_b_signal : unsigned(12 downto 0) := (others => '0');
  signal   rom_address_signal   : unsigned(8 downto 0)  := (others => '0');
  signal   strobe_signal        : std_logic             := '0';
  signal   row_data_signal      : unsigned(7 downto 0)  := (others => '0');
  signal   red, green           : std_logic             := '0';
  signal   blue                 : std_logic             := '0';
  constant HB                   : integer               := 48;
  constant HF                   : integer               := 16;
  constant HS                   : integer               := 96;
  constant HD                   : integer               := 640;
  constant VB                   : integer               := 33;
  constant VF                   : integer               := 10;
  constant VS                   : integer               := 2;
  constant VD                   : integer               := 480;


begin

  red_out       <= red;
  green_out     <= green;
  blue_out      <= blue;
  hs_out        <= hs_out_signal;
  vs_out        <= vs_out_signal;
  ram_address_b <= ram_address_b_signal;
  rom_address   <= rom_address_signal;
  strobe        <= strobe_signal;
  row_data      <= row_data_signal;


  p_vga_signals : process (clk25, ext_reset)
  begin
    if ext_reset = '1' then                 -- asynchronous reset (active high)
      hcounter      <= (others => '0');
      vcounter      <= (others => '0');
      hs_out_signal <= '0';
      vs_out_signal <= '0';
      row_count     <= (others => '0');
    elsif clk25'event and clk25 = '1' then  -- rising clock edge
      -- increment counters
      if (to_integer(hcounter) < 799) then
        hcounter <= hcounter + 1;
      else
        hcounter <= (others => '0');
        if (to_integer(vcounter) < 523) then
          if (to_integer(vcounter) > (VB + VS)) then
            row_count <= row_count + 1;
            if row_count = "111" then
              row_count <= (others => '0');
            end if;
          end if;
          vcounter <= vcounter + 1;
        else
          vcounter  <= (others => '0');
          row_count <= (others => '0');
        end if;
      end if;
    end if;


    -- displays pixel data, in blue colour
    if (to_integer(hcounter) > (HB + HS))
      and (to_integer(hcounter) < (HB + HS + HD))
      and (to_integer(vcounter) > (VB + VS))
      and (to_integer(vcounter) < (VB + VS + VD))
    then
      red   <= '0';
      green <= '0';
      blue  <= pixel;
    else
      red   <= '0';
      green <= '0';
      blue  <= '0';
    end if;


    -- define synch pulse's
    if (to_integer(hcounter) > HB) and
      (to_integer(hcounter) < (HB + HS)) then
      hs_out_signal <= '0';
    else
      hs_out_signal <= '1';
    end if;


    if (to_integer(vcounter) > VB) and
      (to_integer(vcounter) < (VB + VS)) then
      vs_out_signal <= '0';
    else
      vs_out_signal <= '1';
    end if;


    x      <= to_unsigned(to_integer(hcounter) - (HB + HS), x'length);
    y      <= to_unsigned(to_integer(vcounter) - (VB + VS), y'length);
    x_temp <= x(9 downto 3);
    y_temp <= y(8 downto 3);

    if (to_integer(x) < 1) and (to_integer(y) < 1) then
      cell <= (others => '0');
    else
      cell <= to_unsigned(((to_integer(x_temp)) + (to_integer(y_temp) * 80)), cell'length);
    end if;
    
  end process p_vga_signals;







  p_strobe : process(clk25, ext_reset)
  begin
    if ext_reset = '1' then             -- asynchronous reset (active high)
      strobe_signal        <= '0';
      ram_address_b_signal <= (others => '0');
      rom_address_signal   <= (others => '0');
      row_data_signal      <= (others => '0');
    elsif clk25'event and clk25 = '1' then
      
      if (to_integer(hcounter) = 154) and (to_integer(vcounter) = 43) then
        strobe_signal        <= '0';
        ram_address_b_signal <= (others => '0');
      elsif (to_integer(hcounter) = 155) and (to_integer(vcounter) = 43) then
        strobe_signal      <= '0';
        rom_address_signal <= to_unsigned(to_integer(ram_data_b(8 downto 0)) + to_integer(row_count), rom_address'length);
      elsif (to_integer(hcounter) = 156) and (to_integer(vcounter) = 43) then
        strobe_signal   <= '0';
        row_data_signal <= rom_data;
      elsif (to_integer(hcounter) = 162) and (to_integer(vcounter) = 43) then
        strobe_signal <= '1';
      end if;

      if pixelcount_w = "111" then
        strobe_signal <= '1';
      elsif pixelcount_w < "100" then
        strobe_signal        <= '0';
        ram_address_b_signal <= to_unsigned((to_integer(cell)), ram_address_b'length);
      elsif pixelcount_w = "100" then
        strobe_signal      <= '0';
        rom_address_signal <= to_unsigned(to_integer(ram_data_b(8 downto 0)) + to_integer(row_count), rom_address'length);
      elsif pixelcount_w = "101" then
        strobe_signal   <= '0';
        row_data_signal <= rom_data;
      end if;
    end if;
  end process;


  p_pixelcount : process (clk25, ext_reset)
  begin
    if ext_reset = '1' then
      pixelcount_w <= (others => '0');

    elsif clk25'event and clk25 = '1' then
      if (to_integer(hcounter) < (HB + HS))
        or (to_integer(vcounter) < (VB + VS)) then
        pixelcount_w <= (others => '0');
      else
        pixelcount_w <= pixelcount_w + 1;
      end if;
    end if;
  end process;




end behavioral;

