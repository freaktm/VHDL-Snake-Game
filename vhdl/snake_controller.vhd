--------------------------------------------------------------------------------
-- Module Name:    MAINBOARD - behavioral
--
-- Author: Aaron Storey
-- 
-- Description: This module connects all the components together as a system
--              
-- 
-- 
-- Dependencies: VRAM, DCM, LOGIC, VGA, CHROM1 & SHFTREG
-- 
-- 
-- Assisted by:
--
-- Anthonix the great.
-- 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

--library UNISIM;
--use UNISIM.Vcomponents.all;

entity MAINBOARD is
  port(ext_clk_50  : in  std_logic;
       ext_reset   : in  std_logic;
       clks_locked : out std_logic;
       red_out     : out std_logic;
       green_out   : out std_logic;
       blue_out    : out std_logic;
       hs_out      : out std_logic;
       vs_out      : out std_logic;
       ps2d        : in  std_logic;
       ps2c        : in  std_logic
       );
end MAINBOARD;

architecture behavioral of MAINBOARD is

  component KeyboardController is
    port (KeyboardClock : in  std_logic;
           KeyboardData : in  std_logic;
           Direction    : out unsigned(2 downto 0)
           );
  end component;

  component clock_sync is port (
    CLKIN_IN   : in  std_logic;
    RST_IN     : in  std_logic;
    CLK_25_0   : out std_logic;
    CLK_SLOW   : out std_logic;
    LOCKED_OUT : out std_logic
    );
  end component;

  component game_logic is
    port(
    clk25         : in  std_logic;
    ext_reset     : in  std_logic;
    ram_WEA       : out std_logic;
    ram_EN        : out std_logic;
    ram_address_a : out unsigned(12 downto 0);
    ram_input_a   : out unsigned(11 downto 0);
    ram_output_a  : in  unsigned(11 downto 0);
    Direction     : in  unsigned(2 downto 0)

      );
  end component;

  component vga_core is
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
      strobe        : out std_logic;
      row_data      : out unsigned(7 downto 0);
      pixel         : in  std_logic
      );
  end component;

  component screen_ram
    port (
      clk25          : in  std_logic;
      write_enable_a : in  std_logic;
      enable_a       : in  std_logic;
      addr_a         : in  std_logic_vector(12 downto 0);
      addr_b         : in  std_logic_vector(12 downto 0);
      data_input_a   : in  unsigned(11 downto 0);
      data_output_a  : out unsigned(11 downto 0);
      data_output_b  : out unsigned(11 downto 0));
  end component;
  
  component fontrom is port (
    clk25   : in  std_logic;
    address : in  unsigned(8 downto 0);
    data    : out unsigned(7 downto 0)
    );
  end component;

  component serializer is
    port (
      clk    : in  std_logic;
      din    : in  unsigned(7 downto 0);
      strobe : in  std_logic;
      dout   : out std_logic
      );
  end component;


  signal clk25          : std_logic;
 -- signal clk50          : std_logic;
  signal clk_slow : std_logic;          -- game logic clock
  signal WEA            : std_logic;
  signal EN             : std_logic;
  signal address_a      : unsigned(12 downto 0);
  signal address_b      : unsigned(12 downto 0);
  signal data_i_a       : unsigned(11 downto 0);
  signal data_o_a       : unsigned(11 downto 0);
  signal data_o_b       : unsigned(11 downto 0);
  signal number_data    : unsigned(7 downto 0);
  signal number_address : unsigned(8 downto 0);
  signal strobe_sig     : std_logic;
  signal dout_int       : std_logic;
  signal din_int        : unsigned(7 downto 0);
  signal Direction_int  : unsigned(2 downto 0);

  



begin

  -- PS2  Keyboard Controller instantiation


  PS2 : KeyboardController port map (
    KeyboardClock => ps2c,
    KeyboardData  => ps2d,
    Direction     => Direction_int
    );


  -- Clock Manager instantiation 
  DCM : clock_sync port map (
    CLKIN_IN   => ext_clk_50,
    RST_IN     => ext_reset,
    CLK_25_0   => clk25,
    CLK_SLOW   => clk_slow,
    LOCKED_OUT => clks_locked
    );


--  GAME LOGIC instantiation
  LOGIC : game_logic
    port map (
	     clk25         => clk25,
    ext_reset     => ext_reset,
    ram_WEA       => WEA,
    ram_EN        => EN,
    ram_address_a => address_a,
    ram_input_a   => data_i_a,
    ram_output_a  => data_o_a,
    Direction     => Direction_int
	      );



  -- VGA Core instantiation 
  VGA : vga_core port map (
    clk25         => clk25,
    ext_reset     => ext_reset,
    red_out       => red_out,
    green_out     => green_out,
    blue_out      => blue_out,
    hs_out        => hs_out,
    vs_out        => vs_out,
    ram_address_b => address_b,
    ram_data_b    => data_o_b,
    rom_address   => number_address,
    rom_data      => number_data,
    strobe        => strobe_sig,
    row_data      => din_int,
    pixel         => dout_int
    );

  -- VRAM instantiation
  VRAM : screen_ram
    port map (
      clk25          => clk25,
      write_enable_a => WEA,
      enable_a       => EN,
      addr_a         => std_logic_vector(address_a),
      addr_b         => std_logic_vector(address_b),
      data_input_a   => data_i_a,
      data_output_a  => data_o_a,
      data_output_b  => data_o_b);

  -- Character generator memory instantiation
  CHROM : fontrom port map (
    clk25   => clk25,
    address => number_address,
    data    => number_data
    );

-- Serializer instantiation      
  SHFTREG : serializer port map (
    clk    => clk25,
    din    => din_int,
    strobe => strobe_sig,
    dout   => dout_int
    );

end behavioral;

