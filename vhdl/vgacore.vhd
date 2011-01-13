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
  constant HB                   : integer               := 38;
  constant HF                   : integer               := 26;
  constant HS                   : integer               := 96;
  constant HD                   : integer               := 640;
  constant VB                   : integer               := 33;
  constant VF                   : integer               := 10;
  constant VS                   : integer               := 2;
  constant VD                   : integer               := 480;
  constant H_WIDTH              : integer               := HB+HF+HS+HD-1;  -- screen counter horizontal
  constant V_WIDTH              : integer               := VB+VF+VS+VD-1;  -- screen counter vertical


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



  p_row_counter : process (clk25, ext_reset)
  begin  -- process p_row_counter
    if ext_reset = '1' then                 -- asynchronous reset (active high)
      row_count <= (others => '0');
    elsif clk25'event and clk25 = '1' then  -- rising clock edge
      --increment row_count
      if (to_integer(hcounter) = (H_WIDTH-8))
        and (to_integer(vcounter) > (VS+VB-2)) then
        row_count <= row_count + 1;
      end if;
    end if;
  end process p_row_counter;


  p_vga_signals : process (clk25, ext_reset)
  begin
    if ext_reset = '1' then                 -- asynchronous reset (active high)
      hcounter      <= (others => '0');
      vcounter      <= (others => '0');
      hs_out_signal <= '0';
      vs_out_signal <= '0';
    elsif clk25'event and clk25 = '1' then  -- rising clock edge
      -- increment counters
      if (to_integer(hcounter) < H_WIDTH) then
        hcounter <= hcounter + 1;
      else
        if (to_integer(vcounter) < V_WIDTH) then
          vcounter <= vcounter + 1;
        else
          vcounter <= (others => '0');
        end if;
        hcounter <= (others => '0');
      end if;


      -- displays pixel data, in blue colour
      if (to_integer(hcounter) > (HB + HS - 1))
        and (to_integer(hcounter) < (HB + HS + HD))
        and (to_integer(vcounter) > (VB + VS - 1))
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
      if (to_integer(hcounter) > HB - 1) and
        (to_integer(hcounter) < (HB + HS - 1)) then
        hs_out_signal <= '0';
      else
        hs_out_signal <= '1';
      end if;


      if (to_integer(vcounter) > VB - 1) and
        (to_integer(vcounter) < (VB + VS - 1)) then
        vs_out_signal <= '0';
      else
        vs_out_signal <= '1';
      end if;
    end if;
  end process p_vga_signals;



  p_cell_counter : process (hcounter, vcounter, pixelcount_w)
  begin  -- process p_cell_counter
    if ext_reset = '1' then
      cell <= (others => '0');
    else
      if (to_integer(hcounter) > (HB+HS-2))
        and (to_integer(hcounter) < (HB+HS+HD))
        and (to_integer(vcounter) < (VB+VS+VD))
        and (to_integer(vcounter) > (VS+VB-2)) then
        if pixelcount_w = "000" then
          if (to_integer(cell) < 4799) then
            cell <= cell + 1;
          else
            cell <= (others => '0');
          end if;
        end if;
      end if;
    end if;
  end process p_cell_counter;



  p_strobe : process(clk25, ext_reset)
  begin
    if ext_reset = '1' then             -- asynchronous reset (active high)
      strobe_signal        <= '0';
      ram_address_b_signal <= (others => '0');
      rom_address_signal   <= (others => '0');
      row_data_signal      <= (others => '0');
    elsif clk25'event and clk25 = '1' then
      if pixelcount_w = "110" then
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
      else
        strobe_signal <= '0';
      end if;
    end if;
  end process;


  p_pixelcount : process (clk25, ext_reset)
  begin
    if ext_reset = '1' then
      pixelcount_w <= (others => '0');

    elsif clk25'event and clk25 = '1' then
      if (to_integer(hcounter) < (HB + HS - 24))
        or (to_integer(vcounter) < (VB + VS - 2)) then
        pixelcount_w <= (others => '0');
      else
        pixelcount_w <= pixelcount_w + 1;
      end if;
    end if;
  end process;




end behavioral;

